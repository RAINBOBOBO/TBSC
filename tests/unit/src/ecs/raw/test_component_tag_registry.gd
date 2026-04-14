class_name TestComponentTagRegistry extends TestCase

# --- STAT handler ---

func test_stat_handler_fixed_value() -> void:
	var reg := ComponentTagRegistry.new()
	var handler: Callable = reg.get_schema("STAT")["handler"]
	var args: Array[String] = ["strength", "12"]
	var result = handler.call(args)
	assert_eq(result["key"], "strength")
	assert_eq(result["value"], 12)
	assert_true(result["value"] is int)


func test_stat_handler_range() -> void:
	var reg := ComponentTagRegistry.new()
	var handler: Callable = reg.get_schema("STAT")["handler"]
	for _i in range(20):
		var args: Array[String] = ["strength", "5", "15"]
		var result = handler.call(args)
		assert_eq(result["key"], "strength")
		assert_in_range(result["value"], 5, 15)


func test_stat_handler_random() -> void:
	var reg := ComponentTagRegistry.new()
	var handler: Callable = reg.get_schema("STAT")["handler"]
	for _i in range(20):
		var args: Array[String] = ["magic", "RANDOM"]
		var result = handler.call(args)
		assert_eq(result["key"], "magic")
		assert_in_range(result["value"], 1, 20)


# --- get_builders_for ---

func test_get_builders_for_name_only() -> void:
	var reg := ComponentTagRegistry.new()
	var builders := reg.get_builders_for({ "name": { "value": "Orc" } })
	assert_eq(builders.size(), 1)
	assert_eq(builders[0]["key"], "name")
	assert_eq(builders[0]["class"], NameComponent)


func test_get_builders_for_stats_only() -> void:
	var reg := ComponentTagRegistry.new()
	var blueprint := {
		"stats": [{ "key": "strength", "value": 10 }]
	}
	var builders := reg.get_builders_for(blueprint)
	assert_eq(builders.size(), 1)
	assert_eq(builders[0]["key"], "stats")
	assert_eq(builders[0]["class"], StatsComponent)


func test_get_builders_for_both_components() -> void:
	var reg := ComponentTagRegistry.new()
	var blueprint := {
		"name": { "value": "Human" },
		"stats": [{ "key": "strength", "value": 10 }]
	}
	var builders := reg.get_builders_for(blueprint)
	assert_eq(builders.size(), 2)


func test_get_builders_for_empty_blueprint() -> void:
	var reg := ComponentTagRegistry.new()
	assert_eq(reg.get_builders_for({}).size(), 0)
