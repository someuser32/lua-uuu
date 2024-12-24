import re
import os
from typing import Any

import luaparser.ast


vscode_path = ".vscode-oss"
extension_id = "ILKA.umbrella-vscode"


def get_extension_path_by_id(vscode_path: str, extension_id: str) -> str | None:
	extensions_path = os.path.join(os.getenv("USERPROFILE"), vscode_path, "extensions")
	for entry in os.scandir(extensions_path):
		if entry.is_dir() and entry.name.startswith(extension_id.lower()):
			return os.path.join(extensions_path, entry.name)
	return None


extension_path = get_extension_path_by_id(vscode_path, extension_id)
assert extension_path is not None, f"Extension {extension_id} not found in {vscode_path}"


declarations_path = os.path.join(extension_path, "plugin", "library", "natives", "umbrella")

classes = {}
enums = {}
interfaces = {"_G": {"name": "_G", "functions": []}}

def parse_function_args(args: str) -> dict[str, Any] | None:
	match = re.search(r"(.+)\((.+\)):(.+)", args)
	if not match:
		return None

	info = match.groups()

	args = {}

	args["name"] = info[0] if info[0] else ""
	args["args"] = {}
	args["returns"] = {"type": info[2]} if info[2] else None

	for arg in info[1].split(", "):
		arg_info = arg.split(": ")
		if len(arg_info) > 1:
			print(arg_info)
			args["args"][": ".join(arg_info[:-1])] = {"type": arg_info[-1]}
		elif len(arg_info) == 1:
			if "other" in args["args"]:
				print("multiple other args", args)
			args["args"]["other"] = {"type": arg_info[0]}

	return args

def parse_comments(comments: luaparser.ast.Comments) -> dict[str, Any] | None:
	if comments is None:
		return None

	info = {}

	for comment in comments:
		if not comment.s.startswith("---@"):
			if "description" not in info:
				info["description"] = ""
			info["description"] += comment.s[3:] + "\n"
		elif comment.s.startswith("---@class"):
			info["class"] = comment.s[10:]
		elif comment.s.startswith("---@enum"):
			info["enum"] = comment.s[9:]
		elif comment.s.startswith("---@return"):
			return_info = comment.s[11:].split(" ")
			return_type, return_description = return_info[0], " ".join(return_info[1:]) if len(return_info) > 1 else ""
			info["returns"] = {"type": return_type, "description": return_description}
		elif comment.s.startswith("---@field"):
			if "fields" not in info:
				info["fields"] = {}
			field_info = comment.s[10:].split(" ")
			field_name, field_type, field_description = field_info[0], field_info[1], " ".join(field_info[2:]) if len(field_info) > 2 else ""
			info["fields"][field_name] = {"type": field_type, "description": field_description}
		elif comment.s.startswith("---@operator"):
			if "operators" not in info:
				info["operators"] = {}
			operator_info = parse_function_args(comment.s[13:])
			info["operators"][operator_info["name"]] = {"args": operator_info["args"], "returns": operator_info["returns"]}
		elif comment.s.startswith("---@param"):
			if "params" not in info:
				info["params"] = {}
			param_info = re.search(r"(\w+)\??\s+([\w<>:.,\[\]\s]+?)(?:\s*@default:\s+(.*?))?\s+(.*)", comment.s[10:])
			if param_info is None:
				continue
			param_info = param_info.groups()
			param_name, param_type, param_default, param_description = param_info[0], param_info[1], param_info[2] if len(param_info) > 2 else None, param_info[3] if len(param_info) > 3 else ""
			info["params"][param_name] = {"type": param_type, "default": param_default, "description": param_description}
		elif comment.s == "---@deprecated":
			info["deprecated"] = True
		elif comment.s.startswith("---@overload"):
			continue
		else:
			print("unknown comment", comment.s)

	if "description" in info:
		info["description"] = info["description"][:-1]
	return info

