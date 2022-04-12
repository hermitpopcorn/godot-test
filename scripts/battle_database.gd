extends Node

enum UnitStates {
	KNOCKOUT,
}

enum Actions {
	ATTACK,
	SKILL,
	DEFEND,
	CHANGE_EQUIPMENT,
	USE_ITEM,
	RUN,
}

enum MultiActionType {
	SPREAD,
	CONSECUTIVE,
}

enum BuffsDebuffs {
	ATK,
	DEF,
	HIT,
	EVA,
}

enum TargetingType {
	NONE,
	SINGLE,
	TEAM,
}
