function [oppoint,varargout] = findop(model,varargin)
%FINDOP Find operating points from specifications or simulation
%
%   [OP_POINT,OP_REPORT]=FINDOP('model',OP_SPEC) finds an operating point,
%   OP_POINT, of the model, 'model', from specifications given in OP_SPEC. 
%
%   [OP_POINT,OP_REPORT]=FINDOP('model',OP_SPEC,OPTIONS) using everal options 
%   for the optimization are specified in the OPTIONS object, which you can 
%   create with the function LINOPTIONS. 
%   
%   The input to findop, OP_SPEC, is an operating point specification object. 
%   Create this object with the function OPERSPEC. Specifications on the 
%   operating points, such as minimum and maximum values, initial guesses, 
%   and known values, are specified by editing OP_SPEC directly or by using 
%   get and set. To find equilibrium, or steady-state, operating points, set 
%   the SteadyState property of the states and inputs in OP_SPEC to 1. The 
%   FINDOP function uses optimization to find operating points that closely 
%   meet the specifications in OP_SPEC. By default, findop uses the optimizer 
%   fmincon. To use a different optimizer, change the value of OptimizerType 
%   in OPTIONS using the LINOPTIONS function. 
%
%   A report object, OP_REPORT, gives information on how closely FINDOP 
%   meets the specifications. The function FINDOP displays the report 
%   automatically, even if the output is suppressed with a semi-colon. 
%   To turn off the display of the report, set DisplayReport to 'off' in 
%   OPTIONS using the function LINOPTIONS. 
%
%   OP_POINT=FINDOP('model',SNAPSHOTTIMES) runs a simulation of the model, 
%   'model', and extracts operating points from the simulation at the 
%   snapshot times given in the vector, SNAPSHOTTIMES. An operating point 
%   object, OP_POINT, is returned.
%
%   See also OPERSPEC, LINOPTIONS

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/19 01:32:09 $

%% Get the display function handle and arguements
if nargin == 5
    %% Display in the output function using this function handle for trim
    %% the stop function is a function to check to stop the optimization.
    %% The display function should be in the form a vector cell array where 
    %% the first element is a function handle.  The updated string then
    %% will be added as a last arguement.
    dispfcn = varargin{3};
    stopfcn = varargin{4};
else
    %% Otherwise display to the workspace for trim.  Use an empty variable
    %% to optimize checking for this function during the optimization.
    dispfcn = [];
    stopfcn = [];
end

%% If an options object is specified pass this to the operating condition
%% spec object
if ((nargin==1) || (nargin > 5))
    error('slcontrol:findop_InvalidNumInputArguements',...
        'Please specify between 2 and 4 input arguements.');
elseif nargin == 2
    if isa(varargin{1},'opcond.OperatingSpec')
        op = varargin{1};
        options = linoptions;
        try
            [oppoint,opreport] = LocalTrimModel(model,op,options,dispfcn,stopfcn);
        catch
            errmsg=lasterror;
            rethrow(errmsg);
        end
        if nargout == 2
            varargout{1} = opreport;
        elseif nargout > 2
            error('slcontrol:findop_InvalidNumOutputArguements',...
                'Please specify a valid number of output arguements.');            
        end
    elseif isa(varargin{1},'double')
        %% Make sure the model is loaded
        if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',model))
            preloaded = 0;
            load_system(model);
        else
            preloaded = 1;
        end
        
        %% Get the old dirty model flag
        dirty = get_param(model, 'dirty');
        
        if nargout > 1
            error('slcontrol:findop_InvalidNumOutputArguements',...
                'Please specify a valid number of output arguements.');
        end
        %% Display that the block is being added to the model
        disp(sprintf(['findop: Adding a snapshot block to the model %s ',...
                        'and beginning simulation.'],model))
        oppoint = opsnapshot(linevent(model,varargin{:}));
        disp(sprintf('findop: Snapshot block removed and returning snapshot.\n')) 
        
        set_param(model, 'Dirty', dirty);

        if preloaded == 0
            close_system(model,0);
        end
    else
        error('slcontrol:findop_InvalidOperatingSpecObject',...
            'Please specify a valid OperatingSpec object.');
    end
elseif nargin > 2
    if isa(varargin{1},'opcond.OperatingSpec')
        op = varargin{1};
        if isa(varargin{2},'LinearizationObjects.linoptions')
            options = varargin{2};
            [oppoint,opreport] = LocalTrimModel(model,op,options,dispfcn,stopfcn);
            if nargout == 2
                varargout{1} = opreport;
            elseif nargout > 2
                error('slcontrol:findop_InvalidNumOutputArguements',...
                    'Please specify a valid number of output arguements.');
            end
        else
            error('slcontrol:findop_InvalidOptionsObject',...
                'Please specify a valid linoptions object.');
        end
    else
        error('slcontrol:findop_InvalidOperatingSpecObject',...
            'Please specify a valid OperatingSpec object.');
    end
end
  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [oppoint,opreport] = LocalTrimModel(model,op,options,dispfcn,stopfcn)

