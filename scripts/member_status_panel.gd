extends Panel

func _ready():
	$VBoxContainer/HBoxContainer/HPContainer/CenterContainer/HPText.text = String(100)
	$VBoxContainer/HBoxContainer/HPContainer/HPBar/Damage.value = 100
	$VBoxContainer/HBoxContainer/HPContainer/HPBar.value = 100

func damage(amount: int):
	$VBoxContainer/HBoxContainer/HPContainer/HPBar.value -= amount
	$VBoxContainer/HBoxContainer/HPContainer/CenterContainer/HPText.text = String($VBoxContainer/HBoxContainer/HPContainer/HPBar.value)
	$DamageTween.stop_all()
	$DamageTween.interpolate_property(
		$VBoxContainer/HBoxContainer/HPContainer/HPBar/Damage,
		"value",
		$VBoxContainer/HBoxContainer/HPContainer/HPBar/Damage.value,
		$VBoxContainer/HBoxContainer/HPContainer/HPBar.value,
		0.25,
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN,
		0.5
	)
	$DamageTween.start()
