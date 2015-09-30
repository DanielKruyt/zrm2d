#ifndef __ENTITY_H__
#define __ENTITY_H__

#include <vector>
#include <stdint.h>

#include "rev/component.h"

namespace rev
{
	struct entity_handle
	{
		uint64_t id  : 56;
		uint64_t gen : 8;
	};



	struct entity_descriptor
	{
		component_type components[64]; // NULL-terminated
	};



	typedef unsigned int entity_type;
}

#endif
