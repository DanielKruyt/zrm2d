#ifndef __COMPONENT_H__
#define __COMPONENT_H__

#include <stdint.h>

namespace rev
{
	struct component_handle
	{
		uint32_t id;
	};

	typedef unsigned int component_type;

	struct entity_handle;

	class engine;

	class component_manager
	{
public:
		engine* eng;
		virtual	component_handle	create( entity_handle h ) = 0;
		virtual void*				get( component_handle h ) = 0;
		virtual void				destroy( component_handle h ) = 0;
		virtual void				gc() = 0;
	};
}

#endif
