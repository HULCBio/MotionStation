function sym_out = equivalent(str,sym_in)
%   Copyright 2002-2003 The MathWorks, Inc.

nargchk(2,2,nargin);
if ~ishandle(str),
    error('First Parameter must be a RSTRING Handle.');
end
if ischar(sym_in)
    sym_out = ConvertFromChar_ASCII(sym_in);
elseif isnumeric(sym_in)
    sym_out = ConvertFromNumeric_ASCII(sym_in);
else
    error('Second Parameter must be a character or numeric');
end

%---------------------------------------
function out = ConvertFromChar_ASCII(in)
try 
    out = double(in);
catch
    error('Cannot convert to a numeric array');
end
if any(out<0)
    warning('The equivalent has element(s) less than 0, it will be set to the valid minimum value.');
    out([find(out<0)]) = 0;
end
if any(out>127),
    warning('The equivalent has element(s) greater than 127, it will be set to the valid maximum value.');
    out([find(out>127)]) = 127;
end

%---------------------------------------
function out = ConvertFromNumeric_ASCII(in)

if any(in<0)
    warning('The equivalent has element(s) less than 0, it will be set to the valid minimum value.');
    in([find(in<0)]) = 0;
end
if any(in>127),
    warning('The equivalent has element(s) greater than 127, it will be set to the valid maximum value.');
    in([find(in>127)]) = 127;
end

try 
    out = char(in);
catch
    error('Cannot convert to a character array');
end

% [EOF] equivalent.m