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
fn TextInputState::pop(self : TextInputState) -> Unit {
  let chars = self.contents.to_array()
  ignore(chars.pop())
  self.contents = String::from_array(chars)
}

///|
fn TextInputState::delete_surrounding(
  self : TextInputState,
  before_bytes : Int,
  _after_bytes : Int,
) -> Unit {
  let chars = self.contents.to_array()
  let mut remaining = before_bytes
  while remaining > 0 && !chars.is_empty() {
    ignore(chars.pop())
    remaining -= 1
  }
  self.contents = String::from_array(chars)
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
  println("text=\{self.input_state.contents}|")
  println(
    "ime_enabled=\{self.input_state.ime_enabled}, purpose=\{self.input_state.purpose}, hint=\{self.input_state.hint}",
  )
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
  if self.input_state.hint == @core.ImeHint::none() {
    self.input_state.hint = @core.ImeHint::completion()
  } else if self.input_state.hint == @core.ImeHint::completion() {
    self.input_state.hint = @core.ImeHint::spellcheck()
  } else if self.input_state.hint == @core.ImeHint::spellcheck() {
    self.input_state.hint = @core.ImeHint::completion().union(
      @core.ImeHint::spellcheck(),
    )
  } else {
    self.input_state.hint = @core.ImeHint::none()
  }
}

///|
fn App::ime_update_request(self : App) -> @core.ImeRequestData {
  let text = self.input_state.contents
  let utf8_bytes = @utf8.encode(text[:], bom=false)
  let cursor = utf8_bytes.length()
  let cursor_pos = @dpi.LogicalPosition::new((cursor * 10).to_double(), 0.0)
  let mut request = @core.ImeRequestData::default()
    .with_hint_and_purpose(self.input_state.hint, self.input_state.purpose)
    .with_cursor_area(
      cursor_pos.into_position(),
      @dpi.PhysicalSize::new(20, 20).into_size(),
    )

  let surrounding = Some(@core.ImeSurroundingText::new(text, cursor, cursor)) catch {
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
          @core.ImeCapabilities::new(true, true, true),
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
  if key_without_modifiers is @core.Key::Named(@core.NamedKey::Escape) {
    event_loop.exit()
    return
  }

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
      if self.input_state.ime_enabled {
        self.request_ime_update()
      }
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
      if self.input_state.ime_enabled {
        self.request_ime_update()
      }
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
    "IME example (Ctrl+I/P/H, Esc)",
  )
  let window = event_loop.create_window(window_attributes)
  self.window = Some(window)
  match self.window {
    Some(current_window) => {
      let enable_request = @core.ImeEnableRequest::new(
        @core.ImeCapabilities::new(true, true, true),
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
    @core.WindowEvent::CloseRequested => event_loop.exit()
    @core.WindowEvent::SurfaceResized(_) =>
      match self.window {
        Some(window) => window.request_redraw()
        None => ()
      }
    @core.WindowEvent::RedrawRequested =>
      match self.window {
        Some(window) => @util.fill_window(window)
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
