extends VBoxContainer

onready var label = $HBoxHeader/Label
onready var select = $HBoxHeader/Select
onready var new_entry_button = $HBoxNew/NewEntry
onready var new_entry_text = $HBoxNew/NewEntryText
onready var new_box = $HBoxNew
onready var itemliste_scroll = $ItemScroll
onready var itemliste = $ItemScroll/Itemliste

var my_column = ""
var sorted_menu_list = []
var unsorted_menu_list = []

func _set_item(getter):
	my_column = getter
	set_name(getter)

func _ready():
	var item_name = str(my_column)
	item_name = G._to_normal_name(item_name)
	label.set_text(item_name+":")
	load_menu()
	if G.my_status == "CREATOR":
		new_box.set_visible(false)

func load_menu():
	var menu_list = G.db_query("select * from "+my_column)
	if menu_list.size() == 0: return
	for i in menu_list.size():
		unsorted_menu_list.append(menu_list[i]["name"])
	sorted_menu_list = unsorted_menu_list.duplicate()
	sorted_menu_list.sort()
	for i in menu_list.size():
		var new_entry = preload("res://scripts/EintragCheck.tscn").instance()
		new_entry._set_name(sorted_menu_list[i])
		new_entry._set_idX(menu_list[i]["id"])
		itemliste.add_child(new_entry)

func _on_Select_toggled(button_pressed):
	itemliste_scroll.set_visible(button_pressed)
	if not button_pressed:
		var test = _select_getter()
		var items_selected = false
		for i in test.size():
			if test[i] == true:
				items_selected = true
				break
		if items_selected:
			select.add_color_override("font_color",Color(1,0.54,0.31,1))
			select.add_color_override("font_color_focus",Color(1,0.54,0.31,1))
			select.add_color_override("font_color_hover",Color(1,0.54,0.31,1))
			select.add_color_override("font_color_pressed",Color(1,0.54,0.31,1))
		else:
			select.add_color_override("font_color",Color(1,1,1,1))
			select.add_color_override("font_color_focus",Color(1,1,1,1))
			select.add_color_override("font_color_hover",Color(1,1,1,1))
			select.add_color_override("font_color_pressed",Color(1,1,1,1))

func _set_it(setter):
	if setter is Dictionary:
		if setter.size() == 0: return
	if setter is String:
		if setter == "Null": return
	setter = str2var(setter.to_lower())
	for i in setter.size():
		var real_checkbox = sorted_menu_list.find(unsorted_menu_list[i])
		itemliste.get_child(real_checkbox)._set_checked(setter[i])

func _select_getter():
	var selectet_items = {}
	for i in itemliste.get_child_count():
		if i > unsorted_menu_list.size()-1:
			if itemliste.get_child(itemliste.get_child(i)._get_idX())._get_checked():
				selectet_items[i] = true
			else:
				selectet_items[i] = false
		else:
			var test = unsorted_menu_list.find(sorted_menu_list[i])
			if itemliste.get_child(i)._get_checked():
				selectet_items[test] = true
			else:
				selectet_items[test] = false
	return selectet_items

func _all_item_getter():
	var all_items = {}
	if unsorted_menu_list.size() == 0:
		for i in itemliste.get_child_count():
			all_items[i] = itemliste.get_child(i)._get_name()
	else:
		for i in itemliste.get_child_count():
			if i > unsorted_menu_list.size()-1:
				all_items[i] = itemliste.get_child(i)._get_name()
			else:
				all_items[i] = unsorted_menu_list[i]
	return all_items
		
func _on_NewEntry_pressed():
	var new_entry = new_entry_text.get_text()
	var error = 0
	if new_entry == "":
		error = 1
	for i in itemliste.get_child_count():
		if itemliste.get_child(i)._get_name() == new_entry:
			error = 2
	if error > 0:
		new_entry_text.set_self_modulate(ColorN("Red"))
		return
	var new_multi_entry = preload("res://scripts/EintragCheck.tscn").instance()
	new_multi_entry._set_name(new_entry)
	new_multi_entry._set_idX(itemliste.get_child_count())
	itemliste.add_child(new_multi_entry)
	new_entry_text.set_text("")
