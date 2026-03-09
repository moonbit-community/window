///|
pub struct Window {
  priv id : @core.WindowId
} derive(Eq, Show)

///|
pub struct EventLoopProxy {
  priv _unit : Unit
} derive(Eq, Show)

///|
pub fn EventLoopProxy::wake_up(_self : EventLoopProxy) -> Unit {
  native_event_loop_wake_up()
}

///|
pub fn Window::id(self : Window) -> @core.WindowId {
  self.id
}

///|
pub fn Window::surface_size(self : Window) -> @dpi.PhysicalSize {
  @dpi.PhysicalSize::new(
    native_window_width(self.id.into_raw()),
    native_window_height(self.id.into_raw()),
  )
}

///|
pub fn Window::request_surface_size(
  self : Window,
  size : @dpi.PhysicalSize,
) -> Unit {
  set_surface_size(self.id.into_raw(), size.width(), size.height())
}

///|
pub fn Window::set_min_surface_size(
  self : Window,
  size : @dpi.PhysicalSize?,
) -> Unit {
  match size {
    Some(size) =>
      set_min_surface_size(self.id.into_raw(), size.width(), size.height())
    None => set_min_surface_size(self.id.into_raw(), 0, 0)
  }
}

///|
pub fn Window::set_max_surface_size(
  self : Window,
  size : @dpi.PhysicalSize?,
) -> Unit {
  match size {
    Some(size) =>
      set_max_surface_size(self.id.into_raw(), size.width(), size.height())
    None => set_max_surface_size(self.id.into_raw(), 0, 0)
  }
}

///|
pub fn Window::outer_position(self : Window) -> @dpi.PhysicalPosition {
  @dpi.PhysicalPosition::new(
    window_x(self.id.into_raw()),
    window_y(self.id.into_raw()),
  )
}

///|
pub fn Window::set_outer_position(
  self : Window,
  position : @dpi.PhysicalPosition,
) -> Unit {
  set_window_position(self.id.into_raw(), position.x(), position.y())
}

///|
pub fn Window::focus_window(self : Window) -> Unit {
  focus_window(self.id.into_raw())
}

///|
pub fn Window::has_focus(self : Window) -> Bool {
  window_has_focus(self.id.into_raw())
}

///|
pub fn Window::set_minimized(self : Window, minimized : Bool) -> Unit {
  set_window_minimized(self.id.into_raw(), minimized)
}

///|
pub fn Window::is_minimized(self : Window) -> Bool {
  window_minimized(self.id.into_raw())
}

///|
pub fn Window::set_maximized(self : Window, maximized : Bool) -> Unit {
  set_window_maximized(self.id.into_raw(), maximized)
}

///|
pub fn Window::is_maximized(self : Window) -> Bool {
  window_maximized(self.id.into_raw())
}

///|
pub fn Window::set_decorations(self : Window, decorations : Bool) -> Unit {
  set_window_decorations(self.id.into_raw(), decorations)
}

///|
pub fn Window::is_decorated(self : Window) -> Bool {
  window_decorated(self.id.into_raw())
}

///|
pub fn Window::set_ime_purpose(
  self : Window,
  purpose : @core.ImePurpose,
) -> Unit {
  set_ime_purpose(self.id.into_raw(), ime_purpose_to_native(purpose))
}

///|
pub fn Window::set_ime_allowed(self : Window, allowed : Bool) -> Unit {
  set_ime_allowed(self.id.into_raw(), allowed)
}

///|
pub fn Window::set_ime_cursor_area(
  self : Window,
  position : @dpi.PhysicalPosition,
  size : @dpi.PhysicalSize,
) -> Unit {
  set_ime_cursor_area(
    self.id.into_raw(),
    position.x(),
    position.y(),
    size.width(),
    size.height(),
  )
}

///|
pub fn Window::scale_factor(self : Window) -> Double {
  window_scale_factor(self.id.into_raw())
}

///|
pub fn Window::request_redraw(self : Window) -> Unit {
  native_window_request_redraw(self.id.into_raw())
}

///|
pub fn Window::set_title(self : Window, title : String) -> Unit {
  set_title(self.id.into_raw(), title)
}

///|
pub fn Window::set_visible(self : Window, visible : Bool) -> Unit {
  native_set_visible(self.id.into_raw(), visible)
}

///|
pub fn Window::set_resizable(self : Window, resizable : Bool) -> Unit {
  native_set_resizable(self.id.into_raw(), resizable)
}

///|
fn theme_from_native(theme : Int) -> @core.Theme? {
  match theme {
    1 => Some(@core.Theme::Light)
    2 => Some(@core.Theme::Dark)
    _ => None
  }
}

///|
fn element_state_from_native(state : Int) -> @core.ElementState? {
  match state {
    1 => Some(@core.ElementState::Pressed)
    2 => Some(@core.ElementState::Released)
    _ => None
  }
}

