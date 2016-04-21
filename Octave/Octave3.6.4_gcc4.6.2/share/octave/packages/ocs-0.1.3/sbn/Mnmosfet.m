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
## {[@var{a},@var{b},@var{c}]=}Mnmosfet(@var{string},@var{parameters},@
## @var{parameternames},@var{extvar},@var{intvar},@var{t})
##
## SBN file implementing standard models for n-mosfets.
##
## @var{string} is used to select among models. Parameters are listed
## as inner items. Possible models are:
##
## @enumerate
## @item @var{string} = "simple" (Standard model for MOSFET)
## @itemize @minus
## @item rd  -> parasitic resistance between drain and source
## @item k   -> k parameter for usual mosfet model
## @item Vth -> threshold voltage
## @end itemize
## @item @var{string} = "lincap" (Adds RC parasitics)
## @itemize @minus
## @item rd  -> parasitic resistance between drain and source
## @item k   -> k parameter for usual mosfet model
## @item Vth -> threshold voltage
## @item Rs  -> parasitic source resistance 
## @item Rd  -> parasitic drain resistance
## @item Cs  -> gate-source capacitance
## @item Cd  -> gate-drain capacitance
## @item Cb  -> gate-bulk capacitance
## @end itemize
## @end enumerate
##
## See the @cite{IFF file format specifications} for details about 
## the output structures.
##
## @seealso{prs_iff,asm_initialize_system,asm_build_system}
## @end deftypefn

function [a,b,c]=Mnmosfet(string,parameters,parameternames,extvar,intvar,t) 
  
  switch string
    case "simple"
      
      rd   = 1e6;
      k    = 1e-5;
      Vth  = .5;

      for ii=1:length(parameternames)
	eval([parameternames{ii} "=",...
	      num2str(parameters(ii)) " ;"])	
      endfor

      vg   = extvar(1);
      vs   = extvar(2);
      vd   = extvar(3);
      vb   = extvar(4);

      vgs  = vg-vs;
      vds  = vd-vs;
      
      if (vgs < Vth)

	
	gm = 0;
	gd = 1/rd;
	id = vds*gd;
	
      elseif (((vgs-Vth) >= (vds)) && (vds>=0))
	
	id = k*((vgs-Vth)*vds-(vds^2)/2)+vds/rd;
	gm = k*vds;
	gd = k*(vgs-Vth-vds)+1/rd;

      elseif (((vgs-Vth) >= (vds)) && (vds<0))
	
	gm = 0;
	gd = 1/rd;
	id = vds*gd;

      else # (i.e. if 0 <= vgs-vth <= vds)

	id = (k/(2))*(vgs-Vth)^2+vds/rd;
	gm = (2*k/(2))*(vgs-Vth);
	gd = 1/rd;

      endif
      
      a = zeros(4);
      
      b = [0    0       0 0;
	   -gm  (gm+gd) -gd 0; 
	   gm -(gm+gd)  gd 0;
	   0    0       0  0];
      
      c = [0 -id id 0]';
      break;

    case "lincap"

      ## Default parameter values
      if isempty(intvar)
	intvar = zeros(5,1);
      endif
      Rs = 1e2; Rd = 1e2; Cs = 1e-15; 
      Cd = 1e-15; Cb = 1e-14;
      rd = inf; k = 1e-3; Vth = .1; 

      ## parameters given in input
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=",...
	      num2str(parameters(ii)) " ;"])	
      endfor
      
     
      persistent tmpstruct
      
      if isempty(tmpstruct)
 
	mtdnmos   = file_in_path(path,"Mtdnmos.cir");
	mtdnmos(end-3:end)=[];
        tmpstruct = prs_iff(mtdnmos);
  
      endif
     

      tmpstruct.NLC.pvmatrix    = [k Vth rd];
      tmpstruct.LCR(1).pvmatrix = [Rs; Rd];
      tmpstruct.LCR(2).pvmatrix = [Cs; Cd; Cb];

      [A0,B,C]     = asm_initialize_system(tmpstruct,[extvar;intvar]);
      [A1,Jac,res] = asm_build_system(tmpstruct,[extvar;intvar],t);

      a = A0+A1;
      b = B+Jac;
      c = res + B*[extvar;intvar] + C;

      break;
    otherwise
      error(["unknown option:" string]);
  endswitch

endfunction
