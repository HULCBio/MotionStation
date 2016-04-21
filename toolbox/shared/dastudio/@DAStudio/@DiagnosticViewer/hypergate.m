
function hypergate(h)
%  HYPERGATE This function is a gateway for hyperlinking 
%  for the Diagnostic Viewer  
%  Copyright 1990-2004 The MathWorks, Inc.

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:37 $  

row = h.rowSelected;       
msg = h.Messages(row);
link = msg.SourceFullName;
linkType = ml_type_l(msg.SourceObject(1));

% Convert raw Stateflow ids to strings for hyperlink method

if isequal(linkType, 'id')
   link = num2str(msg.SourceObject(1));
end

h.hyperlink(linkType, link);

% Find the type of the id
function theType = ml_type_l(obj),
  
%
% Resolve handle.
%
if isnumeric(obj),
    if ~isempty(obj),
        if (obj==fix(obj) & sf('ishandle', obj)),
            theType = 'id';
	else
	    theType = 'mdl';
        end;
    end;
end;  