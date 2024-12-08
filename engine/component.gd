class_name Component extends RefCounted

var component_name: String

static func create_component(component_class_name: String) -> Component:
	print(ClassDB.get_class_list())
	var new_component: Component = ClassDB.instantiate(component_class_name)
	new_component.component_name = component_class_name
	return new_component


func _to_string() -> String:
	return component_name
