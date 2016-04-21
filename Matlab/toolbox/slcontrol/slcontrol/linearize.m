function [sys,varargout] = linearize(model,varargin);
% LINEARIZE Obtains a linear model from a Simulink model.
%   
%   LIN=LINEARIZE('sys',OP,IO) takes a Simulink model name, 'sys', an 
%   operating point object, OP, and an I/O object, IO, as inputs and 
%   returns a linear time-invariant state-space model, LIN. The operating 
%   point object is created with the function OPERPOINT or FINDOP. The 
%   linearization I/O object is created with the function GETLINIO or 
%   LINIO. Both OP and IO must be associated with the same Simulink model, 
%   sys. 
%
%   LIN=LINEARIZE('sys',OP,IO,OPTIONS) linearizes the Simulink model 'sys' 
%   using the options object, OPTIONS. The linearization options object 
%   is created with the function LINOPTIONS and contains several options 
%   for linearization. 
%
%   LIN_BLOCK=LINEARIZE('sys',OP,'blockname') returns a linearization of
%   a Simulink block named 'blockname' in the model 'sys'. You can also 
%   supply a fourth argument, OPTIONS, to provide options for the 
%   linearization. Create options with the function LINOPTIONS. 
%
%   LIN=LINEARIZE('sys',OP) creates a linearized model, LIN, using the 
%   root-level inport and outport blocks in sys.  You can also supply a 
%   third argument, OPTIONS, to provide options for the linearization. 
%   Create options with the function LINOPTIONS. 
%
%   LIN=LINEARIZE('sys',OP,OPTIONS) is the form of the linearize function 
%   that is used with numerical-perturbation linearization. The function 
%   returns a linear time-invariant state-space model, LIN, of the entire 
%   model, 'sys'.  The LinearizationAlgorithm option must be set to 
%   'numericalpert' within OPTIONS for numerical-perturbation linearization 
%   to be used. Create the variable options with the linoptions function. 
%   The function uses the root-level inport and outport blocks in the model 
%   as inputs and outputs for linearization. 
%
%   [LIN,OP] = LINEARIZE('sys',SNAPSHOTTIMES); creates operating points for 
%   the linearization by simulating the model, 'sys', and taking snapshots 
%   of the system's states and inputs at the times given in the vector 
%   snapshottimes. The function returns LIN, a set of linear time-invariant 
%   state-space models evaluated and OP, the set of operating point objects 
%   used in the linearization. You can specify input and output points for 
%   linearization by providing an additional argument such as a linearization 
%   I/O object created with GETLINIO or LINIO, or a block name. If an I/O 
%   object or block name is not supplied the linearization will use root-level 
%   inport and outport blocks in the model. You can also supply a 
%   fourth argument, OPTIONS, to provide options for the linearization. 
%   Create options with the function LINOPTIONS. 
%
%   See also LINIO, GETLINIO, OPERPOINT, FINDOP.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/19 01:32:11 $

if ((nargin == 1) || (nargin > 6))
    errmsg =  'Invalid number of arguements for the the function linearize';
    error('slcontrol:Linearize_InvalidNumberofArguements', errmsg)
end

%% Make sure the model is loaded
if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',model))
    preloaded = 0;
    load_system(model);
else 
    preloaded = 1;
end 

%% Get the value of the dirty flag
dirty = get_param(model,'Dirty');
%% Do this in a try catch to trap any errors
try
    if isa(varargin{1},'opcond.OperatingPoint')
        %% This is the normal linearization mode.  Loop over each operating
        %% point.
        op = varargin{1};
        for ct = length(op):-1:1
            [sys_ct,J_ct] = LocalNormalLinearizeModel(model,op(ct),varargin{2:end});
            sys(:,:,ct) = sys_ct;
            if (nargout == 2)
                if ~isempty(J_ct)
                    J(ct) = J_ct;
                end
            end
        end
        if (nargout == 2)
            if ~isempty(J_ct)
                varargout{1} = J;
            else
                varargout{1} = [];
            end
        end
    else
        [sys,opss,J] = LocalSimulationLinearizeModel(model,varargin{:});
        varargout{1} = opss;
        varargout{2} = J;
    end
catch
    errmsg = lasterr;
    error(errmsg);
end

%% Set the value of the dirty flag
set_param(model,'Dirty',dirty);

if preloaded == 0
    close_system(model,0);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalSimulationLinearizeModel
%% Computes the linearization of a model specified by a simulation
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,opsim,J] = LocalSimulationLinearizeModel(model,varargin)

%% Get the snapshot times and create the snapshot object
op = linevent(model,varargin{1});
op.LinearizeFlag = true;

