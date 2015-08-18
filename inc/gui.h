#ifndef __GUI_H__
#define __GUI_H__



#include <SFML/System.hpp>
#include <SFML/Graphics.hpp>

#include "rsys.h"
#include "esys.h"

#include "gui/events.h"



namespace Gui
{
	enum class ElementType
	{
		NullElement, Container, Window, Button, TextBox, ScrollContainer
	};
	class Element
	{
	public:
		ElementType Type;
		virtual Element* OnClick( int rmx, int rmy ) = 0; //relative mouse pos
		virtual Element* OnRelease( int rmx, int rmy ) = 0;
		virtual Element* OnHover( int rmx, int rmy ) = 0;

		sf::Vector2i GetPos();
		sf::Vector2i GetDimensions();
		void SetPos( sf::Vector2i p );
		void SetDimensions( sf::Vector2i d );

		void PushEvent( Event e );
		std::vector<Event>* CollectEvents();
	protected:
		sf::Vector2i pos;
		sf::Vector2i dimensions;
		std::vector<Event> eventStack;
	};



	class Container : public Element
	{
	public:
		virtual DrawComposition* GetDrawComp();
		virtual Element* OnClick( int rmx, int rmy );
		virtual Element* OnRelease( int rmx, int rmy );
		virtual Element* OnHover( int rmx, int rmy );
	protected:
		std::vector<Element*> childElements;
	};


	class Window : public Container
	{
	public:
		virtual DrawComposition* GetDrawComp();
		virtual Element* OnClick( int rmx, int rmy );
		virtual Element* OnRelease( int rmx, int rmy );
		virtual Element* OnHover( int rmx, int rmy );
	private:
	};

	class Button : public Element
	{
	};

	class TextBox : public Element
	{
	};

	class ScrollContainer : public Container
	{
	};
}



class GuiSystem
{
public:
	GuiSystem( EventSystem *es );
	void Update();
	void Draw();

	void AddWindow( Gui::Window *w );
private:
};



#endif
