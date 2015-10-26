#ifndef __util_h__
#define __util_h__

template<class T>
class wrapped_queue // only intended for use with plain-old-data
{
	public:
		void push_front( T& v );
		void push_back( T& v );
};

#endif
