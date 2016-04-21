%GET  Get properties of linearization I/Os and operating points 
%
%   GET(OB) displays all properties and corresponding values of the object,
%   OB, which can be a linearization I/O object, an operating point object,
%   or an operating point specification object. Create OB using FINDOP,
%   GETLINIO, LINIO, OPERPOINT, or OPERSPEC. 
%
%   GET(OB,'PropertyName') returns the value of the property, PropertyName,
%   within the object, OB. The object, OB, can be a linearization I/O
%   object, an operating point object, or an operating point specification
%   object. Create OB using FINDOP, GETLINIO, LINIO, OPERPOINT, or OPERSPEC. 
%
%   OB.PropertyName is an alternative notation for displaying the value of
%   the property, PropertyName, of the object, OB. The object, OB, can be a
%   linearization I/O object, an operating point object, or an operating
%   point specification object. Create OB using FINDOP, GETLINIO, LINIO,
%   OPERPOINT, or OPERSPEC. 
%
%   Examples:
%   Create an operating point object for the Simulink model, magball.
%     op=operpoint('magball');
%   Get a list of all object properties using the GET function with the
%   object name as the only input. 
%     get(op)
%   To view the value of a particular property, supply the property name as
%   an argument to GET. For example, to view the name of the model
%   associated with the operating point object, type
%     V=get(op,'Model')
%   Since the operating point object is a structure, you can also view any
%   properties or fields using dot-notation, as in the following example.
%     W=op.States
%   Use GET to view details of W. For example
%     get(W(2),'x')
%
%   See also FINDOP, GETLINIO, LINIO, OPERPOINT, OPERSPEC, OPCOND/SET  

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.4.1 $ $Date: 2004/04/19 01:31:19 $
