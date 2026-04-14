class_name ArchetypeRegistry extends RefCounted

# Holds all parsed archetypes keyed by their ID.
# Populated at startup by passing raw files through RawParser.
# All other systems look up blueprints here before spawning entities.

var _archetypes: Dictionary = {}  # id: archetype_data


# Load and merge all archetypes from a parsed result
# (output of RawParser.parse_file).
func load_archetypes(parsed: Dictionary) -> void:
	for id in parsed:
		assert(not _archetypes.has(id),
			("ArchetypeRegistry: duplicate archetype id '%s'" \
			+ " — each archetype id must be unique" \
			+ " across all raw files") % id)
		_archetypes[id] = parsed[id]


func get_archetype(id: String) -> Dictionary:
	assert(_archetypes.has(id),
		("ArchetypeRegistry: archetype '%s' not found" \
		+ " — check your raw files and make sure" \
		+ " it's loaded") % id)
	return _archetypes[id]


func has_archetype(id: String) -> bool:
	return _archetypes.has(id)


func get_all_ids() -> Array[String]:
	return _archetypes.keys()


func count() -> int:
	return _archetypes.size()
