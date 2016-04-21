function [h]=tempfigure(m)
%TEMPMFIGURE returns handles to a temporary figure

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:50 $

uniqTag='Report Generator Temporary Figure';

found=findall(allchild(0),'Tag',uniqTag);
if ~isempty(found)
   h=get(found(1),'UserData');
else
   h.Figure=figure('Visible','off',...
      'IntegerHandle','off',...
      'Tag',uniqTag,...
      'HandleVisibility','off');
   
   figchild={'Axes','Uicontrol','Uimenu','Uicontextmenu'};
   for i=1:length(figchild)
      h=setfield(h,figchild{i},feval(lower(figchild{i}),...
         'Parent',h.Figure));
   end
   
   axchild={'Image' 'Light' 'Line' 'Patch' 'Surface' 'Text'};
   for i=1:length(axchild)
      h=setfield(h,axchild{i},feval(lower(axchild{i}),...
         'Parent',h.Axes));
   end
   set(h.Figure,'UserData',h);
end