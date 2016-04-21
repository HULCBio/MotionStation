function resp = mm24regread(cc,regname,represent,timeout)
% MM24REGREAD (Private) Reads data from a TMS320C24x register.
% Some TMS320C24x registers are memory-mapped: IMR, GREG, IFR

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/01 16:02:26 $

regname = upper(regname);
represent = lower(represent);

% Memory-mapped registers (0x0000-0x007F)
mmregs = {'IMR','GREG','IFR'};

if ~isempty(findstr(':',regname))
    errid = generateccsmsgid('RegPairNotSupported');
    error(errid,'??? RegRead: Reading from register pairs is not supported on C2400.');
end
 
if isempty(strmatch(regname,mmregs,'exact'))
    % Physical registers
    try
        resp=callSwitchyard(cc.ccsversion,[25 cc.boardnum cc.procnum timeout cc.eventwaitms],regname,represent);
    catch
        ThrowError(lasterr,regname);
    end
else
    % Memory-mapped registers
    if strcmp(regname,'IMR')
        represent = Get16BitRepresent(regname,represent);
        addr = [4 1]; % address 0004h in data memory space
    elseif strcmp(regname,'GREG')
        represent = Get8BitRepresent(regname,represent);
        addr = [5 1]; % address 0005h in data memory space
    elseif strcmp(regname,'IFR')
        represent = Get16BitRepresent(regname,represent);
        addr = [6 1]; % address 0006h in data memory space
    end
    resp = double(read(cc,addr,represent,1,timeout));
end

%--------------------------------------
function represent = Get16BitRepresent(mmr,represent)
if strcmp(represent,'binary')
    represent= 'uint16';
elseif strcmp(represent,'2scomp')
    represent= 'int16';
elseif strcmp(represent,'ieee')
    error(['Contents of register ''' (mmr) ''' cannot be represented in IEEE format.']);
end

%--------------------------------------
function represent = Get8BitRepresent(mmr,represent)
if strcmp(represent,'binary')
    represent= 'uint8';
elseif strcmp(represent,'2scomp')
    represent= 'int8';
elseif strcmp(represent,'ieee')
    error(['Contents of register ''' (mmr) ''' cannot be represented in IEEE format.']);
end

%----------------------------------------
function ThrowError(errmsg,regname)
if ~isempty(findstr(errmsg,'Invalid Register name'))
    errid = generateccsmsgid('RegNotSupported');
    error(errid,['??? RegRead: Register ''' regname ''' is not a supported register on C2400.']);
else
    errid = generateccsmsgid('RegReadException');
    error(errid,errmsg);
end

% [EOF] mm24regread.m