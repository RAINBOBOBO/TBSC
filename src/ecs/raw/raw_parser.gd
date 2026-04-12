class_name RawParser extends RefCounted

# Parses DF-style .cfg raw files into a flat Dictionary of archetype data.
#
# Output format per archetype:
# {
#   "id": "GOBLIN_WARRIOR",
#   "name":  { "value": "Goblin Warrior", "secondary": "of the Dark Caves" },
#   "stats": [ { "key": "strength", "value": 12 }, ... ],
# }
#
# The parser is intentionally data-agnostic — it delegates all tag meaning
# to ComponentTagRegistry. To support new tags, only the registry changes.

var _registry: ComponentTagRegistry


func _init(registry: ComponentTagRegistry) -> void:
	_registry = registry


# Parse a .cfg file at the given res:// or absolute path.
# Returns a Dictionary of { archetype_id: archetype_data }.
func parse_file(path: String) -> Dictionary:
	assert(FileAccess.file_exists(path), "RawParser: file not found: '%s'" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	assert(file != null, "RawParser: could not open file: '%s'" % path)
	var text := file.get_as_text()
	file.close()
	return parse_text(text, path)


# Parse raw text directly (useful for testing).
func parse_text(text: String, source_label: String = "<string>") -> Dictionary:
	var archetypes: Dictionary = {}
	var current_id: String = ""
	var current_data: Dictionary = {}
	var line_number := 0

	for raw_line in text.split("\n"):
		line_number += 1
		var line := raw_line.strip_edges()

		# Skip blanks and comments
		if line.is_empty() or line.begins_with("#"):
			continue

		assert(line.begins_with("[") and line.ends_with("]"),
			"RawParser: malformed line %d in %s — expected [TAG:...]: '%s'" % [line_number, source_label, line])

		# Strip brackets and split on ':'
		var inner := line.substr(1, line.length() - 2)
		var parts := inner.split(":")
		var tag := parts[0].strip_edges().to_upper()
		var args: Array[String] = []
		for i in range(1, parts.size()):
			args.append(parts[i].strip_edges())

		# --- Control tags ---
		if tag == "ARCHETYPE":
			if args[0] == "END":
				assert(current_id != "",
					"RawParser: [ARCHETYPE:END] found with no open archetype at line %d in %s" % [line_number, source_label])
				archetypes[current_id] = current_data
				current_id = ""
				current_data = {}
			else:
				assert(current_id == "",
					"RawParser: nested [ARCHETYPE] at line %d in %s — did you forget [ARCHETYPE:END]?" % [line_number, source_label])
				current_id = args[0]
				current_data = { "id": current_id }
			continue

		# All non-control tags must be inside an archetype block
		assert(current_id != "",
			"RawParser: tag [%s] at line %d in %s is outside an [ARCHETYPE] block" % [tag, line_number, source_label])

		# Delegate to registry
		assert(_registry.has_tag(tag),
			"RawParser: unknown tag [%s] at line %d in %s — register it in ComponentTagRegistry" % [tag, line_number, source_label])

		var schema := _registry.get_schema(tag)
		var component_key: String = schema["component"]
		var cardinality: String = schema["cardinality"]
		var field: String = schema["field"]
		var handler: Callable = schema["handler"]
		var value = handler.call(args)

		match cardinality:
			"one":
				if not current_data.has(component_key):
					current_data[component_key] = {}
				current_data[component_key][field] = value
			"many":
				if not current_data.has(component_key):
					current_data[component_key] = []
				current_data[component_key].append(value)
			_:
				assert(false, "RawParser: unknown cardinality '%s' for tag [%s]" % [cardinality, tag])

	assert(current_id == "",
		"RawParser: file '%s' ended without closing the last [ARCHETYPE] block (id: '%s')" % [source_label, current_id])

	return archetypes
