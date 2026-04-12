class_name TestCase extends RefCounted

# Base class for all test suites.
# Extend this and write methods named test_*

@warning_ignore("unused_private_class_variable")
var _runner: Node = null          # set by TestRunner
var _assertion_failed := false
var _failure_message := ""
var _skipped := false
var _skip_reason := ""


# Override in subclasses for setup/teardown per test
func setUp() -> void:
	pass

func tearDown() -> void:
	pass


func _reset() -> void:
	_assertion_failed = false
	_failure_message = ""
	_skipped = false
	_skip_reason = ""


# --- Assertions ---

func assert_eq(a, b, msg: String = "") -> void:
	if _assertion_failed:
		return
	if a != b:
		_fail("assert_eq failed: expected %s == %s%s" % [str(a), str(b), _msg(msg)])


func assert_ne(a, b, msg: String = "") -> void:
	if _assertion_failed:
		return
	if a == b:
		_fail("assert_ne failed: expected %s != %s%s" % [str(a), str(b), _msg(msg)])


func assert_true(condition: bool, msg: String = "") -> void:
	if _assertion_failed:
		return
	if not condition:
		_fail("assert_true failed%s" % _msg(msg))


func assert_false(condition: bool, msg: String = "") -> void:
	if _assertion_failed:
		return
	if condition:
		_fail("assert_false failed%s" % _msg(msg))


func assert_gt(a, b, msg: String = "") -> void:
	if _assertion_failed:
		return
	if not (a > b):
		_fail("assert_gt failed: expected %s > %s%s" % [str(a), str(b), _msg(msg)])


func assert_ge(a, b, msg: String = "") -> void:
	if _assertion_failed:
		return
	if not (a >= b):
		_fail("assert_ge failed: expected %s >= %s%s" % [str(a), str(b), _msg(msg)])


func assert_lt(a, b, msg: String = "") -> void:
	if _assertion_failed:
		return
	if not (a < b):
		_fail("assert_lt failed: expected %s < %s%s" % [str(a), str(b), _msg(msg)])


func assert_le(a, b, msg: String = "") -> void:
	if _assertion_failed:
		return
	if not (a <= b):
		_fail("assert_le failed: expected %s <= %s%s" % [str(a), str(b), _msg(msg)])


func assert_has(collection, key, msg: String = "") -> void:
	if _assertion_failed:
		return
	var found := false
	if collection is Dictionary:
		found = collection.has(key)
	elif collection is Array:
		found = collection.has(key)
	if not found:
		_fail("assert_has failed: %s not in collection%s" % [str(key), _msg(msg)])


func assert_not_null(value, msg: String = "") -> void:
	if _assertion_failed:
		return
	if value == null:
		_fail("assert_not_null failed%s" % _msg(msg))


func assert_null(value, msg: String = "") -> void:
	if _assertion_failed:
		return
	if value != null:
		_fail("assert_null failed: got %s%s" % [str(value), _msg(msg)])


func assert_in_range(value: int, lo: int, hi: int, msg: String = "") -> void:
	if _assertion_failed:
		return
	if value < lo or value > hi:
		_fail("assert_in_range failed: %d not in [%d, %d]%s" % [value, lo, hi, _msg(msg)])


func skip(reason: String = "") -> void:
	_skipped = true
	_skip_reason = reason


# --- Internal ---

func _fail(message: String) -> void:
	_assertion_failed = true
	_failure_message = message


func _msg(extra: String) -> String:
	return "" if extra.is_empty() else " (%s)" % extra
