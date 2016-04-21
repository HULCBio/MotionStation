function resp = write(re,index,data)
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

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2003/11/30 23:11:09 $

error(nargchk(2,3,nargin));
if ~ishandle(re),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a RENUM handle.');
end
if nargin==2,   
    data = index;
elseif nargin==3 && isempty(index)
    index = 1;
end

if ischar(data) || iscellstr(data),
	if nargin==2,   write_renum(re,data);
	else            write_renum(re,index,data);
	end
	
elseif isnumeric(data),
    CheckIfValid(re.value,data);
	if nargin==2,   write_rnumeric(re,data);
	else            write_rnumeric(re,index,data);
	end

else
    error(generateccsmsgid('InvalidInput'),'Second Parameter must be a numeric or string (enum label)');
end

%-----------------------------
function CheckIfValid(value,data)
siz = size(data);
chk = zeros(siz);
for i=1:length(value)
    chk = chk + (data==value(i));
end
if sumall(chk,length(siz))~=prod(siz)
    warning(generateccsmsgid('InvalidEnumValue'),'Input data contains at least one value that does not match any defined enumerated value.');
end

%----------------------------------
function o = sumall(o,dims)
for i=1:dims
    o = sum(o,i);
end

% [EOF] write.m