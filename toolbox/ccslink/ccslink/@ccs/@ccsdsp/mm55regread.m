function resp = mm55regread(cc,mmr,represent,timeout)
% MM55REGREAD (Private)
% Reads the contents of a TMS320C55x memory-mapped register specified by MMR.

% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/01 16:02:34 $

mmr = upper(mmr);
represent = upper(represent);

% Check Validity of inputs
CheckInputs(mmr,represent);

% Auxiliary Registers for the c55x (not memory-mapped)
XRn = {'XAR0','XAR1','XAR2','XAR3','XAR4','XAR5','XAR6','XAR7','XSP','XSSP','XDP','XCDP'};

% Do not map register-represention to memory-representation on 
% special registers (non 16-bit regs) right away
if ( isempty(strmatch((mmr), {'A','B','AG','BG','AC0','AC1','AC2','AC3','AC0G','AC1G','AC2G','AC3G',...
     'XSP','XSSP','RSA0H','RSA1H','REA0H','REA1H','RSA0', 'RSA1', 'REA0', 'REA1','XDP', XRn{:},...
     'DBIER0','DBIER1'},'exact')) ...
     && isempty(findstr(':',mmr)) && ~strcmpi('PC',mmr) ),
    represent = Get16BitRepresent(mmr,represent);
end

