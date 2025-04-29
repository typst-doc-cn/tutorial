//! This is a WASM wrapper of the embedded Typst.

#![cfg_attr(feature = "typst-plugin", allow(missing_docs))]

use std::{
    collections::HashMap,
    io::Read,
    path::{Path, PathBuf},
    str::FromStr,
    sync::{Arc, Mutex, RwLock},
    vec,
};

use reflexo_typst::{
    font::{pure::MemoryFontSearcher, FontResolverImpl},
    package::{PackageRegistry, PackageSpec, RegistryPathMapper},
    typst::prelude::EcoVec,
    vfs::{dummy::DummyAccessModel, FileSnapshot},
    CompilerUniverse, EntryReader, EntryState, ShadowApi, TaskInputs, TypstDocument,
    TypstPagedDocument,
};
use typst::{
    diag::{eco_format, FileResult, PackageError},
    foundations::Bytes,
    Features,
};

use wasm_minimal_protocol::*;
initiate_protocol!();

type StrResult<T> = Result<T, String>;

/// Allocates a data reference, return the key of the data reference.
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

/// Allocates a file reference, return the key of the data reference.
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

/// Allocates a data reference
fn allocate_data_inner(kind: &[u8], data: &[u8], path: Option<&[u8]>) -> StrResult<Vec<u8>> {
    let kind = std::str::from_utf8(kind).map_err(|e| e.to_string())?;
    let data = ImmutBytes(Bytes::new(data.to_owned()));

    let data_ref = match kind {
        "font" => DataRef::Font { data: Some(data) },
        "package" => {
            let path = std::str::from_utf8(path.unwrap()).map_err(|e| e.to_string())?;
            DataRef::Package {
                spec: path.to_string(),
                data: Some(data),
            }
        }
        "file" => {
            let path = std::str::from_utf8(path.unwrap()).map_err(|e| e.to_string())?;
            DataRef::File {
                path: path.to_owned(),
                data: Some(data),
            }
        }
        _ => return Err(format!("Unknown data kind: {kind}")),
    };

    let mut data = DATA.lock().unwrap();

    data.data.push(data_ref);

    Ok(vec![0])
}

/// A context that is used to resolve a world context.
pub struct Context {
    /// The data that are used in the main file.
    data: Vec<DataRef>,
}

static DATA: Mutex<Context> = Mutex::new(Context { data: vec![] });

/// A bytes object that is cheap to clone.
#[derive(Clone)]
struct ImmutBytes(Bytes);

/// A data reference in global data storage.
#[derive(Clone)]
enum DataRef {
    Font {
        data: Option<ImmutBytes>,
    },
    Package {
        spec: String,
        data: Option<ImmutBytes>,
    },
    File {
        path: String,
        data: Option<ImmutBytes>,
    },
}

impl DataRef {
    /// Gets the data of the object.
    pub fn data(&self) -> Option<&ImmutBytes> {
        match self {
            Self::Font { data, .. } => data.as_ref(),
            Self::Package { data, .. } => data.as_ref(),
            Self::File { data, .. } => data.as_ref(),
        }
    }
}

static VERSE: RwLock<Option<WorldRepr>> = RwLock::new(None);

/// Resolves a world
#[cfg_attr(feature = "typst-plugin", wasm_func)]
pub fn resolve_world() -> StrResult<Vec<u8>> {
    let resolved = create_world()?;
    let mut world = VERSE.write().unwrap();
    if world.is_some() {
        return Err("World is already initialized".to_string());
    }

    *world = Some(resolved);

    Ok(vec![])
}

