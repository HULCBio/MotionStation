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
## @deftypefn{Function File} {[@var{A},@var{Jac},@var{res}] =}@
## asm_build_system(@var{instruct},@var{x},@var{t})
##
## Cycle through the circuit description structure @var{instruct}
## to build the system matrices @var{A}, @var{Jac}, @var{res} for
## the current step of the Newton method.
##
## @var{x} is the current value of the state variables, while @var{t} is the current time point.
##
## See the @cite{IFF file format specifications} for details about 
## the output matrices.
## 
## @seealso{asm_initialize_system,prs_iff}
##
## @end deftypefn

function  [A,Jac,res] = asm_build_system(instruct,x,t);

  ## Check input
  if nargin != 3
    error("asm_build_system: wrong number of input parameters.");
  elseif !(isstruct(instruct) && isfield(instruct,"LCR") && 
	   isfield(instruct,"NLC"))
    error("asm_build_system: first input is not a valid structure.");
  elseif !isvector(x)
    error("asm_build_system: second input is not a valid vector.");
  elseif !isscalar(t)
    error("asm_build_system: third input is not a valid scalar.");
  endif

  n   = instruct.totextvar + instruct.totintvar;
  A   = sparse(n,n);
  Jac = sparse(n,n);
  res = sparse(n,1);
  
  
  ## NLC section
  nblocks = length(instruct.NLC);

  for ibl = 1:nblocks
    for iel = 1:instruct.NLC(ibl).nrows
      
      ## Evaluate element
      if instruct.NLC(ibl).nintvar(iel)    
	intvars = instruct.totextvar+instruct.NLC(ibl).osintvar(iel) + \
	    [1:instruct.NLC(ibl).nintvar(iel)]';
      else
	intvars=[];
      endif
    
      il   = instruct.NLC(ibl).vnmatrix(iel,:)';
      nzil = find(il!=0);
      
      y       = zeros(size(il));
      y(nzil) = x(il(nzil));
      
      z = x(intvars);

      [a,b,c] = feval(instruct.NLC(ibl).func,\
		      instruct.NLC(ibl).section,\
		      instruct.NLC(ibl).pvmatrix(iel,:),\
		      instruct.NLC(ibl).parnames,\
		      y,z,t);

      ## Assemble matrices
      
      ## Global indexing
      vars = [il(nzil);intvars];

      ## Local indexing
      lclvars = [nzil; instruct.NLC(ibl).nextvar + (1:length(intvars))' ];

      ## Reshaping sparse stamps
      a = a(lclvars,lclvars);
      b = b(lclvars,lclvars);
      c = reshape(c(lclvars),[],1);
      
      [na,ma,va] = find(a);
      [nb,mb,vb] = find(b);
      [nc,mc,vc] = find(c);

      ## Stamping
      A   += sparse(vars(na),vars(ma),va,n,n);
      Jac += sparse(vars(nb),vars(mb),vb,n,n);
      res += sparse(vars(nc),1,vc,n,1);
     
    endfor	
  endfor
  
endfunction