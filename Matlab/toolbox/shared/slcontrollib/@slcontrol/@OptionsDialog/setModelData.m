function setModelData(this)
% SETMODELDATA Update the model data from the view settings

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:48 $

% Update the option objects
LocalUpdateSimOptions(this)
LocalUpdateOptimOptions(this)

% --------------------------------------------------------------------------
function LocalUpdateSimOptions(this)
h = this.SimOptionForm;
Handles = this.SimOptionHandles;

info    =   cell( Handles.Panel.getFields );
indices = double( Handles.Panel.getIndices ) + 1; % Matlab indexing

% Update numeric settings
Fields = { 'StartTime',   'StopTime',  'MaxStep', 'MinStep', ...
           'InitialStep', 'FixedStep', 'RelTol',  'AbsTol' };
LocalSetInfo(Fields, h, info);

% Solvers
typeidx = indices(1);
if typeidx == 1
  h.Solver = this.VariableStepSolvers{ indices(2) };
else
  h.Solver = this.FixedStepSolvers{ indices(2) };
end

% Zero crossing
onoff = {'off', 'on'};
h.ZeroCross = onoff{ indices(3) };

% --------------------------------------------------------------------------
function LocalUpdateOptimOptions(this)
h = this.OptimOptionForm;
Handles = this.OptimOptionHandles;

info    =   cell( Handles.Panel.getFields );
indices = double( Handles.Panel.getIndices ) + 1; % Matlab indexing

% Update numeric settings
Fields = { 'DiffMaxChange', 'DiffMinChange', 'TolCon', 'TolFun', 'TolX', ...
           'MaxFunEvals', 'MaxIter', 'Restarts', 'SearchLimit' };
LocalSetInfo(Fields, h, info);

% Algorithm
alg = set(h, 'Algorithm');
h.Algorithm = alg{ indices(1) };

% Model size
scale = {'off', 'on'};
h.LargeScale = scale{ indices(2) };

% Display options
dspl = set(h, 'Display');
h.Display = dspl{ indices(3) };

% Gradient model
grad = set(h, 'GradientType');
h.GradientType = grad{ indices(4) };

% Cost function type
if any( strcmp('CostType', fieldnames(h)) )
  cost = set(h, 'CostType');
  h.CostType = cost{ indices(5) };
end

% Robust algorithm
if any( strcmp('RobustCost', fieldnames(h)) )
  robust = {'off', 'on'};
  h.RobustCost = robust{ indices(6) };
end

% Search method
srch = set(h, 'SearchMethod');
h.SearchMethod = srch{ indices(7) };

% --------------------------------------------------------------------------
function LocalSetInfo(Fields, h, info)
[common, ia] = intersect( Fields, fieldnames(h) );

for ct = 1:length(ia)
  idx = ia(ct);
  f = Fields{idx};
  h.(f) = info{idx};
end
