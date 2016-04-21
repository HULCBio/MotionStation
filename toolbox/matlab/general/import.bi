function [varargout] = import(varargin)
%IMPORT Adds to the current Java packages and classes import list.
%   IMPORT PACKAGE_NAME.* adds the specified package name to the current
%   import list.
%
%   IMPORT PACKAGE1.* PACKAGE2.* ... can be used to add multiple
%   package names.
%
%   IMPORT CLASSNAME adds the fully qualified Java class name
%   to the import list.
%
%   IMPORT CLASSNAME1 CLASSNAME2 ... can be used to add multiple
%   fully qualified class names.
%
%   Use the functional form of IMPORT, such as IMPORT(S), when the
%   package or class name is stored in a string.
%
%   L = IMPORT(...) will return as a cell array of strings the contents
%   of the current import list as it exists when IMPORT completes.
%   L = IMPORT, with no inputs, can be used to obtain current import list
%   without adding to it.
%
%   IMPORT affects only the import list of the function within which
%   it is used.  There is also a base import list that is used
%   at the command prompt.  If IMPORT is used in a script, it will
%   affect the import list of the function which invoked the script,
%   or the base import list if the script is invoked from the
%   command prompt.
%
%   CLEAR IMPORT will clear the base import list.  The import lists
%   of functions may not be cleared.
%
%   Examples
%       import java.awt.*
%       import java.util.Enumeration java.lang.*
%       f = Frame;               % Create java.awt.Frame object
%       s = String('hello');     % Create java.lang.String object
%       methods Enumeration      % List java.util.Enumeration methods
%       
%IMPORTING DATA
%   You can also import various types of data into MATLAB.  This includes
%   importing from MAT-files, text files, binary files, or HDF files.  To 
%   import data from MAT-files, use the LOAD function.  To use the
%   graphical user interface to MATLAB's import functions, type UIIMPORT.
%
%   For further information on importing data, see Importing and Exporting
%   Data in the MATLAB Help Browser under the following headings:
%
%       MATLAB -> Using MATLAB -> Development Environment
%       MATLAB -> Using MATLAB -> External Interfaces/API
%
%   See also CLEAR, LOAD.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2003/06/09 05:58:02 $
%   Built-in function.

if nargout == 0
  builtin('import', varargin{:});
else
  [varargout{1:nargout}] = builtin('import', varargin{:});
end
