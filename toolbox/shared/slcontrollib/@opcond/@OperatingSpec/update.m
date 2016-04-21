function this = update(this,varargin);
%UPDATE Updates operating specification object with structural changes in a 
%       Simulink model.
%
%   UPDATE(OP) updates an operating specification object OP with changes in a
%   Simulink model such as states being added or removed.

% Check - 1 or 0 flag to error out if a Simulink model has changed
% notifying the user to call this method directly to update their model.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:21 $

%% Initialize the check flag
if (nargin == 2) && (varargin{1} == 1);
    Check = 1;
else
    Check = 0;
end

%% Preload the model
[have, preloaded] = local_push_context(this.model);

%% Try catch to prevent the model from being left in a poorly compiled state.
try 
    %% Compile the model 
    [sizes, x0, x_str, pp, qq] = feval(this.model,[],[],[],'compile');
    
    %% Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Defaults and behavior:
    % 1. Values are not known when an input object is instanciated.
    % 2. The initial guess and value properties are initialized to zero.
    %
    % For inputs we need to do the following levels of checking:
    % 1. Check for blocks that have been added or removed.  In this case we
    % will add or remove the input constraint objects.
    % 2. Check for port dimensions that have been changed.  In this case we
    % will get the new input width then update the value, initial guess,
    % upper/lower bounds, and the known properties of these objects with the
    % default values.
    % 3. Must handle the case where the ordering of the input objects may
    % change.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Find the inports to the model
    Inports = find_system(this.model,'SearchDepth',1,'BlockType','Inport');
    
    %% Get the current value of the model inports
    ExtInput = get_param(this.model,'ExternalInput');
    LoadExternalInput = ~strcmp(ExtInput,'[]') && strcmpi(get_param(this.model,'LoadExternalInput'),'on');
    
    %% Get the current input objects
    inputs = this.inputs;
    if ~isempty(inputs)
        %% Get the names of the blocks in the old input set
        old_Blocks = get(inputs,{'Block'});
        %% Find the intersection of the new and old inports
        [Inter,inew,iold] = intersect(Inports,old_Blocks);
        %% Find the Inports blocks that need to be added to the list.
        if Check && (length(iold) ~= length(old_Blocks))
            LocalUpdateError(this);
        end
        Inports = Inports(setxor(1:length(Inports),inew));
        %% Find the input objects that should remain
        inputs = inputs(sort(iold));
    end
    
    %% Create the input constraint objects and populate their values
    for ct = 1:length(Inports)
        if Check
            LocalUpdateError(this);
        end
        newinput = opcond.InputSpec;
        newinput.Block = Inports{ct};
        inputs = [inputs;newinput];
    end
    
    %% Check that the port dimensions are correct
    for ct = 1:length(inputs)
        %% Get the port handles
        Ports = get_param(inputs(ct).Block,'PortHandles');
        %% Get the port width
        PortWidth = get_param(Ports.Outport,'CompiledPortWidth');
        if isempty(inputs(ct).PortWidth) || (PortWidth ~= inputs(ct).PortWidth)
            if Check
                LocalUpdateError(this);
            end
            %% Need to re-initialize the properties
            input = inputs(ct);
            input.PortWidth = PortWidth;
            input.u         = zeros(PortWidth,1);
            input.Known     = zeros(PortWidth,1);   
            input.Min       = -inf*ones(PortWidth,1);
            input.Max       =  inf*ones(PortWidth,1);
            inputs(ct)      = input;
        end
    end
    
    %% Outputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Default behaviors:
    % 1. The known property will be set to 0 for outports and 1
    % for trim signals by default.
    % 2. The initial values will be set to zero.
    %
    % For inputs we need to do the following levels of checking:
    % 1. Whether outports have been added or removed from the Simulink model.
    % In this case we add/remove the appropriate object.
    % 2. Whether trim points have been added or removed from the Simulink model.
    % In this case we will add/remove the appropriate object.   
    % 3. Check the compiled port widths and update the objects
    % accordingly.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Find the outports to the model
    Outports = find_system(this.model,'SearchDepth',1,'BlockType','Outport');
    
    %% Get the current output objects
    outputs = this.outputs;
    
    %% Check to see in output constraints need to be added for changes in
    %% the number of outports
    if ~isempty(outputs)
        %% Get the current block names
        old_Blocks = get(outputs,{'Block'});
        ind_outports = [];
        deleted_outports = [];
        for ct = 1:length(old_Blocks)
            try
                %% Get the indecies of the output objects that represent outports
                if strcmp(get_param(old_Blocks{ct},'BlockType'),'Outport')
                    ind_outport = ct;
                else
                    ind_outport = [];                    
                end
            catch
                if Check;LocalUpdateError(this);end
                deleted_outports = [deleted_outports;ct];
                ind_outport = [];
            end
            ind_outports = [ind_outports;ind_outport];
        end
        outputs(deleted_outports) = [];
        
        if ~isempty(ind_outports)
            %% Find the intersection of the new and old inports
            [Inter,inew,iold] = intersect(Outports,old_Blocks(ind_outports));
            %% Find the Inports blocks that need to be added to the list.
            Outports = Outports(setxor(1:length(Outports),inew));
            %% Remove the unneed output objects
            ind = ind_outports(setxor(1:length(ind_outports),iold));
            if Check && ~isempty(ind)
                LocalUpdateError(this);
            end
            outputs(ind) = [];
        end
    end
    
    %% Create the output constraint objects and populate their values
    for ct = 1:length(Outports)
        %% Add a new output constraint
        newoutput = opcond.OutputSpec;
        newoutput.Block = Outports{ct};
        outputs = [outputs;newoutput]; 
    end
    
    %% Find the indicies of the outport constraints
    ind_outport = find(strcmp(get_param(get(outputs,{'Block'}),'BlockType'),'Outport'));
    %% Create the output constraint objects and populate their values
    for ct = 1:length(outputs(ind_outport))
        %% Get the port handles
        Ports = get_param(outputs(ind_outport(ct)).Block,'PortHandles');
        %% Get the port width
        PortWidth = get_param(Ports.Inport,'CompiledPortWidth');
        if isempty(outputs(ind_outport(ct)).PortWidth) || ...
                (PortWidth ~= outputs(ind_outport(ct)).PortWidth)
            if Check
                LocalUpdateError(this);
            end
            %% Need to re-initialize the properties
            output = outputs(ind_outport(ct));
            output.PortWidth  = PortWidth;
            output.PortNumber = NaN;
            output.Min        = -inf*ones(PortWidth,1);   
            output.Max        =  inf*ones(PortWidth,1);  
            output.y          =  zeros(PortWidth,1);    
            output.Known      =  zeros(PortWidth,1);
            outputs(ind_outport(ct)) = output;
        end    
    end
    
    %% Find trimmed signals in the model
    TrimOut = find_system(this.model,'findall','on',...
        'type','port',...
        'LinearAnalysisTrim','on');
    
    if ~isempty(outputs)
        %% Get the current block names
        old_Blocks = get(outputs,{'Block'});
        old_Ports = get(outputs,{'PortNumber'});
        %% Get the indecies of the output objects that represent outports
        ind_trimport = find(~strcmp(get_param(old_Blocks,'BlockType'),'Outport'));
        if ~isempty(ind_trimport)
            %% Get the TrimOut parents
            if length(TrimOut) == 1
                TrimOutParent = {get_param(TrimOut,'Parent')};
            else
                TrimOutParent = get_param(TrimOut,'Parent');
            end
            old_Blocks = old_Blocks(ind_trimport);
            old_Ports = old_Ports(ind_trimport);
            %% Concatinate port numbers since multiple ports can be marked.
            for ct = 1:length(old_Blocks)
                old_Blocks{ct} = sprintf('%s %d',old_Blocks{ct},old_Ports{ct});
            end
            TrimOutstr = cell(length(TrimOut),1);
            for ct = 1:length(TrimOut)
                TrimOutstr{ct} = sprintf('%s %d',get_param(TrimOut(ct),'Parent'),...
                                        get_param(TrimOut(ct),'PortNumber'));
            end
            %% Find the intersection of the new and old inports
            [Inter,inew,iold] = intersect(TrimOutstr,old_Blocks);
            %% Find the Outport blocks that need to be added to the list.
            TrimOut = TrimOut(setxor(1:length(TrimOut),inew));
        end
    end
    
    %% Create the output constraint objects and populate their values
    for ct = 1:length(TrimOut)
        if Check
            LocalUpdateError(this);
        end
        %% Add a new output constraint
        newoutput = opcond.OutputSpec;
        %% Set the properties
        newoutput.Block = get_param(TrimOut(ct),'Parent');
        newoutput.PortNumber = get_param(TrimOut(ct),'PortNumber');    
        outputs = [outputs;newoutput];        
    end
    
    %% Find the indicies of the trim port constraints
    ind_trimport = find(~strcmp(get_param(get(outputs,{'Block'}),'BlockType'),'Outport'));
    %% Create the output constraint objects and populate their values
    for ct = 1:length(outputs(ind_trimport))
        %% Get the port handles
        Ports = get_param(outputs(ind_trimport(ct)).Block,'PortHandles');
        %% Get the port width
        PortWidth = get_param(Ports.Outport(outputs(ind_trimport(ct)).PortNumber),'CompiledPortWidth');
        %% Populate the properties
        if isempty(outputs(ind_trimport(ct)).PortWidth) || ...
                (PortWidth ~= outputs(ind_trimport(ct)).PortWidth)
            if Check
                LocalUpdateError(this);
            end    
            %% Need to re-initialize the properties
            output = outputs(ind_trimport(ct));
            output.PortWidth = PortWidth;
            output.Min       = -inf*ones(PortWidth,1);   
            output.Max       =  inf*ones(PortWidth,1);  
            output.y         =  zeros(PortWidth,1);    
            output.Known     =  zeros(PortWidth,1);
            outputs(ind_trimport(ct)) = output;
        end    
    end
    
    %% States %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Default behaviors:
    % 1. The known property will be set to 0.
    % 2. The initial values will be set to zero.
    % 3. The steady state property will be set to 1.
    %
    % For state we need to do the following levels of checking:
    % 1. Whether blocks with state have been added or removed from the Simulink model.
    % In this case we add/remove the appropriate object.   
    % 3. Check the number of states and update the objects
    % accordingly.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Find the SimMechanics Ground blocks that are in the model
    SimMechanicsGroundBlocks = find_system( this.model, ...
                            'CaseSensitive',  'off', ...
                            'PhysicalDomain', 'Mechanical', ...
                            'ClassName',      'Ground' );

    %% Find the Block#1 SimMechanics blocks in the model which contain the
    %% states.
    SimMechanicsSFuns = cell(length(SimMechanicsGroundBlocks),1);
    for ct = 1:numel(SimMechanicsGroundBlocks)
        %% Find the root S-Function for the given machine.
        SFun = find_system(SimMechanicsGroundBlocks{ct},...
            'LookUnderMasks','all',...
            'FollowLinks','on',...
            'Name','Block#1',...
            'BlockType','S-Function',...
            'FunctionName','mech_engine');
        if ~isempty(SFun)
            SimMechanicsSFuns{ct,1} = SFun{1};
        else
            SimMechanicsSFuns{ct,1} = '';
        end
    end
    
    %% Get the unique state names
    StateName = unique(x_str);
        
    %% Get the current state objects
    states = this.states;
    if ~isempty(states)
        %% Get the names of the blocks in the old state set
        old_Blocks = get(states,{'Block'});
        %% Find the intersection of the new and old states
        [XOR,inew_xor,iold_xor] = setxor(StateName,old_Blocks);
        %% Find the State blocks that need to be added to the list.
        StateName = StateName(inew_xor);
        %% Find the state objects that should remain
        states = states(setxor(1:length(states),iold_xor));
    end
    
    %% Loop over each of the new states to get their upper and lower bound
    %% values if appropriate
    NewStates = struct('StateName',StateName,'Min',[],'Max',[]);
    for ct = 1:length(StateName)
        if (strcmp(get_param(NewStates(ct).StateName,'BlockType'),'Integrator') && ...
                strcmp(get_param(NewStates(ct).StateName,'LimitOutput'),'on'))
            runtimeobject = get_param(NewStates(ct).StateName,'RunTimeObject');
            minlim = runtimeobject.RuntimePrm(3);
            NewStates(ct).Min = minlim.data;
            maxlim = runtimeobject.RuntimePrm(2);
            NewStates(ct).Max = maxlim.data;
        end
    end

    %% Terminate the model. Cannot get the state information from the
    %% mechanical system with the model compiled!
    feval(this.model,[],[],[],'term');   

    for ct = 1:length(StateName)
        if Check
            LocalUpdateError(this);
        end
        %% Get the index to get the SimMechanics system
        if ~isempty(SimMechanicsSFuns) && ~isempty(strmatch(StateName{ct},SimMechanicsSFuns))
            sfun_ind = strmatch(StateName{ct},SimMechanicsSFuns);
            states = [states;LocalGetSimMechStates(StateName{ct},SimMechanicsGroundBlocks{sfun_ind})];
        else
            newstate = opcond.StateSpec;
            newstate.Block = StateName{ct};
            states = [states;newstate];
        end 
        %% Copy in the upper and lower bounds on the integrators is needed
        if ~isempty(NewStates(ct).Min) && ~isempty(NewStates(ct).Max)
            states(ct).Min = NewStates(ct).Min;
            states(ct).Max = NewStates(ct).Max;
        end
    end
    
    %% Check for valid number of states
    for ct = 1:length(states)
        %% Find the state indicies
        ind = find(strcmp(x_str,states(ct).Block));
        %% Find the SimMech state references if needed.  This will be a subset
        %% of all the states in the SimMechanics machine.
        if isa(states(ct),'opcond.StateSpecSimMech')
            ind = ind(strmatch([states(ct).SimMechBlock,':'],states(ct).SimMechSystemStates));
        end
        if (isempty(states(ct).Nx)) || (length(ind) ~= states(ct).Nx)    
            if Check
                LocalUpdateError(this);
            end
            %% Set the properties
            state = states(ct);
            state.Nx        = length(ind);
            state.x         = x0(ind);
            if ((length(state.Min) ~= state.Nx) && (length(state.Max) ~= state.Nx))
                state.Min       = -inf*ones(size(ind));
                state.Max       =  inf*ones(size(ind));
            end
            state.SteadyState = ones(size(ind));
            state.Known     = zeros(size(ind));
            states(ct) = state;
        end
    end
    
    %% Store results
    this.States = states;
    this.Inputs = inputs;
    this.Outputs = outputs; 
    
