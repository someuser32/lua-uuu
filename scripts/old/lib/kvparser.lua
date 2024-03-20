-- Copyright (c) Elfansoer

--------------------------------------------------------------------------------
-- Metadata:
local PATH = "scripts/vscripts/libraries/kvparser/"

--[[
--------------------------------------------------------------------------------
=========================
=== KV PARSER LIBRARY ===
=========================
A library to parse Valve's KV files, with more options.
Basic features:
- Reads KV from a file (only in Tools mode)
- Reads KV from a string
- Writes KV to a file (only in Tools mode)
- Print KV to console

Additional features:
- Parsing KV with duplicate keys preserved (the keys will be renamed)
- Parsing KV by keeping the order (the resulting table will be an array containing key-val)
- Store KV string as list of lines instead of one large string

--------------------------------------------------------------------------------
API:
-- Enum eParseMode
KVParser.MODE_DEFAULT: Duplicate keys will be combined if both values are tables, written over otherwise.
KVParser.MODE_REPLACE: Duplicate keys will be written over.
KVParser.MODE_UNIQUE: Duplicate keys will be renamed.
KVParser.MODE_ORDERED: Returns arrays instead of tables, with array data containing {data.key} and {data.val}.

---[[ KVParser:LoadKeyValueFromFile
		Loads a KV from a file. Base folder is "dota 2 beta/game/bin/<win32/win64>/".
		Supports referencing other files using "#base".
		Can only be called in tools mode. ])
-- @return table
-- @param file_path string
-- @param mode eParseMode
function KVParser:LoadKeyValueFromFile( file_path, mode = KVParser.MODE_DEFAULT )

---[[ KVParser:LoadKeyValueFromOpenFile
		Loads a KV from an opened file handle.
		Supports referencing other files using "#base".
		Can only be called in tools mode. ])
-- @return table
-- @param file_handle handle
-- @param mode eParseMode
function KVParser:LoadKeyValueFromFile( file_handle, mode = KVParser.MODE_DEFAULT )

---[[ KVParser:LoadKeyValueFromRequire
		Loads a KV from an lua file using 'require'.
		Does not support referencing other files using "#base". ])
-- @return table
-- @param file_path string
-- @param mode eParseMode
function KVParser:LoadKeyValueFromFile( file_path, mode = KVParser.MODE_DEFAULT )

---[[ KVParser:LoadKeyValueFromString
		Loads a KV from a string.
		Does not support referencing other files using "#base". ])
-- @return table
-- @param str string
-- @param mode eParseMode
function KVParser:LoadKeyValueFromString( str, mode = KVParser.MODE_DEFAULT )

--------------------------------
---[[ KVParser:PrintToConsole   ])
-- @return void
-- @param inTable table
function KVParser:PrintToConsole( inTable )

---[[ KVParser:PrintToFile  Writes to opened file. ])
-- @return void
-- @param inTable table
function KVParser:PrintToFile( inTable, file )

---[[ KVParser:PrintToTable  Writes as string to given table, split by newlines ])
-- @return void
-- @param inTable table
-- @param outTable table
function KVParser:PrintToTable( inTable, outTable )

---[[ KVParser:PrintToFunc  Calls func( str ) for each line in produced KV string ])
-- @return void
-- @param inTable table
function KVParser:PrintToFunc( inTable, func )

]]

--------------------------------------------------------------------------------
-- Class Definition
--------------------------------------------------------------------------------
-- check if there is already another cosmetics library
if KVParser and KVParser.AUTHOR~="Elfansoer" then return end
KVParser = {}

KVParser.PATH = PATH
KVParser.VERSION = "1.0"
KVParser.AUTHOR = "Elfansoer"

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------
KVParser = {}
KVParser.MODE_DEFAULT = 0
KVParser.MODE_REPLACE = 1
KVParser.MODE_UNIQUE = 2
KVParser.MODE_ORDERED = 3

