function resp = write_enum(ss,index,data)
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/11/30 23:08:10 $

error(nargchk(2,3,nargin));
if ~ishandle(ss),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be an ENUM handle.');
end
if nargin==2,   
    data = index;   
end

if ~isempty(setdiff(data,ss.label))
    error(generateccsmsgid('UndefinedInputData'),['Input data contains at least one label that does not match any defined enumerated label.']);
end

if ischar(data),
    data = equivalent(ss,data);
elseif iscellstr(data),
    data = equivalent(ss,data);
end
if nargin==2,   write_numeric(ss,data);
else            write_numeric(ss,index,data);
end
    
% [EOF] write_enum.m