///|
fn mouse_button_from_native(button : Int) -> @core.MouseButton {
  match button {
    0 => @core.MouseButton::Left
    1 => @core.MouseButton::Right
    2 => @core.MouseButton::Middle
    3 => @core.MouseButton::Back
    4 => @core.MouseButton::Forward
    _ => @core.MouseButton::Other(button)
  }
}

///|
fn button_source_from_native(button : Int) -> @core.ButtonSource {
  if button < 0 {
    @core.ButtonSource::Unknown(button)
  } else {
    @core.ButtonSource::Mouse(mouse_button_from_native(button))
  }
}

///|
fn pointer_source_from_native(source : Int) -> @core.PointerSource {
  match source {
    1 => @core.PointerSource::Mouse
    _ => @core.PointerSource::Unknown
  }
}

///|
fn pointer_kind_from_native(kind : Int) -> @core.PointerKind {
  match kind {
    1 => @core.PointerKind::Mouse
    _ => @core.PointerKind::Unknown
  }
}

///|
fn scroll_delta_from_native(
  kind : Int,
  x : Double,
  y : Double,
) -> @core.MouseScrollDelta? {
  match kind {
    1 => Some(@core.MouseScrollDelta::LineDelta(x, y))
    2 =>
      Some(
        @core.MouseScrollDelta::PixelDelta(@dpi.PhysicalPositionF64::new(x, y)),
      )
    _ => None
  }
}

///|
fn touch_phase_from_native(phase : Int) -> @core.TouchPhase? {
  match phase {
    1 => Some(@core.TouchPhase::Started)
    2 => Some(@core.TouchPhase::Moved)
    3 => Some(@core.TouchPhase::Ended)
    4 => Some(@core.TouchPhase::Cancelled)
    _ => None
  }
}

///|
fn modifiers_from_native(modifiers : Int) -> @core.Modifiers {
  @core.Modifiers::new(
    (modifiers & 1) != 0,
    (modifiers & 2) != 0,
    (modifiers & 4) != 0,
    (modifiers & 8) != 0,
  )
}

///|
fn ime_purpose_to_native(purpose : @core.ImePurpose) -> Int {
  match purpose {
    @core.ImePurpose::Normal => 0
    @core.ImePurpose::Password => 1
    @core.ImePurpose::Terminal => 2
  }
}

///|
fn optional_text_from_native(bytes : Bytes) -> String? {
  if bytes.length() == 0 {
    None
  } else {
    Some(@utf8.decode_lossy(bytes[:], ignore_bom=false))
  }
}

///|
fn text_from_native(bytes : Bytes) -> String {
  @utf8.decode_lossy(bytes[:], ignore_bom=false)
}

///|
fn ime_from_native(window_id : Int) -> @core.Ime? {
  match input_event_ime_kind(window_id) {
    1 => Some(@core.Ime::Enabled)
    2 => {
      let cursor_start = input_event_ime_cursor_start(window_id)
      let cursor_end = input_event_ime_cursor_end(window_id)
      let cursor = if cursor_start >= 0 && cursor_end >= cursor_start {
        Some(@core.ImeCursorRange::new(cursor_start, cursor_end))
      } else {
        None
      }
      Some(
        @core.Ime::Preedit(
          text_from_native(input_event_ime_text(window_id)),
          cursor,
        ),
      )
    }
    3 =>
      Some(@core.Ime::Commit(text_from_native(input_event_ime_text(window_id))))
    4 => Some(@core.Ime::Disabled)
    _ => None
  }
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_input_events(
  self : EventLoop,
  app : A,
  raw_id : Int,
  window_id : @core.WindowId,
) -> Unit {
  while take_input_event(raw_id) {
    let position = @dpi.PhysicalPositionF64::new(
      input_event_x(raw_id),
      input_event_y(raw_id),
    )
    match input_event_kind(raw_id) {
      1 =>
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::PointerMoved(
            position,
            true,
            pointer_source_from_native(input_event_pointer_source(raw_id)),
          ),
        )
      2 =>
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::PointerEntered(
            position,
            true,
            pointer_kind_from_native(input_event_pointer_kind(raw_id)),
          ),
        )
      3 =>
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::PointerLeft(
            Some(position),
            true,
            pointer_kind_from_native(input_event_pointer_kind(raw_id)),
          ),
        )
      4 =>
        match element_state_from_native(input_event_state(raw_id)) {
          Some(state) =>
            app.window_event(
              self,
              window_id,
              @core.WindowEvent::PointerButton(
                state,
                position,
                true,
                button_source_from_native(input_event_button(raw_id)),
              ),
            )
          None => ()
        }
      5 =>
        match
          (
            scroll_delta_from_native(
              input_event_scroll_delta_kind(raw_id),
              input_event_scroll_delta_x(raw_id),
              input_event_scroll_delta_y(raw_id),
            ),
            touch_phase_from_native(input_event_phase(raw_id)),
          ) {
          (Some(delta), Some(phase)) =>
            app.window_event(
              self,
              window_id,
              @core.WindowEvent::MouseWheel(delta, phase),
            )
          _ => ()
        }
      6 =>
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::ModifiersChanged(
            modifiers_from_native(input_event_modifiers(raw_id)),
          ),
        )
      7 =>
        match element_state_from_native(input_event_state(raw_id)) {
          Some(state) =>
            app.window_event(
              self,
              window_id,
              @core.WindowEvent::KeyboardInput(
                create_key_event(
                  input_event_scancode(raw_id),
                  state,
                  input_event_repeat(raw_id),
                  modifiers_from_native(input_event_modifiers(raw_id)),
                  optional_text_from_native(
                    input_event_text_with_all_modifiers(raw_id),
                  ),
                  optional_text_from_native(
                    input_event_text_ignoring_modifiers(raw_id),
                  ),
                  optional_text_from_native(
                    input_event_text_without_modifiers(raw_id),
                  ),
                ),
                false,
              ),
            )
          None => ()
        }
      8 =>
        match ime_from_native(raw_id) {
          Some(ime) =>
            app.window_event(self, window_id, @core.WindowEvent::Ime(ime))
          None => ()
        }
      _ => ()
    }
  }
}

