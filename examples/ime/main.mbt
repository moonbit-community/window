///|
// Port target: winit-reference/winit/examples/ime.rs
struct TextInputState {
  mut ime_enabled : Bool
  mut contents : String
  mut purpose : @core.ImePurpose
  mut hint : @core.ImeHint
}

///|
fn TextInputState::new() -> TextInputState {
  {
    ime_enabled: true,
    contents: "",
    purpose: @core.ImePurpose::Normal,
    hint: @core.ImeHint::none(),
  }
}

///|
fn TextInputState::append_text(self : TextInputState, text : String) -> Unit {
  self.contents = self.contents + text
}

///|
fn TextInputState::set_text(self : TextInputState, text : String) -> Unit {
  self.contents = text
}

///|
fn TextInputState::pop(self : TextInputState) -> Unit {
  let chars = self.contents.to_array()
  ignore(chars.pop())
  self.contents = String::from_array(chars)
}

///|
fn utf8_len(text : String) -> Int {
  @utf8.encode(text[:], bom=false).length()
}

///|
fn utf8_len_char(ch : Char) -> Int {
  utf8_len(String::from_array([ch]))
}

///|
fn bytes_is_char_boundary(bytes : Bytes, index : Int) -> Bool {
  if index < 0 || index > bytes.length() {
    false
  } else {
    ignore(
      @utf8.decode(bytes[:index], ignore_bom=false) catch {
        _ => return false
      },
    )
    true
  }
}

///|
fn TextInputState::delete_surrounding(
  self : TextInputState,
  before_bytes : Int,
  after_bytes : Int,
) -> Unit {
  let text_utf8 = @utf8.encode(self.contents[:], bom=false)
  let cursor = text_utf8.length()
  let before = if before_bytes < 0 { 0 } else { before_bytes }
  let after = if after_bytes < 0 { 0 } else { after_bytes }
  let delete_start = if before > cursor { 0 } else { cursor - before }
  let mut delete_end = cursor + after
  if delete_end > text_utf8.length() {
    delete_end = text_utf8.length()
  }
  if bytes_is_char_boundary(text_utf8, delete_start) &&
    bytes_is_char_boundary(text_utf8, delete_end) {
    let prefix = @utf8.decode(text_utf8[:delete_start], ignore_bom=false) catch {
      _ => return ()
    }
    let suffix = @utf8.decode(text_utf8[delete_end:], ignore_bom=false) catch {
      _ => return ()
    }
    self.set_text(prefix + suffix)
  }
}

///|
fn ime_hint_all() -> @core.ImeHint {
  @core.ImeHint::from_bits(1023)
}

///|
fn bump_ime_hint(hint : @core.ImeHint) -> @core.ImeHint {
  if hint == ime_hint_all() {
    @core.ImeHint::none()
  } else {
    @core.ImeHint::from_bits(hint.bits() + 1)
  }
}

///|
struct App {
  mut window : @macos.Window?
  input_state : TextInputState
  mut modifiers : @core.ModifiersState
}

///|
fn App::new() -> App {
  {
    window: None,
    input_state: TextInputState::new(),
    modifiers: @core.ModifiersState::none(),
  }
}

///|
fn App::print_input_state(self : App) -> Unit {
  println("\{self.input_state.contents}|")
}

///|
fn App::cycle_purpose(self : App) -> Unit {
  self.input_state.purpose = match self.input_state.purpose {
    @core.ImePurpose::Normal => @core.ImePurpose::Password
    @core.ImePurpose::Password => @core.ImePurpose::Terminal
    @core.ImePurpose::Terminal => @core.ImePurpose::Number
    @core.ImePurpose::Number => @core.ImePurpose::Phone
    @core.ImePurpose::Phone => @core.ImePurpose::Url
    @core.ImePurpose::Url => @core.ImePurpose::Email
    @core.ImePurpose::Email => @core.ImePurpose::Pin
    @core.ImePurpose::Pin => @core.ImePurpose::Date
    @core.ImePurpose::Date => @core.ImePurpose::Time
    @core.ImePurpose::Time => @core.ImePurpose::DateTime
    @core.ImePurpose::DateTime => @core.ImePurpose::Normal
  }
}

