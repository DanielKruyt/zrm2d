build_directory = "./bin"
source_directory = "./src"
include_directory = "./inc"

local lfs = require "lfs"

function to_table(t,match)
     local cmd = {}
     if not match then match = "[^%s]+" end
     for word in string.gmatch(t, match) do
          table.insert(cmd, word)
     end
     return cmd
end

src_files = { }

function ls( path )
	for entry in lfs.dir( path ) do
		if entry ~= "." and entry ~= ".." then
			local qname = path.."/"..entry
			local atr = lfs.attributes( qname )
			
			assert( type(atr) == "table" )
			if atr.mode == "directory" then
				-- Add this directory's contents to the src_files table
				ls( qname )
			else
				if string.sub( qname, qname:len() - 3, qname:len() ) == ".cpp" then
					table.insert( src_files, qname )
				end
			end
		end
	end
end

function bin_path_from_src( path )
	local modded = string.gsub( path, "%.cpp", "" )
	modded = string.gsub( modded, "%./", "" )
	modded = string.gsub( modded, "%/", "%_%_" )
	return modded..".o"
end

function unit_test_path_from_src( path )
	local modded = string.gsub( path, "/%w+%.cpp", "" )
	modded = string.gsub( modded, "%./", "%./module_tests/" )
	return modded
end


ls( source_directory )

unit_test_files = {}

-- compile everything
for i = 1, #src_files do
	local obj_mod_time = lfs.attributes( build_directory.."/"..bin_path_from_src( src_files[i] ), "modification" ) or 0
	local src_mod_time = lfs.attributes( src_files[i], "modification" )
	if (src_mod_time > obj_mod_time ) then
		os.execute("clang++ -ggdb --std=c++14 -I./inc/ -c -Wall "..src_files[i].." -o "..( build_directory.."/"..bin_path_from_src( src_files[i] ) ) ) 
		--  mark unit test to execute
		
		unit_test_files[ unit_test_path_from_src( src_files[i] ) ] = 1
		
		--local unit_test_path = unit_test_path_from_src( src_files )
		--local test_func = dofile( unit_test_path.."/test.lua" )
		--test_func( unit_test_path )
	end
end

-- create .a
--[[ N/A to zrm2d

list_of_objects = ""
for i = 1, #src_files do
	list_of_objects = list_of_objects .. build_directory.."/".. bin_path_from_src( src_files[i] ).." "
end

os.execute( "ar rcs ./bin/librevengine.a "..list_of_objects )

for k,v in pairs(unit_test_files) do
	local test_func = dofile( k.."/test.lua" )
	if not test_func( k )  then
		print("Failed unit test at "..k )
	end
end
]]
