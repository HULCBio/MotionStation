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
## @deftypefn{Function File} {} utl_plot_by_name(@var{t},@var{out}, @
## @var{outstruct},@var{namelist})
##
## Select by name some elements of the state vector of the system described
## by @var{outstruct} and plot their dynamics over the time interval
## @var{t}.  
##
## @var{namelist} should contain the list of names of the variables
## to plot.
## @var{out} should be the output of a transient simulation over the
## time interval @var{t}
##
## @seealso{tst_backward_euler,tst_daspk,tst_theta_method,tst_odepkg,prs_iff}
##
## @end deftypefn

function utl_plot_by_name (t, out, outstruct, namelist)
  
  if (nargin != 4)
    error ("utl_plot_by_name: wrong number of input parameters.")
  endif

  nn  = length (outstruct.namesn);
  leg = {}; ileg = 0;
  for ip = 1:nn
    for in = 1:length (namelist)
      if (strcmp (namelist{in},outstruct.namess{ip}))
	plot (t, out(outstruct.namesn(ip), :), sprintf("%d", mod (in+1, 6) + 1));
        leg{++ileg} = outstruct.namess{ip};
	hold on
      endif
    endfor
  endfor
  legend (leg{:});

  hold off

endfunction