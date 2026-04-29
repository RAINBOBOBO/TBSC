class_name Hurtbox extends Area2D

# Receives incoming hitbox overlaps and re-emits them as
# a clean signal carrying the entity_id of the owner.
#
# This script should be attached to the Hurtbox Area2D
# node in every character scene. It is intentionally
# dumb — it only translates a Godot signal into an
# ECS-friendly one. No damage logic lives here.

signal hit_received(owner_entity_id: int, hitbox: Hitbox)

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if not area is Hitbox:
		return

	var owner_node := get_parent() as CharacterBody
	assert(owner_node != null,
		("Hurtbox: parent is not a CharacterBody"
		+ " — hurtbox must be a direct child of a"
		+ " CharacterBody node"))
	assert(owner_node.entity_id != 0,
		("Hurtbox: entity_id is 0 on parent node"
		+ " — SpawnSystem has not stamped this node yet"))

	hit_received.emit(owner_node.entity_id, area as Hitbox)
