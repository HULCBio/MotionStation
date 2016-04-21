function dtypeinfo = list(cc,dtype)
% LIST (Private) Returns information about a defined type in Code
% Composer(R) Studio. 
%
% I = LIST(CC,typename) returns a structure that contains information on
% all defined data types in the embedded program. This method includes
% 'struct', 'enum' and 'union' datatypes and excludes typedefs. The name of
% a defined type is its C struct tag, enum tag or union tag. If the C tag
% is not defined, it is referred to by the Code Composer (R) compiler as
% '$faken' where n is an assigned number. 
%
% I = LIST(CC,typename) returns a structure that contains information on
% the specified defined datatype. 
%     
% The returned information follows the format:
% 	I.type - Type name 
% 	I.size - Size of this type 
% 	I.uclass - CCSDSP object class that matches the type of this symbol
%     
% Note: Additional information is added depending on the type.
% Note: The type name is used as the fieldname to refer to the type's structure information.
	
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.2.4.3 $ $Date: 2004/04/01 16:03:49 $

error(nargchk(2,2,nargin));
if ~ishandle(cc),
    error('First Parameter must be a TYPE Handle.');
end
if ~ischar(dtype),
    error('Data type must be a string.');
end

typename = dtype;  % original/complete type name

[dtypeinfo,tagOnly] = getDataTypeInformation(cc,dtype);

if findstr('$fake',dtypeinfo.type)
	warning(['Type ''' typename ''' does not have a C tag.']);
end

% If void is returned, dtype is not a defined CCS type
if strcmp(dtypeinfo.type,'void')
    error(['Type ''' typename ''' is not recognized.']); % no information is returned, error out
end

%----------------------------------------------
% remove decriptive type from string; api errors out if used with 'prefix'
function [symbol_i,tagOnly] = retainTag(symbol_i)
if findstr('enum _',symbol_i) % enums usually prepend '_', remove this, it shld still work
    symbol_i = symbol_i(7:end);
elseif findstr('enum ',symbol_i)
    symbol_i = symbol_i(6:end);
elseif findstr('struct ',symbol_i)
    symbol_i = symbol_i(8:end);
elseif findstr('union ',symbol_i)
    symbol_i = symbol_i(7:end);
end
tagOnly = 1;

%----------------------------------------------
function [symbobj,tagOnly] = getDataTypeInformation(cc,symbol_i)
if findstr('$',symbol_i)
    % Note: When locating for the cryptic type info, retain the tag for
    % correctly determining its ID; remove tag later
    tagOnly = 0;
    all_list = callSwitchyard(cc.ccsversion,[53,cc.boardnum,cc.procnum,0,0],'type');
    i = strmatch(symbol_i,all_list,'exact');
    if isempty(i)
        % Just try to check to check without the tag
        all_list = strrep(all_list,'enum _','');    all_list = strrep(all_list,'enum ','');
        all_list = strrep(all_list,'struct ','');   all_list = strrep(all_list,'union ','');
        i = strmatch(symbol_i,all_list,'exact');
        if isempty(i)
            error(['Type '''  symbol_i ''' is not a valid data type']);
        end
    end
    symbobj = callSwitchyard(cc.ccsversion,[61,cc.boardnum,cc.procnum,0,0],'ID',i-1);
else
    % Remove decriptive type from string; api errors out if used with 'prefix'
    [symbol_i,tagOnly] = retainTag(symbol_i);
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

% [EOF] list.m