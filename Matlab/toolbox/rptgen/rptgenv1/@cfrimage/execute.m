function out=execute(c)
%EXECUTE inserts tags into the source file
%   OUTPUT=EXECUTE(C)
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:21 $

[nameOrig,nameNew]=LocGetImgFile(c);

if ~isempty(nameNew)
   imgTag=LocGetImgTag(c.att,nameNew);
   coTag=LocGetCallouts(c.att.CalloutList,imgTag);
   caTag=LocGetCaption(c.att);
   out=LocGetTitle(c.att,coTag,caTag,nameOrig);
else
   out='';
   status(c,sprintf('Error - file "%s" not found', c.att.FileName),2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function figureTag=LocGetTitle(catt,coTag,caTag,fileName);

if strcmp(catt.isTitle,'none')
   figureTag={coTag caTag};
else
   if strcmp(catt.isTitle,'filename')
      [aPath aFile aExt aVer]=fileparts(fileName);
      titleText=[aFile aExt];
   else
      titleText=catt.Title;
   end
   titleTag=set(sgmltag,...
      'tag','Title',...
      'data',titleText);
   figureTag=set(sgmltag,...
      'tag','Figure',...
      'data',{titleTag coTag caTag});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nameOrig,nameNew]=LocGetImgFile(c)

parsedName=parsevartext(c,c.att.FileName);
nameOrig=which(parsedName);
if isempty(nameOrig)
   if exist(parsedName,'file')>0
      nameOrig = parsedName;
   else
      nameOrig='';
      nameNew='';
      return
   end
end

if c.att.isCopyFile
   imgInfo=getimgformat(c.rptcomponent,'png');
   imgInfo.ID='copied-source';
   imgInfo.ext=LocGetExtension(parsedName);
   
   [nameNew,isNew]=getimgname(c,imgInfo,'copied',parsedName);
   
   if isNew
      ok=copyfile(nameOrig,nameNew);
   end
   
   if ~ok
      nameNew = nameOrig;
      status(c,'Could not copy file to Report Images directory',2);
   end
else
   nameNew = nameOrig;
end

%Try to define a relative path name to the file
rptDir=c.rptcomponent.ReportDirectory;
if rptDir(end)~=filesep
   rptDir=[rptDir filesep];
end

foundIndex=findstr(upper(rptDir),upper(nameNew));
if length(foundIndex)>0
   %image is relative to Report Images
   nameNew =['./' nameNew(foundIndex(1)+length(rptDir):end)];
   %fileseps must be '/' for over-the-web use
   nameNew=strrep(nameNew,filesep,'/');
elseif strcmp(c.rptcomponent.Format,'HTML')
   %image is not in a subdirectory of the report path
   %and we're producing to HTML
   nameNew=['file://' strrep(nameNew,filesep,'/')];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function coTag=LocGetCallouts(coList,imgTag);

%an example callout list:
%<GRAPHICCO>
%   <AREASPEC UNITS="CALSPAIR">
%      <AREA ID="co123" COORDS="301,256 402,209">
%      <AREA ID="co124" COORDS="100,100 150,150">
%   </AREASPEC>
%   <GRAPHIC FILEREF=".\foo_html\slsnap2.jpg"></GRAPHIC>
%   <CALLOUTLIST>
%      <CALLOUT AREAREFS="co123">
%         <PARA>Subsystem 1</PARA>
%      </CALLOUT>
%      <CALLOUT AREAREFS="co124">
%         <PARA>Subsystem 2</PARA>
%      </CALLOUT>
%   </CALLOUTLIST>
%</GRAPHICCO>

if isempty(coList)
   coTag=imgTag;
else
    areas={};
    callouts={};
    r=rptcomponent;
    idPrefix=sprintf('callout-id-%10.11f-',now);
    for i=1:size(coList,1)
        coord=coList{i,1};
        thisID=sprintf('%s%i',idPrefix,i);
        thisCoord=sprintf('%i,',coord);
        thisCoord=thisCoord(1:end-1);
        thisText=coList{i,2};
        switch length(coord)
        case 3
            unitType='circle';
        case 4
            unitType='rect';
        otherwise
            unitType='polygon';
        end
        
        if size(coList,2)>2
            attList={'ID',thisID;...
                    'otherunits',unitType;...
                    'coords',thisCoord;...
                    'linkends',coList{i,3}};
        else
            attList={'ID',thisID;...
                    'otherunits',unitType;...
                    'coords',thisCoord};
        end
        
        areas{end+1}=set(sgmltag,...
            'tag','Area',...
            'att',attList,...
            'endtag',logical(0));
        if ~isempty(thisText)
            callouts{end+1}=verifychild(set(sgmltag,...
                'tag','Callout',...
                'data',thisText,...
                'att',{'AreaRefs',thisID}));      
        end
    end
    
    areaspecTag=set(sgmltag,...
        'tag','AreaSpec',...
        'data',areas,...
        'att',{'id',sprintf('clientsidemap-%10.11f',now)});
    if ~isempty(callouts)
        calloutlistTag=set(sgmltag,...
            'tag','CalloutList',...
            'data',callouts);   
    else
        calloutlistTag=[];
    end
    coTag=set(sgmltag,...
        'Tag','graphicco',...
        'Data',{areaspecTag imgTag calloutlistTag});   
end %if isempty(coList)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imgTag=LocGetImgTag(catt,fileName)

if catt.isInline & ...
      isempty(catt.CalloutList) &  ...
      strcmp(catt.isTitle,'none');
   tag='InlineGraphic';
else
   tag='Graphic';
end

imgTag=set(sgmltag,'tag',tag,...
   'att',{'Fileref',fileName},...
   'endtag',0);  %in DocBook 4.0, Graphic and Inlinegraphic are defined as empty


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function caTag=LocGetCaption(att);

if isempty(att.Caption)
   caTag='';
else
   if isempty(findstr(att.Caption,sprintf('\n')))
      pType='Para';
      indent=logical(1);
   else
      pType='LiteralLayout';
      indent=logical(0);
   end
   
   pTag=set(sgmltag,...
      'tag',pType,...
      'data',att.Caption,...
      'indent',indent);
   caTag=set(sgmltag,...
      'tag','BlockQuote',...
      'data',pTag);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ext=LocGetExtension(fName)

dotLoc=findstr(fName,'.');
if length(dotLoc)>0
   ext=fName(dotLoc(end)+1:end);
else
   ext='';
end

