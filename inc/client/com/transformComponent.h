#ifndef __transform_component_h__
#define __transform_component_h__

#include <vector>
#include <queue>
#include <unordered_map>

#include "core/ent.h"

struct TransformInstance
{
	int idx;
};

class TransformComponent : ComponentManager
{
	struct transform
	{
		Entity owner;
		float pos_x, pos_y;
		float rot;
	};
	std::vector<transform> data;
	std::unordered_map<Entity, int> lookup;
	EntitySystem* es;
	int count;
	int gcIdx;
public:

	TransformComponent( EntitySystem *e )
	{
		es = e;
		count = 0;
		gcIdx = 0;
	}

	void entityDestroyed( Entity e )
	{
		return;
	}

	void add( Entity e )
	{
		if( count >= data.size() )
			data.resize( data.size() + 16 );
		transform t;
			t.pos_x = t.pos_y = 0;
			t.rot = 0;
		lookup[e] = count;
		data[count] = t;
		count++;
	}

	TransformInstance getInstance( Entity e )
	{
		TransformInstance t;
		t.idx = -1;
		auto it = lookup.find( e );
		if( it != lookup.end() )
		{
			t.idx = it->second;
		}
		return t;
	}

	void gc()
	{
		gcIdx %= count;
		int c = 0;
		while( c <= 4 )
		{
			gcIdx %= count;
			c++;
			if( !es->alive( data[gcIdx].owner ) )
			{
				c = 0;
				count--;
				if( gcIdx != count )
				{
					data[gcIdx] = data[count];
					gcIdx++;
				} else {
					gcIdx = 0;
				}
			}
		}
	}

	Entity getOwner( TransformInstance inst )
	{
		return data[inst.idx].owner;
	}
	
	void setOwner( TransformInstance inst, Entity owner )
	{
		data[inst.idx].owner = owner;
	}

	float getPosX( TransformInstance inst )
	{
		return data[inst.idx].pos_x;
	}
	float getPosY( TransformInstance inst )
	{
		return data[inst.idx].pos_y;
	}

	void setPosX( TransformInstance inst, float x )
	{
		data[inst.idx].pos_x = x;
	}

	void setPosY( TransformInstance inst, float y )
	{
		data[inst.idx].pos_y = y;
	}

	float getRot( TransformInstance inst )
	{
		return data[inst.idx].rot;
	}
	void setRot( TransformInstance inst, float rot )
	{
		data[inst.idx].rot = rot;
	}
};

#endif
