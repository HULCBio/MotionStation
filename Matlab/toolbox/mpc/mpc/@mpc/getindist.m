function indist=getindist(MPCobj)

%GETINDIST retrieves the model used for representing input disturbances
%
%   indist=GETINDIST(MPCobj) retrieves the model used by the mpc object 
%   MPCobj to represent unmeasured input disturbances entering the plant.
%
%   See also SETINDIST, SET.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2004/04/10 23:35:04 $   

if nargin<1,
    error('mpc:getindist:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:getindist:obj','Invalid MPC object');
end
if isempty(MPCobj),
    error('mpc:getindist:empty','Empty MPC object');
end

MPCData=getmpcdata(MPCobj);
unindex=MPCData.unindex;

if isempty(unindex),
    indist=ss;
    return
end

if ~isempty(MPCobj.Model.Disturbance),
    % User defined input disturbance
    indist=MPCobj.Model.Disturbance;
    indist.outputnames=MPCobj.Model.Plant.Inputnames(unindex);
    for i=1:size(indist,2),
        if isempty(indist.inputnames{i}),
            indist.inputnames{i}=sprintf('Noise#%d',i);
        end
    end
    indist=mpc_chkoutdistmodel(indist,length(unindex),MPCobj.Ts,'Input');
    return
end

% Input disturbance model is the default one

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

% One integrator per input channel, assuming the system remains observable
indistchannels=MPCstruct.indistchannels;

ts=MPCobj.Ts;
nun=length(unindex);
nindist=length(indistchannels);
notindist=setdiff(1:nun,indistchannels);
M=eye(nun);
M(:,notindist)=[];
indist=c2d(M*tf(1,[1 0]),ts);

% User defined input disturbance
innames=MPCobj.Model.Plant.Inputnames(unindex);
indist.outputnames=innames;
for i=1:nindist,
    if isempty(indist.inputnames{i}),
        indist.inputnames{i}=[innames{indistchannels(i)} '-wn'];
    end
end