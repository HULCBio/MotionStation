function allSheets=stylesheets(anObject)
%STYLESHEETS returns a list of all report generator stylesheets

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:28 $

regfiles=which('rptstylesheets.xml','-all');

allSheets=[];
for i=1:length(regfiles)
   [sheetStruct]=LocProcessFile(regfiles{i});
   if isempty(allSheets)
      allSheets=sheetStruct;
   else
      allSheets=[allSheets sheetStruct];
   end
end
[sortedNames,uniqueIndex,allIndex]=unique({allSheets.ID});
allSheets=allSheets(uniqueIndex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sheetStruct=LocProcessFile(filename)

fid = fopen(filename,'r'); 
regText=char(fread(fid))';
fclose(fid);

regText=LocBetweenTag(regText,'registry');

if isempty(regText)
    %v2.0 stylesheet registries use a different root element
    %"stylesheet_registry"
    sheetStruct=[];
    return;
end



%Get overlays reference list
fileRefs=LocBetweenTag(regText{:},'fileentities');
if ~isempty(fileRefs)
   fileID=LocBetweenTag(fileRefs{1},'refname');
   fileLoc=LocFileExtract(LocBetweenTag(fileRefs{1},'filename'));
else
   fileID={};
   fileLoc={};
end

%Create stylesheet information structure
sheet=LocBetweenTag(regText{:},'stylesheet');

for i=length(sheet):-1:1
   sheetStruct(i).Name=xlate(LocExtract(...
      LocBetweenTag(sheet{i},'name')));
   sheetStruct(i).ID=LocExtract(...
      LocBetweenTag(sheet{i},'ID'));
   sheetStruct(i).Formats=LocFormatExtract(...
      LocBetweenTag(sheet{i},'validformats'));
   sheetStruct(i).Description=xlate(LocExtract(...
      LocBetweenTag(sheet{i},'description')));
   
   stylesheetFile=LocFileReferences(...
      LocBetweenTag(sheet{i},'fileref'),fileID,fileLoc);
   if ~isempty(stylesheetFile)
      sheetStruct(i).Filename=stylesheetFile{1};
   else
      sheetStruct(i).Filename='';
   end
   
   %sheetStruct(i).Switches=LocExtract(LocBetweenTag(sheet{i},'switches'));
   
   sheetStruct(i).Variables=LocVariablesExtract(...
      LocBetweenTag(sheet{i},'variables'));
   
   dssslText=LocBetweenTag(sheet{i},'dsssl');
   if ~isempty(dssslText)
      sheetStruct(i).Overlays=LocFileReferences(...
         LocBetweenTag(dssslText{1},'overlayfileref'),fileID,fileLoc);
   else
      sheetStruct(i).Overlays={};
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function between=LocBetweenTag(all,tagname)

between={};
openTag=['<' tagname '>'];
closeTag=['</' tagname '>'];

openLoc=findstr(all,openTag)+length(openTag);
closeLoc=findstr(all,closeTag)-1;

for i=length(openLoc):-1:1
   between{i}=all(openLoc(i):closeLoc(i));   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=LocFormatExtract(tagContent);

stdFormats={'RTF95','RTF97','fot','pdf'};

tagContent=LocBetweenTag(tagContent{1},'format');
result={};

for i=1:length(tagContent)
   if strcmp(tagContent{i},'$stdprint$')
      result={result{:},stdFormats{:}};
   else
      result={result{:},tagContent{i}};
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=LocExtract(tagContent);

[spaces{1:length(tagContent)}]=deal(' ');
spaces{length(tagContent)}='';
toConvert={tagContent{:};spaces{:}};
result=strrep([toConvert{:}],'&amp;','&');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=LocFileExtract(tagContent);

result={};
for i=1:length(tagContent)
   directories=LocBetweenTag(tagContent{i},'d');
   file=LocBetweenTag(tagContent{i},'f');
   
   if strcmp(directories{1},'$MATLABroot$')
      directories{1}=matlabroot;
   end
   
   [fseps{1:length(directories)}]=deal(filesep);
   toConvert={directories{:},file{1};fseps{:},''};
   result{end+1}=[toConvert{:}];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=LocVariablesExtract(tagContent)      

if ~isempty(tagContent)
   vName=LocBetweenTag(tagContent{1},'varname');
   vValue=LocBetweenTag(tagContent{1},'varvalue');
   numVars=min(length(vName),length(vValue));
   
   if numVars>0
      [result{1:numVars,1}]=deal(vName{:});
      [result{1:numVars,2}]=deal(vValue{:});      
   else
      result={};
   end
else
   result={};
end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result=LocFileReferences(fileRefs,fileID,fileLoc)

result={};

for i=1:length(fileRefs)
   listMatch=find(strcmp(fileID,fileRefs{:}));
   if ~isempty(listMatch)
      result{end+1}=fileLoc{listMatch(1)};
   else
      result{end+1}='';
   end
   
   %else
   %   warning('Could not find stylesheet file reference')
   %end
end
