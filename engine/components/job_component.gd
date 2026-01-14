class_name JobComponent extends Resource

@export var title: String = ""
@export var description: String = ""
@export var difficulty: int = -1
@export var min_performance_score: int = 0
@export var reward_gold: int = 0
@export var reward_xp: int = 0

enum Relevance {
	NORMAL = 1,
	IMPORTANT = 2,
	CRITICAL = 3,
}
@export var attribute_weights: Dictionary = {
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
@export var assigned_party_id: int = -1
@export var completion_time: int = 0
