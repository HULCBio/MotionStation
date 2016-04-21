function options = odeset(varargin)
%ODESET Create/alter ODE OPTIONS structure.
%   OPTIONS = ODESET('NAME1',VALUE1,'NAME2',VALUE2,...) creates an integrator
%   options structure OPTIONS in which the named properties have the
%   specified values. Any unspecified properties have default values. It is
%   sufficient to type only the leading characters that uniquely identify the
%   property. Case is ignored for property names. 
%   
%   OPTIONS = ODESET(OLDOPTS,'NAME1',VALUE1,...) alters an existing options
%   structure OLDOPTS.
%   
%   OPTIONS = ODESET(OLDOPTS,NEWOPTS) combines an existing options structure
%   OLDOPTS with a new options structure NEWOPTS. Any new properties
%   overwrite corresponding old properties. 
%   
%   ODESET with no input arguments displays all property names and their
%   possible values.
%   
%ODESET PROPERTIES
%   
%RelTol - Relative error tolerance  [ positive scalar {1e-3} ]
%   This scalar applies to all components of the solution vector, and
%   defaults to 1e-3 (0.1% accuracy) in all solvers.  The estimated error in
%   each integration step satisfies e(i) <= max(RelTol*abs(y(i)),AbsTol(i)).
%
%AbsTol - Absolute error tolerance  [ positive scalar or vector {1e-6} ]
%   A scalar tolerance applies to all components of the solution vector.
%   Elements of a vector of tolerances apply to corresponding components of
%   the solution vector. AbsTol defaults to 1e-6 in all solvers. See RelTol.
%   
%NormControl -  Control error relative to norm of solution  [ on | {off} ]
%   Set this property 'on' to request that the solvers control the error in
%   each integration step with norm(e) <= max(RelTol*norm(y),AbsTol). By
%   default the solvers use a more stringent component-wise error control. 
%   
%Refine - Output refinement factor  [ positive integer ]
%   This property increases the number of output points by the specified
%   factor producing smoother output. Refine defaults to 1 in all solvers 
%   except ODE45, where it is 4. Refine does not apply if length(TSPAN) > 2 
%   or the ODE solver returns the solution as a structure.
%   
%OutputFcn - Installable output function  [ function ]
%   This output function is called by the solver after each time step. When
%   a solver is called with no output arguments, OutputFcn defaults to the
%   function odeplot. Otherwise, OutputFcn defaults to [].
%   
%OutputSel - Output selection indices  [ vector of integers ]
%   This vector of indices specifies which components of the solution vector
%   are passed to the OutputFcn. OutputSel defaults to all components.
%   
%Stats - Display computational cost statistics  [ on | {off} ]
%   
%Jacobian - Jacobian function [ function | constant matrix ]
%   Set this property to a function FJac (if FJac(t,y) returns dF/dy) or to
%   the constant value of dF/dy.   
%   For ODE15I solving F(t,y,y') = 0, set this property to a function
%   [dFdy, dFdyp] = FJac(t,y,yp), or to a cell array of constant
%   values {dF/dy,dF/dyp}.
%      
%JPattern - Jacobian sparsity pattern [ sparse matrix ]
%   Set this property to a sparse matrix S with S(i,j) = 1 if component i of
%   F(t,y) depends on component j of y, and 0 otherwise.
%   For ODE15I solving F(t,y,y') = 0, set this property to
%   {dFdyPattern,dFdypPattern}, the sparsity patterns of dF/dy and
%   dF/dy', respectively. 
%   
%Vectorized - Vectorized ODE function  [ on | {off} ]
%   Set this property 'on' if the ODE function F is coded so that 
%   F(t,[y1 y2 ...]) returns [F(t,y1) F(t,y2) ...]. 
%   For ODE15I solving F(t,y,y') = 0, set this property to
%   {yVect,ypVect}. Setting yVect 'on' indicates that 
%   F(t,[y1 y2 ...],yp) returns [F(t,y1,yp) F(t,y2,yp) ...].  
%   Setting ypVect 'on' indicates that F(t,y,[yp1 yp2 ...])
%   returns [F(t,y,yp1) F(t,y,yp2) ...].   
%      
%Events - Locate events  [ function ]
%   To detect events, set this property to the event function.
%   
%Mass - Mass matrix [ constant matrix | function ]
%   For problems M*y' = f(t,y) set this property to the value of the constant
%   mass matrix. For problems with time- or state-dependent mass matrices,
%   set this property to a function that evaluates the mass matrix.
%
%MStateDependence - Dependence of the mass matrix on y [ none | {weak} | strong ] 
%   Set this property to 'none' for problems M(t)*y' = F(t,y). Both 'weak' and
%   'strong' indicate M(t,y), but 'weak' will result in implicit solvers
%   using approximations when solving algebraic equations.
%   
%MassSingular - Mass matrix is singular  [ yes | no | {maybe} ]
%   Set this property to 'no' if the mass matrix is not singular.
%
%MvPattern - dMv/dy sparsity pattern [ sparse matrix ]
%   Set this property to a sparse matrix S with S(i,j) = 1 if for any k, the 
%   (i,k) component of M(t,y) depends on component j of y, and 0 otherwise.  
%
%InitialSlope - Consistent initial slope yp0 [ vector ]
%   yp0 satisfies M(t0,y0)*yp0 = F(t0,y0).
%
%InitialStep - Suggested initial step size  [ positive scalar ]
%   The solver will try this first.  By default the solvers determine an
%   initial step size automatically. 
%   
%MaxStep - Upper bound on step size  [ positive scalar ]
%   MaxStep defaults to one-tenth of the tspan interval in all solvers.
%
%BDF - Use Backward Differentiation Formulas in ODE15S  [ on | {off} ]
%   This property specifies whether the Backward Differentiation Formulas
%   (Gear's methods) are to be used in ODE15S instead of the default
%   Numerical Differentiation Formulas. 
%
%MaxOrder - Maximum order of ODE15S  [ 1 | 2 | 3 | 4 | {5} ]
%   
%   See also ODEGET, ODE45, ODE23, ODE113, ODE15I, ODE15S, ODE23S, ODE23T, ODE23TB.
%
%
%   NOTE: 
%     Some of the properties available through ODESET have changed in this
%     version of MATLAB. Although we still support the v5 properties when
%     used with the v5 syntax of the ODE solvers, any new functionality will
%     be available only with the new syntax. To see the properties available
%     in v5, type in the command line  
%         more on, type odeset, more off

%   NOTE:
%     This portion describes the properties available in v5
%
%RelTol - Relative error tolerance  [ positive scalar {1e-3} ]
%   This scalar applies to all components of the solution vector, and
%   defaults to 1e-3 (0.1% accuracy) in all solvers.  The estimated error in
%   each integration step satisfies e(i) <= max(RelTol*abs(y(i)),AbsTol(i)).
%
%AbsTol - Absolute error tolerance  [ positive scalar or vector {1e-6} ]
%   A scalar tolerance applies to all components of the solution vector.
%   Elements of a vector of tolerances apply to corresponding components of
%   the solution vector.  AbsTol defaults to 1e-6 in all solvers.
%   
%Refine - Output refinement factor  [ positive integer ]
%   This property increases the number of output points by the specified
%   factor producing smoother output.  Refine defaults to 1 in all solvers 
%   except ODE45, where it is 4.  Refine doesn't apply if length(TSPAN) > 2.
%   
%OutputFcn - Name of installable output function  [ string ]
%   This output function is called by the solver after each time step.  When
%   a solver is called with no output arguments, OutputFcn defaults to
%   'odeplot'.  Otherwise, OutputFcn defaults to ''.
%   
%OutputSel - Output selection indices  [ vector of integers ]
%   This vector of indices specifies which components of the solution vector
%   are passed to the OutputFcn.  OutputSel defaults to all components.
%   
%Stats - Display computational cost statistics  [ on | {off} ]
%   
%Jacobian - Jacobian available from ODE file  [ on | {off} ]
%   Set this property 'on' if the ODE file is coded so that
%   F(t,y,'jacobian') returns dF/dy.
%   
%JConstant - Constant Jacobian matrix dF/dy  [ on | {off} ]
%   Set this property 'on' if the Jacobian matrix dF/dy is constant.
%   
%JPattern - Jacobian sparsity pattern available from ODE file  [ on | {off} ]
%   Set this property 'on' if the ODE file is coded so F([],[],'jpattern')
%   returns a sparse matrix with 1's showing nonzeros of dF/dy.
%   
%Vectorized - Vectorized ODE file  [ on | {off} ]
%   Set this property 'on' if the ODE file is coded so that F(t,[y1 y2 ...])
%   returns [F(t,y1) F(t,y2) ...].
%   
%Events - Locate events  [ on | {off} ]
%   Set this property 'on' if the ODE file is coded so that F(t,y,'events')
%   returns the values of the event functions.  See ODEFILE.
%   
%Mass - Mass matrix available from ODE file  [ {none} | M | M(t) | M(t,y) ]
%   Change this property from 'none' if the ODE file is coded so that
%   F(t,[],'mass') returns a mass matrix.  'M' indicates a constant mass
%   matrix, 'M(t)' indicates a time-dependent mass matrix, and 'M(t,y)'
%   indicates a time- and state-dependent mass matrix.
%   
%MassSingular - Mass matrix is singular  [ yes | no | {maybe} ]
%   Set this property to 'no' if the mass matrix is not singular.
%   
%MaxStep - Upper bound on step size  [ positive scalar ]
%   MaxStep defaults to one-tenth of the tspan interval in all solvers.
%
%InitialStep - Suggested initial step size  [ positive scalar ]
%   The solver will try this first.  By default the solvers determine an
%   initial step size automatically.
%   
%MaxOrder - Maximum order of ODE15S  [ 1 | 2 | 3 | 4 | {5} ]
%   
%BDF - Use Backward Differentiation Formulas in ODE15S  [ on | {off} ]
%   This property specifies whether the Backward Differentiation Formulas
%   (Gear's methods) are to be used in ODE15S instead of the default
%   Numerical Differentiation Formulas.
%   
%NormControl -  Control error relative to norm of solution  [ on | {off} ]
%   Set this property 'on' to request that the solvers control the error in
%   each integration step with norm(e) <= max(RelTol*norm(y),AbsTol).  By
%   default the solvers use a more stringent component-wise error control.   

%   Mark W. Reichelt and Lawrence F. Shampine, 5/6/94
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.46.4.4 $  $Date: 2003/10/21 11:55:47 $

% Print out possible values of properties.
if (nargin == 0) && (nargout == 0)
  fprintf('          AbsTol: [ positive scalar or vector {1e-6} ]\n');
  fprintf('          RelTol: [ positive scalar {1e-3} ]\n');
  fprintf('     NormControl: [ on | {off} ]\n');
  fprintf('       OutputFcn: [ function ]\n');
  fprintf('       OutputSel: [ vector of integers ]\n');
  fprintf('          Refine: [ positive integer ]\n');  
  fprintf('           Stats: [ on | {off} ]\n');
  fprintf('     InitialStep: [ positive scalar ]\n');
  fprintf('         MaxStep: [ positive scalar ]\n');
  fprintf('             BDF: [ on | {off} ]\n');
  fprintf('        MaxOrder: [ 1 | 2 | 3 | 4 | {5} ]\n');
  fprintf('        Jacobian: [ matrix | function ]\n');
  fprintf('        JPattern: [ sparse matrix ]\n');
  fprintf('      Vectorized: [ on | {off} ]\n');
  fprintf('            Mass: [ matrix | function ]\n');
  fprintf('MStateDependence: [ none | {weak} | strong ]\n');
  fprintf('       MvPattern: [ sparse matrix ]\n');
  fprintf('    MassSingular: [ yes | no | {maybe} ]\n');
  fprintf('    InitialSlope: [ vector ]\n');
  fprintf('          Events: [ function ]\n');
  fprintf('\n');
  return;
end

Names = [
    'AbsTol          '
    'BDF             '
    'Events          '
    'InitialStep     '
    'Jacobian        '
    'JConstant       '             % backward compatibility
    'JPattern        '
    'Mass            '
    'MassConstant    '             % obsolete
    'MassSingular    '
    'MaxOrder        '
    'MaxStep         '
    'NormControl     '
    'OutputFcn       '
    'OutputSel       '
    'Refine          '
    'RelTol          '
    'Stats           '
    'Vectorized      '
    'MStateDependence'
    'MvPattern       '
    'InitialSlope    '    
    ];
m = size(Names,1);
names = lower(Names);

% Combine all leading options structures o1, o2, ... in odeset(o1,o2,...).
options = [];
for j = 1:m
  options.(deblank(Names(j,:))) = [];
end
i = 1;
while i <= nargin
  arg = varargin{i};
  if ischar(arg)                         % arg is an option name
    break;
  end
  if ~isempty(arg)                      % [] is a valid options argument
    if ~isa(arg,'struct')
      error('MATLAB:odeset:NoPropNameOrStruct',...
            ['Expected argument %d to be a string property name ' ...
                     'or an options structure\ncreated with ODESET.'], i);
    end
    for j = 1:m
      if any(strcmp(fieldnames(arg),deblank(Names(j,:))))
        val = arg.(deblank(Names(j,:)));
      else
        val = [];
      end
      if ~isempty(val)
        options.(deblank(Names(j,:))) = val;
      end
    end
  end
  i = i + 1;
end

% A finite state machine to parse name-value pairs.
if rem(nargin-i+1,2) ~= 0
  error('MATLAB:odeset:ArgNameValueMismatch',...
        'Arguments must occur in name-value pairs.');
end
expectval = 0;                          % start expecting a name, not a value
while i <= nargin
  arg = varargin{i};
    
  if ~expectval
    if ~ischar(arg)
      error('MATLAB:odeset:NoPropName',...
            'Expected argument %d to be a string property name.', i);
    end
    
    lowArg = lower(arg);
    j = strmatch(lowArg,names);
    if isempty(j)                       % if no matches
      error('MATLAB:odeset:InvalidPropName',...
            'Unrecognized property name ''%s''.', arg);
    elseif length(j) > 1                % if more than one match
      % Check for any exact matches (in case any names are subsets of others)
      k = strmatch(lowArg,names,'exact');
      if length(k) == 1
        j = k;
      else
        msg = sprintf('Ambiguous property name ''%s'' ', arg);
        msg = [msg '(' deblank(Names(j(1),:))];
        for k = j(2:length(j))'
          msg = [msg ', ' deblank(Names(k,:))];
        end
        msg = sprintf('%s).', msg);
        error('MATLAB:odeset:AmbiguousPropName', msg);
      end
    end
    expectval = 1;                      % we expect a value next
    
  else
    options.(deblank(Names(j,:))) = arg;
    expectval = 0;
      
  end
  i = i + 1;
end

if expectval
  error('MATLAB:odeset:NoValueForProp',...
        'Expected value for property ''%s''.', arg);
end
