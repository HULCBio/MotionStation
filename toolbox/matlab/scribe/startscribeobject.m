function startscribeobject(objtype,fig)
%STARTSCRIBEOBJECT Initialize insertion of annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

% At first time creation load scribe classes to speed up
% subsequent creation. Perhaps some helper functions could
% do this in other places, too.
persistent firsttime;
if isempty(firsttime)
  firsttime = 0;
  set(fig,'pointer','watch');
  % load scribe classes
  dummy = scribe.scriberect(fig); delete(dummy);
  dummy = scribe.scribeellipse(fig); delete(dummy);
  dummy = scribe.line(fig); delete(dummy);
  dummy = scribe.arrow(fig); delete(dummy);
  dummy = scribe.doublearrow(fig); delete(dummy);
  dummy = scribe.textarrow(fig); delete(dummy);
  dummy = scribe.textbox(fig); delete(dummy);
end
plotedit(fig,'on');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));

objtypes = {'rectangle','ellipse','textbox','doublearrow','arrow','textarrow','line'};
tindex = find(strcmpi(objtype,objtypes));
if isempty(tindex)
    error('MATLAB:startscribeobject.unknownobjecttype','unknown object type');
end

% turn off other toggles
t = cell(1,8);
t{1} = uigettoolbar(fig,'Annotation.InsertRectangle');
t{2} = uigettoolbar(fig,'Annotation.InsertEllipse');
t{3} = uigettoolbar(fig,'Annotation.InsertTextbox');
t{4} = uigettoolbar(fig,'Annotation.InsertDoubleArrow');
t{5} = uigettoolbar(fig,'Annotation.InsertArrow');
t{6} = uigettoolbar(fig,'Annotation.InsertTextArrow');
t{7} = uigettoolbar(fig,'Annotation.InsertLine');
t{8} = uigettoolbar(fig,'Annotation.Pin');
for k=1:7
    if k~=tindex && ~isempty(t{k})
        set(t{k},'state','off');
    end
end
% be sure pinning is off
startscribepinning(fig,'off');
% set scribeax interactive create mode
if tindex> 0 && tindex<6
    scribeax.InteractiveCreateMode = 'on';
end
set(fig,'WindowButtonDownFcn',{graph2dhelper('scribemethod'),fig,'wbdown',tindex});
set(fig,'WindowButtonMotionFcn','');
set(fig,'pointer','crosshair');
