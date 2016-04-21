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
%% @deftypefn {Function File} {@var{t},@var{pos},@var{vel}} = mdsim (@var{func},@var{tspan},@var{p0},@var{v0})
%% Integrates a system of particles using velocity Verlet algorithm.
%%
%% @end deftypefn

function [tspan y vy] = mdsim(func,tspan,x0,v0,varargin);

  %% Parse options
  options = {"mass","timestep","nonperiodic","substeps","boxlength"};
  opt_given = {varargin{1:2:end}};
  [tf idx] = ismember (options, opt_given);

  % Parse masses
  m = ones (size (x0,1), 1);
  if tf(1)
    m = varargin{idx(1)+1};
  end

  % Parse time step & substeps
  nT = numel (tspan);
  if nT == 1
    tspan(2)=tspan;
    tspan(1)=0;
  end
  
  if tf(2) && tf(4)
      error('mdsim:Error','You cannot define substeps and dt simultaneously.\n');
  elseif tf(2) && ~tf(4)

    dt = varargin{idx(2)+1};
    if ~isscalar (dt) || any (dt < 0);
      error('mdsim:Error','Timestep must be a positive scalar.\n');
    end

    substep = round( (tspan(2)-tspan(1)) / dt);

  elseif ~tf(2) && tf(4)

    substep = varargin{idx(4)+1};
    if ~isscalar (substep) || any (substep < 2);
      error('mdsim:Error','Substeps must be a natural number >= 2.\n');
    end

    dt = (tspan(2)-tspan(1)) / (substep-1);

  else
    substep = 1e1;
    dt = (tspan(2)-tspan(1)) / (substep-1);
  end

  % Parse periodic bc or not
  L = 1;
  if tf(5)
    L = varargin{idx(5)+1};
    if ~isscalar (L) || any (L < 0);
      error('mdsim:Error','Length of box side should be a positive scalar.\n');
    end
  end
  if nargout(func) < 2 && nargin(func) < 4
    error('mdsim:Error',['Interaction force must accept at least 4 arguments'...
           'and return at least 2, when boundary conditions are periodic.\n']);
  end
  integrator = @(x_,v_,dt_) verletstep_boxed (x_, v_, m, dt_, func, L);

  if tf(3)
    if nargout(func) < 2 && nargin(func) < 2
      error('mdsim:Error',['Interaction force must accept at least 2' ...
             'arguments\nwhen boundary conditions are not periodic.\n']);
    end
    integrator = @(x_,v_,dt_) verletstep (x_, v_, m, dt_, func);
  end

  %% Allocate
  [N dim] = size(x0);
  y = zeros (N, dim, nT);

  if nargout > 2
    vy = y;
    vy(:,:,1) = v0;  
  end

  %% Iterate ------------
  if tf(3)
    y(:,:,1) = x0;
    auxX = x0;
    auxV = v0;
  else
    auxX = x0;
    ind = find(x0 < -L/2);
    auxX(ind) = auxX(ind) + L * abs (round (auxX(ind)/L));
    ind = find(x0 > -L/2);
    auxX(ind) = auxX(ind) - L * abs (round (auxX(ind)/L));
    y(:,:,1) = auxX;
    auxV = v0;
  end
    
  for it = 2:nT

    for jt = 1:substep
      [auxX auxV] = integrator (auxX, auxV, dt);
    end

    y(:,:,it) = auxX;
    if nargout > 2
     vy(:,:,it) = auxV;
    end
    
  end
  
  if dim == 1
    y = squeeze (y);
    if nargout > 2
      vy = squeeze (vy);
    end
  end
  
endfunction

% Test arguments
%!function [fx fy] = func4 (xq, x2, v1, v2)
%!  fx = 0; fy = 0;
%! end

%!function [fx fy] = func2 (dx, dv)
%!  fx = 0; fy = 0;
%! end

%!error (mdsim (@func2, [0 1], 0, 0, "nonperiodic", false))
%!error (mdsim (@func4, [0 1], 0, 0, "nonperiodic", true))
%!error (mdsim (@func4, [0 1], 0, 0))
%!error (mdsim (@func2, [0 1], 0, 0,"timestep",-1))
%!error (mdsim (@func2, [0 1], 0, 0,"timestep",[0 1]))
%!error (mdsim (@func2, [0 1], 0, 0,"timestep",1,"substep",2))
%!error (mdsim (@func2, [0 1], 0, 0,"substep",0))
%!error (mdsim (@func2, [0 1], 0, 0,"substep",[0 1]))
%!error (mdsim (@func2, [0 1], 0, 0,"boxlength",-1))
%!error (mdsim (@func2, [0 1], 0, 0,"boxlength",[1 2]))
%!error (mdsim ([], [0 1], 0, 0,"boxlength",[1 2]))

%!demo
%! N       = 6;
%! P0      = linspace (-0.5+1/(N-1), 0.5-1/(N-1), N).';
%! V0      = zeros (N, 1);
%! nT      = 80;
%! tspan   = linspace(0, 2, nT);
%! [t P V] = mdsim ('demofunc1', tspan, P0, V0,'timestep',1e-3);
%!
%! figure (1)
%! plot (P.',t,'.');
%! xlabel ("Position")
%! ylabel ("Time")
%! axis tight
%!
%! disp("Initial values")
%! disp ( sum ([V(:,1) P(:,1)], 1) )
%! disp("Final values")
%! disp ( sum ([V(:,end) P(:,end)], 1) )
%!
%! %-------------------------------------------------------------------
%! % 1D particles with Lennard-Jones potential and periodic boundaries.
%! % Velocity and position of the center of mass are conserved. 

%!demo
%! N     = 10;
%! P0    = linspace (0,1,N).';
%! V0    = zeros (N, 1);
%! nT    = 80;
%! tspan = linspace(0, 1, nT);
%! [t P] = mdsim ('demofunc2', tspan, P0, V0,'nonperiodic', true);
%!
%! figure (1)
%! plot (P.',t,'.');
%! xlabel ("Position")
%! ylabel ("Time")
%!
%! %-------------------------------------------------------------------
%! % 1D array of springs with damping proportional to relative velocity and
%! % nonzero rest length.


%!demo
%! 
%! input("NOTE: It may take a while.\nPress Ctrl-C to cancel or <enter> to continue: ","s");
%!
%! N       = 4;
%! [Px Py] = meshgrid (linspace (-0.5+0.5/(N-1), 0.5-0.5/(N-1), N));
%! P0      = [Px(:) Py(:)];
%! N       = size(P0,1);
%! P0      = P0 + 0.1* 0.5/N *(2*rand (size (P0)) - 1);
%! V0      = zeros (N, 2);
%! nT      = 80;
%! tspan   = linspace(0, 1, nT);
%! [t P]   = mdsim ('demofunc3', tspan, P0, V0);
%! x       = squeeze(P(:,1,:)); 
%! y       = squeeze(P(:,2,:));
%!
%! figure (1)
%! plot (x.',y.','.',x(:,end),y(:,end),'.k');
%! xlabel ("X")
%! ylabel ("Y")
%! axis tight
%!
%! %-------------------------------------------------------------------
%! % 2D particles with Lennard-Jones potential and periodic boundaries
