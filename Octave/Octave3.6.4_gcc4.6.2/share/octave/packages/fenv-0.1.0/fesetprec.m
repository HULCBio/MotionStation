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
## @deftypefn {Function File} {} fesetprec (@var{mode})
## Change the precision of the floating point arithmetics. At present, @code{fesetprec} may work @strong{only} on systems with x86 or x86_64 processors. 
##
## Possible values of @var{mode} are 
## @table @samp
## @item 1 
## @itemx 24
## Sets the x87 FPU precision mode to single precision (24-bit significand)
## @item 2 
## @itemx 53
## Sets the x87 FPU precision mode to double precision (53-bit significand)
## @item 3 
## @itemx 64
## Sets the x87 FPU precision mode to double extended precision (64-bit significand)
## @end table
## 
## When successful, @code{fesetprec} returns 0. It is always recommended to verify the result experimentally by calling the function @code{fetestenv}, which tests the rounding mode and the precision of the floating point arithmetics. 
##
## Modern processors, including x86 and x86_64 architectures, support changing certain properties of their floating point arithmetics. Here, we focus @strong{exclusively} on x86 and x86_64.
## These processors presently feature two types of floating point processing units: the older x87 FPU and the newer SSE unit. Only x87 FPU allows changing the precision, so @code{fesetprec} applies only to those instructions which are executed by x87 FPU. @code{fesetprec} changes the precision of the four basic arithmetic operations and of the square root on x87 FPU. 
## 
## Since floating point operations on x86 or x86_64 may be executed either by x87 FPU or SSE units, @code{fesetprec} may affect all, some, or no Octave's operations. The rule of the thumb, however, is that 64-bit systems usually do their floating point on SSE by default, when 32-bit systems use x87 FPU. You can always check how your system reacts to changes made by @code{fesetprec} by verifying them with @code{fetestenv}.
## 
## It is important to know that all expressions and their intermediate results processed by Octave's interpreter are cast to temporary @code{double} variables and thus it is impossible to execute an interpreted expression in double extended precision. On the other hand, those libraries called by Octave which rely on x87 FPU will usually perform the computations using x87 FPU 80-bit registers, i.e. in double extended precision. This may lead to some subtle differences in how the precision mode affects the computations. Let's take a look at the simplest example:
## 
## @example
## macheps = builtin('eps');
## fesetprec(3);
## x = [1, macheps/2, -1]*[1;1;1];
## y = 1 + macheps/2 - 1;
## @end example 
## 
## The built-in function @code{eps} returns the machine epsilon in @emph{double precision}. Mathematically the expressions for @code{x} and @code{y} are equivalent, but in reality they may be not. The expression for @code{x} will call a BLAS subroutine and on a 32-bit system it will most likely be executed on x87 FPU using 64-bit double extended precision - so @code{x} will be greater than zero. On the other hand, the expression for @code{y} will be executed through the interpreter and these calculations will store all intermediate results in double precision, so that @code{y} will be equal to zero. In contrast to 32-bit systems, many 64-bit systems will do all floating point on SSE - and thus both @code{x} and @code{y} will then be equal to zero.
##
## It is also known that some numerical libraries set their own precision modes or execute floating point operations on different units (say, they may use only the SSE unit when Octave uses exclusively the x87 FPU...). Therefore calls to such numerical libraries may also cancel changes made previously by @code{fesetprec}:
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
## Changes issued by @code{fesetprec} @strong{are} reflected by Octave's function @code{eps}: calling @code{fesetprec} replaces the built-in function @code{eps} with a dispatch @code{fetestenv}. In order to perform a more detailed check of actual parameters of the floating point arithmetics, use @code{fetestenv} directly.
## 
## A possible application of @code{fesetprec}, following the idea by W. Kahan, is an experimental (in)stability analysis. Running some code with various settings of the floating point arithmetics may reveal some instability of the numerical algorithm being used in the code or reveal possible ill conditioning of the very problem being solved.
## 
## Literature
## 
## @enumerate 
## @item W. Kahan, "How Futile are Mindless Assessments of Roundoff in Floating-Point Computation?", available on the Web: @indicateurl{http://www.cs.berkeley.edu/~wkahan/Mindless.pdf}.
## @item W. Kahan, "Why I can Debug some Numerical Programs You can't", available on the Web: @indicateurl{http://www.cs.berkeley.edu/~wkahan/Stnfrd50.pdf}.
## @item Intel 64 and IA-32 Architectures Software Developer's Manual, Volume 1: Basic Architecture, May 2007.
## @end enumerate
## @seealso{fetestenv, fesetround, system_dependent, eps, fe_system_dependent}
## @end deftypefn

## Author: Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
##

## Revision history: 
##
##	2008-10-10, Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
##		Initial release
##

function err = fesetprec(mode)
if (nargin ~= 1)
	print_usage();
end

systemtype = computer();

# Presently, we support either x86_64...
supported = ~isempty(findstr('x86_64', systemtype));

# ...or x86
# 	(Actually we only support i486 and above, 
# 	but in many cases the default compiler settings are for i386.
# 	We also do believe i286 and older are dead or at the museum.)
supported |= strcmp("i86", systemtype([1,3,4]));

err = -2;
if (supported && exist('system_dependent'))
	switch mode
	case {1, 24}
		err = fe_system_dependent('precision','single');
	case {2, 53}
		err = fe_system_dependent('precision','double');
	case {3, 64}
		err = fe_system_dependent('precision','double ext');
	otherwise
		warning('Cannot set the precision mode to %g', mode);
		usage('fesetprec (MODE), with MODE in {1, 2, 3}');
	end
	if (err == 0)
		% replace original eps function with fetestenv
		dispatch('eps', 'any'); % restore the built-in version
		dispatch('eps', 'fetestenv', 'any'); % obscure by fetestenv
	else 
		warning('Problems setting precision mode %g.', mode);
		warning('Use fetestenv() to verify.');
	end
else
	warning('This system is not supported by fesetprec');
end
end
%!demo
%!  fesetprec(1);
%!  fetestenv();
%!  fesetprec(3);
%!  fetestenv();