%% Populate the snapshot object by looping over each arguement
for ct = 2:nargin-1
    var = varargin{ct};
    if isa(var,'LinearizationObjects.linoptions')
        op.linopts = var;
    elseif isa(var,'LinearizationObjects.LinearizationIO')
        op.IO      = var;
    elseif (isa(var,'char') || isa(var,'Simulink.Block'))
        %% Get the UDD block handle
        if isa(var,'Simulink.Block')
            block = var;
        else
            block = get_param(var,'Object');
        end
        %% Store the block that we are linearizing
        op.BlocktoLinearize = block;

        %% Compute the IO for the block linearization
        op.IO = LocalGetBlockLinearizationIO(model,block);
    end
end

%% Create a new linearization options object if the user does not pass one
if isempty(op.linopts)
    op.linopts = linoptions;
end

%% Check to make sure tha model perturbation is not used
if strcmp(op.linopts.LinearizationAlgorithm,'numericalpert')
    error('slcontrol:InvalidPerturbationLinearizationSettingforSimulationLinearization',...
             'Perturbation based linearization is not a valid option for simulation linearization.')
end

%% Compute the desired sample rate
%% Get the user defined sample rate
ts = LocalComputeSampleTime(op.linopts);
%% Get the model sample times and state names
[sizes,x0,str,Ts] = feval(model,[],[],[],'sizes');
if ts == -1
    %% Remove the infinite sample times
    Ts(find(isinf(Ts))) = 0;
    %% Compute the slowest sample time
    op.Ts = max(Ts(:));
else
    op.Ts = ts;
end

%% Perform the snapshot linearization
[opsim,sys,J] = opsnapshot(op);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalNormalLinearizeModel
%% Computes the linearization of a model specified by a user
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,J] = LocalNormalLinearizeModel(model,varargin)

%% Get the operating point object
op = varargin{1};

%% Check to see that the operating condition is up to date
update(op,1);

%% Do arguement checking
if (nargin == 2)
    %% There are no options specified by the user so just pass in a default
    %% Set of options
    opt = linoptions;
    %% This is the root level inport/outport based linearization
    [sys,J] = LocalRootLevelLinearization(model,op,opt);
elseif (nargin == 3)
    %% Check to see if the model matches the operating point
    if ~(strcmp(model,op.Model))
        errmsg = 'Model must match the model in the Operating Point object';
        error('slcontrol:Linearize_ModelDoesNotMatchOperatingPoint',errmsg)
    end
    if isa(varargin{2},'LinearizationObjects.linoptions')
        %% This is the root level inport/outport based linearization
        [sys,J] = LocalRootLevelLinearization(model,op,varargin{2});
    elseif (isa(varargin{2},'char') || isa(varargin{2},'Simulink.Block'))
        %% There are no options specified by the user so just pass in a default
        %% Set of options
        opt = linoptions;
        %% Linearize the block
        [sys,J] = LocalLinearizeBlock(model,op,varargin{2},opt);
    elseif isa(varargin{2},'LinearizationObjects.LinearizationIO')
        %% There are no options specified by the user so just pass in a default
        %% Set of options
        opt = linoptions;
        %% Linearize the model
        [sys,J] = LocalLinearizeModel(model,op,varargin{2},opt);        
    end 
elseif (nargin == 4)
    %% Check to see if the model matches the operating point
    if ~(strcmp(model,op.Model))
        errmsg = 'Model must match the model in the Operating Point object';
        error('slcontrol:Linearize_ModelDoesNotMatchOperatingPoint',errmsg)
    end
    
    if ~isa(varargin{3},'LinearizationObjects.linoptions')
        errmsg = ['The 4th arguement to the linearize command must be a',... 
                   'valid linearization options object'];
        error('slcontrol:Linearize_InvalidOptions',errmsg)
    end
    
    if (isa(varargin{2},'char') || isa(varargin{2},'Simulink.Block'))
        %% Linearize the block
        [sys,J] = LocalLinearizeBlock(model,op,varargin{2},varargin{3});
    elseif isa(varargin{2},'LinearizationObjects.LinearizationIO')
        %% Linearize the model
        [sys,J] = LocalLinearizeModel(model,op,varargin{2},varargin{3});        
    end 
end

%% Reorder the states to match the order in the operating point object 
%% Get the state order from the operating point and the linearized system
opStateNames = get(op.States,{'Block'});
sysStateNames = sys.StateNames;

