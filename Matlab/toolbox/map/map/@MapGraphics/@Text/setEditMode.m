function setEditMode(this,edit)
%setEditMode Make Line editable/un-editable.
%
%   setEditMode(EDITING) makes the Text object editable if EDITING is true and
%   un-editable if EDITING is false.  If the Text is editable it can be moved
%   and deleted.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:56:06 $

if edit
  set(this,'ButtonDownFcn',{@editText this});
else
  set(this,'Selected','off','ButtonDownFcn','');
end
this.OldWindowButtonMotionFcn = get(get(get(this,'Parent'),'Parent'),...
                                    'WindowButtonMotionFcn');

function editText(hSrc,event,this)
% Only one item selected at a time.
set(get(get(this,'Parent'),'Children'),'Selected','off');
set(this,'Selected','on');

fig = get(get(this,'Parent'),'Parent');
if strcmp('open',lower(get(fig,'SelectionType')))
  set(this,'Editing','on');
end

% Enable the Cut and Copy menu items
cutMenu = findall(fig,'Label','Cut');
copyMenu = findall(fig,'Label','Copy');
set([cutMenu,copyMenu],'Enable','on');

selType = get(fig,'SelectionType');
if strcmp(selType,'open') % double-click
  inspect(this);
elseif strcmp(selType,'normal') % single click/drag
  set(fig,'Pointer','fleur');
  set(fig,'WindowButtonMotionFcn',{@movetext this});
  set(fig,'WindowButtonUpFcn',{@windowButtonUp this});
end

function movetext(hSrc,event,this)
oldunits = get(this,'Units');
set(this,'Units','data');
p = get(get(this,'Parent'),'CurrentPoint');
p = [p(1) p(3) 0];
set(this,'Position',p);
set(this,'Units',oldunits);

function windowButtonUp(hSrc,event,this)
fig = get(get(this,'Parent'),'Parent');
set(fig,'WindowButtonMotionFcn',this.OldWindowButtonMotionFcn);
set(fig,'Pointer','arrow');
















