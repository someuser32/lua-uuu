import os
import winreg
from contextlib import suppress as except_error

import vdf
import vpk


def get_steam_path() -> str | None:
	with except_error(FileNotFoundError, OSError):
		key = winreg.OpenKeyEx(key=winreg.HKEY_CURRENT_USER, sub_key="SOFTWARE\\Valve\\Steam\\")
		steam_path = winreg.QueryValueEx(key, "SteamPath")[0]
		if os.path.exists(steam_path):
			return steam_path

def get_app_path(id: int) -> str | None:
	steam = get_steam_path()
	if steam is None:
		return None
	libraryfolders_vdf = os.path.join(steam, "config", "libraryfolders.vdf")
	if not os.path.isfile(libraryfolders_vdf):
		return None
	with open(libraryfolders_vdf, "r", encoding="utf-8") as f:
		libraryfolders = vdf.loads(f.read())
	for _, catalogue in libraryfolders["libraryfolders"].items():
		if str(id) in catalogue["apps"]:
			path = os.path.normpath(catalogue["path"])
			if os.path.exists(path):
				return path
	return None

def get_dota_path() -> str:
	app_path = get_app_path(570)
	if app_path is not None:
		dota_path = os.path.join(app_path, "steamapps", "common", "dota 2 beta")
		if os.path.exists(dota_path):
			return dota_path
	print("Unable to detect Dota 2 path! Set path to \"dota 2 beta\" folder without quotes manually.\nExample: \"C:\\Games\\Steam\\steamapps\\common\\dota 2 beta\"")
	dota_path = input(">>> ")
	dota2exe = os.path.join(dota_path, "game", "bin", "win64", "dota2.exe")
	while not os.path.exists(dota_path) and not os.path.isfile(dota2exe):
		print("Unable to find Dota 2")
		dota_path = input(">>> ")
		dota2exe = os.path.join(dota_path, "game", "bin", "win64", "dota2.exe")
	return dota_path

def locale_abilities():
	dota_path = get_dota_path()
	pak01_dir = vpk.open(os.path.join(dota_path, "game", "dota", "pak01_dir.vpk"))
	ability_names = set()
	for file, _ in pak01_dir.items():
		if file.startswith("scripts/npc/heroes/") or file == "scripts/npc/npc_abilities.txt" or file == "scripts/npc/items.txt":
			data = vdf.loads(pak01_dir[file].read().decode("utf-8"))["DOTAAbilities"].keys()
			ability_names.update(data)
	tokens = {k.lower():v for k,v in vdf.loads(pak01_dir["resource/localization/abilities_english.txt"].read().decode("utf-8"))["lang"]["Tokens"].items()}
	localization = {}
	for ability_name in ability_names:
		token_name = f"dota_tooltip_ability_{ability_name}"
		if token := tokens.get(token_name, None):
			localization[ability_name] = token
	print("{", end="")
	for index, (token, locale) in enumerate(localization.items()):
		print(f"[\"{token}\"]=\"{locale}\"", end="" if index == len(localization)-1 else ",")
	print("}", end="")

def ability_owners():
	dota_path = get_dota_path()
	pak01_dir = vpk.open(os.path.join(dota_path, "game", "dota", "pak01_dir.vpk"))
	npc_heroes = vdf.loads(pak01_dir["scripts/npc/npc_heroes.txt"].read().decode("utf-8"))["DOTAHeroes"]
	npc_units = vdf.loads(pak01_dir["scripts/npc/npc_units.txt"].read().decode("utf-8"))["DOTAUnits"]
	owners = {}
	for owner, data in (npc_heroes | npc_units).items():
		if owner == "Version" or not isinstance(data, dict):
			continue
		for i in range(1, int(data.get("AbilityTalentStart", "10" if owner.startswith("npc_dota_hero") else "36"))):
			if ability := data.get(f"Ability{i}"):
				if ability == "generic_hidden":
					continue
				if owner not in owners:
					owners[owner] = set()
				owners[owner].add(ability)
	print("{", end="")
	for index, (owner, abilities) in enumerate(owners.items()):
		t = "{"
		for aindex, ability in enumerate(abilities):
			t += f"\"{ability}\""
			if aindex != len(abilities)-1:
				t += ","
		t += "}"
		print(f"[\"{owner}\"]={t}", end="" if index == len(owners)-1 else ",")
	print("}", end="")

if __name__ == "__main__":
	ability_owners()