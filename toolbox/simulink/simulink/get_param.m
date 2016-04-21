%GET_PARAM Get Simulink system and block parameter values.
%   GET_PARAM('OBJ','PARAMETER'), where 'OBJ' is a system or block path
%   name, returns the value of the specified parameter.  Case is ignored for
%   parameter names.
%
%   GET_PARAM(OBJ, 'ObjectParameters') returns a structure that describes
%   OBJ's parameters. Each field of the returned structure corresponds to a
%   particular parameter name (e.g., the 'Name' field corresponds to OBJ's
%   name parameter). Each parameter field itself is a structure with the
%   fields:
%
%   Type        parameter type ('boolean', 'string', 'int', 'real','point'
%              'rectangle', 'matrix','enum', 'ports', or 'list')
%   Enum        cell array of enumeration string values (applies only
%               to 'enum' parameter types)
%   Attributes  cell array of strings defining the attributes of the
%               parameter ('read-write', 'read-only','read-only-if-compiled',
%               'write-only', 'dont-eval', 'always-save', 'never-save','nondirty',
%               and/or 'simulation')
%
%   The 'DialogParameters' block property returns a similar structure
%   that describes only the parameters that appear in a block's parameter dialog.
%   
%   See also SET_PARAM, FIND_SYSTEM.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.24 $
%   Built-in function.

