function c6000_callback(action,varargin)
% C6000_CALLBACK - TI C6000 Target
%    dynamic dialog callback handler
%
% $Revision: 1.1.6.2 $ $Date: 2004/02/06 00:29:53 $
% Copyright 2001-2004 The MathWorks, Inc.

s.action = action;
s.hSrc = varargin{1};
s.hDlg = varargin{2};

switch action

    case 'callback',

        s.currentVar = varargin{3};
        s.currentVal = getVal(s, s.currentVar);
        feval([s.currentVar '_callback'], s);

    case 'ActivateCallback',

        % This is when we have access to the  actual user values of the
        % options, so we can set the enable-states of the dependent
        % options.

        % Turn off logging if using GRT-based target.  If ERT-based, this
        % is a user option, so we error out later and tell the user to turn
        % off logging.
        if strcmp( getVal(s,'SystemTargetFile'), 'ti_c6000.tlc'),
            setVal(s, 'MatFileLogging','off');
        end
        
        % Execute all dynamic-dialog callbacks:
        callbacks = {'BoardType','exportCCSObj','useDSPBIOS', ...
            'LinkerCommandFile','c6000BuildAction','OverrunAction'};
        for k = 1:length(callbacks),
            s.currentVar = callbacks{k};
            s.currentVal = getVal(s, s.currentVar);
            feval([s.currentVar '_callback'], s);
        end

        % Propagate the old C6000 Endiannes option to new Hardware widget.
        % Get this info from the configuration set "extra options'.
        % If this transfer fails for some reason, RTW will still treat it
        % as "unspecified" and generate code to determine endianness at
        % run-time.
        try
            if strcmp(getVal(s, 'ProdEndianess'), 'Unspecified'),
                cs = getActiveConfigSet(gcs);
                eo = cs.ExtraOptions;
                f = findstr(eo,'-aEndianness="');
                if ~isempty(f)
                    f2 = f(1) + length('-aEndianness=') + 1;
                    endian1 = strtok(eo(f2:end),'"');
                    switch endian1
                        case 'Big_endian',
                            setVal(s, 'ProdEndianess', 'BigEndian');
                        case 'Little_endian',
                            setVal(s, 'ProdEndianess', 'LittleEndian');
                    end
                end
            end
        end


    case 'SelectCallback',

        % Turn off logging if using GRT-based target.
        if strcmp( getVal(s,'SystemTargetFile'), 'ti_c6000.tlc'),
            setVal(s, 'MatFileLogging','off');
        end
        
        % Disable Generate Code Only checkbox.
        setEnable(s, 'GenCodeOnly', 0);

        % Set Hardware tab items to appropriate settings for C6000
        try
            setVal(s, 'ProdEqTarget', 'on');
            setVal(s, 'ProdHWDeviceType','TI C6000');
        end

        % Execute all dynamic-dialog callbacks:
        widgetsWithCallbacks = {'BoardType','exportCCSObj','useDSPBIOS', ...
            'LinkerCommandFile','c6000BuildAction','OverrunAction'};
        for k = 1:length(widgetsWithCallbacks),
            s.currentVar = widgetsWithCallbacks{k};
            s.currentVal = getVal(s, s.currentVar);
            feval([s.currentVar '_callback'], s);
        end

    case 'UnselectCallback',

        % Re-enable GCO checkbox.
        setEnable(s, 'GenCodeOnly', 1);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%     Callbacks     %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function BoardType_callback(s)

% Update the enable-state of the C6701EVM Clock Rate popup
% and High-Speed RTDX checkbox.
if strcmp(s.currentVal,'C6701EVM'),
    setEnable(s,'c6701evmCpuClockRate',1)
    setEnable(s,'useHSRTDX',0)
else
    setEnable(s,'c6701evmCpuClockRate',0)
    setEnable(s,'useHSRTDX',1)
end

% --------------------------------------------------------------------
function exportCCSObj_callback(s)

if strcmp(s.currentVal,'on'),
    setEnable(s,'ccsObjName',1);
else
    setEnable(s,'ccsObjName',0);
end

% --------------------------------------------------------------------
function useDSPBIOS_callback(s)
% Checkbox: Incorporate DSP/BIOS
%  ... controls ...
% Checkbox: Profile performance at atomic subsystem boundaries

if strcmp(s.currentVal,'on'),
    setEnable(s,'ProfileGenCode',1);
else
    setEnable(s,'ProfileGenCode',0);
end

% --------------------------------------------------------------------
function LinkerCommandFile_callback(s)

if strcmp(s.currentVal,'User_defined'),
    setEnable(s,'UserLinkerCommandFile',1);
else
    setEnable(s,'UserLinkerCommandFile',0);
end


% --------------------------------------------------------------------
function c6000BuildAction_callback(s)

switch s.currentVal
    case 'Generate_code_only',
        updateEnablesForBuildAction(s, 'off');
    otherwise,
        updateEnablesForBuildAction(s, 'on');
end

% --------------------------------------------------------------------
function OverrunAction_callback(s)

switch s.currentVal
    case 'None',
        setEnable(s,'OverrunNotificationMethod',0);
    otherwise,
        setEnable(s,'OverrunNotificationMethod',1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%     Helper functions     %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function updateEnablesForBuildAction(s, state)
% Set certain build options enables to all be 'on' or 'off',
% according to whether the Build Action is
% Generate_code_only or not.

% CCS Obj
setEnable(s,'exportCCSObj',state);
val = getVal(s, 'exportCCSObj');
if strcmp(val,'on'),
    setEnable(s,'ccsObjName',state);
else
    setEnable(s,'ccsObjName',0);
end

% DSP/BIOS is not supported in GCO mode.
setEnable(s,'useDSPBIOS',state);

% Profile checkbox depends on BIOS checkbox
val = getVal(s, 'useDSPBIOS');
if strcmp(val,'on'),
    setEnable(s,'ProfileGenCode',state);
else
    setEnable(s,'ProfileGenCode',0);
end

% Set enable states of all compiler options
setEnable(s,'optLevel',          state);
setEnable(s,'CompilerVerbosity', state);
setEnable(s,'SymbolicDebugOnC6x',state);
setEnable(s,'RetainAsmFiles',    state);
setEnable(s,'RetainObjFiles',    state);

% Set enable states of all linker options
setEnable(s,'CreateMapFile',     state);
setEnable(s,'LinkerCommandFile', state);
val = getVal(s, 'LinkerCommandFile');
if strcmp(val,'User_defined'),
    setEnable(s,'UserLinkerCommandFile',state);
else
    setEnable(s,'UserLinkerCommandFile',0);
end

% --------------------------------------------------------------------
function setEnable(s, propName, state)

% Allow either number or string representation
if strcmp(state,'on'),
    state = 1;
elseif strcmp(state,'off'),
    state = 0;
end

slConfigUISetEnabled(s.hDlg,s.hSrc,propName,state);

% --------------------------------------------------------------------
function val = getVal(s, propName)

val = slConfigUIGetVal(s.hDlg, s.hSrc, propName);

% --------------------------------------------------------------------
function setVal(s, propName, val)

slConfigUISetVal(s.hDlg, s.hSrc, propName, val);

% [EOF] c6000_callback.m
