function corrupted = fix_corrupted_sf_blocks(modelName,silent)
%% fix_corrupted_sf_blocks(modelName)
%% Checks the validity of all Stateflow blocks in <modelName>. 
%% When any corrupted blocks are found, these are marked as 
%% non-Stateflow blocks to prevent further data-dictionary corruptions.
%% 
%%      Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.2 $  $Date: 2004/04/15 00:57:49 $
%
if(nargin<2)
   silent = 0;
end
global SF_LOAD_ALL_CHARTS_CLOSED
openModels = find_system('type','block_diagram');
modelOpenBefore = any(strcmp(openModels,modelName));
machineId = sf('Private','sf_force_open_machine',modelName);

if(strcmp(get_param(modelName,'BlockDiagramType'),'library'))
   set_param(modelName,'Lock','off');
end
modelH = get_param(modelName,'handle');
sfBlocks = find_system(modelH,'LookUnderMasks','all','MaskType','Stateflow');
if(~isempty(machineId))
   charts = sf('get',machineId,'machine.charts');
else
   charts = [];
end
corruptedSfBlocksFound = 0;
for i=1:length(sfBlocks)
   blockH = sfBlocks(i);
   if(isempty(get_param(blockH,'ReferenceBlock')))
      instanceId = get_param(blockH,'userdata');
      if(isempty(sf('get',instanceId,'instance.id')))
         msg = sprintf('Corrupted (no instance id):\n%s\n\n',getfullname(blockH));
         disp(msg);
         set_param(blockH,'masktype','');
         corruptedSfBlocksFound = 1;
      else
         chartId = sf('get',instanceId,'instance.chart');
         if(isempty(sf('get',chartId,'chart.id')))
            msg = sprintf('Corrupted (no chart id):\n%s\n\n',getfullname(blockH));
            disp(msg);
            set_param(blockH,'masktype','');
            corruptedSfBlocksFound = 1;
         else
            charts =setdiff(charts,chartId);
         end
      end
   end
end
if(~isempty(charts))
   orphanChartsFound  = 1;
else
   orphanChartsFound = 0;
end
openModelsNow = find_system('type','block_diagram');   
openModelsToClose = setdiff(openModelsNow,openModels);
if(corruptedSfBlocksFound | orphanChartsFound)
   openModelsToClose = setdiff(openModelsToClose,{modelName});
   open_system(modelName);
   if(corruptedSfBlocksFound)
      msg = sprintf('Corrupted Stateflow blocks found in model "%s".',modelName);
      msg = sprintf('%s\nThese are marked as non-Stateflow blocks in order to avoid further corruptions. Please delete these blocks immediately.',msg);
   elseif orphanChartsFound
      % orphan charts found
      msg = sprintf('Orphan charts (charts without corresponding Simulink blocks) found in "%s":',modelName);
      disp(msg);
      disp('----');
      for i=1:length(charts)
         chart = charts(i);
         msg = sprintf('%s\n',sf('FullNameOf',chart,'/'));
         disp(msg);
      end
      disp('----');   
   end
   disp(msg);
   corrupted = 1;
else
   if(modelOpenBefore)
      openModelsToClose = setdiff(openModelsToClose,{modelName});
   end
   if(~silent)
      disp(['No corrupted Stateflow blocks found in ',modelName]);  
   end
   corrupted = 0;
end
for i=1:length(openModelsToClose) 
   bdclose(openModelsToClose{i});
end
clear global SF_LOAD_ALL_CHARTS_CLOSED
