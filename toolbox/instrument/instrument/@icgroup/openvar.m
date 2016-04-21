function openvar(name, obj)
%OPENVAR Open a device group object for graphical editing.
%
%   OPENVAR(NAME, OBJ) open a device group object, OBJ, for graphical
%   editing. NAME is the MATLAB variable name of OBJ.
%
%   See also ICGROUP/SET, ICGROUP/GET, ICGROUP/PROPINFO, INSTRHELP.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:00:15 $

if ~isa(obj, 'icgroup')
    errordlg('OBJ must be a device group object.', 'Invalid object', 'modal');
    return;
end

if ~isvalid(obj)
    errordlg('The object is invalid.', 'Invalid object', 'modal');
    return;
end

try
    inspect(obj);
catch
    instrgate('privateFixError');
    errordlg(lasterr, 'Inspection error', 'modal');
end

