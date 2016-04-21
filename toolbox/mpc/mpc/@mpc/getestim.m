function [M,A,Cm,Bu,Bv,Dvm]=getestim(MPCobj,ssoutput)

%GETESTIM returns the model for designing the observer gain used by MPC.
%
%   M=GETESTIM(MPCobj) extracts the estimator gain M used by the 
%   MPC controller 'MPCobj'
%
%            y[n|n-1] = Cm x[n|n-1] + Dvm v[n]
%            x[n|n] = x[n|n-1] + M (y[n]-y[n|n-1])
%            x[n+1|n] = A x[n|n] + Bu u[n] + Bv v[n]
%
%   where v[n] are the measured disturbances
%         u[n] are the manipulated plant inputs
%         y[n] are the measured plant outputs
%         x[n] are the state estimates
%
%   [M,A,Cm]=GETESTIM(MPCobj) also returns matrices A,Cm used for observer
%   design. This includes plant model, disturbance model, noise model,
%   offsets. The extended state is x=[xPlant;xDisturbance;xNoise], the
%   extended input is u=[manipulated vars;measured disturbances; 1; noise
%   exciting disturbance model;noise exciting noise model].
%
%   To design an estimator by pole placement, one can use the commands
%
%   [M,A,Cm]=getestim(MPCobj);
%   L=place(A',Cm',observer_poles)';
%   M=A\L;
%   setestim(MPCobj,M);
%
%   assuming that the system A*M=L is solvable.
%
%   [M,A,Cm,Bu,Bv,Dvm]=GETESTIM(MPCobj) retrieves the whole linear
%   system used for observer design.
%
%   [M,model,Index]=GETESTIM(MPCobj,'sys') retrieves the overall model
%   used for observer design (specified in the Model field of the MPC
%   object) as an LTI state-space object, and optionally a structure
%   'Index' summarizing I/O signal types.
%
%   NOTE:  variable M in GETESTIM is equivalent to variable M in DKALMAN.
%
%   See also SETESTIM, DKALMAN, MPCPROPS.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2004/04/16 22:08:55 $

if nargin<1,
    error('mpc:getestim:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:getestim:obj','Invalid MPC object');
end
if isempty(MPCobj),
    error('mpc:getestim:empty','Empty MPC object');
end

if nargin<2 | isempty(ssoutput),
    ssoutput='mat';
else
    if ~ischar(ssoutput)|(~strcmp(ssoutput,'sys')&~strcmp(ssoutput,'mat')),
        error('mpc:getestim:type','Unknown model type option. Supported types are ''sys'' and ''mat''');
    end
end

MPCData=getmpcdata(MPCobj);
InitFlag=MPCData.Init;
update_flag=0;

if ~InitFlag | ~isfield(MPCData.MPCstruct,'C'),
    % Initialize MPC object (to define QP model and full model for observer design)
    try
        MPCstruct=mpc_struct(MPCobj,[],'ssmodel'); % xmpc0=[]
    catch
        rethrow(lasterror);
    end
    update_flag=1;
else
    MPCstruct=MPCData.MPCstruct;
end

% Retrieves parameters from MPCstruct, MPCData
MPCData=getmpcdata(MPCobj);
M=MPCstruct.M;

