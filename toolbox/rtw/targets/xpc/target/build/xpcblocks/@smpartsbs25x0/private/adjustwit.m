function addnum = adjustwit(S,addparam)
% ADJUSTWIT  Convert's User-defined WIT option to an internal table of WIT
% entries
%
% See also SMPARTSBS25X0

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:35:00 $
IWIT = [];
for inxS = 1:numel(S),
   
    for i=1:length(partition),
        tmp = [];
        if strcmp(lower(partition(i).WIT),'off'),
        elseif strcmp(lower(partition(i).WIT),'first'),
            tmp = witconvert(partition(i).Address);
        elseif strcmp(lower(partition(i).WIT),'last'),
            tmp = witconvert(partition(i).Address,widths(i)-1);                
        elseif strcmp(lower(partition(i).WIT),'all'),
            firstaddr = hex2dec(partition(i).Address(3:end));
            lastaddr = firstaddr+widths(i)-1;
            wtable = witconvert(firstaddr);
            firstaddr = firstaddr+1;
            for naddr = firstaddr:lastaddr,
                nextentry = witconvert(naddr);
                if nextentry(2) ~= wtable(end,2),  % Different address
                    wtable = [wtable; nextentry];                
                elseif ~bitand(nextentry(1),wtable(end,1)), %Different bits (append)
                    wtable(end,1) = wtable(end,1)+nextentry(1);
                end
            end
            tmp = wtable;
        else
            error('Invalid value for field WIT.  Valid options: ''off'',''first'',''last'',''all''');
        end
    end
    partition(i).IWIT = tmp;    
end

%--------------------------------------------------
%% Convert a regular address (+offset) into a WIT entry
function witentry = witconvert(address,offset)
% witentry = [bit addr]
if nargin < 2,
    offset = 0;
end
if ischar(address),
    if address(2) == 'x'
        address = hex2dec(address(3:end));
    else
        address = hex2dec(address);
    end
else
    address = round(address);
end
address = address + offset;
%witentry(1) = 2^rem(floor(round(iaddress)/4),8);  % Bit
witentry(1) = 2^(floor((mod(address,32))/4)); %bit
witentry(2) = floor(round(address)/32)*32;           %% Address always multiple of 32
