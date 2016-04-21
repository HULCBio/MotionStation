## Copyright (C) 2009 Dmitry Kolesnikov
## Copyright (C) 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## The queueing toolbox is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the queueing toolbox. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{p0}] =} qnmg1 (@var{lambda}, @var{xavg}, @var{x2nd})
##
## This function is deprecated. Please use @code{qsmg1} instead.
##
## @seealso{qsmg1}
##
## @end deftypefn

## Author: Dmitry Kolesnikov

function [U R Q X p0] = qnmg1( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "qnmg1 is deprecated. Please use qsmg1 instead");
  endif
  [U R Q X p0] = qsmg1( varargin{:} );
endfunction
