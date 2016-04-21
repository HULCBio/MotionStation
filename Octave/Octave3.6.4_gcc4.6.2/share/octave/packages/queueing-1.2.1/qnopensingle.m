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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopensingle (@var{lambda}, @var{S}, @var{V}) 
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopensingle (@var{lambda}, @var{S}, @var{V}, @var{m})
##
## This function is deprecated. Please use @code{qnos} instead.
##
## @seealso{qnos}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qnopensingle( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "qnopensingle is deprecated. Please use qnos instead");
  endif
  [U R Q X] = qnos( varargin{:} );
endfunction
