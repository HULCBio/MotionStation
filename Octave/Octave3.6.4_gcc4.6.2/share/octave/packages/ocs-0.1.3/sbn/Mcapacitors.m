## Copyright (C) 2006,2007,2008  Carlo de Falco            
##
## This file is part of:
## OCS - A Circuit Simulator for Octave
##
## OCS is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program (see the file LICENSE); if not,
## see <http://www.gnu.org/licenses/>.
##
## author: Carlo de Falco <cdf _AT_ users.sourceforge.net> 

## -*- texinfo -*-
##
## @deftypefn{Function File} @
## {[@var{a},@var{b},@var{c}]=} Mcapacitors(@var{string},@var{parameters},@
## @var{parameternames},@var{extvar},@var{intvar},@var{t})
##
## SBN file implementing models for capacitors.
##
## @var{string} is used to select among models. Parameters are listed
## as inner items. Possible models are:
##
## @enumerate
## @item @var{string} = "LIN"  (Linear Capacitor)
## @itemize @minus
## @item C -> capacitance value
## @end itemize
## @item @var{string} = "MULTICAP" (Multipole Capacitor)
## @itemize @minus
## @item C -> capacitance values
## @end itemize
## @item @var{string} = "PDE_NMOS" (Drift-Diffusion PDE NMOS capacitor)
## @itemize @minus
## @item tbulk  -> bulk thickness
## @item tox    -> oxide thickness
## @item Nnodes -> number of nodes of 1D grid 
## @item Na     -> bulk doping
## @item toll   -> absolute tolerance
## @item maxit  -> max iterations number
## @item Area   -> device area
## @end itemize
## @end enumerate
##
## See the @cite{IFF file format specifications} for details about 
## the output structures.
##
## @seealso{prs_iff,asm_initialize_system,asm_build_system}
## @end deftypefn

function [a,b,c] = Mcapacitors(string,parameters,parameternames,extvar,intvar,t)
  
  if isempty(intvar)
    intvar = 0;
  endif

  switch string 
      ##LCR part
    case "LIN"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
            
      a = [0 0 1; 0 0 -1; 0 0 0];
      b = [0 0 0;0 0 0;-C C 1];
      c = [0 0 0]';
      break

    case "MULTICAP"
      
      n = length(extvar);
      C = reshape(parameters,n,n);
      
      a = [zeros(n) eye(n); zeros(n) zeros(n)];
      b = [zeros(n) zeros(n); -C eye(n)];
      c = [zeros(2*n,1)]';
      
      break  

      ##NLC part
    case "PDE_NMOS"
      
      constants
      
      tbulk =  1.5e-6;
      tox   =  90e-9;
      len = tbulk + tox;
      Nnodes = 300;
      Na=1e21;
      toll  = 1e-10;
      maxit = 1000;
      Area = 1e-12;

      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
      
      Vg = extvar(1) - extvar(2);
      q  = intvar(1);

      [Q,C]=Mnmoscap(tbulk,tox,Area,Vg,Na,Nnodes,toll,maxit);
      
      a = [0 0 1; 0 0 -1; 0 0 0];
      b = [0 0 0;0 0 0;C -C -1];
      c = [0 0 Q-q]';
      break  

    otherwise
      error (["unknown section:" string])
  endswitch

endfunction
## Non-linear 1D MOS structure.
## FIXME: requires SECS1D!!!
function [Q,C]=Mnmoscap(tbulk,tox,Area,Vg,Na,Nnodes,toll,maxit);
  
  constants 

  Nelements = Nnodes - 1;
  len = tox+tbulk;
  x = linspace(0,len,Nnodes)';
  sinodes = find(x<=tbulk);
  Nsinodes = length(sinodes);
  NelementsSi = Nsinodes-1;
  D = - Na* ones(Nsinodes,1);
  pp = Na ;
  p = pp* ones(Nsinodes,1);
  n = (ni^2)./p;
  Fn = 0*n;
  Fp = 0*n;

  V = -Phims + Vg * ones(Nnodes,1);
  V(sinodes) = Fn + Vth*log(n/ni);
  
  ## Scaling
  xs  = len;
  ns  = norm(D,inf);
  Din = D/ns;
  Vs  = Vth;
  xin   = x/xs;
  nin   = n/ns;
  pin   = p/ns;
  Vin   = V/Vs;
  Fnin  = (Fn - Vs * log(ni/ns))/Vs;
  Fpin  = (Fp + Vs * log(ni/ns))/Vs;
  
  l2    = (Vs*esio2)/(q*ns*xs^2)* ones(Nelements,1);
  l2(1:NelementsSi)    = (Vs*esi)/(q*ns*xs^2);
  
  ## Solution of Nonlinear Poisson equation
  [V,nout,pout,res,niter] = DDGnlpoisson (xin,sinodes,Vin,nin,...
				       pin,Fnin,Fpin,Din,l2,...
				       toll,maxit,0);
    
  L = Ucomplap(xin,Nnodes,[],Nelements,l2);
  C22 = L(end,end);
  C12 = L(2:end-1,end);
  C11 = L(2:end-1,2:end-1);

  drdv  = zeros(Nnodes,1);    drdv(sinodes) = nout + pout;
  coeff = zeros(Nelements,1); coeff(1:NelementsSi) = 1;
  M     = Ucompmass(xin,Nnodes,[],[],drdv,coeff);
  C     = C22 - C12'*((C11+M(2:end-1,2:end-1))\C12);
  Q     =(C12'*V(2:end-1)+C22*V(end));

  ## Descaling
  C = Area*C*(q*ns*xs/Vs);
  Q = Area*Q*(q*ns*xs);

endfunction