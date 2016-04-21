function resp = write(ss,index,data)
%WRITE Writes data into DSP memory - 
%  WRITE(SS,DATA)
%  WRITE(SS,INDEX,DATA)
%  WRITE(SS,INDEX,DATA,TIMEOUT)
%  WRITE(SS,[],DATA,TIMEOUT)
%  
%   See also READ, WRITEBIN.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/11/30 23:13:01 $

error(nargchk(2,3,nargin));
if ~ishandle(ss),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a STRING handle.');
end
if nargin == 2,
    data = index;
    if isnumeric(data)
        write_numeric(ss,data);
    else
        write_string(ss,data);
    end
else
    if isempty(index),  index = 1;
    end
    if isnumeric(data)
        write_numeric(ss,index,data);
    else
        write_string(ss,index,data);
    end  
end

% [EOF] write.m
