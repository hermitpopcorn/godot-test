static func dia1():
	return [
		1.0,
		['>sprite|show|bg', {
			'src': 'res://images/bg/izumito.png',
			'position': Vector2(0, 0),
		} ],
		0.5,
		['>show_message_box'],
		['>audio|sfx|bike', {
			'src': "res://audio/voice/bike_00.wav",
		} ],
		1.0,
		['>sprite|show|yoshiko', {
			'src': 'res://images/dialog_sprite/yoshiko_n2.png',
			'position': Vector2(-265, 790),
			'duration': 0.1,
			'z_index': 2,
		} ],
		['>sprite|move|yoshiko', {
			'position': Vector2(1201, 790),
			'duration': 0.5,
		} ],
		['>sprite|move|yoshiko|nowait', {
			'position': Vector2(1250, 790),
			'duration': 10,
		} ],
		['>audio|voice|yoshiko_00.wav'],
		"Yoshiko|Yo.",
		['>sprite|change|yoshiko', {
			'src': 'res://images/dialog_sprite/yoshiko_a2.png',
		} ],
		['>audio|voice|yoshiko_01.wav'],
		"Yoshiko|Let's get this party goin', YOROSHIKU!!",
		['>sprite|dim|yoshiko'],
		['>sprite|show|dia', {
			'src': 'res://images/dialog_sprite/dia_a2.png',
			'position': Vector2(2211, 790),
			'duration': 0.1,
			'z_index': 1,
		} ],
		['>sprite|move|dia', {
			'position': Vector2(510, 790),
			'duration': 0.5,
		} ],
		['>sprite|move|dia|nowait', {
			'position': Vector2(480, 790),
			'duration': 10,
		} ],
		['>audio|voice|dia_00.wav'],
		"Dia|YOROSHIKU.",
		['>sprite|light|yoshiko|nowait'],
		['>sprite|dim|dia'],
		['>sprite|clear|yoshiko'],
		['>sprite|clear|dia'],
		['>container|move|sprites|nowait', {
			'scale': Vector2(1.1, 1.1),
			'rotation': 5,
			'position': Vector2(-50, 50),
			'duration': 0.5,
		} ],
		['>container|move|background|nowait', {
			'scale': Vector2(1.3, 1.3),
			'rotation': 10,
			'duration': 0.5,
		} ],
		['>sprite|move|yoshiko', {
			'scale': Vector2(1.2, 1.2),
			'duration': 0.5,
		} ],
		['>container|move|background|nowait', {
			'position': Vector2(30, 0),
			'duration': 10,
		} ],
		['>sprite|move|yoshiko|nowait', {
			'position': Vector2(1280, 790),
			'duration': 10,
		} ],
		['>audio|voice|yoshiko_02.wav'],
		"Yoshiko|Wuzzat? Your decoration game WEAK. You dare callin' this christmas decor, huh?!",
		['>container|clear|background'],
		['>sprite|clear|yoshiko'],
		['>sprite|dim|yoshiko|nowait'],
		['>sprite|light|dia|nowait'],
		['>container|move|sprites|nowait', {
			'scale': Vector2(1.1, 1.1),
			'rotation': -5,
			'position': Vector2(50, 50),
			'duration': 0.5,
		} ],
		['>container|move|background|nowait', {
			'scale': Vector2(1.3, 1.3),
			'rotation': -10,
			'duration': 0.5,
		} ],
		['>sprite|move|yoshiko|nowait', {
			'scale': Vector2(1.0, 1.0),
			'duration': 0.5,
		} ],
		['>sprite|move|dia', {
			'scale': Vector2(1.2, 1.2),
			'position': Vector2(480, 900),
			'duration': 0.5,
		} ],
		0.5,
		['>container|move|background|nowait', {
			'position': Vector2(-30, 0),
			'duration': 10,
		} ],
		['>sprite|move|dia|nowait', {
			'position': Vector2(510, 900),
			'duration': 10,
		} ],
		['>audio|voice|dia_01.wav'],
		"Dia|What, you got a problem with one of my creations?!",
		['>container|clear|background'],
		['>sprite|clear|yoshiko'],
		['>sprite|clear|dia'],
		['>sprite|light|yoshiko|nowait'],
		['>sprite|dim|dia'],
		['>container|move|sprites|nowait', {
			'scale': Vector2(1.1, 1.1),
			'rotation': 5,
			'position': Vector2(-50, 50),
			'duration': 0.5,
		} ],
		['>container|move|background|nowait', {
			'scale': Vector2(1.3, 1.3),
			'rotation': 10,
			'duration': 0.5,
		} ],
		['>sprite|move|yoshiko', {
			'scale': Vector2(1.2, 1.2),
			'duration': 0.5,
		} ],
		['>container|move|background|nowait', {
			'position': Vector2(0, 0),
			'duration': 10,
		} ],
		['>sprite|move|dia|nowait', {
			'position': Vector2(550, 900),
			'duration': 10,
		} ],
		['>sprite|move|yoshiko|nowait', {
			'position': Vector2(1200, 790),
			'duration': 10,
		} ],
		['>audio|voice|yoshiko_03.wav'],
		"Yoshiko|I got problems with ALL your creations!",
		['>container|clear|background'],
		['>container|clear|sprites'],
		['>container|move|background|nowait', {
			'position': Vector2(0, 50),
			'scale': Vector2(1.4, 1.4),
			'duration': 0.5,
		} ],
		['>container|move|sprites|nowait', {
			'position': Vector2(-100, 415),
			'scale': Vector2(1.3, 1.3),
			'duration': 0.5,
		} ],
		['>sprite|move|yoshiko|nowait', {
			'scale': Vector2(1.4, 1.4),
			'duration': 0.5,
		} ],
		['>audio|voice|yoshiko_04.wav'],
		"Yoshiko|Don't be disrespectin' Christmas, skank!",
		['>sprite|hide|bg'],
		['>sprite|hide|yoshiko|nowait', {
			'duration': 0.5,
		} ],
		['>sprite|hide|dia|nowait', {
			'duration': 0.5,
		} ],
		['>hide_message_box'],
		1.0,
		['>container|reset|background'],
		['>container|reset|sprites'],
	]

