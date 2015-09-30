#include "isys.h"

InputSystem::InputSystem( sf::Window *w )
{
	sfmlWindow = w;
}

bool InputSystem::IsKeyDown( sf::Keyboard::Key k )
{
	return sf::Keyboard::isKeyPressed( k );
}

bool InputSystem::IsMouseDown( sf::Mouse::Button b )
{
	return sf::Mouse::isButtonPressed( b );
}
