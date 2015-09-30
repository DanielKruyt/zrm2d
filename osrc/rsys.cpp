#include <rsys.h>

RenderSystem::RenderSystem( sf::RenderWindow *w )
{
	sfmlWindow = w;
	w->setView( Camera );
}

void RenderSystem::Draw()
{
	sfmlWindow->clear( sf::Color::Black );
	sfmlWindow->setView( Camera );
	
	// draw buckets
	for( int i = 0; i < bucketList.size(); i++ )
	{
		sfmlWindow->draw( bucketList[i].drawable, bucketList[i].transform );
	}

	sfmlWindow->display();
}

void RenderSystem::SubmitBucket( DrawBucket b )
{
	bucketList.push_back( b );
}


