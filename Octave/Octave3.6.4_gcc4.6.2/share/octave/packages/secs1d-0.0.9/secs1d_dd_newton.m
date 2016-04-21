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

%% Solve the scaled stationary bipolar DD equation system using Newton's method.
%%
%% [n, p, V, Fn, Fp, Jn, Jp, it, res] = secs1d_dd_newton (x, D, Vin, nin, 
%%                                                        pin, l2, er, un, 
%%                                                        up, theta, tn, tp, 
%%                                                        Cn, Cp, toll, maxit)
%%
%%     input: 
%%       x                spatial grid
%%       D                doping profile
%%       pin              initial guess for hole concentration
%%       nin              initial guess for electron concentration
%%       Vin              initial guess for electrostatic potential
%%       l2               scaled Debye length squared
%%       er               relative electric permittivity
%%       un               electron mobility model coefficients
%%       up               electron mobility model coefficients
%%       theta            intrinsic carrier density
%%       tn, tp, Cn, Cp   generation recombination model parameters
%%       toll             tolerance for Gummel iterarion convergence test
%%       maxit            maximum number of Gummel iterarions
%%
%%     output: 
%%       n     electron concentration
%%       p     hole concentration
%%       V     electrostatic potential
%%       Fn    electron Fermi potential
%%       Fp    hole Fermi potential
%%       Jn    electron current density
%%       Jp    hole current density
%%       it    number of Gummel iterations performed
%%       res   total potential increment at each step

function [n, p, V, Fn, Fp, Jn, Jp, it, normr] = secs1d_dd_newton (x, D, Vin, nin, pin, l2, er, un, up, theta, tn, tp, Cn, Cp, toll, maxit)

  dampit     = 10;
  dampcoeff  = 2;
  Nnodes     = numel (x);

  V  = Vin;
  n  = nin;
  p  = pin;

  [res, jac] = residual_jacobian (x, D, V, n, p, l2, er, un, up, theta, tn, tp, Cn, Cp);

  normr(1)   = norm (res, inf);
  normrnew   = normr(1);

  for it = 1:maxit
	    
    delta = - jac \ res;
  
    tk = 1;
    for dit = 1:dampit

      Vnew          = Vin;
      Vnew(2:end-1) = V(2:end-1) + tk * delta(1:Nnodes-2);

      nnew          = nin;
      nnew(2:end-1) = n(2:end-1) + tk * delta((Nnodes-2)+(1:Nnodes-2));

      pnew          = pin;
      pnew(2:end-1) = p(2:end-1) + tk * delta(2*(Nnodes-2)+(1:Nnodes-2));

      [resnew, jacnew] = residual_jacobian (x, D, Vnew, nnew, pnew, l2, er, un, up, theta, tn, tp, Cn, Cp);

      normrnew = norm (resnew, inf);
      if (normrnew > normr(it))
        tk = tk / dampcoeff;
      else
        jac = jacnew;
        res = resnew;
        break
      endif

    endfor

    V = Vnew; n = nnew; p = pnew;
    normr(it+1) = normrnew;

    if (normr(it+1) <= toll)
      break
    endif
  endfor

  dV = diff (V);
  dx = diff (x);
  [Bp, Bm] = bimu_bernoulli (dV);
  Jn = un  .* (n(2:end) .* Bp - n(1:end-1) .* Bm) ./ dx; 
  Jp = -up .* (p(2:end) .* Bm - p(1:end-1) .* Bp) ./ dx;
  Fp = V + log (p);
  Fn = V - log (n);
endfunction

function [res, jac] = residual_jacobian (x, D, V, n, p, l2, er, un, up, theta, tn, tp, Cn, Cp)

  denomsrh   = tn .* (p + theta) + tp .* (n + theta);
  factauger  = Cn .* n + Cp .* p;
  fact       = (1 ./ denomsrh + factauger); 
  nm         = (n(2:end) + n(1:end-1))/2;
  pm         = (p(2:end) + p(1:end-1))/2;

  Nnodes = numel (x);

  A11 = bim1a_laplacian (x, l2 .* er, 1);
  A12 = bim1a_reaction (x, 1, 1);
  A13 = - A12;
  R1  = A11 * V + bim1a_rhs (x, 1, n-p-D);

  A21 = - bim1a_laplacian (x, un .* nm, 1);
  A22 = bim1a_advection_diffusion (x, un, 1, 1, V) + bim1a_reaction (x, 1, p .* fact);
  A23 = bim1a_reaction (x, 1, n .* fact);
  R2  = A22 * n + bim1a_rhs (x, 1, (p .* n - theta .^ 2) .* fact);

  A31 = bim1a_laplacian (x, up .* pm, 1);
  A32 = bim1a_reaction (x, 1, p .* fact);
  A33 = bim1a_advection_diffusion (x, up, 1, 1, -V) + bim1a_reaction (x, 1, n .* fact);
  R3  = A33 * p + bim1a_rhs (x, 1, (p .* n - theta .^ 2) .* fact);

  res = [R1(2:end-1); R2(2:end-1); R3(2:end-1)];

  jac = [A11(2:end-1, 2:end-1), A12(2:end-1, 2:end-1), A13(2:end-1, 2:end-1);
         A21(2:end-1, 2:end-1), A22(2:end-1, 2:end-1), A23(2:end-1, 2:end-1);
         A31(2:end-1, 2:end-1), A32(2:end-1, 2:end-1), A33(2:end-1, 2:end-1)];

