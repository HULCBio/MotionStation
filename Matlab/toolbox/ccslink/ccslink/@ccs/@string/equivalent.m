function sym_out = equivalent(str,sym_in)
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2003/11/30 23:12:53 $

nargchk(2,2,nargin);
if ~ishandle(str),
    errid = ['MATLAB:STRING:' mfilename '_m:InvalidHandle'];
    error(errid,'First Parameter must be a STRING Handle.');
end
if ischar(sym_in)
    sym_out = ConvertFromChar_ASCII(sym_in);
elseif isnumeric(sym_in)
    sym_out = ConvertFromNumeric_ASCII(sym_in);
else
    errid = ['MATLAB:STRING:' mfilename '_m:ParameterMustBeStringOrNumeric'];
    error(errid,'Second Parameter must be a character or numeric');
end

%---------------------------------------
function out = ConvertFromChar_ASCII(in)
try 
    out = double(in);
catch
    errid = ['MATLAB:STRING:' mfilename '_m:CannotConvert2NumericArray'];
    error(errid,'Cannot convert to a numeric array');
end
if any(out<0)
    warnid = ['MATLAB:STRING:' mfilename '_m:DataIsSaturated2Min'];
    warning(warnid,'The equivalent has element(s) less than 0, it will be set to the valid minimum value.');
    out([find(out<0)]) = 0;
end
if any(out>127),
    warnid = ['MATLAB:STRING:' mfilename '_m:DataIsSaturated2Max'];
    warning(warnid,'The equivalent has element(s) greater than 127, it will be set to the valid maximum value.');
    out([find(out>127)]) = 127;
end

%---------------------------------------
function out = ConvertFromNumeric_ASCII(in)

if any(in<0)
    warnid = ['MATLAB:STRING:' mfilename '_m:DataIsSaturated2Min'];
    warning(warnid,'The equivalent has element(s) less than 0, it will be set to the valid minimum value.');
    in([find(in<0)]) = 0;
end
if any(in>127),
    warnid = ['MATLAB:STRING:' mfilename '_m:DataIsSaturated2Max'];
    warning(warnid,'The equivalent has element(s) greater than 127, it will be set to the valid maximum value.');
    in([find(in>127)]) = 127;
end

try 
    out = char(in);
catch
    errid = ['MATLAB:STRING:' mfilename '_m:CannotConvert2CharArray'];
    error(errid,'Cannot convert to a character array');
end

% [EOF] equivalent.m