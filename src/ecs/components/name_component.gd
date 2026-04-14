class_name NameComponent extends Component

var name: String = "John Entity"
var title: String = ""
var display_name: String:
	get:
		if title.is_empty():
			return name
		return "%s, %s" % [name, title]


func _init(entity_name: String = "") -> void:
	if not entity_name.is_empty():
		name = entity_name


static func build(
	entity: EntityData,
	blueprint: Dictionary,
	archetype_id: String
) -> void:
	assert(blueprint.has("name"),
		"NameComponent: archetype '%s' is missing a [NAME] tag" \
		% archetype_id)

	var data: Dictionary = blueprint["name"]
	var component := NameComponent.new()

	assert(data.has("value"),
		"NameComponent: archetype '%s' [NAME] tag produced no value" \
		% archetype_id)
	component.name = data["value"]

	if data.has("secondary"):
		component.title = data["secondary"]

	entity.add_component("name", component)