endfunction


%!demo
%! % physical constants and parameters
%! secs1d_physical_constants;
%! secs1d_silicon_material_properties;
%! 
%! % geometry
%! L  = 1e-6; % [m] 
%! x  = linspace (0, L, 10)';
%! sinodes = [1:length(x)];
%! 
%! % dielectric constant (silicon)
%! er = esir * ones (numel (x) - 1, 1);
%! 
%! % doping profile [m^{-3}]
%! Na = 1e20 * ones(size(x));
%! Nd = 1e24 * ones(size(x));
%! D  = Nd-Na;  
%! 
%! % externally applied voltages
%! V_p = 10;
%! V_n = 0;
%!  
%! % initial guess for phin, phip, n, p, V
%! Fp = V_p * (x <= L/2);
%! Fn = Fp;
%! 
%! p = abs(D)/2.*(1+sqrt(1+4*(ni./abs(D)).^2)).*(D<0)+...
%!     ni^2./(abs(D)/2.*(1+sqrt(1+4*(ni./abs(D)).^2))).*(D>0);
%! 
%! n = abs(D)/2.*(1+sqrt(1+4*(ni./abs(D)).^2)).*(D>0)+...
%!     ni^2./(abs(D)/2.*(1+sqrt(1+4*(ni./abs(D)).^2))).*(D<0);
%! 
%! V  = Fn + Vth*log(n/ni);
%!
%! % scaling factors
%! xbar = L;                         % [m]
%! nbar = norm(D, 'inf');            % [m^{-3}]
%! Vbar = Vth;                       % [V]
%! mubar = max(u0n, u0p);            % [m^2 V^{-1} s^{-1}]
%! tbar = xbar^2/(mubar*Vbar);       % [s]
%! Rbar = nbar/tbar;                 % [m^{-3} s^{-1}]
%! Ebar = Vbar/xbar;                 % [V m^{-1}]
%! Jbar = q*mubar*nbar*Ebar;         % [A m^{-2}]
%! CAubar = Rbar/nbar^3;             % [m^6 s^{-1}]
%! abar = xbar^(-1);                 % [m^{-1}]
%! 
%! % scaling procedure
%! l2 = e0*Vbar/(q*nbar*xbar^2);     
%! theta = ni/nbar;                  
%! 
%! xin = x/xbar;
%! Din = D/nbar;
%! Nain = Na/nbar;
%! Ndin = Nd/nbar;
%! pin = p/nbar;
%! nin = n/nbar;
%! Vin = V/Vbar;
%! Fnin = Vin - log(nin);
%! Fpin = Vin + log(pin);
%! 
%! tnin = tn/tbar;
%! tpin = tp/tbar;
%! 
%! % mobility model accounting scattering from ionized impurities
%! u0nin = u0n/mubar;
%! uminnin = uminn/mubar;
%! vsatnin = vsatn/(mubar*Ebar);
%! 
%! u0pin = u0p/mubar;
%! uminpin = uminp/mubar;
%! vsatpin = vsatp/(mubar*Ebar);
%! 
%! Nrefnin = Nrefn/nbar;
%! Nrefpin = Nrefp/nbar;
%! 
%! Cnin     = Cn/CAubar;
%! Cpin     = Cp/CAubar;
%! 
%! anin     = an/abar;
%! apin     = ap/abar;
%! Ecritnin = Ecritn/Ebar;
%! Ecritpin = Ecritp/Ebar;
%! 
%! % tolerances for convergence checks
%! ptoll = 1e-12;
%! pmaxit = 1000;
%! 
%! % solve the problem using the Newton fully coupled iterative algorithm
%! [nout, pout, Vout, Fnout, Fpout, Jnout, Jpout, it, res] = secs1d_dd_newton (xin, Din, 
%!                                                                Vin, nin, pin, l2, er, 
%!                                                                u0nin, u0pin, theta, tnin, 
%!                                                                tpin, Cnin, Cpin, ptoll, pmaxit);
%! % Descaling procedure
%! n    = nout*nbar;
%! p    = pout*nbar;
%! V    = Vout*Vbar;
%! Fn   = V - Vth*log(n/ni);
%! Fp   = V + Vth*log(p/ni);
%! dV   = diff(V);
%! dx   = diff(x);
%! E    = -dV./dx;
%! 
%! % compute current densities 
%! [Bp, Bm] = bimu_bernoulli (dV/Vth);
%! Jn       =  q*u0n*Vth .* (n(2:end) .* Bp - n(1:end-1) .* Bm) ./ dx; 
%! Jp       = -q*u0p*Vth .* (p(2:end) .* Bm - p(1:end-1) .* Bp) ./ dx;
%! Jtot     =  Jn+Jp;
%! 
%! % band structure
%! Efn  = -Fn;
%! Efp  = -Fp;
%! Ec   = Vth*log(Nc./n)+Efn;
%! Ev   = -Vth*log(Nv./p)+Efp;
%!
%! plot (x, Efn, x, Efp, x, Ec, x, Ev)
%! legend ('Efn', 'Efp', 'Ec', 'Ev')
%! axis tight