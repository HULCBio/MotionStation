function resp = readhex(mm,index,timeout)
%READ2HEX Retrieves a block of DSP memory as hexadecimal strings.
%   DN = READ2HEX(MM)
%   DN = READ2HEX(MM,[],TIMEOUT)
%   DN = READ2HEX(MM,INDEX)
%   DN = READ2HEX(MM,INDEX,TIMEOUT)
%
%   HS = READ2HEX(MM) - returns a hex representation of the DSP's numeric 
%   values.  For arrays, the returned values will be a cell array
%   of hex strings.  Conversely, if MM.SIZE equals 1,
%   (indicating a scalar), the output is an array of hex characters. 
%
%   DN = READ2HEX(MM,TIMEOUT) - The time alloted to perform the read is 
%   limited  by the MM.TIMEOUT property of the MM object.  However, 
%   this method can be used to explicitly define a different timeout
%   for the read.  For example, this may be necessary for very large 
%   data transfers.
%  
%   See also WRITE, READ, CAST, NUMERICMEM.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $ $Date: 2003/11/30 23:10:45 $


error(nargchk(1,3,nargin));
if ~ishandle(mm),
    error('First Parameter must be a MEMORYOBJ Handle.');
end
if nargin == 1,
    uidata = read(mm);
elseif nargin == 2,
    uidata = read(mm,index);     
else
    uidata = read(mm,index,timeout);
end

if uidata == 1,
    resp = dec2hex(double(uidata));
else % create cell array TBD
   resp = dec2hex(double(uidata));
end

% [EOF] readhex.m
