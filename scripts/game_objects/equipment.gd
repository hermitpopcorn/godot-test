extends Item

class_name Equipment

export(ItemDatabase.EquipmentType) var equipment_type setget set_equipment_type

export(int) var maxhp = 0
export(int) var maxap = 0
export(int) var atk = 0
export(int) var def = 0
export(int) var hit = 0
export(int) var eva = 0
export(int) var spd = 0

export(PackedScene) var animation_scene
export(String) var animation_name

func set_equipment_type(new_equipment_type):
	item_type = ItemDatabase.ItemType.EQUIPMENT
	equipment_type = new_equipment_type
