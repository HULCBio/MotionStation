function status = sfrtw_compliant()
% SFRTW_COMPLIANT checks whether or not the installation of
% Stateflow is compliant with Real-Time Workshop
%

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.2 $

if exist(fullfile(matlabroot,'toolbox','stateflow','coder', ...
		  'private', 'code_machine_source_file_rtw.m'))
  status = 1;
else
  status = 0;
end
