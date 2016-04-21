function this = update(this,varargin);
%UPDATE Updates operating point object with structural changes in a Simulink
%       model.
%
%   UPDATE(OP) updates an operating point object OP with changes in a
%   Simulink model such as states being added or removed.

% Check - 1 or 0 flag to error out if a Simulink model has changed
% notifying the user to call this method directly to update their model.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:10 $

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
            LocalUpdateError(this)
        end
        Inports = Inports(setxor(1:length(Inports),inew));
        %% Find the input objects that should remain
        inputs = inputs(sort(iold));
    end
    
    %% Create the input constraint objects and populate their values
    for ct = 1:length(Inports)
        if Check
            LocalUpdateError(this)
        end
        newinput = opcond.InputPoint;
        newinput.Block = Inports{ct};
        inputs = [inputs(:);newinput];
    end
    
    %% Check that the port dimensions are correct
    for ct = 1:length(inputs)
        %% Get the port handles
        Ports = get_param(inputs(ct).Block,'PortHandles');
        %% Get the port width
        PortWidth = get_param(Ports.Outport,'CompiledPortWidth');
        if isempty(inputs(ct).PortWidth) || (PortWidth ~= inputs(ct).PortWidth)
            if Check
                LocalUpdateError(this)
            end
            %% Need to re-initialize the properties
            input = inputs(ct);
            input.PortWidth = PortWidth;
            input.u = zeros(PortWidth,1);
            inputs(ct) = input;
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
    
    %% Terminate the model. Cannot get the state information from the mechanical system with the
    %% model compiled!
    feval(this.model,[],[],[],'term');
    
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
    
    for ct = 1:length(StateName)
        if Check
            LocalUpdateError(this)
        end
        %% Get the index to get the SimMechanics system
        if ~isempty(SimMechanicsSFuns) && ~isempty(strmatch(StateName{ct},SimMechanicsSFuns))
            sfun_ind = strmatch(StateName{ct},SimMechanicsSFuns);
            states = [states;LocalGetSimMechStates(StateName{ct},SimMechanicsGroundBlocks{sfun_ind})];
        else
            newstate = opcond.StatePoint;
            %% Set the properties
            newstate.Block = StateName{ct};    
            states = [states(:);newstate];
        end 
    end
    
    %% Check for valid number of states
    for ct = 1:length(states)
        %% Find the state indicies
        ind = find(strcmp(x_str,states(ct).Block));
        %% Find the SimMech state references if needed.  This will be a subset
        %% of all the states in the SimMechanics machine.
        if isa(states(ct),'opcond.StatePointSimMech')
            ind = ind(strmatch([states(ct).SimMechBlock,':'],states(ct).SimMechSystemStates));
        end
        if (isempty(states(ct).Nx)) || (length(ind) ~= states(ct).Nx)    
            if Check
                LocalUpdateError(this)
            end
            state = states(ct);
            %% Set the properties
            state.Nx = length(ind);
            state.x  = x0(ind);
            states(ct) = state;
        end
    end
    
    %% Store results
    this.States = states;
    this.Inputs = inputs;
    
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
    newstate = opcond.StatePointSimMech;
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

error('slcontrol:operpoint:NeedsUpdate',sprintf(['The model %s has been modified and the operation \n',...
    'point object is out of date.  Please update the object by calling \n',...
    'the function update on your operating point object.'],this.Model))
