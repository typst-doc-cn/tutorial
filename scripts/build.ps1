cargo build --release --target wasm32-unknown-unknown --manifest-path ./crates/embedded-typst/Cargo.toml --features typst-plugin
$InstallPath = "assets/artifacts/embedded_typst.wasm"
if (Test-Path $InstallPath) {
    Remove-Item $InstallPath
}
Move-Item target/wasm32-unknown-unknown/release/embedded_typst.wasm $InstallPath
