%SUBSYSTEM_CONFIGURATION_BLKINIT Subsystem Configuration Mask initialization.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.5 $

CB = gcb;
status=get_param(CB,'UserData');
if isstruct(status),
  allDataNames= status.allData;
  for ndex = 1:length(allDataNames),
    eval([allDataNames{ndex},'=evalin(''base'',allDataNames{ndex});']);
  end
end
subsystem_configuration('reestablish', CB,'maskinit');
subsystem_configuration('update',CB);