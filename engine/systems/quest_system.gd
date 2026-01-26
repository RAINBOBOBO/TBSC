class_name QuestSystem extends Node

@export var entity_manager: EntityManager

signal quest_assigned(quest_id: int, company_id: int, staff_ids: Array[int])
signal quest_resolved(
	quest_id: int,
	company_id: int,
	staff_ids: Array[int],
	outcome: Dictionary,
)


func generate_quest(difficulty: int = -1) -> EntityData:
	var quest_entity: EntityData = entity_manager.create_entity()
	var quest = JobComponent.new()

	quest.title = _generate_quest_title()
	quest.description = "This quest may not be as placeholder as it seems..."
	quest.difficulty = difficulty if difficulty != -1 else randi_range(1, 10)
	quest.min_performance_score = 40 + (quest.difficulty * 10)
	quest.reward_gold = (quest.difficulty * 100) + randi_range(0, 100)
	quest.reward_xp = (quest.difficulty * 10) + randi_range(0, 20)
	quest.attribute_weights = _generate_random_weights()
	quest.state = JobComponent.JobState.AVAILABLE

	quest_entity.add_component("JobComponent", quest)

	return quest_entity


func assign_staff_to_quest(
	company_id: int,
	quest_entity_id: int,
	staff_ids: Array[int],
) -> bool:
	var quest: JobComponent = entity_manager.get_entity_component(
		quest_entity_id,
		"JobComponent",
	)

	if not quest:
		push_error("Quest entity not found or missing JobComponent")
		return false

	if quest.state != JobComponent.JobState.AVAILABLE:
		push_error("Quest is not available")
		return false

	quest.state = JobComponent.JobState.ACTIVE
	quest.assigned_staff_ids = staff_ids.duplicate()
	quest.assigned_company_id = company_id

	quest_assigned.emit(quest_entity_id, company_id, staff_ids)

	return true


func resolve_quest(quest_entity_id: int) -> Dictionary:
	var quest: JobComponent = entity_manager.get_entity_component(
		quest_entity_id,
		"JobComponent",
	)
	if not quest or quest.state != JobComponent.JobState.ACTIVE:
		return {}

	var party_stats: Dictionary = _calculate_party_stats(
		quest.assigned_staff_ids
	)

	var performance_score = _calculate_performance_score(
		party_stats,
		quest.attribute_weights,
	)

	var luck_bonus = randi_range(1, 20)
	var final_score = performance_score + luck_bonus

	var score_diff = final_score - quest.min_performance_score
	var outcome: Dictionary

	if score_diff > 5:
		# Perfect completion - no damage
		outcome = {
			"result": "perfect",
			"damage_per_member": 0,
			"xp_per_member": quest.reward_xp,
			"gold_reward": quest.reward_gold,
			"score": final_score,
			"required": quest.min_performance_score,
		}
		quest.state = JobComponent.JobState.COMPLETED
	elif score_diff >= -5:
		# Decent completion - some damage
		outcome = {
			"result": "success",
			"damage_per_member": 15 + randi_range(0, 10),
			"xp_per_member": quest.reward_xp,
			"gold_reward": quest.reward_gold,
			"score": final_score,
			"required": quest.min_performance_score,
		}
		quest.state = JobComponent.JobState.COMPLETED
	else:
		# Failed - heavy damage
		outcome = {
			"result": "failure",
			"damage_per_member": 30 + randi_range(0, 20),
			"xp_per_member": int(quest.reward_xp / 2.0),
			"gold_reward": 0,
			"score": final_score,
			"required": quest.min_performance_score,
		}
		quest.state = JobComponent.JobState.FAILED

	_apply_quest_outcome(quest.assigned_staff_ids, outcome)

	quest_resolved.emit(
		quest_entity_id,
		quest.assigned_company_id,
		quest.assigned_staff_ids,
		outcome,
	)

	return outcome


# query functions
func get_active_quests() -> Array[EntityData]:
	var all_quests: Array[EntityData] = entity_manager.get_entities_with(
		"JobComponent"
	)
	var active_quests: Array[EntityData] = []

	for quest_entity in all_quests:
		var job: JobComponent = quest_entity.get_component("JobComponent")
		if job and job.state == JobComponent.JobState.ACTIVE:
			active_quests.append(quest_entity)

	return active_quests


func get_available_quests() -> Array[EntityData]:
	var all_quests: Array[EntityData] = entity_manager.get_entities_with(
		"JobComponent"
	)
	var available_quests: Array[EntityData] = []

	for quest_entity in all_quests:
		var job: JobComponent = quest_entity.get_component("JobComponent")
		if job and job.state == JobComponent.JobState.AVAILABLE:
			available_quests.append(quest_entity)

	return available_quests


func get_company_active_quests(company_id: int) -> Array[EntityData]:
	var active_quests: Array[EntityData] = get_active_quests()
	var company_quests: Array[EntityData] = []

	for quest_entity in active_quests:
		var job: JobComponent = quest_entity.get_component("JobComponent")
		if job and job.assigned_company_id == company_id:
			company_quests.append(quest_entity)

	return company_quests


# helpers
func _apply_quest_outcome(member_ids: Array[int], outcome: Dictionary) -> void:
	for member_id in member_ids:
		var stats: StatsComponent = entity_manager.get_entity_component(
			member_id,
			"StatsComponent",
		)
		if not stats:
			continue

		stats.health = max(0, stats.health - outcome["damage_per_member"])

		# TODO: Apply XP through an XP system
		# For now, you could add an XPComponent or handle it here
		# This is where you'd call something like:
		# xp_system.add_xp(member_id, outcome["xp_per_member"])


func _calculate_party_stats(member_ids: Array[int]) -> Dictionary:
	var total_stats = {
		"strength": 0,
		"dexterity": 0,
		"intelligence": 0,
		"magic": 0,
	}

	for member_id in member_ids:
		var stats: StatsComponent = entity_manager.get_entity_component(
			member_id,
			"StatsComponent",
		)
		if not stats:
			continue

		total_stats["strength"] += stats.strength
		total_stats["dexterity"] += stats.dexterity
		total_stats["intelligence"] += stats.intelligence
		total_stats["magic"] += stats.magic

	return total_stats


func _calculate_performance_score(
		party_stats: Dictionary,
		weights: Dictionary,
	) -> int:
	var total_score: int = 0

	for stat_name in party_stats:
		var stat_value: int = party_stats[stat_name]
		var weight: int = weights.get(stat_name, 1)
		total_score += stat_value * weight

	return total_score


func _generate_random_weights() -> Dictionary:
	var stats: Array[String] = [
		"strength",
		"dexterity",
		"intelligence",
		"magic",
	]
	var weights: Dictionary = {}

	for stat_name in stats:
		var roll: int = randi_range(1, 20)
		if roll > 17:
			weights[stat_name] = JobComponent.Relevance.CRITICAL
		elif roll < 11:
			weights[stat_name] = JobComponent.Relevance.NORMAL
		else:
			weights[stat_name] = JobComponent.Relevance.IMPORTANT

	return weights


func _generate_quest_title() -> String:
	var actions: Array[String] = [
		"Raid",
		"Defend",
		"Investigate",
		"Escort",
		"Hunt",
	]
	var targets: Array[String] = [
		"Goblin Village",
		"Ancient Ruins",
		"Merchant Caravan",
		"Dragon Lair",
		"Bandit Camp",
	]
	return "%s %s" % [
		actions[randi_range(0, actions.size() - 1)],
		targets[randi_range(0, targets.size() - 1)],
	]
