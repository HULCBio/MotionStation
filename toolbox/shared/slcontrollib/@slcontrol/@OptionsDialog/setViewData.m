function setViewData(this)
% SETVIEWDATA Update the view data from the model settings

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:50 $

% Update the panels
LocalUpdateSimOptions(this)
LocalUpdateOptimOptions(this)

% --------------------------------------------------------------------------
function LocalUpdateSimOptions(this)
h = this.SimOptionForm;
Handles = this.SimOptionHandles;

% Update text fields
Fields = { 'StartTime',   'StopTime',  'MaxStep', 'MinStep', ...
           'InitialStep', 'FixedStep', 'RelTol',  'AbsTol' };
Handles.Panel.setFields( LocalGetInfo(Fields, h) );

% Finite settings
typeidx   = 1;
solveridx = find( strcmp( h.Solver, this.VariableStepSolvers ) );
if isempty(solveridx)
  solveridx = find( strcmp( h.Solver, this.FixedStepSolvers ) );
  typeidx   = 2;
end
zeroidx = find( strcmp( h.ZeroCross, {'off', 'on'} ) );

% Update combo boxes
indices = [ typeidx-1, solveridx-1, zeroidx-1 ];
Handles.Panel.setIndices( indices );

% --------------------------------------------------------------------------
function LocalUpdateOptimOptions(this)
h = this.OptimOptionForm;
Handles = this.OptimOptionHandles;

% Update text fields
Fields = { 'DiffMaxChange', 'DiffMinChange', 'TolCon', 'TolFun', 'TolX', ...
           'MaxFunEvals', 'MaxIter', 'Restarts', 'SearchLimit' };
Handles.Panel.setFields( LocalGetInfo(Fields, h) );

% Finite settings
algidx    = find( strcmp( h.Algorithm,    set(h, 'Algorithm') ) );
sizeidx   = find( strcmp( h.LargeScale,   {'off', 'on'} ) );
dispidx   = find( strcmp( h.Display,      set(h, 'Display') ) );
gradidx   = find( strcmp( h.GradientType, set(h, 'GradientType') ) );
searchidx = find( strcmp( h.SearchMethod, set(h, 'SearchMethod') ) );
costidx   = 1; % Default
robustidx = 1; % Default

% Cost function type
if any( strcmp('CostType', fieldnames(h)) )
  costidx = find( strcmp( h.CostType, set(h, 'CostType') ) );
end

% Robust algorithm
if any( strcmp('RobustCost', fieldnames(h)) )
  robustidx = find( strcmp( h.RobustCost, {'off', 'on'} ) );
end

% Update combo boxes
indices = [ algidx-1 sizeidx-1 dispidx-1 gradidx-1 ...
            costidx-1 robustidx-1, searchidx-1 ];
Handles.Panel.setIndices( indices );

% --------------------------------------------------------------------------
function info = LocalGetInfo(Fields, h)
[common, ia] = intersect( Fields, fieldnames(h) );

% Default strings
info = cell( size(Fields) );
info(:) = {'not available'};

for ct = 1:length(ia)
  idx = ia(ct);
  f = Fields{idx};
  info{idx} = h.(f);
end
