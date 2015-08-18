#include "resys.h"

#include <iostream>

bool ResourceSystem::RegisterResource(
	std::string tag, ResourceType type, std::string filename )
{
	if( rsrcMap.find(tag) == rsrcMap.end() )
	{
		rsrcMap[tag] = std::tuple<std::string,ResourceType,void*>
			( filename, type, NULL );
		return true;
	} 

	return false;
}

void ResourceSystem::PrecacheResource( std::string filename, float priority )
{
	//TODO: ResourceSystem::PrecacheResource
	// and all its associated thingies
}

void ResourceSystem::PrecacheVitalResource( std::string filename )
{
	//TODO: ResourceSystem::PrecacheVital
}

void* ResourceSystem::FetchResource( std::string tag )
{
	if( std::get<2>(rsrcMap[tag]) == NULL )
	{
		std::get<2>(rsrcMap[tag]) = LoadResource(
			std::get<0>(rsrcMap[tag]), std::get<1>(rsrcMap[tag])
		);
	}
	return std::get<2>(rsrcMap[tag]);
}

void* ResourceSystem::LoadResource( std::string filename, ResourceType type )
{
	switch( type )
	{
		case( ResourceType::Texture ):
			break;
		case( ResourceType::Sound ):
			break;
		case( ResourceType::YAML ):
			break;
		case( ResourceType::YAMLComposite ):
			break;
		case( ResourceType::BinaryComposite ):
			break;
		default:
			break;
	}
}
