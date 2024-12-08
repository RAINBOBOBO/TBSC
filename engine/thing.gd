class_name Thing extends RefCounted

var name: String

func get_components() -> Array[Component]:
	var components: Array[Component] = []

	for property in get_property_list():
		if property.usage and property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE:
			var new_component: Component = Component.create_component(
				property.get("class_name")
			)
			components.append(new_component)

	return components
