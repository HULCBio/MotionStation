%javaObject   Invoke a Java object constructor.
%   If C is a string containing the name of a Java class, then
%
%   javaObject(C,x1,...,xn)
%
%   invokes the Java constructor for class C with  the signature
%   matching the arguments x1,...,xn. The resulting Java object 
%   is returned as a Java object array.
%
%   For example,
%
%   X = javaObject('java.awt.Color', 0.1, 0, 0.7)
%
%   will construct and return a java.awt.Color object array.
%
%   If a constructor matching the specified class and signature does
%   not exist, an error will occur.
%
%   javaObject will not normally be needed or used; the usual way 
%   to invoke Java constructors is by the MATLAB constructor syntax,
%   such as X = java.awt.Color(0, 0, 200). javaObject is provided
%   for those instances that the MATLAB constructor syntax cannot be
%   used (such as when class parametric object construction is
%   required).
%
%   See also javaMethod, IMPORT, METHODS, FIELDNAMES, ISJAVA.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/15 03:22:44 $