///|
pub fn Window::theme(self : Window) -> @core.Theme? {
  theme_from_native(window_theme(self.id.into_raw()))
}

///|
pub struct EventLoop {
  priv mut control_flow_ : @core.ControlFlow
  priv mut exit_requested : Bool
  priv mut window_ids : Array[Int]
} derive(Show)

///|
pub type ActiveEventLoop = EventLoop

///|
pub fn EventLoop::new() -> EventLoop {
  guard backend_available() else {
    abort("macos backend is unavailable on this target")
  }
  reset_proxy_wake_state()
  {
    control_flow_: @core.ControlFlow::Wait,
    exit_requested: false,
    window_ids: [],
  }
}

///|
pub fn EventLoop::create_window(
  self : EventLoop,
  attributes : @core.WindowAttributes,
) -> Window {
  let size = match attributes.surface_size() {
    Some(size) => size
    None => @dpi.PhysicalSize::new(800, 600)
  }
  let raw_id = create_window(
    size.width(),
    size.height(),
    attributes.visible(),
    attributes.active(),
    attributes.resizable(),
    attributes.decorations(),
    attributes.title(),
  )
  guard raw_id > 0 else { abort("failed to create macos window") }
  set_ime_purpose(raw_id, ime_purpose_to_native(attributes.ime_purpose()))
  match attributes.min_surface_size() {
    Some(min_size) =>
      set_min_surface_size(raw_id, min_size.width(), min_size.height())
    None => ()
  }
  match attributes.max_surface_size() {
    Some(max_size) =>
      set_max_surface_size(raw_id, max_size.width(), max_size.height())
    None => ()
  }
  match attributes.position() {
    Some(position) => set_window_position(raw_id, position.x(), position.y())
    None => ()
  }
  self.window_ids.push(raw_id)
  { id: @core.WindowId::from_raw(raw_id) }
}

///|
pub fn EventLoop::set_control_flow(
  self : EventLoop,
  control_flow : @core.ControlFlow,
) -> Unit {
  self.control_flow_ = control_flow
}

///|
pub fn EventLoop::control_flow(self : EventLoop) -> @core.ControlFlow {
  self.control_flow_
}

///|
pub fn EventLoop::create_proxy(_self : EventLoop) -> EventLoopProxy {
  { _unit: () }
}

///|
pub fn EventLoop::exit(self : EventLoop) -> Unit {
  self.exit_requested = true
}

///|
pub fn EventLoop::exiting(self : EventLoop) -> Bool {
  self.exit_requested
}

///|
pub(open) trait ApplicationHandler {
  new_events(Self, ActiveEventLoop, @core.StartCause) -> Unit = _
  can_create_surfaces(Self, ActiveEventLoop) -> Unit = _
  proxy_wake_up(Self, ActiveEventLoop) -> Unit = _
  window_event(Self, EventLoop, @core.WindowId, @core.WindowEvent) -> Unit = _
  about_to_wait(Self, ActiveEventLoop) -> Unit = _
}

///|
impl ApplicationHandler with new_events(_self, _event_loop, _cause) {
  ()
}