///|
fn App::cycle_hint(self : App) -> Unit {
  self.input_state.hint = bump_ime_hint(self.input_state.hint)
}

///|
fn App::ime_update_request(self : App) -> @core.ImeRequestData {
  let text = self.input_state.contents
  let chars_before_caret = text.to_array().length()
  let cursor_pos = @dpi.LogicalPosition::new(
    (chars_before_caret * 10).to_double(),
    0.0,
  )
  let mut request = @core.ImeRequestData::default()
    .with_hint_and_purpose(self.input_state.hint, self.input_state.purpose)
    .with_cursor_area(
      cursor_pos.into_position(),
      @dpi.PhysicalSize::new(20, 20).into_size(),
    )

  let mut surrounding_text = text
  let max_text_bytes = @core.ImeSurroundingText::max_text_bytes()
  if utf8_len(surrounding_text) > max_text_bytes {
    let chars = surrounding_text.to_array()
    let mut bytes = 0
    let mut start_index = chars.length()
    while start_index > 0 && bytes < max_text_bytes {
      let ch = chars[start_index - 1]
      let ch_bytes = utf8_len_char(ch)
      if bytes + ch_bytes > max_text_bytes {
        break
      }
      bytes += ch_bytes
      start_index -= 1
    }
    let tail : Array[Char] = []
    let mut i = start_index
    while i < chars.length() {
      tail.push(chars[i])
      i += 1
    }
    surrounding_text = String::from_array(tail)
  }

  let surrounding_utf8_len = utf8_len(surrounding_text)
  let surrounding = Some(
    @core.ImeSurroundingText::new(
      surrounding_text, surrounding_utf8_len, surrounding_utf8_len,
    ),
  ) catch {
    _ => None
  }

  match surrounding {
    Some(value) => request = request.with_surrounding_text(value)
    None => ()
  }
  request
}

///|
fn App::request_ime_update(self : App) -> Unit {
  match self.window {
    Some(window) =>
      window.request_ime_update(
        @core.ImeRequest::Update(self.ime_update_request()),
      ) catch {
        err => println("request_ime_update failed: \{err}")
      }
    None => ()
  }
}

///|
fn App::toggle_ime(self : App) -> Unit {
  let enable = !self.input_state.ime_enabled
  match self.window {
    Some(window) =>
      if enable {
        let enable_request = @core.ImeEnableRequest::new(
          @core.ImeCapabilities::default()
          .with_hint_and_purpose()
          .with_cursor_area()
          .with_surrounding_text(),
          self.ime_update_request(),
        )
        match enable_request {
          Some(request) =>
            try {
              window.request_ime_update(@core.ImeRequest::Enable(request))
              self.input_state.ime_enabled = true
            } catch {
              err => println("enable IME failed: \{err}")
            }
          None => ()
        }
      } else {
        try {
          window.request_ime_update(@core.ImeRequest::Disable)
          self.input_state.ime_enabled = false
        } catch {
          err => println("disable IME failed: \{err}")
        }
      }
    None => ()
  }
}

