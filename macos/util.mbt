///|
// Port target: winit-reference/winit-appkit/src/util.rs

///|
fn cg_display_create_uuid_from_display_id(display_id : UInt64) -> UInt64 {
  native_cg_display_create_uuid_from_display_id(display_id.to_uint())
}

///|
fn cg_main_display_id() -> UInt64 {
  native_cg_main_display_id().to_uint64()
}

///|
fn cg_display_model_number(display_id : UInt64) -> Int {
  native_cg_display_model_number(display_id.to_uint()).reinterpret_as_int()
}

///|
fn cg_display_pixels_wide(display_id : UInt64) -> Int {
  native_cg_display_pixels_wide(display_id.to_uint()).to_int()
}

///|
fn cg_display_pixels_high(display_id : UInt64) -> Int {
  native_cg_display_pixels_high(display_id.to_uint()).to_int()
}

///|
fn cg_display_get_display_id_from_uuid(uuid : UInt64) -> UInt64 {
  native_cg_display_get_display_id_from_uuid(uuid).to_uint64()
}

///|
fn cf_release(cf_type : UInt64) -> Unit {
  if cf_type != (0 : Int).to_uint64() {
    native_cf_release(cf_type)
  }
}

///|
fn pthread_is_main_thread() -> Bool {
  native_pthread_main_np() != 0
}

///|
fn cg_active_display_count() -> Int {
  let count = native_cg_active_display_count()
  if count < 0 {
    0
  } else {
    count
  }
}

///|
fn cg_active_display_id_at(index : Int) -> UInt64 {
  native_cg_active_display_id_at(index).to_uint64()
}

///|
fn cg_display_bounds_x(display_id : UInt64) -> Int {
  native_cg_display_bounds_x(display_id.to_uint())
}

///|
fn cg_display_bounds_y(display_id : UInt64) -> Int {
  native_cg_display_bounds_y(display_id.to_uint())
}

///|
fn cg_display_scale_factor(display_id : UInt64) -> Double {
  let factor = native_cg_display_scale_factor(display_id.to_uint())
  if factor > 0.0 {
    factor
  } else {
    1.0
  }
}

///|
fn objc_runtime_class_handle(name : String) -> UInt64 {
  appkit_objc_get_class(@utf8.encode(name[:], bom=false))
}

///|
fn objc_runtime_selector_handle(name : String) -> UInt64 {
  appkit_objc_sel_register_name(@utf8.encode(name[:], bom=false))
}

///|
fn objc_utf8_bytes_from_object(handle : UInt64) -> Bytes {
  if handle == (0 : Int).to_uint64() {
    return b""
  }
  native_objc_copy_utf8_bytes(handle)
}

///|
fn objc_nsstring_from_string(value : String) -> UInt64 {
  let ns_string = objc_runtime_class_handle("NSString")
  if ns_string == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64_bytes(
    ns_string,
    objc_runtime_selector_handle("stringWithUTF8String:"),
    @utf8.encode(value[:], bom=false),
  )
}

///|
fn objc_theme_from_appearance_handle(appearance : UInt64) -> Int {
  if appearance == (0 : Int).to_uint64() {
    return 0
  }
  let name_handle = appkit_objc_msg_send_u64(
    appearance,
    objc_runtime_selector_handle("name"),
  )
  if name_handle == (0 : Int).to_uint64() {
    return 0
  }
  let name = @utf8.decode_lossy(
    objc_utf8_bytes_from_object(name_handle)[:],
    ignore_bom=false,
  )
  if name == "NSAppearanceNameDarkAqua" ||
    name == "NSAppearanceNameVibrantDark" ||
    name == "NSAppearanceNameAccessibilityHighContrastDarkAqua" {
    2
  } else if name == "NSAppearanceNameAqua" ||
    name == "NSAppearanceNameVibrantLight" ||
    name == "NSAppearanceNameAccessibilityHighContrastAqua" {
    1
  } else {
    0
  }
}

///|
fn native_application_shared_handle() -> UInt64 {
  let app_class = objc_runtime_class_handle("NSApplication")
  if app_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(
    app_class,
    objc_runtime_selector_handle("sharedApplication"),
  )
}

///|
fn native_window_objc_handle(handle : UInt64) -> UInt64 {
  if handle == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let window_or_self = appkit_objc_msg_send_u64(
    handle,
    objc_runtime_selector_handle("window"),
  )
  if window_or_self == (0 : Int).to_uint64() {
    handle
  } else {
    window_or_self
  }
}

///|
fn native_window_content_view_objc_handle(handle : UInt64) -> UInt64 {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(window, objc_runtime_selector_handle("contentView"))
}

