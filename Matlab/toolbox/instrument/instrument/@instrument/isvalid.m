function isok = isvalid(obj)
%ISVALID True for instrument or device group objects that can be connected to instrument.
%
%   OUT = ISVALID(OBJ) returns a logical array, OUT, that contains a 0 
%   where the elements of OBJ are deleted objects and a 1 where the
%   elements of OBJ are valid objects. OBJ can be a instrument object, 
%   device group object, an array of instrument objects or an array of
%   device group objects.
%
%   An invalid object (an object that has been deleted) cannot be connected
%   to an instrument. An invalid object should be cleared from the
%   workspace with CLEAR.
%
%   Example:
%       % Create a valid GPIB object.
%       g = gpib('ni', 0, 1);
%       out1 = isvalid(g)
%
%       % Delete the GPIB object and make it invalid.
%       delete(g)
%       out2 = isvalid(g)
%
%   See also INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.9.2.4 $  $Date: 2004/01/16 20:01:07 $


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