extends CheckBox

signal eintrag_pressed

var my_name = "Eintrag"
var my_id

func _set_name(name_text):
	my_name = name_text
	set_name(name_text)

func _ready():
	set_text(my_name)

func _on_Eintrag_pressed():
	emit_signal("eintrag_pressed")

func _get_name():
	return my_name
	
func _get_id():
	return get_index()

func _get_checked():
	return is_pressed()

func _set_checked(pr):
	set_pressed(pr)

func _set_idX(idx):
	my_id = idx
	
func _get_idX():
	return my_id
