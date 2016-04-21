function writebin(bb,index,data)
% WRITEBIN Writes a binary data into bit field location.
%  WRITEBIN(BF,DATA)
%
%  WRITEBIN(BF,INDEX,DATA)
%
%  Note: In both cases, if DATA is empty, 'writebin' operation is not performed.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/11/30 23:06:44 $

error(nargchk(2,3,nargin));
if ~ishandle(bb),
    error('First Parameter must be a BITFIELD handle.');
end
if nargin==2,
    data  = index;
    index = [];
end
if isempty(data)
    return;
end

% convert strings/cell array into hexadecimal
if ischar(data),   % Data is a cell array of hexidecimal (value sized)
    try 
        data = bin2dec(data);
    catch
        error('DATA must contain valid binary characters. ');        
    end
elseif iscellstr(data)
    try
        data = [bin2dec(data)];
    catch
        error('DATA must contain valid binary characters. ');
    end
    if length(bb.size)==1
        data = reshape(data,1,bb.size);
    else
        data = reshape(data,bb.size);
    end
else
    error('DATA must be a binary string or a cell array of binary strings.');
end

data = dec2hex(data);
if isempty(index),
    write_bitfieldhex(bb,data);
else % index version - one value only!
    write_bitfieldhex(bb,index,data);
end

% [EOF] writebin.m