function out=execute(c)
%EXECUTE generates report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:08 $

scNames={};

indThen=rptcp;
indElseif=rptcp;
indElse=rptcp;
indOther=rptcp;

myChildren=children(c);
for i=1:length(myChildren)
   nowChild=myChildren(i);
   if isa(nowChild,'clothen')
      indThen=[indThen subset(myChildren,i)];
   elseif isa(nowChild,'cloelseif')
      indElseif=[indElseif subset(myChildren,i)];
   elseif isa(nowChild,'cloelse')
      indElse=[indElse subset(myChildren,i)];
   else
      indOther=[indOther subset(myChildren,i)];
   end
end

if isempty(indThen)
   indThen=indOther;
end

if istrue(c)
   if isempty(indThen)
      out=c.att.TrueText;
   else
      out=runcomponent(indThen);
   end
else
   index=1;
   found=logical(0);
   while ~found & index<=length(indElseif)
      if istrue(indElseif(index))
         out=runcomponent(subset(indElseif,index));
         found=logical(1);
      else
         index=index+1;
      end
   end %while
   
   if ~found
      out=runcomponent(indElse);
   end
end