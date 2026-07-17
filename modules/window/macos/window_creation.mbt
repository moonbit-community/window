///|
fn initial_window_surface_size(
  surface_size : @dpi.Size?,
  scale_factor : Double,
) -> @dpi.LogicalSize {
  match surface_size {
    Some(size) => size.to_logical(scale_factor)
    None => LogicalSize(800.0, 600.0)
  }
}

///|
fn fullscreen_target_surface_size(
  fullscreen : @core.Fullscreen?,
  primary_monitor : @core.MonitorHandle?,
) -> @dpi.LogicalSize? {
  match fullscreen {
    Some(Borderless(Some(monitor))) =>
      Some(monitor.surface_size().to_logical(monitor.scale_factor()))
    Some(Exclusive(monitor, _video_mode)) =>
      Some(monitor.surface_size().to_logical(monitor.scale_factor()))
    Some(Borderless(None)) =>
      match primary_monitor {
        Some(monitor) =>
          Some(monitor.surface_size().to_logical(monitor.scale_factor()))
        None => None
      }
    None => None
  }
}

///|
fn should_apply_initial_window_position(fullscreen : @core.Fullscreen?) -> Bool {
  match fullscreen {
    Some(_) => false
    None => true
  }
}

///|
fn should_center_initial_window(position : @dpi.Position?) -> Bool {
  match position {
    Some(_) => false
    None => true
  }
}

///|
fn window_position_to_logical(
  position : @dpi.Position,
  scale_factor : Double,
) -> @dpi.LogicalPosition {
  position.to_logical(scale_factor)
}

///|
fn physical_outer_position_to_logical(
  position : @dpi.PhysicalPosition,
  scale_factor : Double,
) -> @dpi.LogicalPosition {
  position.to_logical(scale_factor)
}

///|
fn monitor_position_to_logical(
  monitor : @core.MonitorHandle,
) -> @dpi.LogicalPosition {
  physical_outer_position_to_logical(monitor.position(), monitor.scale_factor())
}

