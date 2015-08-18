#ifndef __COMPONENTS_H__
#define __COMPONENTS_H__

#include "rsys.h"

enum ComponentType
{
	KeyboardInput
};

class Component
{
public:
	static Component* New( ComponentType t );
	ComponentType Type; //read-only
}; 


class DrawBucketComponent : public Component
{
public:
	virtual ~DrawBucketComponent() = 0;
	virtual DrawBucket GetDrawBucket() = 0;
};

class DrawCompositionComponent : public Component
{
public:
	virtual ~DrawCompositionComponent() = 0;
	virtual DrawBucket* GetDrawBuckets() = 0; // read only
};


class CollisionComponent : public Component
{
public:
	CollisionComponent( sf::ConvexShape s );

	sf::Vector2f GetPosition();
	sf::Vector2f GetPath();

	void SetPosition( sf::Vector2f p );
};

#endif
