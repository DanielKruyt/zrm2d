#include "evsys.h"

#include <fstream>

void EventSystem::Trigger( std::string name )
{
	if( m_TrigData.find( name ) == m_TrigData.end() )
	{
		m_TrigData[name] = std::pair<int,void*>( 0, NULL );
	}
	m_TrigData[name].first++;
}



void EventSystem::Trigger( std::string name, void *data )
{
	if( m_TrigData.find( name ) == m_TrigData.end() )
	{
		m_TrigData[name] = std::pair<int,void*>( 0, NULL );
	}
	m_TrigData[name].first++;
	m_TrigData[name].second = data;
}



void EventSystem::PersistentTrigger( std::string name )
{
	if( m_PersistentTrigData.find( name ) == m_PersistentTrigData.end() )
	{
		m_PersistentTrigData[name] = std::pair<int,void*>( 0, NULL );
	}
	m_PersistentTrigData[name].first++;
}



void EventSystem::PersistentTrigger( std::string name, void *data )
{
	if( m_PersistentTrigData.find( name ) == m_PersistentTrigData.end() )
	{
		m_PersistentTrigData[name] = std::pair<int,void*>( 0, NULL );
	}
	m_PersistentTrigData[name].first++;
	m_PersistentTrigData[name].second = data;
}



bool EventSystem::IsTriggered( std::string name )
{
	return ( m_TrigData.find( name ) != m_TrigData.end()
		|| m_PersistentTrigData.find( name ) != m_PersistentTrigData.end() );
}

void *EventSystem::GetData( std::string name )
{
	if( m_PersistentTrigData.find( name ) != m_PersistentTrigData.end() )
	{
		return m_PersistentTrigData[name].second;
	}
	return m_TrigData[name].second;
}

void EventSystem::SaveToFile( std::string filename )
{
	std::fstream file;
	file.open( filename.c_str(), std::ios_base::out );

}

void EventSystem::LoadFromFile( std::string filename )
{
	std::fstream file;
	file.open( filename.c_str(), std::ios_base::in );

}

