extends VBoxContainer

onready var items = $Scroll/Items
onready var new_item = $NewItem

func _ready():
	if G.my_status == "ADMIN" or G.my_status == "ROOT":
		new_item.set_visible(true)
	for i in G.SW_entries.size():
		if i != 0:
			if G.SW_entries[i][0] != "item_Lizenz":
				if G.SW_entries[i][0].begins_with("item_mul_Region"):
					var new_item_mul = preload("res://scripts/ItemMultiRegion.tscn").instance()
					new_item_mul._set_item(G.SW_entries[i][0])
					items.add_child(new_item_mul)
				elif G.SW_entries[i][0].begins_with("item_mul_"):
					var new_item_mul = preload("res://scripts/ItemMulti.tscn").instance()
					new_item_mul._set_item(G.SW_entries[i][0])
					items.add_child(new_item_mul)
				elif G.SW_entries[i][0].begins_with("item_zahl_"):
					var new_item_zahl = preload("res://scripts/ItemZahl.tscn").instance()
					new_item_zahl._set_item(G.SW_entries[i][0])
					items.add_child(new_item_zahl)
				elif G.SW_entries[i][0].begins_with("item_"):
					var new_item_text = preload("res://scripts/Item.tscn").instance()
					new_item_text._set_item(G.SW_entries[i][0])
					items.add_child(new_item_text)
				
	var text_besonderes = preload("res://scripts/Besonderes.tscn").instance()
	items.add_child(text_besonderes)
"""
	for i in G.SW_entries.size():
		if i != 0:
			if G.SW_entries[i][0] != "item_Lizenz":
				if G.SW_entries[i][0].begins_with("item_"):
					if not G.SW_entries[i][0].begins_with("item_zahl_") and not G.SW_entries[i][0].begins_with("item_mul_"):
						var new_item_text = preload("res://scripts/Item.tscn").instance()
						new_item_text._set_item(G.SW_entries[i][0])
						items.add_child(new_item_text)
	for i in G.SW_entries.size():
		if i != 0:
			if G.SW_entries[i][0] != "item_Lizenz":
				if G.SW_entries[i][0].begins_with("item_mul_"):
					var new_item_mul = preload("res://scripts/ItemMulti.tscn").instance()
					new_item_mul._set_item(G.SW_entries[i][0])
					items.add_child(new_item_mul)
	for i in G.SW_entries.size():
		if i != 0:
			if G.SW_entries[i][0] != "item_Lizenz":
				if G.SW_entries[i][0].begins_with("item_zahl_"):
						var new_item_zahl = preload("res://scripts/ItemZahl.tscn").instance()
						new_item_zahl._set_item(G.SW_entries[i][0])
						items.add_child(new_item_zahl)
"""
