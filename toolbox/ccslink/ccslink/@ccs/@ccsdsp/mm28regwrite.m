function mm28regwrite(cc,reg,data,represent,timeout)
% MM28REGWRITE (Private) Writes DATA into a TMS320C28x register.
% Note: TMS320C28x registers are not memory-mapped.

% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.5 $  $Date: 2004/04/06 01:04:49 $

reg = upper(reg);
represent = upper(represent);
DataTypes = {'BINARY','2SCOMP','IEEE'};

% Extended Auxiliary Registers
XARn = {'XAR0','XAR1','XAR2','XAR3','XAR4','XAR5','XAR6','XAR7','XT'};
% Auxiliary Registers
ARn = {'AR0','AR1','AR2','AR3','AR4','AR5','AR6','AR7'};

% 16-bit registers
Bit16Regs = { ARn{:}, ...
              'AL','AH','PH','PL','TL','TH',...
              'IER','IFR','DBGIER','ST0','ST1','SP','DP'};
% 32-bit registers
Bit32Regs = { XARn{:},'ACC','P','T'};

% All registers that we support
SupportedRegisters = { Bit32Regs{:}, Bit16Regs{:}, 'PC', 'IC', 'RPC' };


%%%
if ~ischar(reg),
    errid = generateccsmsgid('InputMustBeAString');
    error(errid,'??? RegWrite: Second parameter must be a string.');
end
if ~ischar(represent),
    errid = generateccsmsgid('InputMustBeAString');
    error(errid,'??? RegWrite: Third parameter must be a string.');
end
if ~isempty(findstr(':',reg))
    errid = generateccsmsgid('RegPairNotSupported');
    error(errid,'??? RegWrite: Writing to register pairs is not supported on C2800.');
end

% statusRegisters = {'ST0','ST1'};
% if ~isempty(strmatch((reg),statusRegisters,'exact'))
%     errid = generateccsmsgid('StatusRegsNotSupported');
%     error(errid,['??? RegWrite: Value of status register ''' reg ''' cannot be overwritten.']);
% end

if isempty(strmatch((reg),SupportedRegisters,'exact'))
    errid = generateccsmsgid('RegNotSupported');
    error(errid,['??? RegWrite: Register ''' reg ''' is not a supported register on C2800.']);
end
if isempty(strmatch((represent),DataTypes,'exact'))
    errid = generateccsmsgid('RegwriteRepNotSupported');
    error(errid,['??? RegWrite: Representation ''' represent ''' is not supported. Representation must be ''binary'', ''2scomp'', or ''ieee''.']);
end


% Important: The API does not recognize registers XARn and XT.
% However, the way it works is that, when you're writing to registers
% ARn or T, the API treats it as if you're writing to the 32-bit XARn or
% XT, respectively. One more thing, register 'TH' is another name for 'T'.

if ~isempty(strmatch(reg,{XARn{:}},'exact'))
    reg = reg(2:end);
    Bit32Regs = {Bit32Regs{:}, reg}; % append register to the 32-bit list
elseif ~isempty(strmatch(reg,{'T'},'exact'))
    reg = 'TH';
end
     
switch reg
    case Bit32Regs
        data = GetDataFromRepresent(reg,data,represent,32);
        callSwitchyard(cc.ccsversion,[26 cc.boardnum cc.procnum timeout cc.eventwaitms],reg,data,lower(represent));
        
    case Bit16Regs
        data = GetDataFromRepresent(reg,data,represent,16);
        callSwitchyard(cc.ccsversion,[26 cc.boardnum cc.procnum timeout cc.eventwaitms],reg,data,lower(represent));
        
    case {'PC','IC','RPC'}
        data = CheckAddress(reg,data,represent);
        callSwitchyard(cc.ccsversion,[26 cc.boardnum cc.procnum timeout cc.eventwaitms],reg,data,lower(represent));
end
 
%-------------------------------------------------------------------------
function data = CheckAddress(reg,data,represent);

if ischar(data)
    data = hex2dec(data);
end

% Check against maximum address for the C28X
absmaxaddress = hex2dec('3FFFFF');
if data>absmaxaddress
    error('Address exceeds available memory space.');
end

if ((any(strcmp({'2SCOMP', 'BINARY'},represent))) && data < 0)
    error('Address has to be a positive value.');
elseif strcmpi(represent,'IEEE')
    error(['Input data cannot be written in IEEE format on less than 32 bit registers: ' reg ]);
end

%--------------------------------------------------------------------
function data = GetDataFromRepresent(reg,data,represent,NumberOfBits)
% private.
% Depending on the NumberOfBits and data representation needed, this
% function returns the appropriate data format in decimals.

NumOfChar = ceil(NumberOfBits/4);
%truncate if data is hex
if ischar(data) 
    if length(data) > NumOfChar
        data = TruncateUpToN(data,NumOfChar);
        warning(['Input data was truncated when writing to register ''' reg ''' ']);
    end
    data = hex2dec(data);
end

if strcmp(represent,'BINARY')
    MaxData = 2^NumberOfBits - 1;
    if data > 0
        if data > MaxData
            warning(['Saturation occurred when writing to register ''' reg ''' ']);
            data = MaxData; %saturate
        end
    else %negative
        data = 0;
    end
    
elseif strcmp(represent,'2SCOMP')
    MaxData = 2^(NumberOfBits-1) - 1;    
    MinData = -2^(NumberOfBits-1);
    if data > MaxData 
        warning(['Saturation occurred when writing to register ''' reg ''' ']);
        data = MaxData;
    elseif data < 0 %negative
        if data < MinData
            warning(['Saturation occurred when writing to register ''' reg ''' ']);
            data = MinData;      
        else
            pos = double(data) - (-2^31);
            % convert to bin with 31 characters & prepend neg bit after
            data_str = dec2hex(bin2dec(horzcat('1',dec2bin(pos,31))),round(32/4));
            data = hex2dec(data_str(end-(NumOfChar-1):1:end)); 
        end
    end
    
elseif (strcmp(represent,'IEEE') && NumberOfBits < 32)
    error(['Input data cannot be written in IEEE format on less than 32 bit registers: ' reg ]);
end

%--------------------------------------------------------------------------
function data = TruncateUpToN(data,N)
data = data(end-N+1:1:end);

% [EOF] mm28regwrite.m