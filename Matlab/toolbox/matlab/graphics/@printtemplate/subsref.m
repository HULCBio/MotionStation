function result = subsref(this, Struct)
%SUBSREF Method to overload the . notation.
%   Publicize subscripted reference to private fields of object.
%
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/10 17:08:44 $

result = builtin('subsref', this, Struct );
