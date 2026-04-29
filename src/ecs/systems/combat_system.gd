class_name CombatSystem extends RefCounted

# Resolves hits by reading and writing StatsComponents.
# Never touches the scene tree directly — it only knows
# about entity ids and components.
#
# Wire this up by connecting Hurtbox.hit_received to
# CombatSystem.on_hit_received, which GameManager does
# at spawn time.

var _entity_manager: EntityManager


func _init(entity_manager: EntityManager) -> void:
	_entity_manager = entity_manager


func on_hit_received(
	target_entity_id: int,
	hitbox: Hitbox
) -> void:
	var target := _entity_manager.get_entity(target_entity_id)
	assert(target != null,
		("CombatSystem: no entity found for id %d"
		+ " — entity may have been deleted before"
		+ " hit was resolved") % target_entity_id)

	var stats := target.get_component("stats") as StatsComponent
	if stats == null:
		return

	stats.health = max(0, stats.health - hitbox.damage)

	if stats.health == 0:
		_on_entity_died(target)


func _on_entity_died(entity: EntityData) -> void:
	# Placeholder — death handling will go here.
	# Could emit a signal, queue despawn, drop loot, etc.
	pass
