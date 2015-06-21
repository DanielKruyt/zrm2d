
require "controller"
require "items"

actor = {}

actor.survivor = {}
	actor.survivor.pos = {['x']=0,['y']=0}
	actor.survivor.rot = 0 -- radians
	actor.survivor.inventory = {
		[1] = {},
		[2] = {},
		[3] = {},
		['current_selection'] = 1
	}
	actor.survivor.controller = {}

actor.zombie = {}
	actor.zombie.pos = {['x']=0,['y']=0}
	actor.zombie.rot = 0 -- radians
	actor.zombie.attack_state = 0
	actor.zombie.controller = {}




actor.zombie = {}


