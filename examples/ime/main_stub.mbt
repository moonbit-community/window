///|
fn main {
  let _ = @core.ControlFlow::Wait
  let _ = @dpi.LogicalSize::new(1.0, 1.0)
  let _ = @macos.backend_available()
  println("examples/ime is only available on the native macOS backend")
}
