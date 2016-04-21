function x=trim(MPCobj,y,u)

%TRIM Steady-state value for extended state vector
%
%   x=trim(MPCobj,y,u) finds a steady-state value for the extended state 
%   vector such that x=Ax+Bu, y=Cx+Du, or the best approximation of such 
%   an x in a least squares sense. x is returned as an MPCSTATE object
%   
%   If offsets are present, then (x-xoff)=A*(x-xoff)+B*(u-uoff),
%                                (y-yoff)=C*(x-xoff)+D*(u-uoff)
%
%   See also MPCSTATE.

%   Author(s): A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.10.6 $  $Date: 2004/04/10 23:35:18 $

if nargin<1,
    error('mpc:trim:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:trim:obj','Invalid MPC object');
end

if MPCobj.MPCData.isempty,
    error('mpc:trim:empty','Empty MPC object');
end

try
    % Get full model and I/O types, and initialize MPCstruct (if needed)
    [M,Model,Index]=getestim(MPCobj,'sys');
catch
    rethrow(lasterror);
end
MPCstruct=MPCobj.MPCData.MPCstruct;

% Retrieves parameters from MPCstruct

nx=MPCstruct.nx;
ny=MPCstruct.ny;
nu=MPCstruct.nu;
nv=MPCstruct.nv-1; % Number of measured dist. (excluding offset=1)
nutot=MPCstruct.nutot;
nxp=MPCstruct.nxp;
nxumd=MPCstruct.nxumd;
nxnoise=MPCstruct.nxnoise;

nnUMDyint=MPCstruct.nnUMDyint; % number of white noise signals driving additional output integrators/dist.model
nnUMD=MPCstruct.nnUMD; % number of white noise signals driving Model.Disturbance
nnMN=MPCstruct.nnMN; % number of white noise signals driving Model.Noise

myindex=Index.MeasuredOutputs;
uyindex=Index.UnmeasuredOutputs;

if nargin<2 | isempty(y),
    my=MPCstruct.myoff;
    uy=MPCstruct.uyoff;
else
    if ~isa(y,'double') | length(y(:))~=ny | ~all(isfinite(y)),
        error('mpc:trim:y',sprintf('Output value Y must be a real valued vector with %d components',ny));
    end
    my=y(myindex);
    uy=y(uyindex);
end



mvindex=Index.ManipulatedVariables;
offindex=Index.Offset;
mdindex=Index.MeasuredDisturbances;
unoise=Index.WhiteNoise;
unindex=MPCobj.MPCData.unindex;

if nargin<3,
    u=MPCstruct.uoff;
    v=MPCstruct.voff;
    d=zeros(nutot-nv-nu,1); % Offsets of UMD are always zero
else
    if ~isa(u,'double') | length(u(:))~=nutot | ~all(isfinite(u)),
        error('mpc:trim:u',sprintf('Input value U must be a real valued vector with %d components',nutot));
    end
    v=u(mdindex);
    d=u(unindex);
    if any(d~=0),
        error('mpc:trim:umd','Input values for unmeasured disturbances must be zero');
    end
    u=u(mvindex);
end

% Trim states
swarn=warning;
warning off; % Prevent rank deficiency when solving algebraic equations

U=zeros(nu+nv+1+length(unoise),1); % All input but MV and MD are zero
U(mvindex)=u-MPCstruct.uoff;
if ~isempty(mdindex),
    U(mdindex)=v-MPCstruct.voff;
end

Y=zeros(ny,1);
Y(myindex)=my-MPCstruct.myoff;
if ~isempty(uyindex),
    Y(uyindex)=uy-MPCstruct.uyoff;
end

%System: x=Ax+Bu  --->  (I-A)^(-1)x=Bu
%        y=Cx+Du  --->           Cx=-Du+y

%    % Don't care about value of states of disturbance model
%    x=[eye(nx)-Model.A;Model.C]\[Model.B*U;Model.D*U-Y];
%    x=mpcstate(x(1:nxp),x(nxp+1:nxp+nxumd),x(nxp+nxumd+1:nxp+nxumd+nxnoise),u(:));

% To improve output fit, the output equation CX=-Du+y could be multiplied
% by a factor rho<1

% States of disturbance model are zeroed
AA=[eye(nxp)-Model.A(1:nxp,1:nxp);Model.C(:,1:nxp)];
BB=[Model.B(1:nxp,:)*U;Y-Model.D*U];

x=AA\BB;

warning(swarn);

x=mpcstate(MPCobj,x+MPCstruct.xoff(1:nxp),...
    zeros(nxumd,1)+MPCstruct.xoff(nxp+1:nxp+nxumd),...
    zeros(nxnoise,1)+MPCstruct.xoff(nxp+nxumd+1:nxp+nxumd+nxnoise),...
    u(:));
