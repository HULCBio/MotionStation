function [varargout] = sscanf(varargin)
%SSCANF Read string under format control.
%   [A,COUNT,ERRMSG,NEXTINDEX] = SSCANF(S,FORMAT,SIZE) reads data from
%   MATLAB string variable S, converts it according to the specified
%   FORMAT string, and returns it in matrix A. COUNT is an optional output
%   argument that returns the number of elements successfully read.
%   ERRMSG is an optional output argument that returns an error message
%   string if an error occurred or an empty matrix if an error did not
%   occur. NEXTINDEX is an optional output argument specifying one more
%   than the number of characters scanned in S.
%
%   SSCANF is the same as FSCANF except that it reads the data from
%   a MATLAB string variable rather than reading it from a file.
%   
%   SIZE is optional; it puts a limit on the number of elements that
%   can be scanned from the string; if not specified, the entire string
%   is considered; if specified, valid entries are: 
%
%       N      read at most N elements into a column vector.
%       inf    read at most to the end of the string.
%       [M,N]  read at most M * N elements filling at least an
%              M-by-N matrix, in column order. N can be inf, but not M.
%
%   If the matrix A results from using character conversions only and
%   SIZE is not of the form [M,N] then a row vector is returned.
%
%   FORMAT is a string containing C language conversion specifications.
%   Conversion specifications involve the character %, optional
%   assignment-suppressing asterisk and width field, and conversion
%   characters d, i, o, u, x, e, f, g, s, c, and [. . .] (scanset).
%   Complete ANSI C support for these conversion characters is
%   provided consistent with 'expected' MATLAB behavior. For a complete
%   conversion character specification, see a C manual.
%
%   If a conversion character s is used, an element read may cause
%   several MATLAB matrix elements to be used, each holding one
%   character.
%
%   Mixing character and numeric conversion specifications will cause
%   the resulting matrix to be numeric and any characters read to show
%   up as their ASCII values one character per MATLAB matrix element.
%
%   Scanning to end-of-string occurs when NEXTINDEX is greater than the
%   size of S.
%
%   SSCANF differs from its C language namesake in an important respect -
%   it is "vectorized" in order to return a matrix argument. The format
%   string is recycled through the string until its end is reached
%   or the amount of data specified by SIZE is converted in.
%
%   For example, the statements
%
%       S = '2.7183  3.1416';
%       A = sscanf(S,'%f')
%
%   create a two element vector containing approximations to e and pi.
%
%   See also FSCANF, SPRINTF, STRREAD, FREAD.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.9.4.3 $  $Date: 2004/04/10 23:32:49 $
%   Built-in function.

if nargout == 0
  builtin('sscanf', varargin{:});
else
  [varargout{1:nargout}] = builtin('sscanf', varargin{:});
end
