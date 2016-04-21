function mm54regwrite(cc,mmr,data,represent,timeout)
% MM54REGWRITE (Private)
% Writes DATA into the TMS320C54x memory-mapped register MMR

% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2004/04/01 16:02:33 $


mmr = upper(mmr);
represent = upper(represent);

% Check Validity of inputs
CheckInputs(mmr,represent);

% Do not map register-represention to memory-representation on 
% special registers (non 16-bit regs) right away
if isempty(strmatch((mmr),{'A','B','AG','BG','PC','XPC'},'exact'))
   data = GetDataFromRepresent(mmr,data,represent);
end

switch (mmr)
    case 'AR0'
        % % addr = {'10' '1'};
        addr = [16 1];
        write(cc,addr,data,timeout);
    case 'AR1'
        % % cc,addr = {'11' '1'};
        addr = [17 1];
        write(cc,addr,data,timeout);
    case 'AR2'
        % addr = {'12' '1'};
        addr = [18 1];
        write(cc,addr,data,timeout);
    case 'AR3'
        % addr = {'13' '1'};
        addr = [19 1];
        write(cc,addr,data,timeout);
    case 'AR4'
        % addr = {'14' '1'};
        addr = [20 1];
        write(cc,addr,data,timeout);
    case 'AR5'
        % addr = {'15' '1'};
        addr = [21 1];
        write(cc,addr,data,timeout);
    case 'AR6'
        % addr = {'16' '1'};
        addr = [22 1];
        write(cc,addr,data,timeout);
    case 'AR7'
        % addr = {'17' '1'};
        addr = [23 1];
        write(cc,addr,data,timeout);
    case 'A',
        WriteAccumulator(cc,data,'A',[8 9],represent,timeout);
    case 'AL'
        % addr = {'8' '1'};
        addr = [8 1];
        write(cc,addr,data,timeout);
    case 'AH'
        % addr = {'9' '1'};
        addr = [9 1];
        write(cc,addr,data,timeout);
    case 'AG'
        % addr = {'A' '1'};
        addr = [10 1];    
        Write8BitGuardReg(cc,data,'AG',addr,represent,timeout);
    case 'B'
        WriteAccumulator(cc,data,'A',[11 12],represent,timeout);
    case 'BL'
        % addr = {'B' '1'};
        addr = [11 1];
        write(cc,addr,data,timeout);
    case 'BH'
        % addr = {'C' '1'};
        addr = [12 1];
        write(cc,addr,data,timeout);
    case 'BG'
        % addr = {'D' '1'};
        addr = [13 1];
        Write8BitGuardReg(cc,data,'BG',addr,represent,timeout);
    case {'T','TREG'}
        % addr = {'E' '1'};
        addr = [14 1];
        write(cc,addr,data,timeout);
    case 'TRN'
        % addr = {'F' '1'};
        addr = [15 1];
        write(cc,addr,data,timeout);
    case 'ST0'
        % addr = {'6' '1'};
        addr = [6 1];
        write(cc,addr,data,timeout);
    case 'ST1'
        % addr = {'7' '1'};
        addr = [7 1];
        write(cc,addr,data,timeout);
    case 'SP'
        % addr = {'18' '1'};
        addr = [24 1];
        write(cc,addr,data,timeout);
    case 'BK'
        % addr = {'19' '1'};
        addr = [25 1];
        write(cc,addr,data,timeout);
    case 'BRC'
        % addr = {'1A' '1'};
        addr = [26 1];
        write(cc,addr,data,timeout);
    case 'RSA'
        % addr = {'1B' '1'};
        addr = [27 1];
        write(cc,addr,data,timeout);
    case 'REA'
        % addr = {'1C' '1'};
        addr = [28 1];
        write(cc,addr,data,timeout);
    case 'PMST'
        % addr = {'1D' '1'};
        addr = [29 1];
        write(cc,addr,data,timeout);
    case 'XPC'
        % addr = {'1E' '1'};
        addr = [30 1];
        Write8BitGuardReg(cc,data,'XPC',addr,represent,timeout);
    case 'PC'
        %Temporary hack for a TI bug, see geck 139894
        WritePC(cc,data,represent,timeout);
