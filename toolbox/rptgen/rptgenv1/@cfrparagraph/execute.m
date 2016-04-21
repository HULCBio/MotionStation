function out=execute(c)
%EXECUTE report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:41 $

myChildren=children(c);
numChild=length(myChildren);

switch c.att.TitleType
case 'subcomp'
   startComp=2;
   if numChild>0
      myTitle=runcomponent(subset(myChildren,1));
   else
      myTitle='';
   end
case 'specify'
   myTitle=parsevartext(c.rptcomponent,c.att.ParaTitle);
   startComp=1;
otherwise %'none'
   myTitle='';
   startComp=1;
end

if numChild >= startComp
    if startComp>1
        out=set(sgmltag,'tag','para',...
            'data',runcomponent(subset(myChildren,[startComp:numChild])));
    else
        out=set(sgmltag,'tag','para',...
            'data',runcomponent(myChildren));
    end
else
   out=set(sgmltag,'tag','para',...
      'data',parsevartext(c.rptcomponent,c.att.ParaText));
end

if ~isempty(myTitle)
   titleTag=set(sgmltag,...
      'tag','Title',...
      'data',myTitle);
   out=set(sgmltag,...
      'tag','FormalPara',...
      'data',{titleTag out});
end