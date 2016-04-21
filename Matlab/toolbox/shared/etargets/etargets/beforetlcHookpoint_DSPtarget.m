function target_state = beforetlcHookpoint_DSPtarget(target_state, modelInfo)

% $RCSfile: beforetlcHookpoint_DSPtarget.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:36:54 $
%% Copyright 2001-2003 The MathWorks, Inc.


deleteOldProjectFiles_TItarget (modelInfo);

% force generate code only (required by 'rtw_c' to skip execution
% of generated makefile)
set_param(modelInfo.name,'RTWGenerateCodeOnly','on');

if (~rtdx_callback ('ChName'))
    error ('All RTDX channel names must be unique.')
end

if isNotGenerateCodeOnly_DSPtarget(modelInfo.buildArgs),
    
    % if BIOS is enabled, check for presence of TCONF patch
    if isUsingDSPBIOS_TItarget(modelInfo),
        try
            patchPresent = logical(winqueryreg('HKEY_LOCAL_MACHINE',...
                'SOFTWARE\GODSP\CodeComposer\Plugins\Server Tools\BiosConfig',...
                'Version'));
        catch
            error(sprintf(['To generate DSP/BIOS projects, you must apply the patch \n'...
                    '"CCStudio v2.1 - Config Server Registration Fix" \n',...
                    'to Code Composer Studio version 2.1.\n\n',...
                    'The patch may be downloaded from \n',...
                    'https://www-a.ti.com/downloads/sds_support/ALL-2.00-SA-to-TI-BIOSRTA-REG01.htm']));
        end
    end
    
    % construct target IDE object and store board IDs to reset blocks
    target_state=connectToIDE_TItarget(target_state,modelInfo);
    
    % all text files MUST be closed here, before 'beforemakeHookpoint' or else
    % newly generated files may cause CCS modal message to include new versions
    % of opened files to old project
    target_state.ccsObj.close('all','text');
end

% Check for errors in model
checkModelAndSystem_DSPtarget(modelInfo);

% Clear persistent data in profile report generator 
ti_profreport('clear');

% [EOF] beforetlcHookpoint_DSPtarget.m
