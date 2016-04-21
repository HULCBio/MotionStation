## Copyright (C) 2008 Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.
##

## -*- texinfo -*-
## @deftypefn {Function File} {} fesetround (@var{mode})
## Change the rounding mode of the floating point arithmetics. 
## 
## Following the IEEE-754 standard recommendation, modern processors, including x86 and x86_64 architectures, support changing the rounding direction of the floating point arithmetics. 
## 
## Possible values of @var{mode} are 
## @table @samp
## @item 0
## Sets the rounding mode to @samp{towards zero}, i.e. @samp{truncate}
## @item 0.5
## Sets the rounding mode to @samp{nearest} (the standard mode)
## @item Inf
## Sets the rounding mode to @samp{up}, i.e. @samp{towards +infinity}
## @item -Inf
## Sets the rounding mode to @samp{down}, i.e. @samp{towards -infinity}
## @end table
## 
## When successful, @code{fesetround} returns 0. It is always recommended to verify the result experimentally by calling the function @code{fetestenv}, which tests the rounding mode and the precision of the floating point arithmetics. 
##
## It is known that some numerical libraries may set their own rounding modes. Therefore @code{fesetround} may affect operations performed by numerical libraries called by Octave in a different way than it does the interpreted code. Calls to such numerical libraries may also cancel changes previously made by @code{fesetround}:
##
## @example
## fesetprec(1); fesetround(0); fetestenv
## @print{} Machine epsilon: 1.19209e-07
## @print{} Rounding mode:   0
## hilb(2)\ones(2,1); fetestenv
## @print{} Machine epsilon: 2.22045e-16
## @print{} Rounding mode:   0.5
## @end example
##
## (the above test has been run on an x86 32-bit system using Octave 3.0.2 package provided along with the Fedora 9 Linux distribution).
##
## A possible application of this function, following the idea by W. Kahan, is an experimental (in)stability analysis. Running some code with various settings of the floating point arithmetics may reveal some instability of the numerical algorithm being used in the code or reveal possible ill conditioning of the very problem being solved.
##
## Literature
## 
## @enumerate 
## @item W. Kahan, "How Futile are Mindless Assessments of Roundoff in Floating-Point Computation?", available on the Web: @indicateurl{http://www.cs.berkeley.edu/~wkahan/Mindless.pdf}.
## @item W. Kahan, "Why I can Debug some Numerical Programs You can't", available on the Web: @indicateurl{http://www.cs.berkeley.edu/~wkahan/Stnfrd50.pdf}.
## @item Intel 64 and IA-32 Architectures Software Developer's Manual, Volume 1: Basic Architecture, May 2007.
## @end enumerate
## @seealso{fetestenv, fesetprec, system_dependent, fe_system_dependent}
## @end deftypefn

## Author: Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
##

## Revision history: 
##
##	2008-10-10, Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
##		Initial release
##

function err = fesetround(mode)
if (nargin ~= 1)
	print_usage();
end
err = -1;
supported = 1;
if supported && exist('system_dependent')
	switch mode
	case 0
		err = fe_system_dependent('rounding','zero');
	case 0.5
		err = fe_system_dependent('rounding','normal');
	case Inf
		err = fe_system_dependent('rounding','up');
	case -Inf
		err = fe_system_dependent('rounding','down');
	otherwise
		warning('Cannot set the rounding mode to %g', mode);
		usage('fesetround (MODE), with MODE in {0, 0.5, Inf, -Inf}');

	end
	if (err ~=0) 
		warning('Problems setting rounding mode %g.', mode);
		warning('Use fetestenv() to verify.');
	end
else
	warning('This system is not supported by fesetround');
end
end
%!demo
%!  fesetround(+Inf);
%!  test = (1 + realmin > 1)
%!  fesetround(0.5);
%!demo
%!  fesetround(0.5);
%!  test = (1 + realmin > 1)
%!  fesetround(0.5);
%!test 
%!  fesetround(+Inf);
%!  assert(1 + realmin > 1, true);
%!  fesetround(0.5);
%!test 
%!  fesetround(0.5);
%!  assert(1 + realmin > 1, false); 
%!test 
%!  fesetround(0);
%!  assert(1 + realmin > 1, false); 
%!  assert(-1 + realmin > -1, true); 
%!  fesetround(0.5);
