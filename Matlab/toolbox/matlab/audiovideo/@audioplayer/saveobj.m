function B = saveobj(obj)
%SAVEOBJ Save filter for audioplayer objects.
%
%    B = SAVEOBJ(OBJ) is called by SAVE when an audioplayer object is
%    saved to a .MAT file. The return value B is subsequently used by
%    SAVE to populate the .MAT file.  
%  
%    See also AUDIOPLAYER/LOADOBJ.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.2 $  $Date: 2003/12/22 00:50:17 $

% Get the properties of the audioplayer object.
props = get(obj);

% Save these properties as the internal object which is a private member.
% We are purposefully destroying the internal object here as a
% convenience for saving out the properties.

obj.internalObj = props;

% Because obj is an audioplayer object, its other private field, signal
% will be saved out when obj is saved.
B = obj;