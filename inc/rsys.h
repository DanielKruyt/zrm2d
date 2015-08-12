#ifndef __RSYS_H__
#define __RSYS_H__

#include <string>
#include <SFML/Graphics.hpp>

struct DrawBucket
{
	sf::Drawable &drawable;
	sf::Transform transform;
	float height;
};


class RenderSystem
{
public:
	RenderSystem( sf::RenderWindow *w );
	void Clear();
	void Draw();

	sf::View Camera;

	void SubmitBucket( DrawBucket b );
private:
	std::vector<DrawBucket> bucketList;
	sf::RenderWindow *sfmlWindow;
};

#endif
