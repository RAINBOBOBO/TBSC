class_name Character extends Thing


func _setup_composition() -> void:
	add_component(CharacterAttributes.new())
	add_component(Health.new())
	add_component(Inventory.new())
	add_component(CharacterUpkeep.new())
	add_component(Party.new())
	add_component(Guild.new())
	add_component(Relationships.new())
	add_component(Abilities.new())
	add_component(Location.new())
	add_component(Fitness.new())
	add_component(Fatigue.new())
	add_component(CareerMotivation.new())
	add_component(JobSatisfaction.new())
	add_component(JobExpectations.new())
	add_component(Mood.new())
