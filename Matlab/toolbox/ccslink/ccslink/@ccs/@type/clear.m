function clear(td,typename)
%CLEAR(OBJ,'ALL') Clears all typedef entries in the Typedef class.
%
%CLEAR(OBJ,typedefname) clears the info on an existing typedef entry in the Typedef class.
% 
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/11/30 23:13:56 $

error(nargchk(2,2,nargin));
if ~ischar(typename)
    error('Second parameter must be a string. ');
end

if strcmp(typename,'all'),
    RemoveTypeEntryAll(td);
else
	matchfound = strmatch(typename,td.typename,'exact');
	if isempty(matchfound),
        warning(['Typedef ''' typename ''' does not exist in the list. ']);
        return
	end
    RemoveTypeEntry(td,typename,matchfound);
end

%----------------------------
function RemoveTypeEntry(td,tdname,id)
if id==1 && length(td.typename)==1,
    RemoveTypeEntryAll(td);
elseif id==1 && length(td.typename)~=1,
	td.typename = { td.typename{2:end} };
	td.typelist = { td.typelist{2:end} };
else
	td.typename = { td.typename{1:id-1},td.typename{id+1:end} };
	td.typelist = { td.typelist{1:id-1},td.typelist{id+1:end} };
end

%----------------------------
function RemoveTypeEntryAll(td)
td.typename = [];
td.typelist = [];

% [EOF] .m