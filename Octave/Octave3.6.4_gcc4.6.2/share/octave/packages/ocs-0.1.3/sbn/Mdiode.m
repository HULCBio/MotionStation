## Copyright (C) 2006,2007,2008  Massimiliano Culpo, Carlo de Falco            
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
## author: culpo@math.uni-wuppertal.de, Carlo de Falco <cdf _AT_ users.sourceforge.net> 

## -*- texinfo -*-
##
## @deftypefn{Function File} @
## {[@var{a},@var{b},@var{c}]=}Mdiode(@var{string},@var{parameters},@
## @var{parameternames},@var{extvar},@var{intvar},@var{t})
##
## SBN file implementing models for diodes.
##
## @var{string} is used to select among models. Parameters are listed
## as inner items. Possible models are:
##
## @itemize @minus
## @item @var{string} = "simple" (Usual exponential diode model)
## @itemize @minus
## @item Is   -> reverse current
## @item Vth  -> thermal voltage
## @item Rpar -> parasitic resistance
## @end itemize
## @item @var{string} = "PDEsymmetric" (Drift-Diffusion PDE model)
## @itemize @minus
## @item len    -> diode length
## @item Nnodes -> number of nodes of 1D grid
## @item Dope   -> doping (abrupt and symmetric)
## @item toll   -> absolute tolerance
## @item maxit  -> max iterations number
## @item Area   -> device area
## @end itemize
## @end itemize
##
## See the @cite{IFF file format specifications} for details about 
## the output structures.
##
## @seealso{prs_iff,asm_initialize_system,asm_build_system}
## @end deftypefn

function [a,b,c] = Mdiode (string,parameters,parameternames,extvar,intvar,t)

  switch string 
      
    case "simple"
      Is = 1e-14;
      Vth = 2.5e-2;
      Rpar = 1e12;
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
      
      vp = extvar(1);
      vm = extvar(2);

      I = Is*(exp((vp - vm)/Vth) -1 ) + (vp - vm)/Rpar;
      geq = Is*exp((vp - vm)/Vth)/Vth + 1/Rpar;

      a = zeros(2);
      b = [geq -geq; -geq geq];
      c = [I ; -I] ;
      break

    case "PDEsymmetric"

      len = 1e-6;
      Nnodes = 100;
      Dope=1e23;
      
      toll  = 1e-5;
      maxit = 100;
      ptoll  = 1e-10;
      pmaxit = 100;

      Area   = 1e-10;

      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor

      vp = extvar(1);
      vm = extvar(2);
      
      [I,g] = Mpdesympnjunct (len,Dope,vp-vm,Area,Nnodes,toll,maxit,ptoll,pmaxit);
      
      a = zeros(2);
      b = [g -g; -g g];
      c = [I ; -I] ;
      
      break

    otherwise
      error(["unknown section:" string])
  endswitch

endfunction
