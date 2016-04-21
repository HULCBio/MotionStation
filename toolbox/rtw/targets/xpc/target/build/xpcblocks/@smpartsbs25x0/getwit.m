function IWIT = getwit(S,INX)
% GETWIT  Convert's User-defined WIT option to an internal table of WIT
% entries. 
%   GETWIT(S)  - Returns a single WIT Table which combines entries from all
%    segments and partitions.  
%
% See also SMPARTSBS25X0

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/06 00:32:07 $
IWIT = [];
for inxS = 1:numel(S),  % Number of partitions
    PAddress = get(S(inxS),'IAddress');    
    for inxE = 1:numseg(S(inxS)),  % Number of segments
        witopt = S(inxS).WIT{inxE};
        if strcmp(witopt,'off'),
        elseif strcmp(witopt,'first'),
            IWIT = vertcat(IWIT,witconvert(PAddress(inxE)));
        elseif strcmp(witopt,'last'),
            IWIT = vertcat(IWIT,witconvert(PAddress(inxE),sizeof(S(inxS),inxE)-1));                
        elseif strcmp(witopt,'all'),
            firstaddr = PAddress(inxE);
            lastaddr = PAddress(inxE)+sizeof(S(inxS),inxE)-1;
            wtable = witconvert(firstaddr);
            firstaddr = firstaddr+1;
            for naddr = firstaddr:lastaddr,
                nextentry = witconvert(naddr);
                if nextentry(2) ~= wtable(end,2),  % Different address
                    wtable = [wtable; nextentry];                
                elseif ~bitand(nextentry(1),wtable(end,1)), %Different bits (append)
                    wtable(end,1) = bitor(wtable(end,1),nextentry(1));
                end
            end
            IWIT= vertcat(IWIT,wtable);
        else
            error('Invalid value for field WIT.  Valid options: ''off'',''first'',''last'',''all''');
        end
    end
end
%--------------------------------------------------
% Combine and order me (if there is anything to order)
%
if ~isempty(IWIT),
    IWITSORTED = sortrows(IWIT,2);
    IWIT = [];
    inxE = 1;
    isdone = boolean(0);
    while (~isdone) && (inxE <= size(IWITSORTED,1));
        IWIT = vertcat(IWIT,IWITSORTED(inxE,:));
        inxE = inxE +1;
        for inxT = inxE:size(IWITSORTED,1),
            if IWIT(end,2) == IWITSORTED(inxT,2),  % Same address???
                IWIT(end,1) = bitor(IWIT(end,1),IWITSORTED(inxT,1));
                if inxT == size(IWITSORTED,1),  % Last entry was combined, we're done
                    isdone = boolean(1);
                end
            else
                break;
            end
        end
        if isempty(inxT),  % Single entry is caught here
            isdone =  boolean(1);
        else
           inxE = inxT;
        end
    end
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
