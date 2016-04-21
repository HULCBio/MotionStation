## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {}  egolaygen ()
## 
## Returns the Extended Golay code (24,12) generator matrix,
## which can correct upto 3 errors. The second argument is the partiy
## check matrix, for this code.
##
## @end deftypefn
## @seealso{egolaydec,egolayenc}

function [G,P]=egolaygen()
  I=eye(12);
  P=[1 0 0 0 1 1 1 0 1 1 0 1;
     0 0 0 1 1 1 0 1 1 0 1 1;
     0 0 1 1 1 0 1 1 0 1 0 1;
     0 1 1 1 0 1 1 0 1 0 0 1;
     1 1 1 0 1 1 0 1 0 0 0 1;
     1 1 0 1 1 0 1 0 0 0 1 1;
     1 0 1 1 0 1 0 0 0 1 1 1;
     0 1 1 0 1 0 0 0 1 1 1 1;
     1 1 0 1 0 0 0 1 1 1 0 1;
     1 0 1 0 0 0 1 1 1 0 1 1;
     0 1 0 0 0 1 1 1 0 1 1 1;
     1 1 1 1 1 1 1 1 1 1 1 0;];
  G=[P I]; %generator.
end
