function out=execute(c)
%EXECUTE generates report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:03 $

out=sgmltag;

figHandles=getfigs(c);

oldCurrFig=get(0,'CurrentFigure');

for i=1:length(figHandles)
   if c.rptcomponent.HaltGenerate
      status(c,'Figure Loop execution halted',2);
      break
   end
   
   status(c,sprintf('looping on figure  %s %s',...
         num2str(figHandles(i)),...
         get(figHandles(i),'Name')),3);
   
   c.zhgmethods.Figure=figHandles(i);
   c.zhgmethods.Axes=get(figHandles(i),'CurrentAxes');
   c.zhgmethods.Object=get(figHandles(i),'CurrentObject');
   
   set(0,'CurrentFigure',figHandles(i));
      
   out=[out;runcomponent(children(c))];
end

set(0,'CurrentFigure',oldCurrFig);