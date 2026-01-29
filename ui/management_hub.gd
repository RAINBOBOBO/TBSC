class_name ManagementHub extends Control

@onready var generate_quest_button: Button = %GenerateQuestButton
@onready var quest_list: VBoxContainer = %QuestList
@onready var company_gold_label: Label = %CompanyGoldLabel
@onready var active_quest_panel: PanelContainer = %ActiveQuestPanel
@onready var active_quest_label: Label = %ActiveQuestLabel
@onready var resolve_quest_button: Button = %ResolveQuestButton
@onready var roster_list: VBoxContainer = %RosterList

const ADVENTURER_CARD_SCENE = preload(
	"res://ui/ui_components/adventurer_card.tscn"
)
