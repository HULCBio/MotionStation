function dummy = writebin(mm,index,data)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:11:52 $

error(nargchk(2,3,nargin));
if ~ishandle(mm),
    error('First Parameter must be a RNUMERIC Handle.');
end
if nargin==2,   
    data  = index;   
    index = [];
elseif nargin==3 && isempty(index),
    index = ones(1,length(nn.size));
end

% Convert strings/cell array into hexadecimal
if ischar(data),   % Data is a cell array of hexidecimal (value sized)
    try 
        data = ConvertBinDataToHex(data);
    catch
        error(sprintf('%s\n%s', lasterr, 'DATA must contain valid binary characters. '));        
    end
   
elseif iscellstr(data),
    msize = prod(size(data));
    try
        for i=1:msize,
            data{i} = ConvertBinDataToHex(data{i});
        end
    catch
        error(sprintf('%s\n%s', lasterr, 'DATA must contain valid binary characters. '));        
    end
else
    error('DATA must be a binary string or a cell array of binary strings');
end

if nargin==2,
    write_rnumerichex(mm,data);
else % index version - one value only!
    write_rnumerichex(mm,index,data);
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