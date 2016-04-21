%javaMethod  Invoke a Java method.
%   javaMethod may be used to invoke either static or non-static
%   Java methods.
%
%   If M is a string containing the name of a Java method, and C is a
%   string containing the name of a Java class, then 
%
%   javaMethod(M,C,x1,...,xn)
%
%   will invoke the Java method M in the class C with the signature
%   matching the arguments x1,...,xn. For example, 
%   
%   javaMethod('isNaN', 'java.lang.Double', x)
%
%   will invoke the static Java method isNaN in class java.lang.Double.
%
%   If J is a Java object array, then javaMethod(M,J,x1,...xn) will 
%   invoke the non-static Java method M in the class of J with the
%   signature matching the arguments x1,...xn. For example,
%   if F is a java.awt.Frame Java object array, then
%
%   javaMethod('setTitle', F, 'New Title')
%
%   will set the title for the frame. javaMethod will not normally be
%   needed or used in this form. The usual way to invoke Java methods
%   on a Java  object is by the MATLAB method invocation syntax, such as 
%   setTitle(F, 'New Title'), or the Java invocation syntax,
%   such as F.setTitle('New Title'). javaMethod is provided for
%   those instances when the normal method invocation syntax cannot
%   be used (such as when complete control is required).
%
%   See also javaObject, IMPORT, METHODS, ISJAVA.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/15 03:22:39 $
