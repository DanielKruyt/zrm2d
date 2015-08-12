#include "game.h"

int main( int argc, char **argv )
{
	for( int i = 0; i < argc; i++ ) // ARE THE ARGUMENTS IN USE NOW, YCM?!?
		argv[i] = argv[i];

	sf::RenderWindow sfmlWindow( sf::VideoMode( 800, 600 ), "ZRM2D-Cpp" );
	
	RenderSystem renderSys( &sfmlWindow );
	InputSystem inputSys( &sfmlWindow );

	Game game( RenderSystem, InputSystem );
	while( game.running() )
	{
		game.Update();
		game.Draw();
	}
}
