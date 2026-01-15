class_name StaffManagementSystem extends Node

@export var entity_manager: EntityManager


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
