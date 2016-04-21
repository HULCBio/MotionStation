%% Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%% 
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {[ @var{dotx}, @var{dotxdx}, @var{u}] =} pendulum (@var{t}, @var{x}, @var{opt})
%% Implements a general pendulum.
%% @tex
%% $$
%% \ddot{q} + \frac{g}{l}\sin(q) + d\dot{q} = f(t,q,\dot{q})
%% $$
%% @end tex
%% @ifnottex
%%
%% @example
%% q'' + (g/l)*sin(q) + d*q' = f(t,q,q')
%% @end example
%%
%% @end ifnottex
%% @noindent
%% where q is the angle of the pendulum and q' its angular velocity
%%
%% This function can be used with the ODE integrators. 
%%
%% @strong{INPUTS}
%% 
%% @var{t}: Time. It can be a scalar or a vector of length @code{nT}.
%%
%% @var{x}: State space vector. An array of size @code{2xnT}, where @code{nT} is
%% the number of time values given. The first row corresponds to the configurations
%% of the system and the second row to its derivatives with respect to time.
%%
%% @var{opt}: An options structure. See the complementary function
%% @code{setpendulum}. The structure containing the fields: 
%%
%% @code{Coefficients}: Contains the coefficients (g/l).
%%
%% @code{Damping}: Contains the coefficient d.
%%
%% @code{Actuation}: An optional field of the structure. If it is present, it
%% defines the function f(t,q,q'). It can be a handle to a function of the form f =
%% func(@var{t},@var{x},@var{opt}) or it can be a @code{1xnT} vector.
%%
%% @strong{OUTPUT}
%% 
%% @var{dotx}: Derivative of the state space vector with respect to time. A @code{2xnT} array.
%%
%% @var{dotxdx}: When requested, it contains the Jacobian of the system. It is a multidimensional array of size @code{2x2xnT}.
%%
%% @var{u}: If present, the function returns the inputs that generate the
%% sequence of state space vectors provided in @var{x}. To do this the functions
%% estimates the second derivative of q using spline interpolation. This implies
%% that there be at least 2 observations of the state vector @var{x}, i.e. @code{nT
%% >= 2}. Otherwise the output is empty.
%%
%% @seealso{setpendulum, nloscillator, odepkg}
%% @end deftypefn

function [dotx dotxdx f] = pendulum (t, x, opt)

  gl = opt.Coefficients(1);
  damp = opt.Damping(1);

  dotx = zeros (size (x));

  dotx(1,:) = x(2,:);
  ac = -gl*sin (x(1,:)) - damp*x(2,:);

  F= zeros (1, size (x, 2));
  if isfield (opt, 'Actuation')
     F = opt.Actuation;
     if ~isnumeric (F);
       F = F(t, x, opt);
     end
  end

  dotx(2,:) =  ac + F;

  if nargout > 1
      nt = size (x, 2);
      dotxdx = zeros (2, 2, nt);

      dotxdx(1,:,:) = [zeros(1, nt); ones(1, nt)]; 
      dotxdx(2,:,:) = [-gl*cos(x(1,:)); -damp*ones(1, nt)];
  end

  if size (x, 2) >= 2 && nargout > 2
  %% inverse dynamics
     aci = ppval (ppder (spline (t, x(2,:))), t);
     f = aci' - ac;
  end
endfunction