///|
fn native_window_delegate_objc_handle(handle : UInt64) -> UInt64 {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(window, objc_runtime_selector_handle("delegate"))
}

///|
fn normalize_ime_purpose_native(purpose : Int) -> Int {
  match purpose {
    1 => 1
    2 => 2
    3 => 3
    4 => 4
    5 => 5
    6 => 6
    7 => 7
    8 => 8
    9 => 9
    10 => 10
    _ => 0
  }
}

///|
fn normalize_window_level_native(level : Int) -> Int {
  match level {
    1 => 1
    2 => 2
    _ => 0
  }
}

///|
fn normalize_option_as_alt_native(option_as_alt : Int) -> Int {
  match option_as_alt {
    1 => 1
    2 => 2
    3 => 3
    _ => 0
  }
}

///|
fn normalize_ime_hints_bits(hints : Int) -> Int {
  let non_negative = if hints < 0 { 0 } else { hints }
  non_negative & 1023
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
fn theme_to_native(theme : @core.Theme?) -> Int {
  match theme {
    Some(@core.Theme::Light) => 1
    Some(@core.Theme::Dark) => 2
    None => 0
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
fn drag_paths_from_native(bytes : Bytes) -> Array[String] {
  let text = text_from_native(bytes)
  let paths : Array[String] = []
  for path in text.split("\n"[:]) {
    let value = path.to_string()
    if value != "" {
      paths.push(value)
    }
  }
  paths
}

///|
fn ime_purpose_to_native(purpose : @core.ImePurpose) -> Int {
  match purpose {
    @core.ImePurpose::Normal => 0
    @core.ImePurpose::Password => 1
    @core.ImePurpose::Terminal => 2
    @core.ImePurpose::Number => 3
    @core.ImePurpose::Phone => 4
    @core.ImePurpose::Url => 5
    @core.ImePurpose::Email => 6
    @core.ImePurpose::Pin => 7
    @core.ImePurpose::Date => 8
    @core.ImePurpose::Time => 9
    @core.ImePurpose::DateTime => 10
  }
}

///|
fn ime_purpose_from_native(purpose : Int) -> @core.ImePurpose {
  match normalize_ime_purpose_native(purpose) {
    1 => @core.ImePurpose::Password
    2 => @core.ImePurpose::Terminal
    3 => @core.ImePurpose::Number
    4 => @core.ImePurpose::Phone
    5 => @core.ImePurpose::Url
    6 => @core.ImePurpose::Email
    7 => @core.ImePurpose::Pin
    8 => @core.ImePurpose::Date
    9 => @core.ImePurpose::Time
    10 => @core.ImePurpose::DateTime
    _ => @core.ImePurpose::Normal
  }
}

///|
fn window_level_to_native(level : @core.WindowLevel) -> Int {
  match level {
    @core.WindowLevel::Normal => 0
    @core.WindowLevel::AlwaysOnTop => 1
    @core.WindowLevel::AlwaysOnBottom => 2
  }
}

///|
fn window_level_from_native(level : Int) -> @core.WindowLevel {
  match normalize_window_level_native(level) {
    1 => @core.WindowLevel::AlwaysOnTop
    2 => @core.WindowLevel::AlwaysOnBottom
    _ => @core.WindowLevel::Normal
  }
}

///|
fn resize_direction_to_native(direction : @core.ResizeDirection) -> Int {
  match direction {
    @core.ResizeDirection::East => 0
    @core.ResizeDirection::North => 1
    @core.ResizeDirection::NorthEast => 2
    @core.ResizeDirection::NorthWest => 3
    @core.ResizeDirection::South => 4
    @core.ResizeDirection::SouthEast => 5
    @core.ResizeDirection::SouthWest => 6
    @core.ResizeDirection::West => 7
  }
}

///|
fn user_attention_type_to_native(
  request_type : @core.UserAttentionType?,
) -> Int {
  match request_type {
    None => 0
    Some(@core.UserAttentionType::Critical) => 1
    Some(@core.UserAttentionType::Informational) => 2
  }
}

///|
fn option_as_alt_to_native(option_as_alt : @core.OptionAsAlt) -> Int {
  match option_as_alt {
    @core.OptionAsAlt::OnlyLeft => 1
    @core.OptionAsAlt::OnlyRight => 2
    @core.OptionAsAlt::Both => 3
    @core.OptionAsAlt::None => 0
  }
}

///|
fn option_as_alt_from_native(option_as_alt : Int) -> @core.OptionAsAlt {
  match normalize_option_as_alt_native(option_as_alt) {
    1 => @core.OptionAsAlt::OnlyLeft
    2 => @core.OptionAsAlt::OnlyRight
    3 => @core.OptionAsAlt::Both
    _ => @core.OptionAsAlt::None
  }
}
