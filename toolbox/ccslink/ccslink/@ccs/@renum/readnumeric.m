function resp = readnumeric(en,index,timeout)
% READNUMERIC Returns the numeric value(s) stored in memory.
%  O = READNUMERIC(RE,TIMEOUT) returns a numeric data value from the memory 
%  space of the DSP processor referenced by the enum register object RE. The 
%  read begins from the DSP memory location given by the 'address' property. 
%  The amount of data returned is the determined by the 'size' property of RE.
%
%  TIMEOUT defines an upper limit (in seconds) on the time this method will wait
%  for completion of the read.  If this period is exceeded, this method will
%  immediately return with a timeout error.  
%
%  O = READNUMERIC(RE) Same as above, except the timeout value defaults to the value 
%  specified by the CC object. Use CC.GET to examine the default supplied by the object.
%
%  O = READNUMERIC(RE,INDEX,TIMEOUT) Same as first, except it reads only the data
%  located in memory specified by INDEX.
%
%  O = READNUMERIC(RE,INDEX) Same as first, except the timeout value defaults to the value 
%  specified by the CC object.
%  
%  Note: INDEX for register objects must always refer to the first and only element.
%  Example:
%  o = readnumeric(re,[1 1 1])  % if re.size = [1 1 1]
%  o = readnumeric(re,[1])      % if re.size = [1]
%  o = readnumeric(re)          % works for any size
%
%  See also WRITENUMERIC, READ, READBIN, READHEX.

%  Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:11:05 $


error(nargchk(1,3,nargin));
if ~ishandle(en),
    error('First Parameter must be an RENUM handle.');
end

if nargin == 1,
    resp = read_rnumeric(en);
elseif nargin == 2,
    resp = read_rnumeric(en,index);     
else
    resp = read_rnumeric(en,index,timeout);
end

%  [EOF] readnumeric.m