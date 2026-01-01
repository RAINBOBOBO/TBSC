class_name CompanyComponent extends Resource

@export var money: int
@export var active_jobs: Array[int] = []
@export var completed_jobs: Array[int] = []
@export var failed_jobs: Array[int] = []
@export var staff: Array[int] = []
@export var out_on_job: Array[int] = []

enum JobOutcome {
	COMPLETED,
	FAILED,
}


func accept_job(job_id: int, assigned_staff: Array[int]) -> void:
	active_jobs.append(job_id)

	for staff_member in assigned_staff:
		if staff_member in staff:
			out_on_job.append(staff_member)


func job_over(
	job_id: int,
	assigned_staff: Array[int],
	job_outcome: JobOutcome,
	money_reward: int,
) -> void:
	if job_id in active_jobs:
		active_jobs.erase(job_id)

	match job_outcome:
		JobOutcome.COMPLETED:
			completed_jobs.append(job_id)
		JobOutcome.FAILED:
			failed_jobs.append(job_id)

	for staff_member in assigned_staff:
		if staff_member in out_on_job:
			out_on_job.erase(staff_member)

	money += money_reward
