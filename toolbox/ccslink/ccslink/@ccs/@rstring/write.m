function resp = write(nn,index,data)
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2003/11/30 23:12:22 $

error(nargchk(2,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a RSTRING Handle.');
end
if nargin == 2,
    data = index;
    write_rstring(nn,data);
else
    if isempty(index),  index = 1;
    end
    write_rstring(nn,index,data);
end

% [EOF] write.m
