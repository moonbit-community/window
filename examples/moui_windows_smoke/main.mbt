///|
struct App {
  mut window : @windows.Window?
  mut saw_handle : Bool
  mut saw_monitor : Bool
  mut saw_cursor : Bool
  mut saw_redraw : Bool
  mut saw_resize : Bool
  mut saw_pointer : Bool
  mut saw_keyboard : Bool
  mut saw_text : Bool
  mut saw_ime_probe : Bool
  mut saw_destroyed : Bool
  mut requested_resize : Bool
  mut requested_input : Bool
  mut destroy_requested : Bool
  mut ready_printed : Bool
  mut wait_count : Int
}

///|
extern "C" fn native_send_input(raw_hwnd : UInt64) -> Int = "mbw_moui_windows_smoke_send_input"

///|
fn App::maybe_ready(self : App, event_loop : @windows.ActiveEventLoop) -> Unit {
  if !self.ready_printed &&
    self.saw_handle &&
    self.saw_monitor &&
    self.saw_cursor &&
    self.saw_redraw &&
    self.saw_resize &&
    self.saw_pointer &&
    self.saw_keyboard &&
    self.saw_text &&
    self.saw_ime_probe {
    self.ready_printed = true
    println("MOUIWindowsSmoke: ready")
    self.request_destroy(event_loop)
  }
}

///|
fn App::request_destroy(
  self : App,
  event_loop : @windows.ActiveEventLoop,
) -> Unit {
  if !self.destroy_requested {
    self.destroy_requested = true
    match self.window {
      Some(window) => {
        window.drop()
        self.window = None
        println("MOUIWindowsSmoke: destroy requested")
      }
      None => event_loop.exit()
    }
  }
}

///|
fn log_surface(window : @windows.Window) -> Unit {
  let size = window.surface_size()
  println(
    "MOUIWindowsSmoke: surface size=\{size.width()}x\{size.height()} scale=\{window.scale_factor()}",
  )
}

///|
fn log_handle(window : @windows.Window) -> Bool {
  let hwnd = window.window_handle()
  let display = window.display_handle()
  let raw_display = window.rwh_06_display_handle()
  let raw_window = window.rwh_06_window_handle()
  println(
    "MOUIWindowsSmoke: handle hwnd=0x\{hwnd.to_string(radix=16)} hinstance=0x\{display.to_string(radix=16)} raw_display=0x\{raw_display.to_string(radix=16)} raw_window=0x\{raw_window.to_string(radix=16)}",
  )
  hwnd != (0 : Int).to_uint64() &&
  display != (0 : Int).to_uint64() &&
  raw_display == display &&
  raw_window == hwnd
}

///|
fn log_monitor_probe(window : @windows.Window) -> Bool {
  let monitors = window.available_monitors()
  let primary = window.primary_monitor()
  let current = window.current_monitor()
  let primary_id = match primary {
    Some(monitor) => monitor.native_id()
    None => 0UL
  }
  let current_id = match current {
    Some(monitor) => monitor.native_id()
    None => 0UL
  }
  println(
    "MOUIWindowsSmoke: monitors count=\{monitors.length()} primary=\{primary is Some(_)} primary_id=0x\{primary_id.to_string(radix=16)} current=\{current is Some(_)} current_id=0x\{current_id.to_string(radix=16)}",
  )
  monitors.length() > 0 && primary is Some(_) && current is Some(_)
}

///|
fn log_cursor_probe(window : @windows.Window) -> Bool {
  window.set_cursor_icon(Text)
  let cursor = window.cursor()
  println("MOUIWindowsSmoke: cursor \{cursor}")
  cursor == Icon(Text)
}

