class_name EntityData extends RefCounted

var id: int
var components: Dictionary = {} # component_type: component_data

func add_component(component_type: String, component_data) -> void:
    components[component_type] = component_data

func get_component(component_type: String):
    return components.get(component_type)

func has_component(component_type: String) -> bool:
    return component_type in components

func remove_component(component_type: String) -> bool:
    return components.erase(component_type)

func get_component_types() -> Array[String]:
    return components.keys()
