extends RefCounted

const BIOME_TITLES := {
	&"forest": "Floresta Corrompida",
	&"castle": "Castelo Fraturado",
	&"cave": "Cavernas dos Ecos",
}
const BIOME_LORE := {
	&"forest": "Raízes antigas cercam os primeiros rasgos da realidade.",
	&"castle": "As muralhas quebradas ainda guardam ecos de uma ordem perdida.",
	&"cave": "Abaixo da pedra, os portais convergem para o núcleo da fratura.",
}

static func title(biome: StringName) -> String:
	return BIOME_TITLES.get(biome, "Unknown Rift")

static func intro(biome: StringName) -> String:
	return BIOME_LORE.get(biome, "")