catch
    %% Terminate the model. Need to make sure that the model is not
    %% compiled if it is needed to exit the update method due to an error.
    lsterr = lasterror;
    try 
        feval(this.model,[],[],[],'term');
    end
    rethrow(lsterr)
end   %% Try-Catch end

local_pop_context(this.model, have, preloaded);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [old,preloaded] = local_push_context(model)
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

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%% LocalGetSimMechStates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function states = LocalGetSimMechStates(StateName,SimMechGroundBlock)

%% Set the property to hold the SimMechanics information
StateMgrObject = mech_stateVectorMgr(SimMechGroundBlock);
SimMechMachineName = StateMgrObject.MachineName;
StateNames = StateMgrObject.StateNames;
states = [];

for ct = 1:length(StateMgrObject.BlockStates)
    newstate = opcond.StateSpecSimMech;
    BlockStates = StateNames(strmatch([StateMgrObject.BlockStates(ct).BlockName,':',...
                    StateMgrObject.BlockStates(ct).Primitive],StateNames));
    newstate.Block = StateName;
    newstate.SimMechMachineName = SimMechMachineName;
    newstate.SimMechBlockStates = BlockStates;
    newstate.SimMechSystemStates = StateNames;
    newstate.SimMechBlock = [StateMgrObject.BlockStates(ct).BlockName,':',...
                            StateMgrObject.BlockStates(ct).Primitive];
    states = [states;newstate];
end

%% LocalUpdateError %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateError(this)

error('slcontrol:operspec:NeedsUpdate',sprintf(['The model %s has been modified and your operation condition\n',...
    'specification object is out of date.  Please update the object by calling \n',...
    'the function update on your operating condition specification object.'],this.Model))

