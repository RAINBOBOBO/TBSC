class_name ComponentTagRegistry extends RefCounted

# Each entry in _schema defines how to handle a tag when parsing an archetype.
#
# Schema entry format:
# {
#   "component": String,       -- which component key this tag writes to
#   "cardinality": "one"|"many", -- "one" = overwrites, "many" = appends to Array
#   "handler": Callable,       -- func(args: Array[String]) -> variant  (the parsed value)
# }
#
# To support a new component/tag: add an entry here and a builder in EntityFactory.
# The parser itself never needs to change.

var _schema: Dictionary = {}  # tag_name -> schema entry


func _init() -> void:
	_register_defaults()


func _register_defaults() -> void:
	# NAME tag: [NAME:Goblin Warrior]
	register("NAME", "name", "one", func(args: Array[String]):
		assert(args.size() >= 1, "RawParser: NAME tag requires 1 argument")
		return args[0]
	)

	# TITLE tag: [TITLE:of the Dark Caves]
	register("TITLE", "name", "one_secondary", func(args: Array[String]):
		assert(args.size() >= 1, "RawParser: TITLE tag requires 1 argument")
		return args[0]
	)

	# STAT tag: [STAT:key:value] or [STAT:key:min:max] or [STAT:key:RANDOM]
	register("STAT", "stats", "many", func(args: Array[String]):
		assert(args.size() >= 2, "RawParser: STAT tag requires at least 2 arguments (key, value/RANDOM/min max)")
		var key := args[0]
		if args.size() == 3:
			# Range: [STAT:strength:8:14]
			var lo := int(args[1])
			var hi := int(args[2])
			assert(lo <= hi, "RawParser: STAT range min must be <= max for key '%s'" % key)
			return { "key": key, "value": randi_range(lo, hi) }
		elif args[1] == "RANDOM":
			return { "key": key, "value": randi_range(1, 20) }
		else:
			return { "key": key, "value": int(args[1]) }
	)


# Register a new tag.
#   tag_name   -- the bracket token, e.g. "STAT"
#   component  -- logical component group, e.g. "stats"
#   cardinality-- "one" (single value), "one_secondary" (secondary slot on same component),
#                 or "many" (accumulates into Array)
#   handler    -- Callable(args: Array[String]) -> variant
func register(tag_name: String, component: String, cardinality: String, handler: Callable) -> void:
	_schema[tag_name] = {
		"component": component,
		"cardinality": cardinality,
		"handler": handler,
	}


func has_tag(tag_name: String) -> bool:
	return tag_name in _schema


func get_schema(tag_name: String) -> Dictionary:
	assert(has_tag(tag_name), "ComponentTagRegistry: unknown tag '%s' — register it in ComponentTagRegistry._register_defaults()" % tag_name)
	return _schema[tag_name]
