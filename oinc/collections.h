#ifndef __COLLECTION_H__
#define __COLLECTION_H__

#include <vector>

#include "entities.h"

class Collection
{
public:
	virtual ~Collection() = 0;

	std::vector<EntityHandle> entities;
	virtual void AddEntity( EntityHandle e ); // on condition, of course
};

class Sponge
{
public:
	virtual ~Sponge() = 0;
	virtual void Soak() = 0;
};

#endif
