## Mr Manager is the game manager with a silly little reference to a cult classic (we don't talk about the Netflix
## seasons)
extends Node

## The Level List is exactly what you think it is. Each time the game tries to load a level, it uses this Array
## to find it. This means that, as far as the game is concerned, the only levels that exist in the game are in
## this Array.
@export var level_list: Array[PackedScene]

