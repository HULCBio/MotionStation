function nn = rnumeric(varargin)
%RNUMERIC  Constructor for rnumeric object 
%  MM = RNUMERIC('PropertyName',PropertyValue,...)  Constructs an ..
%
%  Major Properties of RNUMERIC
%  -----------------
%  SIZE - Defines the dimensions of the numeric array as a vector
%   of sizes.  One place this propetty is used directly is by 
%   the read methods to determine the size of the returned numeric 
%   array.  For example, SIZE = [2 2 2] means 
%
%  STORAGEUNITSPERVALUE - Number of address units used to define a value. For
%   example, IEEE single-precision floating point requires 32 bits,
%   therefore in byte-addressable memory (bitsperstorageunit=8) the ANUM 
%   property equals 4 (i.e. 8x4=32 bits).
%
%  ARRAYORDER - Defines ordering of values when converting MATLAB
%    arrays to/from linearily addressable memory blocks.
%    'row-major' (default) - Rows filled first (C Style)
%    'col-major' - Columns filled first (Matlab Style)
% 
%  REPRESENT - Defines how MATLAB interprets and presents the data stored
%    in the register. Data can be interpreted as a binary, twos complement or
%    IEEE floating point format.
%
%  See Also CAST, READ, WRITE.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:11:46 $

nn = ccs.rnumeric;
construct_rnumeric(nn,varargin);

% [EOF] rnumeric.m
 