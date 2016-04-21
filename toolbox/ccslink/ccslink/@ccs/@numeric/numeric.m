function nn = numeric(varargin)
%NUMERIC  Constructor for raw memory object 
%  MM = NUMERIC('PropertyName',PropertyValue,...)  Constructs an ..
%
%
%  Major Properties of NUMERICMEM
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
%  ENDIANNESS - Specifes the endianness of data values that
%   span multiple address units.  This property is initialized
%   to match the DSP device and memory type.
%
%  ARRAYORDER - Defines ordering of values when converting MATLAB
%    arrays to/from linearily addressable memory blocks.
%    'row-major' (default) - Rows filled first (C Style)
%    'col-major' - Columns filled first (Matlab Style)
%  REPRESENT - 

%  See Also CAST, READ, WRITE.

% 
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.2 $ $Date: 2004/04/08 20:46:38 $

nn = ccs.numeric;
construct_numeric(nn,varargin);

% [EOF] numeric.m
 