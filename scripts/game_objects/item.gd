extends Resource

class_name Item

export(GDScript) var item_script

export(ItemDatabase.ItemType) var item_type

export(String) var name
export(String) var description
export(bool) var usable = false
export(bool) var perish_on_use = true
export(int) var price
export(int) var sell_price
