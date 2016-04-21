function this = AbstractTrimOptimizer(opcond)
% ABSTRACTTRIMOPTIMIZER

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/09/01 09:19:58 $

%% Create the optimization object
this = OptimizationObjects.AbstractTrimOptimizer;

%% Store the time in a variable to be used repeatedly later
this.t = opcond.T;

%% Get the user defined constraints
[x,u,y,dx,ix,iu,iy,idx,lbx,lbu,lby,ubx,ubu,uby] = getXU(opcond);
this.x0 = x; this.y0 = y; this.u0 = u; this.dx0 = zeros(size(x));
this.ix = ix; this.iu = iu; this.iy = iy; this.idx = idx;
this.lbx = lbx; this.lbu = lbu; this.lby = lby;
this.ubx = udx; this.ubu = ubu; this.uby = uby;

%% Find the indicies of the free states and inputs
this.indx = setxor(1:length(x0),ix);
this.indu = setxor(1:length(u0),iu);
this.indy = setxor(1:length(y0),iy);

%% Get information about the model
[sizes,x0] = feval(this.model,[],[],[],'sizes');
this.ncstates = sizes(1);

%% Get the output signal UDD block handles
this.BlockHandles = get_param(get(opcond.Outputs,{'Block'}),'Object');
this.PortNumbers = get(opcond.Outputs,{'PortNumber'});
bt = get([this.BlockHandles{:}],'BlockType');

%% Find the Output Ports
if ~isempty(bt)
    this.OutportHandles = find(strcmpi(bt,'Outport'));
    this.ConstrainedSignals = find(~strcmpi(bt,'Outport'));
end

%% Set the new output fcn
this.OptimizationOptions = this.OptimizationOptions;
% OptimizationOptions.OutputFcn = @LocalWSOutputFcn;   