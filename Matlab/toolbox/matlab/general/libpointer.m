function ptr=libpointer(varargin)
%LIBPOINTER Creates a pointer object for use with external libraries.
%
%   M = LIBPOINTER returns an empty (void) pointer
%
%   M = LIBPOINTER('TYPE') returns an empty pointer to the given type
%   type can be any matlab numeric type, or a structure or enum defined in
%   a loaded library.
%
%   M = LIBPOINTER('TYPE',INITIALVALUE) returns a pointer object
%   initialized to the INITIALVALUE supplied.
%
%   See also JAVA, LIBSTRUCT.
   
%   Copyright 2002-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/03/17 20:05:22 $

 ptr=lib.pointer(varargin{:});
 
