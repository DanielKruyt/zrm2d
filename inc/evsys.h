#ifndef __EVSYS_H__
#define __EVSYS_H__

#include <string>
#include <unordered_map>

#include "evsys.h"

class EventSystem
{
public:
	void	Trigger( std::string name );
	void	Trigger( std::string name, void *data );
	void	PersistentTrigger( std::string name );
	void	PersistentTrigger( std::string name, void *data );
	bool	IsTriggered( std::string name );
	void*	GetData( std::string name );
	void	SaveToFile( std::string filename ); //TODO:
	void	LoadFromFile( std::string filename ); //TODO:
private:
	std::unordered_map<std::string, std::pair<int, void*>> m_TrigData;
	std::unordered_map<std::string, std::pair<int, void*>> m_PersistentTrigData;
};

#endif
