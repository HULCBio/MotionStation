function out = getsetstore(obj,value)
%GETSETSTORE Set daqdevice object's store field.
%
%    VAL = GETSETSTORE(OBJ) returns the value of daqdevice object's, OBJ,
%    Store field to VAL.
%
%    GETSETSTORE(OBJ,VAL) sets the value of the Store field to VAL.
%
%    This function is a helper function for the SAVEOBJ method.
%    It is used to store the object's property information (that is
%    needed when the object is loaded) in the daqdevice object's Store 
%    field before saving the object.
%

%    MP 5-13-98   
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.4 $  $Date: 2003/08/29 04:41:14 $

% Obtain the information in the store field
if nargin==1
   out = obj.store;
% Set the daqdevice's store field to value.   
elseif nargin==2
  obj.store = value;
  out = obj;
end