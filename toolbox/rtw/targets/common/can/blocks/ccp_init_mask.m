function varargout = ccp_init_mask(action, block, varargin)
% CCP_INIT_MASK Configuration for the CCP Block
%
% ccp_init_mask(action, block)
%
% ccp_init_mask('initfcn', block) uses the SF API to uncheck the 'Use Settings
% for all Libraries'
%
% Copyright 2002-2003 The MathWorks, Inc.
% $Revision: 1.11.4.4 $
% $Date: 2004/04/19 01:19:12 $
switch action
    case 'copyfcn' 
        if (strcmp(get_param(bdroot(block),'BlockDiagramType'),'library'))
            % do not run the init code when in the library
            return;
        end;
        internal_copyfcn(block);
    case 'show_commands_mask_callback'
        show_commands=get_param(block,'show_commands');
        var_names = {'GET_CCP_VERSIONenabled' 'EXCHANGE_IDenabled' 'SET_MTAenabled' 'DNLOADenabled' ...
                'UPLOADenabled' 'SHORT_UPenabled' 'GET_DAQ_SIZEenabled' 'SET_DAQ_PTRenabled' ...
                'WRITE_DAQenabled' 'START_STOPenabled' 'SET_S_STATUSenabled' 'GET_S_STATUSenabled' ...
                'START_STOP_ALLenabled' 'DNLOAD_6enabled'};
        switch show_commands
            case 'on'
                internal_show_commands(block, var_names);
            case 'off'
                internal_hide_commands(block, var_names);
        end;
    otherwise
        disp('Unkown action');
end;
   
function internal_show_commands(block, var_names)
    for (i=1:length(var_names)) 
        simUtil_maskParam('show',block,var_names{i});
    end;
    
function internal_hide_commands(block, var_names)
    for (i=1:length(var_names))
        simUtil_maskParam('hide',block,var_names{i});
    end;
    
    
function internal_copyfcn(block)
   ud = get_param(block, 'UserData');
   if (ud.applycopyfcn)
        ud.applycopyfcn = 0;
        set_param(block, 'UserData', ud);
        newline = sprintf('\n');
        warningmessage = ['The CAN Calibration Protocol (CCP) block requires "Target Options" settings from its Simulink '...
                          'library. These settings enable the block to locate various required source files.' newline newline...
                          'It is possible to update the model''s "Target Options" to use settings from the library '...
                          'automatically or manually. Note: if you do not update the "Target Options" at all, this block '...
                          'will not function correctly.' newline newline ...
                          'Steps for automatic update:' newline newline...
                          'a) Answer "Yes" to the question below to accept the automatic update of the "Target Options".' newline newline...
                          'Steps for manual update:' newline newline...
                          'a) Answer "No" to the question below to decline the automatic update of the "Target Options".' newline ...
                          'b) Open any Stateflow block in the model.' newline ...
                          'c) Select the "Simulation Target Options". Then, uncheck the "Use settings for all libraries" checkbox.' newline ...
                          'd) Select the "RTW Target Options". Then, uncheck the "Use settings for all libraries" checkbox.' newline newline ...
                          'Do you wish to automatically update the model''s "Target Options" to use settings from the library?'];
        answer = questdlg(warningmessage, 'Target Options Configuration', 'Yes', 'No', 'Yes');
        switch (answer)
        case 'Yes'
            run_internal_init = 1;
        case 'No'
            run_internal_init = 0;
            disp('Warning: This block will not function correctly unless the Target Options from the library are used!');
        otherwise
            return;
        end;
        if (run_internal_init) 
            internal_sfapi(block);
        end;
   end;
        
% block initialisation
function internal_sfapi(block)
% make sure the Stateflow blocks have
% been initialised correctly - init Stateflow machine for the model
find_system(bdroot(block),'LookUnderMasks','all','FollowLinks','on');
% use SF API to set the library flags correctly.
rt = sfroot;
% get the machine
q  = rt.find('-isa','Stateflow.Machine');
m = rt.find('-isa','Stateflow.Machine','-and','Name',bdroot(block));

% get the function target.
sfun_t = m.find('-isa','Stateflow.Target','-and','Name','sfun');
sfun_t.ApplyToAllLibs = 0;

% create the rtw target if required.
rtw_t = m.find('-isa','Stateflow.Target','-and','Name','rtw');
if (isempty(rtw_t))
    rtw_t = Stateflow.Target(m);
    rtw_t.name = 'rtw';
    rtw_t.description = 'Auto generated RTW Target';
end;
rtw_t.ApplyToAllLibs = 0;
