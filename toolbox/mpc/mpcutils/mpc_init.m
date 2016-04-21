function mpc_init

% MPC_INIT Extract data from MPC Object

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.10 $  $Date: 2004/04/10 23:39:15 $


% Get parameters from MPC block

%gc=get_param(gcb,'Parent'); % Use this when InitFcn or StartFcn is part of the mpcsfun block
gc=gcb;  % Use this when InitFcn or StartFcn is part of the MPC block

% (jgo) run open loop if MPC is empty
mpcobjname = strtrim(get_param(gc,'mpcobj'));
if isempty(mpcobjname)
    nmv = eval(get_param(gc,'n_mv'));
    if ~isnumeric(nmv) || length(nmv)~=1
        set_param(gcs,'SimulationCommand','Stop');
    end
    set_param(gc,'Userdata',[]);
    return
end

mpcobjname=strtrim(get_param(gc,'mpcobj'));
InitialState=strtrim(get_param(gc,'x0'));
if isempty(InitialState),
    InitialState='[]';
end
%InitialInput=get_param(gc,'u0');
%ss_flag=get_param(gc,'ss_flag');
ref_from_ws = get_param(gc,'ref_from_ws');
ref_signal_name = get_param(gc,'ref_signal_name');
if isempty(ref_signal_name),
    ref_signal_name='[]';
end
ref_preview = get_param(gc,'ref_preview');
md_from_ws = get_param(gc,'md_from_ws');
md_signal_name = get_param(gc,'md_signal_name');
if isempty(md_signal_name),
    md_signal_name='[]';
end
md_preview = get_param(gc,'md_preview');

% The object name is obtained from the mask as a string. It must be evaluated.
xmpc0=evalin('base',InitialState); % This may change mpcobj if InitialState=mpcstate(mpcobj)

from_project=get_param(gc,'from_project');

GUIopen=0;
MPCfromWS=0;

if strcmp(from_project,'off'),
    % MPC controller from workspace
    if ~isempty(mpcobjname),
        %hmask=maskhandle;
        %if ~isempty(hmask),
            % The mask is open, controller may be currently edited in the
            % GUI
            [GUIopen,hGUI]=mpc_getGUIstatus(gc);
        %end

        if ~GUIopen,
            MPCfromWS=1;
        else
            % Get current controller in the GUI
            mpcobj=hGUI.getController(mpcobjname);
            if isempty(mpcobj),
                % Controller is no more in the GUI
                MPCfromws=1;
            end
        end
    else
        mpcobj=mpc;
    end

    if MPCfromWS,
        try
            % Load from workspace
            mpcobj=evalin('base',mpcobjname);
        catch
            rethrow(lasterror);
        end
    end
else
    % MPC controller from project
    project_file=get_param(gc,'project_file');    
    project_name=get_param(gc,'project_name');
    
    task_name=get_param(gc,'task_name');

    hmask=maskhandle;
    if ~isempty(hmask), % mask is open

        % Is the GUI also open ?
        [GUIopen,hGUI]=mpc_getGUIstatus(gc);

        if ~GUIopen
            % Load from project (GUI closed)
        else
            % Load from GUI (if GUI and mask is open)

            % Extracts "current" MPC object most recently viewed/modified
            mpcobj=hGUI.getController;
        end
    else
        % Load from project (GUI closed)
        mpcobj=mpc_loadobj(project_file,project_name,task_name,mpcobjname);
    end
end

%u1=evalin('base',InitialInput);
% ss_flag is already a string ('on' or 'off')

if ~isa(mpcobj,'mpc'),
    error('mpc:mpc_init:obj','MPC object must be a valid MPC object.');
end
if isempty(mpcobj),
    error('mpc:mpc_init:empty','Empty MPC object.');
end


if isempty(xmpc0),
    xmpc0=mpcstate(mpcobj); % Empty mpcstate object
end
if ~isa(xmpc0,'mpcdata.mpcstate'),
    error('mpc:mpc_init:state','Initial controller state must be a valid MPCSTATE object. Type HELP MPCSTATE for more details');
end

