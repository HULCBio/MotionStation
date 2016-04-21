function offset=cloffset(MPCobj)

%CLOFFSET computes the MPC closed-loop DC gain from output disturbances to measured 
%   outputs based on the unconstrained response (for zero references, measured,
%   and unmeasured input disturbances).
%
%   DC=CLOFFSET(MPCobj) returns an (nym,nym) DC gain matrix where
%   nym is the number of measured plant outputs.  MPCobj is an MPC object 
%   specifying the controller for which the closed-loop gain is calculated.
%   DC(i,j) represents the gain from an additive (constant) disturbance
%   on output j to measured output i.  If row i is zero, there will be no
%   steady-state offset on output i.
%
%   See also MPC, SS.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2004/04/10 23:35:00 $   

if nargin<1,
    error('mpc:cloffset:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:cloffset:obj','Invalid MPC object');
end
if isempty(MPCobj),
    error('mpc:cloffset:empty','Empty MPC object');
end

MPCData=getmpcdata(MPCobj);
InitFlag=MPCData.Init;
update_flag=0;

if ~InitFlag,
    % Initialize MPC object (QP matrices and observer) 
    try
        MPCstruct=mpc_struct(MPCobj,[],'base'); % xmpc0=[]
    catch
        rethrow(lasterror);
    end
    update_flag=1;
else
    MPCstruct=MPCData.MPCstruct;
end

% Retrieves parameters from MPCstruct

nym=MPCstruct.nym;
A=MPCstruct.A;
Bu=MPCstruct.Bu;
Cm=MPCstruct.Cm;

% Before invoking SS, update object in workspace

if update_flag,
    % Update MPC object in the workspace
    MPCData=getmpcdata(MPCobj);
    MPCData.MPCstruct=MPCstruct;
    MPCData.Init=1;
    MPCData.QP_ready=1;
    MPCData.L_ready=1;
    setmpcdata(MPCobj,MPCData);
    try
       assignin('caller',inputname(1),MPCobj);
    end
end

try
    sysmpc=ss(MPCobj);
catch
    rethrow(lasterror);
end
Abar=sysmpc.A;
Bbar=sysmpc.B;
Cbar=sysmpc.C;
Dbar=sysmpc.D;
nxbar=size(Abar,1);

bigC=[Cm,zeros(nym,nxbar)];
bigA=[A+Bu*Dbar*Cm,Bu*Cbar;
    Bbar*Cm,Abar];
bigB=[Bu*Dbar;Bbar];
bigD=eye(nym);

offset=dcgain(ss(bigA,bigB,bigC,bigD,MPCobj.Ts));


if update_flag,
    % Update MPC object in the workspace
    MPCData=getmpcdata(MPCobj);
    MPCData.Init=1;
    MPCData.QP_ready=1;
    MPCData.L_ready=1;
    setmpcdata(MPCobj,MPCData);
    try
        assignin('caller',inputname(1),MPCobj);
    end
end
