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

%%
%% Solve the scaled stationary bipolar DD equation system using Gummel algorithm.
%%
%% [n, p, V, Fn, Fp, Jn, Jp, it, res] = secs1d_dd_gummel_map (x, D, Na, Nd, 
%%                                                       pin, nin, Vin, Fnin, 
%%                                                       Fpin, l2, er, u0n, 
%%                                                       uminn, vsatn, betan, 
%%                                                       Nrefn, u0p, uminp, vsatp, 
%%                                                       betap, Nrefp, theta, tn, tp, 
%%                                                       Cn, Cp, an, ap, Ecritnin, Ecritpin, 
%%                                                       toll, maxit, ptoll, pmaxit)         
%%
%%     input: 
%%            x                        spatial grid
%%            D, Na, Nd                doping profile
%%            pin                      initial guess for hole concentration
%%            nin                      initial guess for electron concentration
%%            Vin                      initial guess for electrostatic potential
%%            Fnin                     initial guess for electron Fermi potential
%%            Fpin                     initial guess for hole Fermi potential
%%            l2                       scaled Debye length squared
%%            er                       relative electric permittivity
%%            u0n, uminn, vsatn, Nrefn electron mobility model coefficients
%%            u0p, uminp, vsatp, Nrefp hole mobility model coefficients
%%            theta                    intrinsic carrier density
%%            tn, tp, Cn, Cp, 
%%            an, ap, 
%%            Ecritnin, Ecritpin       generation recombination model parameters
%%            toll                     tolerance for Gummel iterarion convergence test
%%            maxit                    maximum number of Gummel iterarions
%%            ptoll                    convergence test tolerance for the non linear
%%                                     Poisson solver
%%            pmaxit                   maximum number of Newton iterarions
%%
%%     output: 
%%             n     electron concentration
%%             p     hole concentration
%%             V     electrostatic potential
%%             Fn    electron Fermi potential
%%             Fp    hole Fermi potential
%%             Jn    electron current density
%%             Jp    hole current density
%%             it    number of Gummel iterations performed
%%             res   total potential increment at each step

