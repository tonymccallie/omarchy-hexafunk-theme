#!/usr/bin/env python3
"""Remap Omarchy's generated VS Code theme to hexafunk syntax roles.

Usage: vscode_remap.py <generated vscode-theme.json> <output path>

Omarchy's template maps functions to blue, variables to cyan, numbers to
orange. hexafunk wants keywords pink, functions teal, strings green, types
yellow, variables blue, numbers/booleans/built-ins purple, operators orange.
Rules are matched on each tokenColors entry's FIRST scope.
"""
import json
import sys

P = dict(pink="#ff79bc", teal="#00f0d0", green="#afb87a", yellow="#fbc956",
         blue="#3eafcc", purple="#c297ed", orange="#fa984c", red="#ff7370",
         gray="#8e927c", fg1="#eee8df", fg3="#bcb4a9")

M = {
    "comment": "gray", "variable": "blue", "variable.parameter": "blue",
    "variable.other.property": "blue", "variable.other.constant": "purple",
    "variable.other.enummember": "purple", "invalid": "red", "invalid.deprecated": "yellow",
    "keyword": "pink", "storage.modifier": "pink", "keyword.control": "pink",
    "keyword.control.import": "pink", "keyword.operator": "orange",
    "punctuation.accessor": "orange", "storage.type": "yellow",
    "storage.type.primitive": "yellow", "entity.name.type.class": "yellow",
    "entity.name.type.interface": "yellow", "entity.name.type.enum": "yellow",
    "entity.name.type.parameter": "yellow", "entity.name.namespace": "blue",
    "entity.name.function": "teal", "support.function": "teal",
    "entity.name.function.method": "teal", "entity.name.function.decorator": "teal",
    "punctuation": "fg3", "constant.numeric": "purple", "constant.language.boolean": "purple",
    "constant.language": "purple", "constant.character": "green",
    "constant.character.escape": "purple", "string": "green",
    "punctuation.definition.template-expression": "orange", "string.regexp": "orange",
    "support.type.property-name": "blue", "entity.name.tag": "pink",
    "entity.other.attribute-name": "blue", "support.type.property-name.css": "blue",
    "support.constant.property-value.css": "fg1",
    "entity.other.attribute-name.class.css": "yellow",
    "entity.other.attribute-name.pseudo-class.css": "teal", "keyword.other.unit.css": "purple",
    "markup.heading": "pink", "markup.bold": "fg1", "markup.italic": "fg1",
    "markup.underline.link": "blue", "markup.inline.raw": "green", "markup.quote": "gray",
    "punctuation.definition.list.begin.markdown": "orange", "markup.inserted": "teal",
    "markup.deleted": "red", "markup.changed": "yellow", "variable.language.this": "purple",
    "meta.object-literal.key": "blue", "entity.name.type.lifetime.rust": "yellow",
    "entity.name.function.macro.rust": "teal", "variable.other.normal.shell": "blue",
    "entity.name.command.shell": "teal", "support.function.builtin.shell": "purple",
    "entity.name.tag.yaml": "blue", "keyword.key.toml": "blue",
    "entity.other.attribute-name.table.toml": "yellow",
    "entity.name.section.group-title.ini": "yellow", "keyword.other.definition.ini": "blue",
    "entity.name.function.target.makefile": "teal", "variable.other.makefile": "blue",
    "entity.name.package.go": "blue",
    "variable.parameter.function.language.special.self.python": "purple",
    "support.function.magic.python": "purple", "variable.other.php": "blue",
    "meta.preprocessor.c": "pink", "meta.attribute.csharp": "teal",
    "keyword.other.DML.sql": "pink", "support.type.graphql": "yellow", "variable.graphql": "blue",
}

SEMANTIC = {
    "parameter": "blue", "variable": "blue", "property": "blue", "namespace": "blue",
    "function": "teal", "method": "teal", "macro": "teal", "decorator": "teal",
    "class": "yellow", "interface": "yellow", "enum": "yellow", "type": "yellow",
    "typeParameter": "yellow", "struct": "yellow", "enumMember": "purple",
    "number": "purple", "boolean": "purple", "keyword": "pink", "modifier": "pink",
    "operator": "orange", "string": "green", "regexp": "orange", "comment": "gray",
}


def main(src, dst):
    t = json.load(open(src))
    unmapped = []
    for tc in t.get("tokenColors", []):
        sc = tc.get("scope", [])
        sc = [sc] if isinstance(sc, str) else sc
        first = sc[0] if sc else ""
        settings = tc.setdefault("settings", {})
        if first.startswith("source.json"):
            last = first.split()[-1]
            if "property-name" in last:
                settings["foreground"] = P["blue"]
            elif last.startswith("string"):
                settings["foreground"] = P["green"]
            elif "constant" in last:
                settings["foreground"] = P["purple"]
        elif first in M:
            settings["foreground"] = P[M[first]]
        elif "foreground" in settings:
            unmapped.append(first)

    stc = t.get("semanticTokenColors", {})
    for key in list(stc):
        base, *mods = key.split(".")
        role = SEMANTIC.get(base)
        if base in ("variable", "function", "method") and (
                "defaultLibrary" in mods or "readonly" in mods):
            role = "purple"
        if role:
            if isinstance(stc[key], dict):
                stc[key]["foreground"] = P[role]
            else:
                stc[key] = P[role]

    t["name"] = "hexafunk"
    t.setdefault("colors", {}).update({
        "gitDecoration.addedResourceForeground": P["teal"],
        "gitDecoration.modifiedResourceForeground": P["yellow"],
        "gitDecoration.untrackedResourceForeground": P["orange"],
        "gitDecoration.deletedResourceForeground": P["red"],
        "editorGutter.addedBackground": P["teal"],
        "editorGutter.modifiedBackground": P["yellow"],
        "editorGutter.deletedBackground": P["red"],
        "editor.selectionBackground": "#c41a6e",
        "editor.selectionForeground": "#f5f1ea",
        "editor.lineHighlightBackground": "#36382e",
    })
    with open(dst, "w") as f:
        json.dump(t, f, indent=2)
        f.write("\n")
    if unmapped:
        print("unmapped scopes (left as generated):", ", ".join(unmapped), file=sys.stderr)


if __name__ == "__main__":
    main(*sys.argv[1:3])
