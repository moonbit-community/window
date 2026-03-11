///|
fn main {
  let _ = @core.ControlFlow::Wait
  let _ = @macos.backend_available()
  println("examples/pump_events is only available on the native macOS backend")
}
