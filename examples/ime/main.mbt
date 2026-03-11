///|
struct App {
  mut window : @macos.Window?
  mut input_text : String
  mut ime_enabled : Bool
  mut modifiers : @core.ModifiersState
  mut purpose : @core.ImePurpose
  mut hint : @core.ImeHint
}

///|
fn App::new() -> App {
  {
    window: None,
    input_text: "",
    ime_enabled: true,
    modifiers: @core.ModifiersState::none(),
    purpose: @core.ImePurpose::Normal,
    hint: @core.ImeHint::none(),
  }
}

///|
fn App::print_state(self : App) -> Unit {
  println("text=\{self.input_text}")
  println(
    "ime_enabled=\{self.ime_enabled}, purpose=\{self.purpose}, hint=\{self.hint}",
  )
}

///|
fn App::cycle_purpose(self : App) -> Unit {
  self.purpose = match self.purpose {
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
  if self.hint == @core.ImeHint::none() {
    self.hint = @core.ImeHint::completion()
  } else if self.hint == @core.ImeHint::completion() {
    self.hint = @core.ImeHint::spellcheck()
  } else if self.hint == @core.ImeHint::spellcheck() {
    self.hint = @core.ImeHint::completion().union(@core.ImeHint::spellcheck())
  } else {
    self.hint = @core.ImeHint::none()
  }
}

///|
fn App::apply_ime_state(self : App) -> Unit {
  match self.window {
    Some(window) => {
      window.set_ime_allowed(self.ime_enabled)
      window.set_ime_purpose(self.purpose)
      window.set_ime_hints(self.hint)
      window.set_ime_cursor_area(
        @dpi.LogicalPosition::new(16.0, 16.0).into_position(),
        @dpi.LogicalSize::new(20.0, 20.0).into_size(),
      )
      let surrounding = try {
        let cursor = self.input_text.length()
        Some(@core.ImeSurroundingText::new(self.input_text, cursor, cursor))
      } catch {
        _ => None
      }
      window.set_ime_surrounding_text(surrounding)
    }
    None => ()
  }
}

///|
fn App::backspace(self : App) -> Unit {
  let chars = self.input_text.to_array()
  ignore(chars.pop())
  self.input_text = String::from_array(chars)
}

///|
fn App::handle_key_pressed(
  self : App,
  event_loop : @macos.ActiveEventLoop,
  key_event : @core.KeyEvent,
) -> Unit {
  let logical_key = key_event.logical_key()
  if logical_key is @core.Key::Named(@core.NamedKey::Escape) {
    event_loop.exit()
    return
  }

  if self.modifiers.control_key() {
    match logical_key {
      @core.Key::Character("i") | @core.Key::Character("I") => {
        self.ime_enabled = !self.ime_enabled
        self.apply_ime_state()
        println("toggle ime_enabled=\{self.ime_enabled}")
      }
      @core.Key::Character("p") | @core.Key::Character("P") => {
        self.cycle_purpose()
        self.apply_ime_state()
        println("purpose=\{self.purpose}")
      }
      @core.Key::Character("h") | @core.Key::Character("H") => {
        self.cycle_hint()
        self.apply_ime_state()
        println("hint=\{self.hint}")
      }
      _ => ()
    }
    return
  }

  match logical_key {
    @core.Key::Named(@core.NamedKey::Backspace) => {
      self.backspace()
      self.apply_ime_state()
      self.print_state()
    }
    _ =>
      match key_event.text() {
        Some(text) =>
          if !text.is_empty() {
            self.input_text = self.input_text + text
            self.apply_ime_state()
            self.print_state()
          }
        None => ()
      }
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
  self.apply_ime_state()
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
        Some(window) => window.pre_present_notify()
        None => ()
      }
    @core.WindowEvent::Ime(ime_event) => {
      println("IME event: \{ime_event}")
      match ime_event {
        @core.Ime::Commit(text) => {
          self.input_text = self.input_text + text
          self.apply_ime_state()
          self.print_state()
        }
        _ => ()
      }
    }
    @core.WindowEvent::ModifiersChanged(modifiers) => {
      self.modifiers = modifiers.state()
      println("modifiers=\{self.modifiers}")
    }
    @core.WindowEvent::KeyboardInput(_device_id, key_event, is_synthetic) =>
      if !is_synthetic && key_event.state() is @core.ElementState::Pressed {
        self.handle_key_pressed(event_loop, key_event)
      }
    _ => ()
  }
}

///|
fn main {
  println("IME example controls:")
  println("  Ctrl+I toggle IME")
  println("  Ctrl+P cycle IME purpose")
  println("  Ctrl+H cycle IME hint")
  println("  Esc to exit")

  let event_loop = @macos.EventLoop::new()
  event_loop.run_app(App::new())
}
