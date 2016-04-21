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
## {[@var{a},@var{b},@var{c}]=}Minductors(@var{string},@var{parameters},@
## @var{parameternames},@var{extvar},@var{intvar},@var{t})
##
## SBN file implementing models for inductors.
##
## @var{string} is used to select among models. Parameters are listed
## as inner items. Possible models are:
##
## @enumerate
## @item @var{string} = "LIN" (Linear inductor model)
## @itemize @minus
## @item L -> inductance value
## @end itemize
## @end enumerate
##
## See the @cite{IFF file format specifications} for details about 
## the output structures.
##
## @seealso{prs_iff,asm_initialize_system,asm_build_system}
## @end deftypefn

function [a,b,c] = Minductors (string,parameters,parameternames,extvar,intvar,t)

  if isempty(intvar)
    intvar = [0 0];
  endif

  switch string 
      
    case "LIN"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
      
      phi = intvar(1);
      jl  = intvar(2);

      a = [0 0 0 0; 
	   0 0 0 0; 
	   0 0 1 0; 
	   0 0 0 0];

      b = [0 0 0 1; 
	   0 0 0 -1; 
	   -1 1 0 0; 
	   0 0 1 -L];

      c = [0 0 0 0]';
    otherwise
      error (["unknown section:" string])
  endswitch

endfunction
  