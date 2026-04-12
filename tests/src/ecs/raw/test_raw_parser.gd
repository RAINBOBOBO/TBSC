class_name TestRawParser extends TestCase

# Helpers — each test builds its own parser so there's no shared state.
func _make_parser() -> RawParser:
	return RawParser.new(ComponentTagRegistry.new())


# --- Happy path ---

func test_single_archetype_is_parsed() -> void:
	var result := _make_parser().parse_text("""
[ARCHETYPE:GOBLIN]
[NAME:Goblin]
[STAT:strength:8]
[ARCHETYPE:END]
""")
	assert_true(result.has("GOBLIN"), "archetype key should be present")


func test_name_value_is_stored() -> void:
	var result := _make_parser().parse_text("""
[ARCHETYPE:ORC]
[NAME:Orc]
[STAT:strength:10]
[ARCHETYPE:END]
""")
	assert_eq(result["ORC"]["name"]["value"], "Orc")


func test_title_stored_as_secondary() -> void:
	var result := _make_parser().parse_text("""
[ARCHETYPE:GOBLIN_LORD]
[NAME:Goblin Lord]
[TITLE:of the Dark Caves]
[STAT:strength:8]
[ARCHETYPE:END]
""")
	assert_eq(result["GOBLIN_LORD"]["name"]["secondary"], "of the Dark Caves")


func test_stat_fixed_value() -> void:
	var result := _make_parser().parse_text("""
[ARCHETYPE:DUMMY]
[NAME:Dummy]
[STAT:strength:12]
[ARCHETYPE:END]
""")
	var stats: Array = result["DUMMY"]["stats"]
	var entry = stats.filter(func(e): return e["key"] == "strength")[0]
	assert_eq(entry["value"], 12)


func test_stat_range_stays_within_bounds() -> void:
	var result := _make_parser().parse_text("""
[ARCHETYPE:DUMMY]
[NAME:Dummy]
[STAT:strength:5:15]
[ARCHETYPE:END]
""")
	var stats: Array = result["DUMMY"]["stats"]
	var entry = stats.filter(func(e): return e["key"] == "strength")[0]
	assert_in_range(entry["value"], 5, 15)


func test_multiple_stats_all_present() -> void:
	var result := _make_parser().parse_text("""
[ARCHETYPE:DUMMY]
[NAME:Dummy]
[STAT:strength:10]
[STAT:dexterity:8]
[STAT:intelligence:6]
[ARCHETYPE:END]
""")
	var stats: Array = result["DUMMY"]["stats"]
	var keys: Array[String] = []
	for entry in stats:
		keys.append(entry["key"])
	assert_has(keys, "strength")
	assert_has(keys, "dexterity")
	assert_has(keys, "intelligence")


func test_multiple_archetypes_in_one_file() -> void:
	var result := _make_parser().parse_text("""
[ARCHETYPE:A]
[NAME:Alpha]
[STAT:strength:1]
[ARCHETYPE:END]
[ARCHETYPE:B]
[NAME:Beta]
[STAT:strength:2]
[ARCHETYPE:END]
""")
	assert_true(result.has("A"))
	assert_true(result.has("B"))


func test_comments_and_blank_lines_ignored() -> void:
	var result := _make_parser().parse_text("""
# This is a comment

[ARCHETYPE:DUMMY]
# Another comment
[NAME:Dummy]
[STAT:strength:5]
[ARCHETYPE:END]
""")
	assert_true(result.has("DUMMY"))


func test_archetype_id_stored_in_data() -> void:
	var result := _make_parser().parse_text("""
[ARCHETYPE:TROLL]
[NAME:Troll]
[STAT:strength:14]
[ARCHETYPE:END]
""")
	assert_eq(result["TROLL"]["id"], "TROLL")
