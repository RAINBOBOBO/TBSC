class_name QuestSystem extends Node

var available_quests: Array[JobComponent] = []
var active_quests: Array[JobComponent] = []
var resolved_quests: Array[JobComponent] = []
var quest_counter: int = 0


func generate_quest(difficulty: int = -1) -> JobComponent:
	var quest = JobComponent.new()
	quest_counter += 1
	quest.title = "raid goblin village"
	quest.description = "kill all the goblins mercilessly"
	quest.difficulty = difficulty if difficulty != -1 else randi_range(1, 10)
	quest.min_performance_score = 40 + (quest.difficulty * 10)
	quest.reward_gold = (quest.difficulty * 100) + randi_range(0, 100)
	quest.reward_xp = (quest.difficulty * 10) + randi_range(0, 20)

	quest.attribute_to_relevance = generate_random_weights()

	available_quests.append(quest)

	return quest


func assign_party_to_quest(pary: PartyComponent, quest: JobComponent) -> bool:
	if quest.state != JobComponent.JobState.AVAILABLE:
		return false

	quest.state = JobComponent.JobState.ACTIVE
	return true

# helpers
func generate_random_weights() -> Dictionary:
	var stats: Array[String] = ["strength", "dexterity", "intelligence", "magic"]
	var weights: Dictionary = {}

	for stat_name in stats:
		var roll: int = randi_range(1, 20)
		if roll > 10 and roll <= 15:
			weights[stat_name] = JobComponent.Relevance.IMPORTANT
		elif roll > 15:
			weights[stat_name] = JobComponent.Relevance.CRITICAL
		else:
			weights[stat_name] = JobComponent.Relevance.NORMAL

	return weights
