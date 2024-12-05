class_name Thing extends RefCounted


func get_components() -> Array[Component]:
	var components: Array[Component] = []
	for property in get_property_list():
		if property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE:

	return components
