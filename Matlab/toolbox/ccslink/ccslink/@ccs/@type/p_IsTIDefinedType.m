function resp = p_IsTIDefinedType(td,dtype)
% P_ISTIDEFINEDTYPE (Private) Returns information about a native C data
% type. Returns empty if the data type is not a native C type.

% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/01 16:03:51 $

dtype = p_deblankall(td,dtype);

llist = callSwitchyard(td.ccsversion,[53,td.boardnum,td.procnum,0,0],'type');
llist = strrep(llist,'enum _','enum '); % remove leading underscore
matchfound = strmatch(dtype,llist,'exact');

if ~isempty(matchfound),
    resp = 1;
else
    llist = strrep(llist,'union ',''); % remove union labels
    llist = strrep(llist,'struct ',''); % remove struct labels
    llist = strrep(llist,'enum ',''); % remove enum labels
    matchfound = strmatch(dtype,llist,'exact');
	if ~isempty(matchfound),
        resp = 1;
    else
        resp = 0;
    end
end

% [EOF] p_IsTIDefinedType.m