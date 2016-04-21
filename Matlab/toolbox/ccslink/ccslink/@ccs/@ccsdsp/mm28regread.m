function resp = mm28regread(cc,reg,represent,timeout)
% MM28REGREAD (Private) Reads DATA from a TMS320C28x register.
% Note: TMS320C28x registers are not memory-mapped.

% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.3.6.3 $  $Date: 2004/04/01 16:02:30 $

reg = upper(reg);
represent = upper(represent);
DataTypes = {'BINARY','2SCOMP','IEEE'};

% Extended Auxiliary Registers
XARn = {'XAR0','XAR1','XAR2','XAR3','XAR4','XAR5','XAR6','XAR7','XT'};
% Auxiliary Registers
ARn = {'AR0','AR1','AR2','AR3','AR4','AR5','AR6','AR7','T'};
% 16-bits registers
Bit16Regs = { ARn{:},...
              'AL','AH','PH','PL','TL','TH','T',...
              'IER','IFR','DBGIER','ST0','ST1','SP','DP'};

% All registers that we support
SupportedRegisters = { XARn{:}, Bit16Regs{:}, 'P', 'ACC', 'PC', 'IC', 'RPC' };

% Check if inputs are valid
if ~ischar(reg),
    errid = generateccsmsgid('InputMustBeAString');
    error(errid,'??? RegRead: Second parameter must be a string.');
end
if ~ischar(represent),
    errid = generateccsmsgid('InputMustBeAString');
    error(errid,'??? RegRead: Third parameter must be a string.');
end
if ~isempty(findstr(':',reg))
    errid = generateccsmsgid('RegPairNotSupported');
    error(errid,'??? RegRead: Reading from register pairs is not supported on C2800.');
end

if isempty(strmatch((reg),SupportedRegisters,'exact'))
    errid = generateccsmsgid('RegNotSupported');
    error(errid,['??? RegRead: Register ''' reg ''' is not a supported register on C2800.']);
end
if isempty(strmatch((represent),DataTypes,'exact'))
    errid = generateccsmsgid('RegReadRepNotSupported');
    error(errid,['??? RegRead: Representation ''' represent ''' is not supported. Representation must be ''binary'', ''2scomp'', or ''ieee''.']);
end

% Important: The API does not recognize registers XARn and XT.
% However, the way it works is that, when you're reading from registers
% ARn or T, the API treats it as if you're reading from the 32-bit XARn or
% XT, respectively. 

switch reg
    case XARn
        reg = reg(2:end);
        resp = callSwitchyard(cc.ccsversion,[25 cc.boardnum cc.procnum cc.timeout cc.eventwaitms],reg,lower(represent));
    case ARn
        resp = callSwitchyard(cc.ccsversion,[25 cc.boardnum cc.procnum cc.timeout cc.eventwaitms],reg,lower(represent));
        resp = ConvertToSigned16bits(double(resp),represent,reg);
    case {'PC','RPC','IC'}
        resp = callSwitchyard(cc.ccsversion,[25 cc.boardnum cc.procnum cc.timeout cc.eventwaitms],reg,lower(represent));
    otherwise
        resp = callSwitchyard(cc.ccsversion,[25 cc.boardnum cc.procnum cc.timeout cc.eventwaitms],reg,lower(represent));
end

%-------------------------------------------------------
function resp = ConvertToSigned16bits(resp,represent,reg)
ndx = 16;
if strcmpi(represent,'BINARY')
    bin = dec2bin(resp,ndx) - '0';
    resp = (bin(1:ndx) * (2 .^ [ndx-1:-1:0])');
elseif strcmpi(represent,'2SCOMP')
    pos = resp - (-2^31);
    % convert to bin with 31 characters & prepend neg bit after
    data_str = dec2hex(bin2dec(horzcat('1',dec2bin(pos,31))),round(32/4));
    data = hex2dec(data_str(end-3:1:end)); 
    bin =  dec2bin(data,ndx) - '0';
    resp = (-1*bin(1)*(2^(ndx-1))) + (bin(2:ndx) * (2 .^ [ndx-2:-1:0])');
elseif strcmpi(represent,'IEEE')
    error(['Input data cannot be written in IEEE format on less than 32 bit registers: ' reg ]);
end

% [EOF] mm28regread.m