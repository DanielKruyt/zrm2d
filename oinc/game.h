#ifndef __GAME_H__
#define __GAME_H__

#include "resys.h"
#include "rsys.h"
#include "isys.h"
#include "esys.h"

class Game 
{
public:
	void Update( float dt );
	void Draw();
private:
	RenderSystem rs;
	EntitySystem es;
	ResourceSystem res;
	InputSystem is;
};

#endif 
