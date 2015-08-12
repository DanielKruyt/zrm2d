#ifndef __ISYS_H__
#define __ISYS_H__

#include <SFML/Window.hpp>

class InputSystem
{
public:
	InputSystem( sf::Window *w );
private:
	sf::Window *sfmlWindow;
};

#endif
