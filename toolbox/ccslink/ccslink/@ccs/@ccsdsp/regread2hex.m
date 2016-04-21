function resp = regread2hex(cc,regname,represent,timeout)
%REGREAD2HEX Returns the data value in the specified DSP register in
%   hexadecimal format.
%
%   See also REGREAD.
%   Copyright 2002-2003 The MathWorks, Inc.
%
%   $Revision: 1.4.4.1 $  $Date: 2003/11/30 23:07:32 $

error(nargchk(2,4,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error('First Parameter must be a CCSDSP Handle.');
end
if nargin==2
    represent = 'binary';
end
if nargin==4
    val = regread(cc,regname,'binary',timeout);
else
    val = regread(cc,regname,'binary');
end
resp = dec2hex(val);

% In C54x, show only 32-bit equivalent
if cc.subfamily==84 & strcmpi(represent,'ieee') & ...
   ~isempty(strmatch(upper(regname),{'A','B'},'exact')), 
    resp = dec2hex(val,10);
    resp = resp(3:end); % remove guard bits
end

% [EOF] regread2hex.m
