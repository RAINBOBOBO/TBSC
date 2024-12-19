class_name Thing extends Node

var composition:= Composition.new()


func _init() -> void:
	_setup_composition()
	composition.print_composition()


func add_component(new_component: Component) -> void:
	composition.add_component(new_component)


func component(search: Component) -> void:
	pass


func _setup_composition() -> void:
	push_warning("Just tried to setup a generic Thing class. Something has gone wrong.")
