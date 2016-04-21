function out=execute(c)
%EXECUTE produces output from the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:48 $

%d=getsectiondepth(c);

sectCounter=c.rptcomponent.DocBookSectionCounter;
d=min(length(sectCounter),length(c.ref.allTypes));
if ~isfield(c.ref,'allTypes')
   c.ref.allTypes=i.ref.allTypes;
end
tagName=c.ref.allTypes{d,1};

sectCounter(end)=sectCounter(end)+1;

out=set(sgmltag,...
   'tag',tagName,...
   'data',LocMakeFileName(sectCounter,c.rptcomponent));

if strcmp(c.att.NumberMode,'manual')
	sectLabel = parsevartext(c.rptcomponent,c.att.Number);
	out = set(out,'att',{'label',sectLabel});
end

c.rptcomponent.DocBookSectionCounter=[sectCounter 0];

myChildren=children(c);
if c.att.isTitleFromSubComponent & ...
      length(myChildren)>0   
   out=[out;...
         LocInsertTitle(tagName,runcomponent(subset(myChildren,1)))];
   subStart=2;
else
   out=[out;LocInsertTitle(tagName,parsevartext(c.rptcomponent,c.att.SectionTitle))];
   subStart=1;
end

nChild=length(myChildren);
if nChild<subStart
    sectContent={};
elseif subStart==1
    sectContent=runcomponent(myChildren);
else
    sectContent=runcomponent(subset(myChildren,[subStart:nChild]));
end

if locIsEmpty(sectContent)
    switch tagName
    case {'','Para'}
        sectContent='&nbsp;';
    otherwise
        sectContent=set(sgmltag,'tag','Para','data','&nbsp;');
    end
end

%Note: we could have an option to the effect of
%"don't include empty sections in the report"
out=[out;sectContent];


c.rptcomponent.DocBookSectionCounter=sectCounter;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function titleTag=LocInsertTitle(sectionName,titleName);

switch sectionName
case {'','Para'}
   tagName='Para';
otherwise
   tagName='Title';
end

titleTag=set(sgmltag,...
   'tag',tagName,...
   'data',titleName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fName=LocMakeFileName(sectCounter,r)

d=length(sectCounter);
if d>2 | d<1
   fName='';
else
   if d==2
      sectString=sprintf('-sect1-%d',sectCounter(2));
   else
      sectString='';
   end
   
   fString=sprintf('?html-filename %s-chap-%d%s.html',...
      r.ReportFilename,...
      sectCounter(1),...
      sectString);
   
   fName=set(sgmltag,'tag',fString,'endtag',0);
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=locIsEmpty(sectContent)

if isempty(sectContent)
    tf=logical(1);
elseif iscell(sectContent)
    %we can't use cellfun('isempty') here because
    %it is important to call overloaded isempty on sgmltags
    tf=logical(1);
    cLen=length(sectContent);
    i=1;
    while i<=cLen & tf
        tf=locIsEmpty(sectContent{i});
        i=i+1;
    end
else
    tf=logical(0);
end