%% Make sure the model is loaded
if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',op.Model))
    preloaded = 0;
    load_system(op.Model);
else 
    preloaded = 1;
end 

%% Check to see that the operating condition is up to date
update(op,1);

%% If the user has the output constraints on set the analysis points for
%% linearization get the output signal UDD block handles.
outs = op.Outputs;
bh = get_param(get(outs,{'Block'}),'Object');
bt = get([bh{:}],{'BlockType'});

%% Determine whether to use analysis ports.  If all the output constraints
%% are outports then use the standard model output evaluation function.
%% Otherwise find all the source ports for the output constraints and mark
%% them for linear analysis.
if ~all(strcmpi(bt,'Outport')) && ~isempty(bt)
    %% The portflag determines whether or not to use the analysis ports for
    %% linearization.
    portflag = 'on';
    %% Get and store any of the users Analysis I/O settings.
    oldio = getlinio(op.Model);
    %% Get ready to create the I/O required for linearization
    h = LinearizationObjects.LinearizationIO;
    h.Type = 'out';
    ios = [];
    for ct = 1:length(bt)
        ios = [ios;h.copy];
        if strcmpi(bt(ct),'Outport')
            %% Get the source block
            ios(ct).Block = [op.Model,'/',get_param(bh{ct}.PortConnectivity.SrcBlock,'Name')];
            %% Get the source port
            ios(ct).PortNumber = bh{ct}.PortConnectivity.SrcPort + 1;
        else
            %% Set the Block and PortNumber properties
            ios(ct).Block = outs(ct).Block;            
            ios(ct).PortNumber = outs(ct).PortNumber;            
        end
        [ios,I,iy] = unique(ios);
    end
    %% Set the Analysis I/O properties for the input ports
    ins = op.Inputs;
    h.Type = 'in';
    for ct = 1:length(ins)
        ios = [ios;h.copy];
        ios(end).Block = ins(ct).Block;
        ios(end).PortNumber = 1;
    end    
    setlinio(op.Model,ios);
else
    %% Otherwise don't use the analysis ports, do the classic
    %% linearization.
    portflag = 'off';
    iy = 1:1:length(bh);
end

%% Set the desired Simulink setparam properties
want = struct('AnalyticLinearization','on',...
    'BufferReuse', 'off',...
    'SimulationMode', 'normal',...
    'RTWInlineParameters', 'on',...
    'UseAnalysisPorts', portflag);

%% Load model, save old settings, install new ones suitable for linearization
have = local_push_context(op.Model, want);

%% Compile the model.
feval(op.Model, [], [], [], 'lincompile');

%% Run the algorithm as a subroutine so we can trap errors and <CTRL-C>
lasterr(''); errmsg='';

%% Create the optimization object
try
    switch options.OptimizerType
        case 'graddescent_elim'
            optim = OptimizationObjects.fmincon(op,options);
        case 'graddescent'
            optim = OptimizationObjects.fmincon_xuvary(op,options);
        case 'lsqnonlin'
            optim = OptimizationObjects.lsqnonlin(op,options);
        case 'simplex'
            optim = OptimizationObjects.fminsearch(op,options);
        otherwise
            lasterr('Invalid optimization type.', 'slcontrol:InvalidOptimizationType')
    end
catch
    feval(op.Model, [], [], [], 'term');
    errmsg=lasterror;
    rethrow(errmsg);
end

%% Set the display and stop functions
optim.dispfcn = dispfcn;
optim.stopfcn = stopfcn;

%% Run the optimization
try
    [oppoint,opreport,exitflag,optimoutput] = optimize(optim);  
catch
    %% Release the compiled model
    feval(op.Model, [], [], [], 'term');
    errmsg=lasterror;
    rethrow(errmsg);
end

%% Release the compiled model
feval(op.Model, [], [], [], 'term');

if (exitflag > 0)
    exitdata = sprintf('Operating point specifications were successully met.');
elseif (exitflag == 0)
    exitdata = sprintf(['The maximum number of function evaluations or iterations ',...
                         'was exceeded.']);   
elseif (exitflag == -1)
    exitdata = sprintf(['The operating point search was terminated prematurely']);
else
    exitdata = sprintf(['The operating point specifications did not converge ',...
                         'to a solution.']);   
end

%% Store the optimization data in the report
opreport.TerminationString = exitdata;
opreport.OptimizationOutput = optimoutput;

%% Display the report of the optimization
if strcmp(options.DisplayReport,'on')
    disp(sprintf('\n Operating Point Search Report:'));
    disp('---------------------------------');
    display(opreport);
elseif strcmp(options.DisplayReport,'iter') && isempty(dispfcn)
    disp(sprintf('\n%s\n',exitdata));
end

%% Restore the settings in the Simulink model
local_pop_context(op.Model, have, preloaded);

%% Reset analysis ports if needed
if strcmp(portflag,'on')
    setlinio(op.Model,oldio);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function old = local_push_context(model, new)
%% Save model parameters before setting up new ones

%% Save op before calling set_param() ..
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

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
