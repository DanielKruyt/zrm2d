#ifndef __RESYS_H__
#define __RESYS_H__

#include <string>
#include <unordered_map>

/*
** This exists only for the sake of the possible future use,
** most of the stuff it does is not neccesary when game is less than 250Mb
** in size, since it can effectively be loaded into RAM all at once anyway
*/

enum class ResourceType
{
	Texture, Sound, YAML, YAMLComposite, BinaryComposite
};

class ResourceSystem
{
public:
	bool RegisterResource(
		std::string tag, ResourceType type, std::string filename
	);
	
	void PrecacheResource( std::string tag, float priority ); 
	void PrecacheVitalResource( std::string tag );

	void* FetchResource( std::string tag );

#ifdef DEBUG // all times are in ms and sizes in bytes
	int CacheMisses;
	int AverageMissLoadTime;
	int MissLoadTimeVariance;
	int AverageMissSize;

	int AverageResourceSize;
	int ResourceSizeVariation;
#endif
private:
	std::unordered_map<
		std::string,
		std::tuple<std::string,ResourceType,void*>
		>	rsrcMap;
	void* LoadResource( std::string filename, ResourceType type );
};

#endif
