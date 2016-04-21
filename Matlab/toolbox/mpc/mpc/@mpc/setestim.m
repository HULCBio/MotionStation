function setestim(MPCobj,M)

%SETESTIM modifies an MPC object's linear state estimator.
%
%   SETESTIM(MPCobj,M) where MPCobj is an MPC object -- changes the default
%   Kalman estimator gain stored in MPCobj to that specified by matrix M.
%
%   SETESTIM(MPCobj,'default') restores the default Kalman gain.
%
%   The estimator used in MPC is
%            y[n|n-1] = Cm x[n|n-1] + Dvm v[n]
%            x[n|n] = x[n|n-1] + M (y[n]-y[n|n-1])
%            x[n+1|n] = A x[n|n] + Bu u[n] + Bv v[n]
%
%   where v[n] are the measured disturbances
%         u[n] are the manipulated plant inputs
%         y[n] are the measured plant outputs
%         x[n] are the state estimates
%
%   To design an estimator by pole placement, one can use the commands
% 
%   [M,model]=getestim(MPCobj);
%   L=place(model.A',model.Cm',observer_poles)';
%   M=A\L;
%   setestim(MPCobj,M);
%
%   assuming that the system A*M=L is solvable.
%
%   NOTE:  variable M in SETESTIM is equivalent to variable M in DKALMAN.
%
%   See also GETESTIM, DKALMAN, MPCPROPS.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2004/04/10 23:35:12 $   

if nargin<1,
    error('mpc:setestim:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:setestim:obj','Invalid MPC object');
end
if isempty(MPCobj),
    error('mpc:setestim:empty','Empty MPC object');
end

MPCData=getmpcdata(MPCobj);
InitFlag=MPCData.Init;
update_flag=0;

if ~InitFlag,
    % Initialize MPC object (QP matrices and observer) 
    try
        MPCstruct=mpc_struct(MPCobj,[],'base'); % xmpc0=[]
        MPCData=getmpcdata(MPCobj);
    catch
        rethrow(lasterror);
    end
    update_flag=1;
else
    MPCstruct=MPCData.MPCstruct;
end

% Retrieves parameters from MPCstruct

nym=MPCstruct.nym;
nx=MPCstruct.nx;

A=MPCstruct.A;
Cm=MPCstruct.Cm;

if nargin>=2,
    if ischar(M),
        if strcmp(M,'default'),
            MPCData.L_ready=0; 
            MPCstruct=mpc_struct(MPCobj,[],'base');
            update_flag=1;
        else
            error('mpc:setestim:option','Unknown option');
        end
    else        
        if ~isa(M,'double'),
            error('mpc:setestim:gain','Observer gain must be a real valued array.')
        elseif ~all(isfinite(M)), %some M(i) are Inf
            error('mpc:setestim:inf','Infinite components in observer gain are not allowed.')
        else
            [n,m]=size(M);
            if (n~=nx)|(m~=nym), 
                error('mpc:setestim:dim',sprintf('Observer gain must have dimension %d-by-%d.',nx,nym));
            end
            e=eig(A-A*M*Cm);
            if any(abs(e)>1),
                warning('mpc:setestim:unstable','Unstable state estimator!');
            end
            MPCstruct.L=M;
            update_flag=1;
        end
    end
end

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
