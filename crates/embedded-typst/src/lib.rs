//! This is a WASM wrapper of the embedded Typst.

#![cfg_attr(feature = "typst-plugin", allow(missing_docs))]

use std::{
    collections::HashMap,
    hash::Hash,
    io::Read,
    ops::Deref,
    path::{Path, PathBuf},
    str::FromStr,
    sync::{Arc, Mutex},
};

use base64::Engine;
use serde::{Deserialize, Serialize, Serializer};
use typst::{
    diag::{eco_format, PackageError},
    foundations::Bytes,
    syntax::{PackageSpec, VirtualPath},
};
use typst_ts_compiler::{
    font::pure::MemoryFontBuilder, service::WorkspaceProvider, vfs::dummy::DummyAccessModel,
    ShadowApi,
};
use typst_ts_core::{
    hash::{FingerprintHasher, FingerprintSipHasher},
    package::{dummy::DummyRegistry, Registry},
    typst::prelude::EcoVec,
    TypstFileId,
};

use wasm_minimal_protocol::*;
initiate_protocol!();

/// A bytes object that is cheap to clone.
#[derive(Clone, Hash)]
struct ImmutBytes(Bytes);

impl Serialize for ImmutBytes {
    fn serialize<S: Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        serializer.serialize_str(&base64::engine::general_purpose::STANDARD.encode(&self.0))
    }
}

impl<'de> Deserialize<'de> for ImmutBytes {
    fn deserialize<D: serde::Deserializer<'de>>(deserializer: D) -> Result<Self, D::Error> {
        let string = String::deserialize(deserializer)?;
        let bytes = base64::engine::general_purpose::STANDARD
            .decode(string.as_bytes())
            .map_err(|e| serde::de::Error::custom(e.to_string()))?;
        Ok(Self(Bytes::from(bytes)))
    }
}

/// A data reference in global data storage.
#[derive(Clone, Deserialize, Serialize, Hash)]
#[serde(tag = "kind")]
enum DataRef {
    #[serde(rename = "font")]
    Font {
        hash: String,
        data: Option<ImmutBytes>,
    },
    #[serde(rename = "package")]
    Package {
        hash: String,
        spec: String,
        data: Option<ImmutBytes>,
    },
    #[serde(rename = "file")]
    File {
        hash: String,
        path: String,
        data: Option<ImmutBytes>,
    },
}

impl DataRef {
    /// Gets the key of the object.
    pub fn key(&self) -> &String {
        match self {
            Self::Font { hash, .. } => hash,
            Self::Package { hash, .. } => hash,
            Self::File { hash, .. } => hash,
        }
    }

    /// Gets the data of the object.
    pub fn data(&self) -> Option<&ImmutBytes> {
        match self {
            Self::Font { data, .. } => data.as_ref(),
            Self::Package { data, .. } => data.as_ref(),
            Self::File { data, .. } => data.as_ref(),
        }
    }

    /// Sets the data of the object.
    pub fn set_data(&mut self, data: ImmutBytes) {
        match self {
            Self::Font { data: d, .. } => *d = Some(data),
            Self::Package { data: d, .. } => *d = Some(data),
            Self::File { data: d, .. } => *d = Some(data),
        }
    }
}

/// Alloccates a data reference
fn allocate_data_inner(kind: &[u8], data: &[u8], path: Option<&[u8]>) -> StrResult<Vec<u8>> {
    let kind = std::str::from_utf8(kind).map_err(|e| e.to_string())?;
    let data = ImmutBytes(Bytes::from(data));
    let hash = {
        let mut hasher = FingerprintSipHasher::default();
        kind.hash(&mut hasher);
        data.hash(&mut hasher);
        hasher.finish_fingerprint().0.as_svg_id("")
    };

    let data_ref = match kind {
        "font" => DataRef::Font {
            hash: hash.clone(),
            data: Some(data),
        },
        "package" => {
            let path = std::str::from_utf8(path.unwrap()).map_err(|e| e.to_string())?;
            DataRef::Package {
                hash: hash.clone(),
                spec: path.to_string(),
                data: Some(data),
            }
        }
        "file" => {
            let path = std::str::from_utf8(path.unwrap()).map_err(|e| e.to_string())?;
            DataRef::File {
                hash: hash.clone(),
                path: path.to_owned(),
                data: Some(data),
            }
        }
        _ => return Err(format!("Unknown data kind: {kind}")),
    };

    let mut data = DATA
        .get_or_init(|| Mutex::new(HashMap::new()))
        .lock()
        .unwrap();

    data.insert(hash.clone(), data_ref);

    Ok(hash.into_bytes())
}

/// Encodes a string to base64.
///
/// # Errors
///
/// Error if there is an error
#[cfg_attr(feature = "typst-plugin", wasm_func)]
pub fn encode_base64(data: &[u8]) -> Vec<u8> {
    base64::engine::general_purpose::STANDARD
        .encode(data)
        .into_bytes()
}

