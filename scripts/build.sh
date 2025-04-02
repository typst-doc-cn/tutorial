#!/bin/bash

cargo build --release --target wasm32-unknown-unknown

INSTALL_PATH="assets/artifacts/embedded_typst.wasm"
if [ -f "$INSTALL_PATH" ]; then
    rm "$INSTALL_PATH"
fi

mv target/wasm32-unknown-unknown/release/embedded_typst.wasm $INSTALL_PATH