end


% % ---------------------------------
function Write8BitGuardReg(cc,data,acc,addr,represent,timeout)
%truncate if data is hex
if ischar(data) 
    if length(data) > 2
        data = TruncateUpToN(data,2);
        warning(['Input data was truncated when writing to register ''' (acc) ''' ']);
    end
    data = hex2dec(data);
end

if strcmp(represent,'BINARY')   
    write(cc,addr,uint8(data),timeout);
elseif strcmp(represent,'2SCOMP')
    write(cc,addr,int8(data),timeout);
elseif strcmp(represent,'IEEE')
    error(['Input data cannot be written in IEEE format on less than 32 bit registers: ' acc ]);
end

%---------------------------------------------
function WriteAccumulator(cc,data,acc,address,represent,timeout)
% Write to 32-bit accummulator (XL, XH)

addrLo = address(1); % XH
addrHi = address(2); % XL

%truncate if data is hex
if ischar(data) 
    if length(data) > 8
        data = TruncateUpToN(data,8);
        warning(['Input data was truncated when writing to register ''' (acc) ''' ']);
    end
    data = hex2dec(data);
end

if strcmp(represent,'BINARY')
    MaxData = 2^32 - 1;
    if data > MaxData
        warning(['Saturation occurred when writing to register ''' (acc) ''' ']);
    end
    data = uint32(data);
    data_str = dec2hex(double(data),round(32/4));
    
elseif strcmp(represent,'2SCOMP')
    MaxData = 2^31 - 1;    
    MinData = -2^31;
    if (data > MaxData) || (data < MinData)
        warning(['Saturation occurred when writing to register ''' (acc) ''' ']);
    end
    
    if data >= 0
        data = int32(data);
        data_str = dec2hex(double(data),round(32/4));
        
    else %negative
        pos = double(data) - (-2^31);
        % if data < -2^31, just saturate by setting data = -2^31
        if pos < 0 
            pos = 0;
        end
        % convert to bin with 31 characters & prepend neg bit after 
        data_str = dec2hex(bin2dec(horzcat('1',dec2bin(pos,31))),round(32/4)); 
    end
    
elseif strcmp(represent,'IEEE')
    hex = sprintf('%tX',double(data));
    dataH = uint16( hex2dec( hex(1:4)   ) );
    dataL = uint16( hex2dec( hex(5:end) ) );
    write(cc,[addrLo 1],uint16(dataL),timeout);
    write(cc,[addrHi 1],uint16(dataH),timeout);
    return; %done
end

dataH = uint16( hex2dec( data_str(1:4)   ) ); 
dataL = uint16( hex2dec( data_str(5:end) ) );

write(cc,[addrLo 1],uint16(dataL),timeout);
write(cc,[addrHi 1],uint16(dataH),timeout);

%----------------------------------------
function data = GetDataFromRepresent(mmr,data,represent)

% truncate if data is hex
if ischar(data) 
    if length(data) > 4
        data = TruncateUpToN(data,4);
        warning(['Input data was truncated when writing to register ''' (mmr) ''' ']);
    end
    data = hex2dec(data);
end

if strcmpi(represent,'BINARY')
    MaxData = 2^16 - 1;
    if data > MaxData
        warning(['Saturation occurred when writing to register ''' (mmr) ''' ']);
    end
    data = uint16(data);
elseif strcmpi(represent,'2SCOMP')
    MaxData = 2^15 - 1;    
    MinData = -2^15;
    if (data > MaxData) || (data < MinData)
        warning(['Saturation occurred when writing to register ''' (mmr) ''' ']);
    end
    data = int16(data);   
elseif strcmpi(represent,'IEEE')
    error(['Input data cannot be written in IEEE format on less than 32 bit registers: ' (mmr) ]);
end
%---------------------------------------
function WritePC(cc,data,represent,timeout)
% no mapping in memory
absmaxaddress = 2^23 - 1;
if ischar(data)
    data = hex2dec(data);
end
if data>absmaxaddress
    error('Address exceeds available memory space.');
end
if strcmp(represent,'IEEE')
    error(['Input data cannot be written in IEEE format on less than 32 bit registers: ' 'PC' ]);
end
callSwitchyard(cc.ccsversion,[54 cc.boardnum cc.procnum timeout cc.eventwaitms],['PC=' num2str(double(data))]); 

% Gecked to TI
% % no mapping in memory
% absmaxaddress = 2^23 - 1;
% dataPC = uint16(data);
% dataXPC = double(data) - double(uint16(data));
% if ischar(data)
%     data = [num2str(zeros(1,6-length(data))) data]; %pad zeros
%     dataPC = hex2dec(TruncateUpToN(data,4));
%     dataXPC = hex2dec(data(end-5:1:end-4));
%     data = hex2dec(data);
% end
% if data>absmaxaddress
%     error('Address exceeds available memory space.');
% end
% if any(strcmp(represent,{'IEEE','2SCOMP'}))
%     error(['Input data can only be represented in BINARY on register ''PC'' on the ''C54x. ']);
% end
% % This is a temporary fix to a bug in TI's API
% % callSwitchyard(cc.ccsversion,[54 cc.boardnum cc.procnum timeout cc.eventwaitms],['PC=' num2str(double(data))]); 
% callSwitchyard(cc.ccsversion,[26 cc.boardnum cc.procnum timeout cc.eventwaitms],'PC',uint16(dataPC),lower(represent));
% Write8BitGuardReg(cc,dataXPC,'XPC',[30 1],represent,timeout);
%------------------------------------
function CheckInputs(mmr,represent)
DataTypes = {'BINARY','2SCOMP','IEEE'};
SupportedRegisters = { ...
        'A','AL','AH','AG','B','BL','BH','BG',...           % accumulators
        'AR0','AR1','AR2','AR3','AR4','AR5','AR6','AR7',... % auxillary registers
        'T','TREG','TRN',...    % temporary & transition registers
        'SP',...                % Stack pointer
        'BK',...                % circular-buffer register
        'REA','BRC','RSA',...   % block-repeat registers
        'PC','XPC' ...          % PC registers
	};
statusRegisters = { ...
        'ST0' ,... % Status register 0, 16 bits
		'ST1' ,... % Status register 1, 16 bits
        'PMST' ... % Processor-mode status register
    };

if ~ischar(mmr),
    error('??? RegWrite: Second parameter must be a string.');
end
if ~ischar(represent),
    error('??? RegWrite: Third parameter must be a string.');
end
if ~isempty(findstr(':',mmr))
    error('??? RegWrite: Writing to register pairs is not supported on C5400.');
end
if ~isempty(strmatch((mmr),statusRegisters,'exact'))
    errid = ['MATLAB:CCSDSP:' mfilename '_m:StatusRegsNotSupported'];
    error(errid,['??? RegWrite: Value of status register ''' mmr ''' cannot be overwritten.']);
end
if isempty(strmatch((mmr),SupportedRegisters,'exact'))
    error(['??? RegWrite: Register ''' mmr ''' is not a supported register on C5400.']);
end
if isempty(strmatch((represent),DataTypes,'exact'))
    error(['??? RegWrite: Representation ''' represent ''' is not supported. Representation must be ''binary'', ''2scomp'', or ''ieee''.']);
end

%-----------------------------------
function data = TruncateUpToN(data,N)
data = data(end-N+1:1:end);

% [EOF] mm54regwrite.m