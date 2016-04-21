function mm27regwrite(cc,regname,data,represent,timeout)
% MM27REGWRITE (Private) Writes data into a TMS320C27x register.

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:02:29 $

regname = upper(regname);
represent = lower(represent);

if ~isempty(findstr(':',regname))
    errid = generateccsmsgid('RegPairNotSupported');
    error(errid,'??? RegWrite: Writing to register pairs is not supported on C2700.');
end

% Physical registers
try
    if ischar(data)
        data = hex2dec(data);
    end
    callSwitchyard(cc.ccsversion,[26 cc.boardnum cc.procnum timeout cc.eventwaitms],regname,data,represent);
catch
    ThrowError(lasterr,regname);
end

%----------------------------------------
function ThrowError(errmsg,regname)
if ~isempty(findstr(errmsg,'Invalid Register name'))
    errid = generateccsmsgid('RegNotSupported');
    error(errid,['??? RegWrite: Register ''' regname ''' is not a supported register on C2700.']);
else
    errid = generateccsmsgid('RegWriteException');
    error(errid,errmsg);
end

% [EOF] mm27regwrite.m