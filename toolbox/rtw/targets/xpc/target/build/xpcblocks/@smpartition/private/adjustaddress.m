function S = adjustaddress(S)
% ADJUSTADDRESS  Computes address of each segment.
% SA = AdjustAddress(S)  - Modifies the address parameters by starting with
% the first entry and adjusting the rest to reflect the effect of segment
% size and alignment
%
%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:56 $

baseAddresses = base(S);
for inxS = 1:numel(S),
    baseAddress = baseAddresses(inxS);
    unbaseAddress = baseAddress;  % Keep this for a check later
% OLD method - alignment applied to NEXT Address
%     for ix=1:length(S(inxS).Address)-1,
%         xtype = S(inxS).Type{ix};
%         xalignment =  eval([S(inxS).Alignment{ix},';']);
%         xsize = eval([S(inxS).Size{ix},';']);
%         xsegize = type2bytes(S(inxS),xtype); 
% 
%         xbytes= prod(xsize)*xsegize;
%         xbytes= ceil(xbytes/xalignment)*xalignment;
% 
%         baseAddress = baseAddress+xbytes;
%         S(inxS).Address{ix+1} = ['0x' dec2hex(baseAddress)];
%     end

% NEW method - alignment applied to THIS Address
    for ix=1:length(S(inxS).Address),
        xalignment =  S(inxS).Alignment(ix);
        % apply alignment to THIS address
        baseAddress = ceil(baseAddress/xalignment)*xalignment;
        S(inxS).Address(ix) = baseAddress;
        [junk,xsegize] = typeconvert(S,S(inxS).Type(ix));
        xsize = S(inxS).Size(:,ix)';
        xbytes= prod(xsize)*xsegize;
        if xbytes == 0,
            xsize = S(inxS).Size(1,ix);
            xbytes= xsize*xsegize;            
        end
        S(inxS).NBytes(ix) = xbytes; % Worth keeping (used by sizeof)
        baseAddress = baseAddress+xbytes;
    end
    baseAddress = base(S);
    if mod(baseAddress(inxS),4) ~= 0,
        error(['Starting address MUST be aligned to a 32-bit boundary',char(10),...
               '  Consider changing your staring address to : 0x' dec2hex(ceil(baseAddress/4)*4 )]);
    end
    if unbaseAddress ~= baseAddress,
        warning('XPC:SMPartition:BaseChange','Specified Alignment shifted your starting address for Partition Number= %u',inxS)        
    end
end
