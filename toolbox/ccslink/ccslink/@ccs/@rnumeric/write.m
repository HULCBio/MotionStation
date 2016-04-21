function resp = write(nn,index,data)
%WRITE Writes data into DSP registers
%  WRITE(RN,DATA) Stores DATA on the register(s) that the RNUMERIC object
%  RN points to.
%
%  WRITE(RN,INDEX,DATA) Same as above, except a specific location in the
%  register array is supplied through INDEX.
%  Note: For register objects, 'size' is always equivalent to 1. Hence,
%  the second syntax is not always recommended.
%  Note: If INDEX is empty, it is the same as doing a 'write' operation
%  without passing an index.
%  
%   See also READ, WRITEBIN.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2003/11/30 23:11:49 $

error(nargchk(2,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a RNUMERIC handle.');
end

if nargin==2,   
    data  = index;
    index = []; % make index empty
end

if isempty(data)
    return; % do not proceed with write
end

if iscellstr(data) || ischar(data),
	if isempty(index),
        write_rnumerichex(nn,data);
	else
        write_rnumerichex(nn,index,data);
	end
elseif isnumeric(data),
	if isempty(index),
        write_rnumeric(nn,data);
	else
        write_rnumeric(nn,index,data);
	end
else
    error(generateccsmsgid('InvalidDataFormat'),'DATA must be a numeric array or a hexadecimal string (cell array) ');
end

% [EOF] write.m