///|
fn main {
  let _ = @core.ControlFlow::Wait
  let _ = @macos.backend_available()
  println("examples/window is only available on the native macOS backend")
}
