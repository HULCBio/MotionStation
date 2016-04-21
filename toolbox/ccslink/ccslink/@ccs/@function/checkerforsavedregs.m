function sv = checkerforsavedregs(nn,usersSV)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/11/30 23:08:14 $

usersSV = upper(usersSV);
reglist = p_saved_register_list(nn,nn.procsubfamily);
check_ones = ismember(reglist,usersSV);
if any( check_ones(1:length(reglist))==0 )
    error('You can not remove a register that the compiler requires to be preserved.');
    return;
end
additionalregs = usersSV(length(reglist)+1 : end);
check_if_valid(['C' dec2hex(nn.link.subfamily) 'x'],additionalregs);
sv = horzcat(reglist,additionalregs);

%----------------------------------------------
function check_if_valid(procsubfamily,additionalregs)

switch procsubfamily
case {'C67x','C62x'},
    % A0-A9 and B0-B9
    reglist = { 'A0',   'A1',   'A2',   ...
                'A6',   'A7',   'A8',   'A9',   ...
                'A10',  'A11',  'A12',  'A13',  'A14',  'A15',  ...
                'B0',   'B1',   'B2',           'B4',   'B5',   ...
                'B6',   'B7',   'B8',   'B9',   ...
                'B10',  'B11',  'B12',  'B13',  'B14',  'B15',...
                'B3', ...    % return address - program
                'A3', ...    % address of return data - only if return is struct/union
                'A4', ...    % first input / return data
                'A5', ...    % part of first input if >32
                'PC'  ...    % program counter
              };
        
case 'C64x',
    % A0-A9 and B0-B9
    % A16-A31 and B16-B31
    reglist = {'A0',  'A1',  'A2',   ...
               'A6',  'A7',  'A8',  'A9',  ...
               'A10', 'A11', 'A12', 'A13', 'A14', 'A15',...
               'A16', 'A17', 'A18', 'A19', ...
               'A20', 'A21', 'A22', 'A23', 'A24', 'A25',...
               'A26', 'A27', 'A28', 'A29', 'A30', 'A31', ...
               'B0',  'B1',  'B2',         'B4',  'B5', ...
               'B6',  'B7',  'B8',  'B9',  ...  
               'B10', 'B11', 'B12', 'B13', 'B14', 'B15',...
               'B16', 'B17', 'B18', 'B19', ...
               'B20', 'B21', 'B22', 'B23', 'B24', 'B25',...
               'B26', 'B27', 'B28', 'B29', 'B30', 'B31', ...
               'B3', ...    % return address - program
               'A3', ...    % address of return data - only if return is struct/union
               'A4', ...    % first input / return data
               'A5', ...    % part of first input if >32
               'PC'  ...    % program counter
               };
    
case 'C54x',
    reglist = { 'AR0', 'AR1', 'AR2', 'AR3', ... % gen-purpose registers
                'AR4', 'AR5', 'AR6', 'AR7',...  % gen-purpose registers
                'PC',  ...                      % program counter
                'XPC', ...                      % xpc = program address 'page'
                'SP', ...                       % stack pointer
                'T', 'TREG', 'TRN',...          % temporary registers
                'A', 'AL', 'AH', 'AG', ...      % accumulator A
                'B', 'BL', 'BH', 'BG', ...      % accumulator B
                'STO','ST1','BK','BRC','RSA','REA','PMST' ... % additional registers
              };
          
case 'C55x',
	reglist = {'AC0','AC1','AC2','AC3',...
               'XAR0','XAR1','XAR2','XAR3','XAR4',...
               'T0','T1',...
               'RPTC','CSR','BRC0','BRC1','BRS1','RSA0','RSA1','REA0','REA1',...
               'SP','SSP' ... %- not required by compiler, but reguired by ML
              };
    %% TO DO %%
    
case 'C28x',
        reglist = { 'AL'   ,'AH'   ,... % accumulator
            'AR0'  ,'AR1'  ,'AR2'  ,'AR3'  ,'AR4'  ,'AR5'  ,'AR6'  ,'AR7'  ,...
            'XAR0' ,'XAR1' ,'XAR2' ,'XAR3' ,'XAR4' ,'XAR5' ,'XAR6' ,'XAR7' ,... % auxillary registers
            'XT'   ,... % multiplicand register
            'T'    ,'TL'   ,'P'    ,'PL'   ,'PH'  ,... % product registers
            'DP',... % data page pointer
            'ST0'  ,'ST1'  ,... % status registers
            'IFR'  ,'IER'  ,'DBGIER' ,... % interrupt-control registers
            'SP'   ,... % stack pointer
            'PC'   ,'RPC' ... % pc & return pc
        };

          
otherwise
    error(generateccsmsgid('ProcessorNotSupported'),['Processor ' procsubfamily ' not supported.']);
end

if ~isempty(setdiff(additionalregs,reglist))
    error(generateccsmsgid('InvalidSavedReg'),'Attempting to add invalid registers to saved-register list.');
    return;
end

% [EOF] checkerforsavedregs.m