if length(sysStateNames) > 0
    ind = [];
    indfull = [1:length(sys.A)]';

    %% Loop over the state objects
    for ct = 1:length(opStateNames)
        stateind = find(strcmp(opStateNames(ct),sys.StateNames));
        if isa(op.States(ct),'opcond.StatePointSimMech')
            stateind = stateind(strmatch([op.States(ct).SimMechBlock,':'],...
                op.States(ct).SimMechSystemStates));
            %% Replace the block state with the SimMechanics State
            for ct2 = 1:length(stateind)
                sysStateNames{stateind(ct2)} = op.States(ct).SimMechBlock;
            end
        end
        indfull(stateind) = zeros(size(stateind));
        ind = [ind;stateind];
    end
    %% Add additional states due to transport delays, ect
    ind = [ind;find(indfull)];

    %% Reorder the states
    sys.A = sys.A(ind,ind);
    sys.B = sys.B(ind,:);
    sys.C = sys.C(:,ind);
    sys.StateNames = sysStateNames(ind);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalLinearizeModel
%% Computes the linearization of a model specified by a user
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,J] = LocalLinearizeModel(model,op,io,opt)

%% Set the io settings
oldio = setlinio(model,io);

%% Preconfigure everything
oldBusExpand = feature('BusPropagationForNVBlocks');
feature('BusPropagationForNVBlocks',1)
ts = LocalComputeSampleTime(opt);

%% Compute the linearizations
[sys,J] = LocalDLinmod(model,io,op,ts,opt);

feature('BusPropagationForNVBlocks',oldBusExpand)
%% Restore the previous operating conditions
setlinio(model,oldio);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalLinearizeBlock
%% Computes the linearization of a block specified by a user
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,J] = LocalLinearizeBlock(model,op,block,opt)

%% Check to make sure tha model perturbation is not used
if strcmp(opt.LinearizationAlgorithm,'numericalpert')
    error('slcontrol:InvalidPerturbationLinearizationSetting',...
          'Perturbation based linearization is not a valid option for block linearization.')
end

%% Get the UDD block handle
if isa(block,'Simulink.Block')
    block = block;
else
    block = get_param(block,'Object');
end

%% Compute the io for the block linearization
newio = getblocklinio(model,block);
%% Set the io settings
oldio = setlinio(model,newio);

%% Linearize the Simulink model
oldBusExpand = feature('BusPropagationForNVBlocks');
feature('BusPropagationForNVBlocks',1)

%% Compute the sample rate
ts = LocalComputeSampleTime(opt);

if nargout > 1
    [sys,J] = LocalDLinmod(model,newio,op,ts,opt,block);
else
    [sys] = LocalDLinmod(model,newio,op,ts,opt,block);
end

feature('BusPropagationForNVBlocks',oldBusExpand)
%% Restore the previous operating conditions
setlinio(model,oldio);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalRootLevelLinearization
%% Computes the linearization using the standard root level linearization
%% used in linmod and dlinmod
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,J] = LocalRootLevelLinearization(model,op,opt)

%% Get the x and u vectors
[x,u] = LocalGetXU(op);

%% Get the user defined sample rate
ts = LocalComputeSampleTime(opt);
%% Get the model sample times and state names
[sizes,x0,str,Ts] = feval(model,[],[],[],'sizes');
if ts == -1
    %% Remove the infinite sample times
    Ts(find(isinf(Ts))) = 0;
    %% Compute the slowest sample time
    ts = max(Ts(:));
end

if strcmp(opt.LinearizationAlgorithm,'numericalpert')
    para = opt.NumericalPertRel;
    xpert = opt.NumericalXPert;
    upert = opt.NumericalUPert;
    if ~isempty(xpert) && ~(length(x)==length(xpert))
        error(sprintf(['The option NumericalXPert must be a vector of length\n ',... 
                    'equal to the number of states (%d) in the model %s.'],length(x),model))
    end
    if ~isempty(upert) && ~(length(u)==length(upert))
        error(sprintf(['The option NumericalUPert must be a vector of length\n',... 
                    'equal to the number of inputs (%d) to the model %s.'],length(u),model))
    end
    if ts == 0
        [A,B,C,D] = linmodv5(model,x,u,para,xpert,upert);
        %% Create the linear model
        sys = ss(A,B,C,D);
        J = [];
    else
        [A,B,C,D] = dlinmodv5(model,ts,x,u,para,xpert,upert);
        %% Create the linear model
        sys = ss(A,B,C,D,ts);
        J = [];
    end
else
    if ts == 0
        [A,B,C,D,J] = linmod(model,x,u);
        %% Create the linear model
        sys = ss(A,B,C,D);
        %% Get the state names from J
        str = J.StateName;
    else
        [A,B,C,D,J] = dlinmod(model,ts,x,u);
        %% Create the linear model
        sys = ss(A,B,C,D,ts);
        %% Get the state names from J
        str = J.StateName;
    end
end

%% Set the state properties
sys.StateName = str;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalComputeSampleTime 
%% Computes the sample time from the linearization options
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ts = LocalComputeSampleTime(options)

