% XPCBYTES2FILE Generate a file suitable for use by the 'From File' block.
%
%    XPCBYTES2FILE(FNAME, VAR1, VAR2, ...) generates a file FNAME
%    suitable for use by the xPC Target From File block.
%
%    The functions outputs one column of VAR1, VAR2, etc. will be output at
%    every time step. The variables VARn must all have the same number of
%    columns, though they may differ in the number of rows and in their data
%    types. For instance, if you want to use the From File block to output a
%    variable ERRORVAL (single precision, scalar) and VELOCITY (double, width
%    3) at every time step, you can generate the file by using the command
%
%       xpcbytes2file('myfile', errorval, velocity)
%
%    where ERRORVAL has class 'single' and dimensions [1 x N] and
%    VELOCITY has class 'double' and dimensions [3 x N]. In this case,
%    set up the From File block to output 28 bytes
%    (1 * sizeof('single') + 3 * sizeof('double')) at every sample time.
%
%    Note that you might have the data organized such that a row refers to a
%    single time step and not a column. In that case, pass the transpose of
%    the variable to XPCBYTES2FILE. Organizing the data in columns leads to a
%    more efficient file write.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: $ $Date: 2002/04/11 14:18:38 $