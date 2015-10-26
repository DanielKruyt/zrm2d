#ifndef __qtree_h__
#define __qtree_h__

#include "ent.h"
#include "math.h"

struct eqtree_node
{
	eqtree_node* child[4];
	int ent_cnt;
	int ent_cap;
	entity *ent;
};

class entity_quadtree
{
	public:
		entity *get_entities( float x, float y, int d, int* count );
		entity *get_entities( aabb bbox, int* count );
};

#endif
