class_name Composition extends RefCounted

var components: Dictionary = {}


func add_component(new_component: Component) -> void:
	if not components.has(new_component.class_as_string):
		components[new_component.class_as_string] = [new_component]
		return

	if not new_component.stackable:
		return

	components[new_component.class_as_string].append(new_component)


func get_component(search: String) -> Component:
	if not components.has(search):
		return NullComponent.new()

	return components[search][-1]


func has(search: Component) -> bool:
	return components.has(search.class_as_string)


func print_composition() -> void:
	for component_array in components.values():
		print(component_array[-1])