///|
fn App::handle_key_pressed(
  self : App,
  event_loop : @macos.ActiveEventLoop,
  key_event : @core.KeyEvent,
) -> Unit {
  let key_without_modifiers = key_event.key_without_modifiers()
  let _ = event_loop

  if self.modifiers == @core.ModifiersState::control() {
    match key_without_modifiers {
      @core.Key::Character("i") | @core.Key::Character("I") => {
        self.toggle_ime()
        println("IME enabled now \{self.input_state.ime_enabled}")
      }
      @core.Key::Character("p") | @core.Key::Character("P") => {
        self.cycle_purpose()
        if self.input_state.ime_enabled {
          self.request_ime_update()
        }
        println("IME purpose now \{self.input_state.purpose}")
      }
      @core.Key::Character("h") | @core.Key::Character("H") => {
        self.cycle_hint()
        if self.input_state.ime_enabled {
          self.request_ime_update()
        }
        println("IME hint now \{self.input_state.hint}")
      }
      _ => ()
    }
    return
  }

  match key_without_modifiers {
    @core.Key::Named(@core.NamedKey::Backspace) => {
      self.input_state.pop()
      self.print_input_state()
    }
    _ =>
      match key_event.text() {
        Some(text) =>
          if !text.is_empty() {
            self.input_state.append_text(text)
            if self.input_state.ime_enabled {
              self.request_ime_update()
            }
            self.print_input_state()
          }
        None => ()
      }
  }
}

///|
fn App::handle_ime_event(self : App, ime_event : @core.Ime) -> Unit {
  println("IME event: \{ime_event}")
  match ime_event {
    @core.Ime::Commit(text) => {
      self.input_state.append_text(text)
      if self.input_state.ime_enabled {
        self.request_ime_update()
      }
      self.print_input_state()
    }
    @core.Ime::DeleteSurrounding(before_bytes, after_bytes) => {
      self.input_state.delete_surrounding(before_bytes, after_bytes)
      self.print_input_state()
    }
    _ => ()
  }
}

///|
pub impl @macos.ApplicationHandler for App with can_create_surfaces(
  self,
  event_loop,
) {
  let window_attributes = @core.WindowAttributes::default().with_title(
    "IME example (Ctrl+I/P/H)",
  )
  let window : @macos.Window? = Some(
    event_loop.try_create_window(window_attributes),
  ) catch {
    err => {
      println("error creating window: \{err}")
      event_loop.exit()
      None
    }
  }
  self.window = window
  match self.window {
    Some(current_window) => {
      let enable_request = @core.ImeEnableRequest::new(
        @core.ImeCapabilities::default()
        .with_hint_and_purpose()
        .with_cursor_area()
        .with_surrounding_text(),
        self.ime_update_request(),
      )
      match enable_request {
        Some(request) =>
          current_window.request_ime_update(@core.ImeRequest::Enable(request)) catch {
            err => println("initial IME enable failed: \{err}")
          }
        None => ()
      }
    }
    None => ()
  }
}

///|
pub impl @macos.ApplicationHandler for App with window_event(
  self,
  event_loop,
  _window_id,
  event,
) {
  match event {
    @core.WindowEvent::CloseRequested => {
      self.window = None
      event_loop.exit()
    }
    @core.WindowEvent::SurfaceResized(_) =>
      match self.window {
        Some(window) => window.request_redraw()
        None => ()
      }
    @core.WindowEvent::RedrawRequested =>
      match self.window {
        Some(window) => {
          window.pre_present_notify()
          @util.fill_window(window)
        }
        None => ()
      }
    @core.WindowEvent::Ime(ime_event) => self.handle_ime_event(ime_event)
    @core.WindowEvent::ModifiersChanged(modifiers) =>
      self.modifiers = modifiers.state()
    @core.WindowEvent::KeyboardInput(_device_id, key_event, is_synthetic) =>
      if !is_synthetic && key_event.state() is @core.ElementState::Pressed {
        self.handle_key_pressed(event_loop, key_event)
      }
    _ => ()
  }
}

///|
fn main {
  println("This showcases IME support by emulating a text field.")
  println("Use Ctrl+I to toggle IME support.")
  println("Use Ctrl+P to cycle content purpose values.")
  println("Use Ctrl+H to cycle content hint permutations.")

  @util.tracing_init()
  let event_loop = @macos.EventLoop::new()
  event_loop.run_app(App::new())
}
