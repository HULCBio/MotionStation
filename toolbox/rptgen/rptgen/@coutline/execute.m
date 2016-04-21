function ReportName=execute(c)
%EXECUTE generate report output
%   REPORTNAME=EXECUTE(COUTLINE) Generates a report.
%   All report components are children of the COUTLINE component.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:23 $

%status(c,['Generating report from ' c.rptcomponent.SetfilePath],3);

if c.att.isDebug
   c.rptcomponent.DebugMode=logical(1);
   errWarn.WarnState='on';
   errWarn.DbstopCond={'error','warning'};
   oldWarn=nenw(c,errWarn);
else
   c.rptcomponent.DebugMode=logical(0);
   oldWarn=nenw(c);
end

c.rptcomponent.Format=c.att.Format;

[c,bookTag]=LocCreateOutput(c);

allChild=children(c);
for j=1:length(allChild)
   if ~LocWriteOutput(c,...
         char(sgmltag(runcomponent(subset(allChild,j)))));
      status(c,'Error! Writing output file failed.',1);
   end
end

LocInsertEnd(c,bookTag);

%Pop currently generating figure to the top
olH=currgenoutline(c);
if ishandle(olH)
   figure(get(olH,'Parent'));
end

if ~c.rptcomponent.HaltGenerate
   if ~ischar(c.att.Format)
      formatString='';
   else
      formatString=lower(c.att.Format);
   end
   
   status(c,...
      sprintf('Beginning %s output transform (this may take a moment)',...
	  formatString),...
      3);
   
   %Perform actual conversion
   [ReportName,messages]=convertoutputfile(c);
   LocInsertMessages(c,messages);
   
   %Show post-conversion status messages
   if isempty(ReportName)
      status(c,'Error - Output transform failed',1);
   else
      status(c,'Output transform complete.',3);
      
      if c.rptcomponent.ScanDocumentForImports
          status(c,'Importing external documents',3);
          if javaMethod('scanDocumentForImports',...
                  'com.mathworks.toolbox.rptgencore.docbook.FileImporter',...
                  ReportName);
              status(c,'Done importing external documents',3);
          else
              status(c,'Error importing external documents',1);    
          end
      end
      
      status(c,sprintf('Output file is "%s".',ReportName),3);
   end
else
   ReportName='';
end

if c.att.isView & ...
      ~c.rptcomponent.HaltGenerate & ...
      ~isempty(ReportName)
   [ok,msgString]=rptviewfile(ReportName);
   LocInsertViewMessages(c,ok,msgString);
else
   status(c,'View file cancelled.',3);
end

if ~isempty(c.att.PostGenerateFcn) & ...
        ~c.rptcomponent.HaltGenerate & ...
        ~isempty(ReportName)
    pgf=strrep(c.att.PostGenerateFcn,'%<ReportName>',ReportName);
    evalin('base',pgf,'warning(''Error evaluating PostGenerateFcn'');');
end


status(c,'Report complete',3);

