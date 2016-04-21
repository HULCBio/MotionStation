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
## {[@var{a},@var{b},@var{c}]=} Mvoltagesources(@var{string},@var{parameters},@
## @var{parameternames},@var{extvar},@var{intvar},@var{t})
##
## SBN file implementing models for voltage sources.
##
## @var{string} is used to select among models. Parameters are listed
## as inner items. Possible models are:
##
## @enumerate
## @item @var{string} = "DC" (Static indipendent voltage source)
## @itemize @minus
## @item V -> Current source value
## @end itemize
## @item @var{string} = "sinwave" (Sinusoidal indipendent voltage
## source)
## @itemize @minus
## @item shift -> mean value of sinusoidal input
## @item Ampl  -> amplitude of sinusoidal wave
## @item f     -> frequency of sinusoidal wave
## @item delay -> delay of sinusoidal wave
## @end itemize
## @item @var{string} = "pwl" (Piecewise linear voltage source)
## @itemize @minus
## @item takes as parameter times and values. For example @code{0 1 4 6}
## means at time instant 0 value 1, at time instant 4 value 6, etc.
## @end itemize
## @item @var{string} = "squarewave" (Square wave)
## @itemize @minus
## @item low   -> low-state value
## @item high  -> high-state value
## @item tlow  -> duration of low-state
## @item thigh -> duration of high-state
## @item delay -> delay of square wave
## @item start -> starting voltage value
## @end itemize
## @item @var{string} = "step" (Voltage step)
## @itemize @minus
## @item low   -> low-state value
## @item high  -> high-state value
## @item tstep -> time instant of step transition
## @end itemize
## @item @var{string} = "VCVS" (Voltage controlled voltage source)
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

function [a,b,c] = Mvoltagesources (string,parameters,parameternames,extvar,intvar,t)

  if isempty(intvar)
    intvar = 0;
  endif

  switch string 
      ##LCR part
    case "DC"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
      
      j = intvar(1);
      
      a = zeros(3);
      b = [0 0 1;0 0 -1;1 -1 0];
      c = [0 0 -V];
      break
      ## NLC part
    case "sinwave"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
     
      DV = shift+Ampl * sin(2*pi*(t+delay)*f );
      j = intvar(1);
      
      a = zeros(3);
      b = [0 0 1;0 0 -1;1 -1 0];
      c = [0 0 -DV]' + b * [extvar;intvar];
      break
    
    case "pwl"

      times = parameters(1:2:end-1);
      values= parameters(2:2:end);
     
      DV = interp1(times,values,t,"linear","extrap");
      j  = intvar(1);
      
      a = zeros(3);
      b = [0 0 1;0 0 -1;1 -1 0];
      c = [0 0 -DV]' + b * [extvar;intvar];
      break
      
    case "squarewave"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
      if t<delay
	if exist("start")
	  DV=start;
	else
	  DV=low;
	endif
      else
	T = tlow+thigh;
	t = mod(t-delay,T);
	if t<tlow
	  DV = low;
	else
	  DV = high;
	endif
      endif
      j = intvar(1);
            
      a = zeros(3);
      b = [0 0 1;0 0 -1;1 -1 0];
      c = [0 0 -DV]' + b * [extvar;intvar];
      break

    case "step"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor
      
      if t<tstep
	DV=low;
      else
	DV = high;
      endif

      j = intvar(1);
      
      a = zeros(3);
      b = [0 0 1;0 0 -1;1 -1 0];
      c = [0 0 -DV]' + b * [extvar;intvar];
      break
      
    case "VCVS"
      K = 1;
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      endfor

      j = intvar(1);
      
      a = zeros(5);
      b = [0 0 0 0 1;0 0 0 0 -1;0 0 0 0 0;0 0 0 0 0;1 -1 -K K 0];
      c = zeros(5,1);
      break
    otherwise
      error (["unknown section:" string])
  endswitch

endfunction
