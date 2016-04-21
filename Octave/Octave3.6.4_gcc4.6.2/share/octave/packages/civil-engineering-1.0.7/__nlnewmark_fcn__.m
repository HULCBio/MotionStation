## Copyright (C) 2000 Matthew W. Roberts.  All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2, or (at your option) any
## later version.
##
## This software is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##
## You should have received a copy of the GNU General Public License
## along with this software; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{y} =} __nlnewmark_fcn__(@var{x})
##
## Non-linear function used with fsolve for nlnewmark.m
## @end deftypefn

## Author:  Matthew W. Roberts
## Created: May, 2000

function  y = __nlnewmark_fcn__(x)

global nlnewmark_status;

# nlnewmark_status.a1 = dt^2*beta;
y(1) = -x(1) + nlnewmark_status.a1 * x(3) + nlnewmark_status.rhs(1);
# nlnewmark_status.a2 = dt*alpha;
y(2) = -x(2) + nlnewmark_status.a2 * x(3) + nlnewmark_status.rhs(2);
y(3) = feval( nlnewmark_status.Q, [x(1), x(2), x(3)]) + nlnewmark_status.C * x(2) + nlnewmark_status.M * x(3) - nlnewmark_status.rhs(3);

endfunction

