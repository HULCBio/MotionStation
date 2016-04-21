function p_Append(td,typename,typeeqv)
% P_APPEND (Private) Appends another property or overwrites an existing 
%  property in the Type class. 
% 
%  P_APPEND(TD,TYPENAME,TYPEEQV) - 
%  TD - Type object, i.e., cc.type
%  TYPEDEFNAME - typedef name as declared in the C code
%  If TYPEDEFNAME is a new type entry, a property named 'typeN' is added 
%  to the class, where N is the numeric order of the new entry. 
%  If TYPEDEFNAME is already an existing type entry, information
%  contained in property 'typeN' is overwritten, where N is the order of
%  the entry.
%  TYPEDEFEQV - a MATLAB structure that contains information about the
%  equivalent base type of the type entry (this is usually an output of
%  the parser).

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2003/11/30 23:14:01 $

error(nargchk(3,3,nargin));
if ~ischar(typename),
    error('Second Parameter must be the type name in string format. ');
end
if ~isstruct(typeeqv),
    error('Invalid type information. ');
end

all_typenames = td.typename;
matchfound = strmatch(typename,all_typenames,'exact');
if isempty(matchfound),
    
	% Add new cell element in typelist
    idx = length(all_typenames) + 1;
    td.typelist{idx} = struct('name',[],'basetype',[]);
    
    % Append to type name list 
    all_typenames = horzcat(all_typenames,{typename});
    set(td,'typename',all_typenames);
    
else
    warning(['''' typename ''' already exists in the type list, information will be overwritten. ']);
    idx = matchfound;
    td.typelist{idx}.name = [];   td.typelist{idx}.basetype = [];  % initialize fields
    
end

% Change property 'typdefN'
SetTypeEntry(td,idx,typename,typeeqv);

%---------------------------------
function SetTypeEntry(td,idx,typename,typeeqv)
td.typelist{idx}.name = typename;  % assign type name
td.typelist{idx}.basetype = typeeqv; % assign type equivalent base type - struct format

% [EOF] p_Append.m