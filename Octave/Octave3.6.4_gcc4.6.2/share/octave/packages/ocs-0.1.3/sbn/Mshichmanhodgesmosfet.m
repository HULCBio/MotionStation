## Copyright (C) 2006-2009  Carlo de Falco, Massimiliano Culpo
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
## author: Carlo de Falco <cdf _AT_ users.sourceforge.net>, culpo@math.uni-wuppertal.de

## -*- texinfo -*-
##
## @deftypefn{Function File} @
## {[@var{a},@var{b},@var{c}]=} Mshichmanhodgesmosfet(@var{string},@var{parameters},@
## @var{parameternames},@var{extvar},@var{intvar},@var{t})
##
## SBN file implementing Schichman-Hodges MOSFETs model.
##
## @var{string} is used to select among models. Possible models are:
##
## @enumerate
## @item @var{string} = "NMOS" (Schichman-Hodges n-MOSFET)
## @item @var{string} = "PMOS" (Schichman-Hodges p-MOSFET)
## @end enumerate
##
## Parameters for all the above models are:
## @itemize
## @item rd     -> parasitic resistance between drain and source
## @item W      -> MOSFET width
## @item L      -> channel length
## @item mu0    -> reference value for mobility
## @item Vth    -> threshold voltage
## @item Cox    -> oxide capacitance
## @item Cgs    -> gate-source capacitance
## @item Cgd    -> gate-drain capacitance
## @item Cgb    -> gate-bulk capacitance
## @item Csb    -> source-bulk capacitance
## @item Cdb    -> drain-bulk capacitance
## @item Tshift -> shift for reference temperature on MOSFETs (default 0)
## @end itemize
##
## See the @cite{IFF file format specifications} for details about 
## the output structures.
##
## @seealso{prs_iff,asm_initialize_system,asm_build_system}
## @end deftypefn

function [a,b,c]= Mshichmanhodgesmosfet (string,parameters,parameternames,extvar,intvar,t)   

  if isempty(intvar)
    ## If intvar is empty, then we are initializing the system
    ## and there is no need of a matrix evaluation
    a = sparse(10,10);
    b = [];
    c = [];
  else
    ## If intvar is NOT empty, then we are evaluating the 
    ## element stamp
    switch string
      case "NMOS"
	
	rd   = 1e6;
	W    = 1;
	L    = 1;
	mu0  = 1e-5;
	Vth  = .5;
	Cox  = 1e-9;
	Cgb  = Cox;
	Cgs=Cgd=Csb=Cdb=.1*Cox;
	Tshift = 0;

	for ii=1:length(parameternames)
	  eval([parameternames{ii} "=",...
		num2str(parameters(ii)) " ;"])	
	endfor

	[gm,gd,ids,didT,P,dPdT,dPdvgs,dPdvds] = \
	    nmos(extvar,mu0,Cox,W,L,Vth,rd,Tshift);

	vg   = extvar(1);
	vs   = extvar(2);
	vd   = extvar(3);
	vb   = extvar(4);
	T    = max(extvar(5),0);
	
	if isempty(intvar)
	  intvar = zeros(5,1);
	endif
	
	Qgb  = intvar(1);
	Qgs  = intvar(2);
	Qgd  = intvar(3);
	Qsb  = intvar(4);
	Qdb  = intvar(5);
	
	a11 = a21 = a22 = zeros(5,5);
	a12 = [ 1  1  1  0  0; \
	       0 -1  0  1  0; \
	       0  0 -1  0  1; \
	       -1  0  0 -1 -1; \
	       0  0  0  0  0];

	a   = [a11 a12; a21 a22];

	b11 = [0        0                0      0     0; \
	       -gm      (gm+gd)         -gd     0 -didT; \
	       gm      -(gm+gd)          gd     0  didT; \
	       0        0                0      0     0; \
	       dPdvgs  -(dPdvgs+dPdvds)  dPdvds 0  dPdT];

	b12 = zeros(5,5);

	b21 = [Cgb  0        0   -Cgb  0; \
	       Cgs -Cgs      0    0    0; \
	       Cgd  0       -Cgd  0    0; \
	       0    Csb      0   -Csb  0; \
	       0    0        Cdb -Cdb  0];
	b22 = -eye(5);

	b   = [b11 b12; b21 b22];
	
	
	c1 = [0; -ids; ids; 0; P];

	c2 = [Cgb*(vg - vb) - Qgb;\
	      Cgs*(vg - vs) - Qgs;\
	      Cgd*(vg - vd) - Qgd;\
	      Csb*(vs - vb) - Qsb;\
	      Cdb*(vd - vb) - Qdb];
	
	c = [c1;c2];
	

	break;

      case "PMOS"
	
	rd   = 1e6;
	W    = 1;
	L    = 1;
	mu0  = 1e-5;
	Vth  = -.5;
	Cox  = 1e-9;
	Cgb=Cox;
	Cgs=Cgd=Csb=Cdb=.1*Cox;
	Tshift = 0;

	for ii=1:length(parameternames)
	  eval([parameternames{ii} "=",...
		num2str(parameters(ii)) " ;"])	
	endfor

	[gm,gd,ids,didT,P,dPdT,dPdvgs,dPdvds] = \
	    pmos(extvar,mu0,Cox,W,L,Vth,rd,Tshift);

	
	vg   = extvar(1);
	vs   = extvar(2);
	vd   = extvar(3);
	vb   = extvar(4);
	T    = extvar(5);

	if isempty(intvar)
	  intvar = zeros(5,1);
	endif

	Qgb  = intvar(1);
	Qgs  = intvar(2);
	Qgd  = intvar(3);
	Qsb  = intvar(4);
	Qdb  = intvar(5);
	
	a11 = a21 = a22 = zeros(5,5);
	a12 = [ 1  1  1  0  0; \
	       0 -1  0  1  0; \
	       0  0 -1  0  1; \
	       -1  0  0 -1 -1; \
	       0  0  0  0  0];

	a   = [a11 a12; a21 a22];
	
	b11 = [0        0                0      0     0; \
	       -gm      (gm+gd)         -gd     0 -didT; \
	       gm      -(gm+gd)          gd     0  didT; \
	       0        0                0      0     0; \
	       dPdvgs  -(dPdvgs+dPdvds)  dPdvds 0  dPdT];

	b12 = zeros(5,5);

	b21 = [Cgb  0        0   -Cgb  0; \
	       Cgs -Cgs      0    0    0; \
	       Cgd  0       -Cgd  0    0; \
	       0    Csb      0   -Csb  0; \
	       0    0        Cdb -Cdb  0];
	
	b22 = -eye(5);

	b   = [b11 b12; b21 b22];
	
	
	c1 = [0; -ids; ids; 0; P];

	c2 = [Cgb*(vg - vb) - Qgb;\
	      Cgs*(vg - vs) - Qgs;\
	      Cgd*(vg - vd) - Qgd;\
	      Csb*(vs - vb) - Qsb;\
	      Cdb*(vd - vb) - Qdb];
	
	c = [c1;c2];
	
	break;

      otherwise
	error(["unknown option:" string]);
    endswitch
  endif
  