function KVParser:LoadKeyValueFromFile( file_path, mode )
	-- create instance
	local instance = {}
	for k,v in pairs(KVParser) do
		instance[k] = v
	end

	-- get folder path
	instance.folder_path = string.match( file_path, '.*/' )

	-- set mode
	instance.mode = mode or self.MODE_DEFAULT

	-- open
	local file, err = io.open( file_path, r )
	if not file then
		print("Read File error: " .. err)
		return
	end

	-- read and close
	instance.string = file:read( "*all" )
	file:close()

	-- start
	instance:Start()

	-- return
	local ret = instance.root
	instance = nil
	return ret
end

function KVParser:LoadKeyValueFromOpenFile2( file, mode )
	-- create instance
	local instance = {}
	for k,v in pairs(KVParser) do
		instance[k] = v
	end

	-- load string
	instance.string = file:read("*all")

	-- set mode
	instance.mode = mode or self.MODE_DEFAULT

	-- start
	instance:Start()

	-- return
	local ret = instance.root
	instance = nil
	return ret
end

function KVParser:LoadKeyValueFromOpenFile( file, mode )
	-- create instance
	local instance = {}
	for k,v in pairs(KVParser) do
		instance[k] = v
	end

	-- load string
	instance.string = file

	-- set mode
	instance.mode = mode or self.MODE_DEFAULT

	-- start
	instance:Start()

	-- return
	local ret = instance.root
	instance = nil
	return ret
end

function KVParser:LoadKeyValueFromRequire( path, mode )
	-- create instance
	local instance = {}
	for k,v in pairs(KVParser) do
		instance[k] = v
	end

	-- load string
	local status, err = pcall( function()
		instance.string = require( path )
	end)
	if not status then
		print("Read Required File error: " .. err)
		return
	end
	instance.mode = mode or instance.MODE_DEFAULT

	-- start
	instance:Start()

	-- return
	local ret = instance.root
	instance = nil
	return ret
end

function KVParser:LoadKeyValueFromString( str, mode )
	-- create instance
	local instance = {}
	for k,v in pairs(KVParser) do
		instance[k] = v
	end

	instance.string = str
	instance.mode = mode or self.MODE_DEFAULT

	-- start
	instance:Start()

	-- return
	local ret = instance.root
	instance = nil
	return ret
end

function KVParser:PrintToConsole( inTable )
	-- just do defaults
	self:Printing( inTable )
end

function KVParser:PrintToFile( inTable, file )
	-- set up printing func
	local func = function( str )
		file:write( str .. '\n' )
	end
	self:Printing( inTable, func )
end

function KVParser:PrintToTable( inTable, tab )
	-- set up printing func
	local func = function( str )
		table.insert( tab, str )
	end
	self:Printing( inTable, func )
end

function KVParser:PrintToFunc( inTable, func )
	self:Printing( inTable, func )
end

--------------------------------------------------------------------------------
-- legacy
function KVParser:LoadKV( path )
	-- create instance
	local instance = {}
	for k,v in pairs(KVParser) do
		instance[k] = v
	end

	-- load string
	local status, err = pcall( function()
		instance.string = require( path )
	end)
	if not status then
		print( err )
		return
	end
	instance.mode = instance.MODE_UNIQUE

	-- start
	instance:Start()

	-- return
	local ret = instance.root
	instance = nil
	return ret
end

function KVParser:LoadKVFromFile( file )
	-- create instance
	local instance = {}
	for k,v in pairs(KVParser) do
		instance[k] = v
	end

	-- load string
	instance.string = file:read("*all")
	instance.mode = instance.MODE_UNIQUE

	-- start
	instance:Start()

	-- return
	local ret = instance.root
	instance = nil
	return ret
end

function KVParser:PrintKVToFile( file, inTable, level )
	self:PrintToFile( inTable, file )
end

