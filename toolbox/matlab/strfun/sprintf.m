function [varargout] = sprintf(varargin)
%SPRINTF Write formatted data to string.
%   [S,ERRMSG] = SPRINTF(FORMAT,A,...) formats the data in the real
%   part of array A (and in any additional array arguments), under
%   control of the specified FORMAT string, and returns it in the
%   MATLAB string variable S. ERRMSG is an optional output argument
%   that returns an error message string if an error occurred or an
%   empty array if an error did not occur. SPRINTF is the same as
%   FPRINTF except that it returns the data in a MATLAB string
%   variable rather than writing it to a file.
%
%   FORMAT is a string containing C language conversion specifications.
%   Conversion specifications involve the character %, optional flags,
%   optional width and precision fields, optional subtype specifier, and
%   conversion characters d, i, o, u, x, X, f, e, E, g, G, c, and s.
%   See the Language Reference Guide or a C manual for complete details.
%
%   The special formats \n,\r,\t,\b,\f can be used to produce linefeed,
%   carriage return, tab, backspace, and formfeed characters respectively.
%   Use \\ to produce a backslash character and %% to produce the percent
%   character.
%
%   SPRINTF behaves like ANSI C with certain exceptions and extensions.
%   These include:
%   1. ANSI C requires an integer cast of a double argument to correctly
%      use an integer conversion specifier like d. A similar conversion
%      is required when using such a specifier with non-integral MATLAB
%      values. Use FIX, FLOOR, CEIL or ROUND on a double argument to
%      explicitly convert non-integral MATLAB values to integral values
%      if you plan to use an integer conversion specifier like d.
%      Otherwise, any non-integral MATLAB values will be outputted using
%      the format where the integer conversion specifier letter has been
%      replaced by e.
%   2. The following non-standard subtype specifiers are supported for
%      conversion characters o, u, x, and X.
%      t    - The underlying C datatype is a float rather than an
%             unsigned integer.
%      b    - The underlying C datatype is a double rather than an
%             unsigned integer.
%      For example, to print out in hex a double value use a format like
%      '%bx'.
%   3. SPRINTF is "vectorized" for the case when A is nonscalar. The
%      format string is recycled through the elements of A (columnwise)
%      until all the elements are used up. It is then recycled in a similar
%      manner through any additional array arguments.
%
%   See the reference page in the online help for other exceptions, 
%   extensions, or platform-specific behavior.
%
%   Examples
%      sprintf('%0.5g',(1+sqrt(5))/2)       1.618
%      sprintf('%0.5g',1/eps)               4.5036e+15       
%      sprintf('%15.5f',1/eps)              4503599627370496.00000
%      sprintf('%d',round(pi))              3
%      sprintf('%s','hello')                hello
%      sprintf('The array is %dx%d.',2,3)   The array is 2x3.
%      sprintf('\n') is the line termination character on all platforms.
%
%   See also FPRINTF, SSCANF, NUM2STR, INT2STR.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.12.4.3 $  $Date: 2004/04/10 23:32:48 $
%   Built-in function.

if nargout == 0
  builtin('sprintf', varargin{:});
else
  [varargout{1:nargout}] = builtin('sprintf', varargin{:});
end
