#ifndef __ESYS_H__
#define __ESYS_H__

#include <stdint.h>

#include "rsys.h"
#include "components.h"
#include "entities.h"



class EntitySystem
{
public:
	EntityHandle	NewEntity( Entity *e ); // e will now be owned by this class
	void			DeleteEntity( EntityHandle h );
	void			Update( float dt );
private:
};

#endif
