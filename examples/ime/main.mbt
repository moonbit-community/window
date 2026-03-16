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
fn utf8_bytes(text : String) -> Bytes {
  @utf8.encode(text[:], bom=false)
}

///|
fn utf8_len(text : String) -> Int {
  utf8_bytes(text).length()
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
fn utf8_is_char_boundary(text : String, index : Int) -> Bool {
  bytes_is_char_boundary(utf8_bytes(text), index)
}

///|
fn utf8_slice(text : String, start : Int, end : Int) -> String? {
  if start < 0 || end < start {
    return None
  }
  let bytes = utf8_bytes(text)
  if end > bytes.length() {
    return None
  }
  if !bytes_is_char_boundary(bytes, start) ||
    !bytes_is_char_boundary(bytes, end) {
    return None
  }
  Some(@utf8.decode(bytes[start:end], ignore_bom=false)) catch {
    _ => None
  }
}

///|
fn min_int(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn max_int(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn preedit_with_cursor_checked(
  text : String,
  cursor : Int,
  anchor : Int,
) -> String? {
  let first = min_int(cursor, anchor)
  let second = max_int(cursor, anchor)
  let text_len = utf8_len(text)

  let before = match utf8_slice(text, 0, first) {
    Some(value) => value
    None => return None
  }
  let end = match utf8_slice(text, second, text_len) {
    Some(value) => value
    None => return None
  }

  if second == first {
    return Some("\{before}|\{end}")
  }

  let mid = match utf8_slice(text, first, second) {
    Some(value) => value
    None => return None
  }

  if first == cursor {
    Some("\{before}|\{mid}_\{end}")
  } else {
    Some("\{before}_\{mid}|\{end}")
  }
}

///|
fn preedit_with_cursor(text : String, cursor : Int, anchor : Int) -> String {
  match preedit_with_cursor_checked(text, cursor, anchor) {
    Some(value) => value
    None => "INVALID: cursor or anchor is not on char boundary"
  }
}

///|
fn TextInputState::delete_surrounding(
  self : TextInputState,
  before_bytes : Int,
  after_bytes : Int,
) -> Bool {
  let text = self.contents
  let text_len = utf8_len(text)
  let cursor = text_len
  let before = if before_bytes < 0 { 0 } else { before_bytes }
  let after = if after_bytes < 0 { 0 } else { after_bytes }

  let delete_start = if before > cursor { 0 } else { cursor - before }
  let mut delete_end = cursor + after
  if delete_end > text_len {
    delete_end = text_len
  }

  let before_text = match utf8_slice(text, 0, delete_start) {
    Some(value) => value
    None => return false
  }
  let after_text = match utf8_slice(text, delete_end, text_len) {
    Some(value) => value
    None => return false
  }

  self.set_text(before_text + after_text)
  true
}

///|
fn ime_hint_all() -> @core.ImeHint {
  @core.ImeHint::none()
  .union(@core.ImeHint::completion())
  .union(@core.ImeHint::spellcheck())
  .union(@core.ImeHint::auto_capitalization())
  .union(@core.ImeHint::lowercase())
  .union(@core.ImeHint::uppercase())
  .union(@core.ImeHint::titlecase())
  .union(@core.ImeHint::hidden_text())
  .union(@core.ImeHint::sensitive_data())
  .union(@core.ImeHint::latin())
  .union(@core.ImeHint::multiline())
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
fn next_valid_ime_hint(hint : @core.ImeHint) -> @core.ImeHint {
  let all_hints = ime_hint_all()
  let mut next = bump_ime_hint(hint)
  while !all_hints.contains(next) {
    next = bump_ime_hint(next)
  }
  next
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
  let text = self.input_state.contents
  let cursor = utf8_len(text)
  println(preedit_with_cursor(text, cursor, cursor))
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
  self.input_state.hint = next_valid_ime_hint(self.input_state.hint)
}

///|
fn App::get_ime_update(self : App) -> @core.ImeRequestData {
  let text = self.input_state.contents
  let cursor = utf8_len(text)
  let text_before_caret = match utf8_slice(text, 0, cursor) {
    Some(value) => value
    None => ""
  }
  let chars_before_caret = text_before_caret.to_array().length()
  let cursor_pos = @dpi.LogicalPosition::new(
    (10 * chars_before_caret).to_double(),
    0.0,
  )

  let max_bytes = @core.ImeSurroundingText::max_text_bytes()
  let minimal_offset = cursor / max_bytes * max_bytes

  let mut first_char_boundary = cursor
  let mut first_offset = minimal_offset
  while first_offset <= cursor {
    if utf8_is_char_boundary(text, first_offset) {
      first_char_boundary = first_offset
      break
    }
    first_offset += 1
  }

  let text_len = utf8_len(text)
  let mut search_end = first_char_boundary + max_bytes
  if search_end > text_len {
    search_end = text_len
  }

  let mut last_char_boundary = cursor
  let mut last_offset = search_end
  while last_offset >= cursor {
    if utf8_is_char_boundary(text, last_offset) {
      last_char_boundary = last_offset
      break
    }
    if last_offset == 0 {
      break
    }
    last_offset -= 1
  }

  let surrounding_text = match
    utf8_slice(text, first_char_boundary, last_char_boundary) {
    Some(value) => value
    None => ""
  }
  let relative_cursor = cursor - first_char_boundary

  let mut request = @core.ImeRequestData::default()
    .with_hint_and_purpose(self.input_state.hint, self.input_state.purpose)
    .with_cursor_area(
      cursor_pos.into_position(),
      @dpi.PhysicalSize::new(20, 20).into_size(),
    )

  let surrounding = Some(
    @core.ImeSurroundingText::new(
      surrounding_text, relative_cursor, relative_cursor,
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
      window.request_ime_update(@core.ImeRequest::Update(self.get_ime_update())) catch {
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
          self.get_ime_update(),
        )
        match enable_request {
          Some(request) =>
            window.request_ime_update(@core.ImeRequest::Enable(request)) catch {
              err => {
                println("enable IME failed: \{err}")
                return
              }
            }
          None => return
        }
      } else {
        window.request_ime_update(@core.ImeRequest::Disable) catch {
          err => {
            println("disable IME failed: \{err}")
            return
          }
        }
      }
    None => return
  }

  self.input_state.ime_enabled = enable
  println("IME enabled now \{self.input_state.ime_enabled}")
}

///|
fn App::handle_key_pressed(self : App, key_event : @core.KeyEvent) -> Unit {
  let key_without_modifiers = key_event.key_without_modifiers()

  if self.modifiers == @core.ModifiersState::control() {
    match key_without_modifiers {
      @core.Key::Character("i") | @core.Key::Character("I") => self.toggle_ime()
      @core.Key::Character("p") | @core.Key::Character("P") => {
        self.cycle_purpose()
        if self.input_state.ime_enabled {
          self.request_ime_update()
        }
        println("text input purpose now \{self.input_state.purpose}")
      }
      @core.Key::Character("h") | @core.Key::Character("H") => {
        self.cycle_hint()
        if self.input_state.ime_enabled {
          self.request_ime_update()
        }
        println("text input IME hint now \{self.input_state.hint}")
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
  match ime_event {
    @core.Ime::Enabled =>
      match self.window {
        Some(window) => println("IME enabled for Window=\{window.id()}")
        None => println("IME enabled")
      }
    @core.Ime::Preedit(text, caret_pos) =>
      println("Preedit: \{text}, with caret at \{caret_pos}")
    @core.Ime::Commit(text) => {
      self.input_state.append_text(text)
      self.request_ime_update()
      self.print_input_state()
    }
    @core.Ime::DeleteSurrounding(before_bytes, after_bytes) =>
      if self.input_state.delete_surrounding(before_bytes, after_bytes) {
        println("IME deleted bytes: \{before_bytes}, \{after_bytes}")
        self.print_input_state()
      } else {
        println("Buggy IME tried to delete with indices not on char boundary.")
      }
    @core.Ime::Disabled =>
      match self.window {
        Some(window) => println("IME disabled for Window=\{window.id()}")
        None => println("IME disabled")
      }
  }
}

///|
pub impl @macos.ApplicationHandler for App with can_create_surfaces(
  self,
  event_loop,
) {
  let window : @macos.Window? = Some(
    event_loop.try_create_window(@core.WindowAttributes::default()),
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
        self.get_ime_update(),
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
      println("Close was requested; stopping")
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
    @core.WindowEvent::ModifiersChanged(modifiers) => {
      self.modifiers = modifiers.state()
      println("Modifiers changed to \{self.modifiers}")
    }
    @core.WindowEvent::KeyboardInput(_device_id, key_event, is_synthetic) =>
      if !is_synthetic && key_event.state() is @core.ElementState::Pressed {
        self.handle_key_pressed(key_event)
      }
    _ => ()
  }
}

///|
fn main {
  println(
    "This showcases the use of an input method engine (IME) by emulating a text edit field.",
  )
  println("Use CTRL+i to toggle IME support.")
  println("Use CTRL+p to cycle content purpose values.")
  println("Use CTRL+h to cycle content hint permutations.")

  @util.tracing_init()
  let event_loop = @macos.EventLoop::new()
  event_loop.run_app(App::new())
}
