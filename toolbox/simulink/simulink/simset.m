function options = simset(varargin)
%SIMSET Create/alter OPTIONS structure for input to SIM.
%   OPTIONS = SIMSET('NAME1',VALUE1,'NAME2',VALUE2,...) creates a Simulink
%   sim options structure, OPTIONS, in which the named properties have
%   the specified values.  It is sufficient to type only the leading
%   characters that uniquely identify the property.  Case is ignored for
%   property names.
%
%   OPTIONS = SIMSET(OLDOPTS,'NAME1',VALUE1,...) alters an existing options
%   structure OLDOPTS.
%
%   OPTIONS = SIMSET(OLDOPTS,NEWOPTS) combines an existing options structure
%   OLDOPTS with a new options structure NEWOPTS.  Any new properties
%   overwrite corresponding old properties.
%
%   SIMSET with no input arguments displays all property names and their
%   possible values.
%
%   SIMSET PROPERTY DEFAULTS
%
%   The default for any unspecified property is taken from the simulation
%   parameters dialog box if present.  If the value specified in the simulation
%   parameter dialog box is "auto", then the default value specified below is
%   used.
%
%   SIMSET PROPERTIES
%
%   Solver - Method to advance time [ VariableStepDiscrete |
%                                     ode45 | ode23 | ode113 | ode15s | 
%                                     ode23s | ode23t | ode23tb |
%                                     FixedStepDiscrete |
%                                     ode5 | ode4 | ode3 | ode2 | ode1 |
%                                     ode14x ]
%   This property specifies which solver is used to advance time.
%
%   RelTol - Relative error tolerance [ positive scalar {1e-3} ]
%   This scalar applies to all components of the state vector.  The
%   estimated error in each integration step satisfies
%   e(i) <= max(RelTol*abs(x(i)),AbsTol(i)).  RelTol applies only to the
%   variable step solvers, and defaults to 1e-3 (0.1% accuracy).
%
%   AbsTol - Absolute error tolerance [ positive scalar {1e-6} ]
%   This scalar applies to all components of the state vector.  AbsTol
%   applies only to the variable step solvers, and defaults to 1e-6.
%
%   Refine - Output refinement factor [ positive integer {1} ]
%   This property increases the number of output points by the specified
%   factor producing smoother output.  During refinement the solver
%   also checks for zero crossings. Refine applies only to the variable
%   step solvers and defaults to 1.  Refine is ignored if output times are
%   specified. 
%
%   MaxStep - Upper bound on the step size [ positive scalar {auto} ]
%   MaxStep applies only to the variable step solvers, and defaults to
%   one-fiftieth of the simulation interval.
%
%   MinStep - Lower bound on the step size [ positive scalar {auto} ]
%   or [ positive scalar, nonnegative integer ]
%   Minstep applies only to the variable step solvers, and defaults to 
%   a value based on machine precision.
%
%   InitialStep - Suggested initial step size [ positive scalar {auto} ]
%   InitialStep applies only to the variable step solvers.  The solvers will
%   try a step size of InitialStep first.  By default the solvers determine
%   an initial step size automatically.
%
%   MaxOrder - Maximum order of ODE15S [ 1 | 2 | 3 | 4 | {5} ]
%   MaxOrder applies only to ODE15S, and defaults to 5.
%
%   FixedStep - Fixed step size [ positive scalar ]
%   FixedStep applies only to the fixed-step solvers.  If there are discrete
%   components, the default is the fundamental sample time; otherwise, the
%   default is one-fiftieth of the simulation interval.
%
%   ExtrapolationOrder - Order of extrapolation in ODE14X [ 1 | 2 | 3 | {4} ]
%   Order of extrapolation method used by ODE14X. Defaults to 4.
%
%   NumberNewtonIterations - Number of Newton iterations in ODE14X [ {1} ]
%   Number of iterations performed in ODE14X. Defaults to 1. 
%
%   OutputPoints - Determine output points [ {specified} | all ]
%   OutputPoints defaults to 'specified', i.e. the solver produces outputs
%   T, X, and Y only at the times specified in TIMESPAN.  When OutputPoints
%   is set to 'all', the T, X, and Y will also include the time steps taken
%   by the solver.
%
%   OutputVariables - Set output variables [ {txy} | tx | ty | xy | t | x | y ]
%   If 't' or 'x' or 'y' is missing from the OutputVariables string then the
%   solver produces an empty matrix in the corresponding output T, X,
%   or Y. This property is ignored if there are no left hand side arguments.
%  
%   SaveFormat - Set save format [{'Array'} | 'Structure' | 'StructureWithTime'] 
%   This property specifies the format of saving states and outputs.
%   The state matrix contains continuous states followed by discrete states. 
%   If save format is 'Structure' or 'StructureWithTime', states and
%   outputs are saved in structure arrays with time and signals fields.
%   The signals field contains the following fields: 'values', 'label', and
%   'blockName'.  If the save format is 'StructureWithTime', simulation time is
%   saved in the corresponding structures. 
%
%   MaxDataPoints - Limit number of data points [non-negative integer {0}]
%   'MaxDataPoints' was previously called 'MaxRows'. This property limits the 
%   number of data points returned in T, X, and Y to the last MaxDataPoints
%   data logging time points.  If specified as 0, then no limit is imposed.  
%   MaxDataPoints defaults to 0.
%
%   Decimation - Decimation for output variables [ positive integer {1} ]
%   Decimation factor applied to the return variables, T, X, and Y.  A
%   decimation factor of 1 returns every data logging time point, a
%   decimation factor of 2 returns every other data logging time point,
%   etc.  Decimation defaults to 1.
%
%   InitialState - Initial continuous and discrete states [ vector {[]} ]
%   The initial state vector consists of the continuous states (if any)
%   followed by the discrete states (if any).  InitialState supersedes the
%   initial states specified in the model.  InitialState defaults to the
%   empty matrix [] indicating that the initial state values specified in
%   the model are to be used.
%
%   FinalStateName - Name of final states variable [ string {''} ]
%   The property specifies the name of a variable into which to save
%   the states of the model at the end of the simulation.  FinalStateName
%   defaults to the empty string ''.
%
%   Trace - comma separated list of [ 'minstep', 'siminfo', 'compile', 
%                                     'compilestats' {''} ]
%   This property enables simulation tracing facilities.
%   o The 'minstep' trace flag specifies that simulation will stop when the
%     solution changes so abruptly that the variable step solvers cannot take
%     a step and satisfy the error tolerances.  By default Simulink issues a
%     warning and continues the simulation.
%   o The 'siminfo' trace flag provides a short summary of the simulation
%     parameters in effect at the start of simulation.
%   o The 'compile' trace flag displays the compilation phases of a block
%     diagram model.
%   o The 'compilestats' trace flag displays the time and memory usage for
%     the compilation phases of a block diagram model.
%
%   SrcWorkspace - Where to evaluate expressions [ {base} | current | parent ]
%   This property specifies the workspace in which to evaluate MATLAB
%   expressions defined in the model.  The default is the base
%   workspace.
%
%   DstWorkspace - Where to assign variables [ base | {current} | parent ]
%   This property specifies the workspace in which to assign any variables
%   defined in the model.  The default is the current workspace.
%
%   ZeroCross - Enable/disable location of zero crossings [ {on} | off ]
%   ZeroCross applies only to the variable step solvers, and defaults to 'on'.
%
%   Debug - Enable/disable the Simulink debugger [ on | {off} ]
%   Setting this property to on will start the Simulink debugger.
%
%   See also SIM, SIMGET.

