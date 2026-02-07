class_name QuestCard extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var difficulty_label: Label = %DifficultyLabel
@onready var reward_label: Label = %RewardLabel
@onready var stat_weights_container: HBoxContainer = %StatWeightsContainer
@onready var accept_button: Button = %AcceptButton

var entity_manager: EntityManager
var quest_id: int = -1

signal accept_pressed(quest_id: int)


func _ready() -> void:
	if accept_button:
		accept_button.pressed.connect(_on_accept_button_pressed)


func setup(
	p_entity_manager: EntityManager,
	p_quest_id: int,
	show_accept_button: bool = true
) -> void:
	entity_manager = p_entity_manager
	quest_id = p_quest_id
	accept_button.visible = show_accept_button
	_update_display()


func _update_display() -> void:
	if not entity_manager or quest_id == -1:
		return

	var job: JobComponent = entity_manager.get_entity_component(
		quest_id,
		"JobComponent",
	)

	if not job:
		push_error("Quest missing JobComponent")
		return

	title_label.text = job.title
	description_label.text = job.description

	difficulty_label.text = "Difficulty: %d" % job.difficulty
	if job.difficulty <= 3:
		difficulty_label.modulate = Color.GREEN
	elif job.difficulty <= 6:
		difficulty_label.modulate = Color.YELLOW
	else:
		difficulty_label.modulate = Color.RED

	reward_label.text = "Reward: %d gold, %d XP" % [
		job.reward_gold,
		job.reward_xp,
	]

	_display_stat_weights(job.attribute_weights)


func _display_stat_weights(weights: Dictionary) -> void:
	for child in stat_weights_container.get_children():
		child.queue_free()

	var stat_names: Dictionary = {
		"strength": "STR",
		"dexterity": "DEX",
		"intelligence": "INT",
		"magic": "MAG"
	}

	for stat_name in weights:
		var weight: int = weights[stat_name]
		var short_name: String = stat_names.get(stat_name, stat_name.to_upper())

		var label: Label = Label.new()

		match weight:
			JobComponent.Relevance.CRITICAL:
				label.text = "%s★★★" % short_name
				label.modulate = Color.ORANGE_RED
			JobComponent.Relevance.IMPORTANT:
				label.text = "%s★★" % short_name
				label.modulate = Color.ORANGE
			JobComponent.Relevance.NORMAL:
				label.text = "%s★" % short_name
				label.modulate = Color.GRAY

		label.add_theme_font_size_override("font_size", 12)
		stat_weights_container.add_child(label)


func _on_accept_button_pressed() -> void:
	accept_pressed.emit(quest_id)
