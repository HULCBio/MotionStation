%METHODS Display class method names.
%   METHODS CLASSNAME displays the names of the methods for the
%   class with the name CLASSNAME.
%
%   METHODS(OBJECT) displays the names of the methods for the
%   class of OBJECT.
%
%   M = METHODS('CLASSNAME') returns the methods in a cell array of
%   strings.
%
%   METHODS differs from WHAT in that the methods from all method
%   directories are reported together, and METHODS removes all
%   duplicate method names from the result list.  METHODS will also
%   return the methods for a Java class.
%
%   METHODS CLASSNAME -full  displays a full description of the
%   methods in the class, including inheritance information and,
%   for Java methods, also attributes and signatures.  Duplicate
%   method names with different signatures are not removed.
%   If class_name represents a MATLAB class, then inheritance 
%   information is returned only if that class has been instantiated. 
%
%   M = METHODS('CLASSNAME', '-full') returns the full method
%   descriptions in a cell array of strings.
%   
%   See also METHODSVIEW, WHAT, WHICH, HELP.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.20 $  $Date: 2002/04/15 03:21:37 $
%   Built-in functions.
