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
## @deftypefn {Function File} {} [@var{macheps}, @var{round}, @var{machepsb}, @var{roundb}] = fetestenv ()
## Check some properties of floating point arithmetics: 
## the rounding mode and the machine epsilon, as seen by
## Octave's interpreted code (@var{round} and @var{macheps}, respectively) and, if requested, as seen by BLAS (@var{roundb} and @var{machepsb}, respectively). 
##
## The function performs a variant of the standard 
## @display
## 1 + @var{macheps} ~= 1
## @end display
## test in order to check the actual machine epsilon @var{macheps} 
## and the present rounding mode @var{round} used in all interpreted 
## expressions in Octave.
##
## As Octave interpreted code cannot achieve more than double precision,
## and some BLAS implementations may impose their internal precision and rounding modes,
## the user may request to check the actual rounding and precision used in BLAS calls.
## To this end, we perform a machine epsilon/rounding mode check of the form 
## @display
## [1, @var{machepsb}, -1]*[1; 1; 1] ~= 0.
## @end display
## This Octave code results in a call to a BLAS routine, which in turn may use different floating point arithmetic settings than
## available to Octave. 
## Rounding mode and machine epsilon (both as seen by BLAS) are returned 
## in @var{roundb} and @var{machepsb}, respectively.
##
## See the manual pages of @command{fesetprec} for more details and subtleties.
##
## Note that the results of this test may or may not apply to library functions called by Octave. The simplest way to verify if the function you use in Octave is affected by the change of the rounding mode or the precision, is to run your function on the same data with different settings. Small differences between various modes indicate these modes do affect the behaviour of your function. No differences mean they probably do not apply. Big differences most likely indicate either an instability of your function or ill conditioning of your problem.
##
##
## @seealso{fesetround, fesetprec, system_dependent, eps, fe_system_dependent}
## @end deftypefn

## Author: Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
##

## Revision history: 
##
##	2008-10-10, Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
##		Initial release
##

function [macheps, round, machepsb, roundb] = fetestenv()
if (nargin != 0)
	warning ("Ignoring extra arguments");
end

# first run the standard "1 + eps == 1" test, modified to accommodate 
# various rounding modes
x 	= [  1,  1, -1, -1];
xeps 	= [  1, -1,  1, -1];
do 
	xeps = xeps ./ 2;
	stop = [(x + xeps > x)([1,3]), (x + xeps < x)([2,4])];
until ( ~prod(stop) )

# machine eps is thus a twice as big number
macheps = xeps(1)*2;

# use an even smaller number to reveal rounding direction
xeps = xeps ./ 2;
stop = [(x + xeps > x)([1,3]), (x + xeps < x)([2,4])];

round = sense_round(stop);

if(nargout != 2)
# Check macheps and rounding as in BLAS' routine
# (Inspired by some discussion on the Octave's mailing list)

	x 	= [  1,  1, -1, -1];
	xeps 	= [  1, -1,  1, -1];
	do 
		xeps = xeps ./ 2;
		stop = [([1,1,1]*[x; xeps; -x]>0)([1,3]), ...
			([1,1,1]*[x; xeps; -x]<0)([2,4])];
	until ( ~prod(stop) )

	# machine eps is thus a twice as big number
	machepsb = xeps(1)*2;

	# use an even smaller number to reveal rounding direction
	xeps = xeps ./ 2;
	stop = [([1,1,1]*[x; xeps; -x]>0)([1,3]), ...
		([1,1,1]*[x; xeps; -x]<0)([2,4])];

	roundb = sense_round(stop);
end

if(nargout == 0)
	printf('Interpreter:\n');
	printf('\tMachine epsilon: %g\n', macheps);	
	printf('\tRounding mode:   %g\n', round);	
	printf('BLAS:\n');
	printf('\tMachine epsilon: %g\n', machepsb);	
	printf('\tRounding mode:   %g\n', roundb);	
end

endfunction

function rnd = sense_round(stop)
# tries to sniff the rounding mode from the sign checks 
# of the "1+meps-1" type expressions provided in 'stop' argument
switch stop
case [0, 0, 0, 0]
	# all additions/subtractions collapsed to +1 or -1; we are in the
	# round-to-nearest mode
	rnd = 0.5;
case [1, 1, 0, 0]
	# round-up mode
	rnd = +Inf;
case [0, 0, 1, 1]
	# round-down mode
	rnd = -Inf;
case [0, 1, 1, 0]
	# round-to-zero mode
	rnd = 0;
otherwise
	# am I dreaming?
	rnd = NaN;
	error('Unknown rounding mode detected.');
end
endfunction
%!demo
%!  fesetround(+Inf); fesetprec(1);
%!  fetestenv();
%!  fesetround(0.5); fesetprec(3);
%!demo
%!  fesetround(0); fesetprec(3);
%!  fetestenv();
%!  fesetround(0.5); fesetprec(3);
%!test 
%!  if( fesetround(+Inf) == 0) 
%!    [eps, round] = fetestenv();
%!    assert(round, Inf);
%!    fesetround(0.5);
%!  endif
%!test 
%!  if( fesetround(0) == 0) 
%!    [eps, round] = fetestenv();
%!    assert(round, 0);
%!    fesetround(0.5);
%!  endif
