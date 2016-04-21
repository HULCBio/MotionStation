function out=execute(c)
%EXECUTE
%   OUT=EXECUTE(C)


% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 16:55:42 $

out='';

optionNames={
   'FixLogPref'
   'FixLogMerge'
   'FixUseDbl'
};

for i=1:length(optionNames)
   optionVal=getfield(c.att,optionNames{i});
   evalString=['global ' optionNames{i} '; ' ...
         optionNames{i} '=' optionVal ';'];
   try
      evalin('base',evalString);
   catch
      status(c,...
         ['Warning - could not set global value "' ...
            optionNames{i} '"'],...
         2);
   end
end