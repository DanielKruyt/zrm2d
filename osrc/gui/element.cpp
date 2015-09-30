#include "gui.h"

/*
		sf::Vector2i GetPos();
		sf::Vector2i GetDimensions();
		void SetPos( sf::Vector2i p );
		void SetDimeonsions( sf::Vector2i d );

		void PushEvent( Event e );
		std::vector<Event> CollectEvents();
	private:
		sf::Vector2i pos;
		sf::Vector2i dimensions;
		std::vector<Event> eventStack;
		*/

sf::Vector2i Gui::Element::GetPos()
{
	return pos;
}

sf::Vector2i Gui::Element::GetDimensions()
{
	return dimensions;
}

void Gui::Element::SetPos( sf::Vector2i p )
{
	pos = p;
}

void Gui::Element::SetDimensions( sf::Vector2i d )
{
	dimensions = d;
}

void Gui::Element::PushEvent( Gui::Event e )
{
	eventStack.push_back( e );
}

std::vector<Event>* Gui::Element::CollectEvents()
{
	return &eventStack;
}
