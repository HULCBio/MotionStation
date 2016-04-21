function [symbolAddr,isemptyaddr] = p_getSymbolAddress(cc,symb,default)
% P_GETSYMBOLADDRESS (Private) Returns the address of the specified symbol.
% If the symbol's address cannot be determined, a default value, specified
% by the user, is assigned to it.
%   [symbolAddr,isemptyaddr] = p_getSymbolAddress(cc,'main',[])
%     symbolAddr =
%         32     0
%     isemptyaddr =
%          0
%   [symbolAddr,isemptyaddr] = p_getSymbolAddress(cc,'exit',[])
%     symbolAddr =
%          []
%     isemptyaddr =
%          1

%   Copyright 2004 The MathWorks, Inc.

error(nargchk(3,3,nargin));
warnstate = warning('off');
isemptyaddr = false;
[lastwarnmsg,lastwarnmsgid] = lastwarn('');
try
    symbolAddr = address(cc,symb);
    if strfind(['Address: Failed to locate symbol ''' symb ''' in symbol table'],lastwarn)
        [symbolAddr,isemptyaddr] = getDefaultAddress(default);
    else
        lastwarn(lastwarnmsg,lastwarnmsgid); % reset lastwarn if no warning has been thrown
    end
catch
    [symbolAddr,isemptyaddr] = getDefaultAddress(default);
end
warning(warnstate);

%--------------------------------------------------------------------------
function [addr,isemptyaddr] = getDefaultAddress(default)
addr = default;
if isempty(default)
    isemptyaddr = true;
else
    isemptyaddr = false;
end

% [EOF] p_getSymbolAddress.m