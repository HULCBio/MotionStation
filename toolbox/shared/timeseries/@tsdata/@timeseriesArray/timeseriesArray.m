function h = timeseriesArray(varname)
% TIMESERIESARRAY Time storage object constructor
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:34:07 $

h = tsdata.timeseriesArray;
if nargin==0
    return
end
% Grab singleton hds variable manager
vm = hds.VariableManager;
% Install variables
h.variable = vm.findvar(varname);

% Install metadata
switch varname
    case 'Time'
        h.metadata = tsdata.timemetadata;
    case 'Quality'
        h.metadata = tsdata.qualmetadata;
    case 'Data'
        h.metadata = tsdata.metadata;
        h.metadata.Name = 'Data';
end

 