--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------
function KVParser:Start()
	self.pointer = 1
	self.root = {}
	self.key = nil
	self.val = nil
	self.table_stack = {}

	-- try lexing
	local status, err
	status, err = pcall(function()
		self:LexingParsing()
	end)
	if not status then
		print("LexingParsing error: " .. (err.text or err))
		return {}
	end

	-- clean up
	self.string = nil
	self.table_stack = nil
	self.key = nil
	self.val = nil
end

-- It used to be 2 functions: Lexing and Parsing.
-- But they took so much memory for large files (25MB files) that they are combined instead.
-- Resulting in this mixed hard-to-understand code, optimized for memory, sacrificing readability.
function KVParser:LexingParsing()
	local a,b
	local token
	local brace_pairs = 0
	local last_pointer = 1

	while true do
		-- consume whitespaces
		a,b = string.find( self.string, '[%s]-%S', self.pointer )
		if not a then break end
		self.pointer = b+1
		
		-- find token
		token = string.sub( self.string, b, b )

		-- switch token
		if token == '"' then
			-- store init position
			local start = b

			-- get matching quotes that is not backslashed or in newline
			while true do
				a,b = string.find( self.string, '[\n"]', self.pointer )
				if not a then
					-- find <EOF> instead of quotes
					error( { text = "Unexpected <EOF> to close quote (\") in line " .. self:GetLine( start ) } )
				end
				self.pointer = b+1

				-- no newline inside quote
				if string.sub( self.string, a, a )=='\n' then
					error( { text = "Unexpected newline to close quote (\") in line " .. self:GetLine( start ) } )
				end

				-- check if backslashed
				if string.sub( self.string, a-1, a-1 )~='\\' then break end
			end

			----------------------
			-- Do Parsing
			local val
			if not self.key then
				-- get key
				self.key = string.sub( self.string, start+1, b-1 )
			else
				-- get val
				val = string.sub( self.string, start+1, b-1 )

				-- check #base command
				if self.key=="#base" then
					-- ref other file
					local ret = self:Referencing( val )
					if not ret then
						error( { text = "Unable to load file " .. self.folder_path .. val } )
					end

					-- join
					for k,v in pairs(ret) do
						if self.mode == self.MODE_ORDERED then
							k = v.key
							v = v.val
						end
						self.Insert[self.mode]( self.root, k, v )
					end
				else
					-- store kv
					self.Insert[self.mode]( self.root, self.key, val )
				end

				-- reset
				self.key = nil
			end

		elseif token == '{' then
			-- push pairs
			brace_pairs = brace_pairs + 1

			----------------------
			-- Do Parsing
			local val
			if not self.key then
				-- error
				error( { text = "Unexpected '{' instead of a key string in line " .. self:GetLine( token.pos[0] ) } )
			else
				-- value is table
				local val = {}

				-- on mode combine, returns existing table
				val = self.Insert[self.mode]( self.root, self.key, val ) or val

				-- push stack
				table.insert( self.table_stack, self.root )
				self.root = val
				self.key = nil
			end

		elseif token == '}' then
			-- pop pairs
			brace_pairs = brace_pairs - 1

			-- too much closing bracket
			if brace_pairs<0 then
				error( { text = "Expected <EOF> instead of '}' (Probably too much closing brackets)." } )
			end

			----------------------
			-- Do Parsing
			if not self.key then
				-- pop root
				self.root = table.remove( self.table_stack )
			else
				-- error
				error( { text = "Unexpected '}' instead of a value string in line " .. self:GetLine( token.pos[0] ) } )
			end

		elseif token == '/' then
			-- get comment
			a,b = string.find( self.string, '//.-[\n$]', a )

			-- the comment is malfunctioned <EOF> instead of quotes
			if not a then
				error( { text = "Malfunctioned comment (//) in line " .. self:GetLine( self.pointer ) } )
			end

			self.pointer = b+1

			----------------------
			-- No Parsing

		elseif token == '#' then
			-- find "#base"
			a,b = string.find( self.string, '#base', a )
			if not a then
				-- why would you typo a #?
				error( { text = "Why would you typo a # in line " .. self:GetLine( self.pointer ) .. "? You must put #base." } )
			end
			self.pointer = b+1

			----------------------
			-- Do Parsing
			if not self.key then
				self.key = "#base"
			else
				-- error
				error( { text = "Unexpected '#base' instead of a value string in line " .. self:GetLine( token.pos[0] ) } )
			end

		else
			error( { text = "Looks like a typo of character \"" .. token .. "\" in line " .. self:GetLine( a ) } )
		end
	end

	-- check if brace_pairs is not empty
	if brace_pairs>0 then
		error( { text = "Expected '}' instead of <EOF> (Probably too much opening brackets)." } )
	end
