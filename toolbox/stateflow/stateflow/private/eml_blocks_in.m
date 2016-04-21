function emlBlocks = eml_blocks_in(objectId)

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/15 00:57:19 $
% returns the eML blocks in simulink that are powered
% by Stateflow
charts = unencrypted_charts_in(objectId);
emlBlocks = [];
for i=1:length(charts)
   if(is_eml_chart(charts(i)))
      emlBlocks = [emlBlocks,charts(i)];
   end
end

