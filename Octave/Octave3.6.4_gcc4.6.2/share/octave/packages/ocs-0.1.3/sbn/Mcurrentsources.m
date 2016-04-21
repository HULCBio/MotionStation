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
## author culpo@math.uni-wuppertal.de

## -*- texinfo -*-
##
## @deftypefn{Function File} @
## {[@var{a},@var{b},@var{c}]=}Mcurrentsources(@var{string},@var{parameters},@
## @var{parameternames},@var{extvar},@var{intvar},@var{t})
##
## SBN file implementing models for current sources.
##
## @var{string} is used to select among models. Parameters are listed
## as inner items. Possible models are:
##
## @enumerate
## @item @var{string} = "DC" (Static indipendent current source)
## @itemize @minus
## @item I -> Current source value
## @end itemize
## @item @var{string} = "VCCS" (Voltage controlled current source)
## @itemize @minus
## @item K -> Control parameter
## @end itemize
## @item @var{string} = "sinwave" (Sinusoidal indipendent current
## source)
## @itemize @minus
## @item shift -> mean value of sinusoidal input
## @item Ampl  -> amplitude of sinusoidal wave
## @item f     -> frequency of sinusoidal wave
## @item delay -> delay of sinusoidal wave
## @end itemize
## @item @var{string} = "VCPS" (Voltage controlled power source)
## @itemize @minus
## @item K -> Control parameter
## @end itemize
## @end enumerate
##
## See the @cite{IFF file format specifications} for details about 
## the output structures.
##
## @seealso{prs_iff,asm_initialize_system,asm_build_system}
## @end deftypefn

function [a,b,c] = Mcurrentsources (string,parameters,parameternames,extvar,intvar,t)  

  switch string 
    ## LCR part
    case "DC"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
      
      a = zeros(2);
      b = a;
      c = [I -I]';
      break

    case "VCCS"
      ## Voltage controlled current source
      K = 1;
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
      
      a = zeros(4);
      b = [0  0  K -K;\
	   0  0 -K  K;\
	   0  0  0  0;\
	   0  0  0  0];
      c = zeros(4,1);
    ## NLC part
    case "sinwave"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
      
      I = shift+Ampl * sin(2*pi*(t+delay)*f );
      a = zeros(2);
      b = a;
      c = [I -I]';
      break
      
    case "VCPS"
      ## Voltage controlled power source
      K = 1;
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor

      dv   = extvar(3) - extvar(4);
      I    = K*(dv^2);
      dIdv = 2*K*dv;
      
      a = zeros(4);
      b = [0  0  dIdv -dIdv;\
	   0  0 -dIdv  dIdv;\
	   0  0     0     0;\
	   0  0     0     0];
      c = [I -I 0 0];

    otherwise
      error (["unknown section:" string])
  endswitch

endfunction
