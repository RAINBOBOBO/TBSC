class_name CharacterBody extends CharacterBody2D

# Base node script for all entities that live in the scene
# tree. Intentionally thin — ECS systems own behaviour,
# this script only owns what the scene tree needs to know
# about an entity.
#
# All character and enemy packed scenes should use this
# script (or a subclass of it) as their root node script.
#
# entity_id is stamped by SpawnSystem.attach_node() after
# instantiation. It is 0 until then — never read it in
# _ready(), only in signals and system callbacks that fire
# after SpawnSystem has finished.

var entity_id: int = 0


# Hurtbox: the Area2D that receives incoming hits.
# Subclasses can override this to return a differently
# named node if needed, but by convention every character
# scene should have a child node named "Hurtbox".
func get_hurtbox() -> Area2D:
	return $Hurtbox
