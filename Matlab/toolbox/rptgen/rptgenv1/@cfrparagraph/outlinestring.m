function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:43 $

strout=xlate('Paragraph - ');

numChild=numsubcomps(c);
if strcmp(c.att.TitleType,'subcomp')
   minChild=1;
else
   minChild=0;
end


if numChild > minChild
   postString='<Text from subcomponents>';
else
   if isempty(c.att.ParaText)
      postString='<No Text>';
   else
      switch class(c.att.ParaText)
      case 'char'
         postString=c.att.ParaText(1,:);
      case 'cell'
         postString=c.att.ParaText{1};
      otherwise
         postString='';
      end
   end
end

if length(postString)>32
   dispText=[postString(1:32) '...'];
end



strout=[strout postString];

