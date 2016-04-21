function resp = readnumeric(en,index,timeout)
% READNUMERIC Returns the numeric value(s) stored in memory.
%  O = READNUMERIC(EN,TIMEOUT) returns a numeric data value from the memory 
%  space of the DSP processor referenced by the enum memory object EN. The 
%  read begins from the DSP memory location given by the 'address' property. 
%  The amount of data returned is the determined by the 'size' property of EN.
%
%  TIMEOUT defines an upper limit (in seconds) on the time this method will wait
%  for completion of the read.  If this period is exceeded, this method will
%  immediately return with a timeout error.  
%
%  O = READNUMERIC(EN) Same as above, except the timeout value defaults to the value 
%  specified by the CC object. Use CC.GET to examine the default supplied by the object.
%
%  O = READNUMERIC(EN,INDEX,TIMEOUT) Same as first, except it reads only the data
%  located in memory specified by INDEX.
%
%  O = READNUMERIC(EN,INDEX) Same as first, except the timeout value defaults to the value 
%  specified by the CC object.
%  
%  See also WRITENUMERIC, READ, READBIN, READHEX.

%  Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:08:06 $

error(nargchk(1,3,nargin));
if ~ishandle(en),
    error('First Parameter must be an ENUM handle.');
end

if nargin == 1,
    resp = read_numeric(en);
elseif nargin == 2,
    resp = read_numeric(en,index);     
else
    resp = read_numeric(en,index,timeout);
end

%  [EOF] readnumeric.m