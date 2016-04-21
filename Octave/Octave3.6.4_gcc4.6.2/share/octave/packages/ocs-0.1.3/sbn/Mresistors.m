## Copyright (C) 2006,2007,2008  Carlo de Falco, Culpo Massimiliano
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
## author: culpo@math.uni-wuppertal.de

## -*- texinfo -*-
##
## @deftypefn{Function File} @
## {[@var{a},@var{b},@var{c}]=}Mresistors(@var{string},@var{parameters},@
## @var{parameternames},@var{extvar},@var{intvar},@var{t})
##
## SBN file implementing models for resistors.
## 
## @var{string} is used to select among models. Parameters are listed
## as inner items. Possible models are:
##
## @enumerate
## @item @var{string} = "LIN" (Linear resistor)
## @itemize @minus
## @item R -> resistance value
## @end itemize
## @item @var{string} = "THERMAL" (Linear resistor with termal pin)
## @itemize @minus
## @item R0   -> reference resistance value at temperature @code{TNOM}
## @item TC1  -> coefficient for first order Taylor expansion
## @item TC2  -> coefficient for second order Taylor expansion
## @item TNOM -> reference temperature
## @end itemize
## @item @var{string} = "THERMAL1D" (1D Thermal resistor)
## @itemize @minus
## @item L  -> length of 1D domain
## @item N  -> number of discretized elements
## @item cv -> PDE coefficient for dynamic part
## @item k  -> PDE coefficient for diffusion part
## @end itemize
## @end enumerate
##
## See the @cite{IFF file format specifications} for details about 
## the output structures.
##
## @seealso{prs_iff,asm_initialize_system,asm_build_system}
## @end deftypefn


function [a,b,c] =Mresistors(string,parameters,parameternames,extvar,intvar,t)
  
  switch string 
    ## LCR part
    case "LIN"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
      
      vp = extvar(1);
      vm = extvar(2);
      
      a = zeros(2);
      b = [1 -1 ;-1 1]/R;
      c = -[0; 0];
      
      break
      ##NLCpart
    case "THERMAL"

      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
      
      v1 = extvar(1);
      v2 = extvar(2);
      T  = extvar(3);
      
      RT = R0*(1 + TC1*(T-TNOM) + TC2*(T - TNOM)^2);
      dRdT = R0*(TC1 + 2*TC2*(T-TNOM));
      
      i1 = (v1-v2)/RT;
      i2 = (v2-v1)/RT;
      P  = -(v1-v2)^2/RT;
      
      a = zeros(3);
      b = [ 1/RT -1/RT (v2-v1)*dRdT/RT^2;... 
      	   -1/RT 1/RT  (v1-v2)*dRdT/RT^2;...
	   -2*(v1-v2)/RT -2*(v2-v1)/RT (v1-v2)^2*dRdT/RT^2];
      c = [i1 i2 P]';
      
      break;
      
      case "THERMAL1D"
      	 
	 for ii=1:length(parameternames)
		eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
	 endfor

	 h = L/N;
	 
	 A       = (cv*S*h)*speye(N+1);
	 
	 B       = spdiags([ -ones(N+1,1) 2*ones(N+1,1) -ones(N+1,1)],-1:1,N+1,N+1);
	 B(1 ,1)     = 1;
	 B(N+1 ,N+1) = 1;
	 
	 ext=[1 N+1];
	 int=[2:N];
	 
	 a = [A(ext,ext), A(ext,int); A(int,ext), A(int,int)];	  
	 b = k*(S/h)*[B(ext,ext), B(ext,int); B(int,ext), B(int,int)];
	 c = zeros(N+1,1);
      
      break;
      
      otherwise
      error (["unknown section:" string])
  endswitch

endfunction
