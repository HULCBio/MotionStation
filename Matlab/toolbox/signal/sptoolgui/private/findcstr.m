function ind = findcstr(cstr,str)
%FINDCSTR  Finds occurrences of string in cell array of strings.
%   IND = FINDCSTR(CSTR,STR) finds the indices of the cell array of strings
%   CSTR where CSTR{IND(I)} == STR, for I from 1 to length(IND).

%   Copyright 1988-2002 The MathWorks, Inc.
%       $Revision: 1.8 $

if isempty(cstr)
    ind = [];
    return
end
for i=prod(size(cstr)):-1:1
    ind(i) = strcmp(cstr{i},str);
end
ind = find(ind);



