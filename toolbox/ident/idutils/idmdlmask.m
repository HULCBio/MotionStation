function varargout=idmdlmask(Action,varargin)
%IDMDLMASK  Initialize Mask for Idmdlsim block.
%
%  This function is meant to be called only by the Idmdlsim Block mask.
%

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/10 23:18:37 $


lwarn = lastwarn;warn = warning('off');

switch Action,
    case 'InitializeData',
        % Used both for initializing and updating after Apply
        % RE: The mask variable sys and IC (X0) are automatically reevaluated
        %     in the proper workspace when the mask init callback is executed.
        [CB,sys,X0,noi,seed] = deal(varargin{:});
        
        % Check mask data (already evaluated)
        [A,B,C,D,Ts,X0,tsn,variance,ActSeed,sysname,Tdi] = LocalCheckData(CB,sys,X0,noi,seed);
       
        % Return data to Mask workspace (for initialization of blocks underneath)
        varargout = {A,B,C,D,Ts,Tdi,X0,tsn,variance,ActSeed,sysname};
        
    case 'UpdateDiagram'
        
        [CB,Ts,noi] = deal(varargin{:});
        % Update diagram
        LocalUpdateDiagram(CB,Ts,noi);
        
    case 'MaskLTICallback'
        % Callback from editing LTI system field
        % RE: 1) Only enables/disables the X0 edit field. Do not attempt to run mask
        %        init (would disable Cancel) or reset dialog entries here (must wait
        %        for Apply)
        %     2) Callback name hardwired in block property 'MaskCallbacks'
        CB = varargin{1};
        MaskVal = get_param(CB,'MaskValues');
        str = get_param(CB,'MaskEnables');
        noi = MaskVal(3);
        str{4} = noi{1};
        sys = evalin('base',MaskVal{1},'[]');
        if isempty(sys)
            return
        elseif isa(sys,'idss')|isa(sys,'idgrey')
            str{2} = 'on';
        else
            str{2} = 'off';
        end
        set_param(CB,'MaskEnables',str);
        
    case 'InitializeVars',
        % Nothing is done here
        
end

warning(warn);lastwarn(lwarn);

%-------------------------------Internal Functions----------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCheckData %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

function [A,B,C,D,Ts,X0,tsn,variance,ActSeed,sysname,Tdi] = LocalCheckData(CB,sys,X0,noi,seed)
% Checks system data

% Defaults
A=[]; B=[]; C=[]; D=1; Tdi=0; Tdo=0; Ts=0; sysname = '???';nu=1;
tsn = 0; variance = []; ActSeed = 1001;

MaskVal = get_param(CB,'MaskValues');

% Check type and dimension of LTI object
if ~isa(sys,'idmodel'),
    LocalIDModelError('The IDModel system variable must be a valid IDModel.')
elseif isa(sys,'idfrd') 
    % IDFRDs not supported
    LocalIDModelError('The IDModel block does not support IDFRD models.');
else
    nu = size(sys,'nu');
    % Convert to noise channel to input (Revisit: should we use innovations
    % form)
    if noi
        sys = noisecnv(sys,'Normalize');
    else
        sys = sys('m');
    end
end    

% Extract state-space data
[A,B,C,D,K,X0m] = ssdata(sys);   

Ts = abs(sys.Ts);
sysname = MaskVal{1};
Tdi = pvget(sys,'InputDelay');
if any(Tdi<0)
    LocalIDModelError('Only positive InputDelays are handled by IDMDLSIM.');
    return
end
if any(Tdi>0)&Ts % move inputdelays to model if discrete time
    sys = inpd2nk(sys);
end
% Validate initial condition
% RE: Make sure SET_PARAM never executes during initialization (recursive call -> error)
is_ss = isa(sys,'idss')|isa(sys,'idgrey');
if ~is_ss & ~isempty(X0)
    % Ignore initial condition
    try
        % Only for dialog's Apply callback. Errors out when called during mask init.
        set_param(CB,'MaskValues',{MaskVal{1};'[]';MaskVal{3};MaskVal{4}}) 
    end
    X0 = 0;
else
    if ischar(X0)
        switch lower(X0(1))
            case 'm'
                X0 = X0m;
            case 'z'
                X0 = zeros(size(X0m));
        end
    end
    if ~isa(X0,'double')
        LocalIDModelError(['The Initial state must either be 0, ''z'', ''m'' (within quotes)',...
                ' or a vector of length = # of states.']);
    end
    if is_ss & ~any(length(X0)==[1 size(sys,4)])
        % Wrong length
        if ~isempty(X0)
            LocalIDModelError(sprintf('%s\n%s',...
                'Length of Initial State vector does not match number of states.',...
                'Using zero Initial State instead.'))
        end
        try
            % Only for dialog's Apply callback. Errors out when called during mask init.
            set_param(CB,'MaskValues',{MaskVal{1};'0';MaskVal{3};MaskVal{4}}) 
        end
        X0 = 0;
    end
    
    % Correctly set enable state of IC edit box 
    if is_ss
        if noi
            set_param(CB,'MaskEnables',{'on';'on';'on';'on'})
        else
            set_param(CB,'MaskEnables',{'on';'on';'on';'off'})
        end
        
    else
        if noi
            set_param(CB,'MaskEnables',{'on';'off';'on';'on'})
        else
            set_param(CB,'MaskEnables',{'on';'off';'on';'off'})
        end
        
    end
