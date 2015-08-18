#ifndef __ESYS_H__
#define __ESYS_H__

#include <stdint.h>

#include "rsys.h"
#include "evsys.h"

#include "components.h"
#include "entities.h"
#include "collections.h"

class EntitySystem
{
public:
	EntitySystem( EventSystem *es );

	EntityHandle	NewEntity( Entity *e ); // e will now be owned by this class
	void			DeleteEntity( EntityHandle h );
	Entity*			GetEntity( EntityHandle h );
	void			Update( float dt );
private:
	EventSystem*	eventSys;
	//TODO: Implement the specifics of the EntitySystem:
	//      * Componenets
	//      * Entites
	//      * Collections, Sponges and mutators
};

#endif