static func yoshiko1():
	return [
		{ 'command': 'show_message_box' },
		"Test2",
		{ 'command': 'sprite', 'options': {
			'action': 'show',
			'key': 'yoshiko',
			'src': 'res://images/dialog_sprite/yoshiko_a2.png',
			'position': Vector2(800, 790),
			'duration': 0.5,
			'z_index': 2,
		} },
		"Yoshiko|It's YOHANE!",
		{ 'command': 'sprite', 'options': {
			'action': 'hide',
			'key': 'yoshiko',
			'duration': 0.5,
		} },
		{ 'command': 'hide_message_box' },
	]

static func door1():
	return [
		['>show_message_box'],
		"There's still something I need to do here.",
		['>hide_message_box'],
	]

static func notice1():
	return [
		['>show_message_box'],
		"There's a written notice stuck on the whiteboard.",
		['>pause_sequence'],
		"Yoshiko|Tell all your friends to watch my streams.",
		"What a waste of space...",
		['>pause_sequence'],
		['>hide_message_box'],
	]

static func photos1():
	return [
		['>show_message_box'],
		"There are posters of Aqours and µ's on the wall.",
		"Some of the members also stuck some of their own photos there.",
		"...I remember this one. It's from when Aqours participated in the bicycle decorating thingy on Christmas last year.",
		['>hide_message_box'],
	]

static func mirror1():
	return [
		['>show_message_box'],
		"{s0.01}WHOA{w1.0} WHO IS THAT HIDEOUS->>",
		0.5,
		"Oh, wait.{w1.0} It's [color=aqua]my own face[/color].",
		"On the table sits a small mirror. ",
		"_You can adjust the angle of it. ",
		"_Which reminds me,{w0.5} you can move the [color=aqua]view camera[/color] by using the [b]WASD keys.{w1.0} {s0.2}Try it.[/b]",
		['>hide_message_box'],
	]
