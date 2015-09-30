#ifndef __ISYS_H__
#define __ISYS_H__

#include <SFML/Window.hpp>

class InputSystem
{
public:
	InputSystem( sf::Window *w );
	bool IsKeyDown( sf::Keyboard::Key k );
	bool IsMouseDown( sf::Mouse::Button b );
private:
	sf::Window *sfmlWindow;
};

#endif