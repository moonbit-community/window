///|
test "system menu descriptors retain item details" {
  let open = SystemMenuItemDescriptor::new(
    title="Open",
    action_id=7,
    key_equivalent="o",
    key_modifier_mask=1_048_576,
    separator=false,
  )
  let separator = SystemMenuItemDescriptor::new(
    title="",
    action_id=0,
    key_equivalent="",
    key_modifier_mask=-1,
    separator=true,
  )
  let file_menu = SystemMenuDescriptor::new(title="File", items=[
    open, separator,
  ])

  assert_eq(file_menu.title, "File")
  assert_eq(file_menu.items.length(), 2)
  assert_eq(file_menu.items[0].title, "Open")
  assert_eq(file_menu.items[0].action_id, 7)
  assert_eq(file_menu.items[0].key_equivalent, "o")
  assert_eq(file_menu.items[0].key_modifier_mask, 1_048_576)
  assert_false(file_menu.items[0].separator)
  assert_true(file_menu.items[1].separator)
}
