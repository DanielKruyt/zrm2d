#include "ent.h"

#include <stdlib.h>

entity_system::entity_system()
{

	ent.gen.reserve( INITIAL_ENTITY_RESERVATION );
	for( int i = 0; i < INITIAL_ENTITY_RESERVATION; i++ )
	{
		ent.gen[i] = 0x00;
		ent.free.push( i );
	}

	cmgr.reserve( INITIAL_CMGR_RESERVATION );

	for( int i = 0; i < INITIAL_CMGR_RESERVATION; i++ )
		destroy_hooks.cnt_occd[i] = destroy_hooks.cnt_ownd[i] = 0;
}


component entity_system::add_cmgr( component_manager* c )
{
	if( cmgr.size() >= cmgr.capacity() )
	{
		cmgr.reserve( cmgr.size() + CMGR_RESERVE_ON_END );
	}
	cmgr.push_back( c );

	return cmgr.size()-1;
}

entity entity_system::create_entity()
{
	entity e;
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
	e.gen = ent.gen[e.id];

	return e;
}

entity entity_system::create_entity( entity_template& t )
{
	entity e = create_entity();

	for( int i = 0; i < t.num_components; i++ )
	{
		add_component( e, t.components[i] );
	}

	return e;
}

void entity_system::add_component( entity e, component c )
{
	cmgr[c]->add( e );
}

void entity_system::destroy_notify( entity e, component_manager* c )
{
	if( destroy_hooks.find(e) == destroy_hooks.end() )
	{
		destroy_hooks[e] = std::vector<component>();
	}
	destroy_hooks[e].push_back( c );
}

void entity_system::destroy( entity e )
{
	ent.gen[e.id]++;
	ent.free.push( e.id );
	auto it = destroy_hooks.find( e );
	if( it != destroy_hooks.end() )
	{
		component_manager **c = it->data();
		for( int i = 0; i < it->size(); i++ )
		{
			c[i]->entity_destroyed( e );
		}
	}
}

bool entity_system::alive( entity e )
{
	return ent.gen[e.id] == e.gen;
}

