extends Node

enum ItemType {
	ITEM,
	EQUIPMENT,
	LOOT, # drops from enemies, mainly for selling and unlocking new equipments at the store
	KEY_ITEM, # cannot be discarded
	ARTEFACT, # items that impact the game systems and can be toggled on and off
}

enum EquipmentType {
	ACCESSORY, ARMOR,
	DUAL_SWORDS,
	LASER_GUN,
	BAYONET,
	COMICALLY_LARGE_SPOON
}
