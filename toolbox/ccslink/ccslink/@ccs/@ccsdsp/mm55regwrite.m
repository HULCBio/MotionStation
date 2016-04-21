function mm55regwrite(cc,mmr,data,represent,timeout)
% MM55REGWRITE (Private)
% Writes DATA into the TMS320C55x memory-mapped register MMR

% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/01 16:02:35 $

mmr = upper(mmr);
represent = upper(represent);

% Check Validity of inputs
CheckInputs(mmr,represent);

% Auxiliary Registers for the c55x (not memory-mapped)
XARn = {'XAR0','XAR1','XAR2','XAR3','XAR4','XAR5','XAR6','XAR7','XCDP'};

% Do not map register-represention to memory-representation on 
% special registers (non 16-bit regs) right away
if ( isempty(strmatch((mmr), {'A','B','AG','BG','AC0','AC1','AC2','AC3','AC0G','AC1G','AC2G','AC3G',...
     'XSP','XSSP','XCDP','RSA0H','RSA1H','REA0H','REA1H','RSA0', 'RSA1', 'REA0', 'REA1','XDP', XARn{:},...
     'DBIER0','DBIER1'},'exact')) ...
     && isempty(findstr(':',mmr)) && ~strcmpi('PC',mmr) ),
    data = GetDataFromRepresent(mmr,data,represent);
end

