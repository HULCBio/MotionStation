function isok = isvalid(obj)
%ISVALID True for serial port objects that can be connected to device.
%
%   OUT = ISVALID(OBJ) returns a logical array, OUT, that contains a 0 
%   where the elements of OBJ are deleted serial port objects and a 1 
%   where the elements of OBJ are valid serial port objects. 
%
%   An invalid serial port object (an object that has been deleted) 
%   cannot be connected to the device. An invalid serial port object
%   should be cleared from the workspace with CLEAR.
%
%   Example:
%       % Create a valid serial port object.
%       s = serial('COM1');
%       out1 = isvalid(s)
%
%       % Delete the serial port object and make it invalid.
%       delete(s)
%       out2 = isvalid(s)
%
%   See also SERIAL/DELETE.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.3 $  $Date: 2004/01/16 20:04:29 $


% Call isvalid on the java object.
try
    jobject = igetfield(obj, 'jobject');
    size_jobject = size(jobject);
    isok = zeros(1, max(size_jobject));
    for i=1:max(size_jobject)
    	isok(i) = isvalid(jobject(i));
    end
catch
   rethrow(lasterror);
end

if ~isequal([1 max(size_jobject)], size_jobject)
	isok = isok';
end

isok = logical(isok);
