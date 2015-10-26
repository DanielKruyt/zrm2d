#ifndef __render_component_h__
#define __render_component_h__

#include "core/ent.h"
#include "client/gfx.h"

#include "client/com/transformComponent.h"

struct RenderableInstance
{
	int idx;
};

class RenderComponent : ComponentManager
{
	struct renderable {
		Entity owner;
		Texture tex;
		VertexSet vert;
		Color color;
		float h;
	};
	int comp_count;
	std::vector<renderable> data;
	std::unordered_map<Entity, int> lookup;
	EntitySystem* es;
	GfxSystem *gs;
	TransformComponent *transformCmgr;
public:
	RenderComponent( EntitySystem* e, GfxSystem *g, TransformComponent *tcm )
	{
		es = e;
		gs = g;
		transformCmgr = tcm;
		comp_count = 0;
	}
	void entityDestroyed( Entity e )
	{
		return;
	}
	void add( Entity e )
	{
		if( comp_count >= data.size() )
		{
			data.resize( data.size() + 16 );
		}
		lookup[e] = comp_count;
		renderable r;
			r.owner = e;
			r.h = 0;
			r.color.r = r.color.g = r.color.b = 1.f;
			r.vert = 0;
			r.tex = 0;

		data[comp_count] = r;
		comp_count++;
	}

	void render_frame()
	{
		for( int i = 0; i < comp_count; i++ )
		{
			renderable r = data[i];
			if( es->alive( r.owner ) )
			{
				TransformInstance t = transformCmgr->getInstance( r.owner );

				DrawBucket b;
					b.tex = r.tex;
					b.vert = r.vert;
					b.rot = transformCmgr->getRot( t );
					b.pos.x = transformCmgr->getPosX( t );
					b.pos.y = transformCmgr->getPosY( t );
					b.color.r = r.color.r; b.color.g = r.color.g; b.color.b = r.color.b;
					b.h = r.h;

				gs->submitBucket( b );
			}
		}
		gs->drawFrame();
	}
	void gc()
	{
		//TODO: rationalise this
		for( int i = 0; i < comp_count; i++ )
		{
			renderable *r = &(data[i]);
			if( ! es->alive( r->owner ) )
			{
				if( i != comp_count-1 )
				{
					data[i] = data[comp_count-1];
					lookup[ data[i].owner ] = i;
				}
				comp_count--;
			}
		}
	}

	RenderableInstance getInstance( Entity e )
	{
		RenderableInstance r;
		r.idx = -1;
		auto it = lookup.find( e );
		if( it != lookup.end() )
			r.idx = it->second;
		return r;
	}

	Entity getOwner( RenderableInstance inst )
	{
		return data[inst.idx].owner;
	}

	void setOwner( RenderableInstance inst, Entity owner )
	{
		data[inst.idx].owner = owner;
	}

	Texture getTexture( RenderableInstance inst )
	{
		return data[inst.idx].tex;
	}

	void setTexture( RenderableInstance inst, Texture t )
	{
		data[inst.idx].tex = t;
	}

	VertexSet getVertexSet( RenderableInstance inst )
	{
		return data[inst.idx].vert;
	}

	void setVertexSet( RenderableInstance inst, VertexSet vs )
	{
		data[inst.idx].vert = vs;
	}

	Color getColor( RenderableInstance inst )
	{
		return data[inst.idx].color;
	}

	void setColor( RenderableInstance inst, Color c )
	{
		data[inst.idx].color = c;
	}

	float getHeight( RenderableInstance inst )
	{
		return data[inst.idx].h;
	}

	void setHeight( RenderableInstance inst, float h )
	{
		data[inst.idx].h = h;
	}
};

#endif
