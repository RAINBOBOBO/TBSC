class_name CareerComponent extends Resource

@export var current_role: String = "unemployed"
@export var employer_id: int = -1
@export var hire_date: int = 0
@export var salary: int = 0
@export var contract_duration_days: int = 0
@export var previous_roles: Array[String] = []
@export var achievements: Array[String] = []

func is_employed() -> bool:
	return employer_id != -1 and current_role != "unemployed"

func hire(new_role: String, new_employer: int):
	if current_role != "unemployed":
		previous_roles.append(current_role)
	current_role = new_role
	employer_id = new_employer
	#salary = new_salary
	#contract_duration = duration
	#hire_date = Global.game_time  # You'll need a game time system
