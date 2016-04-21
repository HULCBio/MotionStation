function [outdist,outdistchannels]=getoutdist(MPCobj)

%GETOUTDIST retrieves the model used for representing output disturbances
%
%   outdist=GETOUTDIST(MPCobj) retrieves the model used to generate output
%   disturbances from the mpc object MPCobj.
%
%   [outdist,channels]=GETOUTDIST(MPCobj) also returns the output channels where
%   integrated white noise was added as output disturbance model (empty for
%   user-provided output disturbance models).
%
%   See also SETOUTDIST.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2004/04/10 23:35:05 $   


if nargin<1,
    error('mpc:getoutdist:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:getoutdist:obj','Invalid MPC object');
end
if isempty(MPCobj),
    error('mpc:getoutdist:empty','Empty MPC object');
end

MPCData=getmpcdata(MPCobj);
ny=MPCData.ny;

if MPCData.OutDistFlag,
    % User defined output disturbance
    outdist=MPCData.OutDistModel;
    outdistchannels=[];
    outdist.outputnames=MPCobj.Model.Plant.Outputnames;
    for i=1:size(outdist,2),
        outdist.inputnames{i}=sprintf('Noise#%d',i);
    end
    return
end

% Output disturbance is the default one

InitFlag=MPCData.Init;

if ~InitFlag,
    % Initialize MPC object (QP matrices and observer) 
    try
        MPCstruct=mpc_struct(MPCobj,[],'mpc_init');
    catch
        rethrow(lasterror);
    end

    % Update MPC object in the workspace
    MPCData=getmpcdata(MPCobj);
    MPCData.Init=1;
    MPCData.QP_ready=1;
    MPCData.L_ready=1;
    MPCData.MPCstruct=MPCstruct;
    setmpcdata(MPCobj,MPCData);
    try
        assignin('caller',inputname(1),MPCobj);
    end
else
    MPCstruct=MPCData.MPCstruct;
end

% One integrator per channel specified in outdistchannels
outdistchannels=MPCstruct.outdistchannels;

ts=MPCobj.Ts;

outnames=MPCobj.Model.Plant.Outputnames;
if isempty(outdistchannels),
    outdist=ss(zeros(ny,0));
else
    nout=length(outdistchannels);
    A=eye(nout);
    B=eye(nout,nout)*ts;
    C=zeros(ny,nout);
    D=zeros(ny,nout);
    for i=1:nout,
        j=outdistchannels(i);
        C(j,i)=1;
    end
    outdist=tf(ss(A,B,C,D,ts));
    for i=1:nout,
        outdist.inputnames{i}=[outnames{outdistchannels(i)} '-wn'];
    end
end
outdist.outputnames=MPCobj.Model.Plant.Outputnames;