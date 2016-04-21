function commit(obj, filename)
%COMMIT Save IVI configuration store object.
%
%   COMMIT(OBJ) saves the IVI configuration store object, OBJ, to the 
%   configuration store data file. The configuration store data file is 
%   defined by OBJ's ActualLocation property.
%
%   COMMIT(OBJ, FILE) saves the IVI configuration store object, OBJ, to 
%   the configuration store data file, FILE. No changes are saved to the 
%   configuration store data file that is defined by OBJ's ActualLocation 
%   property.
%
%   The IVI configuration store object, OBJ, can be modified with the ADD,
%   UPDATE and REMOVE functions.
%
%   See also IVICONFIGURATIONSTORE/ADD, IVICONFIGURATIONSTORE/UPDATE,
%   IVICONFIGURATIONSTORE/REMOVE.
%

%   PE 10-01-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 19:59:28 $

nargchk(1, 2, nargin);

if (nargin == 1)
    if ~isempty(obj.cobject.ProcessDefaultLocation)
        filename = obj.cobject.ProcessDefaultLocation;
    else
        filename = obj.cobject.MasterLocation;
    end
else
    if (~ischar(filename))
        error('iviconfigurationstore:commit:invalidfile', 'FILENAME must be a string.');
    end
end

try
    Serialize(obj.cobject, filename);
catch
    rethrow(lasterror);
end