///|
fn log_ime_probe(window : @windows.Window) -> Bool {
  let position : @dpi.Position = @dpi.LogicalPosition::LogicalPosition(
    12.0, 18.0,
  ).into_position()
  let size : @dpi.Size = @dpi.LogicalSize::LogicalSize(2.0, 20.0).into_size()
  let updated_position : @dpi.Position = @dpi.LogicalPosition::LogicalPosition(
    14.0, 20.0,
  ).into_position()
  let updated_size : @dpi.Size = @dpi.LogicalSize::LogicalSize(3.0, 21.0).into_size()
  let surrounding = @core.ImeSurroundingText::ImeSurroundingText("moui", 4, 4) catch {
    _ => {
      println("MOUIWindowsSmoke: ime probe surrounding failed")
      return false
    }
  }
  let updated_surrounding = @core.ImeSurroundingText::ImeSurroundingText(
    "moui!", 5, 5,
  ) catch {
    _ => {
      println("MOUIWindowsSmoke: ime probe update surrounding failed")
      return false
    }
  }
  let data = @core.ImeRequestData::default()
    .with_hint_and_purpose(@core.ImeHint::completion(), Email)
    .with_surrounding_text(surrounding)
    .with_cursor_area(position, size)
  let update_data = @core.ImeRequestData::default()
    .with_hint_and_purpose(@core.ImeHint::spellcheck(), Url)
    .with_surrounding_text(updated_surrounding)
    .with_cursor_area(updated_position, updated_size)
  let enable = @core.ImeEnableRequest::from_capabilities(
    @core.ImeCapabilities::default()
    .with_hint_and_purpose()
    .with_surrounding_text()
    .with_cursor_area(),
    data,
  )
  guard enable is Some(enable) else {
    println("MOUIWindowsSmoke: ime probe enable request failed")
    return false
  }
  window.request_ime_update(Enable(enable)) catch {
    err => {
      println("MOUIWindowsSmoke: ime probe enable failed \{err}")
      return false
    }
  }
  let scale = window.scale_factor()
  let expected_position = position.to_physical(scale)
  let expected_size = size.to_physical(scale)
  let enabled = window.ime_capabilities() is Some(_)
  let hint_ok = window.ime_hints().contains(@core.ImeHint::completion()) &&
    window.ime_purpose() == Email
  let surrounding_ok = match window.ime_surrounding_text() {
    Some(text) => text.text() == "moui"
    None => false
  }
  let cursor_ok = window.ime_cursor_area_position() == expected_position &&
    window.ime_cursor_area_size() == expected_size
  window.request_ime_update(Update(update_data)) catch {
    err => {
      println("MOUIWindowsSmoke: ime probe update failed \{err}")
      return false
    }
  }
  let expected_updated_position = updated_position.to_physical(scale)
  let expected_updated_size = updated_size.to_physical(scale)
  let updated_hint_ok = window.ime_hints().contains(@core.ImeHint::spellcheck()) &&
    window.ime_purpose() == Url
  let updated_ok = match window.ime_surrounding_text() {
    Some(text) => text.text() == "moui!"
    None => false
  }
  let updated_cursor_ok = window.ime_cursor_area_position() ==
    expected_updated_position &&
    window.ime_cursor_area_size() == expected_updated_size
  window.request_ime_update(Disable) catch {
    err => {
      println("MOUIWindowsSmoke: ime probe disable failed \{err}")
      return false
    }
  }
  let disabled = window.ime_capabilities() is None
  println(
    "MOUIWindowsSmoke: ime probe enabled=\{enabled} hint=\{hint_ok} surrounding=\{surrounding_ok} cursor=\{cursor_ok} updated=\{updated_ok} updated_hint=\{updated_hint_ok} updated_cursor=\{updated_cursor_ok} disabled=\{disabled}",
  )
  enabled &&
  hint_ok &&
  surrounding_ok &&
  cursor_ok &&
  updated_ok &&
  updated_hint_ok &&
  updated_cursor_ok &&
  disabled
}

