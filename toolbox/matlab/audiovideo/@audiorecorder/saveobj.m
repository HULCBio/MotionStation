function B = saveobj(obj)
%SAVEOBJ Save filter for audiorecorder objects.
%
%    B = SAVEOBJ(OBJ) is called by SAVE when an audiorecorder object is
%    saved to a .MAT file. The return value B is subsequently used by
%    SAVE to populate the .MAT file.  
%  
%    SAVEOBJ will not save the recorded audio data.  In order to save
%    the recorded audio data, use GETAUDIODATA on the audiorecorder object.
%
%    See also AUDIORECORDER/LOADOBJ, AUDIORECORDER/GETAUDIODATA.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/22 00:50:20 $

% Get the properties of the audiorecorder object.
props = get(obj);

% Save these properties as the internal object which is a private member.
% We are purposefully deleting the internalObj here as a convenience for
% saving the properties.
obj.internalObj = props;

B = obj;