///|
// Port target: window_delegate.rs::new
fn new_window(
  event_loop : EventLoop,
  attributes : @core.WindowAttributes,
) -> Window raise @core.RequestError {
  guard is_main_thread() else {
    raise @core.RequestError::os(
      "Window creation must happen on the main thread",
    )
  }
  let raw_id = app_state_next_window_id()
  let scale_factor = match event_loop.primary_monitor() {
    Some(monitor) => monitor.scale_factor()
    None => 1.0
  }
  let fullscreen = attributes.fullscreen()
  let size = match
    fullscreen_target_surface_size(fullscreen, event_loop.primary_monitor()) {
    Some(size) => size
    None => initial_window_surface_size(attributes.surface_size(), scale_factor)
  }
  let raw_window_handle = create_window(
    clamp_size(size.width().to_int()),
    clamp_size(size.height().to_int()),
  )
  guard native_window_objc_handle(raw_window_handle) != (0 : Int).to_uint64() else {
    raise Ignored
  }
  match attributes.parent_window() {
    Some(parent_window) => {
      let parent_view = match parent_window.into_raw() {
        AppKit(handle) => handle.ns_view()
        _ => {
          close_window(raw_window_handle)
          raise @core.RequestError::not_supported(
            "The parent window handle is not an AppKit handle",
          )
        }
      }
      guard set_parent_window(raw_window_handle, parent_view) else {
        close_window(raw_window_handle)
        raise @core.RequestError::os(
          "Failed to attach native parent window handle",
        )
      }
    }
    None => ()
  }
  set_window_raw_id(raw_window_handle, raw_id)
  app_state_register_window_handle(raw_id, raw_window_handle)
  set_title(raw_window_handle, attributes.title())
  native_set_resizable(raw_window_handle, attributes.resizable())
  set_window_panel(raw_window_handle, attributes.platform_attributes().panel())
  set_window_decorations(raw_window_handle, attributes.decorations())
  match attributes.name() {
    Some(name) => set_window_name(raw_window_handle, name)
    None => ()
  }
  set_window_skip_taskbar(raw_window_handle, attributes.skip_taskbar())
  set_window_clip_children(raw_window_handle, attributes.clip_children())
  set_window_borderless_game(
    raw_window_handle,
    attributes.platform_attributes().borderless_game(),
  )
  set_window_accepts_first_mouse(
    raw_window_handle,
    attributes.platform_attributes().accepts_first_mouse(),
  )
  set_window_fullsize_content_view(
    raw_window_handle,
    attributes.platform_attributes().fullsize_content_view(),
  )
  set_window_has_shadow(
    raw_window_handle,
    attributes.platform_attributes().has_shadow(),
  )
  set_window_movable_by_window_background(
    raw_window_handle,
    attributes.platform_attributes().movable_by_window_background(),
  )
  set_window_option_as_alt(
    raw_window_handle,
    normalize_option_as_alt_native(
      option_as_alt_to_native(attributes.platform_attributes().option_as_alt()),
    ),
  )
  match attributes.platform_attributes().tabbing_identifier() {
    Some(identifier) => {
      set_window_tabbing_identifier(raw_window_handle, identifier)
      set_window_tabbing_mode_preferred(raw_window_handle)
    }
    None => ()
  }
  set_window_title_hidden(
    raw_window_handle,
    attributes.platform_attributes().title_hidden(),
  )
  set_window_titlebar_hidden(
    raw_window_handle,
    attributes.platform_attributes().titlebar_hidden(),
  )
  set_window_titlebar_buttons_hidden(
    raw_window_handle,
    attributes.platform_attributes().titlebar_buttons_hidden(),
  )
  set_window_titlebar_transparent(
    raw_window_handle,
    attributes.platform_attributes().titlebar_transparent(),
  )
  set_window_unified_titlebar(
    raw_window_handle,
    attributes.platform_attributes().unified_titlebar(),
  )
  set_window_theme(raw_window_handle, theme_to_native(attributes.theme()))
  set_window_content_protected(
    raw_window_handle,
    attributes.content_protected(),
  )
  set_window_blur(raw_window_handle, attributes.blur())
  let mut cursor_state = attributes.cursor()
  match attributes.cursor() {
    Icon(icon) => set_window_cursor(raw_window_handle, icon)
    Custom(custom_cursor) =>
      if native_window_set_custom_cursor(
          raw_window_handle,
          custom_cursor.into_raw(),
        ) ==
        false {
        set_window_cursor(raw_window_handle, Default)
        cursor_state = Icon(Default)
      }
  }
  set_window_cursor_visible(raw_window_handle, attributes.cursor_visible())
  ignore(
    set_window_cursor_hittest(raw_window_handle, attributes.cursor_hittest()),
  )
  let enabled_buttons = attributes.enabled_buttons()
  set_window_enabled_buttons(
    raw_window_handle,
    enabled_buttons.close(),
    enabled_buttons.minimize(),
    enabled_buttons.maximize(),
  )
  match attributes.surface_resize_increments() {
    Some(increments) => {
      let logical_increments = increments.to_logical(scale_factor)
      set_surface_resize_increments(
        raw_window_handle,
        logical_increments.width().to_int(),
        logical_increments.height().to_int(),
      )
    }
    None => ()
  }
  set_ime_purpose(
    raw_window_handle,
    normalize_ime_purpose_native(
      ime_purpose_to_native(attributes.ime_purpose()),
    ),
  )
  set_ime_hints(
    raw_window_handle,
    normalize_ime_hints_bits(attributes.ime_hints().bits()),
  )
  set_window_level(
    raw_window_handle,
    normalize_window_level_native(
      window_level_to_native(attributes.window_level()),
    ),
  )
  set_window_transparent(raw_window_handle, attributes.transparent())
  match fullscreen {
    Some(Borderless(target_monitor)) => {
      match target_monitor {
        Some(monitor) => {
          let logical_position = monitor_position_to_logical(monitor)
          set_window_position(
            raw_window_handle,
            logical_position.x().to_int(),
            logical_position.y().to_int(),
          )
        }
        None => ()
      }
      set_window_fullscreen(raw_window_handle, true)
    }
    Some(Exclusive(_, _)) => ()
    None => ()
  }
  match attributes.min_surface_size() {
    Some(min_size) => {
      let logical_min = min_size.to_logical(scale_factor)
      set_min_surface_size(
        raw_window_handle,
        logical_min.width().to_int(),
        logical_min.height().to_int(),
      )
    }
    None => ()
  }
  match attributes.max_surface_size() {
    Some(max_size) => {
      let logical_max = max_size.to_logical(scale_factor)
      set_max_surface_size(
        raw_window_handle,
        logical_max.width().to_int(),
        logical_max.height().to_int(),
      )
    }
    None => ()
  }
  let position = attributes.position()
  if should_center_initial_window(position) {
    center_window(raw_window_handle)
  } else if should_apply_initial_window_position(fullscreen) {
    match position {
      Some(position) => {
        let logical_position = window_position_to_logical(
          position, scale_factor,
        )
        set_window_position(
          raw_window_handle,
          logical_position.x().to_int(),
          logical_position.y().to_int(),
        )
      }
      None => ()
    }
  }
  if attributes.visible() {
    show_window(raw_window_handle, attributes.active())
  }
  if attributes.maximized() {
    set_window_maximized(raw_window_handle, true)
  }
  let window : Window = {
    id: @core.WindowId::from_raw(raw_id),
    raw_window_handle,
    cursor_state,
    fullscreen_state: initial_fullscreen_state(attributes),
    ime_capabilities_state: None,
    ime_surrounding_text_state: None,
    prefers_home_indicator_hidden_state: false,
    prefers_status_bar_hidden_state: false,
    preferred_screen_edges_deferring_system_gestures_state: @core.ScreenEdge::none(),
    blur_state: attributes.blur(),
    disallow_hidpi_state: attributes.platform_attributes().disallow_hidpi(),
    borderless_game_state: attributes.platform_attributes().borderless_game(),
    unified_titlebar_state: attributes.platform_attributes().unified_titlebar(),
    simple_fullscreen_state: false,
    simple_fullscreen_saved_style_mask_state: None,
    simple_fullscreen_saved_presentation_options_state: None,
    simple_fullscreen_saved_outer_position_state: None,
    simple_fullscreen_saved_outer_size_state: None,
    exclusive_fullscreen_state: false,
    exclusive_fullscreen_display_id_state: None,
    exclusive_fullscreen_saved_mode_state: None,
    exclusive_fullscreen_saved_style_mask_state: None,
    exclusive_fullscreen_saved_outer_position_state: None,
    exclusive_fullscreen_saved_outer_size_state: None,
  }
  match attributes.fullscreen() {
    Some(Exclusive(target_monitor, video_mode)) =>
      ignore(window.enter_exclusive_fullscreen(target_monitor, video_mode))
    _ => ()
  }
  window
}
