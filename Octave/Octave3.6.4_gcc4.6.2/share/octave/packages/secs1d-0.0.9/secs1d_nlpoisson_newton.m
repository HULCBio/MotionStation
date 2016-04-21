%% Copyright (C) 2004-2012  Carlo de Falco
%%
%% This file is part of 
%% SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
%%
%% SECS1D is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% SECS1D is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with SECS1D; If not, see <http://www.gnu.org/licenses/>.

%% Solve the non-linear Poisson problem using Newton's algorithm.
%%
%% [V, n, p, res, niter] = secs1d_nlpoisson_newton (x, sinodes, Vin, nin, pin,
%%                                                  Fnin, Fpin, D, l2, er, toll, maxit)
%%
%%     input:  
%%             x       spatial grid
%%             sinodes index of the nodes of the grid which are in the semiconductor subdomain
%%                     (remaining nodes are assumed to be in the oxide subdomain)
%%             Vin     initial guess for the electrostatic potential
%%             nin     initial guess for electron concentration
%%             pin     initial guess for hole concentration
%%             Fnin    initial guess for electron Fermi potential
%%             Fpin    initial guess for hole Fermi potential
%%             D       doping profile
%%             l2      scaled Debye length squared
%%             er      relative electric permittivity
%%             toll    tolerance for convergence test
%%             maxit   maximum number of Newton iterations
%%
%%     output: 
%%             V       electrostatic potential
%%             n       electron concentration
%%             p       hole concentration
%%             res     residual norm at each step
%%             niter   number of Newton iterations

function [V, n, p, res, niter] = secs1d_nlpoisson_newton (x, sinodes, Vin, nin, pin, 
                                                          Fnin, Fpin, D, l2, er, toll, maxit)

  dampit     = 10;
  dampcoeff  = 2;

  sielements = sinodes(1:end-1);
  Nnodes     = numel (x);
  Nelements  = Nnodes - 1;

  V  = Vin;
  Fn = Fnin;
  Fp = Fpin;
  n  = exp ( V(sinodes) - Fn);
  p  = exp (-V(sinodes) + Fp);

  L  = bim1a_laplacian (x, l2 .* er, 1);
  
  b =  zeros (Nelements, 1); 
  b(sielements) = 1;
  
  a =  zeros (Nnodes, 1);
  a(sinodes) = (n + p);

  M = bim1a_reaction (x, b, a);

  a = zeros (Nnodes,1);    
  a(sinodes) = (n - p - D);

  N = bim1a_rhs (x, b, a);

  A = L + M;
  R = L * V + N; 

  normr(1)   = norm (R(2:end-1), inf);
  normrnew   = normr(1);

  for newtit = 1:maxit
    
    dV = zeros (Nnodes, 1);
    dV(2:end-1) = - A(2:end-1, 2:end-1) \ R(2:end-1) ;
  
    tk = 1;
    for dit = 1:dampit
      Vnew   = V + tk * dV;
    
      n  = exp ( Vnew(sinodes) - Fn);
      p  = exp (-Vnew(sinodes) + Fp);

      a  = zeros (Nnodes, 1); 
      a(sinodes) =  (n + p);
      M  = bim1a_reaction (x, b, a);
      Anew  = L + M;

      a = zeros (Nnodes,1); 
      a(sinodes) = (n - p - D);
      N = bim1a_rhs (x, b, a);
      Rnew = L * Vnew  + N; 
    
      normrnew = norm (Rnew(2:end-1), inf);
      if (normrnew > normr(newtit))
        tk = tk / dampcoeff;
      else
        A = Anew;
        R = Rnew;
        break
      endif	
      
    endfor

    V               = Vnew;	
    normr(newtit+1) = normrnew;
    reldVnorm       = norm (tk*dV, inf) / norm (V, inf);
    
    if (reldVnorm <= toll)
      break
    endif

  endfor

  res   = normr;
  niter = newtit;

endfunction

%!demo
%! secs1d_physical_constants
%! secs1d_silicon_material_properties
%! 
%! tbulk= 1.5e-6;
%! tox = 90e-9;
%! L = tbulk + tox;
%! cox = esio2/tox;
%! 
%! Nx  = 50;
%! Nel = Nx - 1;
%! 
%! x = linspace (0, L, Nx)';
%! sinodes = find (x <= tbulk);
%! xsi = x(sinodes);
%! 
%! Nsi = length (sinodes);
%! Nox = Nx - Nsi;
%! 
%! NelSi   = Nsi - 1;
%! NelSiO2 = Nox - 1;
%! 
%! Na = 1e22;
%! D = - Na * ones (size (xsi));
%! p = Na * ones (size (xsi));
%! n = (ni^2) ./ p;
%! Fn = Fp = zeros (size (xsi));
%! Vg = -10;
%! Nv = 80;
%! for ii = 1:Nv
%!     Vg = Vg + 0.2;
%!     vvect(ii) = Vg; 
%!     
%!     V = - Phims + Vg * ones (size (x));
%!     V(sinodes) = Fn + Vth * log (n/ni);
%!     
%!     % Scaling
%!     xs  = L;
%!     ns  = norm (D, inf);
%!     Din = D / ns;
%!     Vs  = Vth;
%!     xin   = x / xs;
%!     nin   = n / ns;
%!     pin   = p / ns;
%!     Vin   = V / Vs;
%!     Fnin  = (Fn - Vs * log (ni / ns)) / Vs;
%!     Fpin  = (Fp + Vs * log (ni / ns)) / Vs;
%!     
%!     er    = esio2r * ones(Nel, 1);
%!     l2(1:NelSi) = esi;
%!     l2    = (Vs*e0)/(q*ns*xs^2);
%!     
%!     % Solution of Nonlinear Poisson equation
%!     
%!     % Algorithm parameters
%!     toll  = 1e-10;
%!     maxit = 1000;
%!     
%!     [V, nout, pout, res, niter] = secs1d_nlpoisson_newton (xin, sinodes, 
%!                                                            Vin, nin, pin,
%!                                                            Fnin, Fpin, Din, l2,
%!                                                            er, toll, maxit);
%! 
%!     % Descaling
%!     n     = nout*ns;
%!     p     = pout*ns;
%!     V     = V*Vs;
%!     
%!     qtot(ii) = q * trapz (xsi, p + D - n);
%! end
%! 
%! vvectm = (vvect(2:end)+vvect(1:end-1))/2;
%! C = - diff (qtot) ./ diff (vvect);
%! plot(vvectm, C)
%! xlabel('Vg [V]')
%! ylabel('C [Farad]')
%! title('C-V curve')
