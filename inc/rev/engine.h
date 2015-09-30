#ifndef __ENGINE_H__
#define __ENGINE_H__

#include <vector>
#include <deque>

#include "rev/component.h"
#include "rev/entity.h"
#include "rev/system.h"
#include "rev/event.h"

namespace rev
{
	class engine
	{
public:
		engine( event_system* es );
		void tick();
		void tick_to_death();
		void gc();
		event_system *es;

/*                           -------------------                              */

		void		register_system( system s );
		entity_type register_entity( entity_descriptor ed );
		entity_type register_component( component_manager* cm );

/*                           --------------------                             */

		entity_handle	create_entity( entity_type et );
		void			destroy_entity( entity_handle eh );

		uint32_t*		get_instance( entity_handle h );
		bool			alive( entity_handle h );

		component_handle	create_component
			( component_type t, entity_handle owner );
		void				destroy_component( rev::component_handle h );
		void*				get_instance( rev::component_handle );

private:


		std::vector<component_manager*> cm;
		unsigned int mgr_bitmask;
		unsigned int mgr_shift;
		std::vector<system> sys;

		std::deque<int> free_list;
		std::vector<unsigned char> generation;
		std::vector<component_handle*> entity;
		std::vector<entity_descriptor> ent_desc;
		std::vector<int> num_components;
	};
}

#endif
