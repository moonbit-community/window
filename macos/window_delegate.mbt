///|
// Port target: winit-reference/winit-appkit/src/window_delegate.rs

///|
fn EventLoop::close_windows(self : EventLoop) -> Unit {
  for raw_id in self.window_ids {
    app_state_clear_window_redraw(raw_id)
    close_window(raw_id)
  }
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_window_events(
  self : EventLoop,
  app : A,
) -> Unit {
  let active = self.as_active()
  let mut polled = false
  let remaining_window_ids : Array[Int] = []
  for raw_id in self.window_ids {
    if polled == false {
      native_poll_window(raw_id)
      polled = true
    }
    let window_id = @core.WindowId::from_raw(raw_id)
    if take_moved(raw_id) {
      app.window_event(
        active,
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
        active,
        window_id,
        @core.WindowEvent::Focused(pending_focused(raw_id)),
      )
    }
    self.dispatch_input_events(app, raw_id, window_id)
    if take_theme_changed(raw_id) {
      match theme_from_native(pending_theme(raw_id)) {
        Some(theme) =>
          app.window_event(
            active,
            window_id,
            @core.WindowEvent::ThemeChanged(theme),
          )
        None => ()
      }
    }
    if take_occluded_changed(raw_id) {
      app.window_event(
        active,
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
        active,
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
      app.window_event(
        active,
        window_id,
        @core.WindowEvent::SurfaceResized(size),
      )
    }
    if app_state_take_redraw(raw_id) {
      app.window_event(active, window_id, @core.WindowEvent::RedrawRequested)
    }
    if native_window_take_close_requested(raw_id) {
      app.window_event(active, window_id, @core.WindowEvent::CloseRequested)
    }
    let destroyed = take_destroyed(raw_id)
    if destroyed {
      app_state_clear_window_redraw(raw_id)
      app.window_event(active, window_id, @core.WindowEvent::Destroyed)
    }
    if destroyed == false {
      remaining_window_ids.push(raw_id)
    }
  }
  self.window_ids = remaining_window_ids
}

///|
pub fn EventLoop::try_create_window(
  self : EventLoop,
  attributes : @core.WindowAttributes,
) -> Window raise @core.RequestError {
  guard is_main_thread() else { raise @core.RequestError::Os }
  let scale_factor = match self.primary_monitor() {
    Some(monitor) => monitor.scale_factor()
    None => 1.0
  }
  let size = match attributes.surface_size() {
    Some(size) => size.to_physical(scale_factor)
    None => @dpi.PhysicalSize::new(800, 600)
  }
  let raw_id = create_window(
    size.width(),
    size.height(),
    attributes.visible(),
    attributes.active(),
    attributes.resizable(),
    attributes.decorations(),
    attributes.platform_attributes().panel(),
    attributes.title(),
  )
  guard raw_id > 0 else { raise @core.RequestError::Ignored }
  match attributes.parent_window() {
    Some(parent_window) => {
      guard set_parent_window(raw_id, parent_window.into_raw()) else {
        close_window(raw_id)
        raise @core.RequestError::Os
      }
    }
    None => ()
  }
  set_window_borderless_game(
    raw_id,
    attributes.platform_attributes().borderless_game(),
  )
  set_window_accepts_first_mouse(
    raw_id,
    attributes.platform_attributes().accepts_first_mouse(),
  )
  set_window_disallow_hidpi(
    raw_id,
    attributes.platform_attributes().disallow_hidpi(),
  )
  set_window_fullsize_content_view(
    raw_id,
    attributes.platform_attributes().fullsize_content_view(),
  )
  set_window_has_shadow(raw_id, attributes.platform_attributes().has_shadow())
  set_window_movable_by_window_background(
    raw_id,
    attributes.platform_attributes().movable_by_window_background(),
  )
  set_window_option_as_alt(
    raw_id,
    normalize_option_as_alt_native(
      option_as_alt_to_native(attributes.platform_attributes().option_as_alt()),
    ),
  )
  match attributes.platform_attributes().tabbing_identifier() {
    Some(identifier) => {
      set_window_tabbing_identifier(raw_id, identifier)
      set_window_tabbing_mode_preferred(raw_id)
    }
    None => ()
  }
  set_window_title_hidden(
    raw_id,
    attributes.platform_attributes().title_hidden(),
  )
  set_window_titlebar_hidden(
    raw_id,
    attributes.platform_attributes().titlebar_hidden(),
  )
  set_window_titlebar_buttons_hidden(
    raw_id,
    attributes.platform_attributes().titlebar_buttons_hidden(),
  )
  set_window_titlebar_transparent(
    raw_id,
    attributes.platform_attributes().titlebar_transparent(),
  )
  set_window_unified_titlebar(
    raw_id,
    attributes.platform_attributes().unified_titlebar(),
  )
  set_window_theme(raw_id, theme_to_native(attributes.theme()))
  set_window_content_protected(raw_id, attributes.content_protected())
  set_window_blur(raw_id, attributes.blur())
  let mut cursor_state = attributes.cursor()
  match attributes.cursor() {
    @core.Cursor::Icon(icon) =>
      set_window_cursor(raw_id, cursor_icon_to_native(icon))
    @core.Cursor::Custom(custom_cursor) =>
      if set_window_custom_cursor(raw_id, custom_cursor.into_raw()) == false {
        set_window_cursor(
          raw_id,
          cursor_icon_to_native(@core.CursorIcon::Default),
        )
        cursor_state = @core.Cursor::Icon(@core.CursorIcon::Default)
      }
  }
  set_window_cursor_visible(raw_id, attributes.cursor_visible())
  ignore(set_window_cursor_hittest(raw_id, attributes.cursor_hittest()))
  let enabled_buttons = attributes.enabled_buttons()
  set_window_enabled_buttons(
    raw_id,
    enabled_buttons.close(),
    enabled_buttons.minimize(),
    enabled_buttons.maximize(),
  )
  match attributes.surface_resize_increments() {
    Some(increments) => {
      let physical_increments = increments.to_physical(scale_factor)
      set_surface_resize_increments(
        raw_id,
        physical_increments.width(),
        physical_increments.height(),
      )
    }
    None => ()
  }
  set_ime_purpose(
    raw_id,
    normalize_ime_purpose_native(
      ime_purpose_to_native(attributes.ime_purpose()),
    ),
  )
  set_ime_hints(raw_id, normalize_ime_hints_bits(attributes.ime_hints().bits()))
  set_window_level(
    raw_id,
    normalize_window_level_native(
      window_level_to_native(attributes.window_level()),
    ),
  )
  set_window_transparent(raw_id, attributes.transparent())
  match attributes.fullscreen() {
    Some(@core.Fullscreen::Borderless(target_monitor)) => {
      match target_monitor {
        Some(monitor) =>
          set_window_position(
            raw_id,
            monitor.position().x(),
            monitor.position().y(),
          )
        None => ()
      }
      set_window_fullscreen(raw_id, true)
    }
    Some(@core.Fullscreen::Exclusive(target_monitor, video_mode)) => {
      let mode_size = video_mode.surface_size()
      ignore(
        set_window_exclusive_fullscreen(
          raw_id,
          target_monitor.native_id(),
          mode_size.width(),
          mode_size.height(),
          match video_mode.bit_depth() {
            Some(bit_depth) => bit_depth
            None => 0
          },
          match video_mode.refresh_rate_millihertz() {
            Some(refresh_rate) => refresh_rate
            None => 0
          },
        ),
      )
    }
    None => ()
  }
  match attributes.min_surface_size() {
    Some(min_size) => {
      let physical_min = min_size.to_physical(scale_factor)
      set_min_surface_size(raw_id, physical_min.width(), physical_min.height())
    }
    None => ()
  }
  match attributes.max_surface_size() {
    Some(max_size) => {
      let physical_max = max_size.to_physical(scale_factor)
      set_max_surface_size(raw_id, physical_max.width(), physical_max.height())
    }
    None => ()
  }
  match attributes.position() {
    Some(position) => {
      let physical_position = position.to_physical(scale_factor)
      set_window_position(raw_id, physical_position.x(), physical_position.y())
    }
    None => ()
  }
  if attributes.visible() {
    show_window(raw_id, attributes.active())
  }
  if attributes.maximized() {
    set_window_maximized(raw_id, true)
  }
  self.window_ids.push(raw_id)
  {
    id: @core.WindowId::from_raw(raw_id),
    cursor_state,
    fullscreen_state: initial_fullscreen_state(attributes),
    ime_capabilities_state: None,
    ime_cursor_area_position_state: @dpi.PhysicalPosition::new(0, 0),
    ime_cursor_area_size_state: @dpi.PhysicalSize::new(1, 1),
    ime_surrounding_text_state: None,
    visible_state: attributes.visible(),
    resizable_state: attributes.resizable(),
    content_protected_state: attributes.content_protected(),
    decorated_state: attributes.decorations(),
    enabled_buttons_state: attributes.enabled_buttons(),
    blur_state: attributes.blur(),
    has_shadow_state: attributes.platform_attributes().has_shadow(),
    document_edited_state: false,
    option_as_alt_state: attributes.platform_attributes().option_as_alt(),
    borderless_game_state: attributes.platform_attributes().borderless_game(),
    unified_titlebar_state: attributes.platform_attributes().unified_titlebar(),
    cursor_visible_state: attributes.cursor_visible(),
    cursor_hittest_state: attributes.cursor_hittest(),
    transparent_state: attributes.transparent(),
    window_level_state: attributes.window_level(),
    ime_allowed_state: false,
    ime_purpose_state: attributes.ime_purpose(),
    ime_hints_state: attributes.ime_hints(),
  }
}

///|
pub fn Window::simple_fullscreen(self : Window) -> Bool {
  window_simple_fullscreen(self.id.into_raw())
}

///|
pub fn Window::set_simple_fullscreen(self : Window, fullscreen : Bool) -> Bool {
  set_window_simple_fullscreen(self.id.into_raw(), fullscreen)
}

///|
pub fn Window::set_borderless_game(
  self : Window,
  borderless_game : Bool,
) -> Unit {
  self.borderless_game_state = borderless_game
  set_window_borderless_game(self.id.into_raw(), borderless_game)
}

///|
pub fn Window::is_borderless_game(self : Window) -> Bool {
  self.borderless_game_state
}

///|
pub fn Window::set_unified_titlebar(
  self : Window,
  unified_titlebar : Bool,
) -> Unit {
  self.unified_titlebar_state = unified_titlebar
  set_window_unified_titlebar(self.id.into_raw(), unified_titlebar)
}

///|
pub fn Window::unified_titlebar(self : Window) -> Bool {
  self.unified_titlebar_state
}

///|
pub fn Window::set_tabbing_identifier(
  self : Window,
  identifier : String,
) -> Unit {
  set_window_tabbing_identifier(self.id.into_raw(), identifier)
}

///|
pub fn Window::tabbing_identifier(self : Window) -> String {
  text_from_native(window_tabbing_identifier(self.id.into_raw()))
}

///|
pub fn Window::select_next_tab(self : Window) -> Unit {
  select_window_next_tab(self.id.into_raw())
}

///|
pub fn Window::select_previous_tab(self : Window) -> Unit {
  select_window_previous_tab(self.id.into_raw())
}

///|
pub fn Window::select_tab_at_index(self : Window, index : Int) -> Unit {
  if index >= 0 {
    select_window_tab_at_index(self.id.into_raw(), index)
  }
}

///|
pub fn Window::num_tabs(self : Window) -> Int {
  window_num_tabs(self.id.into_raw())
}

///|
pub fn Window::set_decorations(self : Window, decorations : Bool) -> Unit {
  self.toggle_window_decorations(decorations)
}

///|
fn Window::toggle_window_decorations(self : Window, decorations : Bool) -> Unit {
  self.decorated_state = decorations
  set_window_decorations(self.id.into_raw(), decorations)
}

///|
pub fn Window::set_enabled_buttons(
  self : Window,
  buttons : @core.WindowButtons,
) -> Unit {
  self.enabled_buttons_state = buttons
  set_window_enabled_buttons(
    self.id.into_raw(),
    buttons.close(),
    buttons.minimize(),
    buttons.maximize(),
  )
}

///|
pub fn Window::set_blur(self : Window, blur : Bool) -> Unit {
  self.blur_state = blur
  set_window_blur(self.id.into_raw(), blur)
}

///|
pub fn Window::has_shadow(self : Window) -> Bool {
  self.has_shadow_state
}

///|
pub fn Window::set_has_shadow(self : Window, has_shadow : Bool) -> Unit {
  self.has_shadow_state = has_shadow
  set_window_has_shadow(self.id.into_raw(), has_shadow)
}

///|
pub fn Window::set_cursor(self : Window, cursor : @core.Cursor) -> Unit {
  let raw_id = self.id.into_raw()
  match cursor {
    @core.Cursor::Icon(icon) => {
      set_window_cursor(raw_id, cursor_icon_to_native(icon))
      self.cursor_state = cursor
    }
    @core.Cursor::Custom(custom_cursor) =>
      if set_window_custom_cursor(raw_id, custom_cursor.into_raw()) {
        self.cursor_state = cursor
      } else {
        set_window_cursor(
          raw_id,
          cursor_icon_to_native(@core.CursorIcon::Default),
        )
        self.cursor_state = @core.Cursor::Icon(@core.CursorIcon::Default)
      }
  }
}

///|
pub fn Window::set_cursor_icon(
  self : Window,
  cursor : @core.CursorIcon,
) -> Unit {
  self.set_cursor(@core.Cursor::Icon(cursor))
}

///|
pub fn Window::set_cursor_visible(self : Window, visible : Bool) -> Unit {
  self.cursor_visible_state = visible
  set_window_cursor_visible(self.id.into_raw(), visible)
}

///|
pub fn Window::set_cursor_hittest(
  self : Window,
  hittest : Bool,
) -> Unit raise @core.RequestError {
  if set_window_cursor_hittest(self.id.into_raw(), hittest) {
    self.cursor_hittest_state = hittest
    ()
  } else {
    raise @core.RequestError::Ignored
  }
}

///|
pub fn Window::set_cursor_position(
  self : Window,
  position : @dpi.Position,
) -> Unit raise @core.RequestError {
  let physical_position = position.to_physical(self.scale_factor())
  if set_cursor_position(
      self.id.into_raw(),
      physical_position.x(),
      physical_position.y(),
    ) {
    ()
  } else {
    raise @core.RequestError::Ignored
  }
}

///|
pub fn Window::set_cursor_grab(
  self : Window,
  mode : @core.CursorGrabMode,
) -> Unit raise @core.RequestError {
  if mode is @core.CursorGrabMode::Confined {
    raise @core.RequestError::NotSupported
  }
  if set_cursor_grab(self.id.into_raw(), cursor_grab_mode_to_native(mode)) {
    ()
  } else {
    raise @core.RequestError::Ignored
  }
}

///|
pub fn Window::drag_window(self : Window) -> Unit raise @core.RequestError {
  if drag_window(self.id.into_raw()) {
    ()
  } else {
    raise @core.RequestError::Ignored
  }
}

///|
pub fn Window::drag_resize_window(
  self : Window,
  direction : @core.ResizeDirection,
) -> Unit raise @core.RequestError {
  if drag_resize_window(
      self.id.into_raw(),
      resize_direction_to_native(direction),
    ) {
    ()
  } else {
    raise @core.RequestError::NotSupported
  }
}

///|
pub fn Window::show_window_menu(
  self : Window,
  position : @dpi.Position,
) -> Unit {
  let physical_position = position.to_physical(self.scale_factor())
  let _ = show_window_menu(
    self.id.into_raw(),
    physical_position.x(),
    physical_position.y(),
  )
}

///|
pub fn Window::is_decorated(self : Window) -> Bool {
  self.decorated_state
}

///|
pub fn Window::enabled_buttons(self : Window) -> @core.WindowButtons {
  self.enabled_buttons_state
}

///|
pub fn Window::is_blurred(self : Window) -> Bool {
  self.blur_state
}

///|
pub fn Window::cursor(self : Window) -> @core.Cursor {
  self.cursor_state
}

///|
pub fn Window::is_cursor_visible(self : Window) -> Bool {
  self.cursor_visible_state
}

///|
pub fn Window::is_cursor_hittest(self : Window) -> Bool {
  self.cursor_hittest_state
}

///|
pub fn Window::set_transparent(self : Window, transparent : Bool) -> Unit {
  self.transparent_state = transparent
  set_window_transparent(self.id.into_raw(), transparent)
}

///|
pub fn Window::is_transparent(self : Window) -> Bool {
  self.transparent_state
}

///|
pub fn Window::set_window_level(
  self : Window,
  level : @core.WindowLevel,
) -> Unit {
  self.window_level_state = level
  set_window_level(
    self.id.into_raw(),
    normalize_window_level_native(window_level_to_native(level)),
  )
}

///|
pub fn Window::window_level(self : Window) -> @core.WindowLevel {
  self.window_level_state
}

///|
pub fn Window::set_ime_purpose(
  self : Window,
  purpose : @core.ImePurpose,
) -> Unit {
  match self.ime_capabilities() {
    Some(capabilities) =>
      if capabilities.hint_and_purpose() {
        let _ = self.request_ime_update(
          @core.ImeRequestData::default()
          .with_hint_and_purpose(@core.ImeHint::none(), purpose)
          .into_request(),
        ) catch {
          _ => ()
        }
      }
    None => ()
  }
}

///|
fn Window::set_ime_purpose_raw(
  self : Window,
  purpose : @core.ImePurpose,
) -> Unit {
  self.ime_purpose_state = purpose
  set_ime_purpose(
    self.id.into_raw(),
    normalize_ime_purpose_native(ime_purpose_to_native(purpose)),
  )
}

///|
pub fn Window::set_ime_hints(self : Window, hints : @core.ImeHint) -> Unit {
  self.ime_hints_state = hints
  set_ime_hints(self.id.into_raw(), normalize_ime_hints_bits(hints.bits()))
}

///|
pub fn Window::set_ime_allowed(self : Window, allowed : Bool) -> Unit {
  let request : @core.ImeRequest? = if allowed {
    let capabilities = @core.ImeCapabilities::default()
      .with_hint_and_purpose()
      .with_cursor_area()
    let request_data = @core.ImeRequestData::default()
      .with_hint_and_purpose(@core.ImeHint::none(), @core.ImePurpose::Normal)
      .with_cursor_area(
        @dpi.LogicalPosition::new(0.0, 0.0).into_position(),
        @dpi.LogicalSize::new(0.0, 0.0).into_size(),
      )
    match @core.ImeEnableRequest::new(capabilities, request_data) {
      Some(enable_request) => Some(@core.ImeRequest::Enable(enable_request))
      None => None
    }
  } else {
    Some(@core.ImeRequest::Disable)
  }
  match request {
    Some(request) => {
      let _ = self.request_ime_update(request) catch { _ => () }
      ()
    }
    None => ()
  }
}

///|
fn Window::set_ime_allowed_raw(self : Window, allowed : Bool) -> Unit {
  self.ime_allowed_state = allowed
  if allowed == false {
    self.ime_capabilities_state = None
    self.ime_surrounding_text_state = None
  }
  set_ime_allowed(self.id.into_raw(), allowed)
}

///|
pub fn Window::ime_allowed(self : Window) -> Bool {
  self.ime_allowed_state
}

///|
pub fn Window::set_ime_cursor_area(
  self : Window,
  position : @dpi.Position,
  size : @dpi.Size,
) -> Unit {
  match self.ime_capabilities() {
    Some(capabilities) =>
      if capabilities.cursor_area() {
        let _ = self.request_ime_update(
          @core.ImeRequestData::default()
          .with_cursor_area(position, size)
          .into_request(),
        ) catch {
          _ => ()
        }
      }
    None => ()
  }
}

///|
fn Window::set_ime_cursor_area_raw(
  self : Window,
  position : @dpi.Position,
  size : @dpi.Size,
) -> Unit {
  let scale_factor = self.scale_factor()
  let physical_position = position.to_physical(scale_factor)
  let physical_size = size.to_physical(scale_factor)
  let width = if physical_size.width() > 0 { physical_size.width() } else { 1 }
  let height = if physical_size.height() > 0 {
    physical_size.height()
  } else {
    1
  }
  self.ime_cursor_area_position_state = physical_position
  self.ime_cursor_area_size_state = @dpi.PhysicalSize::new(width, height)
  set_ime_cursor_area(
    self.id.into_raw(),
    physical_position.x(),
    physical_position.y(),
    width,
    height,
  )
}

///|
pub fn Window::set_ime_surrounding_text(
  self : Window,
  surrounding_text : @core.ImeSurroundingText?,
) -> Unit {
  match surrounding_text {
    Some(surrounding_text) => {
      set_ime_surrounding_text(
        self.id.into_raw(),
        surrounding_text.text(),
        surrounding_text.cursor(),
        surrounding_text.anchor(),
      )
      self.ime_surrounding_text_state = Some(surrounding_text)
    }
    None => {
      clear_ime_surrounding_text(self.id.into_raw())
      self.ime_surrounding_text_state = None
    }
  }
}

///|
pub fn Window::ime_cursor_area_position(self : Window) -> @dpi.PhysicalPosition {
  self.ime_cursor_area_position_state
}

///|
pub fn Window::ime_cursor_area_size(self : Window) -> @dpi.PhysicalSize {
  self.ime_cursor_area_size_state
}

///|
pub fn Window::ime_surrounding_text(self : Window) -> @core.ImeSurroundingText? {
  self.ime_surrounding_text_state
}

///|
pub fn Window::ime_purpose(self : Window) -> @core.ImePurpose {
  self.ime_purpose_state
}

///|
pub fn Window::ime_hints(self : Window) -> @core.ImeHint {
  self.ime_hints_state
}

///|
fn Window::apply_ime_request_data(
  self : Window,
  request_data : @core.ImeRequestData,
) -> Unit raise @core.ImeRequestError {
  if self.ime_allowed() == false {
    raise @core.ImeRequestError::NotEnabled
  }
  if request_data.has_hint_and_purpose() {
    if self.ime_supports_hint_and_purpose() {
      match request_data.hint_and_purpose() {
        Some((hints, purpose)) => {
          self.set_ime_hints(hints)
          self.set_ime_purpose_raw(purpose)
        }
        None => ()
      }
    }
  }
  if request_data.has_cursor_area() {
    if self.ime_supports_cursor_area() {
      match request_data.cursor_area() {
        Some((position, size)) => self.set_ime_cursor_area_raw(position, size)
        None => ()
      }
    }
  }
  if request_data.has_surrounding_text() {
    if self.ime_supports_surrounding_text() {
      match request_data.surrounding_text() {
        Some(surrounding_text) =>
          self.set_ime_surrounding_text(Some(surrounding_text))
        None => ()
      }
    }
  }
}

///|
pub fn Window::request_ime_update(
  self : Window,
  request : @core.ImeRequest,
) -> Unit raise @core.ImeRequestError {
  match request {
    @core.ImeRequest::Enable(enable_request) =>
      if self.ime_allowed() {
        raise @core.ImeRequestError::AlreadyEnabled
      } else {
        let capabilities = enable_request.capabilities()
        let request_data = enable_request.request_data()
        self.set_ime_allowed_raw(true)
        self.ime_capabilities_state = Some(capabilities)
        self.apply_ime_request_data(request_data)
      }
    @core.ImeRequest::Update(request_data) =>
      self.apply_ime_request_data(request_data)
    @core.ImeRequest::Disable => {
      self.set_ime_allowed_raw(false)
      ()
    }
  }
}

///|
pub fn Window::ime_capabilities(self : Window) -> @core.ImeCapabilities? {
  self.ime_capabilities_state
}

///|
fn Window::ime_supports_hint_and_purpose(self : Window) -> Bool {
  match self.ime_capabilities_state {
    Some(capabilities) => capabilities.hint_and_purpose()
    None => true
  }
}

///|
fn Window::ime_supports_cursor_area(self : Window) -> Bool {
  match self.ime_capabilities_state {
    Some(capabilities) => capabilities.cursor_area()
    None => true
  }
}

///|
fn Window::ime_supports_surrounding_text(self : Window) -> Bool {
  match self.ime_capabilities_state {
    Some(capabilities) => capabilities.surrounding_text()
    None => true
  }
}

///|
pub fn Window::scale_factor(self : Window) -> Double {
  window_scale_factor(self.id.into_raw())
}

///|
pub fn Window::request_redraw(self : Window) -> Unit {
  app_state_queue_redraw(self.id.into_raw())
  native_event_loop_wake_up()
}

///|
pub fn Window::pre_present_notify(_self : Window) -> Unit {
  ()
}

///|
pub fn Window::reset_dead_keys(_self : Window) -> Unit {
  ()
}

///|
pub fn Window::set_title(self : Window, title : String) -> Unit {
  set_title(self.id.into_raw(), title)
}

///|
pub fn Window::title(self : Window) -> String {
  text_from_native(window_title(self.id.into_raw()))
}

///|
pub fn Window::set_theme(self : Window, theme : @core.Theme?) -> Unit {
  set_window_theme(self.id.into_raw(), theme_to_appearance(theme))
}

///|
pub fn Window::set_window_icon(
  _self : Window,
  _window_icon : @core.Icon?,
) -> Unit {
  ()
}

///|
pub fn Window::set_content_protected(
  self : Window,
  content_protected : Bool,
) -> Unit {
  self.content_protected_state = content_protected
  set_window_content_protected(self.id.into_raw(), content_protected)
}

///|
pub fn Window::set_visible(self : Window, visible : Bool) -> Unit {
  self.visible_state = visible
  native_set_visible(self.id.into_raw(), visible)
}

///|
pub fn Window::is_visible(self : Window) -> Bool? {
  Some(self.visible_state)
}

///|
pub fn Window::set_resizable(self : Window, resizable : Bool) -> Unit {
  self.resizable_state = resizable
  native_set_resizable(self.id.into_raw(), resizable)
}

///|
pub fn Window::is_resizable(self : Window) -> Bool {
  self.resizable_state
}

///|
pub fn Window::is_content_protected(self : Window) -> Bool {
  self.content_protected_state
}

///|
pub fn Window::is_document_edited(self : Window) -> Bool {
  self.document_edited_state
}

///|
pub fn Window::set_document_edited(self : Window, edited : Bool) -> Unit {
  self.document_edited_state = edited
  set_window_document_edited(self.id.into_raw(), edited)
}

///|
pub fn Window::set_option_as_alt(
  self : Window,
  option_as_alt : @core.OptionAsAlt,
) -> Unit {
  self.option_as_alt_state = option_as_alt
  set_window_option_as_alt(
    self.id.into_raw(),
    normalize_option_as_alt_native(option_as_alt_to_native(option_as_alt)),
  )
}

///|
pub fn Window::option_as_alt(self : Window) -> @core.OptionAsAlt {
  self.option_as_alt_state
}

///|
pub fn Window::request_user_attention(
  self : Window,
  request_type : @core.UserAttentionType?,
) -> Unit {
  request_user_attention(
    self.id.into_raw(),
    user_attention_type_to_native(request_type),
  )
}

///|
pub fn Window::theme(self : Window) -> @core.Theme? {
  theme_from_native(window_appearance(self.id.into_raw()))
}

///|
pub fn Window::is_occluded(self : Window) -> Bool {
  window_occluded(self.id.into_raw())
}

///|
fn window_appearance(window_id : Int) -> Int {
  window_theme(window_id)
}

///|
fn theme_to_appearance(theme : @core.Theme?) -> Int {
  theme_to_native(theme)
}
