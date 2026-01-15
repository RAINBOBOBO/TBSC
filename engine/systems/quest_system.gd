class_name QuestSystem extends Node

var entity_manager: EntityManager

func _init(em: EntityManager) -> void:
	entity_manager = em


func generate_quest(difficulty: int = -1) -> EntityData:
	var quest_entity: EntityData = entity_manager.create_entity()
	var quest = JobComponent.new()

	quest.title = "raid goblin village"
	quest.description = "kill all the goblins mercilessly"
	quest.difficulty = randi_range(1, 10)
	quest.min_performance_score = 40 + (quest.difficulty * 10)
	quest.reward_gold = (quest.difficulty * 100) + randi_range(0, 100)
	quest.reward_xp = (quest.difficulty * 10) + randi_range(0, 20)
	quest.attribute_weights = _generate_random_weights()
	quest.state = JobComponent.JobState.AVAILABLE

	quest_entity.add_component("JobComponent", quest)

	return quest_entity


func assign_party_to_quest(party_entity_id: int, quest_entity_id: int) -> bool:
	var party: PartyComponent = entity_manager.get_entity_component(
		party_entity_id,
		"PartyComponent",
	)
	var quest: JobComponent = entity_manager.get_entity_component(
		quest_entity_id,
		"JobComponent",
	)

	if not party or not quest:
		push_error("Missing required components")
		return false

	if quest.state != JobComponent.JobState.AVAILABLE:
		return false

	quest.state = JobComponent.JobState.ACTIVE
	quest.assigned_party_id = party_entity_id
	party.current_quest_id = quest_entity_id

	return true


func resolve_quest(quest_entity_id: int) -> Dictionary:
	var quest: JobComponent = entity_manager.get_entity_component(
		quest_entity_id,
		"JobComponent",
	)
	if not quest or quest.state != JobComponent.JobState.ACTIVE:
		return {}

	var party: PartyComponent = entity_manager.get_entity_component(
		quest.assigned_party_id,
		"PartyComponent",
	)

	var party_stats = _calculate_party_stats(party.member_ids)

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
			"xp_per_member": quest.reward_xp / 2,
			"gold_reward": 0,
			"score": final_score,
			"required": quest.min_performance_score,
		}
		quest.state = JobComponent.JobState.FAILED

	_apply_quest_outcome(party.member_ids, outcome)

	party.current_quest_id = -1

	return outcome


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
	var stats: Array[String] = ["strength", "dexterity", "intelligence", "magic"]
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