%   Mark W. Reichelt and John Ciolfi, 3/14/96
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.29.2.5 $

% Print out possible values of options.
if (nargin == 0) & (nargout == 0)
  fprintf('         Solver: [ ''VariableStepDiscrete'' |\n');
  fprintf('                   ''ode45'' | ''ode23'' | ''ode113'' | ''ode15s'' | ''ode23s'' | ''ode23t'' | ''ode23tb'' |\n');
  fprintf('                   ''FixedStepDiscrete'' |\n');
  fprintf('                   ''ode5'' | ''ode4'' | ''ode3'' | ''ode2'' | ''ode1'' | ''ode14x'' ]\n');
  fprintf('         RelTol: [ positive scalar {1e-3} ]\n');
  fprintf('         AbsTol: [ positive scalar {1e-6} ]\n');
  fprintf('         Refine: [ positive integer {1} ]\n');
  fprintf('        MaxStep: [ positive scalar {auto} ]\n');
  fprintf('        MinStep: [ [positive scalar, nonnegative integer] {auto} ]\n');
  fprintf('    InitialStep: [ positive scalar {auto} ]\n');
  fprintf('       MaxOrder: [ 1 | 2 | 3 | 4 | {5} ]\n');
  fprintf('      FixedStep: [ positive scalar {auto} ]\n');
  if slfeature('UseODE14xFixedStepSolver') > 0
      fprintf('    ExtrapolationOrder: [ 1 | 2 | 3 | {4} ]\n');
      fprintf('NumberNewtonIterations: [ positive integer {1} ]\n');
  end  
  fprintf('   OutputPoints: [ {''specified''} | ''all'' ]\n');
  fprintf('OutputVariables: [ {''txy''} | ''tx'' | ''ty'' | ''xy'' | ''t'' | ''x'' | ''y'' ]\n');
  fprintf('     SaveFormat: [ {''Array''} | ''Structure'' | ''StructureWithTime'']\n');
  fprintf('  MaxDataPoints: [ non-negative integer {0} ]\n');
  fprintf('     Decimation: [ positive integer {1} ]\n');
  fprintf('   InitialState: [ vector {[]} ]\n');
  fprintf(' FinalStateName: [ string {''''} ]\n');
  fprintf('          Trace: [ comma separated list of ''minstep'', ''siminfo'', ''compile'', ''compilestats'' {''''}]\n');
  fprintf('   SrcWorkspace: [ {''base''} | ''current'' | ''parent'' ]\n');
  fprintf('   DstWorkspace: [ ''base'' | {''current''} | ''parent'' ]\n');
  fprintf('      ZeroCross: [ {''on''} | ''off'' ]\n');
  fprintf('          Debug: [ ''on'' | {''off''} ]\n');
  fprintf('\n');
  return;
