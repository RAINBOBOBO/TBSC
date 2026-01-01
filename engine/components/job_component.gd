class_name JobComponent extends Resource

@export var title: String = ""
@export var description: String = ""
@export var difficulty: int = -1
@export var min_performance_score: int = 0
@export var reward_gold: int = 0
@export var reward_xp: int = 0

enum Relevance {
	NORMAL,
	IMPORTANT,
	CRITICAL,
}
@export var attribute_to_relevance: Dictionary = {
	"strength": Relevance.NORMAL,
	"dexterity": Relevance.NORMAL,
	"intelligence": Relevance.NORMAL,
	"magic": Relevance.NORMAL,
}

enum JobState {
	AVAILABLE,
	ACTIVE,
	COMPLETED,
	FAILED
}
@export var state: JobState = JobState.AVAILABLE
@export var assigned_party_ids: Array[int] = []
@export var party_performance_score: int = 0
@export var completion_time: int = 0

func calculate_performance_score(party_stats: Dictionary) -> int:
	var total_score: int = 0
	var relevance_to_multiplier: Dictionary = {
		Relevance.NORMAL: 1,
		Relevance.IMPORTANT: 2,
		Relevance.CRITICAL: 3,
	}

	for stat in party_stats:
		var current_relevance: Relevance = attribute_to_relevance[stat]
		var current_multiplier: int = relevance_to_multiplier[current_relevance]
		total_score += party_stats.get(stat, 0) * current_multiplier

	return total_score
