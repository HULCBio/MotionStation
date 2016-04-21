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

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.18.4.3 $ $Date: 2004/04/01 16:02:25 $

error(nargchk(2,4,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a CCSDSP Handle.');
end

if ~ischar(ltype),
    error(generateccsmsgid('InvalidInput'),'List TYPE specifier must be a string');
end


if nargin==2  % all entries, get list of symbol names
    iqualifier = strfind(ltype,'-');
    if isempty(iqualifier)
        llist = callSwitchyard(cc.ccsversion,[53,cc.boardnum,cc.procnum,0,0],ltype);
    else
        llist = callSwitchyard(cc.ccsversion,[53,cc.boardnum,cc.procnum,0,0],ltype(1:iqualifier-1));        
    end
    if strfind(ltype,'function') % remove () in function name - SDK 2.2/API 1.3
        for i=1:length(llist)
            llist{i} = unmangleFunctionName(cc.ccsversion,llist{i});
        end
    end
elseif nargin==3 & ischar(llist)    % one entry, create a single-elt cell
    llist = cellstr(llist);
end
resp = struct([]);

switch lower(ltype)
case 'project',
    resp = callSwitchyard(cc.ccsversion,[53,cc.boardnum,cc.procnum,0,0],ltype);
    
case 'variable-short',
    for symbol_i=llist,  
       try 
            if isempty( strmatch(symbol_i,fieldnames(resp),'exact') ) % get local first if within scope
                symbobj = callSwitchyard(cc.ccsversion,[60,cc.boardnum,cc.procnum,0,0],symbol_i{1});
                symbobj.name = unmangleFunctionName(cc.ccsversion,symbobj.name);
            else
                % second occurence of SYMBOL in list, get its global
                symbobj = callSwitchyard(cc.ccsversion,[60,cc.boardnum,cc.procnum,0,0],symbol_i{1},'global');
                symbobj.name = unmangleFunctionName(cc.ccsversion,symbobj.name);
            end
        catch
            % if a local static, its in the global symbol_i table
            if findstr(['GetVariable: Variable: ''' symbol_i{1} ''' is not a variable'],lasterr)
                try
                    symbobj = callSwitchyard(cc.ccsversion,[60,cc.boardnum,cc.procnum,0,0],symbol_i{1},'global');
                    symbobj.name = unmangleFunctionName(cc.ccsversion,symbobj.name);
                catch
                    % symbol_i{1} is not a loaded variable
                    throwCorrectError(lasterr,symbol_i{1});
                end
            else
                % report other error
                error(generateccsmsgid('UnexpectedError'),lasterr);
            end
        end
        name    = mangleName(symbol_i{1},fieldnames(resp));
        resp    = setfield(resp,{1},name,symbobj);
    end 
    
case {'variable','variable-complete'}
    for symbol_i=llist,    
        try 
            if isempty( strmatch(symbol_i,fieldnames(resp),'exact') ) % get local first if within scope
                symbobj = callSwitchyard(cc.ccsversion,[56,cc.boardnum,cc.procnum,0,0],symbol_i{1});
                symbobj.name = unmangleFunctionName(cc.ccsversion,symbobj.name);
            else
                % second occurence of SYMBOL in list, get its global
                symbobj = callSwitchyard(cc.ccsversion,[56,cc.boardnum,cc.procnum,0,0],symbol_i{1},'global');
                symbobj.name = unmangleFunctionName(cc.ccsversion,symbobj.name);
            end
        catch
            % if a local static, its in the global symbol table
            if findstr(['GetVariable: Variable: ''' symbol_i{1} ''' is not a variable'],lasterr)
                try
                    symbobj = callSwitchyard(cc.ccsversion,[56,cc.boardnum,cc.procnum,0,0],symbol_i{1},'global');
                    symbobj.name = unmangleFunctionName(cc.ccsversion,symbobj.name);
                catch
                    % symbol_i{1} is not a loaded variable
                    throwCorrectError(lasterr,symbol_i{1});
                end
            else
                % report other error
                error(generateccsmsgid('UnexpectedError'),lasterr);
            end
        end
        name    = mangleName(symbol_i{1},fieldnames(resp));
        resp    = setfield(resp,{1},name,symbobj);
        resp.(name) = RemoveIrrelevantVarFields(resp.(name),ltype);
    end
    
case {'globalvar','globalvar-complete'}
    for symbol_i=llist,
        try
            symbobj = callSwitchyard(cc.ccsversion,[56,cc.boardnum,cc.procnum,0,0],symbol_i{1},'global');
            symbobj.name = unmangleFunctionName(cc.ccsversion,symbobj.name);
        catch
            throwCorrectError(lasterr,symbol_i{1});
        end
        name    = mangleName(symbol_i{1},fieldnames(resp));
        resp    = setfield(resp,{1},name,symbobj);
        resp.(name) = RemoveIrrelevantVarFields(resp.(name),ltype);
    end
    
case 'function-short',
    if nargin==3,
        lopt = '';
    end
    for symbol_i=llist,
        try
            symbobj = callSwitchyard(cc.ccsversion,[60,cc.boardnum,cc.procnum,0,0],symbol_i{1});
            symbobj.name = unmangleFunctionName(cc.ccsversion,symbobj.name);
        catch
            throwCorrectError(lasterr,symbol_i{1});
        end
        name    = mangleName(symbol_i{1},fieldnames(resp));
        resp    = setfield(resp,{1},name,symbobj);
    end
    
    
case {'function','function-complete'}
    if nargin==3,
        lopt = '';
    end
    for symbol_i=llist,
        try
            symbobj = callSwitchyard(cc.ccsversion,[56,cc.boardnum,cc.procnum,0,0],symbol_i{1});
            symbobj.name = unmangleFunctionName(cc.ccsversion,symbobj.name);
        catch
            throwCorrectError(lasterr,symbol_i{1});
        end
        name    = mangleName(symbol_i{1},fieldnames(resp));
        resp    = setfield(resp,{1},name,symbobj);
        resp.(name) = RemoveIrrelevantFcnFields(resp.(name),ltype);
    end
    
case 'type',
    len = length(llist);
    if len>50,
        disp(['Extracting information on ' num2str(len) ' defined types...']);
    end 
    for i=1:len,
        symbol_i = llist{i};
        typename = symbol_i;  % original/complete type name
        
        [symbol_i,symbobj,withTag] = getDataTypeInformation(cc,symbol_i,i,nargin);
        
        checkTypeInformation(symbobj.type,typename,nargin);

        % Send warning message if tag is not specified in C code; give user a chance to clean his C code
        % for easier usage of Links, esp function objects
        if findstr('$fake',symbobj.type)
        	warning(generateccsmsgid('DataTypeHasNoTag'),sprintf(['Type ''%s'' does not have a tag. Put tag in your C code or always refer\n',... 
                'to this type in MATLAB as ''%s''.'],typename,symbol_i));
        end
        % Need to remove tag so it can be made as a MATLAB field
        if withTag
            % Remove decriptive type from string; api errors out if used with 'prefix'
            [symbol_i,withTag] = removeTag(symbol_i);
        end
        % Need to mangle tag so it can be made as a MATLAB field
        name = mangleName(symbol_i,fieldnames(resp));
        % Set type as a MATLAB field of resp
        resp = setfield(resp,{1},name,symbobj);
    end
    
otherwise
    error(generateccsmsgid('InvalidInput'),['TYPE ''' ltype ''' is not supported.']);
    return;
end

%--------------------------------------------------
function name = mangleName(name,existing_names)

if name(1)=='_'
	warning(generateccsmsgid('InvalidFieldName'),['NAME ''' name ''' is an invalid ML structure fieldname. The leading underscore (_) is replaced ''Q_''.']);
	ismangled = true;  % Eventually this should be noted in class
    name = ['Q' name];
end

if findstr(name,'$')
	warning(generateccsmsgid('InvalidFieldName'),['NAME ''' name ''' is an invalid ML structure fieldname. The dollar ($) character is replaced by ''DOLLAR''.']);
	ismangled = true;  % Eventually this should be noted in class
    name = strrep(name,'$','DOLLAR');
end

if findstr(name,'.')
	warning(generateccsmsgid('InvalidFieldName'),['NAME ''' name ''' is an invalid ML structure fieldname. The period (.) character is replaced by ''PERIOD''.']);
	ismangled = true;  % Eventually this should be noted in class
    name = strrep(name,'.','PERIOD');
end

if strmatch(name,existing_names,'exact')
	temp = name;
	i = 0;
	while strmatch(temp,existing_names,'exact')
        temp = [name num2str(i)];
        i = i+1; 
	end
	if i==1
		warning(generateccsmsgid('DuplicateStructMemberNames'),['Member ''' name ''' already exists. Second ''' name ''' will be replaced by ''' temp '''.']);
	end
    name = temp;
end


%-------------------------------------------------
function resp = RemoveIrrelevantFcnFields(resp,ltype)
if strcmp('function',lower(ltype))
    if isfield(resp,'funcdecl')
        resp = rmfield(resp,'funcdecl');
    end
    resp = rmfield(resp,'funcinfo');
end

%------------------------------------------------
function resp = RemoveIrrelevantVarFields(resp,ltype)
if strcmp('variable',lower(ltype)) || strcmp('globalvar',lower(ltype)) 
    resp = rmfield(resp,{'location' 'uclass'});
end

%----------------------------------------------
function throwCorrectError(last_error,symbol_i)
double_err_msg = findstr([symbol_i,''''],last_error); % fix this - 2 concatenated error msgs
if ~isempty(double_err_msg),    
	errId = generateccsmsgid('SymbolNotFound');
    error(errId,['GetVariable: Variable: ''' last_error(double_err_msg(end):end)]);  
else   
    error(last_error); 
end

%----------------------------------------------
% remove decriptive type from string; api errors out if used with 'prefix'
function [symbol_i,withTag] = removeTag(symbol_i)
if findstr('enum _',symbol_i) % enums usually prepend '_', remove this, it shld still work
    symbol_i = symbol_i(7:end);
elseif findstr('enum ',symbol_i)
    symbol_i = symbol_i(6:end);
elseif findstr('struct ',symbol_i)
    symbol_i = symbol_i(8:end);
elseif findstr('union ',symbol_i)
    symbol_i = symbol_i(7:end);
end
withTag = 0;

%----------------------------------------------
function [symbol_i,symbobj,withTag] = getDataTypeInformation(cc,symbol_i,i,nargs)
if findstr('$',symbol_i)
    % Note: When locating for the cryptic type info, retain the tag for
    % correctly determining its ID; remove tag later
    withTag = 1; 
    if nargs==3
        all_list = callSwitchyard(cc.ccsversion,[53,cc.boardnum,cc.procnum,0,0],'type');
        i = strmatch(symbol_i,all_list,'exact');
        if isempty(i)        
            % Just try to check to check without the tag
            all_list = strrep(all_list,'enum _','');    all_list = strrep(all_list,'enum ','');
            all_list = strrep(all_list,'struct ','');   all_list = strrep(all_list,'union ','');
            i = strmatch(symbol_i,all_list,'exact');
            if isempty(i)
                error(generateccsmsgid('DataTypeNotFound'),['Type '''  symbol_i ''' is not a valid data type']);
            end
        end
    end
    symbobj = callSwitchyard(cc.ccsversion,[61,cc.boardnum,cc.procnum,0,0],'ID',i-1);
else
    % Remove decriptive type from string; api errors out if used with 'prefix'
    [symbol_i,withTag] = removeTag(symbol_i);
    symbobj = callSwitchyard(cc.ccsversion,[61,cc.boardnum,cc.procnum,0,0],'name',symbol_i);
end
% Check for uclass (To do: remove this and fix in switchyard)
if ~isfield(symbobj,'uclass') 
    symbobj.uclass = '';
else
    if strcmpi(symbobj.uclass,'union')
        symbobj.uclass = 'structure';
    end
end
%----------------------------------------------
function checkTypeInformation(symbobjType,typename,nargs)
if strcmp(symbobjType,'void') % no information is returned, error out
    if nargs==2
        warning(generateccsmsgid('IncompleteTypeInfo'),['Not enough information extracted for type ''' typename '''.']);
    else
        error(generateccsmsgid('DataTypeNotFound'),['Type ''' typename ''' is not recognized.']);
    end
end

% [EOF] list.m