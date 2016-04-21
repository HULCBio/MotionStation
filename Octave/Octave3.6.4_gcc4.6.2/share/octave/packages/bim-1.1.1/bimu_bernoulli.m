## Copyright (C) 2006,2007,2008,2009,2010  Carlo de Falco, Massimiliano Culpo
##
## This file is part of:
##     BIM - Diffusion Advection Reaction PDE Solver
##
##  BIM is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  BIM is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with BIM; If not, see <http://www.gnu.org/licenses/>.
##
##  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>
##  author: Massimiliano Culpo <culpo _AT_ users.sourceforge.net>

## -*- texinfo -*-
##
## @deftypefn {Function File} @
## {[@var{bp}, @var{bn}]} = bimu_bernoulli (@var{x})
##
## Compute the values of the Bernoulli function corresponding to @var{x}
## and - @var{x} arguments. 
## 
## @seealso{bimu_logm}
## @end deftypefn

function [bp,bn] = bimu_bernoulli(x)

  ## Check input
  if nargin != 1
    error("bimu_bernoulli: wrong number of input parameters.");
  endif

  xlim= 1e-2;
  ax  = abs(x);
  bp  = zeros(size(x));
  bn  = bp;
  
  block1  = find(~ax);
  block21 = find((ax>80)&x>0);
  block22 = find((ax>80)&x<0);
  block3  = find((ax<=80)&(ax>xlim));
  block4  = find((ax<=xlim)&(ax~=0));
  
  ##  X=0
  bp(block1)=1.;
  bn(block1)=1.;
  
  ## ASYMPTOTICS
  bp(block21)=0.;
  bn(block21)=x(block21);
  bp(block22)=-x(block22);
  bn(block22)=0.;
  
  ## INTERMEDIATE VALUES
  bp(block3)=x(block3)./(exp(x(block3))-1);
  bn(block3)=x(block3)+bp(block3);
  
  ## SMALL VALUES
  if(any(block4))jj=1;
    fp=1.*ones(size(block4));
    fn=fp;
    df=fp;
    segno=1.;
    while (norm(df,inf) > eps),
      jj=jj+1;
      segno=-segno;
      df=df.*x(block4)/jj;
      fp=fp+df;
      fn=fn+segno*df;
    endwhile;
    bp(block4)=1./fp;
    bn(block4)=1./fn;
  endif
  
endfunction