end

% Handle the band limited white noise block
if ~noi
    variance = '0';
    tsn = 1;
else
    if Ts
        variance = Ts;
        tsn = variance;
    else
        % Find out the natural dynamics
        [dum,tsn] = iddeft(sys);
        variance = tsn;
        tsn = variance;
    end
end

ny = size(C,1);
if isempty(seed)
    % Get the state of the random number generator
    S = rand('state');
    % Set the state of the random number generator to a new value each time
    rand('state',sum(100*clock)) 
    ss = randn(1,ny);    
    ActSeed = floor(10000*ss);
    % Restore the old random state
    rand('state',S);
else
    ActSeed = evalin('base',['[',seed,']']);
end

if length(ActSeed)~=ny
    erm = ['If you specify random seeds, there must be ',int2str(ny),' of them.'];
    LocalIDModelError(erm)
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalUpdateDiagram %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateDiagram(CB,Ts,noi)

SSBlockName = strvcat(...
    find_system(CB,'FollowLinks','on','LookUnderMasks','all','blocktype','StateSpace'),...
    find_system(CB,'FollowLinks','on','LookUnderMasks','all','blocktype','DiscreteStateSpace'));
if size(SSBlockName,1)~=1
    % Should never happen
    return
end
IsDiscreteBlock = strcmp(get_param(SSBlockName,'blocktype'),'DiscreteStateSpace');

% Flag for Input Transport Delay
HasDelayBlock = ~isempty(find_system(CB,...
    'FollowLinks','on', ...            
    'LookUnderMasks', 'all', ...
    'MaskType','Transport Delay (masked)', ...
    'Tag','InputDelayBlock'));
if ~HasDelayBlock, % It got deleted some how, add it back.
    % In1 may or may not be present ... check?
    delete_line(CB,'Mux/1','IdModel/1');
    add_block('identextras/Transport Delay (masked)',[CB '/Tdi'], ...
        'DelayTime', 'Tdi', 'Position', [70 30 100 60],...
        'Tag','InputDelayBlock');
    add_line(CB,'Mux1/1','Tdi/1'      );
    add_line(CB,'Tdi/1' ,'IdModel/1');
end % if ~HasDelayBlock

% Flag for Band Limited Noise
HasNoiseBlock = ~isempty(find_system(CB,...
    'FollowLinks','on', ...            
    'LookUnderMasks', 'all', ...
    'MaskType','Band-Limited White Noise.', ...
    'Tag','NoiseBlock'));

if (~HasNoiseBlock && noi), % It got deleted recreate it.
    % Change the mux block to have two inputs
    set_param([CB,'/Mux'],'Inputs','2');
    % Add the noise block
    add_block('simulink/Sources/Band-Limited White Noise',[CB '/NoiseBlock'],...
        'Position', [25 105 55 135],...
        'Tag','NoiseBlock');
    set_param([CB,'/NoiseBlock'],...
                'Seed','ActSeed',...
                'Cov','variance',...
                'Ts','tsn');
    % Connect the noise block to the mux
    add_line(CB,'NoiseBlock/1','Mux/2');
elseif (HasNoiseBlock && ~noi), % It does not need it if it has it.
    % Delete the line connecting the noise block to the mux block
    delete_line(CB,'NoiseBlock/1','Mux/2');
    % Change the mux block to have one input
    set_param([CB,'/Mux'],'Inputs','1');
    % Delete the noise block
    delete_block([CB '/NoiseBlock']);
end % if ~HasNoiseBlock

% Discrete/Continuous checks
if xor(IsDiscreteBlock,Ts)
    % System is discrete but current block is continuous, or converse
    Orient = get_param(SSBlockName,'orientation');
    Size = get_param(SSBlockName,'position');
    delete_block(SSBlockName);
    if Ts
        add_block('built-in/DiscreteStateSpace',SSBlockName, ...
            'Orientation',Orient,...
            'Position'   ,Size);
        set_param([CB,'/Internal'], ...
            'A'          ,'A' , ...
            'B'          ,'B' , ...
            'C'          ,'C' , ...
            'D'          ,'D' , ...
            'X0'         ,'X0', ...
            'Sample time','Ts');
    else
        add_block('built-in/StateSpace',SSBlockName, ...
            'Orientation',Orient        , ...
            'Position'   ,Size);
        set_param([CB,'/Internal'], ...
            'A'          ,'A' , ...
            'B'          ,'B' , ...
            'C'          ,'C' , ...
            'D'          ,'D' , ...
            'X0'         ,'X0');
    end
end 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalIDModelError(msg)
% Display error messages

InitFlag=strcmp(get_param(bdroot(gcb),'SimulationStatus'),'initializing');
if InitFlag,
    errordlg(msg,'Simulink Initialization Error','modal');
else
    errordlg(msg,'ID Model Block Error','modal');
end    
