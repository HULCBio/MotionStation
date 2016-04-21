%% Copyright (c) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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
%% @deftypefn {Function File} {[@var{J} @var{sigma}]= } rodmassmatrix (@var{sigma},@var{l}, @var{rho})
%% Mass matrix of one dimensional rod in 3D.
%%
%% Let q be the configuration vector of the rod, with the first three elements of
%% q being the spatial coordinates (e.g. x,y,z) and the second three elements of
%% q the rotiational coordinates (e.g. Euler angles), then the kinetical energy
%% of the rod is given by
%% T = 1/2 (dqdt)^T kron(J,eye(3)) dqdt
%%
%% @var{sigma} is between 0 and 1. Corresponds to the point in the rod that is
%% being used to indicate the position of the rod in space.
%% If @var{sigma} is a string then the value corresponding to the center of mass
%% of the rod. This makes @var{J} a diagonal matrix. If @var{sigma} is a string
%% the return value of @var{sigma} corresponds to the value pointing to the
%% center of mass.
%%
%% @var{l} is the length of the rod. If omitted the rod has unit length.
%%
%% @var{rho} is a function handle to the density of the rod defined in the
%% interval 0,1. The integral of this density equals the mass and is stored in
%% @code{@var{J}(1,1)}. If omitted, the default is a uniform rod with unit mass.
%%
%% Run @code{demo rodmassmatrix} to see some examples.
%%
%% @end deftypefn

function [J varargout] = rodmassmatrix(sigma, l = 1, dens = @(x)1)

  if ischar (sigma)
    sigma = quadgk (@(x)x.*dens(x), 0,1);
  end

  u = [-sigma*l (1-sigma)*l];

  m      = quadgk (@(x)dens(sigma+x/l), u(1),u(2))/l;
  f      = quadgk (@(x)dens(sigma+x/l).*x, u(1),u(2))/l;
  iner_m = quadgk (@(x)dens(sigma+x/l).*x.^2, u(1),u(2))/l;

  J = [m f; f iner_m];

  if nargout > 0
    varargout{1} = quadgk (@(x)x.*dens(x), 0,1);
  end

endfunction

%!demo
%! barlen  = 2;
%! [Jc, s] = rodmassmatrix (0, barlen);
%!
%! printf ("Inertia matrix from the extrema : \n")
%! disp (Jc)
%! printf ("Sigma value to calculate from center of mass : %g \n",s)
%!
%! J = rodmassmatrix (s);
%! printf ("Inertia matrix from the CoM : \n")
%! disp (J)
%!
%! J2 = rodmassmatrix ("com");
%! tf = all((J2 == J)(:));
%! disp (["Are J and J2 equal? " "no"*not(tf) "yes"*tf])
%!
%! % ----------------------------------------------------------------------------
%! % This example shows the calculations for rod of length 2. First we place one
%! % of its extrema in the origin. Then we use the value of sigma provided by
%! % the function to do the same calculation form the center of mass.

%!demo
%! % A normalized density function
%! density = @(x) (0.5*ones(size(x)) + 10*(x<0.1)).*(x>=0 & x<=1)/1.5;
%! [Jc, s] = rodmassmatrix (0,1,density);
%!
%! printf ("Inertia matrix from the extrema : \n")
%! disp (Jc)
%! printf ("Sigma value to calculate from center of mass : %g \n",s)
%! J = rodmassmatrix (s,1,density);
%!
%! printf ("Inertia matrix from the CoM : \n")
%! disp (J)
%!
%! figure (1)
%! clf
%! x = linspace (0,1,100)';
%! h = plot (x,density(x),'b-;density;');
%! set (h,'linewidth',2)
%! axis tight
%! v = axis();
%! hold on
%! h = plot ([s s],v([3 4]),'k-;CoM;');
%! set (h, 'linewidth', 2);
%! hold off
%! axis auto
%! % ----------------------------------------------------------------------------
%! % This example defines a density function with an accumulation of mass near
%! % one end of the rod. First we place one of its extrema in the origin. Then
%! % we use the value of sigma provided by the function to do the same
%! % calculation form the center of mass.