end

Names = {
    'AbsTol'
    'Debug'
    'Decimation'
    'DstWorkspace'
    'FinalStateName'
    'FixedStep'
    'InitialState'
    'InitialStep'
    'MaxOrder'
    'SaveFormat'
    'MaxDataPoints'
    'MaxStep'
    'MinStep'
    'OutputPoints'
    'OutputVariables'
    'Refine'
    'RelTol'
    'Solver'
    'SrcWorkspace'
    'Trace'
    'ZeroCross'
    'ExtrapolationOrder'
    'NumberNewtonIterations'
    };
[m,n] = size(Names);
names = lower(char(Names));

% Combine all leading options structures o1, o2, ... in simset(o1,o2,...).
options = [];
for j = 1:m
  eval(['options.' Names{j} '= [];']);
end
i = 1;
while i <= nargin
  arg = varargin{i};
  if ischar(arg)                         % arg is an option name
    break;
  end
  if ~isempty(arg)                      % [] is a valid options argument
    if ~isa(arg,'struct')
      error(sprintf(['Expected argument %d to be a string property name ' ...
                     'or an options structure\ncreated with SIMSET.'], i));
    end
    for j = 1:m
      if any(strcmp(fieldnames(arg),deblank(Names{j})))
        eval(['val = arg.' Names{j} ';']);
      else
        val = [];
      end
      if ~isempty(val)
        eval(['options.' Names{j} '= val;']);
      end
    end
  end
  i = i + 1;
end

% A finite state machine to parse name-value pairs.
if rem(nargin-i+1,2) ~= 0
  error('Arguments must occur in name-value pairs.');
end
expectval = 0;                          % start expecting a name, not a value
while i <= nargin
  arg = varargin{i};

  if ~expectval
    if ~ischar(arg)
      error(sprintf('Expected argument %d to be a string property name.', i));
    end
    % For backward compatibility
    if(strcmp(lower(arg),'maxrows'))
      arg = 'MaxDataPoints';
    end
    lowArg = lower(arg);
    j = strmatch(lowArg,names);
    if isempty(j)                       % if no matches
      error(sprintf('Unrecognized property name ''%s''.', arg));
    elseif length(j) > 1                % if more than one match
      % Check for any exact matches (in case any names are subsets of others)
      k = strmatch(lowArg,names,'exact');
      if length(k) == 1
        j = k;
      else
        msg = sprintf('Ambiguous property name ''%s'' ', arg);
        msg = [msg '(' Names{j(1)}];
        for k = j(2:length(j))'
          msg = [msg ', ' Names{k}];
        end
        msg = sprintf('%s).', msg);
        error(msg);
      end
    end
    expectval = 1;                      % we expect a value next

  else
    eval(['options.' Names{j} '= arg;']);
    expectval = 0;

  end
  i = i + 1;
end

if expectval
  error(sprintf('Expected value for property ''%s''.', arg));
end
