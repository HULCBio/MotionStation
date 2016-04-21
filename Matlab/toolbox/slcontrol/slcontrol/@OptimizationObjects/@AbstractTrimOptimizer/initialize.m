function initialize(this,opcond)
% INITIALIZE

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/19 01:32:06 $

%% Store the time in a variable to be used repeatedly later
this.t = opcond.T;
this.model = opcond.model;
this.opcond = opcond;

%% Get information about the model
[sizes,x0,x_str] = feval(this.model,[],[],[],'sizes');
this.ncstates = sizes(1);

%% Get the user defined constraints
[x,u,y,dx,ix,iu,iy,idx,lbx,lbu,lby,ubx,ubu,uby,x_str] = LocalGetXU(opcond,sizes,x0,x_str);
this.x0 = x; this.y0 = y; this.u0 = u; this.dx0 = zeros(size(x));

this.ix = ix; this.iu = iu; this.iy = iy; this.idx = idx;
this.lbx = lbx; this.lbu = lbu; this.lby = lby;
this.ubx = ubx; this.ubu = ubu; this.uby = uby;

%% Find the indicies of the free states and inputs
this.indx = setxor(1:length(x),ix);
this.indu = setxor(1:length(u),iu);
this.indy = setxor(1:length(y),iy);

if isempty([this.indx(:);this.indu(:)])
    error('slcontrol:findop_InvalidConstraints',...
        'There are no free variables to optimize.  Free either a state or an input.');
end
    
%% Store the blocks that the constraints are on
this.StateConstraintBlocks = regexprep(x_str,'\n',' ');;
OutputConstraintBlocks = cell(length(y),1);
ind = 1;
for ct1 = 1:length(opcond.Outputs)
    for ct2 = 1:length(opcond.Outputs(ct1).PortWidth)
        OutputConstraintBlocks{ind} = opcond.Outputs(ct1).Block;
        ind = ind + 1;
    end
end
this.OutputConstraintBlocks = OutputConstraintBlocks;

%% Get the output signal UDD block handles
this.BlockHandles = get_param(get(opcond.Outputs,{'Block'}),'Object');
this.PortNumbers = get(opcond.Outputs,{'PortNumber'});

%% Find the Output Ports
if ~isempty(this.BlockHandles)
    bt = get([this.BlockHandles{:}],'BlockType');
    this.OutportHandles = find(strcmpi(bt,'Outport'));
    this.ConstrainedSignals = find(~strcmpi(bt,'Outport'));
end

%% Set the new output fcn and optimization options
this.linoptions.OptimizationOptions.OutputFcn = @LocalOutputFcn;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,u,y,dx,ix,iu,iy,idx,lbx,lbu,lby,ubx,ubu,uby,x_str_new] = LocalGetXU(this,sizes,x0,x_str);
%% Function to get the state, input, output, and constraint vectors in 
%% their proper order for the model in its current state.  

% Initialize the vectors
x = zeros(size(x_str));
dx = zeros(size(x_str));
u = [];
y = [];
ix = [];
iu = [];
iy = [];
idx = [];
lbx = zeros(size(x_str));
lbu = [];
lby = [];
ubx = zeros(size(x_str));
ubu = [];
uby = [];
x_str_new = x_str;

%% Extract the states from the operating condition object
for ct = 1:length(this.States)
    ind = find(strcmp(this.States(ct).Block,x_str));    
    
    if isa(this.States(ct),'opcond.StateSpecSimMech')
        ind = ind(strmatch([this.States(ct).SimMechBlock,':'],this.States(ct).SimMechSystemStates));
        %% Update the state name list with the SimMechanics block name
        for ct2 = 1:length(ind)
            x_str_new{ind(ct2)} = this.States(ct).SimMechBlock;
        end
    end
    ind_known = find(this.States(ct).Known);
    ix = [ix;ind(ind_known)];
    
    x(ind) = this.States(ct).x(:);

    
    SteadyStateInd = find(this.States(ct).SteadyState(:));
    idx = [idx;ind(SteadyStateInd)];
        
    lbx(ind) = this.States(ct).Min(:);
    ubx(ind) = this.States(ct).Max(:);
end

%% Extract the input levels handle multivariable case
offset = 0;
for ct = 1:length(this.Inputs)    
    ind_known = find(this.Inputs(ct).Known);
    iu = [iu;offset+ind_known];    
    u_guess = this.Inputs(ct).u(:);
    u = [u;u_guess];

    offset = offset + this.Inputs(ct).PortWidth;
    lbu = [lbu;this.Inputs(ct).Min(:)];
    ubu = [ubu;this.Inputs(ct).Max(:)];
end

%% Extract the output levels handle multivariable case
offset = 0;
for ct = 1:length(this.Outputs)
    ind_known = find(this.Outputs(ct).Known);
    iy = [iy;offset+ind_known];  
    y = [y;this.Outputs(ct).y(:)];
    
    offset = offset + this.Outputs(ct).PortWidth;
    lby = [lby;this.Outputs(ct).Min(:)];
    uby = [uby;this.Outputs(ct).Max(:)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalOutputFcn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stop = LocalOutputFcn(x, optimValues, state, this)

% Stop variable for the optimization
stop = false;

switch state
    case 'iter'
        % Make updates to plot or guis as needed
        if strcmp(this.linoptions.DisplayReport,'iter')
            if ~isempty(this.dispfcn)
                str = iterdisplayGUI(this,x,optimValues);
                feval(this.dispfcn{:},str);
            else
                str = iterdisplay(this,x,optimValues);
                for ct = 1:length(str)
                    disp(str{ct});
                end
            end
        end
        if ~isempty(this.stopfcn)
            stop = feval(this.stopfcn{:});
        end
    case 'interrupt'
        % Probably no action here. Check conditions to see
        % whether optimization should quit.
        if ~isempty(this.stopfcn)
            stop = feval(this.stopfcn{:});
        end
    case 'init'
        if strcmp(this.linoptions.DisplayReport,'iter')
            str = initdisplay(this,x,optimValues);
            if ~isempty(this.dispfcn)
                feval(this.dispfcn{:},str);
            else
                for ct = 2:length(str)
                    disp(str{ct});
                end
            end
        end
    case 'done'
        % Cleanup of plots, guis, or final plot
        if strcmp(this.linoptions.DisplayReport,'iter')
            if ~isempty(this.dispfcn)
                str = iterdisplayGUI(this,x,optimValues);
                feval(this.dispfcn{:},str);
            else
                str = iterdisplay(this,x,optimValues);
                for ct = 1:length(str)
                    disp(str{ct});
                end
            end
        end
    otherwise
end



