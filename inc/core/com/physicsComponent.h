#ifndef __physics_component_h__
#define __physics_component_h__

#include "core/ent.h"
#include "core/physics.h"
#include "core/collision.h"

struct PhysicsObject
{
	triangle_mesh shape;
	float cr; // containing radius
	aabb cb; // containing box
};

struct PhysicsInstance
{
	int id;
};

class PhysicsComponentManager : ComponentManager
{
	public:
		PhysicsComponentManager( EntitySystem *es );

		void add( Entity e );
		void entityDestroyed( Entity e );

		void tick( float dt );

		PhysicsInstance getInstance( Entity e );

		vec2f getPos( Entity e );
		void setPos( Entity e, vec2f pos );
		void 
	private:
		struct objectInst
		{
			int phyObjId;
			vec2f pos;
			vec2f vel;
			vec2f acc;
		};
		std::vector<objectInst> obj;
		std::unordered_map<Entity,int> lookup;
};

#endif
