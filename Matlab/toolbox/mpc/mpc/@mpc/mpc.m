function MPCobj = mpc(varargin)
%MPC  Create an MPC controller object.
%
%   MPCOBJ = MPC(PLANT) creates the MPC object based on the discrete-time,
%   LTI model PLANT.
%
%   MPCOBJ = MPC(PLANT,TS) specifies a sampling time for the MPC controller.
%   If PLANT is a continuous-time LTI model, it is discretized with sampling time
%   TS.  If PLANT is discrete-time LTI, it is resampled to sampling time TS.
%
%   MPCOBJ = MPC(PLANT,TS,P) specifies the prediction horizon P.
%   P is a positive, finite integer.
%
%   MPCOBJ = MPC(PLANT,TS,P,M) specifies the control horizon, M. M is either an
%   integer (<= P) or a vector of blocking factors such that sum(M) <= P.
%
%   Weights and constraints on outputs, inputs, input rates, as well as other
%   properties, can be specified using
%
%         SET(MPCOBJ,Property1,Value1,Property2,Value2,...)
%     or
%         MPCOBJ.Property = Value
%
%   Type MPCPROPS for details.
%
%   Disturbance models and operating conditions can be directly specified using
%   the syntax:
%
%   MPCOBJ = MPC(MODELS,TS,P,M) where MODELS is a structure containing
%      MODELS.Plant = LTI plant model
%            .Disturbance = LTI model describing the input disturbances.
%                           This model is assumed to be driven by unit variance
%                           white noise.
%            .Noise = LTI model describing the plant output measurement noise.
%                           This model is assumed to be driven by unit variance
%                           white noise.
%            .Nominal = structure specifying the plant nominal conditions
%                       (e.g., at which the plant was linearized).
%
%   MPCOBJ = MPC creates an empty MPC object
%
%   See also SET, MPCPROPS, GET, MPCVERBOSITY.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.10.8 $  $Date: 2004/04/10 23:35:06 $

default=mpc_defaults;

swarn=warning;
verbinit=warning('query','mpc:verbosity:init');
verbinit=verbinit.state;
if strcmp(verbinit,'on'),
    % MPC Verbosity was not initialized yet
    warning('off','mpc:verbosity:init');
    % Set level of verbosity to the default value
    warning(default.verbosity,'mpc:verbosity');
end

%swarn=warning;
%warning backtrace off; % to avoid backtrace

ni = nargin;
if ni<1,
    %   Note: the idea of using MPC to invoke the Model Predictive Control Toolbox
    %   Graphical User Interface does not work when loading an MPC object from
    %   a .mat file. In this case, LOAD creates an empty MPC object to define
    %   the fields.
    %% Invokes the GUI
    %mpctool

    % Empty MPC object

    ManipulatedVariables=[];
    OutputVariables=[];
    Weights=[];
    Model=[];
    Ts=[];
    Optimizer=[];
    p=[];
    moves=[];
    Private=[];
    Private.isempty=1;
    DV=[];

    %     Private.mvindex=[];
    %     Private.myindex=[];
    %     Private.mdindex=[];
    %     Private.unindex=[];
    %     Private.nutot=[];
    %     Private.ny=[];
    %     Private.nu=[];
    %     Private.QP_ready=0;
    %     Private.L_ready=0;
