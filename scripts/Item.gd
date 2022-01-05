extends VBoxContainer

onready var select = $Select
onready var new_row = $HBoxNew/NewRow
onready var new_box = $HBoxNew
onready var label = $HBoxNew/Label

onready var itemliste_scroll = $ItemScroll
onready var itemliste = $ItemScroll/Itemliste

onready var timer = $HBoxNew/NewRow/CheckTimer

var my_popup
var my_column = ""
var sorted_menu_list = []
var unsorted_menu_list = []
var checked = true

func _set_item(getter):
	my_column = getter
	set_name(getter)

func _ready():
	var item_name = str(my_column)
	item_name = G._to_normal_name(item_name)
	select.set_text(item_name+" auswählen:")
	label.set_text(str(item_name)+": ")
	load_menu()
	make_adder()

func load_menu():
	var menu_list = G.db_query("select * from "+my_column)
	if menu_list.size() == 0: return
	var new_empty = preload("res://scripts/Eintrag.tscn").instance()
	var item_name = str(my_column)
	item_name = G._to_normal_name(item_name)
	new_empty._set_name(item_name+" auswählen:")
	new_empty.connect("eintrag_pressed", self, "_on_Select_item_selected", [itemliste.get_child_count()])
	itemliste.add_child(new_empty)
	for i in menu_list.size():
		unsorted_menu_list.append(menu_list[i]["name"])
	sorted_menu_list = unsorted_menu_list.duplicate()
	sorted_menu_list.sort()
	for i in unsorted_menu_list.size():
		var new_entry = preload("res://scripts/Eintrag.tscn").instance()
		new_entry._set_name(sorted_menu_list[i])
		new_entry.connect("eintrag_pressed", self, "_on_Select_item_selected", [itemliste.get_child_count()])
		itemliste.add_child(new_entry)


func _on_Select_toggled(button_pressed):
	itemliste_scroll.set_visible(button_pressed)

func _on_Select_item_selected(index):
	itemliste_scroll.set_visible(false)
	select.set_text(itemliste.get_child(index)._get_name())
	if select.get_text() == "Eigenschafts-Typ erstellen":
		new_box.set_visible(true)
	else:
		new_box.set_visible(false)
		if index > 0:
			select.add_color_override("font_color",Color(1,0.54,0.31,1))
			select.add_color_override("font_color_focus",Color(1,0.54,0.31,1))
			select.add_color_override("font_color_hover",Color(1,0.54,0.31,1))
			select.add_color_override("font_color_pressed",Color(1,0.54,0.31,1))
		else:
			select.add_color_override("font_color",Color(1,1,1,1))
			select.add_color_override("font_color_focus",Color(1,1,1,1))
			select.add_color_override("font_color_hover",Color(1,1,1,1))
			select.add_color_override("font_color_pressed",Color(1,1,1,1))

func make_adder():
	var new_entry = preload("res://scripts/Eintrag.tscn").instance()
	new_entry._set_name("Eigenschafts-Typ erstellen")
	new_entry.connect("eintrag_pressed", self, "_on_Select_item_selected", [itemliste.get_child_count()])
	itemliste.add_child(new_entry)

func _set_it(setter):
	var real_checkbox = sorted_menu_list.find(unsorted_menu_list[setter-1])
	select.set_text(itemliste.get_child(real_checkbox+1)._get_name())

func get_selected_entry():
	var indexzahl = 0
	for i in itemliste.get_child_count():
		if itemliste.get_child(i).get_text() == select.get_text():
			indexzahl = i
	if indexzahl == 0:
		return 0
	elif indexzahl == itemliste.get_child_count()-1:
		return indexzahl-1
	else:
		var real_index = unsorted_menu_list.find(sorted_menu_list[indexzahl-1])
		return real_index
	
func _on_NewRow_text_changed(_new_text):
	timer.start(2)
func _on_CheckTimer_timeout():
	var ckecking_text = new_row.get_text()
	for i in itemliste.get_child_count():
		if itemliste.get_child(i).get_text() == ckecking_text:
			new_row.set_self_modulate(ColorN("red"))
			checked = false
			return
	new_row.set_self_modulate(Color(1,1,1,1))
	checked = true

func _is_checked():
	return checked

