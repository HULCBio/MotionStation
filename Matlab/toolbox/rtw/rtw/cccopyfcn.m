function cccopyfcn(block)
%CCCOPYFCN Custom Code blocks Copyfcn callback


%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $

%
% Abstract:
%   cccodefcn deletes empty subsystems in Custom Code blocks
%   required for Simulink Library Browser functionality
%

%break library link
set_param(block,'Linkstatus','none');

%delete empty subsystem
asub=find_system(block,'LookUnderMasks','all','BlockType','SubSystem');
if ~isempty(asub) & (length(asub) > 1)
  delete_block(asub{2});
end


