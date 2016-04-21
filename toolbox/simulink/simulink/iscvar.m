function status = iscvar(s)
%ISCVAR  True for valid C variables.
%    For a string S, ISCVAR(S) is 1 for alphanumeric
%    variables starting with [_a-zA-Z] and 0 otherwise.

% Copyright 1994-2002 The MathWorks, Inc.
% $RCSfile: iscvar.m,v $
% $Revision: 1.1.6.1 $
% $Date: 2002/09/23 16:29:33 $
%
% Abstract:
%    Required for Real-Time Workshop for TLC callbacks into MATLAB
%
% Relevant ASCII codes
%   0-9: 48-57
%   A-Z: 65-90
%   _  : 95
%   a-z: 97-122

status = 0;

% must be at least 1 character
if length(s) == 0
   return
end

% first char must be [_A-Za-z]
if ~isletter(s(1)) & ~strcmp(s(1), '_')
   return
end

% everything else must be alphanumeric
ds = double(s);
if length(find(ds<48)) | ...
      length(find(s(find(ds>57))<65)) | ...
      length(find(s(find(ds>90))<95)) | ...
      length(find(ds==96)) | ...
      length(find(ds>122))
   return
end

% it's valid
status = 1;