function [n, p, V, Fn, Fp, Jn, Jp, it, res] = secs1d_dd_gummel_map (x, D, Na, Nd, pin, nin, Vin, 
                                                                    Fnin, Fpin, l2, er, u0n, uminn,
                                                                    vsatn,betan,Nrefn, u0p, 
                                                                    uminp,vsatp,betap,Nrefp,
                                                                    theta, tn, tp, Cn, Cp, an, ap, 
		                                                    Ecritnin, Ecritpin, toll, maxit, 
                                                                    ptoll, pmaxit)         

  p  = pin;
  n  = nin;
  V  = Vin;
  Fp = Fpin;
  Fn = Fnin;
  dx  = diff (x);
  dxm = (dx(1:end-1) + dx(2:end));

  Nnodes = numel (x);
  Nelements = Nnodes -1;

  Jn = zeros (Nelements, 1);
  Jp = zeros (Nelements, 1);

  for it = 1:maxit
  
    [V(:,2), n(:,2), p(:,2)] = secs1d_nlpoisson_newton (x, [1:Nnodes], V(:,1), n(:, 1), 
                                                        p(:,1), Fn(:,1), Fp(:,1), D, l2, 
                                                        er, ptoll, pmaxit); 
  
    dV = diff (V(:, 2));
    E  = - dV ./ dx;
    [Bp, Bm] = bimu_bernoulli (dV);

    [Rn, Rp, Gn, Gp, II] = generation_recombination_model (x, n(:, end), p(:, end),
	                                                   E, Jn, Jp, tn, tp, theta, 
                                                           Cn, Cp, an, ap, Ecritnin, Ecritpin); 
    
    mobility = mobility_model (x, Na, Nd, Nrefn, E, u0n, uminn, vsatn, betan);
    
    A = bim1a_advection_diffusion (x, mobility, 1, 1, V(:, 2));
    M = bim1a_reaction (x, 1, Rn) + bim1a_reaction (x, II, 1);
    
    R = bim1a_rhs (x, 1, Gn);
  
    A = A + M;
  
    n(:,3) = nin;
    n(2:end-1,3) = A(2:end-1, 2:end-1) \ (R(2:end-1) - A(2:end-1, [1 end]) * nin ([1 end]));
    Fn(:,2) = V(:,2) - log (n(:, 3));
    Jn =  mobility .* (n(2:end, 2) .* Bp - n(1:end-1, 2) .* Bm) ./ dx; 

    [Rn, Rp, Gn, Gp, II] = generation_recombination_model (x, n(:, end), p(:, end), 
	                                                   E, Jn, Jp, tn, tp, theta, 
                                                           Cn, Cp, an, ap, Ecritnin, Ecritpin);

    mobility = mobility_model (x, Na, Nd, Nrefp, E, u0p, uminp, vsatp, betap);

    A = bim1a_advection_diffusion (x, mobility, 1, 1, -V(:, 2));
    M = bim1a_reaction (x, 1, Rp) + bim1a_reaction (x, II, 1);
    R = bim1a_rhs (x, 1, Gp);
    A = A + M;
  
    p(:,3) = pin;
    p(2:end-1,3) = A(2:end-1, 2:end-1) \ (R(2:end-1) - A(2:end-1, [1 end]) * pin ([1 end]));
    Fp(:,2) = V(:,2) + log (p(:,3));
    Jp = -mobility .* (p(2:end, 2) .* Bm - p(1:end-1, 2) .* Bp) ./ dx;

    nrfn   = norm (Fn(:,2) - Fn(:,1), inf);
    nrfp   = norm (Fp(:,2) - Fp(:,1), inf);
    nrv    = norm (V(:,2)  - V(:,1),  inf);
    res(it) = max  ([nrfn; nrfp; nrv]);

    if (res(it) < toll)
      break
    endif
    
    V(:,1)  = V(:,end);
    p(:,1)  = p(:,end) ;
    n(:,1)  = n(:,end);
    Fn(:,1) = Fn(:,end);
    Fp(:,1) = Fp(:,end);  
    
  endfor

  n  = n(:,end);
  p  = p(:,end);
  V  = V(:,end);
  Fn = Fn(:,end);
  Fp = Fp(:,end);
  
endfunction

function u = mobility_model (x, Na, Nd, Nref, E, u0, umin, vsat, beta)

  Neff = Na + Nd;
  Neff = (Neff(1:end-1) + Neff(2:end)) / 2;
  
  ubar = umin + (u0 - umin) ./ (1 + (Neff ./ Nref) .^ beta);
  u    = 2 * ubar ./ (1 + sqrt (1 + 4 * (ubar .* abs (E) ./ vsat) .^ 2));

endfunction

function [Rn, Rp, Gn, Gp, II] = generation_recombination_model (x, n, p, E, Jn, Jp, tn, tp, 
                                                                theta, Cn, Cp, an, ap, Ecritn, 
                                                                Ecritp)
  
  denomsrh   = tn .* (p + theta) + tp .* (n + theta);
  factauger  = Cn .* n + Cp .* p;
  fact       = (1 ./ denomsrh + factauger);

  Rn = p .* fact;
  Rp = n .* fact;

  Gn = theta .^ 2 .* fact;
  Gp = Gn;

  II = an * exp(-Ecritn./abs(E)) .* abs (Jn) + ap * exp(-Ecritp./abs(E)) .* abs (Jp);

endfunction


