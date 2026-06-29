#the level node manages the level mechanics, respawn points, which level you are on
extends Node2D

#the system node is responcible for controling broad game mechanics, like saving, knowing what to load in etc
var system: Node = get_parent()
