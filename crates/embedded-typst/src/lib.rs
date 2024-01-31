//! This is a WASM wrapper of the embedded Typst.

#![cfg_attr(feature = "typst-plugin", allow(missing_docs))]

use std::path::{Path, PathBuf};

use typst::{foundations::Bytes, syntax::VirtualPath};
use typst_ts_compiler::{
    font::pure::MemoryFontBuilder, service::WorkspaceProvider, vfs::dummy::DummyAccessModel,
    ShadowApi,
};
use typst_ts_core::{package::dummy::DummyRegistry, typst::prelude::EcoVec, TypstFileId};

use wasm_minimal_protocol::*;
initiate_protocol!();

/// Makes `instant::SystemTime::now` happy
pub extern "C" fn now() -> f64 {
    0.0
}

/// Compile a typst file to svg.
///
/// # Errors
///
/// Error if there is an error
#[cfg_attr(feature = "typst-plugin", wasm_func)]
pub fn svg(input: &[u8]) -> Result<Vec<u8>, String> {
    let mut world = TypstWasmWorld::new().0;

    // Prepare main file.
    let entry_file = Path::new("/main.typ");
    world.set_main_id(TypstFileId::new(None, VirtualPath::new(entry_file)));
    world
        .map_shadow(entry_file, Bytes::from(input.to_owned()))
        .map_err(|e| e.to_string())?;

    // Compile.
    let mut tracer = Default::default();
    let doc = typst::compile(&world, &mut tracer).map_err(
        |e: EcoVec<typst::diag::SourceDiagnostic>| {
            let mut error_log = String::new();
            for c in e.into_iter() {
                error_log.push_str(&format!(
                    "{:?}\n",
                    typst_ts_core::error::diag_from_std(c, Some(&world))
                ));
            }
            error_log
        },
    )?;

    // Query header.
    let header = typst_ts_compiler::service::query::retrieve(&world, "<embedded-typst>", &doc);
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
    /// It accesses nofile system.
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

macro_rules! add_embedded_font {
    ($name:literal) => {
        include_bytes!(concat!("../../../assets/typst-fonts/", $name)).as_slice()
    };
}

pub static EMBEDDED_FONT: &[&[u8]] = &[
    // Embed default fonts.
    add_embedded_font!("LinLibertine_R.ttf"),
    add_embedded_font!("LinLibertine_RB.ttf"),
    add_embedded_font!("LinLibertine_RBI.ttf"),
    add_embedded_font!("LinLibertine_RI.ttf"),
    add_embedded_font!("NewCMMath-Book.otf"),
    add_embedded_font!("NewCMMath-Regular.otf"),
    add_embedded_font!("NewCM10-Regular.otf"),
    add_embedded_font!("NewCM10-Bold.otf"),
    add_embedded_font!("NewCM10-Italic.otf"),
    add_embedded_font!("NewCM10-BoldItalic.otf"),
    add_embedded_font!("DejaVuSansMono.ttf"),
    add_embedded_font!("DejaVuSansMono-Bold.ttf"),
    add_embedded_font!("DejaVuSansMono-Oblique.ttf"),
    add_embedded_font!("DejaVuSansMono-BoldOblique.ttf"),
];
