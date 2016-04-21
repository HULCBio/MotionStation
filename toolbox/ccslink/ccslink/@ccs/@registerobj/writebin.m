function dummy = writebin(rr,index,data)
%WRITEBIN Writes binary data into DSP register
%   WRITEBIN(rr,DATA) 
%   WRITEBIN(rr,DATA,[],TIMEOUT) - Writes a block of binary string (DATA) into 
%   the register block described by rr.  DATA is string containing '0' or '1' or 
%   a cell array of such binary strings.  This operation will fail if DATA has 
%   more entries that register ranged specifed by rr.  Conversely, if DATA has less
%   elements than the register range, DATA will be written starting at the first
%   address.
%   
%   WRITEBIN(rr,DATA,INDEX)
%   WRITEBIN(rr,DATA,INDEX,TIMEOUT) - Writes a single binary string (DATA) at
%   the specifed index (address offset). 
%
%
%   DN = WRITEBIN(rr,TIMEOUT) - The time alloted to perform the read is 
%   limited  by the rr.TIMEOUT property of the rr object.  However, 
%   this method can be used to explicitly define a different timeout
%   for the read.  For example, this may be necessary for very large 
%   data transfers.
%  
%   See also WRITE, READ, READ2BIN.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $ $Date: 2003/11/30 23:10:52 $

error(nargchk(2,3,nargin));
if ~ishandle(rr),
    error('First Parameter must be a REGISTEROBJ Handle.');
end
if nargin==2,   
    data = index;
elseif nargin==3 & isempty(index)
    index = 1;
end

% convert strings/cell array into unsigned integer vector
if iscell(data), % Data is a cell array of hexidecimal (value sized)
    data = dec2hex(bin2dec(data));
elseif ischar(data),   
    data = dec2hex(bin2dec(data));
else
    error('DATA must be binary strings (or cell array of them)');
end

if nargin==2,   write(rr,data);
else            write(rr,index,data);
end

% [EOF] writebin.m