///|
pub impl @windows.ApplicationHandler for App with fn can_create_surfaces(
  self,
  event_loop,
) {
  event_loop.set_control_flow(Poll)
  let initial_size : @dpi.PhysicalSize = PhysicalSize(320, 180)
  let attributes = @core.WindowAttributes::default()
    .with_title("MoUI Windows smoke")
    .with_surface_size(initial_size.into_size())
  let window : @windows.Window? = Some(event_loop.try_create_window(attributes)) catch {
    err => {
      println("MOUIWindowsSmoke: create failed \{err}")
      event_loop.exit()
      None
    }
  }
  match window {
    Some(window) => {
      self.window = Some(window)
      log_surface(window)
      self.saw_handle = log_handle(window)
      self.saw_monitor = log_monitor_probe(window)
      self.saw_cursor = log_cursor_probe(window)
      self.saw_ime_probe = log_ime_probe(window)
      let resized_size : @dpi.PhysicalSize = PhysicalSize(400, 240)
      ignore(window.request_surface_size(resized_size.into_size()))
      self.requested_resize = true
      println(
        "MOUIWindowsSmoke: resize requested size=\{resized_size.width()}x\{resized_size.height()}",
      )
      if native_send_input(window.window_handle()) != 0 {
        self.requested_input = true
        println("MOUIWindowsSmoke: input requested")
      } else {
        println("MOUIWindowsSmoke: input request failed")
      }
      window.request_redraw()
    }
    None => ()
  }
}

///|
pub impl @windows.ApplicationHandler for App with fn window_event(
  self,
  event_loop,
  _window_id,
  event,
) {
  match event {
    SurfaceResized(size) => {
      self.saw_resize = true
      println("MOUIWindowsSmoke: resize size=\{size.width()}x\{size.height()}")
      match self.window {
        Some(window) => window.request_redraw()
        None => ()
      }
      self.maybe_ready(event_loop)
    }
    RedrawRequested => {
      self.saw_redraw = true
      match self.window {
        Some(window) => {
          window.pre_present_notify()
          println("MOUIWindowsSmoke: redraw pre_present_notify")
        }
        None => ()
      }
      self.maybe_ready(event_loop)
    }
    PointerMoved(_, position, _, _) => {
      self.saw_pointer = true
      println("MOUIWindowsSmoke: pointer x=\{position.x()} y=\{position.y()}")
      self.maybe_ready(event_loop)
    }
    KeyboardInput(_, key_event, false) =>
      if key_event.state() is Pressed {
        match key_event.logical_key() {
          Character(key) => {
            println("MOUIWindowsSmoke: keyboard key=\{key}")
            if key == "a" {
              self.saw_keyboard = true
            }
          }
          _ => println("MOUIWindowsSmoke: keyboard pressed")
        }
        self.maybe_ready(event_loop)
      }
    Ime(Commit(text)) => {
      self.saw_text = true
      println("MOUIWindowsSmoke: ime text=\{text}")
      self.maybe_ready(event_loop)
    }
    Destroyed => {
      self.saw_destroyed = true
      println("MOUIWindowsSmoke: destroyed")
      event_loop.exit()
    }
    CloseRequested => event_loop.exit()
    _ => ()
  }
}

///|
pub impl @windows.ApplicationHandler for App with fn about_to_wait(
  self,
  event_loop,
) {
  self.wait_count += 1
  match self.window {
    Some(window) => if !self.saw_redraw { window.request_redraw() }
    None => ()
  }
  self.maybe_ready(event_loop)
  if self.wait_count > 500 &&
    (!self.ready_printed || (self.destroy_requested && !self.saw_destroyed)) {
    println(
      "MOUIWindowsSmoke: failed handles=\{self.saw_handle} monitor=\{self.saw_monitor} cursor=\{self.saw_cursor} redraw=\{self.saw_redraw} resize=\{self.saw_resize} pointer=\{self.saw_pointer} keyboard=\{self.saw_keyboard} text=\{self.saw_text} ime_probe=\{self.saw_ime_probe} requested_resize=\{self.requested_resize} requested_input=\{self.requested_input} destroy_requested=\{self.destroy_requested} destroyed=\{self.saw_destroyed}",
    )
    event_loop.exit()
  }
}

///|
fn main {
  let event_loop = @windows.EventLoop::new()
  event_loop.run_app({
    window: None,
    saw_handle: false,
    saw_monitor: false,
    saw_cursor: false,
    saw_redraw: false,
    saw_resize: false,
    saw_pointer: false,
    saw_keyboard: false,
    saw_text: false,
    saw_ime_probe: false,
    saw_destroyed: false,
    requested_resize: false,
    requested_input: false,
    destroy_requested: false,
    ready_printed: false,
    wait_count: 0,
  })
  println("MOUIWindowsSmoke: finished")
}
