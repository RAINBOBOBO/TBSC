class_name SpawnSystem extends Node

# Bridges the ECS and the Godot scene tree.
#
# EntityFactory.spawn() creates pure data entities.
# This system handles the second, optional step:
# instantiating a PackedScene and wiring it to the entity.
#
# Headless entities (off-screen NPCs, unit-test subjects)
# are never passed to this system, so they never touch
# the scene tree.

var _entity_manager: EntityManager


func _init(entity_manager: EntityManager) -> void:
    _entity_manager = entity_manager


# Instantiate a node for the given entity and add it to
# parent. Stamps entity_id onto the node so combat signals
# can route back into the ECS.
#
# Crashes loudly if:
#   - the entity has no SceneComponent
#   - the scene_path does not resolve to a PackedScene
func attach_node(
    entity: EntityData,
    parent: Node
) -> Node2D:
    var scene_comp := (
        entity.get_component("scene") as SceneComponent)
    assert(scene_comp != null,
        ("SpawnSystem: entity %d has no SceneComponent"
        + " — attach_node() should only be called on"
        + " entities with a [SCENE] tag") % entity.id)

    var packed := load(scene_comp.scene_path)
    assert(packed is PackedScene,
        ("SpawnSystem: '%s' did not load as a PackedScene"
        + " for entity %d") % [scene_comp.scene_path,
        entity.id])

    var node := packed.instantiate() as Node2D
    assert(node != null,
        ("SpawnSystem: scene '%s' did not instantiate as"
        + " Node2D for entity %d") % [scene_comp.scene_path,
        entity.id])

    # Stamp the entity id so Area2D/hitbox signals can
    # look this entity back up in the ECS.
    assert("entity_id" in node,
        ("SpawnSystem: node from '%s' is missing an"
        + " entity_id property — add 'var entity_id: int'"
        + " to its root script") % scene_comp.scene_path)
    node.entity_id = entity.id

    parent.add_child(node)
    scene_comp.node = node

    return node


# Remove the node from the scene tree and clear the
# reference on SceneComponent. The entity and its data
# components are unaffected — it becomes dormant.
func detach_node(entity: EntityData) -> void:
    var scene_comp := (
        entity.get_component("scene") as SceneComponent)
    if scene_comp == null or scene_comp.node == null:
        return

    scene_comp.node.queue_free()
    scene_comp.node = null
