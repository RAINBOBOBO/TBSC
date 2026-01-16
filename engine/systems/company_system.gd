class_name CompanySystem extends Node

@export var entity_manager: EntityManager


func complete_job(
		company_id: int,
		quest_id: int,
		party_ids: Array[int],
		success: bool,
		reward: int,
	) -> void:
	var company: CompanyComponent = entity_manager.get_entity_component(
		company_id,
		"CompanyComponent",
	)
	if not company:
		return

	company.active_jobs.erase(quest_id)

	if success:
		company.completed_jobs.append(quest_id)
		company.money += reward
	else:
		company.failed_jobs.append(quest_id)

	for staff_id in party_ids:
		company.out_on_job.erase(staff_id)


func get_available_for_job(company_entity_id: int) -> Array[int]:
	var company: CompanyComponent = entity_manager.get_entity_component(
		company_entity_id,
		"CompanyComponent",
	)
	if not company:
		return []

	var available: Array[int] = []
	for staff_id in company.staff:
		if staff_id not in company.out_on_job:
			available.append(staff_id)

	return available


func hire_staff_member(company_entity_id: int, staff_member_id: int) -> bool:
	var company: CompanyComponent = entity_manager.get_entity_component(
		company_entity_id,
		"CompanyComponent"
	)
	if not company:
		return false

	if company.staff.size() >= 10:
		return false

	if staff_member_id in company.staff:
		return false

	company.staff.append(staff_member_id)
	return true


func fire_staff_member(company_entity_id: int, staff_member_id: int) -> bool:
	var company: CompanyComponent = entity_manager.get_entity_component(
		company_entity_id,
		"CompanyComponent"
	)
	if not company:
		return false

	if staff_member_id not in company.staff:
		return false

	company.staff.erase(staff_member_id)
	return true
