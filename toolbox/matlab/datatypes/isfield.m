function tf = isfield(s,f)
%ISFIELD True if field is in structure array.
%   F = ISFIELD(S,'field') returns true if 'field' is the name of a field
%   in the structure array S.
%
%   See also GETFIELD, SETFIELD, FIELDNAMES, ORDERFIELDS, RMFIELD, ISSTRUCT.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.13.4.3 $  $Date: 2004/04/10 23:25:25 $

if isa(s,'struct')  
  tf = any(strcmp(fieldnames(s),f));
else
  tf = false;
end


