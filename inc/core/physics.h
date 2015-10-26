#ifndef __physics_h__
#define __physics_h__

#include "core/collision.h"

struct PhysicsObject
{
	triangle_mesh shape;
	float cr; // containing radius

	float mass;
	float moi; //moment of inertia around (0,0) in local coords (centre of mass)
};

struct PhyObjInst
{
	int id; // idx into physics object

	vec2f pos;
	vec2f vel;
	vec2f acc;
	float rpos;
	float rvel;
	float racc;
};

class PhysicsSystem
{
	public:
		
};

#endif
