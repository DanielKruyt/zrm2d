clang++ \
	-ggdb \
	-std=c++11 \
	-o bin/a.out \
	-I./inc \
	src/rev/event.cpp \
	src/rev/component.cpp \
	src/rev/system.cpp \
	src/rev/engine.cpp \
	main2.cpp