/// Alloccates a data reference, return the key of the data reference.
///
/// # Panics
///
/// Panics if the world is not initialized.
///
/// # Errors
///
/// Error if there is an error
#[cfg_attr(feature = "typst-plugin", wasm_func)]
pub fn allocate_data(kind: &[u8], data: &[u8]) -> StrResult<Vec<u8>> {
    allocate_data_inner(kind, data, None)
}

/// Alloccates a file reference, return the key of the data reference.
///
/// # Panics
///
/// Panics if the world is not initialized.
///
/// # Errors
///
/// Error if there is an error
#[cfg_attr(feature = "typst-plugin", wasm_func)]
pub fn allocate_file(kind: &[u8], path: &[u8], data: &[u8]) -> StrResult<Vec<u8>> {
    allocate_data_inner(kind, data, Some(path))
}

/// The global data storage.
static DATA: std::sync::OnceLock<Mutex<HashMap<String, DataRef>>> = std::sync::OnceLock::new();

/// Makes `instant::SystemTime::now` happy
pub extern "C" fn now() -> f64 {
    0.0
}

/// A context that is used to resolve a world context.
#[derive(Deserialize, Serialize, Hash)]
pub struct Context {
    /// The data that are used in the main file.
    data: Vec<DataRef>,
}

type StrResult<T> = Result<T, String>;

/// Resolves data references.
fn resolve_data(mut ctx: Context) -> StrResult<Context> {
    // The missing data will cause an exception.
    let mut missing_data = Vec::new();

    let mut data = DATA
        .get_or_init(|| Mutex::new(HashMap::new()))
        .lock()
        .unwrap();

    for f in ctx.data.iter_mut() {
        let data_entry = data.get(f.key().as_str());

        match (data_entry, f.data()) {
            // Borrow data from the global storage.
            (Some(data_entry), None) => {
                f.set_data(data_entry.data().unwrap().clone());
            }
            // Add data to the global storage.
            (None, Some(..)) => {
                data.insert(f.key().clone(), f.clone());
            }
            // Error if there is no data.
            (None, None) => {
                missing_data.push(f.key().clone());
            }
            (Some(_), Some(_)) => {}
        }
    }

    // All data are resolved.
    if missing_data.is_empty() {
        return Ok(ctx);
    }

    // Some data are missing.
    Err(missing_data.join(", "))
}

/// Resolves a world by context.
fn resolve_world(ctx: &[u8]) -> StrResult<Arc<Mutex<WorldRepr>>> {
    /// Extracts a package.
    fn extract_package(
        data: &[u8],
        mut cb: impl FnMut(String, &[u8], u64) -> StrResult<()>,
    ) -> StrResult<()> {
        let decompressed = flate2::read::GzDecoder::new(data);
        let mut reader = tar::Archive::new(decompressed);
        let entries = reader.entries();
        let entries = entries.map_err(|err| {
            let t = PackageError::MalformedArchive(Some(eco_format!("{err}")));
            format!("{t:?}",)
        })?;

        let mut buf = Vec::with_capacity(1024);
        for entry in entries {
            // Read single entry
            let mut entry = entry.map_err(|e| e.to_string())?;
            let header = entry.header();

            let is_file = header.entry_type().is_file();
            if !is_file {
                continue;
            }

            let mtime = header.mtime().unwrap_or(0);

            let path = header.path().map_err(|e| e.to_string())?;
            let path = path.to_string_lossy().as_ref().to_owned();

            let size = header.size().map_err(|e| e.to_string())?;
            buf.clear();
            buf.reserve(size as usize);
            entry.read_to_end(&mut buf).map_err(|e| e.to_string())?;

            cb(path, &buf, mtime)?
        }

        Ok(())
    }

    /// Creates a world based on the context.
    #[comemo::memoize]
    fn resolve_world_inner(ctx: Context) -> StrResult<Arc<Mutex<WorldRepr>>> {
        // Adds embedded fonts.
        let mut fb = MemoryFontBuilder::new();
        let mut pb = MemoryPackageBuilder::default();

        let vfs = typst_ts_compiler::vfs::Vfs::new(DummyAccessModel);

        for data in ctx.data {
            match data {
                DataRef::Font { data, .. } => {
                    fb.add_memory_font(data.unwrap().0);
                }
                DataRef::Package { data, spec, .. } => {
                    let spec = PackageSpec::from_str(&spec).map_err(|e| e.to_string())?;
                    let path = pb.add_memory_package(spec);

                    let data = data.unwrap().0;
                    extract_package(&data, |key, value, _mtime| {
                        vfs.map_shadow(&path.join(key.as_str()), Bytes::from(value.to_owned()))
                            .map_err(|e| e.to_string())
                    })?;
                }
                DataRef::File { .. } => {}
            }
        }

        for data in EMBEDDED_FONT {
            fb.add_memory_font(Bytes::from_static(data));
        }

        // Creates a world.
        let world = WorldRepr::new_raw(PathBuf::from("/"), vfs, DummyRegistry, fb.into());

        Ok(Arc::new(Mutex::new(world)))
    }

    // Deserializes context.
    let ctx = serde_json::from_slice::<Context>(ctx).map_err(|e| e.to_string())?;
    let mut ctx = resolve_data(ctx)?;

    // Removes files from the context as they are not used for resolving a world.
    let mut files = Vec::new();
    ctx.data.retain(|f| match f {
        DataRef::File { .. } => {
            files.push(f.clone());
            false
        }
        _ => true,
    });

    let world = resolve_world_inner(ctx)?;

    // Adds files to the world.
    let world_mut = world.lock().unwrap();
    for f in files.into_iter() {
        let path = match &f {
            DataRef::File { path, .. } => path,
            _ => unreachable!(),
        };
        let path = Path::new(path);
        let data = f.data().cloned().unwrap().0;
        world_mut
            .map_shadow(path, data)
            .map_err(|e| e.to_string())?;
    }
    drop(world_mut);

    Ok(world)
}

