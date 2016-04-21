function resp = list(cc,ltype,llist,lopt)
% LIST   Returns a list of information from Code Composer(R) Studio.
% 	I = LIST(CC,...) reads information about your Code Composer
% 	Studio session and returns it in 'I'.  Different types of information 
% 	and return formats are possible.  The TYPE parameter is used to specify
% 	which list is to be returned.  Note, the LIST command returns dynamic 
% 	Code Composer information that can be altered by the user.  A returned 
% 	'I' list represents a snapshot of the present Code Composer studio 
% 	configuration state.  Therefore, be aware that old copies of 'I' might 
% 	contain stale information.
% 	
% 	I = LIST(CC,'project') returns a vector of structures containing project 
% 	information:
% 	I(n).name - Project file name (with path).
% 	I(n).type - Project type: 'project','projlib', or 'projext', see NEW
% 	I(n).targettype - String Description of Target CPU
% 	I(n).srcfiles - Vector of structures that describes project source files
% 	I(n).srcfiles(m).name - Source file name (with path)
% 	I(n).buildcfg   - Vector of structures that describe build configurations
% 	I(n).buildcfg(m).name - Build Configuration name
% 	I(n).buildcfg(m).outpath - Default directory used to store build output
% 
% 	I = LIST(CC,'variable') returns a structure of structures that contains information 
%     on all local variables within scope. The list also includes information on all global 
%     variables. Note, however, that if a local variable has the same symbol name as a global, 
%     information about the local will be given instead.
% 	I = LIST(CC,'variable',varname) returns information about the specified variable
% 	I = LIST(CC,'variable',varnamelist) returns information about variables in a list.
% 	
% 	The returned information follows the format:
% 	I.(varname1). ...
% 	I.(varname2). ...
% 	...
% 	I.(varnameN).name - Symbol name 
% 	I.(varnameN).isglobal - Indicates whether symbol is global or local
% 	I.(varnameN).location - Information about the location of the symbol
% 	I.(varnameN).size - Size per dimension
% 	I.(varnameN).uclass - CCSDSP object class that matches the type of this symbol
% 	I.(varnameN).type - Datatype of symbol
% 	I.(varnameN).bitsize - Size in bits
%     
% 	More information is added to the structure depending on the symbol type.
%     
% 	Note: The variable name is used as the fieldname to refer to the variable's structure 
%     information.
% 	
% 	I = LIST(CC,'globalvar') returns a structure that contains information on all global variables.
% 	I = LIST(CC,'globalvar',varname) returns a structure that contains information on the 
%     specified global variable.
% 	I = LIST(CC,'globalvar',varnamelist) returns a structure that contains information on global 
%     variables in the list.
%     
% 	The returned information follows the same format as I = LIST(CC,'variable',...).
% 	
% 	I = LIST(CC,'function') returns a structure that contains information on all functions 
%     in the embedded program.
% 	I = LIST(CC,'function',varname) returns a structure that contains information on the 
%     specified function.
% 	I = LIST(CC,'function',varname) returns a structure that contains information 
%     on the specified functions in the list.
%     
% 	The returned information follows the format:
% 	I.(funcname1). ...
% 	I.(funcname2). ...
% 	...
% 	I.(funcnameN).name - Function name 
% 	I.(funcnameN).filename - Name of file where function is defined
% 	I.(funcnameN).address - Relevant address information such as start address and end address
% 	I.(funcnameN).funcvar - Variables local to the function
% 	I.(funcnameN).uclass - CCSDSP object class that matches the type of this symbol - 'function'
% 	I.(funcnameN).funcdecl - Function declaration; where information such the function return type is contained
% 	I.(funcnameN).islibfunc - Is this a library function?
% 	I.(funcnameN).linepos - Start and end line positions of function
% 	I.(funcnameN).funcinfo - Miscellaneous information about the function
%     
% 	Note: The function name is used as the fieldname to refer to the function's structure information.
% 	
% 	I = LIST(CC,'type') returns a structure that contains information on all defined data types 
%     in the embedded program. This method includes 'struct', 'enum' and 'union' datatypes and excludes 
%     typedefs. The name of a defined type is its C struct tag, enum tag or union tag. If the C tag is not 
%     defined, it is referred to by the Code Composer (R) compiler as '$faken' where n is an assigned number.
% 	I = LIST(CC,'type',typename) returns a structure that contains information on the specified defined datatype.
% 	I = LIST(CC,'type',typenamelist) returns a structure that contains information on the specified 
%     defined datatypes in the list.
%     
% 	The returned information follows the format:
% 	I.(typename1). ...
% 	I.(typename2). ...
% 	...
% 	I.(typenameN).type - Type name 
% 	I.(typenameN).size - Size of this type 
% 	I.(typenameN).uclass - CCSDSP object class that matches the type of this symbol
%     
% 	Additional information is added depending on the type.
%     
% 	Note: The type name is used as the fieldname to refer to the type's structure information.
% 	
% 	Important: If a variable name, type name or function name is not a valid MATLAB structure fieldname, 
%     it is replaced such that it becomes valid.
%     
% 	Example 1:
% 		varname1 = '_with_underscore'; % invalid fieldname
% 		>> I = list(cc,'variable',varname1);
%         
% 		ans = 
%         	Q_with_underscore : [varinfo]
% 		
% 		>> I. Q_with_underscore
%         
%                   	 name: '_with_underscore '
%                  isglobal: 0
%                  location: [1x62 char]
%                      size: 1
%                    uclass: 'numeric'
%                      type: 'int'
%                   bitsize: 16
% 	
% 	Note: In fieldnames that start with an underscore character, the character ‘Q’ is inserted before the name.
% 	
% 	Example 2:
%     
% 		typename1 = '$fake3'; % name of defined C type with no tag
% 		>> I = list(cc,'type',typename1);
%         
% 		ans = 
% 		    DOLLARfake0 : [typeinfo]
% 		
% 		>> I. DOLLARfake0
%         
% 				   type: 'struct $fake0'
% 				   size: 1
% 				 uclass: 'structure'
% 				 sizeof: 1
% 				members: [1x1 struct]
%                 
% 	Note: In fieldnames that contain the invalid dollar character '$', it is replaced by 'DOLLAR'.
% 	
% 	*** Changing the MATLAB fieldname does not change the name of the embedded symbol or type.
% 	
% 	See also INFO.

% Copyright 2004 The MathWorks, Inc.
