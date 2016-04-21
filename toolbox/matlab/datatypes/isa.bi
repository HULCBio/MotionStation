%ISA    True if object is a given class.
%   ISA(OBJ,'class_name') returns true if OBJ is of the class, or inherits
%   from the class, 'class_name' and false otherwise.
%
%   Some possibilities for 'class_name' are:
%     double          -- Double precision floating point numeric array
%                        (this is the traditional MATLAB matrix or array)
%     logical         -- Logical array
%     char            -- Character array
%     single          -- Single precision floating-point numeric array
%     float           -- Double or single precision floating-point numeric array
%     int8            -- 8-bit signed integer array
%     uint8           -- 8-bit unsigned integer array
%     int16           -- 16-bit signed integer array
%     uint16          -- 16-bit unsigned integer array
%     int32           -- 32-bit signed integer array
%     uint32          -- 32-bit unsigned integer array
%     int64           -- 64-bit signed integer array
%     uint64          -- 64-bit unsigned integer array
%     integer         -- An array of any of the 8 integer classes above
%     numeric         -- Integer or floating-point array
%     cell            -- Cell array
%     struct          -- Structure array
%     function_handle -- Function Handle
%     <class_name>    -- Custom MATLAB object class or Java class
%
%   See also ISNUMERIC, ISLOGICAL, ISCHAR, ISCELL, ISSTRUCT, ISFLOAT,
%            ISINTEGER, ISOBJECT, ISJAVA, ISSPARSE, ISREAL, CLASS.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.16.4.1 $  $Date: 2004/03/08 02:01:32 $
%   Built-in function.
