function resp = mm54regread(cc,mmr,represent,timeout)
% MM54REGREAD (Private)
% Reads the contents of a TMS320C54x memory-mapped register specified by MMR.

% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/01 16:02:32 $


mmr = upper(mmr);
represent = upper(represent);

% Check Validity of inputs
CheckInputs(mmr,represent);

% Do not map register-represention to memory-representation on 
% special registers (non 16-bit regs) right away
if isempty(strmatch((mmr),{'A','B','AG','BG','XPC','PC'},'exact'))
    represent = Get16BitRepresent(mmr,represent);
end

switch (mmr)
    case 'AR0'
        % % addr = {'10' '1'};
        addr = [16 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AR1'
        % % cc,addr = {'11' '1'};
        addr = [17 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AR2'
        % addr = {'12' '1'};
        addr = [18 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AR3'
        % addr = {'13' '1'};
        addr = [19 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AR4'
        % addr = {'14' '1'};
        addr = [20 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AR5'
        % addr = {'15' '1'};
        addr = [21 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AR6'
        % addr = {'16' '1'};
        addr = [22 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AR7'
        % addr = {'17' '1'};
        addr = [23 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'A',
        resp = ReadAccumulator(cc,'A',[8 9],represent,timeout);
    case 'AL'
        % addr = {'8' '1'};
        addr = [8 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AH'
        % addr = {'9' '1'};
        addr = [9 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AG'
        % addr = {'A' '1'};
        addr = [10 1];    
        resp = Read8BitGuardReg(cc,'AG',addr,represent,timeout);
    case 'B'
        resp = ReadAccumulator(cc,'A',[11 12],represent,timeout);
    case 'BL'
        % addr = {'B' '1'};
        addr = [11 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'BH'
        % addr = {'C' '1'};
        addr = [12 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'BG'
        % addr = {'D' '1'};
        addr = [13 1];
        resp = Read8BitGuardReg(cc,'BG',addr,represent,timeout);
    case {'T','TREG'}
        % addr = {'E' '1'};
        addr = [14 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'TRN'
        % addr = {'F' '1'};
        addr = [15 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'ST0'
        % addr = {'6' '1'};
        addr = [6 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'ST1'
        % addr = {'7' '1'};
        addr = [7 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'SP'
        % addr = {'18' '1'};
        addr = [24 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'BK'
        % addr = {'19' '1'};
        addr = [25 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'BRC'
        % addr = {'1A' '1'};
        addr = [26 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'RSA'
        % addr = {'1B' '1'};
        addr = [27 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'REA'
        % addr = {'1C' '1'};
        addr = [28 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'PMST'
        % addr = {'1D' '1'};
        addr = [29 1];
        resp = read(cc,addr,represent,1,timeout);     
    case 'XPC'
        % addr = {'1E' '1'};
        addr = [30 1];
        resp = Read8BitGuardReg(cc,'XPC',addr,represent,timeout);
end
resp = double(resp);


%-------------------------------
function resp = ReadAccumulator(cc,acc,address,represent,timeout)
% Read 32-bit accumulator (AL,AH); 

AddrLow   = address(1);
AddrHigh  = address(2);
raw(1) = double( read(cc,[AddrLow   1],'uint16',1,timeout) );
raw(2) = double( read(cc,[AddrHigh  1],'uint16',1,timeout) ) * 2^16;

if strcmpi(represent,'BINARY')
    resp    = sum(raw);
    
elseif strcmpi(represent,'2SCOMP')
    ndx = 32;
    resp = sum(raw);
    bin = dec2bin(resp,ndx) - '0';
    resp = (-1*bin(1)*(2^(ndx-1))) + (bin(2:ndx) * (2 .^ [ndx-2:-1:0])');
    
elseif strcmpi(represent,'IEEE')
    warning(['IEEE format only uses ' acc 'L and ' acc 'H (single precision)']);
    bin = dec2bin(raw(1)+raw(2));
    resp = bin2float(bin);
    
end

%--------------------------------------
function represent = Get16BitRepresent(mmr,represent)

if strcmpi(represent,'BINARY')
    represent= 'uint16';
elseif strcmpi(represent,'2SCOMP')
    represent= 'int16';
elseif strcmpi(represent,'IEEE')
    error(['Contents of Register ''' (mmr) ''' cannot be represented in IEEE format']);
end

%--------------------------------------------
function resp = Read8BitGuardReg(cc,acc,address,represent,timeout);

if strcmpi(represent,'BINARY')
    represent= 'uint8';
elseif strcmpi(represent,'2SCOMP')
    represent= 'int8';
elseif strcmpi(represent,'IEEE')
    error(['Register ' acc ' cannot be represented in IEEE format']);
end
resp = read(cc,address,represent,1,timeout);

%-------------------------------------------
function CheckInputs(mmr,represent)

DataTypes = {'BINARY','2SCOMP','IEEE'};

SupportedRegisters = {'A','AL','AH','AG','B','BL','BH','BG',...
        'AR0','AR1','AR2','AR3','AR4','AR5','AR6','AR7',...
        'T','TREG','TRN','ST0','ST1','SP','BK','BRC','RSA',...
        'REA','PMST','PC','XPC'};

if ~ischar(mmr),
    error('??? RegRead: Second parameter must be a string.');
end
if ~ischar(represent),
    error('??? RegRead: Third parameter must be a string.');
end
if ~isempty(findstr(':',mmr))
    error('??? RegRead: Reading from register pairs is not supported on C5400.');
end
if isempty(strmatch((mmr),SupportedRegisters,'exact'))
    error(['??? RegRead: Register ''' mmr ''' is not a supported register on C5400.']);
end
if isempty(strmatch((represent),DataTypes,'exact'))
    error(['??? RegRead: Representation ''' represent ''' is not supported. Representation must be ''binary'', ''2scomp'', or ''ieee''.']);
end
%-------------------------------------------

% [EOF] mm54regread.m