---------------------------------------
-- This file provides utility functions
-- for the build script
---------------------------------------

lfs = require "lfs"

local cxx = "clang++ -c"
local lxx = "clang++"
local ar = "ar rcs"

function compile( file, outfile, flags )
	local flag_str = ""
	for k, v in pairs(flags ) do
		flag_str = flag_str..v.." "
	end
	os.execute( cxx.." "..flag_str.." -o "..outfile.." "..file )
end

function link( files, outfile, flags )
	local flag_str = ""
	for k, v in pairs(flags) do
		flag_str = flag_str..v.." "
	end
	local file_str = ""
	for k,v in pairs(files) do
		file_str = file_str..v.." "
	end
	os.execute( lxx.." "..flag_str.." -o "..outfile.." "..file_str)
end

function archive( files, outfile )
	local file_str = ""
	for k,v in pairs( files ) do
		file_str = file_str..v.." "
	end
	os.execute( ar.." "..outfile.." "..file_str )
end

function is_file_newer( file1, file2 )
	local file1_mod = lfs.attributes( file1, "modification" )
	local file2_mod = lfs.attributes( file2, "modification" )
	if file1_mod ~= nil and file2_mod ~= nil then
		return file1_mod > file2_mod
	else
		return nil
	end
end

function logify_path( path )
	local modded = string.gsub( path, "/+", "/" )
	return modded
end

function merge_tables_k( tbl1, tbl2 )
	local merged = {}
	for k, _ in pairs( tbl1 ) do
		merged[k] = 1
	end
	for k, _ in pairs( tbl2 ) do
		merged[k] = 1
	end

	return merged
end

function cpp_header_dependencies( file, inc_dirs, prev_done )
	local filenames = {}
	for line in io.lines( file ) do
		if string.sub( line, 1, 8 ) == "#include" then
			local modded = string.gsub( line, "#include%s*<","" )
			modded = string.gsub( modded, ">.*", "" )
			filenames[modded] = 1
		end
	end
	


	local fpath_headers = {}
	
	if prev_done ~= nil then
		for _,dir in pairs( inc_dirs ) do
			for fname, _ in pairs(filenames) do
				if lfs.attributes(dir.."/"..fname) ~= nil then
					local logified = logify_path( dir.."/"..fname)
					if not prev_done[logified] then
						fpath_headers[logified] = 1
					end
				end
			end
		end

	else
		for _,dir in pairs( inc_dirs ) do
			for fname, _ in pairs(filenames) do
				if lfs.attributes(dir.."/"..fname) ~= nil then
					local logified = logify_path( dir.."/"..fname)
					fpath_headers[logified] = 1
				end
			end
		end

	end

	-- merge fpath_headers and prev_done

	local merged = {}
	if prev_done ~= nil then
		merged = merge_tables_k( fpath_headers, prev_done )
	else
		merged = fpath_headers
	end

	
	for flap,_ in pairs( fpath_headers ) do
		merged = merge_tables_k( merged, cpp_header_dependencies(flap,inc_dirs, merged) )
	end

	if prev_done ~= nil then
		return merged
	else
		local newheaders = {}
		for k,_ in pairs(merged) do
			table.insert( newheaders, k )
		end
		return newheaders

	end
end


function obj_needs_update(ofile, src_file, inc_dirs)
	local deps = cpp_header_dependencies( src_file, inc_dirs )
	table.insert( deps, src_file )
	local newest = 0
	for _, v in pairs( deps ) do
		local modtime = lfs.attributes( v, "modification" )
		if modtime > newest then
			newest = modtime
		end
	end
	local ret = false
	local ofile_modtime = lfs.attributes(ofile,"modification")
	if ofile_modtime then
		return newest > ofile_modtime
	else
		return true
	end
end

















