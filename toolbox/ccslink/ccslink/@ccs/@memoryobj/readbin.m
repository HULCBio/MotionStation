function resp = readbin(mm,index,timeout)
%READ2BIN Retrieves a block of DSP memory as hexadecimal strings.
%   DN = READ2BIN(MM)
%   DN = READ2BIN(MM,[],TIMEOUT) - reads a 
%
%
%   DN = READ2BIN(MM,INDEX)
%   DN = READ2BIN(MM,INDEX,TIMEOUT) - reads a ?
%
%   HS = READ2BIN(MM) - returns a binary string representation of 
%   the DSP's numeric values.  For arrays, the returned values will 
%   be a cell array of binary strings.  Conversely, if MM.SIZE equals 1,
%   (indicating a scalar), the output is an array of hex characters. 
%
%   DN = READ2BIN(MM,TIMEOUT) - The time alloted to perform the read is 
%   limited  by the MM.TIMEOUT property of the MM object.  However, 
%   this method can be used to explicitly define a different timeout
%   for the read.  For example, this may be necessary for very large 
%   data transfers.
%  
%   See also WRITE, READ, CAST, NUMERICMEM.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.8.2.2 $ $Date: 2004/04/08 20:46:26 $

error(nargchk(1,3,nargin));
if ~ishandle(mm),
    error('First Parameter must be a MEMORYOBJ Handle.');
end
if nargin == 1,
    uidata = read_memoryobj(mm);
elseif nargin == 2,
    uidata = read_memoryobj(mm,index);     
else
    uidata = read_memoryobj(mm,index,timeout);
end
neleminuidata = prod(size(uidata));

if uidata == 1,
    resp = dec2bin(double(uidata),mm.bitsperstorageunit);
else % create cell array TBD
   resp = dec2bin(double(uidata),mm.bitsperstorageunit);
end

% [EOF] readbin.m
