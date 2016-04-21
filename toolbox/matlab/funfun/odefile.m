%ODEFILE  ODE file syntax.
%
% NOTE:
%   The interpretation of the first input argument of the ODE solvers
%   (formerly referred to as 'ODEFILE') and several options available through
%   ODESET have changed in MATLAB v6. While the v5 syntax is still supported,
%   any new functionality is available only with the new syntax. This help
%   describes the v5 syntax. For information about the new syntax, see a help
%   entry for any of the ODE solvers or for ODESET. To see the v5 help, type 
%   in the command line
%       more on, type odefile, more off

% NOTE:
%   This portion describes the ODEFILE and the syntax the ODE solvers used in
%   MATLAB v5.   
%
% An ODE file is an M-file function you write to define a differential
% equation problem for the ODE Suite solvers.  This M-file is referred to as
% 'ODEFILE' here, although you can give your M-file any name you like.
% 
% By default, the ODE Suite solvers solve initial value problems of the form
% dy/dt = F(t,y) where t is an independent variable and y is a vector of
% dependent variables.  To do this, the solvers repeatedly call F =
% ODEFILE(T,Y) where argument T is a scalar, Y is a column vector, and
% output F is expected to be a column vector of the same length.  Note that
% the ODE file must accept the arguments T and Y, although it does not have
% to use them.  In its simplest form, an ODE file can be coded as
%  
%function F = odefile(t,y)
%F = < Insert a function of t and/or y here. >;
% 
% As described in the User's Guide, the ODE Suite solvers are capable of
% using additional information coded in the ODE file.  In this more general
% usage, an ODE file is expected to respond to the arguments
% ODEFILE(T,Y,FLAG,P1,P2,...) where T and Y are the integration variables,
% FLAG is a lower case string indicating the type of information that the
% ODE file should return, and P1,P2,... are any additional parameters that
% the problem requires.  The currently supported flags are
% 
%    FLAGS        RETURN VALUES
%    '' (empty) - F(t,y)
%    'init'     - default TSPAN, Y0 and OPTIONS for this problem
%    'jacobian' - Jacobian matrix J(t,y) = dF/dy
%    'jpattern' - matrix showing the Jacobian sparsity pattern
%    'mass'     - mass matrix M, M(t), or M(t,y), for solving M*y' = F(t,y)
%    'events'   - information for zero-crossing location
% 
% Below is a template that illustrates how you might code an extended ODE
% file that uses two additional input parameters.  This template uses
% subfunctions.  Note that it is not typical to include all of the cases
% shown below.  For example, 'jacobian' information is used for evaluating
% Jacobians analytically, and 'jpattern' information is used for generating
% Jacobians numerically.
% 
%function varargout = odefile(t,y,flag,p1,p2)
%
%switch flag
%case ''                                 % Return dy/dt = f(t,y).
%  varargout{1} = f(t,y,p1,p2);
%case 'init'                             % Return default [tspan,y0,options].
%  [varargout{1:3}] = init(p1,p2);
%case 'jacobian'                         % Return Jacobian matrix df/dy.
%  varargout{1} = jacobian(t,y,p1,p2);
%case 'jpattern'                         % Return sparsity pattern matrix S.
%  varargout{1} = jpattern(t,y,p1,p2);
%case 'mass    '                         % Return mass matrix.
%  varargout{1} = mass(t,y,p1,p2);
%case 'events'                           % Return [value,isterminal,direction].
%  [varargout{1:3}] = events(t,y,p1,p2);
%otherwise
%  error(['Unknown flag ''' flag '''.']);
%end
%
%% --------------------------------------------------------------------------
%
%function dydt = f(t,y,p1,p2)
%dydt = < Insert a function of t and/or y, p1, and p2 here. >
%
%% --------------------------------------------------------------------------
%
%function [tspan,y0,options] = init(p1,p2)
%tspan = < Insert tspan here. >;
%y0 = < Insert y0 here. >;
%options = < Insert options = odeset(...) or [] here. >;
%
%% --------------------------------------------------------------------------
%
%function dfdy = jacobian(t,y,p1,p2)
%dfdy = < Insert Jacobian matrix here. >;
%
%% --------------------------------------------------------------------------
%
%function S = jpattern(t,y,p1,p2)
%S = < Insert Jacobian matrix sparsity pattern here. >;
%
%% --------------------------------------------------------------------------
%
%function M = mass(t,y,p1,p2)
%M = < Insert mass matrix here. >;
%
%% --------------------------------------------------------------------------
%
%function [value,isterminal,direction] = events(t,y,p1,p2)
%value = < Insert event function vector here. >
%isterminal = < Insert logical ISTERMINAL vector here.>;
%direction = < Insert DIRECTION vector here.>;

%   Mark W. Reichelt and Lawrence F. Shampine, 8-4-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/15 04:21:54 $
