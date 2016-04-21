function targDataMap = gettargdatamap(relBuildDir,name),
% GETTARGDATAMAP calls the generated m-file model_targ_data_map.m and returns
%  data type transition information about the target.
%


%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/15 00:23:25 $
  
origDir = cd;

try
  buildDir = fullfile(origDir,relBuildDir);
  cd(buildDir);
  
  targDataMap = feval(name);        
  
catch
  cd(origDir);
  error(lasterr);
    
end

cd(origDir);
