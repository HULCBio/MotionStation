function [opcond,varargout] = opsnapshot(this,varargin)
% OPSNAPSHOT  Method to gather snapshot operating conditions @TimeEvent class

%  Author(s): John Glass
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:34:57 $

%% Get the singleton storage object
op = LinearizationObjects.SimulationOperatingConditionStorage;

%% Store the time event object
op.TimeEventObj = this;

%% Clear the old operating conditions and linearizations
op.OpCond = [];
op.Time = [];
op.Linearizations = [];
op.Jacobians = [];

%% Create an empty opearting point object
op.EmptyOpCond = operpoint(this.model);

%% Get the initial states in struct form for simulation
[x,u,xstruct] = getxu(op.EmptyOpCond);

%% Use a try catch to prevent block that were added to not be
%% left behind
try
    %% Handle the case where a user specifies t = 0.  Don't need to
    %% simulate to get this answer.
    if (any(this.Times == 0))
        opcond = copy(op.EmptyOpCond);
        if this.LinearizeFlag
            [sys,Jacobians] = linearize(this.Model,opcond,this.IO);
        end
        ind = find(this.Times == 0);
        this.Times(ind) = [];
    else
        opcond = [];
        sys = [];
        Jacobians = [];
    end
catch
    str = sprintf(['Your Simulink model %s could not be linearized due ',...
        'to the following error: \n\n %s'],this.Model,lsterror.message);
    errordlg(str, 'Simulink Control Design')
    return
end

%% Get the final time
Tfinal = max(this.Times);

if Tfinal > 0
    try
        %% Load the slctrlextras model to copy blocks
        load_system('slctrlextras')

        %% Add the linearization block to the model
        this.addblock('opsnapshot');

        %% Parameter settings we need to set/cache before linearizing
        want = struct('AnalyticLinearization','on',...
            'UseAnalysisPorts', 'on', ...
            'BufferReuse', 'off',...
            'BlockReductionOpt','off',...
            'SimulationMode', 'normal',...
            'RTWInlineParameters', 'on');

        %% Load model, save old settings, install new ones suitable for linearization
        [have, preloaded] = local_push_context(this.Model, want);

        %% Don't let sparse math re-order columns
        autommd_orig = spparms('autommd');
        spparms('autommd', 0);

        if this.LinearizeFlag
            oldio = setlinio(this.Model,this.IO);
        end
        %% Run the simulation.  Do not need to simulate past
        %% the final specified time.
        S = simset('InitialState',xstruct);
        sim(this.Model,Tfinal,S);

        %% Restore sparse math and block diagram settings
        spparms('autommd', autommd_orig);
        local_pop_context(this.Model, have, preloaded);

        %% Remove the linearization block from the model
        delete_block(this.Block);

        %% Get the resulting operating conditions
        opcond = [opcond;op.OpCond(:)];

        if this.LinearizeFlag
            %% Restore the previous IO settings
            setlinio(this.Model,oldio);
            if ~isempty(sys)
                for ct = 1:length(op.Jacobians)
                    sys(:,:,end+1) = op.Linearizations(:,:,ct);
                end
            else
                sys = op.Linearizations;
            end
            varargout{1} = sys;
            varargout{2} = [Jacobians;op.Jacobians(:)];
        end

        %% Close the slctrlextras model to copy blocks
        close_system('slctrlextras')
        
    catch
        %% Simulation interrupted display
        disp('Operating point snapshot aborted')

        %% Remove the linearization block from the model
        delete_block(this.Block);

        %% Close the slctrlextras model to copy blocks
        close_system('slctrlextras')
        
        %% Throw the last error
        error(lasterr);

        if this.LinearizeFlag
            varargout{1} = [];
        end
        opcond = [];
    end
end

%% Remove the time event object
op.TimeEventObj = [];

%---

function [old, preloaded] = local_push_context(model, new)
%% Save model parameters before setting up new ones

%% Make sure the model is loaded
if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',model))
    preloaded = 0;
    load_system(model);
else
    preloaded = 1;
end

%% Save this before calling set_param() ..
old = struct('Dirty', get_param(model,'Dirty'));

f = fieldnames(new);
for k = 1:length(f)
    prop = f{k};
    have_val = get_param(model, prop);
    want_val = getfield(new, prop);
    if ~isequal(have_val, want_val)
        set_param(model, prop, want_val);
        old = setfield(old, prop, have_val);
    end
end

%---

function local_pop_context(model, old, preloaded)
%% Restore model parameters from previous context

f = fieldnames(old);
for k = 1:length(f)
    prop = f{k};
    if ~isequal(prop,'Dirty')
        set_param(model, prop, getfield(old, prop));
    end
end

set_param(model, 'Dirty', old.Dirty);

if preloaded == 0
    close_system(model,0);
end
