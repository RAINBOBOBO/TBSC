class_name Component extends Resource

# Base class for all components.
# Every subclass must override build() to construct itself
# from a blueprint dictionary.

static func build(
	_entity: EntityData,
	_blueprint: Dictionary,
	_archetype_id: String
) -> void:
	assert(false, "Component: build() not implemented by subclass")
