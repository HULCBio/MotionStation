%Using Java from within MATLAB.
%
%   You can construct Java objects from within MATLAB by using the
%   name of the class to instantiate:
%
%    >> f = java.awt.Frame('My Title')
%
%    f =
%
%    java.awt.Frame[frame0,0,0,0x0,invalid,hidden,layout=java.awt.BorderLayout,resizable,title=my title]
%
%   You can call methods of Java objects using either MATLAB syntax:
%       >> setTitle (f, 'new title' )
%       >> t = getTitle(f)
%   
%       t =
%   
%       new title
%
%   or Java syntax:
%       >> f.setTitle ('new title' )
%       >> t = f.getTitle
%   
%       t =
%   
%       new title
%
%   In this example f is the java.awt.Frame object created above,
%   and getTitle and setTitle are methods of that object.
%
% Changed and enhanced built-in functions
%
%  METHODS
%   The METHODS function now accepts a Java class name as an
%   argument.  METHODS also now accepts the -full qualifier.
%   The -full qualifier will cause METHODS to return a full
%   description of all methods instances in a Java class,
%   including method signatures and other information relevant to
%   use of the methods in a Java class. 
%   METHODS without -full will return a compact methods listing
%   with all duplicate method names removed.
%
%  FIELDNAMES
%   The FIELDNAMES function now accepts a Java object as an
%   argument. FIELDNAMES also now accepts the -full qualifier.
%   The -full qualifier will cause FIELDNAMES to return a full
%   description of all public fields in a Java object,
%   including attributes and type and inheritance. FIELDNAMES
%   without -full will return a compact fieldnames listing.
%
%  ISA
%   The ISA function now accepts Java class names.  It will return 1
%   if an array is a member of the specified Java class, or if the
%   array inherits from the specified Java class.  For example,
%   isa(x, 'java.awt.Frame'), isa(x, 'java.awt.Component'),
%   and isa(x, 'java.lang.Object') will all return 1 if
%   x contains an object of class java.awt.Frame.
%
%  EXIST
%   The EXIST function now accepts a second argument 'class'.
%   EXIST now returns 8 if the first argument is the name of a
%   Java class on MATLAB's Java classpath.
%
%  CLASS
%   The CLASS function has been enhanced to return the Java class
%   name of Java objects.
%
%  DOUBLE
%   DOUBLE has been overloaded to convert to MATLAB double all Java
%   objects and Java arrays of objects that inherit from java.lang.Number,
%   such as java.lang.Integer, java.lang.Byte, etc.  Any Java class
%   that contains a "toDouble" method can also enable MATLAB to convert
%   objects of that class to MATLAB double;  MATLAB calls the "toDouble"
%   method in the Java class to convert such objects to MATLAB double.
%
%  CHAR
%   CHAR has been overloaded to convert to MATLAB character array all
%   java.lang.String objects, and to convert to MATLAB cell array of
%   characters all Java array of java.lang.String.  Any Java class
%   that contains a "toChar" method can also enable MATLAB to convert
%   objects of that class to MATLAB characters;  MATLAB calls the "toChar"
%   method in the Java class to convert such objects to MATLAB
%   characters.
%
%  INMEM
%   INMEM has been enhanced to accept an optional third argument
%   output.  If supplied, this third argument will return a list of
%   all Java classes loaded.
%
%  WHICH
%   WHICH will search all loaded Java classes for methods that
%   match the argument string.
%
%  CLEAR
%   CLEAR IMPORT will clear the base import list.
%
%  SIZE
%   When the SIZE function is applied to a Java array, the number of
%   rows returned is the length of the Java array and the number of
%   columns is always 1.  When SIZE is applied to a Java array of arrays,
%   the result describes only the top level array in the array of arrays.
%
% New built-in functions
%
%  METHODSVIEW
%   The METHODSVIEW function displays information on all methods 
%   implemented by the specified class.  METHODSVIEW creates a new 
%   window and formats the information in an easily read table format.
%
%   METHODSVIEW PACKAGE_NAME.CLASS_NAME displays information describing 
%   the Java class, CLASS_NAME, that is available from the package of 
%   Java classes, PACKAGE_NAME.
%
%   METHODSVIEW CLASS_NAME displays information describing the imported 
%   Java or MATLAB class, CLASS_NAME.
%
%   Example
%   % list information on all methods in the java.awt.MenuItem class.
%   methodsview java.awt.MenuItem
%
%  IMPORT Adds to the current Java packages and classes import list.
%   IMPORT PACKAGE_NAME.* adds the specified package name to the
%   current import list.  IMPORT PACKAGE_NAME.CLASS_NAME imports
%   the specified Java class.
%
%   IMPORT PACKAGE1.* PACKAGE2.CLASS_NAME ... can be used to import
%   multiple packages and classes.
%
%   L = IMPORT(...) will return as a cell array of strings the
%   contents of the current import list as it exists when IMPORT
%   completes.
%
%   L = IMPORT, with no inputs, can be used to obtain current import
%   list without adding to it.
%
%   IMPORT affects only the import list of the function within which
%   it is used.  There is also a base import list that is used
%   at the command prompt.  If IMPORT is used in a script, it will
%   affect the import list of the function which invoked the script,
%   or the base import list if the script is invoked from the
%   command prompt.
%
%   CLEAR IMPORT will clear the base import list.
%
%   Examples
%       import java.awt.*
%       import java.util.Enumeration java.lang.*
%       f = Frame;               % Create java.awt.Frame object
%       s = String('hello');     % Create java.lang.String object
%       methods Enumeration      % List java.util.Enumeration methods
%
%  ISJAVA  True for Java objects
%   ISJAVA(J) returns 1 if J is a Java object, and 0 otherwise.
%
%   If a constructor matching the specified class and signature does
%   not exist,  an error will occur.
%
%  javaArray
%   The javaArray function constructs a Java array having the 
%   specified dimensions.
%
%   JA = javaArray(CLASS_NAME,DIM1,...) returns a Java array object
%   (an object with Java dimensionality), the component class of which
%   is the Java class specified by the character string CLASSNAME.
%
%   Examples
%     % create a 10x5 java.awt.Frame Java array
%     ja = javaArray('java.awt.Frame',10,5);
%
%  javaMethod 
%   The javaMethod function invokes the specified Java method.
%
%   X = javaMethod(METHOD_NAME,CLASS_NAME,X1,...,Xn) invokes the 
%   static method METHOD_NAME in the class CLASS_NAME, with the 
%   argument list that matches X1,...,Xn.
%
%   javaMethod(METHOD_NAME,J,X1,...,Xn) invokes the nonstatic method
%   METHOD_NAME on the object J, with the argument list that matches
%   X1,...,Xn.
%
%   Example
%     % invoke the nonstatic method setTitle, where frameObj is a 
%     % java.awt.Frame object.
%     frameObj = java.awt.Frame;
%     javaMethod('setTitle', frameObj, 'New Title');
%
%  javaObject
%   The javaObject function constructs an object of the specified
%   Java class.
%
%   J = javaObject(CLASS_NAME,X1,...,Xn) invokes the Java constructor
%   for class CLASS_NAME with the argument list that matches X1,...,Xn,
%   to return a new object.
%
%   Example
%     % construct and return a Java object of class java.lang.String
%     strObj = javaObject('java.lang.String','hello')
%
% Caveats
%
%   When a Java array of arrays is indexed with only one subscript,
%   the value returned is an array in the top level array of arrays,
%   not a scalar element of the linearized form of the array of
%   arrays.
%
%   See also PERL, MEX.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.3 $  $Date: 2004/03/17 20:05:20 $


