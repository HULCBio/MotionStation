function out=execute(c)
%EXECUTE generate report output
%   OUT=EXECUTE(C);

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:51 $

commentText=parsevartext(c.rptcomponent,c.att.CommentText);

if c.att.isDisplayComment & ~isempty(c.att.CommentText)
   status(c,c.att.CommentText,c.att.CommentStatusLevel);
end


myChildren=children(c);
if length(myChildren)>0
   childTags=runcomponent(myChildren);
else
   childTags='';
end

commentTag=set(sgmltag,...
   'tag','Remark',...
   'data',commentText);

out=set(sgmltag,...
   'issgml',1,...
   'data',{'<!-- ' commentTag childTags '-->'});

%Note that the <comment> tag allows just about anything
%inside of it except <IndexTerm> and <BeginPage>