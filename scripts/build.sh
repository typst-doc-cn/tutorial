#!/bin/bash

cargo build --release --target wasm32-unknown-unknown

INSTALL_PATH="assets/artifacts/embedded_typst.wasm"
if [ -f "$INSTALL_PATH" ]; then
    rm "$INSTALL_PATH"
fi

# https://github.com/dicej/stubber
stubber -m wasi_snapshot_preview1 -m __wbindgen_placeholder__ -m __wbindgen_externref_xform__ < target/wasm32-unknown-unknown/release/embedded_typst.wasm > "$INSTALL_PATH"
