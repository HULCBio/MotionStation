function mm24regwrite(cc,regname,data,represent,timeout)
% MM24REGWRITW (Private) Writes data into a TMS320C24x register.
% Some TMS320C24x registers are memory-mapped: IMR, GREG, IFR

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:02:27 $

regname = upper(regname);
represent = lower(represent);

% Memory-mapped registers (0x0000-0x007F)
mmregs = {'IMR','GREG','IFR'};

if ~isempty(findstr(':',regname))
    errid = generateccsmsgid('RegPairNotSupported');
    error(errid,'??? RegWrite: Writing to register pairs is not supported on C2400.');
end

if isempty(strmatch(regname,mmregs,'exact'))
    % Physical registers
    try
        if ischar(data)
            data = hex2dec(data);
        end
        callSwitchyard(cc.ccsversion,[26 cc.boardnum cc.procnum timeout cc.eventwaitms],regname,data,represent);
    catch
        ThrowError(lasterr,regname);
    end
else
    % Memory-mapped registers
    if strcmp(regname,'IMR')
        data = Get16BitData(regname,represent,data);
        addr = [4 1]; % address 0004h in data memory space
    elseif strcmp(regname,'GREG')
        data = Get8BitData(regname,represent,data);
        addr = [5 1]; % address 0005h in data memory space
    elseif strcmp(regname,'IFR')
        data = Get16BitData(regname,represent,data);
        addr = [6 1]; % address 0006h in data memory space
    end
    write(cc,addr,data,timeout);
    
end

%--------------------------------------
function data = Get16BitData(regname,represent,data)
if ischar(data)
    data = hex2dec(data);
end
if strcmp(represent,'binary')
    data = uint16(data);
elseif strcmp(represent,'2scomp')
    data = int16(data);
elseif strcmp(represent,'ieee')
    error(['Input data cannot be written in IEEE format on a non-32 bit register: ' regname]);
end
%--------------------------------------
function data = Get8BitData(regname,represent,data)
if ischar(data)
    data = hex2dec(data);
end
if strcmp(represent,'binary')
    data = uint8(data);
elseif strcmp(represent,'2scomp')
    data = int8(data);
elseif strcmp(represent,'ieee')
    error(['Input data cannot be written in IEEE format on a non-32 bit register: ' regname]);
end

%----------------------------------------
function ThrowError(errmsg,regname)
if ~isempty(findstr(errmsg,'Invalid Register name'))
    errid = generateccsmsgid('RegNotSupported');
    error(errid,['??? RegWrite: Register ''' regname ''' is not a supported register on C2400.']);
else
    errid = generateccsmsgid('RegWriteException');
    error(errid,errmsg);
end

% [EOF] mm24regwrite.m