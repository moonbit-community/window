///|
priv struct MaximizedStandardFrame {
  x : Double
  y : Double
  width : Double
  height : Double
}

///|
priv struct MaximizedStandardFrameEntry {
  window_handle : UInt64
  mut frame : MaximizedStandardFrame
}

///|
priv struct FullscreenTransitionEntry {
  window_handle : UInt64
  mut in_transition : Bool
  mut target_fullscreen : Bool?
}

///|
let maximized_standard_frame_entries : Ref[Array[MaximizedStandardFrameEntry]] = Ref([],
)

///|
let fullscreen_transition_entries : Ref[Array[FullscreenTransitionEntry]] = Ref([],
)

///|
fn clear_all_window_fullscreen_state() -> Unit {
  maximized_standard_frame_entries.val = []
  fullscreen_transition_entries.val = []
}

///|
fn maximized_standard_frame_index(window_handle : UInt64) -> Int? {
  let window_identity = window_handle
  maximized_standard_frame_entries.val.search_by(entry => {
    entry.window_handle == window_identity
  })
}

///|
fn set_maximized_standard_frame_state(
  window_handle : UInt64,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Unit {
  let frame = { x, y, width, height }
  match maximized_standard_frame_index(window_handle) {
    Some(index) => maximized_standard_frame_entries.val[index].frame = frame
    None => maximized_standard_frame_entries.val.push({ window_handle, frame })
  }
}

///|
fn maximized_standard_frame_state(
  window_handle : UInt64,
) -> MaximizedStandardFrame? {
  match maximized_standard_frame_index(window_handle) {
    Some(index) => Some(maximized_standard_frame_entries.val[index].frame)
    None => None
  }
}

///|
fn clear_maximized_standard_frame_state(window_handle : UInt64) -> Unit {
  match maximized_standard_frame_index(window_handle) {
    Some(index) => ignore(maximized_standard_frame_entries.val.remove(index))
    None => ()
  }
}

///|
fn fullscreen_transition_index(window_handle : UInt64) -> Int? {
  let window_identity = window_handle
  fullscreen_transition_entries.val.search_by(entry => {
    entry.window_handle == window_identity
  })
}

///|
fn fullscreen_transition_ensure_index(window_handle : UInt64) -> Int {
  match fullscreen_transition_index(window_handle) {
    Some(index) => index
    None => {
      fullscreen_transition_entries.val.push({
        window_handle,
        in_transition: false,
        target_fullscreen: None,
      })
      fullscreen_transition_entries.val.length() - 1
    }
  }
}

///|
fn set_window_fullscreen_transition_state(
  window_handle : UInt64,
  in_transition : Bool,
) -> Unit {
  let index = fullscreen_transition_ensure_index(window_handle)
  fullscreen_transition_entries.val[index].in_transition = in_transition
}

///|
fn set_window_target_fullscreen_state(
  window_handle : UInt64,
  fullscreen : Bool,
) -> Unit {
  let index = fullscreen_transition_ensure_index(window_handle)
  fullscreen_transition_entries.val[index].target_fullscreen = Some(fullscreen)
}

///|
fn clear_window_target_fullscreen_state(window_handle : UInt64) -> Unit {
  match fullscreen_transition_index(window_handle) {
    Some(index) =>
      fullscreen_transition_entries.val[index].target_fullscreen = None
    None => ()
  }
}

///|
fn take_window_target_fullscreen_state(window_handle : UInt64) -> Bool? {
  match fullscreen_transition_index(window_handle) {
    Some(index) => {
      let target = fullscreen_transition_entries.val[index].target_fullscreen
      fullscreen_transition_entries.val[index].target_fullscreen = None
      target
    }
    None => None
  }
}

///|
fn clear_window_fullscreen_transition_state(window_handle : UInt64) -> Unit {
  match fullscreen_transition_index(window_handle) {
    Some(index) => ignore(fullscreen_transition_entries.val.remove(index))
    None => ()
  }
}

///|
fn window_in_fullscreen_transition(window_handle : NativeWindow) -> Bool {
  match fullscreen_transition_index(native_window_identity(window_handle)) {
    Some(index) => fullscreen_transition_entries.val[index].in_transition
    None => false
  }
}

///|
fn native_window_store_standard_frame(
  handle : NativeWindow,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Unit {
  set_maximized_standard_frame_state(
    native_window_identity(handle),
    x,
    y,
    width,
    height,
  )
}

///|
fn native_window_saved_standard_frame(
  handle : NativeWindow,
) -> MaximizedStandardFrame? {
  maximized_standard_frame_state(native_window_identity(handle))
}

///|
fn native_window_forget_standard_frame(handle : NativeWindow) -> Unit {
  clear_maximized_standard_frame_state(native_window_identity(handle))
}
