#ifndef __GUI__EVENTS_H__
#define __GUI__EVENTS_H__

namespace Gui
{
	enum class EventType
	{
	};



	class Event
	{
	public:
		EventType Type;
		bool FreeData; // whether Data will be free'd at end of frame
		void *Data;
	};
}

#endif
