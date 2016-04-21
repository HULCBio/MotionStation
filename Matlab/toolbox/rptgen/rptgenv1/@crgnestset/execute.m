function out=execute(c)
%EXECUTE generate report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:19 $

%check to see if this setup file has been run nested before

if length(c.att.FileName)>2 & ...
      strncmp(c.att.FileName,'%<',2) & ...
      strncmp(c.att.FileName(end),'>',1)
   evalStr=c.att.FileName(3:end-1);
   try
      c.ref.FileName=evalin('base',evalStr);
   catch
      c.ref.FileName=[];
   end
else
   c.ref.FileName=c.att.FileName;
end

updatepointer(c);

errPriority=1;
if ~ischar(c.ref.FileName)
   s=[];
   ok=0;
   errMsg=sprintf('Error - expression "%s" does not create a valid string',...
      c.att.FileName);
elseif ~isempty(c.ref.FileName)
   nestComponents=findall(c.rptcomponent.stack.h,...
      'flat',...
      'type','uimenu',...
      'tag',class(c));
   nestDepth=length(nestComponents);
   
   recurseCount=0;
   
   for i=1:nestDepth
      refC=rptcp(nestComponents(i));
      recurseCount=recurseCount+...
         strcmp(refC.ref.FileName,c.ref.FileName);
   end
   
   if recurseCount>c.att.RecursionLimit
      errMsg=sprintf(...
         'Nest Setup File recursion limit of %i exceeded. (%s)',...
         c.att.RecursionLimit,...
         c.ref.FileName);
      errPriority=3;
      ok=0;
      s=[];
   else
      [s,ok]=loadsetfile(c,c.ref.FileName);
      errMsg=sprintf('Error - could not load file "%s"', c.ref.FileName );
   end
else
   s=[];
   ok=logical(0);
   errMsg='Error - no nested setup file name specified.';
end

if ok
   newChildren=children(s);
   
   h=currgenoutline(c);
   
   if ishandle(h);
      olstr=outlinestring(s.ref.outlineIndex);
      %protect against going out-of-bounds on listbox
      
      olstr{1}=sprintf('[ -] Nested Setup File - Depth=%s', ...
            num2str(nestDepth));
      
      prevStr=get(h,'String');      
      prevPos=get(h,'Value');
      set(h,...
         'String',olstr,...
         'Value',[]);
   else
      LocWashIndexInfo(newChildren);
   end
   
   if c.att.Inline
      out = generateInlineReport(newChildren);
   else
      reportName=generatereport(s);
      out='';
   end
   
   if ishandle(h)
      set(h,'String',prevStr,'Value',prevPos);
   end
else
   status(c,errMsg,errPriority);
   out='';
end

if isa(s,'rptsp')
   delete(s);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocWashIndexInfo(compList)

for i=1:length(compList)
   compList(i).ref.OutlineIndex=0;
   LocWashIndexInfo(children(subset(compList,i)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=generateInlineReport(coutlineHandle)

try
   methList=getzxxmethodslist(coutlineHandle);
catch
   methList={};
end

numMeth=length(methList);

methObj{numMeth}=[];
oldStored{numMeth}=[];

for i=1:numMeth
   try
      methObj{i}=eval(methList{i});
      
      if ~locIsinitialized(methObj{i})
          %we only initialize things which haven't been
          %initalized yet
	      initialize(methObj{i},coutlineHandle.h);
          %disp(sprintf('Initializing %s',class(methObj{i})));
      else
          %disp(sprintf('%s has already been initialized elsewhere',class(methObj{i})));
          methObj{i}=[];
      end
  catch
      %disp('Error instantiating or initializing an object');
   end
end

outlineChildren=children(coutlineHandle);
out=runcomponent(outlineChildren);

for i=numMeth:-1:1
   if ~isempty(methObj{i})
      try
         %disp(sprintf('Cleaning up after %s',class(methObj{i})));
         cleanup(methObj{i});
      catch
		%disp(sprintf('Cleanup failed for %s',class(methObj{i})));
      end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=locIsinitialized(methObj)

if any(strcmp(methods(class(methObj)),'isinitialized'))
    tf=isinitialized(methObj);
else
    tf=~isempty(rgstoredata(methObj));
end
    





