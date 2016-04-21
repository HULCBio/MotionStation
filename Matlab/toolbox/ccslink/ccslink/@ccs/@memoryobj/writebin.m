function dummy = writebin(mm,index,data)
%WRITEBIN Writes binary data into DSP memory
%   WRITEBIN(MM,DATA) 
%   WRITEBIN(MM,DATA,[],TIMEOUT) - Writes a block of binary string (DATA) into 
%   the memory block described by MM.  DATA is string containing '0' or '1' or 
%   a cell array of such binary strings.  This operation will fail if DATA has 
%   more entries that memory ranged specifed by MM.  Conversely, if DATA has less
%   elements than the memory range, DATA will be written starting at the first
%   address.
%   
%   WRITEBIN(MM,DATA,INDEX)
%   WRITEBIN(MM,DATA,INDEX,TIMEOUT) - Writes a single binary string (DATA) at
%   the specifed index (address offset). 
%
%
%   DN = WRITEBIN(MM,TIMEOUT) - The time alloted to perform the read is 
%   limited  by the MM.TIMEOUT property of the MM object.  However, 
%   this method can be used to explicitly define a different timeout
%   for the read.  For example, this may be necessary for very large 
%   data transfers.
%  
%   See also WRITE, READ, READ2BIN.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $ $Date: 2003/11/30 23:09:33 $

error(nargchk(2,3,nargin));
if ~ishandle(mm),
    error('First Parameter must be a MEMORYOBJ Handle.');
end
if nargin==2,   
    data = index;
elseif nargin==3 & isempty(index)
    index = 1;
end

% convert strings/cell array into unsigned integer vector
if iscell(data) | ischar(data),   % Data is a cell array of hexidecimal (value sized)
    uidata = bin2dec(data);
else
    error('DATA must be binary strings (or cell array of them)');
end

if nargin == 2,
    write_memoryobj(mm,uidata)
elseif nargin == 3, % index version - one value only!
    write_memoryobj(mm,index,uidata);
end

% [EOF] writebin.m