MPCData=getmpcdata(mpcobj);
InitFlag=MPCData.Init;
if ~InitFlag,
    % Initialize MPC object (QP matrices and observer)
    try
        MPCstruct=mpc_struct(mpcobj,xmpc0,'mpc_init');
    catch
        rethrow(lasterror);
    end

    % Update MPC object in the workspace
    MPCData=getmpcdata(mpcobj);
    MPCData.Init=1;
    MPCData.QP_ready=1;
    MPCData.L_ready=1;
    MPCData.MPCstruct=MPCstruct;
    setmpcdata(mpcobj,MPCData);
    if MPCfromWS,
        try
            assignin('caller',mpcobjname,mpcobj);
        end
    end
else
    MPCstruct=MPCData.MPCstruct;

    % Update initial state and initial input
    nxp=MPCstruct.nxp;
    xpoff=MPCstruct.xpoff;

    xp0=xmpc0.Plant;
    xd0=xmpc0.Disturbance;
    xn0=xmpc0.Noise;

    try
        xp0=mpc_chkx0u1(xp0,nxp,xpoff,'Initial plant model state'); % Check consistency of xp0
        xp0=xp0-xpoff; % Initial condition for the linearized plant

        xd0=mpc_chkx0u1(xd0,MPCstruct.nxumd,zeros(MPCstruct.nxumd,1),'Initial disturbance model state');
        xn0=mpc_chkx0u1(xn0,MPCstruct.nxnoise,zeros(MPCstruct.nxnoise,1),'Initial noise model state');

        % Form extended state vector
        x0=[xp0;xd0;xn0];

        u1=xmpc0.LastMove;
        nu=MPCstruct.nu;
        uoff=MPCstruct.uoff;
        u1=mpc_chkx0u1(u1,nu,uoff,'Initial Input');% Check consistency of u1
        u1=u1-uoff; % Initial condition for linearized input
    catch
        rethrow(lasterror);
    end

    MPCstruct.lastx=x0;
    MPCstruct.lastu=u1;
end



% Determine if measured disturbance port is connected
ports=get_param(gc,'PortConnectivity');

no_md=false;
md_inport = get_param(gc,'md_inport');
if strcmp(md_inport,'on'),
    % MD signal enabled
    if ports(3).SrcBlock<0,
        % Measured disturbance is not connected, but Simulink has added a
        % scalar zero to yrd
        no_md=true;
    end
else
    no_md=true;
end


% Determine if reference port is connected
no_ref=false;
if ports(2).SrcBlock<0,
    % Reference signal is not connected, must replace the scalar zero added by Simulink to yrd
    % with a vector of 0s
    no_ref=true;
end

% Determine if output measurement port is connected
no_ym=false;
if ports(1).SrcBlock<0,
    % Measured output signal is not connected, must replace the scalar zero 
    % added by Simulink to yrd with a vector of 0s
    no_ym=true;
end

MPCstruct.no_ref=double(no_ref); % RTW doesn't like non-numerical values !!
MPCstruct.no_md=double(no_md);
MPCstruct.no_ym=double(no_ym);


% External signals and preview parameters
MPCstruct.ref_from_ws=double(strcmp(ref_from_ws,'on')); %1='on', 0='off'
MPCstruct.ref_preview=double(strcmp(ref_preview,'on'));
MPCstruct.ref_signal_name=ref_signal_name;
MPCstruct.md_from_ws=double(strcmp(md_from_ws,'on'));
MPCstruct.md_preview=double(strcmp(md_preview,'on'));
MPCstruct.md_signal_name=md_signal_name;
MPCstruct.md_inport=double(strcmp(md_inport,'on'));

% Update MPC object in the workspace
MPCData.MPCstruct=MPCstruct;
setmpcdata(mpcobj,MPCData);
if MPCfromWS,
    try
        assignin('caller',mpcobjname,mpcobj);
    end
end

set_param(gc,'Userdata',MPCstruct);


%-----------------------------------
function hfig=maskhandle

% Is the Simulink mask for this block already open?
blkh = gcbh;
oldsh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
fig = findobj('Type','figure', 'Tag','MPC_mask');
set(0,'ShowHiddenHandles',oldsh');
hfig = findobj(fig, 'flat', 'UserData',blkh);
