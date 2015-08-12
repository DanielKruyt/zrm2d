#ifndef __ENTITIES_H__
#define __ENTITIES_H__

#include <stdint.h>

#include "components.h"



typedef int EntityType;



class Entity
{
public:
	EntityType			Type; //read-only
	virtual Component*	GetComponent( ComponentType id, int instance );
	virtual Component*	GetComponent( ComponentType id );
	virtual int			HasComponent( ComponentType id ); // returns number of comp
};



struct EntityHandle
{
	uint64_t id  : 32;
	uint64_t gen : 32;
};

#endif 
