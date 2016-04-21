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
## @deftypefn{Function File} {[@var{A},@var{B},@var{C}] =}@
## asm_initialize_system(@var{instruct},@var{x})
##
## Cycle through the circuit description structure @var{instruct} 
## to build the system matrices @var{A}, @var{B}, @var{C} for
## the linear and time-invariant part of the system.
##
## @var{x} is the current value of the state variables.
##
## See the @cite{IFF file format specifications} for details about 
## the output matrices.
## 
## @seealso{asm_build_system,prs_iff}
##
## @end deftypefn

function  [A,B,C] = asm_initialize_system(instruct,x);

  ## Check input
  if nargin != 2
    error("asm_initialize_system: wrong number of input parameters.");
  elseif !(isstruct(instruct) && isfield(instruct,"LCR") && 
	   isfield(instruct,"NLC"))
    error("asm_initialize_system: first input is not a valid structure.");
  elseif !isvector(x)
    error("asm_initialize_system: second input is not a valid vector.");
  endif

  ## Build linear part of the system
  n  = instruct.totextvar + instruct.totintvar; # Number of variables

  ## Initialize to zero any state variable that is not in the input argument
  lx = length(x);
  if lx < n
    x(lx+1:n) = 0;
  endif
  ## FIXME: should a warning be passed if lx != n ?

  A = sparse(n,n);
  
  ## LCR section
  B = sparse(n,n);
  C = sparse(n,1);

  nblocks = length(instruct.LCR);

  for ibl = 1:nblocks
    for iel = 1:instruct.LCR(ibl).nrows
      
      ## Evaluate element
      if instruct.LCR(ibl).nintvar(iel)
	intvars = instruct.totextvar + instruct.LCR(ibl).osintvar(iel) + [1:instruct.LCR(ibl).nintvar(iel)]';
      else
	intvars=[];
      endif

      il   = instruct.LCR(ibl).vnmatrix(iel,:)';
      nzil = find(il!=0);
      
      y       = zeros(size(il));
      y(nzil) = x(il(nzil));
      z       = x(intvars);
      
      [a,b,c] = feval(instruct.LCR(ibl).func,
		      instruct.LCR(ibl).section,
		      instruct.LCR(ibl).pvmatrix(iel,:),
		      instruct.LCR(ibl).parnames,
		      y,z,0);
      
      ## Assemble matrices
      
      ## Global indexing
      vars = [il(nzil);intvars];

      ## Local indexing
      lclvars = [nzil; instruct.LCR(ibl).nextvar + (1:length(intvars))' ];

      ## Reshaping sparse stamps
      a = a(lclvars,lclvars);
      b = b(lclvars,lclvars);
      c = reshape(c(lclvars),[],1);
      
      [na,ma,va] = find(a);
      [nb,mb,vb] = find(b);
      [nc,mc,vc] = find(c);

      ## Stamping
      A += sparse(vars(na),vars(ma),va,n,n);
      B += sparse(vars(nb),vars(mb),vb,n,n);
      C += sparse(vars(nc),1,vc,n,1);
      
    endfor
  endfor

endfunction