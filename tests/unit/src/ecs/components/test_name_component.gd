class_name TestNameComponent extends TestCase

func test_display_name_without_title() -> void:
    var c := NameComponent.new()
    c.name = "Goblin"
    assert_eq(c.display_name, "Goblin")


func test_display_name_with_title() -> void:
    var c := NameComponent.new()
    c.name = "Goblin"
    c.title = "of the Dark Caves"
    assert_eq(c.display_name, "Goblin, of the Dark Caves")
