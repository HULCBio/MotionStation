function write(bb,index,data)
% WRITE Writes a numeric or hexadecimal data into bit field location.
%  WRITE(BF,DATA)
%
%  WRITE(BF,INDEX,DATA)
%
%  Note: In both cases, if DATA is empty, 'write' operation is not performed.

%   Copyright 2001-2003 The MathWorks, Inc.

error(nargchk(2,3,nargin));
if ~ishandle(bb),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a BITFIELD handle.');
end
if nargin==2,
    data = index;
elseif nargin==3 && isempty(index)
    index = ones(1,length(bb.size));
end
if isempty(data)
    return;
end

if iscellstr(data) || ischar(data),
    if nargin==2,   write_bitfieldhex(bb,data);
    else            write_bitfieldhex(bb,index,data);
    end
elseif isnumeric(data),
    if nargin==2,   write_bitfield(bb,data);
    else            write_bitfield(bb,index,data);
    end
else
    error(generateccsmsgid('InvalidInput'),'DATA must be a numeric array or a hexadecimal string (cell array) ');
end

% [EOF] write.m