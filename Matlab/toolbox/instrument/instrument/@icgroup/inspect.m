function inspect(obj)
%INSPECT Inspect instrument or device group object properties.
%
%   INSPECT(OBJ) opens the property inspector and allows you to 
%   inspect and set properties for instrument object or device group
%   object, OBJ. 
%
%   Example:
%       g = gpib('agilent', 0, 2);
%       d = icdevice('agilent_e3648a', g);
%       outputs = d.Output;
%       inspect(g);
%       inspect(outputs(1));
%
%   See also INSTRUMENT/SET, INSTRUMENT/GET, INSTRUMENT/PROPINFO,
%   ICGROUP/SET, ICGROUP/GET, ICGROUP/PROPINFO, INSTRHELP.
%

%   MP 04-17-00
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 19:59:54 $

% Error checking.
if ~isa(obj, 'icgroup')
   error('icgroup:inspect:invalidOBJ','OBJ must be a device group object.');
end	

if ~isvalid(obj)
   error('icgroup:inspect:invalidOBJ','Device group object OBJ is an invalid object.');
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