if nargout>1,
    A=MPCstruct.A;
    if strcmp(ssoutput,'mat'),
        nx=MPCstruct.nx;
        nym=MPCstruct.nym;
        Cm=MPCstruct.Cm;
        if nargout>3,
            Bu=MPCstruct.Bu;
            if nargout>4,
                Bv=MPCstruct.Bv;
                if nargout>5,
                    Dvm=MPCstruct.Dvm;
                end
            end
        end
    else
        nxp=MPCstruct.nxp;
        mdindex=MPCData.mdindex;
        mvindex=MPCData.mvindex;
        myindex=MPCData.myindex;
        unindex=MPCData.unindex;
        nutot=MPCData.nutot;
        nnUMDyint=MPCstruct.nnUMDyint; % number of white noise signals driving output dist. model (e.g. integrators)
        nnUMD=MPCstruct.nnUMD; % number of white noise signals driving Model.Disturbance
        nnMN=MPCstruct.nnMN; % number of white noise signals driving Model.Noise
        nv=MPCstruct.nv; % number of measured disturbances (including v=1 for taking into account offsets)
        ny=MPCData.ny;
        nu=MPCData.nu;
        nxumd=MPCstruct.nxumd;

        nxnoise=MPCstruct.nxnoise;
        Bmn=MPCstruct.Bmn;
        Dmn=MPCstruct.Dmn;

        % Retrieves input/output/state names from Model.Plant
        plant=MPCobj.Model.Plant;
        yname=plant.OutputName;
        for i=1:ny,
            if isempty(yname{i}),
                yname{i}=sprintf('y%d',i);
            end
            if ismember(i,myindex),
                yname{i}=[yname{i} '(meas.)'];
            else
                yname{i}=[yname{i} '(unmeas.)'];
            end
        end

        uname=plant.InputName;
        for i=1:nutot,
            signal='u';
            if ismember(i,mdindex),
                signal='v';
            end
            if isempty(uname{i}),
                uname{i}=sprintf('%s%d',signal,i);
            end
            %switch type
            %    case 'u'
            %        uname{i}=[uname{i} ' (MV)'];
            %    case 'v'
            %        uname{i}=[uname{i} ' (MD)'];
            %end
        end
        uname{nutot+1}='Offset(=1)';
        %remove UD signals
        uname=uname([mvindex(:);mdindex(:);nutot+1]);

        %if strcmp(type,'estimator'),
        % Now adds names for noise driving the unmeasured disturbance model (including output
        % integrators) and measurement noise model

        for i=1:nnUMD,
            uname{i+nu+nv}=sprintf('InDist%d',i);
        end
        for i=1:nnUMDyint,
            uname{i+nu+nv+nnUMD}=sprintf('OutDist%d',i);
        end
        for i=1:nnMN,
            uname{i+nu+nv+nnUMD+nnUMDyint}=sprintf('OutNoise%d',i);
        end
        %for i=1:nu+nv,
        %    uname{i+nu+nv+nnUMD+nnUMDyint+nnMN}=sprintf('InNoise%d',i);
        %end
        %end

        if isa(plant,'ss'),
            xname=plant.StateName;
            for i=1:nxp,
                if isempty(xname{i}),
                    xname{i}=sprintf('x%dplant',i);
                end
            end
        else
            xname={};
            for i=1:nxp,
                xname{i}=sprintf('x%dplant',i);
            end
        end
        for i=1:nxumd,
            xname{i+nxp}=sprintf('x%ddist',i);
        end
        %if strcmp(type,'estimator'),
        for i=1:nxnoise,
            xname{i+nxp+nxumd}=sprintf('x%dnoise',i);
        end
        %end

        %if strcmp(type,'estimator'),
        B=MPCstruct.B;

        % Removes columns corresponding to noise added on manipulated vars
        % and measured disturbances (including noise added on the
        % additional MD=1)
        B(:,end-nu-nv+1:end)=[];

        % Replace the columns corresponding to nxnoise by Bmn;
        nuaux=nu+nv+nnUMD+nnUMDyint;
        Bnew=B(:,nuaux+1:nuaux+nxnoise)*Bmn;
        B(:,nuaux+1:nuaux+nxnoise)=[];
        B=[B,Bnew];

        C=MPCstruct.C;
        D=MPCstruct.D;
        % Removes columns corresponding to noise added on MVs and MDs
        D(:,end-nu-nv+1:end)=[];

        % Add Dmn
        D=[D(:,1:nuaux),zeros(ny,nnMN),D(:,nuaux+nxnoise+1:end)];
        D(myindex,nuaux+1:nuaux+nnMN)=Dmn;
        model=ss(A,B,C,D,MPCobj.Ts);
        %else
        %    model=MPCstruct.QPmodel;
        %    set(model,'B',model.B(:,1:nu+nv),'D',model.D(:,1:nu+nv));
        %end

        % Convert possible old 6.xx cell format to structure, using mpc_getgroup
        ugroup=mpc_getgroup(plant.InputGroup);
        % Remove the field 'Unmeasured'
        if isfield(ugroup,'Unmeasured'),
            ugroup=rmfield(ugroup,'Unmeasured');
        end
        ugroup.Offset=nu+nv;
        ugroup.WhiteNoise=(nu+nv+1:nuaux+nnMN);

        % Set names and groups
        set(model,'StateName',xname,'InputName',uname,'OutputName',yname,...
            'InputGroup',ugroup,'OutputGroup',plant.OutputGroup);

        % Set groups
        noiseindex=(nu+nv+1:nuaux+nnMN);
        uyindex=setdiff(1:ny,myindex);
        %mdindex=[mdindex(:);nu+nv]; % add v=1

        if update_flag,
            % Update MPC object in the workspace
            MPCData.MPCstruct=MPCstruct;
            MPCData.Init=1;
            MPCData.QP_ready=1;
            MPCData.L_ready=1;
            setmpcdata(MPCobj,MPCData);
            try
                assignin('caller',inputname(1),MPCobj);
            end
        end
        A=model;

        if nargout>=3,
            Index=struct('ManipulatedVariables',mvindex(:),'MeasuredDisturbances',mdindex(:),...
                'Offset',nu+nv,'WhiteNoise',...
                noiseindex(:),'MeasuredOutputs',myindex(:),'UnmeasuredOutputs',uyindex(:));
            Cm=Index;
        end
    end
end
