function result = eml_template_man(method,libName,fcnName)

% Copyright 2003-2004 The MathWorks, Inc.

switch(method)
   case 'lib_dir'
      result = eml_lib_dir(libName);
   case 'get_support_fcn_list'
      emlLibDir = eml_lib_dir(libName);
      templateSupportFcnListFile  = fullfile(emlLibDir,'template_support_fcn_list.h');
      if(exist(templateSupportFcnListFile))
         fp = fopen(templateSupportFcnListFile,'r');
         F = fread(fp);
         result = char(F');
         fclose(fp);
      else
         result = [];
      end
   case 'get_list'
      [emlLibDir,emlLibDoubleDir] = eml_lib_dir(libName);
      r1 = script_names_in(emlLibDir);
      r2 = script_names_in(emlLibDoubleDir);
      % the intersection between r1 and r2 must be empty to insure
      % unique script names wrt the @double subdirectory
      i = intersect(r1,r2);
      if ~isempty(i)
         s = ['{ ',sprintf('"%s" ',i{:}),'}'];
         error(sprintf('Embedded MATLAB function(s) %s in "%s" runtime library is not unique!',s,libName));
      end
      result = {r1{:},r2{:}};
   case 'get_script'
      [emlLibDir,emlLibDoubleDir] = eml_lib_dir(libName);
      scriptInfo.script = '';
      scriptInfo.checksum = [0 0 0 0];

      scriptFile = fullfile(emlLibDoubleDir,[fcnName,'.m']);
      scriptInfo.filepath = scriptFile;
      if(~exist(scriptFile,'file'))
         scriptFile = fullfile(emlLibDir,[fcnName,'.m']);
         scriptInfo.filepath = scriptFile;
         if(~exist(scriptFile,'file'))
             % Return empty if the request script doesn't exist.
             result = [];
             return;
         end
      end
      fp = fopen(scriptFile,'r');
      F = fread(fp);
      F = char(F');
      fclose(fp);
      scriptInfo.script = F;

      %for authentication
      matFile = fullfile(matlabroot,'toolbox','eml','lib',libName,[fcnName,'.mat']);
      if(exist(matFile))
         load(matFile);
         scriptInfo.checksum = templateChecksum;
      end
      result = scriptInfo;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [libDir,libDoubleDir] = eml_lib_dir(libName)

libDir = fullfile(matlabroot,'toolbox','eml','lib',libName);
if nargout>1
    libDoubleDir = fullfile(libDir,'@double');
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = script_names_in( emlLibDir ) 
      if(~exist(emlLibDir,'dir'))
         result = {};
         return;
      end
      emlScriptList = dir(fullfile(emlLibDir,'*.m'));
      if(~isempty(emlScriptList))
         scriptNames = {emlScriptList.name};
         for i=1:length(scriptNames)
            [pathStr,scriptNames{i}] = fileparts(scriptNames{i});
         end
      else
         scriptNames = {};
      end
      result = scriptNames;