nenw(c,oldWarn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ok=LocWriteOutput(c,outString)

ok=logical(1);
if ~isempty(outString)
   fid = fopen(c.ref.SourceFileName,'a');
   if fid>0
      try
         numchar=fprintf(fid,outString);
      catch
         ok=logical(0);
      end    
      result=fclose(fid);
      if result<0
         ok=logical(0);
      end
   else
      ok=logical(0);
   end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [c,bookTag]=LocCreateOutput(c)

%create output document

[rDir,rName,rExt,c]=getrptname(c);
%by returning c from getrptname, we are setting 
%            c.ref.SourceFileName=DIR/FILE .sgml
%            c.ref.ReportFileName=DIR/FILE EXT;
%            c.rptcomponent.ReportDirectory=DIR;
%            c.rptcomponent.ReportFilename=FILE;
%            c.rptcomponent.ReportExt=EXT;

[bookTag,titleTag]=LocGetBookTag(c.ref.ID,c.rptcomponent);

head=['<!DOCTYPE ' bookTag ' PUBLIC "-//OASIS//DTD DocBook V4.0//EN"> \n'...  
      '<' bookTag '>' titleTag '\n'];

ok=logical(0);
fid = fopen(c.ref.SourceFileName,'w');
if fid>0
   printCount=fprintf(fid,head);
   ok=(printCount>0);
   fclose(fid);
end

if ~ok
   status(c,{sprintf('Error - can not write file %s.',c.ref.SourceFileName ); ...
         sprintf('Check your directory permissions and output file name.')},1);
   c.rptcomponent.HaltGenerate=logical(1);
else
    ok=checkWritableFile(c,c.ref.ReportFileName);
end


if ok
   %if c.att.isRegenerateImages is turned on, we want to 
   %clear out previously generated images and the image
   %database.
   
   % These images can only exist if the
   % local report images directory exists.
   
   imgDir=fullfile(rDir,...
      [c.rptcomponent.ReportFilename '_' ...
         c.rptcomponent.ReportExt '_' 'files']);
   
   if exist(imgDir,'dir')>0
      c.rptcomponent.ImageDirectory=imgDir;
      
      if c.att.isRegenerateImages
         safeFiles={};
      else
         safeFiles=getimgname(c,'$ReorderFiles');
      end
      
      dirFiles=dir([c.rptcomponent.ImagePreface,'*.*']);
      if ~isempty(dirFiles)
          allFiles=strcat([imgDir filesep],{dirFiles.name});
          
          if ~isempty(safeFiles)
              delFiles=setdiff(allFiles,safeFiles);         
          else
              delFiles=allFiles;
          end
          
          for i=1:length(delFiles)
              delete(delFiles{i});        
          end %delete each image file
      end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ok=checkWritableFile(c,reportFileName)
%CHECKWRITABLEFILE
%  Check to make sure the output file name is
%  writable - most critical when going to RTF
%  and file may be locked by application

try
    prevExist=(exist(reportFileName,'file')==2);
    
    %Append the currently existing report so that if
    %we halt generation anytime before the transform
    %the original report won't be blown away.
    fid=fopen(reportFileName,'a');
    fprintf(fid,' ');
    ok=logical(fclose(fid)+1);
    
    if ~prevExist
        %If the file did not exist before the writable check, 
        %delete it so that we return to the same state.  Some
        %unix systems with 'noclobber' turned on will have 
        %trouble with HTML conversion calls that use redirection.
        try
            delete(reportFileName);
        catch
		    status(c,{sprintf('Warning - problem creating file %s.',reportFileName); ...
 	           'Report may not be able to convert.'},2);
        end
    end
catch
    status(c,{sprintf('Error - can not write file %s.',reportFileName); ...
            'File may be write protected - check file permissions'; ...
            'File may be in use - make sure file is not locked by any applications.'},1);
    c.rptcomponent.HaltGenerate=logical(1);
    ok=logical(0);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocInsertEnd(c,bookTag)

foot=['</' bookTag '>'];
ok=LocWriteOutput(c,foot);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocInsertMessages(c,messages);
%displays the messages created by JADE
%in the generation status window

for i=1:length(messages)
    line=messages{i};
    if isempty(findstr(line,'Link to missing ID'))
        %The "Link to missing ID" error is common and expected
        %we don't include it in the debug list
        colons=findstr(line,':');
        if ~isempty(colons)
            character=line(colons(length(colons))-1);
            switch upper(character)
            case 'E'
                priority=1;
            case 'W'
                priority=2;
            case 'I'
                priority=5;
            case 'X'
                priority=7;
            otherwise
                priority=4;
            end
        else
            priority=1;
        end   
        status(c,line,priority)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   LocInsertViewMessages(c,ok,msgString);
%displays the messages created by RPTVIEWFILE
%in the generation status window

if ok
   priority=4;
else
   priority=1;
end

status(c,msgString,priority);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bookTag,titleTag]=LocGetBookTag(pointerID,r);
%LocGetBookTag determines if there are any Chapter/Subsection
%components as children of coutline.
%If there are no chapter/Subsection components
%and there are no nested setup files, the report
%should be wrapped in a Sect1 component.  Otherwise the
%report will be wrapped inside a book component.


sectPointer=[];
nestPointer=[];

if isa(pointerID,'rptcp')
   h=pointerID.h;
   if ishandle(h)
      sectPointer=findall(h,...
         'type','uimenu',...
         'tag','cfrsection');
      nestPointer=findall(h,...
         'type','uimenu',...
         'tag','crgnestset');
   end
end

if length(sectPointer)==0 & ...
      length(nestPointer)==0
   bookTag='Sect1';
   titleTag='<Title>&nbsp;</Title>';
   r.DocBookSectionCounter=[0 0];
else
   bookTag='Book';
   titleTag='';
   r.DocBookSectionCounter=[0];
end
titleTag=[titleTag '<?html-filename ' r.ReportFilename '.html>'];

r.DocBookDoctype=bookTag;
