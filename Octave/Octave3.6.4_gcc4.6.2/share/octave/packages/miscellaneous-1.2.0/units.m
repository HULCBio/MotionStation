## Copyright (C) 2005 Carl Osterwisch <osterwischc@asme.org>
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
## @deftypefn {Function File} {} units (@var{fromUnit}, @var{toUnit})
## @deftypefnx {Function File} {} units (@var{fromUnit}, @var{toUnit}, @var{x})
## Return the conversion factor from @var{fromUnit} to @var{toUnit} measurements.
##
## This is an octave interface to the @strong{GNU Units} program which comes
## with an annotated, extendable database defining over two thousand 
## measurement units.  See @code{man units} or 
## @url{http://www.gnu.org/software/units} for more information.
## If the optional argument @var{x} is supplied, return that argument
## multiplied by the conversion factor.  Nonlinear conversions
## such as Fahrenheit to Celsius are not currently supported.  For example, to 
## convert three values from miles per hour into meters per second:
##
## @example
## units ("mile/hr", "m/sec", [30, 55, 75])
## ans =
##
##   13.411  24.587  33.528
## @end example
## @end deftypefn

function y = units(fromUnit, toUnit, x)
    if 2 > nargin || 3 < nargin || !ischar(fromUnit) || !ischar(toUnit)
        print_usage;
    endif

    [status, rawoutput] = system(sprintf('units "%s" "%s"', fromUnit, toUnit), 1);
    (0 == status) || error([rawoutput,
        'Verify that GNU units is installed in the current path.']);
    
    i = index(rawoutput, "*");
    j = index(rawoutput, "\n") - 1;
    i && (i < j) || error('parsing units output "%s"', rawoutput);

    exist("x", "var") || (x = 1);
    eval(['y = x', rawoutput(i:j), ';'])
endfunction

%!demo
%! a.value = 100; a.unit = 'lb';
%! b.value =  50; b.unit = 'oz';
%! c.unit = 'kg';
%! c.value = units(a.unit, c.unit, a.value) + units(b.unit, c.unit, b.value)

%!assert( units("in", "mm"), 25.4 )
