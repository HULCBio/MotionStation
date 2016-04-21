function write(nn,index,data)
%WRITE - Writes data into DSP memory.
% 
% WRITE(MM,DATA) - write DATA into the DSP memory pointed to by the object handle MM.
% 
% WRITE(MM,DATA,INDEX) - write DATA into the nth element of MM, where n is specified by  INDEX.
% 
% WRITE(MM,DATA,INDEX,TIMEOUT) - write DATA into the nth element of MM, where n is specified by INDEX. 
%     TIMEOUT specifies the duration of the WRITE execution.
% 
% WRITE(MM,DATA,[ ],TIMEOUT) - same as first syntax except with TIMEOUT specified.
% 
% Important Notes:
% 
% ·	If DATA is above the maximum allowed value or below the minimum allowed value for MM, 
%     the final value is saturated, meaning either the minimum or maximum value is written into DSP 
%     memory.
% 
% Example:
% MM - object handle to a scalar variable having a 16-bit wordsize and 'unsigned' representation
% 	write(mm,-3) - results to writing 0 (the min) into memory.
% 	write(mm,70000) - results to writing 65535 (the max) into memory.
% 
% 
% ·	If DATA contains more number of elements than the specified size for MM, DATA will be truncated 
%     such that only the first set of elements that fit into the memory block which MM points to is 
%     written. On the other hand, if DATA contains less number of elements than the specified size for 
%     MM, only the memory space where DATA can fit into will be populated. The remaining memory space 
%     is unaffected.
% 
% Example:
% MM - object handle to a [1x10] variable
% 	write(mm,[1:15]) - results to writing [1:10] into memory.
% 	write(mm,[1:5]) - results to writing [1:5] into memory.
%  
%   See also READ, WRITEBIN, WRITEHEX.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $ $Date: 2004/04/08 20:46:42 $

error(nargchk(2,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a NUMERIC Handle.');
end
if nargin==2,   
    data = index;
end

if isempty(data),
	warning(generateccsmsgid('InvalidInput'),'DATA must be numeric or hexadecimal format. ');
	return;
end

if iscellstr(data) || ischar(data),
	if nargin == 2, write_numerichex(nn,data);
	else            write_numerichex(nn,index,data);
	end
    
elseif isnumeric(data),
	if nargin == 2, write_numeric(nn,data);
	else            write_numeric(nn,index,data);
	end
    
else
    error(generateccsmsgid('InvalidInput'),'DATA must be a numeric array or a hexadecimal string (cell array) ');
end

% [EOF] write.m