///|
impl ApplicationHandler with can_create_surfaces(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with proxy_wake_up(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with window_event(_self, _event_loop, _id, _event) {
  ()
}

///|
impl ApplicationHandler with about_to_wait(_self, _event_loop) {
  ()
}

///|
fn EventLoop::close_windows(self : EventLoop) -> Unit {
  for raw_id in self.window_ids {
    close_window(raw_id)
  }
}

///|
fn EventLoop::has_open_windows(self : EventLoop) -> Bool {
  for raw_id in self.window_ids {
    if native_window_should_close(raw_id) == false {
      return true
    }
  }
  false
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_window_events(
  self : EventLoop,
  app : A,
) -> Unit {
  let mut polled = false
  for raw_id in self.window_ids {
    if polled == false {
      native_poll_window(raw_id)
      polled = true
    }
    let window_id = @core.WindowId::from_raw(raw_id)
    if take_moved(raw_id) {
      app.window_event(
        self,
        window_id,
        @core.WindowEvent::Moved(
          @dpi.PhysicalPosition::new(
            pending_move_x(raw_id),
            pending_move_y(raw_id),
          ),
        ),
      )
    }
    if take_focused_changed(raw_id) {
      app.window_event(
        self,
        window_id,
        @core.WindowEvent::Focused(pending_focused(raw_id)),
      )
    }
    self.dispatch_input_events(app, raw_id, window_id)
    if take_theme_changed(raw_id) {
      match theme_from_native(pending_theme(raw_id)) {
        Some(theme) =>
          app.window_event(
            self,
            window_id,
            @core.WindowEvent::ThemeChanged(theme),
          )
        None => ()
      }
    }
    if take_occluded_changed(raw_id) {
      app.window_event(
        self,
        window_id,
        @core.WindowEvent::Occluded(pending_occluded(raw_id)),
      )
    }
    if take_scale_factor_changed(raw_id) {
      let scale_factor = pending_scale_factor(raw_id)
      let suggested_size = @dpi.PhysicalSize::new(
        pending_scale_width(raw_id),
        pending_scale_height(raw_id),
      )
      let writer = @core.SurfaceSizeWriter::new(suggested_size)
      app.window_event(
        self,
        window_id,
        @core.WindowEvent::ScaleFactorChanged(scale_factor, writer),
      )
      let requested_size = writer.surface_size()
      set_surface_size(raw_id, requested_size.width(), requested_size.height())
    }
    if native_window_take_surface_resized(raw_id) {
      let size = @dpi.PhysicalSize::new(
        native_window_width(raw_id),
        native_window_height(raw_id),
      )
      app.window_event(self, window_id, @core.WindowEvent::SurfaceResized(size))
    }
    if native_window_take_redraw_requested(raw_id) {
      app.window_event(self, window_id, @core.WindowEvent::RedrawRequested)
    }
    if native_window_take_close_requested(raw_id) {
      app.window_event(self, window_id, @core.WindowEvent::CloseRequested)
    }
    if take_destroyed(raw_id) {
      app.window_event(self, window_id, @core.WindowEvent::Destroyed)
    }
  }
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_proxy_wake_up(
  self : EventLoop,
  app : A,
) -> Unit {
  if native_event_loop_take_proxy_wake_up() {
    app.proxy_wake_up(self)
  }
}

///|
fn EventLoop::wait_next_iteration(self : EventLoop) -> @core.StartCause {
  match self.control_flow_ {
    @core.ControlFlow::Poll => @core.StartCause::Poll
    @core.ControlFlow::Wait => {
      let start_ms = runtime_now_ms()
      let _ = wait_for_events(-1)
      @core.StartCause::WaitCancelled(start_ms, None)
    }
    @core.ControlFlow::WaitUntil(requested_resume_ms) => {
      let start_ms = runtime_now_ms()
      let remaining_ms = requested_resume_ms - start_ms
      if remaining_ms <= 0L {
        @core.StartCause::ResumeTimeReached(start_ms, requested_resume_ms)
      } else if wait_for_events(
          if remaining_ms > 2147483647L {
            2147483647
          } else {
            remaining_ms.to_int()
          },
        ) {
        @core.StartCause::ResumeTimeReached(start_ms, requested_resume_ms)
      } else {
        @core.StartCause::WaitCancelled(start_ms, Some(requested_resume_ms))
      }
    }
  }
}

///|
pub fn[A : ApplicationHandler] EventLoop::run_app(
  self : EventLoop,
  app : A,
) -> Unit {
  app.new_events(self, @core.StartCause::Init)
  app.can_create_surfaces(self)
  while self.exit_requested == false {
    self.dispatch_window_events(app)
    self.dispatch_proxy_wake_up(app)
    if self.exit_requested {
      break
    }
    app.about_to_wait(self)
    if self.exit_requested || self.has_open_windows() == false {
      break
    }
    app.new_events(self, self.wait_next_iteration())
  }
  if self.exit_requested {
    self.close_windows()
    self.dispatch_window_events(app)
  }
}