%!demo
%! % physical constants and parameters
%! secs1d_physical_constants;
%! secs1d_silicon_material_properties;
%! 
%! % geometry
%! L  = 10e-6;          % [m] 
%! xm = L/2;
%! 
%! Nelements = 1000;
%! x         = linspace (0, L, Nelements+1)';
%! sinodes   = [1:length(x)];
%! 
%! % dielectric constant (silicon)
%! er = esir * ones (Nelements, 1);
%! 
%! % doping profile [m^{-3}]
%! Na = 1e23 * (x <= xm);
%! Nd = 1e23 * (x > xm);
%! 
%! % avoid zero doping
%! D  = Nd - Na;  
%!  
%! % initial guess for n, p, V, phin, phip
%! V_p = -1;
%! V_n =  0;
%! 
%! Fp = V_p * (x <= xm);
%! Fn = Fp;
%! 
%! p = abs (D) / 2 .* (1 + sqrt (1 + 4 * (ni./abs(D)) .^2)) .* (x <= xm) + ...
%!     ni^2 ./ (abs (D) / 2 .* (1 + sqrt (1 + 4 * (ni ./ abs (D)) .^2))) .* (x > xm);
%! 
%! n = abs (D) / 2 .* (1 + sqrt (1 + 4 * (ni ./ abs (D)) .^ 2)) .* (x > xm) + ...
%!     ni ^ 2 ./ (abs (D) / 2 .* (1 + sqrt (1 + 4 * (ni ./ abs (D)) .^2))) .* (x <= xm);
%! 
%! V = Fn + Vth * log (n / ni);
%! 
%! % scaling factors
%! xbar = L;                       % [m]
%! nbar = norm(D, 'inf');          % [m^{-3}]
%! Vbar = Vth;                     % [V]
%! mubar = max (u0n, u0p);         % [m^2 V^{-1} s^{-1}]
%! tbar = xbar^2 / (mubar * Vbar); % [s]
%! Rbar = nbar / tbar;             % [m^{-3} s^{-1}]
%! Ebar = Vbar / xbar;             % [V m^{-1}]
%! Jbar = q * mubar * nbar * Ebar; % [A m^{-2}]
%! CAubar = Rbar / nbar^3;         % [m^6 s^{-1}]
%! abar = 1/xbar;                  % [m^{-1}]
%! 
%! % scaling procedure
%! l2 = e0 * Vbar / (q * nbar * xbar^2);
%! theta = ni / nbar;
%! 
%! xin = x / xbar;
%! Din = D / nbar;
%! Nain = Na / nbar;
%! Ndin = Nd / nbar;
%! pin = p / nbar;
%! nin = n / nbar;
%! Vin = V / Vbar;
%! Fnin = Vin - log (nin);
%! Fpin = Vin + log (pin);
%! 
%! tnin = tn / tbar;
%! tpin = tp / tbar;
%! 
%! u0nin = u0n / mubar;
%! uminnin = uminn / mubar;
%! vsatnin = vsatn / (mubar * Ebar);
%! 
%! u0pin = u0p / mubar;
%! uminpin = uminp / mubar;
%! vsatpin = vsatp / (mubar * Ebar);
%! 
%! Nrefnin = Nrefn / nbar;
%! Nrefpin = Nrefp / nbar;
%! 
%! Cnin     = Cn / CAubar;
%! Cpin     = Cp / CAubar;
%! 
%! anin     = an / abar;
%! apin     = ap / abar;
%! Ecritnin = Ecritn / Ebar;
%! Ecritpin = Ecritp / Ebar;
%! 
%! % tolerances for convergence checks
%! toll  = 1e-3;
%! maxit = 1000;
%! ptoll = 1e-12;
%! pmaxit = 1000;
%! 
%! % solve the problem using the full DD model
%! [nout, pout, Vout, Fnout, Fpout, Jnout, Jpout, it, res] = ...
%!       secs1d_dd_gummel_map (xin, Din, Nain, Ndin, pin, nin, Vin, Fnin, Fpin, ...
%!                             l2, er, u0nin, uminnin, vsatnin, betan, Nrefnin, ...
%! 	                       u0pin, uminpin, vsatpin, betap, Nrefpin, theta, ...
%! 		               tnin, tpin, Cnin, Cpin, anin, apin, ...
%! 		               Ecritnin, Ecritpin, toll, maxit, ptoll, pmaxit); 
%! 
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
%! % band structure
%! Efn  = -Fn;
%! Efp  = -Fp;
%! Ec   = Vth*log(Nc./n)+Efn;
%! Ev   = -Vth*log(Nv./p)+Efp;
%! 
%! plot (x, Efn, x, Efp, x, Ec, x, Ev)
%! legend ('Efn', 'Efp', 'Ec', 'Ev')
%! axis tight