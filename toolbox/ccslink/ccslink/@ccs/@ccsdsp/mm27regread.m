function resp = mm27regread(cc,regname,represent,timeout)
% MM27REGREAD (Private) Reads data from a TMS320C27x register.

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:02:28 $

regname = upper(regname);
represent = lower(represent);

% Special case: 22-bit registers
bit22regs = {'PC','IC','XAR6','XAR7'};

if ~isempty(findstr(':',regname))
    errid = generateccsmsgid('RegPairNotSupported');
    error(errid,'??? RegRead: Reading from register pairs is not supported on C2700.');
end

try
    if isempty(strmatch(regname,bit22regs,'exact'))
        % 16-bit and 32-bit registers
        resp=callSwitchyard(cc.ccsversion,[25 cc.boardnum cc.procnum timeout cc.eventwaitms],regname,represent);
    else
        % 22-bit registers
        resp=callSwitchyard(cc.ccsversion,[25 cc.boardnum cc.procnum timeout cc.eventwaitms],regname,'binary');
        resp = Convert32BitValTo22Bit2scompVal(resp,represent);
    end
catch
    ThrowError(lasterr,regname);
end
    
%----------------------------------------
function resp = Convert32BitValTo22Bit2scompVal(resp,represent)
% Convert 22-bit binary number into its 2scomp representation
if strcmp(represent,'2scomp')
    respbin = dec2bin(resp,22);
    if length(respbin)>22 % truncate, sometimes necessary since switchyard reads this 
                          % reg as a 32-bit value instead as a correct 22-bit value
		respbin = respbin(end-21:end);
    end
    if respbin(1)=='1' % msbit=1, must be converted to negative counterpart
        resp = -2^21 + [respbin(2:end)-'0'] * [2.^(20:-1:0)'];
    end
end
%----------------------------------------
function ThrowError(errmsg,regname)
if ~isempty(findstr(errmsg,'Invalid Register name'))
    errid = generateccsmsgid('RegNotSupported');
    error(errid,['??? RegRead: Register ''' regname ''' is not a supported register on C2700.']);
else
    errid = generateccsmsgid('RegReadException');
    error(errid,errmsg);
end

% [EOF] mm27regread.m