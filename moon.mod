name = "Milky2018/window"

version = "0.5.3"

preferred_target = "native"

readme = "README.mbt.md"

repository = "https://github.com/moonbit-community/window.git"

license = "Apache-2.0"

keywords = [ "windowing", "winit", "macos", "appkit", "gui" ]

description = "A MoonBit port of winit with a native macOS event loop and windowing backend."

options(
  "--moonbit-unstable-prebuild": "build.js",
)
