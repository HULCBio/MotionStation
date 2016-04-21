function [varargout] = fprintf(varargin)
%FPRINTF Write formatted data to file.
%   COUNT = FPRINTF(FID,FORMAT,A,...) formats the data in the real
%   part of array A (and in any additional array arguments), under
%   control of the specified FORMAT string, and writes it to the file
%   associated with file identifier FID.  COUNT is the number of bytes
%   successfully written. FID is an integer file identifier obtained
%   from FOPEN. It can also be 1 for standard output (the screen) or 2
%   for standard error. If FID is omitted, output goes to the screen.
%   
%   FORMAT is a string containing C language conversion specifications.
%   Conversion specifications involve the character %, optional flags,
%   optional width and precision fields, optional subtype specifier, and
%   conversion characters d, i, o, u, x, X, f, e, E, g, G, c, and s.
%   For more details, see the FPRINTF function description in online help
%   (search by Function Name for FPRINTF), or look up FPRINTF in a C 
%   language manual.
%
%   The special formats \n,\r,\t,\b,\f can be used to produce linefeed,
%   carriage return, tab, backspace, and formfeed characters respectively.
%   Use \\ to produce a backslash character and %% to produce the percent
%   character.
%
%   FPRINTF behaves like ANSI C with certain exceptions and extensions. 
%   These include:
%   1. Only the real part of each parameter is processed.
%   2. ANSI C requires an integer cast of a double argument to correctly
%      use an integer conversion specifier like d. A similar conversion
%      is required when using such a specifier with non-integral MATLAB
%      values. Use FIX, FLOOR, CEIL or ROUND on a double argument to
%      explicitly convert non-integral MATLAB values to integral values
%      if you plan to use an integer conversion specifier like d.
%      Otherwise, any non-integral MATLAB values will be outputted using
%      the format where the integer conversion specifier letter has been
%      replaced by e.
%   3. The following non-standard subtype specifiers are supported for
%      conversion characters o, u, x, and X.
%      t    - The underlying C datatype is a float rather than an
%             unsigned integer.
%      b    - The underlying C datatype is a double rather than an
%             unsigned integer.
%      For example, to print out in hex a double value use a format like
%      '%bx'.
%   4. FPRINTF is "vectorized" for the case when A is nonscalar. The
%      format string is recycled through the elements of A (columnwise)
%      until all the elements are used up. It is then recycled in a similar
%      manner through any additional array arguments.
%   
%   For example, the statements
%
%       x = 0:.1:1; y = [x; exp(x)];
%       fid = fopen('exp.txt','w');
%       fprintf(fid,'%6.2f  %12.8f\n',y);
%       fclose(fid);
%
%   create a text file containing a short table of the exponential function:
%
%       0.00    1.00000000
%       0.10    1.10517092
%            ...
%       1.00    2.71828183
%
%   See the reference page in the online help for other exceptions, 
%   extensions, or platform-specific behavior.
%
%   See also FSCANF, SPRINTF, FWRITE, DISP, DIARY, SAVE, INPUT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.16.4.3 $  $Date: 2004/04/10 23:29:26 $
%   Built-in function.




if nargout == 0
  builtin('fprintf', varargin{:});
else
  [varargout{1:nargout}] = builtin('fprintf', varargin{:});
end
