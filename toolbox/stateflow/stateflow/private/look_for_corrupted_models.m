function result = look_for_corrupted_models(dirName)
% Usage: 
% look_for_corrupted_models(dirName)
% where dirName is a relative or absolute path containing
% Simulink models/libraries you wish to sanity-check.
% It opens every mdl file in the specified directory
% and checks for corrupted Stateflow blocks.
% It then prints a message indicating the pathnames of
% corrupted blocks and keeps these models open.
% 

% Copyright 2003 The MathWorks, Inc.

openModels = find_system('type','block_diagram');

if(nargin==0)
   dirName = pwd;
   lookAtOpenModelsOnly = 1;
else
   lookAtOpenModelsOnly = 0;
end

currDir = pwd;
cd(dirName);

corruptedModels = {};
if(lookAtOpenModelsOnly)
   interestingModels = setdiff(openModels,{'simulink','simulink3','simulink_extras'});
else
   a = what;
   mdlFiles = a.mdl;
   interestingModels = {};
   for i=1:length(mdlFiles)
      [pathStr,mdlName] = fileparts(mdlFiles{i});
      interestingModels{end+1} = mdlName;
   end
end   
for i=1:length(interestingModels)
   corrupted = sf('Private','fix_corrupted_sf_blocks',interestingModels{i},1);
   if(corrupted)
      corruptedModels{end+1} = interestingModels{i};
   end
end
if(~isempty(corruptedModels))
   disp(sprintf('Corrupted Models Found:\n'));
   for i=1:length(corruptedModels)
      disp(sprintf('%s\n',corruptedModels{i}));
   end
else
   if(lookAtOpenModelsOnly)
      disp(sprintf('All open models are ok'));
   else
      disp(sprintf('All models in directory %s are ok',dirName));
   end
end

openModelsNow = find_system('type','block_diagram');   
openModelsToClose = setdiff(openModelsNow,openModels);
openModelsToClose = setdiff(openModelsToClose,corruptedModels);
for i=1:length(openModelsToClose) 
   bdclose(openModelsToClose{i});
end
cd(currDir);

if(nargout==1)
   result = corruptedModels;
end
