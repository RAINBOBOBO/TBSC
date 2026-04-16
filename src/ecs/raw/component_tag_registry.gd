class_name ComponentTagRegistry extends RefCounted

# Each entry in _schema defines how to handle a tag when parsing an archetype.
#
# Schema entry format:
# {
#   "component":       String,   -- component key this tag writes to
#   "component_class": GDScript, -- Component subclass that builds this
#   "cardinality":     String,   -- "one" = named field, "many" = Array
#   "field":           String,   -- (one only) dict key inside the component
#   "handler":         Callable, -- func(args: Array[String]) -> variant
# }
#
# To add a new component/tag: add an entry here and implement build()
# on the component class. The parser and factory never need to change.

var _schema: Dictionary = {}            # tag_name -> schema entry
var _component_classes: Dictionary = {} # component_key -> Component subclass


func _init() -> void:
	_register_defaults()


func _register_defaults() -> void:
	# NAME tag: [NAME:Goblin Warrior]
	register("NAME", "name", NameComponent, "one", "value",
		func(args: Array[String]):
			assert(args.size() >= 1,
				"RawParser: NAME tag requires 1 argument")
			return args[0]
	)

	# TITLE tag: [TITLE:of the Dark Caves]
	register("TITLE", "name", NameComponent, "one", "secondary",
		func(args: Array[String]):
			assert(args.size() >= 1,
				"RawParser: TITLE tag requires 1 argument")
			return args[0]
	)

	# STAT tag: [STAT:key:value] or [STAT:key:min:max] or [STAT:key:RANDOM]
	register("STAT", "stats", StatsComponent, "many", "",
		func(args: Array[String]):
			assert(args.size() >= 2,
				"RawParser: STAT tag requires at least 2 arguments " \
				+ "(key, value/RANDOM/min max)")
			var key := args[0]
			if args.size() == 3:
				# Range: [STAT:strength:8:14]
				var lo := int(args[1])
				var hi := int(args[2])
				assert(lo <= hi,
					("RawParser: STAT range min must be <= max " \
					+ "for key '%s'") % key)
				return { "key": key, "value": randi_range(lo, hi) }
			elif args[1] == "RANDOM":
				return { "key": key, "value": randi_range(1, 20) }
			else:
				return { "key": key, "value": int(args[1]) }
	)

	# SCENE tag: [SCENE:res://scenes/characters/human.tscn]
	register("SCENE", "scene", SceneComponent, "one", "path",
		func(args: Array[String]):
			assert(args.size() >= 2,
				"RawParser: SCENE tag requires a res:// path")
			var path := ":".join(args)
			assert(path.begins_with("res://"),
				("RawParser: SCENE path must begin with"
				+ " 'res://' — got '%s'") % path)
			return path
	)


# Register a new tag.
#   tag_name        -- the bracket token, e.g. "STAT"
#   component       -- logical component group, e.g. "stats"
#   component_class -- the Component subclass that owns this component key
#   cardinality     -- "one" (named field) or "many" (accumulates into Array)
#   field           -- for "one": dict key to write (e.g. "value", "secondary")
#                      pass "" for "many" tags — it is ignored
#   handler         -- Callable(args: Array[String]) -> variant
func register(
	tag_name: String,
	component: String,
	component_class: GDScript,
	cardinality: String,
	field: String,
	handler: Callable
) -> void:
	assert(
		component_class.get_base_script() == Component \
		or component_class == Component,
		"ComponentTagRegistry: '%s' must extend Component" % tag_name)

	_schema[tag_name] = {
		"component": component,
		"component_class": component_class,
		"cardinality": cardinality,
		"field": field,
		"handler": handler,
	}
	_component_classes[component] = component_class


func has_tag(tag_name: String) -> bool:
	return tag_name in _schema


func get_schema(tag_name: String) -> Dictionary:
	assert(has_tag(tag_name),
		("ComponentTagRegistry: unknown tag '%s' " \
		+ "— register it in ComponentTagRegistry._register_defaults()") \
		% tag_name)
	return _schema[tag_name]


# Returns build targets for every component key present in the blueprint.
# Each entry is { "key": component_key, "class": component_class }.
func get_builders_for(blueprint: Dictionary) -> Array:
	var builders: Array = []
	for component_key in _component_classes:
		if blueprint.has(component_key):
			builders.append({
				"key": component_key,
				"class": _component_classes[component_key]
			})
	return builders
