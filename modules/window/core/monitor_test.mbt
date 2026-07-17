///|
struct CountingMonitorProvider {
  identity_high : UInt64
  identity_low : UInt64
  native_id : UInt64
  name : String?
  video_mode_calls : Array[Int]
}

///|
impl @core.MonitorHandleProvider for CountingMonitorProvider with fn id(self) {
  (self.identity_high, self.identity_low)
}

///|
impl @core.MonitorHandleProvider for CountingMonitorProvider with fn native_id(
  self,
) {
  self.native_id
}

///|
impl @core.MonitorHandleProvider for CountingMonitorProvider with fn name(self) {
  self.name
}

///|
impl @core.MonitorHandleProvider for CountingMonitorProvider with fn position(
  _self,
) {
  PhysicalPosition(10, 20)
}

///|
impl @core.MonitorHandleProvider for CountingMonitorProvider with fn surface_size(
  _self,
) {
  PhysicalSize(1920, 1080)
}

///|
impl @core.MonitorHandleProvider for CountingMonitorProvider with fn scale_factor(
  _self,
) {
  2.0
}

///|
impl @core.MonitorHandleProvider for CountingMonitorProvider with fn current_video_mode(
  _self,
) {
  None
}

///|
impl @core.MonitorHandleProvider for CountingMonitorProvider with fn video_modes(
  self,
) {
  self.video_mode_calls[0] = self.video_mode_calls[0] + 1
  []
}

///|
test "monitor handle identity is cheap and video modes are lazy" {
  let calls = [0]
  let handle_a = @core.MonitorHandle::from_provider(
    {
      identity_high: 7,
      identity_low: 11,
      native_id: 1,
      name: Some("first snapshot"),
      video_mode_calls: calls,
    }
    as &@core.MonitorHandleProvider,
  )
  let handle_b = @core.MonitorHandle::from_provider(
    {
      identity_high: 7,
      identity_low: 11,
      native_id: 2,
      name: Some("changed snapshot"),
      video_mode_calls: calls,
    }
    as &@core.MonitorHandleProvider,
  )

  assert_eq(calls[0], 0)
  assert_eq(handle_a, handle_b)
  assert_eq(calls[0], 0)
  assert_eq(handle_a.video_modes(), [])
  assert_eq(calls[0], 1)
}
