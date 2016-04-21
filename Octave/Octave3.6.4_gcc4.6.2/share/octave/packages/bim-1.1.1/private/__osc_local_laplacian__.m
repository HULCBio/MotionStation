## Copyright (C) 2012  Carlo de Falco
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

## -*- texinfo -*-
##
## @deftypefn {Function File} @
## {@var{Lloc}} = __osc_local_laplacian__ @
## (@var{p}, @var{t}, @var{shg}, @var{epsilon}, @var{area}, @var{nnodes}, @var{nelem})
##
## Unocumented private function.
##
## @end deftypefn

function   Lloc = __osc_local_laplacian__ (p, t, shg, epsilon, area, nnodes, nelem)

  Lloc = zeros (4, 4, nelem);

  epsilonbyareak = epsilon(:) ./  area(:) / 48;
  A = zeros (3, 4, nelem);

  ## Computation
  for inode = 1:4
    A(:, inode, :) = 3 * area .* squeeze (shg(:, inode, :));
  endfor
  Ann = squeeze (sum (A .^ 2, 1));

  r12 = p(:, t (2, :)) - p(:, t (1, :));
  r13 = p(:, t (3, :)) - p(:, t (1, :));
  r14 = p(:, t (4, :)) - p(:, t (1, :));
  r23 = p(:, t (3, :)) - p(:, t (2, :));
  r24 = p(:, t (4, :)) - p(:, t (2, :));
  r34 = p(:, t (4, :)) - p(:, t (3, :));
  
  s12 = - epsilonbyareak .* (2 * (dot ( r13,  r23,  1) .* 
                                  dot ( r14,  r24,  1))(:) + 
                             squeeze (dot (A(:, 3, :), A(:, 4, :), 1)) .* 
                             (dot ( r13,  r23,  1) .^ 2 ./ Ann(4, :) + 
                              dot ( r14,  r24,  1).^ 2 ./ Ann(3, :))(:));

  s13 = - epsilonbyareak .* (2 * (dot ( r12, -r23,  1) .* 
                                  dot ( r14,  r34,  1))(:) + 
                             squeeze (dot (A(:, 2, :), A(:, 4, :), 1)) .* 
                             (dot ( r12, -r23, 1) .^ 2  ./ Ann(4, :) + 
                              dot ( r14,  r34,  1).^ 2 ./ Ann(2, :))(:));

  s14 = - epsilonbyareak .* (2 * (dot ( r12, -r24,  1) .* 
                                  dot ( r13, -r34,  1))(:) + 
                             squeeze (dot (A(:, 2, :), A(:, 3, :), 1)) .* 
                             (dot ( r12, -r24, 1) .^ 2  ./ Ann(3, :) + 
                              dot ( r13, -r34,  1).^ 2 ./ Ann(2, :))(:));

  s23 = - epsilonbyareak .* (2 * (dot (-r12, -r13,  1) .* 
                                  dot ( r24,  r34,  1))(:) + 
                             squeeze (dot (A(:, 1, :), A(:, 4, :), 1)) .* 
                             (dot (-r12, -r13, 1) .^ 2  ./ Ann(4, :) + 
                              dot ( r24,  r34,  1).^ 2 ./ Ann(1, :))(:));

  s24 = - epsilonbyareak .* (2 * (dot (-r12, -r14,  1) .* 
                                  dot ( r23, -r34,  1))(:) + 
                             squeeze (dot (A(:, 1, :), A(:, 3, :), 1)) .* 
                             (dot (-r12, -r14, 1) .^ 2  ./ Ann(3, :) + 
                              dot ( r23, -r34,  1).^ 2 ./ Ann(1, :))(:));

  s34 = - epsilonbyareak .* (2 * (dot (-r13, -r14,  1) .* 
                                  dot (-r23, -r24,  1))(:) + 
                             squeeze (dot (A(:, 1, :), A(:, 2, :), 1)) .*
                             (dot (-r13, -r14, 1) .^ 2  ./ Ann(2, :) + 
                              dot (-r23, -r24,  1).^ 2 ./ Ann(1, :))(:));
  
  Lloc(1, 2, :) = s12;  Lloc(2, 1, :) = s12;
  Lloc(1, 3, :) = s13;  Lloc(3, 1, :) = s13;
  Lloc(1, 4, :) = s14;  Lloc(4, 1, :) = s14;
  Lloc(1, 1, :) = -(s12+s13+s14);

  Lloc(2, 3, :) = s23;  Lloc(3, 2, :) = s23;
  Lloc(2, 4, :) = s24;  Lloc(4, 2, :) = s24;
  Lloc(2, 2, :) = -(s12+s23+s24);

  Lloc(3, 4, :) = s34;  Lloc(4, 3, :) = s34;
  Lloc(3, 3, :) = -(s13+s23+s34);

  Lloc(4, 4, :) = -(s14+s24+s34);

endfunction