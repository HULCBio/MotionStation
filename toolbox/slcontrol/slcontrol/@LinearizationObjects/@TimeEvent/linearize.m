function [sys,opcond,J] = linearize(this,varargin)
%% LINEARIZE  Method to linearize a model using the @TimeEvent class

%%  Author(s): John Glass
%%  Copyright 1986-2003 The MathWorks, Inc.

%% Load the slctrlextras model to copy blocks
load_system('slctrlextras')

%% Get the singleton storage object
op = LinearizationObjects.SimulationStorage;

%% Clear the old linearizations
op.Linearizations = [];
op.Jacobians = [];
op.OpCond = [];
op.Block = [];

if nargin == 1;
    %% TODO: HANDLE THIS CASE
    %% Linearize the Simulink model
    io = [];
else    
    if isa(varargin{1},'double')
        %% TODO: HANDLE THIS CASE
        ts = varargin{1};
        %% Linearize the Simulink model
        io = [];

    elseif (isa(varargin{1},'char') || isa(varargin{1},'Simulink.Block'))
        %% Get the new IO for block linearization
        io = [];
        %% Get the UDD block handle
        if isa(varargin{1},'Simulink.Block')
            block= varargin{1};
        else
            block = get_param(varargin{1},'Object');
        end        
        %% Get ready to create the I/O required for linearization
        hio = LinearizationObjects.LinearizationIO;
        %% Set the Block and PortNumber properties
        hio.Type = 'out';
        %% Get the full block name
        ph = block.PortHandles;
        %% Block must either have an inport of outport
        ph = [ph.Inport ph.Outport];
        hio.Block = get_param(ph(1),'Parent');
        %% Set the openloop property to be on
        hio.OpenLoop = 'on';
        %% Loop over each outport
        for ct = 1:length(block.PortHandles.Outport)
            hio.PortNumber = ct;
            hio.Description = sprintf('%d',ct);
            io = [io;hio.copy];
        end
        %% Get the source block
        hio.Type = 'in';
        %% Loop over each input
        for ct = 1:length(block.PortHandles.Inport)
            SourceBlock = get_param(block.PortConnectivity(ct).SrcBlock,'Object');
            SourcePort = block.PortConnectivity(ct).SrcPort + 1;
            hio.Block = get_param(SourceBlock.PortHandles.Outport(SourcePort),'Parent');
            %% Get the source port
            hio.PortNumber = SourcePort;
            hio.Description = sprintf('%d',ct);
            io = [io;hio.copy];
        end        
        op.Block = block;
    elseif isa(varargin{1},'LinearizationObjects.LinearizationIO')
        %% Get the handles to the IO objects
        io = varargin{1};
    end
end

%% Set the io settings
oldio = setio(this.Model,io);

%% Create an empty opearting condition object
op.EmptyOpCond = getopconstraint(this.model);
op.EmptyOpCond.setallInputs(1);
op.EmptyOpCond.setallStates(1,0);

%% Store the io to be used by the linsnap code
op.IO = io;

%% Use a try catch to prevent block that were added to not be
%% left behind
try
    %% Add the linearization block to the model
    this.addblock('linsnapshot');
    
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
    
    %% Make sure the bus expansion is enabled
    oldBusExpand = feature('BusPropagationForNVBlocks');
    feature('BusPropagationForNVBlocks',1)
    
    %% Set the properties of the linearization storage object
    op.LinearizationOptions = this.LinearizationOptions;
    
    %% Get the final time
    Tfinal = max(this.LinearizationTimes);
    
    %% Linearize the model via simulation.  Do not need to simulate past
    %% the final specified time.
    switch nargin
        case 2
            sim(this.Model,Tfinal);
        otherwise
            sim(this.Model,Tfinal,varargin{:});
    end
    
    %% Restore sparse math and block diagram settings
    spparms('autommd', autommd_orig);
    feature('BusPropagationForNVBlocks',oldBusExpand)
    local_pop_context(this.Model, have, preloaded);
    
    %% Restore the previous linearization io
    setio(this.Model,oldio);
    
    %% Remove the linearization block from the model
    blocks = find_system(this.Model,'MaskType','Timed Constrained Linearization');
    for ct = 1:length(blocks)
        delete_block(blocks{ct});
    end
    
    %% Get the linearized result
    sys = op.Linearizations;
    J = op.Jacobians;
    opcond = op.OpCond;
        
    %% Close the slctrlextras model to copy blocks
    close_system('slctrlextras')
    
catch
    %% Linearization interrupted display
    disp('Linearization aborted')
    
    %% Remove the linearization block from the model
    blocks = find_system(this.Model,'MaskType','Timed Constrained Linearization');
    for ct = 1:length(blocks)
        delete_block(blocks{ct});
    end
    
    sys = [];
end

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