def parse_lua(lua: str):
	for node in luaparser.ast.walk(luaparser.ast.parse(lua)):
		node: luaparser.ast.Node

		if node.display_name in {"Chunk"}:
			continue

		if node.display_name in {"Assign", "LocalAssign"}:
			for name, value in zip(node.targets, node.values):
				if value.display_name == "Table":
					comments_info = parse_comments(node.comments) or {}
					description = comments_info.get("description")
					if "class" in comments_info:
						classes[name.id] = {"name": comments_info["class"], "description": description, "methods": []}
					elif "enum" in comments_info:
						parent = name.value.id if hasattr(name, "idx") else "_G"
						name = name.idx.id if hasattr(name, "idx") else name.id
						if parent == "_G":
							enums[name] = {"name": comments_info["enum"], "description": description, "values": []}
						else:
							if parent not in enums:
								enums[parent] = {}
							enums[parent][name] = {"name": comments_info["enum"], "values": []}
					else:
						interfaces[name.id] = {"name": name.id, "description": description, "functions": []}
					if "enum" not in comments_info and len(value.fields) > 0:
						print("assigning NON EMPTY TABLE", name)
				else:
					print("assigning NON TABLE", name.display_name)

		if node.display_name == "Function":
			interface = node.name.value.id if hasattr(node.name, "value") else "_G"
			name = node.name.idx.id if hasattr(node.name, "idx") else node.name.id
			args = [arg.id for arg in node.args]
			comments_info = parse_comments(node.comments) or {}
			description = comments_info.get("description")
			arg_values = comments_info.get("params")
			returns = comments_info.get("returns")

			info = {
				"name": name,
				"args": args,
				"returns": returns,
			}

			if description is not None:
				info["description"] = description

			if "deprecated" in comments_info:
				info["deprecated"] = True

			if arg_values is not None:
				info["arg_values"] = arg_values

			interfaces[interface]["functions"].append(info)

		if node.display_name == "Method":
			name = node.name.id
			comments_info = parse_comments(node.comments) or {}
			description = comments_info.get("description")
			args = [arg.id for arg in node.args]
			arg_values = comments_info.get("params")
			returns = comments_info.get("returns")

			info = {
				"name": name,
				"args": args,
				"returns": returns,
			}

			if description is not None:
				info["description"] = description

			if "deprecated" in comments_info:
				info["deprecated"] = True

			if arg_values is not None:
				info["arg_values"] = arg_values

			classes[node.source.id]["methods"].append(info)

		# print(node.display_name, node.first_token, [comment.s for comment in node.comments])


for root, _, files in os.walk(declarations_path):
	for file in files:
		if file.endswith(".lua"):
			with open(os.path.join(root, file), "r") as f:
				content = f.read()
			try:
				parse_lua(content)
			except Exception as e:
				print(file)
				raise e


def dump_interface(prefix: str, interface_name: str, interface: dict, depth: int=0) -> str:
	indent = "\t" * depth
	pre_indent = "\t" * (depth - 1)
	content = prefix

	if "description" in interface:
		content = pre_indent + f"/**\n * {interface["description"].replace("\n", f"\n{pre_indent}* ")}\n */\n{content}"

	for function in interface.get("functions", interface.get("methods", [])):
		description = function.get("description", "")

		args = {}
		desc = ""
		if "arg_values" in function:
			for arg, arg_value in function["arg_values"].items():
				desc += pre_indent + f"@param {arg}"
				if arg_value["default"] is not None:
					desc += f" @default {arg_value["default"]}"
				desc += f" {arg_value["description"]}\n"
				args[arg] = arg_value["type"]

		desc += pre_indent + f"@returns {function["returns"]["type"]}{" " + function["returns"]["description"] if "description" in function["returns"] else ""}"
		description = f"{desc}{description}"

		if "deprecated" in function and function["deprecated"]:
			if len(description) > 0:
				description += "\n"

			description += pre_indent + "@deprecated"

		if len(description) > 0:
			content += f"\n{indent}/**\n{indent} * {description.replace("\n", f"\n{indent} * ")}\n{indent} */"

		arguments = []
		for arg in function["args"]:
			arg_type = args.get(arg)
			if arg_type is None:
				arg_type = "any"
			arguments.append(f"{arg}: {arg_type}")

		if depth == 0:
			content += pre_indent + f"""\n{indent}declare function {function["name"]}({', '.join(arguments)}): {function["returns"]["type"]};\n"""
			continue

		content += pre_indent + f"""\n{indent}{function["name"]}({', '.join(arguments)}): {function["returns"]["type"]};"""

	return content


interfaces_file = []

for interface_name, interface in interfaces.items():
	if interface_name == "_G":
		content = dump_interface("", interface_name, interface)
		interfaces_file.append(content+"\n")
		continue

	content = dump_interface(f"""declare interface {interface["name"]} """ + "{", interface_name, interface, 1) + "\n}"

	interfaces_file.append(content+"\n")


for interface_name, interface in interfaces.items():
	if interface_name == "_G":
		continue

	content = f"""declare var {interface_name}: {interface["name"]};"""

	interfaces_file.append(content+"\n")


with open("interfaces.d.ts", "w") as f:
	f.write("\n".join(interfaces_file))

classes_file = []

for class_name, class_info in classes.items():
	content = dump_interface(f"""declare interface {class_info["name"]} """ + "{", class_name, class_info, 1) + "\n}"

	classes_file.append(content+"\n")

with open("classes.d.ts", "w") as f:
	f.write("\n".join(classes_file))


classes_file = []
