#ifndef __EVENT_H__
#define __EVENT_H__

#include <vector>
#include <unordered_map>
#include <stdint.h>

namespace rev
{
	const uint64_t FLAG_DEATH = 0;
	class event_system
	{
public:
		event_system();
		//~event_system();

		static uint64_t hash( const char* str );

		uint64_t register_event( const char* name );
		uint64_t register_event( const uint64_t hash );
		int register_flag( const char* name, bool persistent );
		int register_flag( const uint64_t hash, bool persistent );

		void add_hook( const uint64_t hash, void(*hkptr)(void*) );

		void trigger_event( const uint64_t hash, void* data );
		void trigger_event( const uint64_t hash );
		void set_flag( const uint64_t hash, int v );

		void* get_event_data( const uint64_t hash );
		bool get_flag( const uint64_t hash );

		void run_hooks();
private:
		uint64_t flag[8192];
		int num_flag;
		int num_pflag;

		uint64_t triggered[4096]; // array of triggered events
		int num_triggered;

		std::unordered_map<uint64_t,int> flag_map;
		std::unordered_map<uint64_t,void*> events;
		std::unordered_map<uint64_t,std::vector<void*>> hooks;
	};
};

#endif
