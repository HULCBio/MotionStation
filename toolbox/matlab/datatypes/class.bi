%CLASS  Create object or return object class.
%   C = CLASS(OBJ) returns the class of the object OBJ.
%   Possibilities are:
%     double          -- Double precision floating point number array
%                        (this is the traditional MATLAB matrix or array)
%     single          -- Single precision floating point number array
%     logical         -- Logical array
%     char            -- Character array
%     cell            -- Cell array
%     struct          -- Structure array
%     function_handle -- Function Handle
%     int8            -- 8-bit signed integer array
%     uint8           -- 8-bit unsigned integer array
%     int16           -- 16-bit signed integer array
%     uint16          -- 16-bit unsigned integer array
%     int32           -- 32-bit signed integer array
%     uint32          -- 32-bit unsigned integer array
%     int64           -- 64-bit signed integer array
%     uint64          -- 64-bit unsigned integer array
%     <class_name>    -- Custom object class
%     <java_class>    -- Java class name for java objects
%
%   All other uses of CLASS must be invoked within a constructor method,
%   in a file named <class_name>.m in a directory named @<class_name>.
%   Further, 'class_name' must be the second argument to CLASS.
%
%   O = CLASS(S,'class_name') creates an object of class 'class_name'
%   from the structure S.
%
%   O = CLASS(S,'class_name',PARENT1,PARENT2,...) also inherits the
%   methods and fields of the parent objects PARENT1, PARENT2, ...
%
%   O = CLASS(struct([]),'class_name',PARENT1,PARENT2,...), specifying
%   an empty structure S, creates an object that inherits from one or
%   more parent classes, but which does not have any additional fields
%   not inherited from the parents.
%
%   See also ISA, SUPERIORTO, INFERIORTO, STRUCT.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.17.4.1 $  $Date: 2004/04/01 16:12:14 $
%   Built-in function.
