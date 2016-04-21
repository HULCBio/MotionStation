%SET  Set properties of linearization I/Os and operating points 
%
%   SET(OB) displays all editable properties of the object, OB, which can 
%   be a linearization I/O object, an operating point object, or an
%   operating point specification object. Create OB using FINDOP, GETLINIO,
%   LINIO, OPERPOINT, or OPERSPEC. 
%
%   SET(OB,'PropertyName',VAL) sets the property, PropertyName, of the 
%   object, OB, to the value, VAL. The object, OB, can be a linearization 
%   I/O object, an operating point object, or an operating point 
%   specification object. Create OB using FINDOP, GETLINIO, LINIO, 
%   OPERPOINT, or OPERSPEC. 
%
%   OB.PropertyName=VAL is an alternative notation for assigning the value,
%   VAL, to the property, PropertyName, of the object, OB. The object, OB,
%   can be a linearization I/O object, an operating point object, or an 
%   operating point specification object. Create OB using FINDOP, GETLINIO,
%   LINIO, OPERPOINT, or OPERSPEC. 
%
%   Examples
%   Create an operating point object for the Simulink model, magball. 
%     op_cond=operpoint('magball');
%   Use the SET function to get a list of all editable properties of this 
%   object. 
%     set(op_cond)
%   To set the value of a particular property, provide the property name 
%   and the desired value of this property as arguments to SET. For
%   example, to change the name of the model associated with the operating
%   point object from 'magball' to 'Magnetic Ball', type 
%     set(op_cond,'Model','Magnetic Ball')
%   To view the property value and verify that the change was made type 
%     op_cond.Model
%   Since the operating point object is a structure, you can set any
%   properties or fields using dot-notation. First produce a list of
%   properties of the second States object. 
%     set(op_cond.States(2))
%   Now, use dot-notation to set the x property to 8. 
%     op_cond.States(2).x=8;
%  
%   See also FINDOP, GET, LINIO, OPERPOINT, OPERSPEC, SETLINIO

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.4.1 $ $Date: 2004/04/19 01:31:21 $
