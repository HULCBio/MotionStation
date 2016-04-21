function objectList = dow_package_registry()
%DOW_PACKAGE_REGISTRY returns the dow package registry
%
%   [OBJECTLIST]=DOW_PACKAGE_REGISTRY()
%   This function returns the registered packages for use with the data
%   object wizard.

%   INPUTS:
%          NONE
%   OUTPUTS:
%         objectList : a structure to be registerd for use with the data 
%                      object wizard.
%
%     objectList(1).class = {'Simulink'};
%     objectList(1).type{1} ={'Signal'};
%     objectList(1).type{2} ={'Parameter'};
%     objectList(1).derivedbyMPT = 'No';
%     objectList(2).class = {'mpt'};
%     objectList(2).type{1} ={'Signal'};
%     objectList(2).type{2} ={'Parameter'};
%     objectList(2).derivedbyMPT = 'Yes';
%     objectList(3).class = {'ASAP2'};
%     objectList(3).type{1} ={'Signal'};
%     objectList(3).type{2} ={'Parameter'};
%     objectList(3).derivedbyMPT = 'No';
%

%   Linghui Zhang
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/31 19:52:49 $

objectList(1).class={'Simulink'};
objectList(1).type{1}={'Signal'};
objectList(1).type{2}={'Parameter'};
objectList(1).derivedbyMPT = 'No';

objectList(2).class={'mpt'};
objectList(2).type{1}={'Signal'};
objectList(2).type{2}={'Parameter'};
objectList(2).derivedbyMPT = 'Yes';

if exist('get_additional_package_reg','file') == 2
    addList = get_additional_package_reg;
    for i = 1:length(addList)
        objectList(2+i) = addList(i);
    end
end
