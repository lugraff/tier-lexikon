extends HBoxContainer

onready var display_name = $Name
onready var wert_line = $Wert

var my_column = ""
var checked = true

func _set_item(getter):
	my_column = getter
	set_name(getter)

func _ready():
	var item_name = str(my_column)
	item_name = G._to_normal_name(item_name)
	display_name.set_text(item_name+": ")

func _on_Wert_text_changed(new_text):
	if new_text.is_valid_integer() or new_text.is_valid_float() or new_text == "":
		wert_line.set_self_modulate(Color(1,1,1,1))
		checked = true
	else:
		wert_line.set_self_modulate(ColorN("Red"))
		checked = false

func _set_it(setter):
	wert_line.set_text(str(setter))

func _is_checked():
	return checked
