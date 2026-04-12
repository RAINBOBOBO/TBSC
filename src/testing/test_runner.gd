class_name TestRunner extends Node

# Lightweight test runner — no plugins required.
#
# Usage:
#   1. Attach this script to a Node in a test scene (e.g. res://tests/test_scene.tscn)
#   2. Drop any file named test_*.gd into res://tests/ — it's discovered automatically
#   3. Run the scene — results print to the Output panel
#
# Writing tests:
#   - Each test file must extend TestCase
#   - Every method starting with "test_" is auto-run
#   - Use assert_eq, assert_true, assert_false, assert_has, etc.
#   - Call skip("reason") inside a test to mark it [SKIP] without deleting it
#
# Exit codes (when running headless via CLI):
#   0 = all passed, 1 = failures or errors

const TEST_DIR := "res://tests/"

var _passed := 0
var _failed := 0
var _skipped := 0
var _errors := 0


func _ready() -> void:
	run_all()


func _discover_test_scripts() -> Array[String]:
	var scripts: Array[String] = []
	_scan_dir(TEST_DIR, scripts)
	scripts.sort()
	return scripts


func _scan_dir(path: String, scripts: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("TestRunner: could not open directory: %s" % path)
		_errors += 1
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		var full_path := path + file_name
		if dir.current_is_dir():
			_scan_dir(full_path + "/", scripts)
		elif file_name.begins_with("test_") and file_name.ends_with(".gd"):
			scripts.append(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()


func run_all() -> void:
	print("\n========================================")
	print("  TEST RUNNER")
	print("========================================\n")

	for script_path in _discover_test_scripts():
		_run_script(script_path)

	print("\n========================================")
	var total := _passed + _failed + _errors
	print("  RESULTS: %d/%d passed" % [_passed, total])
	if _skipped > 0:
		print("  SKIPPED: %d" % _skipped)
	if _failed > 0:
		print("  FAILED:  %d" % _failed)
	if _errors > 0:
		print("  ERRORS:  %d" % _errors)
	print("========================================\n")

	if _failed > 0 or _errors > 0:
		get_tree().quit(1)
	else:
		print("All tests passed!")
		get_tree().quit(0)


func _run_script(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("TestRunner: script not found: %s" % path)
		_errors += 1
		return

	var script: GDScript = load(path)
	if script == null:
		push_error("TestRunner: failed to load script: %s" % path)
		_errors += 1
		return

	var instance = script.new()
	if not instance is TestCase:
		push_error("TestRunner: %s does not extend TestCase" % path)
		_errors += 1
		return

	instance._runner = self

	var methods: Array = []
	for method in instance.get_method_list():
		if method["name"].begins_with("test_"):
			methods.append(method["name"])
	methods.sort()

	if methods.is_empty():
		return

	var suite_name := path.get_file().get_basename()
	print("── %s  (%d tests)" % [suite_name, methods.size()])  # (3) suite count

	for method in methods:
		instance._reset()
		instance.setUp()

		# (1) If setUp itself failed an assertion, skip the test body
		if instance._assertion_failed:
			print("  [FAIL] %s\n         setUp failed: %s" % [method, instance._failure_message])
			_failed += 1
			instance.tearDown()
			continue

		instance.call(method)

		instance.tearDown()

		# (4) skip() support
		if instance._skipped:
			print("  [SKIP] %s  (%s)" % [method, instance._skip_reason])
			_skipped += 1
		elif instance._assertion_failed:
			print("  [FAIL] %s\n         %s" % [method, instance._failure_message])
			_failed += 1
		else:
			print("  [PASS] %s" % method)
			_passed += 1

	print("")
