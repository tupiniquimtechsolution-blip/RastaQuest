extends Node

const SAVE_PATH := "user://save.dat"

var coins := 0
var upgrades := {}

func save():
	var data = {
		"coins": coins,
		"upgrades": upgrades
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(data)

func load():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = file.get_var()
	coins = data["coins"]
	upgrades = data["upgrades"]