/// Creates a world
fn create_world() -> StrResult<WorldRepr> {
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
    fn resolve_world_inner() -> StrResult<WorldRepr> {
        let data_guard = DATA.lock().unwrap();

        // Adds embedded fonts.
        let mut fb = MemoryFontSearcher::new();
        let mut pb = MemoryRegistry::default();

        for data in &data_guard.data {
            match data {
                DataRef::Font { data, .. } => {
                    fb.add_memory_font(data.clone().unwrap().0);
                }
                DataRef::Package { spec, .. } => {
                    let spec = PackageSpec::from_str(spec).map_err(|e| e.to_string())?;
                    pb.add_memory_package(spec);
                }
                DataRef::File { .. } => {}
            }
        }

        let registry = Arc::new(pb);
        let resolver = Arc::new(RegistryPathMapper::new(registry.clone()));
        let mut vfs = reflexo_typst::vfs::Vfs::new(resolver, DummyAccessModel);

        for data in &data_guard.data {
            match data {
                DataRef::Package { data, spec, .. } => {
                    let spec = PackageSpec::from_str(spec).map_err(|e| e.to_string())?;
                    let path = registry.resolve(&spec).map_err(|e| e.to_string())?;

                    let data = data.clone().unwrap().0;
                    extract_package(&data, |key, value, _mtime| {
                        vfs.revise()
                            .map_shadow(
                                &path.join(key.as_str()),
                                FileSnapshot::from(FileResult::Ok(Bytes::new(value.to_owned()))),
                            )
                            .map_err(|e| e.to_string())
                    })?;
                }
                DataRef::Font { .. } | DataRef::File { .. } => {}
            }
        }

        for data in EMBEDDED_FONT {
            fb.add_memory_font(Bytes::new(data));
        }

        // Creates a world.
        let world = WorldRepr::new_raw(
            EntryState::new_workspace(PathBuf::from("/").into()),
            Features::default(),
            None,
            vfs,
            registry,
            Arc::new(fb.build()),
        );

        Ok(world)
    }

    // Removes files from the context as they are not used for resolving a world.
    let mut files = Vec::new();
    let _ = &DATA.lock().unwrap().data.retain(|f| match f {
        DataRef::File { .. } => {
            files.push(f.clone());
            false
        }
        _ => true,
    });
    let mut world = resolve_world_inner()?;

    for f in files.into_iter() {
        let path = match &f {
            DataRef::File { path, .. } => path,
            _ => unreachable!(),
        };
        let path = Path::new(path);
        let data = f.data().cloned().unwrap().0;
        world.map_shadow(path, data).map_err(|e| e.to_string())?;
    }
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
pub fn svg(input: &[u8]) -> StrResult<Vec<u8>> {
    let verse = VERSE.read().unwrap();
    let Some(verse) = verse.as_ref() else {
        return Err("World is not initialized".to_string());
    };

    // Prepare main file.
    let entry_file = Path::new("/main.typ");
    let entry = verse.entry_state().select_in_workspace(entry_file);

    // Compile.
    let mut world = verse.snapshot_with(Some(TaskInputs {
        entry: Some(entry),
        inputs: None,
    }));
    world
        .map_shadow(entry_file, Bytes::new(input.to_owned()))
        .map_err(|e| e.to_string())?;

    // todo: warning
    let doc: TypstPagedDocument =
        typst::compile(&world)
            .output
            .map_err(|e: EcoVec<typst::diag::SourceDiagnostic>| {
                let mut error_log = String::new();
                for c in e.into_iter() {
                    error_log.push_str(&format!(
                        "{:?}\n",
                        reflexo_typst::error::diag_from_std(c, Some(&world))
                    ));
                }
                error_log
            })?;

    let pages_data: Vec<_> = doc
        .pages
        .iter()
        .map(|page| typst_svg::svg(page).into_bytes())
        .collect();

    let doc = Arc::new(doc);
    let typ_doc = TypstDocument::Paged(doc);
    // Query header.
    let header = reflexo_typst::query::retrieve(&world, "<embedded-typst>", &typ_doc);
    let header = match header {
        Ok(header) => serde_json::to_vec(&header).map_err(|e| e.to_string())?,
        Err(e) => serde_json::to_vec(&e).map_err(|e| e.to_string())?,
    };

    // Build payload.
    Ok((Some(header).into_iter())
        .chain(pages_data)
        .collect::<Vec<_>>()
        .join(&b"\n\n\n\n\n\n\n\n"[..]))
}

/// type trait of [`TypstWasmWorld`].
#[derive(Debug, Clone, Copy)]
pub struct WasmCompilerFeat;

impl reflexo_typst::world::CompilerFeat for WasmCompilerFeat {
    /// It accesses no file system.
    type FontResolver = FontResolverImpl;
    /// It accesses no file system.
    type AccessModel = DummyAccessModel;
    /// It cannot load any package.
    type Registry = MemoryRegistry;
}

type WorldRepr = reflexo_typst::world::CompilerUniverse<WasmCompilerFeat>;

/// The compiler world in wasm environment.
#[allow(unused)]
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
        let registry = Arc::new(MemoryRegistry::default());
        let resolver = Arc::new(RegistryPathMapper::new(registry.clone()));
        let vfs = reflexo_typst::vfs::Vfs::new(resolver, DummyAccessModel);

        // Adds embedded fonts.
        let mut fb = MemoryFontSearcher::new();

        for data in EMBEDDED_FONT {
            fb.add_memory_font(Bytes::new(data));
        }

        // Creates a world.
        Self(CompilerUniverse::new_raw(
            EntryState::new_workspace(PathBuf::from("/").into()),
            Features::default(),
            None,
            vfs,
            registry,
            Arc::new(fb.build()),
        ))
    }
}

pub static EMBEDDED_FONT: &[&[u8]] = &[];

/// Creates a memory package registry from the builder.
#[derive(Default, Debug)]
pub struct MemoryRegistry(HashMap<PackageSpec, Arc<Path>>);

impl MemoryRegistry {
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

impl PackageRegistry for MemoryRegistry {
    /// Resolves a package.
    fn resolve(&self, spec: &PackageSpec) -> Result<Arc<Path>, PackageError> {
        self.0
            .get(spec)
            .cloned()
            .ok_or_else(|| PackageError::NotFound(spec.clone()))
    }
}

/// Makes `instant::SystemTime::now` happy
pub extern "C" fn now() -> f64 {
    0.0
}
