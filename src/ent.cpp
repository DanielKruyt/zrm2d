#include "core/ent.h"

#include <stdlib.h>

EntitySystem::EntitySystem()
{

	ent.gen.reserve( INITIAL_ENTITY_RESERVATION );
	for( int i = 0; i < INITIAL_ENTITY_RESERVATION; i++ )
	{
		ent.gen[i] = 0x00;
		ent.free.push( i );
	}

	cmgr.reserve( INITIAL_CMGR_RESERVATION );
}


Entity EntitySystem::create()
{
	Entity e;
	if( ent.free.empty() )
	{
		//alloc more space
		ent.gen.reserve( ent.gen.size() + ENTITY_RESERVE_ON_END );
		for( int i = ent.gen.size(); i < ent.gen.capacity(); i++ )
		{
			ent.gen[i] = 0x00;
			ent.free.push( i );
		}
	}
	e.id = ent.free.front();
	ent.free.pop();
	e.gen = ent.gen[e.id];

	return e;
}

void EntitySystem::notifyOnDestroy( Entity e, ComponentManager* c )
{
	if( destroyHooks.find(e) == destroyHooks.end() )
	{
		destroyHooks[e] = std::vector<ComponentManager*>();
	}
	destroyHooks[e].push_back( c );
}

void EntitySystem::destroy( Entity e )
{
	ent.gen[e.id]++;
	ent.free.push( e.id );
	auto it = destroyHooks.find( e );
	if( it != destroyHooks.end() )
	{
		ComponentManager **c = it->second.data();
		for( int i = 0; i < it->second.size(); i++ )
		{
			c[i]->entityDestroyed( e );
		}
	}
}

bool EntitySystem::alive( Entity e )
{
	return ent.gen[e.id] == e.gen;
}

