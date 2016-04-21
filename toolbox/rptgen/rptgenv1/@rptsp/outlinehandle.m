function h=outlinehandle(p,allProps,cbString);
%OUTLINEHANDLE - handle of setup file editor outline

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:27 $

if nargin<3
   cbString='rgstoregui';
   if nargin<2
      allProps=struct('Parent',p.h,...
         'Units','points',...
         'HandleVisibility','off');
   end
end

s=get(p,'UserData');
if isa(s,'rptsetupfile')
   h=s.ref.OutlineHandle;
   if isempty(h) | ~ishandle(h)
      h=LocBuildOutline(allProps,cbString);
      s.ref.OutlineHandle=h;
      set(p,'UserData',s);
   end   
else
   h=LocBuildOutline(allProps,cbString);
end

set(h,'UserData',p.h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=LocBuildOutline(allProps,cbString)

h = uicontrol(allProps,...
   'BackgroundColor',[1 1 1], ...
   'Interruptible','off',...
   'HitTest','off',...
   'Callback',...
   ['doguiaction(',cbString,',''SelectOutline'');'],...
   'String',{'[ -] Report - Unnamed.rpt'},...
   'Style','listbox', ...
   'Tag','OutlineListbox', ...
   'Max',2,'Min',0,...
   'Value',1);