% Read contents of register(s)
% Note: for the non-extended auxiliary registers(ARn), we do not read
% from the extended part, bits 16-22. We only read from bits 0-15.
switch (mmr)
    case XRn,  % Auxiliary registers are Not memory-mapped
        resp=callSwitchyard(cc.ccsversion,[25 cc.boardnum cc.procnum timeout cc.eventwaitms],mmr,lower(represent)); 
        % since XRs are 23 bits, we need to explicitly find the 2SCOMP representation
        if strcmp(represent,'2SCOMP')
            resp = binTo2SCOMP(resp,23);
       end
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
    case {'AC0' ,'A'}
        resp = ReadAccumulator(cc,'AC0',[8 9],represent,timeout);
    case {'AC0L','AL'}
        % addr = {'8' '1'};
        addr = [8 1];
        resp = read(cc,addr,represent,1,timeout);
    case {'AC0H','AH'}
        % addr = {'9' '1'};
        addr = [9 1];
        resp = read(cc,addr,represent,1,timeout);
    case {'AC0G','AG'}
        % addr = {'A' '1'};
        addr = [10 1];    
        resp = read8BitGuardReg(cc,'AC0G',addr,represent,timeout);
    case {'AC1','B'}
        resp = ReadAccumulator(cc,'AC1',[11 12],represent,timeout);
    case {'AC1L','BL'}
        % addr = {'B' '1'};
        addr = [11 1];
        resp = read(cc,addr,represent,1,timeout);
    case {'AC1H','BH'}
        % addr = {'C' '1'};
        addr = [12 1];
        resp = read(cc,addr,represent,1,timeout);
    case {'AC1G','BG'}
        % addr = {'D' '1'};
        addr = [13 1];    
        resp = read8BitGuardReg(cc,'AC1G',addr,represent,timeout);
    case 'AC2',
        resp = ReadAccumulator(cc,'AC2',[36 37],represent,timeout);    
    case 'AC2L'
        % addr = {'24' '1'};
        addr = [36 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AC2H'
        % addr = {'25' '1'};
        addr = [37 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AC2G'
        % addr = {'26' '1'};
        addr = [38 1];    
        resp = read8BitGuardReg(cc,'AC2G',addr,represent,timeout);
    case 'AC3',
        resp = ReadAccumulator(cc,'AC3',[40 41],represent,timeout);    
    case 'AC3L'
        % addr = {'28' '1'};
        addr = [40 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AC3H'
        % addr = {'29' '1'};
        addr = [41 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'AC3G'
        % addr = {'2A' '1'};
        addr = [42 1];    
        resp = read8BitGuardReg(cc,'AC3G',addr,represent,timeout);
    case 'T0'
        % addr = {'20' '1'};
        addr = [32 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'T1'
        % addr = {'21' '1'};
        addr = [33 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'T2'
        % addr = {'22' '1'};
        addr = [34 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'T3'   %only DP direct addressing mode??
        % addr = {'23' '1'};
        addr = [35 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'TRN0'
        % addr = {'F' '1'};
        addr = [15 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'TRN1'
        % addr = {'38' '1'};
        addr = [56 1];
        resp = read(cc,addr,represent,1,timeout); 
        
    case 'IER0' 
        % addr = {'0' '1'};
        addr = [0 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'IER1'
        % addr = {'45' '1'};
        addr = [69 1];
        resp = read(cc,addr,represent,1,timeout);
       
    case 'IFR0' 
        % addr = {'1' '1'};
        addr = [1 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'IFR1'
        % addr = {'46' '1'};
        addr = [70 1];
        resp = read(cc,addr,represent,1,timeout);       
    case 'ST0'
        % addr = {'6' '1'};
        addr = [6 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'ST1'
        % addr = {'7' '1'};
        addr = [7 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'ST2'
        % addr = {'4B' '1'};
        addr = [75 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'ST3'
        % addr = {'4' '1'};
        addr = [4 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'BK03'
        % addr = {'19' '1'};
        addr = [25 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'BK47'
        % addr = {'30' '1'};
        addr = [48 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'BKC'
        % addr = {'31' '1'};
        addr = [49 1];
        resp = read(cc,addr,represent,1,timeout);       
    case 'BRC0'
        % addr = {'1A' '1'};
        addr = [26 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'BRC1'
        % addr = {'39' '1'};
        addr = [57 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'BRS1'
        % addr = {'3A' '1'};
        addr = [58 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'RSA0L' 
        % addr = {'1B' '1'};
        addr = [27 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'RSA1L' 
        % addr = {'41' '1'};
        addr = [65 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'REA0L'
        % addr = {'1C' '1'};
        addr = [28 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'REA1L'
        % addr = {'43' '1'};
        addr = [67 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'RSA0H' 
        % addr = {'3C' '1'};
        addr = [60 1];
        %since this register is 8-bits we can use Read8BitGuardReg
        % to shape the data correctly
        resp = read8BitGuardReg(cc,'RSA0H',addr,represent,timeout);
    case 'RSA1H' 
        % addr = {'40' '1'};
        addr = [64 1];
        resp = read8BitGuardReg(cc,'RSA1H',addr,represent,timeout);
    case 'REA0H'
        % addr = {'3E' '1'};
        addr = [62 1];
        resp = read8BitGuardReg(cc,'REA0H',addr,represent,timeout);
    case 'REA1H'
        % addr = {'42' '1'};
        addr = [66 1];
        resp = read8BitGuardReg(cc,'REA1H',addr,represent,timeout);
    case 'CSR'
        % addr = {'3B' '1'};
        addr = [59 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'RPTC'
        % addr = {'44' '1'};
        addr = [68 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'BSA01'
        % addr = {'32' '1'};
        addr = [50 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'BSA23'
        % addr = {'33' '1'};
        addr = [51 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'BSA45'
        % addr = {'34' '1'};
        addr = [52 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'BSA67'
        % addr = {'35' '1'};
        addr = [53 1];
        resp = read(cc,addr,represent,1,timeout); 
    case 'BSAC'
        % addr = {'36' '1'};
        addr = [54 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'IVPD'
        % addr = {'49' '1'};
        addr = [73 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'IVPH'
        % addr = {'4A' '1'};
        addr = [74 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'SP'
        % addr = {'4A' '1'};
        addr = [77 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'SSP'    
        % addr = {'4C' '1'};
        addr = [76 1];
        resp = read(cc,addr,represent,1,timeout);
    case 'PC'
        resp=callSwitchyard(cc.ccsversion,[25 cc.boardnum cc.procnum timeout cc.eventwaitms],mmr,lower(represent));
        if strcmp(represent,'2SCOMP')
            resp = binTo2SCOMP(resp,24);
        end
    case 'SPH', % High part of Extended SP, 6-0 bits
        addr = [78 1]; % addr = {'4E' '1'};
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(127,double(resp));
        if strcmpi(represent,'int16')
            resp = binTo2SCOMP(resp,7);
        end
    case 'XPC', % Extended PC, 7-0 bits
        addr = [30 1]; % addr = {'1E' '1'};
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(255,double(resp));
        if strcmpi(represent,'int16')
            resp = binTo2SCOMP(resp,8);
        end
    case 'CDP', % Coefficient data pointer, 16 bits
        addr = [39 1]; % addr = {'27' '1'};
        resp = read(cc,addr,represent,1,timeout);
    case 'CDPH', % High part of Coefficient data pointer, 6-0 bits
        addr = [79 1]; % addr = {'4F' '1'};
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(127,double(resp));
        if strcmpi(represent,'int16')
            resp = binTo2SCOMP(resp,7);
        end
    case 'DP', % Data page register, 16 bits
        addr = [46 1]; % addr = {'2E' '1'};
        resp = read(cc,addr,represent,1,timeout);
    case 'DPH', % High part of Data page register, 6-0 bits
        addr = [43 1]; % addr = {'2B' '1'};
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(127,double(resp));
        if strcmpi(represent,'int16')
            resp = binTo2SCOMP(resp,7);
        end
    case 'PDP', % Peripheral Data page register, 8-0 bits
        addr = [47 1]; % addr = {'2F' '1'};
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(511,double(resp));
        if strcmpi(represent,'int16')
            resp = binTo2SCOMP(resp,9);
        end
    case 'ST0_55', % Status register 0, 16 bits
        addr = [2 1]; % addr = {'2' '1'};
        resp = read(cc,addr,represent,1,timeout);
    case 'ST1_55', % Status register 1, 16 bits
        addr = [3 1]; % addr = {'3' '1'};
        resp = read(cc,addr,represent,1,timeout);
    case 'ST2_55', % Status register 2, 16 bits
        addr = [75 1]; % addr = {'4B' '1'};
        resp = read(cc,addr,represent,1,timeout);
    case 'ST3_55', % Status register 3, 16 bits
        addr = [4 1]; % addr = {'4' '1'};
        resp = read(cc,addr,represent,1,timeout);
    case 'PMST', % Status register 3 - protected for C54x, 16 bits
        addr = [29 1]; % addr = {'1D' '1'};
        resp = read(cc,addr,represent,1,timeout);
    case {'REA0','REA1','RSA0','RSA1'},
        addr = struct( 'REA0', [62 1], ... % addr = {'3e' '1'}; Block-repeat end address register 0, 24 bits
                       'REA1', [66 1], ... % addr = {'42' '1'}; Block-repeat end address register 1, 24 bits
                       'RSA0', [60 1], ... % addr = {'3c' '1'}; Block-repeat start address register 0, 24 bits
                       'RSA1', [64 1]);    % addr = {'40' '1'}; Block-repeat start address register 1, 24 bits
        resp = read(cc,addr.(mmr),'uint32',1,timeout);
        resp = bitand(2^24-1,double(resp));
        if strcmpi(represent,'ieee')
            error(['Cannot convert data in register ''' mmr ''' to IEEE floating-point format. Data must be at least 32 bits in size.']);
        elseif strcmpi(represent,'2scomp')
            resp = binTo2SCOMP(resp,24);
        end
    case 'DBIER0', % Debug interrupt enable register 0, 15-2 bits
        addr = [71 1]; % addr = {'47' '1'}; 
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitshift(double(resp),-2,14);
        if strcmpi(represent,'2scomp')
            resp = binTo2SCOMP(resp,14);
        end
    case 'DBIER1', % Debug interrupt enable register 1, 10-0 bits
        addr = [72 1]; % addr = {'48' '1'}; 
        resp = read(cc,addr,'uint16',1,timeout);
        resp = bitand(2^11-1,double(resp));
        if strcmpi(represent,'2scomp')
            resp = binTo2SCOMP(resp,11);
        end
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
    resp = binTo2SCOMP(resp,ndx);
    
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
function resp = read8BitGuardReg(cc,acc,address,represent,timeout);

if strcmpi(represent,'BINARY')
    represent= 'uint8';
elseif strcmpi(represent,'2SCOMP')
    represent= 'int8';
elseif strcmpi(represent,'IEEE')
    error(['Register ' acc ' cannot be represented in IEEE format']);
end
resp = read(cc,address,represent,1,timeout);

%---------------------------------------------
function resp = binTo2SCOMP(resp,ndx)
% MSB is always 0 on the auxiliary resgisters
bin = dec2bin(resp,ndx) - '0';
resp = (-1*bin(1)*(2^(ndx-1))) + (bin(2:ndx) * (2 .^ [ndx-2:-1:0])');

%---------------------------------------
function CheckInputs(mmr,represent)

DataTypes = {'BINARY','2SCOMP','IEEE'};

SupportedRegisters = {'A','AL','AH','AG','B','BL','BH','BG',...
        'AC0','AC0L','AC0H','AC0G','AC1','AC1L','AC1H','AC1G',...
        'AC2','AC2L','AC2H','AC2G','AC3','AC3L','AC3H','AC3G',...
        'AR0','AR1','AR2','AR3','AR4','AR5','AR6','AR7',...
        'XAR0','XAR1','XAR2','XAR3','XAR4','XAR5','XAR6','XAR7',... 
        'XSP','PC','IER0','IER1','IFR0',...
        'IFR1','ST0','ST1','ST2','ST3','T0','T1','T2','T3',...
        'TRN0','TRN1','BK03','BK47','BKC','BRC0','BRC1',...
        'BRS1','RSA0L','RSA1L','REA0L','REA1L',...
        'RSA0H','RSA1H','REA0H','REA1H','CSR','RPTC',...
        'BSA01','BSA23','BSA45','BSA67','BSAC','IVPD','IVPH',...
        'XDP','XSP','XSSP','SSP','PC','SP',...
        'XCDP', ... % physical register added to the list, 23 bits
        'ST0_55',... % mm-register added to the list, 16 bits
		'ST1_55',... % mm-register added to the list, 16 bits
		'ST3_55',... % mm-register added to the list, 16 bits
		'PMST',... % mm-register added to the list, 16 bits
		'XPC',... % mm-register added to the list, 8 bits
		'CDP',... % mm-register added to the list, 16 bits
		'DPH',... % mm-register added to the list, 7 bits
		'DP',... % mm-register added to the list, 16 bits
		'PDP',... % mm-register added to the list, 9 bits
		'RSA0',... % mm-register added to the list, 24* bits
		'REA0',... % mm-register added to the list, 24* bits
		'RSA1',... % mm-register added to the list, 24* bits
		'REA1',... % mm-register added to the list, 24* bits
		'DBIER0',... % mm-register added to the list, 14 bits
		'DBIER1',... % mm-register added to the list, 11 bits
		'ST2_55',... % mm-register added to the list, 16 bits
		'SPH',... % mm-register added to the list, 7 bits
		'CDPH'... % mm-register added to the list, 7 bits
    };

if ~ischar(mmr),
    error('??? RegRead: Second parameter must be a string.');
end
if ~ischar(represent),
    error('??? RegRead: Third parameter must be a string.');
end
if ~isempty(findstr(':',mmr))
    error('??? RegRead: Reading from register pairs is not supported on C5500.');
end
if isempty(strmatch((mmr),SupportedRegisters,'exact'))
    error(['??? RegRead: Register ''' mmr ''' is not a supported register on C5500.']);
end
if isempty(strmatch((represent),DataTypes,'exact'))
    error(['??? RegRead: Representation ''' represent ''' is not supported. Representation must be ''binary'', ''2scomp'', or ''ieee''.']);
end

% [EOF] mm55regread.m