endfunction

function [gm,gd,ids,didT,P,dPdT,dPdvgs,dPdvds] = nmos(extvar,mu0,Cox,W,L,Vth,rd,Tshift)
  ##Computes values for nmos case
  
  vg   = extvar(1);
  vs   = extvar(2);
  vd   = extvar(3);
  vb   = extvar(4);
  T    = max(extvar(5),0);

  k    = mu0*Cox*((T + Tshift)/300)^(-3/2)*W/L;
  dkdT = mu0*Cox*W*(-3/2)*((T + Tshift)/300)^(-5/2)*(1/300)/L;
  
  vgs  = vg-vs;
  vds  = vd-vs;
  
  if (vgs < Vth)
    
    gm  = 0;
    gd  = 1/rd;
    ids = vds*gd;
    didT= 0;
    
  elseif (((vgs-Vth) >= (vds)) && (vds >= 0))
    
    ids = k*((vgs-Vth)*vds-(vds^2)/2)+vds/rd;
    gm  = k*vds;
    gd  = k*(vgs-Vth-vds) + 1/rd;
    didT= dkdT*((vgs-Vth)*vds-(vds^2)/2);
    
  elseif (((vgs-Vth) >= (vds)) && (vds < 0))
    
    gm  = 0;
    gd  = 1/rd;
    ids = vds*gd;
    didT= 0;
    
  else # (i.e. if 0 <= vgs-vth <= vds)
    
    ids = (k/2)*(vgs-Vth)^2+vds/rd;
    gm  = k*(vgs-Vth);
    gd  = 1/rd;
    didT= (dkdT/(2))*(vgs-Vth)^2;
    
  endif
  
  P       = -ids * vds;
  dPdT    = -didT* vds;
  dPdvgs  = -(gm*vds);
  dPdvds  = -(gd*vds + ids);

endfunction

function [gm,gd,ids,didT,P,dPdT,dPdvgs,dPdvds] = pmos(extvar,mu0,Cox,W,L,Vth,rd,Tshift)
  ##Computes values for pmos case

  vg   = extvar(1);
  vs   = extvar(2);
  vd   = extvar(3);
  vb   = extvar(4);
  T    = extvar(5);

  k    = - mu0 * Cox * ((T + Tshift)/300)^(-3/2) *W/L;
  dkdT = - mu0 * Cox * W *(-3/2)*((T + Tshift)/300)^(-5/2)*(1/300)/L;

  vgs  = vg-vs;
  vds  = vd-vs;

  if (vgs > Vth)
    
    gm  = 0;
    gd  = 1/rd;
    ids = vds*gd;
    didT= 0;

  elseif (((vgs-Vth) <= (vds)) && (vds <= 0))
    
    ids = k*((vgs-Vth)*vds-(vds^2)/2)+vds/rd;
    gm  = k*vds;
    gd  = k*(vgs-Vth-vds)+1/rd;
    didT= dkdT*((vgs-Vth)*vds-(vds^2)/2);

  elseif (((vgs-Vth) <= (vds)) && (vds > 0))
    
    gm  = 0;
    gd  = 1/rd;
    ids = vds*gd;
    didT= 0;

  else 

    ids = (k/2)*(vgs-Vth)^2+vds/rd;
    gm  = k*(vgs-Vth);
    gd  = 1/rd;
    didT= (dkdT/(2))*(vgs-Vth)^2;

  endif
  
  P    = -ids * vds;
  dPdT = -didT* vds;
  dPdvgs  = -(gm*vds);
  dPdvds  = -(gd*vds + ids);
  
endfunction