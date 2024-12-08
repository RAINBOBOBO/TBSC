class_name Character extends Thing

var attributes: CharacterAttributes
var health: Health
var inventory: Inventory
var upkeep: CharacterUpkeep
var party: Party
var guild: Guild
var relationships: Relationships
var abilities: Abilities
var location: Location
var fitness: Fitness
var fatigue: Fatigue
var career_motivation: CareerMotivation
var job_satisfaction: JobSatisfaction
var job_expectations: JobExpectations
var mood: Mood


func setup_components() -> void:
	print(get_property_list())
	print(get_components())
	return
