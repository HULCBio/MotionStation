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
## {[@var{j},@var{g}]=}Mpdesympnjunct@
## (@var{len}, @var{Dope}, @var{va}, @
## @var{Area}, @var{Nnodes}, @var{toll}, @var{maxit}, @var{ptoll}, @var{pmaxit})
##
## INTERNAL FUNCTION:
##
## NOT SUPPOSED TO BE CALLED DIRECTLY BY USERS
## @end deftypefn

function [j,g] = Mpdesympnjunct (len,Dope,va,Area,Nnodes,toll,maxit,ptoll,pmaxit)
  
  constants

  x = linspace(0,len,Nnodes)';
  xm = mean(x);
  Nd=Dope;
  Na=Dope;
  nn = (Nd + sqrt(Nd^2+4*ni^2))/2;
  pp = (Na + sqrt(Na^2+4*ni^2))/2;
  xn = xm+len/10;
  xp = xm-len/10;
  D = Nd * (x>xm) - Na * (x<=xm);

  ## Scaling coefficients
  xs        = len;
  ns        = norm(D,inf);
  Vs        = Vth;
  us        = un;
  Js        = (Area*us*Vs*q*ns/xs);
  xin       = x/xs;
  gs        = Js/Vs;
  
  n = nn * (x>=xn) + (ni^2)/pp * (x<xn);
  p = (ni^2)/nn * (x>xp) + pp * (x<=xp);
  
  Fn = va*(x<=xm);
  Fp = Fn;
  
  V  = (Fn - Vth * log(p/ni)); 
  
  ## Scaling
  idata.D    = D/ns;
  idata.un   = un/us;
  idata.up   = up/us;
  idata.tn   = inf;
  idata.tp   = inf;
  idata.l2   = (Vs*esi)/(q*ns*xs^2);
  idata.nis  = ni/ns;
  idata.n   = n/ns;
  idata.p   = p/ns;
  idata.V   = V/Vs;
  idata.Fn  = (Fn - Vs * log(ni/ns))/Vs;
  idata.Fp  = (Fp + Vs * log(ni/ns))/Vs;
  

  ## Solution of DD system    
  ## Algorithm parameters
 
  sinodes = [1:length(x)];
  
  [idata,it,res] = DDGgummelmap (xin,idata,toll,maxit/2,ptoll,pmaxit,0);
  [odata,it,res] = DDNnewtonmap (xin,idata,toll,maxit/2,0);
  
  DV = diff(odata.V);
  h  = xin(2)-xin(1);
  
  Bp = Ubernoulli(DV,1);
  Bm = Ubernoulli(DV,0);
  
  Jn = -odata.un * (odata.n(2:end).*Bp-odata.n(1:end-1).*Bm)/h;
  Jp =  odata.up * (odata.p(2:end).*Bm-odata.p(1:end-1).*Bp)/h;
    
  coeff = idata.un.*Umediaarmonica(odata.n);
  L =- Ucomplap (xin,Nnodes,[],[],coeff);
  Jn1 = L*odata.Fn;
  fprintf(1,"jn1=%g\n",Jn1(1))
  fprintf(1,"jn=%g\n",Jn(1))
  
  C11 = L(1,1);
  C1I = L(1,2:end-1);
  CII = L(2:end-1,2:end-1);
  Gn   = C11 - C1I*(CII\C1I');
  Gn   = Gn - coeff(1)*(odata.Fn(2)-odata.Fn(1))/h

  coeff = idata.up.*Umediaarmonica(odata.p);
  L =- Ucomplap (xin,Nnodes,[],[],coeff);
  Jp1 = L*odata.Fp;
  fprintf(1,"jp1=%g\n",Jp1(1))
  fprintf(1,"jp=%g\n",Jp(1))
  
  C11 = L(1,1);
  C1I = L(1,2:end-1);
  CII = L(2:end-1,2:end-1);
  Gp   = C11 - C1I*(CII\C1I');
  Gp   = Gp - coeff(1)*(odata.Fp(2)-odata.Fp(1))/h


  ## Descaling
  j= -(Jp(1)+Jn(1))*Js
  g= gs*(Gn+Gp)

endfunction