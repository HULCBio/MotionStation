function this = mpcstate(mpcobj,plant,dist,noise,lastu)  

% Copyright 2004 The MathWorks, Inc.

this = mpcdata.mpcstate;
if nargin==0
    return
end
    
if ~isa(mpcobj,'mpc'),
    error('mpc:mpcstate:obj','Invalid MPC object');
end

MPCData = getmpcdata(mpcobj);
if ~MPCData.Init,
    % Initialize MPC object
    try
        MPCstruct = mpc_struct(mpcobj,[],'base');
    catch
        rethrow(lasterror);
    end

    % Update MPC object in the workspace
    MPCData = getmpcdata(mpcobj);
    MPCData.MPCstruct = MPCstruct;
    MPCData.Init = 1;
    MPCData.QP_ready = 1;
    MPCData.L_ready = 1;
    setmpcdata(mpcobj,MPCData);
    try
        assignin('caller',inputname(1),mpcobj);
    end
else
    MPCstruct = MPCData.MPCstruct;
end

nxp = MPCData.MPCstruct.nxp;
nxumd = MPCData.MPCstruct.nxumd;
nxnoise = MPCData.MPCstruct.nxnoise;
nu = MPCData.MPCstruct.nu;

% Possibly assign default values
if nargin<2,
    plant = MPCData.MPCstruct.xoff(1:nxp);
end
if nargin<3,
    dist = MPCData.MPCstruct.xoff(nxp+1:nxp+nxumd);
end
if nargin<4,
    noise = MPCData.MPCstruct.xoff(nxp+nxumd+1:nxp+nxumd+nxnoise);
end
if nargin<5,
    lastu = MPCData.MPCstruct.uoff;
end

% Assign props
set(this,'Plant',plant,'Disturbance',dist,'Noise',noise,'LastMove',lastu);

try
    mpc_chkstate(this,'Plant',nxp,MPCData.MPCstruct.xoff(1:nxp));
    mpc_chkstate(this,'Disturbance',nxumd,MPCData.MPCstruct.xoff(nxp+1:nxp+nxumd));
    mpc_chkstate(this,'Noise',nxnoise,MPCData.MPCstruct.xoff(nxp+nxumd+1:nxp+nxumd+nxnoise));
    mpc_chkstate(this,'LastMove',nu,MPCData.MPCstruct.uoff);
catch
    rethrow(lasterror);
end