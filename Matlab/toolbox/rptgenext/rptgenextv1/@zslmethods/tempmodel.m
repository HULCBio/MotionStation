function [modelName,systemName,blockName,signalName]=tempmodel(z,isSet)
%TEMPMODEL returns the name of a simple model
%   [MODEL,SYSTEM,BLOCK,SIGNAL]=TEMPMODEL(ZSLMETHODS)
%   [MODEL,SYSTEM,BLOCK,SIGNAL]=TEMPMODEL(ZSLMETHODS,1) will set the
%        ZSLMETHODS data structure .Model .System .Block and .Signal 
%        fields.


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:56 $


modelName='temp_rptgen_model';
systemName=[modelName '/SubSystem'];

if length(find_system('type','block_diagram','name',modelName))<1
   
   oldCurrentSystem=get_param(0,'currentsystem');
   
   %load model
   %oldDir=pwd;   
   %[aPath aFile aExt]=fileparts(mfilename('fullpath'));
   %cd(aPath);
   load_system(modelName);
   %cd(oldDir);   
   
   if ~isempty(oldCurrentSystem)
      try 
         set_param(0,'currentsystem',oldCurrentSystem);
      end
   end 
end

foundBlocks=find_system(systemName,'tag','TempmodelCurrentBlock');
if length(foundBlocks)>0
   blockName=foundBlocks{1};
else
   blockName=[];
end

foundSignals=find_system(systemName,'findall','on',...
   'porttype','outport',...
   'tag','TempmodelCurrentSignal');
if length(foundSignals)>0
   signalName=foundSignals(1);
else
   signalName=[];
end


if nargin >1 & isSet
   d=rgstoredata(z);
   d.Model=modelName;
   d.System=systemName;
   d.Block=blockName;
   d.Signal=d.signalName;
   rgstoredata(z,d);
end