end

--------------------------------------------------------------------------------
KVParser.Insert = {
	[KVParser.MODE_DEFAULT] = function( tab, key, val )
		-- preferably store as number
		key = tonumber( key ) or key
		val = tonumber( val ) or val

		-- check if existing and both is a table
		local exist = tab[key]
		if exist and type(exist)=="table" and type(val)=="table" then
			-- combine
			for k,v in pairs(val) do
				exist[k] = v
			end

			-- return the existing table
			return exist
		end

		-- if not, replace whatever value may exist
		tab[ key ] = val
	end,

	[KVParser.MODE_REPLACE] = function( tab, key, val )
		-- preferably store as number
		key = tonumber( key ) or key
		val = tonumber( val ) or val

		-- store, replacing whatever value may exist
		tab[ key ] = val
	end,
	
	[KVParser.MODE_UNIQUE] = function( tab, key, val )
		-- duplicate numbering starts from 2
		local number = 2
		local basekey = key

		-- check existing key
		while tab[ key ] do
			-- increment key
			key = basekey .. "_" .. number
			number = number + 1
		end

		-- preferably store as number
		key = tonumber( key ) or key
		val = tonumber( val ) or val
		tab[ key ] = val
	end,

	[KVParser.MODE_ORDERED] = function( tab, key, val )
		-- preferably store as number
		key = tonumber( key ) or key
		val = tonumber( val ) or val

		-- use table insert
		local data = {}
		data.key = key
		data.val = val
		table.insert( tab, data )
	end,
}

--------------------------------------------------------------------------------
function KVParser:Referencing( path )
	local full_path = self.folder_path .. path

	-- recursive Parser
	local ret = self:LoadKeyValueFromFile( full_path, self.mode )

	return ret
end

--------------------------------------------------------------------------------
function KVParser:Printing( inTable, func, level, ordered )
	if not level then level = 0 end
	local indent = string.rep( "    ", level ) 

	-- check if it is MODE_ORDERED
	if ordered==nil then
		ordered = #inTable>0
	end

	-- give quote
	local Q = function( s )
		return '"' .. tostring(s) .. '"'
	end

	-- default printing func
	if not func then
		func = function( str )
			print( str )
		end
	end

	-- traverse
	for key,val in pairs(inTable) do
		if ordered then
			key = val.key
			val = val.val
		end

		-- check value
		if type( val )=="table" then

			-- write key then newline and `{`, then another newline
			func( indent .. Q(key) )
			func( indent .. "{" )

			-- write child kv
			self:Printing( val, func, level+1, ordered )

			-- close with `}`
			func( indent .. "}" )
		else
			-- write key value
			func( indent .. Q(key) .. '\t' .. Q(val) )
		end
	end
end

--------------------------------------------------------------------------------
-- Helper
--------------------------------------------------------------------------------
function KVParser:GetLine( pos )
	local line = 1
	for newline in string.gmatch( string.sub( self.string, 1, pos ), '\n' ) do
		line = line + 1
	end

	return line
end

function KVParser:DeepPrint( tab, level )
	level = level or 0
	local indent = string.rep( "    ", level ) 

	for k,v in pairs(tab) do
		if type(v)=="table" then
			print(indent .. k .. "\ttable")
			self:DeepPrint( v, level+1 )
		else
			print(indent .. k .. "\t" .. v)
		end
	end
end