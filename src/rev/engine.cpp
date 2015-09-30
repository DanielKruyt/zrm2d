#include "rev/engine.h"

#include <cmath>
#include <stdlib.h>


rev::engine::engine( event_system *evsys )
{
	es = evsys;

	cm = std::vector<component_manager*>();
	cm.reserve( 64 );
	mgr_shift = (32-6);
	mgr_bitmask = 63;

	sys = std::vector<system>();

	free_list = std::deque<int>();
	for( int i = 0; i < 4096; i++ )
		free_list.push_back( i );

	generation = std::vector<unsigned char>();
	generation.reserve( 4096 );
	entity = std::vector<component_handle*>();
	entity.reserve( 4096 );
}

void rev::engine::tick()
{
	for( int i = 0; i < sys.size(); i++ )
		sys[i]( this );
	gc();
}

void rev::engine::tick_to_death()
{
	while( not es->get_flag( FLAG_DEATH ) )
	{
		for( int i = 0; i < sys.size(); i++ )
			sys[i]( this );
		gc();
	}
}

void rev::engine::gc()
{
	for( int i = 0; i < cm.size(); i++ )
		cm[i]->gc();
}

/*                           -------------------                              */


void rev::engine::register_system( rev::system s )
{
	sys.push_back( s );
}

rev::entity_type rev::engine::register_entity( rev::entity_descriptor ed )
{
	ent_desc.push_back( ed );
	return( ent_desc.size() - 1 );
}

rev::component_type rev::engine::register_component( rev::component_manager *mgr )
{
	cm.push_back( mgr );
	int tmp = (int)std::ceil( std::log( cm.size() )/std::log(2) );
	mgr_shift = 32 - tmp;
	mgr_bitmask = (int)std::pow( 2, tmp ) - 1;

	return( cm.size() - 1 );
}

/*                           --------------------                             */

rev::entity_handle rev::engine::create_entity( rev::entity_type et )
{
	rev::entity_handle h;
	h.id = free_list.front();
	free_list.pop_front();
	h.gen = generation[h.id];
	// TODO:  better allocations on creating entities and components
	uint32_t *ret = new uint32_t[ num_components[et]+ 1];
	entity.push_back( (component_handle*) ret );

	for( int i = 1; i < num_components[et]+1; i++ )
	{
		component_handle ch = create_component( ent_desc[et].components[i], h );
		ret[i] = ch.id;
	}

	return h;
}

void rev::engine::destroy_entity( rev::entity_handle h )
{
	free_list.push_back( h.id );
	generation[h.id]++;
	// TODO: callbacks on entity destructions to delete components
	// TODO: CONTD: and stop manually destroying all components each time
	// TODO: CONTD2: b/c inefficient and making gc() redundant/useless
	rev::entity_type t = *( (int*) entity[h.id] );
	for( int i = 0; i < num_components[t]; i++ )
		cm[ ent_desc[t].components[i] ]->destroy( entity[h.id][i] );
}


uint32_t* rev::engine::get_instance( rev::entity_handle h )
{
	return( (h.gen==generation[h.id]) ? (uint32_t*)entity[h.id] : NULL );
}

bool rev::engine::alive( rev::entity_handle h )
{
	return generation[h.id] == h.gen;
}

/*                           -------------------                              */

rev::component_handle rev::engine::create_component(
	rev::component_type t, rev::entity_handle owner )
{
	return cm[t]->create( owner );
}

void rev::engine::destroy_component( rev::component_handle h )
{
	cm[ (h.id >> mgr_shift) & mgr_bitmask ]->destroy( h );
}

//template<typename component_instance>
void* rev::engine::get_instance( rev::component_handle h )
{
	return cm[ (h.id >> mgr_shift) & mgr_bitmask ]->get( h );
}

