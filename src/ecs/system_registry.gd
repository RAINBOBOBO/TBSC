class_name SystemRegistry extends Node

var systems: Dictionary = {} # name: system instance
var update_order: Array[String] = []
var initialized: bool = false
