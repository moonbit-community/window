///|
fn main {
  let _ = @core.ControlFlow::Wait
  let _ = @macos.backend_available()
  println("cmd/main is only supported on native macOS in this MVP")
}
