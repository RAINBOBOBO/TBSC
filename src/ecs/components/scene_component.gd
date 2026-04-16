class_name SceneComponent extends Component

# Holds the live Godot node that represents this entity
# in the scene tree. Set by SpawnSystem.attach_node() —
# never by build().

var node: Node2D = null
var scene_path: String = ""


static func build(
    entity: EntityData,
    blueprint: Dictionary,
    archetype_id: String
) -> void:
    assert(blueprint.has("scene"),
        ("SceneComponent: archetype '%s' is missing"
        + " a [SCENE] tag") % archetype_id)

    var component := SceneComponent.new()
    component.scene_path = blueprint["scene"]["path"]

    # Node attachment is intentionally left to SpawnSystem.
    # build() only records what scene to use.
    entity.add_component("scene", component)