/// Compile a typst file to svg.
///
/// # Panics
///
/// Panics if the world is not initialized.
///
/// # Errors
///
/// Error if there is an error
#[cfg_attr(feature = "typst-plugin", wasm_func)]
pub fn svg(context: &[u8], input: &[u8]) -> StrResult<Vec<u8>> {
    // Resolves the world.
    let world = resolve_world(context);
    let world = match world {
        Ok(world) => world,
        // Traps the function if not all data are resolved.
        Err(e) => {
            let mut t = b"code-trapped, ".to_vec();
            t.append(&mut e.into_bytes());
            return Ok(t);
        }
    };
    let mut world = world.lock().unwrap();
    world.reset();

    // Prepare main file.
    let entry_file = Path::new("/main.typ");
    world.set_main_id(TypstFileId::new(None, VirtualPath::new(entry_file)));
    world
        .map_shadow(entry_file, Bytes::from(input.to_owned()))
        .map_err(|e| e.to_string())?;

    // Compile.
    let mut tracer = Default::default();
    let doc = typst::compile(world.deref(), &mut tracer).map_err(
        |e: EcoVec<typst::diag::SourceDiagnostic>| {
            let mut error_log = String::new();
            for c in e.into_iter() {
                error_log.push_str(&format!(
                    "{:?}\n",
                    typst_ts_core::error::diag_from_std(c, Some(world.deref()))
                ));
            }
            error_log
        },
    )?;

    // Query header.
    let header =
        typst_ts_compiler::service::query::retrieve(world.deref(), "<embedded-typst>", &doc);
    let header = match header {
        Ok(header) => serde_json::to_vec(&header).map_err(|e| e.to_string())?,
        Err(e) => serde_json::to_vec(&e).map_err(|e| e.to_string())?,
    };

    // Build payload.
    Ok((Some(header).into_iter())
        .chain(
            doc.pages
                .iter()
                .map(|page| typst_svg::svg(page).into_bytes()),
        )
        .collect::<Vec<_>>()
        .join(&b"\n\n\n\n\n\n\n\n"[..]))
    // Ok(b"Hello world".to_vec())
}

/// type trait of [`TypstWasmWorld`].
#[derive(Debug, Clone, Copy)]
pub struct WasmCompilerFeat;

impl typst_ts_compiler::world::CompilerFeat for WasmCompilerFeat {
    /// It accesses no file system.
    type AccessModel = DummyAccessModel;
    /// It cannot load any package.
    type Registry = DummyRegistry;
}

type WorldRepr = typst_ts_compiler::world::CompilerWorld<WasmCompilerFeat>;

/// The compiler world in wasm environment.
pub struct TypstWasmWorld(WorldRepr);

impl Default for TypstWasmWorld {
    fn default() -> Self {
        Self::new()
    }
}

impl TypstWasmWorld {
    /// Create a new [`TypstWasmWorld`].
    pub fn new() -> Self {
        // Creates a virtual file system.
        let vfs = typst_ts_compiler::vfs::Vfs::new(DummyAccessModel);

        // Adds embedded fonts.
        let mut fb = MemoryFontBuilder::new();
        for data in EMBEDDED_FONT {
            fb.add_memory_font(Bytes::from_static(data));
        }

        // Creates a world.
        Self(WorldRepr::new_raw(
            PathBuf::from("/"),
            vfs,
            DummyRegistry,
            fb.into(),
        ))
    }
}

pub static EMBEDDED_FONT: &[&[u8]] = &[];

/// A builder of memory package.
#[derive(Default, Debug)]
pub struct MemoryPackageBuilder(HashMap<PackageSpec, Arc<Path>>);

impl MemoryPackageBuilder {
    /// Adds a memory package.
    pub fn add_memory_package(&mut self, spec: PackageSpec) -> Arc<Path> {
        let package_root: Arc<Path> = PathBuf::from("/internal-packages")
            .join(spec.name.as_str())
            .join(spec.version.to_string())
            .into();

        self.0.insert(spec, package_root.clone());

        package_root
    }
}

#[derive(Default, Debug)]
pub struct MemoryPackageRegistry(HashMap<PackageSpec, Arc<Path>>);

impl Registry for MemoryPackageRegistry {
    /// Resolves a package.
    fn resolve(&self, spec: &PackageSpec) -> Result<Arc<Path>, PackageError> {
        self.0
            .get(spec)
            .cloned()
            .ok_or_else(|| PackageError::NotFound(spec.clone()))
    }
}