else
    Model=varargin{1};

    if isa(Model,'mpc'),
        % Quick exit for MPC(MODEL) with MODEL of class MPC
        MPCobj = Model;
        if ni>1,
            error('mpc:mpc:set','Use SET to modify the properties of MPC objects.');
        end
        return
    end

    % Prediction model

    if isa(Model,'lti'), % |~isa(Model,'fir'), %<<<<<========== CHECK OUT for FIR models !!!
        Model=struct('Plant',Model);
    end

    if ~isa(Model,'struct'),
        error('mpc:mpc:model','The first input argument of the MPC constructor must be an LTI object or a structure of models and offsets')
    end


    fields={'Ts','PredictionHorizon','ControlHorizon','Weights','ManipulatedVariables','OutputVariables','DV'};
    nf=length(fields);
    if ni>nf+1,
        warning('mpc:mpc:extra','Extra input arguments to MPC constructor ignored');
    end
    for i=1:nf,
        if ni>i,
            %eval(sprintf('%s=varargin{%d};',fields{i},i+1));
            aux=varargin{i+1};
        else
            %eval(sprintf('%s=[];',fields{i}));
            aux=[];
        end
        switch fields{i}
            case 'Ts'
                Ts=aux;
            case 'PredictionHorizon'
                PredictionHorizon=aux;
            case 'ControlHorizon'
                ControlHorizon=aux;
            case 'Weights'
                Weights=aux;
            case 'ManipulatedVariables'
                ManipulatedVariables=aux;
            case 'OutputVariables'
                OutputVariables=aux;
            case 'DV'
                DV=aux;
        end
    end

    try
        % Check consistency of sampling time.
        mpc_chkts(Ts);

        % Check the Model structure and consistencies
        [Model,nu,ny,nutot,mvindex,mdindex,unindex,myindex]=mpc_prechkmodel(Model,Ts);

        if isempty(Ts),
            % If Ts=[] then Plant is discrete time, it was checked by MPC_PRECHKMODEL
            Ts=Model.Plant.Ts;
        end

        % Check correctness of prediction horizon
        [p,p_defaulted]=mpc_chkp(PredictionHorizon,default.p,Model,Ts);

        % Check correctness of input horizon/blocking moves
        moves=mpc_chkm(ControlHorizon,p,default.m);

        % Define default weights
        WeightsDefault=isempty(Weights);
        Weights=mpc_chkweights(Weights,p,nu,ny);

        % Define default InputSpecs and limits, ECRs

        namesfromplant=1;
        ManipulatedVariables=mpc_specs(ManipulatedVariables,nu,'ManipulatedVariables',...
            p,[],Model.Plant.InputName,mvindex,namesfromplant);

        % Define default Optimizer structure
        Optimizer=mpc_chkoptimizer([]);

        % Define default OutputSpecs and limits, ECRs
        OutputVariables=mpc_specs(OutputVariables,ny,'OutputVariables',p,...
            Optimizer.MinOutputECR,Model.Plant.OutputName,1:ny);

        % Define default DisturbanceVariables
        DV=mpc_specs(DV,nutot-nu,'DisturbanceVariables',[],...
            [],Model.Plant.InputName,[mdindex;unindex]);

%         % Possibly assigns I/O names from Specs to Model.Plant (only if
%         % Model.Plant has empty names)
%         unames=Model.Plant.InputNames;
%         ynames=Model.Plant.OutputNames;
%         for i=1:length(mvindex),
%             j=mvindex(i);
%             if isempty(unames{j}),
%                 % The following is appropriate, since mvindex is sorted
%                 Model.Plant.InputNames{j}=ManipulatedVariables(i).Name;
%             end
%         end
%         nmd=length(mdindex);
%         for i=1:nmd,
%             j=mdindex(i);
%             if isempty(unames{j}),
%                 % The following is appropriate, since mdindex is sorted
%                 Model.Plant.InputNames{j}=DV(i).Name;
%             end
%         end
%         for i=1:length(unindex),
%             j=unindex(i);
%             if isempty(unames{j}),
%                 % The following is appropriate, since unindex is sorted
%                 % and DV=[mvindex;unindex]
%                 Model.Plant.InputNames{j}=DV(i+nmd).Name;
%             end
%         end
%         for i=1:ny,
%             if isempty(ynames{i}),
%                 Model.Plant.OutputNames{i}=OutputVariables(i).Name;
%             end
%         end

    catch
        rethrow(lasterror);
    end

    % DisturbanceSpecs can be only defined by SET.M

    Private=struct('p_defaulted',p_defaulted,...
        'mvindex',mvindex,'mdindex',mdindex,...
        'myindex',myindex,'unindex',unindex,...
        'nutot',nutot,'ny',ny,'nu',nu,...
        'QP_ready',0,'L_ready',0,...
        'Init',0,'isempty',0,'OutDistFlag',0,'WeightsDefault',WeightsDefault);
end

% Define property values

MPCobj = struct('ManipulatedVariables',ManipulatedVariables,...
    'OutputVariables',OutputVariables,...
    'DisturbanceVariables',DV,...
    'Weights',Weights,...
    'Model',Model,...
    'Ts',Ts,...
    'Optimizer',Optimizer,...
    'PredictionHorizon',p,...
    'ControlHorizon',moves,...
    'History',clock,...
    'Notes',{{}},...
    'UserData',[],...
    'MPCData',Private,...
    'Version','2.0');


% Label MPCobj as an object of class MPC
MPCobj = class(MPCobj,'mpc');

%warning(swarn)