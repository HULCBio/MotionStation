function update_eml_data(machineId)
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/15 01:01:23 $

emlFcns = eml_fcns_in(machineId);
for j = 1:length(emlFcns)
    eml_man('update_data', emlFcns(j));
    eml_man('update_layout_data', emlFcns(j));
end
