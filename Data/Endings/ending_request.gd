extends Resource
class_name EndingRequest

enum Faction { KING, PEASANTS }
enum Outcome { VICTORY, DEFEAT }

@export_range(0, 100) var level: int = 0
@export var side: Faction = Faction.KING
@export var outcome: Outcome = Outcome.VICTORY
