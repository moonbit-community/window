///|
test "native input text payload applies left option as alt" {
  let text = native_input_keyboard_text_payload(
    7,
    10,
    0x20,
    1,
    @utf8.encode("option-a"[:], bom=false),
    @utf8.encode("a"[:], bom=false),
    @utf8.encode("option-a"[:], bom=false),
  )

  assert_eq(text.text_with_all_modifiers, @utf8.encode("a"[:], bom=false))
  assert_eq(text.text_without_modifiers, @utf8.encode("a"[:], bom=false))
}

///|
test "native input text payload keeps option text with control modifier" {
  let text = native_input_keyboard_text_payload(
    7,
    10,
    0x20 | 262_144,
    1,
    @utf8.encode("control-option-a"[:], bom=false),
    @utf8.encode("a"[:], bom=false),
    @utf8.encode("control-option-a"[:], bom=false),
  )

  assert_eq(
    text.text_with_all_modifiers,
    @utf8.encode("control-option-a"[:], bom=false),
  )
  assert_eq(text.text_without_modifiers, @utf8.encode("a"[:], bom=false))
}