if ischar(options.SampleTime)
    try
        ts = evalin('base',options.SampleTime); 
    catch
        error('slcontrol:InvalidSampleTimeExpression',...
            sprintf('Invalid expression %s for the sample time option.',...
            options.SampleTime))
    end
else
    ts = options.SampleTime;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalDLinmod 
%% Obtains linear models from systems of ODEs and discrete-time systems.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,J] = LocalDLinmod(model,io,op,Ts,opt,varargin)

%% Get the states and input levels
[x,u] = LocalGetXU(op);

%% Parameter settings we need to set/cache before linearizing
want = struct('AnalyticLinearization','on',...
    'UseAnalysisPorts', 'on', ...
    'BufferReuse', 'off',...
    'SimulationMode', 'normal',...
    'RTWInlineParameters', 'on');

%% More block diagram state settings unique to [t,x,u] case.  Want to set
%% the states through the InitialState field so to overwrite external initial
%% conditions for integrators.
if length(x) > 0
    want = setfield(want, 'InitialState', mat2str(x));
    want = setfield(want, 'LoadInitialState', 'on');
end
if length(u) > 0
    %% Get the linearization time
    t = op.t;

    %% Time in the first column, u in the remaining columns
    if length(u) > 0
        u = [t;u]';
    end
    want = setfield(want, 'ExternalInput', mat2str(u));
    want = setfield(want, 'LoadExternalInput', 'on');
end
want = setfield(want, 'StartTime', mat2str(op.Time));
want = setfield(want, 'StopTime',  mat2str(op.Time+1));
want = setfield(want, 'OutputOption', 'RefineOutputTimes');

%% Load model, save old settings, install new ones suitable for linearization
have = local_push_context(model, want);

%% Don't let sparse math re-order columns
autommd_orig = spparms('autommd');
spparms('autommd', 0);

try
    %% Compile the model
    feval(model,[],[],[],'lincompile');
catch
    error(lasterr)
end

try
    %% Get the Jacobian data structure
    J = get_param(model,'Jacobian');
    %% Get the port handles
    inports = J.Mi.InputPorts;
    outports = J.Mi.OutputPorts;
    %% Logic to get the proper names and dimensions for each IO.
    if nargin == 6
        [input_ind,output_ind,input_name,output_name] = getIOIndecies(io,inports,outports,varargin{1});
    else
        [input_ind,output_ind,input_name,output_name] = getIOIndecies(io,inports,outports);        
    end
    feval(model,[],[],[],'term');
catch
    feval(model,[],[],[],'term');
    error(lasterr)
end

sys = jacobian2ss(J,model,opt,Ts,input_ind,output_ind,input_name,output_name);

%% Restore sparse math and block diagram settings
spparms('autommd', autommd_orig);
local_pop_context(model, have);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,u] = LocalGetXU(op)

%% Get the states of the system using the lincompile option to get
%% the proper state ordering.
[sizes, x0, x_str, ts, xts] = feval(op.Model,[],[],[],'lincompile'); 

% Initialize the vectors
x = zeros(size(x_str));
u = [];

%% Extract the states from the operating condition object
for ct = 1:length(op.States)
    ind = find(strcmp(op.States(ct).Block,x_str));    
    
    if isa(op.States(ct),'opcond.StatePointSimMech') || ...
             isa(op.States(ct),'opcond.StateSpecSimMech')
        ind = ind(strmatch(op.States(ct).SimMechBlock,op.States(ct).SimMechSystemStates));
    end
    
    x(ind) = op.States(ct).x;
end

%% Extract the input levels handle multivariable case
for ct = 1:length(op.Inputs)    
    u = [u;op.Inputs(ct).u(:)];
end

feval(op.Model,[],[],[],'term');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function M = local_vlcm(x)
%% VLCM  find least common multiple of several sample times

%% Protect against a few edge cases, remove zeros and Infs before computing LCM
x(~x) = [];
x(isinf(x)) = [];
if isempty(x), M = []; return; end;

[a,b]=rat(x);
v = b(1);
for k = 2:length(b), v=lcm(v,b(k)); end
d = v;

y = round(d*x);         % integers
v = y(1);
for k = 2:length(y), v=lcm(v,y(k)); end
M = v/d;

%---

function old = local_push_context(model, new)
%% Save model parameters before setting up new ones

%% Create an empty structure
old = struct;

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

function local_pop_context(model, old)
%% Restore model parameters from previous context

f = fieldnames(old);
for k = 1:length(f)
    prop = f{k};
    if ~isequal(prop,'Dirty')
        set_param(model, prop, getfield(old, prop));
    end
end
