function dummy = write(mm,index,data)
%WRITE Writes data into DSP memory - 
%  WRITE(MM,DATA)
%  WRITE(MM,DATA,INDEX)
%  WRITE(MM,DATA,INDEX,TIMEOUT)
%  WRITE(MM,DATA,[],TIMEOUT)
%
%   WRITE(MM,DATA) this will accept only two forms of data:
%   Cell Array/String => Hexidecimal representation of value
%   Numeric => Unsigned Integer (binary) representation of value, values will
%   to rounded to nearest integer and satured to 
%
%   Min Integer value = 0
%   Max Integer value = 2^(mm.wordsize)
%
%   If DATA is smaller than the size defined for the MM object, this will only
%   write .  Not warning or error will be issued.
%
%   If DATA is larger than the size defined for the MM object, this method
%   will only write data until the memory area specified by MM are full.  An 
%   additional values in DATA will be ignored.  Also, A warning will be generated.
%
%   WRITE(MM,DATA,INDEX,TIMEOUT)
%
%
%   WRITE(MM,DATA,[],TIMEOUT) 
%
%   HS = write(MM,VAL) - returns a hex representation of the DSP's numeric 
%   values.  For arrays, the returned values will be a cell array
%   of hex strings.  Conversely, if MM.SIZE equals 1,
%   (indicating a scalar), the output is an array of hex characters. 
%
%   DN = WRITE(MM,[],TIMEOUT) - The time alloted to perform the read is 
%   limited  by the MM.TIMEOUT property of the MM object.  However, 
%   this method can be used to explicitly define a different timeout
%   for the read.  For example, this may be necessary for very large 
%   data transfers.
%  
%   See also WRITE, READ, WRITEBIN, MEMORYOBJ.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $ $Date: 2003/11/30 23:10:50 $

error(nargchk(2,3,nargin));
if ~ishandle(mm),
    error('First Parameter must be a MEMORYOBJ Handle.');
end

if nargin == 2,
    data = index;
    write_registerobj(mm,data);
else
    if isempty(index),  index=1;
    end
    write_registerobj(mm,index,data);
end

% [EOF] write.m
