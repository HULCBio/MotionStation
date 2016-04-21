function retCS = configSetPref(action, path)

% Copyright 2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $
  
  retCS = [];
  
  % if we did not find any preference path then quietly bail out
  if isempty(path)
    return;
  end
  
  currPath = pwd;
  try
    cd(path);
  catch
    return;
  end
  
  prefFileName = 'Simulink_ConfigSet_Prefs.mat';

  try
    switch action
     case 'Save'
      %disp(['Saving out Simulink root configuration sets to ' pwd]);
      defaultCS = get_param(0, 'ConfigurationSets');
      % make a copy so that we can get rid of all unwanted dialog stuffs
      for i = 1:length(defaultCS)
        defaultCSCopy(i) = defaultCS(i).copy;
      end
      defaultCS = defaultCSCopy;
      ConfigSetSettings.Defaults = defaultCS;
      save(prefFileName, 'ConfigSetSettings');        
      clear defaultCSCopy;
      clear defaultCS;
      clear ConfigSetSettings;
      rootCS = getActiveConfigSet(0);
      set(rootCS, 'HasUnsavedChanges', 'off');
      set(rootCS, 'HasSavedPrefs', 'on');
      
     case 'Load'
      if exist(prefFileName, 'file')
        content = load(prefFileName);
        if isfield(content, 'ConfigSetSettings')
          ConfigSetSettings = content.ConfigSetSettings;
          if isfield(ConfigSetSettings, 'Defaults') && ...
                isa(ConfigSetSettings.Defaults, 'Simulink.ConfigSet')
            retCS = ConfigSetSettings.Defaults;
            %disp(['Loaded Simulink root configuration sets from ' pwd]);
          end
        end
      end

     case 'Clear'
      if exist(prefFileName, 'file')
        delete(prefFileName);
      end
     otherwise
    end
  end
  
  cd(currPath);
  