% Write to Registers
% Note: for the non-extended auxiliary registers(ARn), we do not write
% to the extended part, bits 16-22. We only write to bits 0-15.
switch (mmr)
    case XARn  % Auxiliary registers are Not memory-mapped
        % if necessary, truncate and fix data
        data = CheckandTruncate(data,represent,mmr);
        callSwitchyard(cc.ccsversion,[54 cc.boardnum cc.procnum timeout cc.eventwaitms],[mmr '=' num2str(double(data))]);
    case 'AR0'
        % % addr = {'10' '1'};
        addr = [16 1];
        write(cc,addr,data,timeout);
    case 'AR1'
        % cc,addr = {'11' '1'};
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
        
    case {'AC0' ,'A'}
        WriteAccumulator(cc,data,mmr,[8 9],represent,timeout);
    case {'AC0L','AL'}
        % addr = {'8' '1'};
        addr = [8 1];
        write(cc,addr,data,timeout);
    case {'AC0H','AH'}
        % addr = {'9' '1'};
        addr = [9 1];
        write(cc,addr,data,timeout);
    case {'AC0G','AG'}
        % addr = {'A' '1'};
        addr = [10 1];    
        Write8BitGuardReg(cc,data,mmr,addr,represent,timeout);   
    case {'AC1','B'}
        WriteAccumulator(cc,data,mmr,[11 12],represent,timeout);
    case {'AC1L','BL'}
        % addr = {'B' '1'};
        addr = [11 1];
        write(cc,addr,data,timeout);
    case {'AC1H','BH'}
        % addr = {'C' '1'};
        addr = [12 1];
        write(cc,addr,data,timeout);
    case {'AC1G','BG'}
        % addr = {'D' '1'};
        addr = [13 1];    
        Write8BitGuardReg(cc,data,mmr,addr,represent,timeout);         
    case 'AC2',
        WriteAccumulator(cc,data,'AC2',[36 37],represent,timeout);    
    case 'AC2L'
        % addr = {'24' '1'};
        addr = [36 1];
        write(cc,addr,data,timeout);
    case 'AC2H'
        % addr = {'25' '1'};
        addr = [37 1];
        write(cc,addr,data,timeout);
    case 'AC2G'
        % addr = {'26' '1'};
        addr = [38 1];    
        Write8BitGuardReg(cc,data,'AC2G',addr,represent,timeout);   
    case 'AC3',
        WriteAccumulator(cc,data,'AC3',[40 41],represent,timeout);    
    case 'AC3L'
        % addr = {'28' '1'};
        addr = [40 1];
        write(cc,addr,data,timeout);
    case 'AC3H'
        % addr = {'29' '1'};
        addr = [41 1];
        write(cc,addr,data,timeout);
    case 'AC3G'
        % addr = {'2A' '1'};
        addr = [42 1];    
        Write8BitGuardReg(cc,data,'AC3G',addr,represent,timeout);
    case 'T0'
        % addr = {'20' '1'};
        addr = [32 1];
        write(cc,addr,data,timeout);
    case 'T1'
        % addr = {'21' '1'};
        addr = [33 1];
        write(cc,addr,data,timeout);
    case 'T2'
        % addr = {'22' '1'};
        addr = [34 1];
        write(cc,addr,data,timeout);
    case 'T3'   %only DP direct addressing mode??
        % addr = {'23' '1'};
        addr = [35 1];
        write(cc,addr,data,timeout);
        
    case 'TRN0'
        % addr = {'F' '1'};
        addr = [15 1];
        write(cc,addr,data,timeout);
    case 'TRN1'
        % addr = {'38' '1'};
        addr = [56 1];
        write(cc,addr,data,timeout);  
        
    case 'IER0' 
        % addr = {'0' '1'};
        addr = [0 1];
        write(cc,addr,data,timeout);
        a = dec2hex(double(data));
        if( all(a(end) ~= ['0' '4' '8' 'C']) )
            warning(['Only certain bits, 2-15, are writable in register ''' mmr '''.']);
        end  
    case 'IER1'
        % addr = {'45' '1'};
        addr = [69 1];
        write(cc,addr,data,timeout);
        if(data > hex2dec('7FF')) % max value with bits 11-15 is 0.
            warning(['Only certain bits, 0-10, are writable in register ''' mmr '''.']);
        end
        
    case 'IFR0' 
        % addr = {'1' '1'};
        addr = [1 1];
        write(cc,addr,data,timeout);
        a = dec2hex(double(data));
        if( all(a(end) ~= ['0' '4' '8' 'C']) )
            warning(['Only certain bits, 2-15, are writable in register ''' mmr '''.']);
        end
    case 'IFR1'
        % addr = {'46' '1'};
        addr = [70 1];
        write(cc,addr,data,timeout);
        if(data > hex2dec('7FF')) %max value with bits 11-15 are 0.
            warning(['Only certain bits, 0-10, are writable in register ''' mmr '''.']);
        end
    case 'ST0'
        % addr = {'6' '1'};
        addr = [2 1];
        write(cc,addr,data,timeout);
    case 'ST1'
        % addr = {'7' '1'};
        addr = [3 1];
        write(cc,addr,data,timeout);
    case 'ST2'
        % addr = {'4B' '1'};
        addr = [75 1];
        write(cc,addr,data,timeout);
    case 'ST3'
        % addr = {'4' '1'};
        addr = [4 1];
        write(cc,addr,data,timeout);
    case 'BK03'
        % addr = {'19' '1'};
        addr = [25 1];
        write(cc,addr,data,timeout);  
    case 'BK47'
        % addr = {'30' '1'};
        addr = [48 1];
        write(cc,addr,data,timeout);  
    case 'BKC'
        % addr = {'31' '1'};
        addr = [49 1];
        write(cc,addr,data,timeout);        
        
    case 'BRC0'
        % addr = {'1A' '1'};
        addr = [26 1];
        write(cc,addr,data,timeout);
    case 'BRC1'
        % addr = {'39' '1'};
        addr = [57 1];
        write(cc,addr,data,timeout);  
    case 'BRS1'
        % addr = {'3A' '1'};
        addr = [58 1];
        write(cc,addr,data,timeout);  
    case 'RSA0L' 
        % addr = {'1B' '1'};
        addr = [27 1];
        write(cc,addr,data,timeout);  
    case 'RSA1L' 
        % addr = {'41' '1'};
        addr = [65 1];
        write(cc,addr,data,timeout);  
    case 'REA0L'
        % addr = {'1C' '1'};
        addr = [28 1];
        write(cc,addr,data,timeout);  
    case 'REA1L'
        % addr = {'43' '1'};
        addr = [67 1];
        write(cc,addr,data,timeout); 
        
    case 'RSA0H' 
        % addr = {'3C' '1'};
        addr = [60 1];
        %since this register is 8-bits we can use Write8BitGuardReg
        % to shape the data correctly
        Write8BitGuardReg(cc,data,mmr,addr,represent,timeout);   
    case 'RSA1H' 
        % addr = {'40' '1'};
        addr = [64 1];
        Write8BitGuardReg(cc,data,mmr,addr,represent,timeout);   
    case 'REA0H'
        % addr = {'3E' '1'};
        addr = [62 1];
        Write8BitGuardReg(cc,data,mmr,addr,represent,timeout);   
    case 'REA1H'
        % addr = {'42' '1'};
        addr = [66 1];
        Write8BitGuardReg(cc,data,mmr,addr,represent,timeout);   
        
    case 'CSR'
        % addr = {'3B' '1'};
        addr = [59 1];
        write(cc,addr,data,timeout);  
    case 'RPTC'
        % addr = {'44' '1'};
        addr = [68 1];
        write(cc,addr,data,timeout); 
        
    case 'BSA01'
        % addr = {'32' '1'};
        addr = [50 1];
        write(cc,addr,data,timeout);  
    case 'BSA23'
        % addr = {'33' '1'};
        addr = [51 1];
        write(cc,addr,data,timeout);  
    case 'BSA45'
        % addr = {'34' '1'};
        addr = [52 1];
        write(cc,addr,data,timeout);  
    case 'BSA67'
        % addr = {'35' '1'};
        addr = [53 1];
        write(cc,addr,data,timeout);  
    case 'BSAC'
        % addr = {'36' '1'};
        addr = [54 1];
        write(cc,addr,data,timeout); 
        
    case 'IVPD'
        % addr = {'49' '1'};
        addr = [73 1];
        write(cc,addr,data,timeout); 
    case 'IVPH'
        % addr = {'4A' '1'};
        addr = [74 1];
        write(cc,addr,data,timeout); 
    case 'XDP'    
        % Not Memory-Mapped
        data = CheckandTruncate(data,represent,mmr);
        callSwitchyard(cc.ccsversion,[54 cc.boardnum cc.procnum timeout cc.eventwaitms],[mmr '=' num2str(double(data))]);
    case 'XSP'    
       data = CheckandTruncate(data,represent,mmr);
       callSwitchyard(cc.ccsversion,[54 cc.boardnum cc.procnum timeout cc.eventwaitms],[mmr '=' num2str(double(data))]);
    case 'XSSP'
        data = CheckandTruncate(data,represent,mmr);
        % Not Memory-Mapped
        callSwitchyard(cc.ccsversion,[54 cc.boardnum cc.procnum timeout cc.eventwaitms],[mmr '=' num2str(double(data))]);
    case 'SSP'    
        % addr = {'4C' '1'};
        addr = [76 1];
        write(cc,addr,data,timeout);  
    case 'PC'
        % no mapping in memory
        absmaxaddress = hex2dec('FFFFFF');
        if ischar(data)
            data = hex2dec(data);
        end
        if data>absmaxaddress
            error('Address exceeds available memory space.');
        end
        data = CheckandTruncate(data,represent,mmr);
        callSwitchyard(cc.ccsversion,[54 cc.boardnum cc.procnum timeout cc.eventwaitms],['PC=' num2str(double(data))]);       
        
    case 'SPH', % High part of Extended SP, 6-0 bits
        addr = [78 1]; % addr = {'4E' '1'};
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(65408,resp);
        data = CheckAndTruncate_General(data,represent,mmr,7);
        data  = bitor(resp,double(data));
        write(cc,addr,uint16(data),timeout);  
    case 'XPC', % Extended PC, 7-0 bits
        addr = [30 1]; % addr = {'1E' '1'};
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(65280,resp);
        data = CheckAndTruncate_General(data,represent,mmr,8);
        data  = bitor(resp,double(data));
        write(cc,addr,uint16(data),timeout);  
    case 'CDP', % Coefficient data pointer, 16 bits
        addr = [39 1]; % addr = {'27' '1'};
        write(cc,addr,data,timeout); 
    case 'CDPH', % High part of Coefficient data pointer, 6-0 bits
        addr = [79 1]; % addr = {'4F' '1'};
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(65408,resp);
        data = CheckAndTruncate_General(data,represent,mmr,7);
        data  = bitor(resp,double(data));
        write(cc,addr,uint16(data),timeout);  
    case 'DP', % Data page register, 16 bits
        addr = [46 1]; % addr = {'2E' '1'};
        write(cc,addr,data,timeout); 
    case 'DPH', % High part of Data page register, 6-0 bits
        addr = [43 1]; % addr = {'2B' '1'};
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(65408,resp);
        data = CheckAndTruncate_General(data,represent,mmr,7);
        data  = bitor(resp,double(data));
        write(cc,addr,uint16(data),timeout);  
    case 'PDP', % Peripheral Data page register, 8-0 bits
        addr = [47 1]; % addr = {'2F' '1'};
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(65024,resp);
        data = CheckAndTruncate_General(data,represent,mmr,9);
        data  = bitor(resp,double(data));
        write(cc,addr,uint16(data),timeout);  
    case 'ST0_55', % Status register 0, 16 bits
        addr = [2 1]; % addr = {'2' '1'};
        write(cc,addr,data,timeout); 
    case 'ST1_55', % Status register 1, 16 bits
        addr = [3 1]; % addr = {'3' '1'};
        write(cc,addr,data,timeout); 
    case 'ST2_55', % Status register 2, 16 bits
        addr = [75 1]; % addr = {'4B' '1'};
        write(cc,addr,data,timeout); 
    case 'ST3_55', % Status register 3, 16 bits
        addr = [4 1]; % addr = {'4' '1'};
        write(cc,addr,data,timeout); 
    case 'PMST', % Status register 3 - protected for C54x, 16 bits
        addr = [29 1]; % addr = {'1D' '1'};
        write(cc,addr,data,timeout); 
    case {'REA0','REA1','RSA0','RSA1'},
        addr = struct( 'REA0', [62 1], ... % addr = {'3e' '1'}; Block-repeat end address register 0, 24 bits
                       'REA1', [66 1], ... % addr = {'42' '1'}; Block-repeat end address register 1, 24 bits
                       'RSA0', [60 1], ... % addr = {'3c' '1'}; Block-repeat start address register 0, 24 bits
                       'RSA1', [64 1]);    % addr = {'40' '1'}; Block-repeat start address register 1, 24 bits
        data = CheckAndTruncate_General(data,represent,mmr,24);
        dataH = bitshift(data,-16,16); % High-part
        dataL = dec2hex(data,8); dataL = hex2dec(dataL(end-3:end)); % Low-part
        write(cc,addr.(mmr),uint16(dataH),timeout); % write hi-part into lower address
        addr = addr.(mmr);
        write(cc,[addr(1)+1 addr(2)],uint16(dataL),timeout);  % write lo-part into higher address
    case 'DBIER0', % Debug interrupt enable register 0, 15-2 bits
        addr = [71 1]; % addr = {'47' '1'}; 
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(3,resp); % '11'==3, zero out bits 2-15
        data = CheckAndTruncate_General(data,represent,mmr,14);
        data = bitshift(data,2,16); % shift to the left by 2 bits
        data = bitor(resp,double(data));
        write(cc,addr,uint16(data),timeout);  
    case 'DBIER1', % Debug interrupt enable register 1, 10-0 bits
        addr = [72 1]; % addr = {'48' '1'}; 
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(63488,resp); % '1111100000000000'==63488, zero out bits 0-10
        data = CheckAndTruncate_General(data,represent,mmr,11);
        data  = bitor(resp,double(data));
        write(cc,addr,uint16(data),timeout);  
end


% ---------------------------------
function Write8BitGuardReg(cc,data,acc,addr,represent,timeout)
if ischar(data)
    data = hex2dec(data);
end

if strcmp(represent,'BINARY')
    write(cc,addr,uint8(data),timeout);
elseif strcmp(represent,'2SCOMP')
    write(cc,addr,int8(data),timeout);
elseif strcmp(represent,'IEEE')
    error(['Input data cannot be written in IEEE format on a non-32-bit register: ' acc ' (8-bit)']);
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
        warning(['Input data is truncated to fit in register ''' (acc) '''.']);
    end
    data = hex2dec(data);
end

if strcmp(represent,'BINARY')
    MaxData = 2^32 - 1;
    if data > MaxData
        warning(['Saturation occurred while writing to register ''' (acc) ''' ']);
    end
    data = uint32(data);
    data_str = dec2hex(double(data),round(32/4));
    
elseif strcmp(represent,'2SCOMP')
    MaxData = 2^31 - 1;    
    MinData = -2^31;
    if (data > MaxData) || (data < MinData)
        warning(['Saturation occurred while writing to register ''' (acc) ''' ']);
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
%------------------------------------------------
function data = CheckandTruncate(data,represent,mmr)
if strcmpi(mmr,'PC'),
    MSB = 1;
else 
    MSB = 0;
end
% Truncate extra bits, if data is hex
if ischar(data) 
    if length(data) > 6
        data = TruncateUpToN(data,6);
        warning(['Input data is truncated to fit in register ''' (mmr) '''.']);
    end
    data = hex2dec(data);
end
% Convert data into ieee, 2scomp, or binary format
if strcmp(represent,'IEEE')
    errid = ['MATLAB:CCSDSP:' mfilename '_m:CannotWriteInIeeeFormat'];
    error(errid,['Input data cannot be written in IEEE format on a non-32-bit register: ' mmr ]);
elseif strcmp(represent,'BINARY')
    if data >= 0,
       MaxData = 2^(23+MSB) - 1;
       if data > MaxData,
            warning(['Saturation occurred while writing to register ''' (mmr) '''.']);
            data = MaxData;
        end      
        data = double(data); % 24-bits, MSB=0 if data is 23-bits
    else % negative
        warning(['Saturation occurred while writing to register ''' (mmr) '''.']);
        data = 0;
    end
elseif strcmp(represent,'2SCOMP')
    MaxData = 2^(22+MSB) - 1;
    MinData = -2^(22+MSB);
    if data > MaxData
        warning(['Saturation occurred while writing to register ''' (mmr) '''.']);
        data = MaxData;
    elseif data < MinData
        warning(['Saturation occurred while writing to register ''' (mmr) '''.']);
        data = MinData;      
    end
    if data<0,
        pos = double(data) - (-2^31);
        % convert to bin with 31 characters & prepend neg bit after
        data_str = dec2hex(bin2dec(horzcat('1',dec2bin(pos,31))),round(32/4));
        data = hex2dec(data_str(end-5:1:end));
        data_bin =  dec2bin(data,24);
        data = bin2dec(data_bin(end-(22+MSB):1:end));
    end
end
%------------------------------------------------
function data = CheckAndTruncate_General(data,represent,mmr,numbits)
numhex = ceil(numbits/4);
% Truncate extra bits, if data is hex
if ischar(data) 
    if length(data) > numhex
        data = TruncateUpToN(data,numhex);
        warning(['Input data is truncated to fit in register ''' (mmr) '''.']);
    end
    data = hex2dec(data);
end
% Convert data into ieee, 2scomp, or binary format
if strcmp(represent,'IEEE')
    errid = ['MATLAB:CCSDSP:' mfilename '_m:CannotWriteInIeeeFormat'];
    error(errid,['Input data cannot be written in IEEE format on a non-32-bit register: ' mmr ]);
elseif strcmp(represent,'BINARY')
    if data >= 0,
       MaxData = 2^(numbits) - 1;
       if data > MaxData,
            warning(['Saturation occurred while writing to register ''' (mmr) '''.']);
            data = MaxData;
        end      
        data = double(data); % 24-bits, MSB=0 if data is 23-bits
    else % negative
        warning(['Saturation occurred while writing to register ''' (mmr) '''.']);
        data = 0;
    end
elseif strcmp(represent,'2SCOMP')
    MaxData = 2^(numbits-1) - 1;
    MinData = -2^(numbits-1);
    if data > MaxData
        warning(['Saturation occurred while writing to register ''' (mmr) '''.']);
        data = MaxData;
    elseif data < MinData
        warning(['Saturation occurred while writing to register ''' (mmr) '''.']);
        data = MinData;      
    end
    if data<0,
        data = double(data) - (-2^numbits);
    end
end
data = double(data);
%--------------------------------------------------------
function data = GetDataFromRepresent(mmr,data,represent)
% Truncate if data is hex
if ischar(data) 
    if length(data) > 4
        data = TruncateUpToN(data,4);
        warning(['Input data is truncated to fit in register ''' (mmr) '''.']);
    end
    data = hex2dec(data);
end

if strcmpi(represent,'BINARY')
    MaxData = 2^16 - 1;
    if data > MaxData
        warning(['Saturation occurred while writing to register ''' (mmr) '''.']);
    end
    data = uint16(data);
elseif strcmpi(represent,'2SCOMP')
    MaxData = 2^15 - 1;    
    MinData = -2^15;
    if (data > MaxData) || (data < MinData)
        warning(['Saturation occurred while writing to register ''' (mmr) '''.']);
    end
    data = int16(data);   
elseif strcmpi(represent,'IEEE')
    errid = ['MATLAB:CCSDSP:' mfilename '_m:CannotWriteInIeeeFormat'];
    error(errid,['Input data cannot be written in IEEE format on a non-32-bit register: ' mmr ]);
end

%---------------------------------------
function CheckInputs(mmr,represent)

DataTypes = {'BINARY','2SCOMP','IEEE'};
SupportedRegisters = {
        'AC0'  ,'A'  ,'AC1'  ,'B'  ,'AC2'  ,'AC3',...      % Accumulators
        'AC0L' ,'AL' ,'AC1L' ,'BL' ,'AC2L' ,'AC3L',...     % Accumulator low
        'AC0H' ,'AH' ,'AC1H' ,'BH' ,'AC2H' ,'AC3H',...     % Accumulator high
        'AC0G' ,'AG' ,'AC1G' ,'BG' ,'AC2G' ,'AC3G',...     % Accumulator guard
        'AR0' ,'AR1' ,'AR2' ,'AR3' ,'AR4' ,'AR5' ,'AR6' ,'AR7' ,... % Auxillary registers
        'XAR0','XAR1','XAR2','XAR3','XAR4','XAR5','XAR6','XAR7',... % Extended auxillary registers 
        'T0','T1','T2','T3',... % Temporary registers
        'TRN0','TRN1',...       % Transition registers
        'XSP','XSSP',...        % extended data & stack stack pointers
        'SP', 'SSP', ...        % Data & System Stack pointers
		'SPH',...               % Stack pointer - high part, 7 bits
        'IVPD','IVPH','IER0','IER1','IFR0','IFR1',...   % interrupt registers
		'DBIER0','DBIER1',...   % interrupt registers, 14 bits & 11 bits, respectively
        'BK03','BK47','BKC',... % circular-buffer registers
        'BSA01','BSA23','BSA45','BSA67','BSAC',... % circular-buffer start/end registers
        'BRC0','BRC1','RSA0','RSA1','REA0','REA1','BRS1',... % Block-repeat registers
        'RSA0L','RSA1L','REA0L','REA1L',... % Block-repeat registers - low part
        'RSA0H','RSA1H','REA0H','REA1H',... % Block-repeat registers - high part
        'PC', ...       % Program counter
		'XPC',...       % Extended PC, 8 bits
		'CDP',...       % Coeff data pointer, 16 bits
		'CDPH'...       % Coeff data pointer - high part, 7 bits
        'XCDP',...      % Extended coeff data pointer, 23 bits
		'DP','DPH',...  % Data page pointer, 16 bits
		'PDP',...       % peripheral data page register, 9 bits
        'XDP',...       % Extended data page pointer
        'CSR',...       % computed single-repeat counter
        'RPTC'...       % single-repeat counter
    };
statusRegisters = { ...
        'ST0_55', 'ST0'... % Status register 0, 16 bits
		'ST1_55', 'ST1'... % Status register 1, 16 bits
		'ST2_55',...       % Status register 2, 16 bits
		'PMST'  ,...       % Program-mode status register, 16 bits
		'ST3_55', 'ST3'... % Status register 3, 16 bits
    };
    
if ~ischar(mmr),
    errid = ['MATLAB:CCSDSP:' mfilename '_m:InputMustBeAString'];
    error(errid,'??? RegWrite: Second parameter must be a string.');
end
if ~ischar(represent),
    errid = ['MATLAB:CCSDSP:' mfilename '_m:InputMustBeAString'];
    error(errid,'??? RegWrite: Third parameter must be a string.');
end
if ~isempty(findstr(':',mmr))
    errid = ['MATLAB:CCSDSP:' mfilename '_m:RegPairNotSupported'];
    error(errid,'??? RegWrite: Writing to register pairs is not supported on C5500.');
end

if ~isempty(strmatch((mmr),statusRegisters,'exact'))
    errid = ['MATLAB:CCSDSP:' mfilename '_m:StatusRegsNotSupported'];
    error(errid,['??? RegWrite: Value of status register ''' mmr ''' cannot be overwritten.']);
end
if isempty(strmatch((mmr),SupportedRegisters,'exact'))
    errid = ['MATLAB:CCSDSP:' mfilename '_m:RegNotSupported'];
    error(errid,['??? RegWrite: Register ''' mmr ''' is not a supported register on C5500.']);
end
if isempty(strmatch((represent),DataTypes,'exact'))
    errid = ['MATLAB:CCSDSP:' mfilename '_m:RegwriteRepNotSupported'];
    error(errid,['??? RegWrite: Representation ''' represent ''' is not supported. Representation must be ''binary'', ''2scomp'', or ''ieee''.']);
end

%----------------------------------------
function data = TruncateUpToN(data,N)
data = data(end-N+1:1:end);

% [EOF] mm55regwrite.m