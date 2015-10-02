#ifndef __REV__ENGINE_H__
#define __REV__ENGINE_H__

#include "rev/system.h"

namespace rev
{
	class engine
	{
		public:
			engine( event_system *es );
			int register_component( rev::component_manager *cm );
			int register_entity( rev::entity_descriptor ed );
			int register_system( rev::system *s );

			void tick();
			void tick_to_death();

			void gc();

/******************************************************************************/

			rev::entity_handle create_entity( int type );
			void destroy_entity( rev::entity_handle h );
			bool alive( rev::entity_handle h );
			rev::component_handle *get_instance( rev::entity_handle h );

			rev::component_handle create_component( int type );
			void destroy_component( rev::component_handle h );
			void *get_instance( rev::component_handle h );


	};
}

#endif
