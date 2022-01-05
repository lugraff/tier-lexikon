extends VBoxContainer

onready var name_edit = $HBoxName/Name
onready var text_cont = $TextBoxContainer
onready var text_menu = $HBoxText/ButtonAuswahlTextBox
onready var button_text_box = $HBoxText/ButtonAuswahlTextBox
onready var button_add_text = $HBoxText/ButtonAddTextBox

func _on_ButtonEinfName_pressed():
	name_edit.set_text(OS.get_clipboard())

func _on_ButtonAuswahlTextBox_item_selected(index):
	for i in text_cont.get_child_count():
		text_cont.get_child(i).set_visible(false)
	text_cont.get_child(index).set_visible(true)

func _on_ButtonAddTextBox_pressed():
	if text_cont.get_child_count() <= 9:
		for i in text_cont.get_child_count():
			text_cont.get_child(i).set_visible(false)
		var new_textbox = preload("res://scripts/TextBox.tscn").instance()
		text_cont.add_child(new_textbox)
		text_menu.add_item("Textbox "+ str(new_textbox.get_index()+1))
		button_text_box._select_int(new_textbox.get_index())
	else:
		button_add_text.set_disabled(true)

