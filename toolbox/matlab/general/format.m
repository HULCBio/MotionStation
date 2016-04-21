function [varargout] = format(varargin)
%FORMAT Set output format.
%   FORMAT with no inputs sets the ouput format to the default appropriate
%   for the class of the variable. For float variables, the default is
%   FORMAT SHORT.
%
%   FORMAT does not affect how MATLAB computations are done. Computations
%   on float variables, namely single or double, are done in appropriate
%   floating point precision, no matter how those variables are displayed. 
%   Computations on integer variables are done natively in integer. Integer
%   variables are always displayed to the appropriate number of digits for
%   the class, for example, 3 digits to display the INT8 range -128:127.
%   FORMAT SHORT and LONG do not affect the display of integer variables.
%
%   FORMAT may be used to switch between different output display formats
%   of all float variables as follows:
%     FORMAT SHORT   Scaled fixed point format with 5 digits.
%     FORMAT LONG    Scaled fixed point format with 15 digits for double
%                    and 7 digits for single.
%     FORMAT SHORT E Floating point format with 5 digits.
%     FORMAT LONG E  Floating point format with 15 digits for double and
%                    7 digits for single.
%     FORMAT SHORT G Best of fixed or floating point format with 5 digits.
%     FORMAT LONG G  Best of fixed or floating point format with 15 digits
%                    for double and 7 digits for single.
%
%   FORMAT may be used to switch between different output display formats
%   of all numeric variables as follows:
%     FORMAT HEX     Hexadecimal format.
%     FORMAT +       The symbols +, - and blank are printed 
%                    for positive, negative and zero elements.
%                    Imaginary parts are ignored.
%     FORMAT BANK    Fixed format for dollars and cents.
%     FORMAT RAT     Approximation by ratio of small integers.
%
%   FORMAT may be used to affect the spacing in the display of all
%   variables as follows:
%     FORMAT COMPACT Suppresses extra line-feeds.
%     FORMAT LOOSE   Puts the extra line-feeds back in.
%
%   Example:
%      format short, pi, single(pi)
%   displays both double and single pi with 5 digits as 3.1416 while
%      format long, pi, single(pi)
%   displays pi as 3.14159265358979 and single(pi) as 3.1415927.
%
%      format, intmax('uint64'), realmax
%   shows these values as 18446744073709551615 and 1.7977e+308 while
%      format hex, intmax('uint64'), realmax
%   shows them as ffffffffffffffff and 7fefffffffffffff respectively.
%   The HEX display corresponds to the internal representation of the value
%   and is not the same as the hexadecimal notation in the C programming
%   language.
%
%   See also DISP, DISPLAY, ISNUMERIC, ISFLOAT, ISINTEGER.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.10.4.4 $  $Date: 2004/03/17 20:05:13 $
%   Built-in function.

if nargout == 0
  builtin('format', varargin{:});
else
  [varargout{1:nargout}] = builtin('format', varargin{:});
end
