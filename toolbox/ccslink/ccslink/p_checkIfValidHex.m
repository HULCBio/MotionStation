function p_checkIfValidHex(h)
% P_CHECKIFVALIDHEX(STR) Checks if a string contains invalid hexadecimal
% characters. This function throws an error if invalid characters are
% detected.

% Copyright 2004 The MathWorks, Inc.

error(nargchk(1,1,nargin));

h = upper(h);
if any(any(~((h>='0' & h<='9') | (h>='A'& h<='F'))))
    error(generateccsmsgid('InvalidHexAddress'),...
        'The hexadecimal address you entered contains invalid characters.');
end

% [EOF] p_checkIfValidHex.