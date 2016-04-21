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
%   See also WRITE, READ.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/11/30 23:10:16 $

error(nargchk(2,3,nargin));
if ~ishandle(mm),
    error('First Parameter must be a NUMERIC Handle.');
end
if nargin==2,   
    data = index;
    index = []; % this is taken cared of in write_numerichex
end
if isempty(data),
	warning('DATA must be a binary string or a cell array of binary strings ');
	return;
end

% Convert strings/cell array into hexadecimal
if ischar(data),   % Data is a cell array of hexidecimal (value sized)
    try 
        data = ConvertBinDataToHex(data);
    catch
        error(sprintf('%s\n%s', lasterr, 'DATA must contain valid binary characters '));        
    end
   
elseif iscellstr(data)
    msize = prod(size(data));
    try
        for i=1:msize,
            data{i} = ConvertBinDataToHex(data{i});
        end
    catch
        error(sprintf('%s\n%s', lasterr, 'DATA must contain valid binary characters '));        
    end
else
    error('DATA must be a binary string or a cell array of binary strings');
end

if nargin==2,
    write_numerichex(mm,data);
else % index version - one value only!
    write_numerichex(mm,index,data);
end

%-----------------------------------------------------
function data = ConvertBinDataToHex(data)
idx = find(data=='1');
data = data(idx:end);
if length(data)<=50,
    data = [dec2hex(bin2dec(data))];
else  
    % if too long - converting data to dec to hex will result to incorrect conversion - bin2dec limitation
    % therefore, split into 2 and then concatenate
    data = [ConvertBinDataToHex(data(1:end-32)) , dec2hex(bin2dec(data(end-31:end)),8)];
end
if isempty(data)
    data = '0';
end

% [EOF] writebin.m