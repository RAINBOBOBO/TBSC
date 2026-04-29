class_name Hitbox extends Area2D

# Attached to weapons, projectiles, or any swing/lunge
# that can deal damage. Carries the attacking entity's
# id and the raw damage value so the combat system has
# everything it needs to resolve the hit.
#
# Set attacker_entity_id and damage before enabling the
# hitbox — typically done by whatever system activates
# the attack.

var attacker_entity_id: int = 0
var damage: int = 0
