///|
pub fn ImeSurroundingText::max_text_bytes() -> Int {
  4000
}

///|
pub fn ImeSurroundingText::into_text(self : ImeSurroundingText) -> String {
  self.text
}

///|
pub fn ImeCapabilities::default() -> ImeCapabilities {
  ImeCapabilities::new(false, false, false)
}

///|
pub fn ImeCapabilities::all() -> ImeCapabilities {
  ImeCapabilities::new(true, true, true)
}

///|
pub fn ImeCapabilities::with_hint_and_purpose(
  self : ImeCapabilities,
) -> ImeCapabilities {
  self.hint_and_purpose = true
  self
}

///|
pub fn ImeCapabilities::without_hint_and_purpose(
  self : ImeCapabilities,
) -> ImeCapabilities {
  self.hint_and_purpose = false
  self
}

///|
pub fn ImeCapabilities::with_cursor_area(
  self : ImeCapabilities,
) -> ImeCapabilities {
  self.cursor_area = true
  self
}

///|
pub fn ImeCapabilities::without_cursor_area(
  self : ImeCapabilities,
) -> ImeCapabilities {
  self.cursor_area = false
  self
}

///|
pub fn ImeCapabilities::with_surrounding_text(
  self : ImeCapabilities,
) -> ImeCapabilities {
  self.surrounding_text = true
  self
}

///|
pub fn ImeCapabilities::without_surrounding_text(
  self : ImeCapabilities,
) -> ImeCapabilities {
  self.surrounding_text = false
  self
}

///|
pub struct ImeRequestData {
  priv mut cursor_area_position : @dpi.Position?
  priv mut cursor_area_size : @dpi.Size?
  priv mut hint : ImeHint?
  priv mut purpose : ImePurpose?
  priv mut surrounding_text : ImeSurroundingText?
} derive(Eq, Show)

///|
pub fn ImeRequestData::default() -> ImeRequestData {
  {
    cursor_area_position: None,
    cursor_area_size: None,
    hint: None,
    purpose: None,
    surrounding_text: None,
  }
}

///|
pub fn ImeRequestData::with_hint_and_purpose(
  self : ImeRequestData,
  hint : ImeHint,
  purpose : ImePurpose,
) -> ImeRequestData {
  self.hint = Some(hint)
  self.purpose = Some(purpose)
  self
}

///|
pub fn ImeRequestData::without_hint_and_purpose(
  self : ImeRequestData,
) -> ImeRequestData {
  self.hint = None
  self.purpose = None
  self
}

///|
pub fn ImeRequestData::with_cursor_area(
  self : ImeRequestData,
  position : @dpi.Position,
  size : @dpi.Size,
) -> ImeRequestData {
  self.cursor_area_position = Some(position)
  self.cursor_area_size = Some(size)
  self
}

///|
pub fn ImeRequestData::without_cursor_area(
  self : ImeRequestData,
) -> ImeRequestData {
  self.cursor_area_position = None
  self.cursor_area_size = None
  self
}

///|
pub fn ImeRequestData::with_surrounding_text(
  self : ImeRequestData,
  surrounding_text : ImeSurroundingText,
) -> ImeRequestData {
  self.surrounding_text = Some(surrounding_text)
  self
}

///|
pub fn ImeRequestData::without_surrounding_text(
  self : ImeRequestData,
) -> ImeRequestData {
  self.surrounding_text = None
  self
}

///|
pub fn ImeRequestData::hint(self : ImeRequestData) -> ImeHint? {
  self.hint
}

///|
pub fn ImeRequestData::hint_and_purpose(
  self : ImeRequestData,
) -> (ImeHint, ImePurpose)? {
  match (self.hint, self.purpose) {
    (Some(hint), Some(purpose)) => Some((hint, purpose))
    _ => None
  }
}

///|
pub fn ImeRequestData::purpose(self : ImeRequestData) -> ImePurpose? {
  self.purpose
}

///|
pub fn ImeRequestData::cursor_area_position(
  self : ImeRequestData,
) -> @dpi.Position? {
  self.cursor_area_position
}

///|
pub fn ImeRequestData::cursor_area(
  self : ImeRequestData,
) -> (@dpi.Position, @dpi.Size)? {
  match (self.cursor_area_position, self.cursor_area_size) {
    (Some(position), Some(size)) => Some((position, size))
    _ => None
  }
}

///|
pub fn ImeRequestData::cursor_area_size(self : ImeRequestData) -> @dpi.Size? {
  self.cursor_area_size
}

///|
pub fn ImeRequestData::surrounding_text(
  self : ImeRequestData,
) -> ImeSurroundingText? {
  self.surrounding_text
}

///|
pub fn ImeRequestData::has_hint_and_purpose(self : ImeRequestData) -> Bool {
  self.hint is Some(_) && self.purpose is Some(_)
}

///|
pub fn ImeRequestData::has_cursor_area(self : ImeRequestData) -> Bool {
  self.cursor_area_position is Some(_) && self.cursor_area_size is Some(_)
}

///|
pub fn ImeRequestData::has_surrounding_text(self : ImeRequestData) -> Bool {
  self.surrounding_text is Some(_)
}

///|
pub fn ImeRequestData::is_empty(self : ImeRequestData) -> Bool {
  self.has_hint_and_purpose() == false &&
  self.has_cursor_area() == false &&
  self.has_surrounding_text() == false
}

///|
pub fn ImeRequestData::into_request(self : ImeRequestData) -> ImeRequest {
  ImeRequest::Update(self)
}

///|
pub struct ImeEnableRequest {
  priv capabilities : ImeCapabilities
  priv request_data : ImeRequestData
} derive(Eq, Show)

///|
pub fn ImeEnableRequest::new(
  capabilities : ImeCapabilities,
  request_data : ImeRequestData,
) -> ImeEnableRequest? {
  if capabilities.hint_and_purpose() != request_data.has_hint_and_purpose() {
    return None
  }
  if capabilities.cursor_area() != request_data.has_cursor_area() {
    return None
  }
  if capabilities.surrounding_text() != request_data.has_surrounding_text() {
    return None
  }
  Some({ capabilities, request_data })
}

///|
pub fn ImeEnableRequest::capabilities(
  self : ImeEnableRequest,
) -> ImeCapabilities {
  self.capabilities
}

///|
pub fn ImeEnableRequest::request_data(
  self : ImeEnableRequest,
) -> ImeRequestData {
  self.request_data
}

///|
pub fn ImeEnableRequest::into_raw(
  self : ImeEnableRequest,
) -> (ImeCapabilities, ImeRequestData) {
  (self.capabilities, self.request_data)
}

///|
pub fn ImeEnableRequest::into_request(self : ImeEnableRequest) -> ImeRequest {
  ImeRequest::Enable(self)
}
