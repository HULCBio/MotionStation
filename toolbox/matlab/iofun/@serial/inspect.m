function inspect(obj)
%INSPECT Open inspector and inspect serial port object properties.
%
%   INSPECT(OBJ) opens the property inspector and allows you to 
%   inspect and set properties for serial port object, OBJ. 
%
%   Example:
%       s = serial('COM2');
%       inspect(s);
%   
%   See also SERIAL/SET, SERIAL/GET.
%

%   MP 04-17-00
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.3 $  $Date: 2004/01/16 20:04:23 $

% Error checking.
if ~isa(obj, 'instrument')
   error('MATLAB:serial:inspect:invalidOBJ','OBJ must be an instrument object.');
end	

if ~isvalid(obj)
   error('MATLAB:serial:inspect:invalidOBJ','Instrument object OBJ is an invalid object.');
end

% Build up the array of instrument objects to pass to the inspector.
id.type = '()';
id.subs = {1};

out = cell(1, length(obj));
for i=1:length(obj)
    id.subs = {i};
    s = subsref(obj, id);
    out{i} = java(igetfield(s, 'jobject'));
end

% Open the inspector.
com.mathworks.ide.inspector.Inspector.inspectObjectArray(out);