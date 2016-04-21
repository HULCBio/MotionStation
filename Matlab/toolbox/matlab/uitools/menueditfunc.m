function varargout = menueditfunc(whichcall, varargin)
%MENUEDITFUNC  Support function for GUIDE menu editor

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.3 $  $Date: 2004/04/10 23:34:00 $

  switch whichcall
    case 'getMenuStructure'
      menuRoot = newMenuNode;
      cmnuRoot = newMenuNode;
      show = get(0, 'showhiddenhandles');
      set(0, 'showhiddenhandles', 'on');
      tail = getMenuStructure(varargin{1}, menuRoot, 1, 0,0);
      tail = getMenuStructure(varargin{1}, cmnuRoot, 1, 1,tail);
      set(0, 'showhiddenhandles', show);
      varargout{1} = requestJavaAdapter(varargin{1});
      varargout{2} = menuRoot;
      varargout{3} = cmnuRoot;
      varargout{4} = num2str(tail);

    case 'doNewMenu'
      parent = varargin{1};
      label = varargin{2};
      newMenu = uimenu(parent, 'label', label);
      set(newMenu,'callback',AUTOMATIC);
      set(newMenu,'tag',strrep(label,' ', '_'));
      adapter = requestJavaAdapter(newMenu);
      varargout{1} = newMenuNode(1, newMenu, adapter, getProperty(newMenu));
      varargout{2} = adapter;
      varargout{3} = requestJavaAdapter(parent);

    case 'doNewContextMenu'
      parent = varargin{1};
      tag = varargin{2};
      newCMenu = uicontextmenu('parent', parent, 'tag', tag);
      set(newCMenu,'callback',AUTOMATIC);
      set(newCMenu,'tag',strrep(tag,' ', '_'));
      adapter = requestJavaAdapter(newCMenu);
      varargout{1} = newMenuNode(2, newCMenu, adapter,getProperty(newCMenu));
      varargout{2} = adapter;
      varargout{3} = requestJavaAdapter(parent);

    case 'getCMenuData'
      [varargout{1}, varargout{2}] = getCMenuData(varargin{1});

    case 'doSetProperty'
      menu = varargin{1};
      if ishandle(menu)
          set(menu,varargin{2},varargin{3});
      end

    case 'doGetProperty'
      varargout{1} = getProperty(varargin{1});
        
    case 'doMoveUp'
      fig = varargin{1};
      item = varargin{2};
      parent = get(item,'Parent');
      if (parent == fig)
        % move in the same group
        uistack(item,'down');
      else
        children = allchild(parent);
        location = find(ismember(children,item));

        if (location + 1 <= length(children))
            % move in the same group
            uistack(item,'down');
        else
            % move out of the current group
            % move in the next group
           parents = findobj(get(get(parent,'parent'),'Children'), 'flat', 'type', get(parent,'type'));
           plocation = find(ismember(parents,parent));
           set(item,'parent',parents(plocation+1));

           uistack(item,'top');
        end
      end

      varargout{1} = 0;

    case 'doMoveDown'
      fig = varargin{1};
      item = varargin{2};
      parent = get(item,'Parent');
      if (parent == fig)
        % move in the same group
        uistack(item,'up');
      else
        children = allchild(parent);
        location = find(ismember(children,item));

        if (location - 1 >= 1)
            % move in the same group
            uistack(item,'up');
        else
            % move out of the current group
            % move in the next group
           parents = findobj(get(get(parent,'parent'),'Children'), 'flat', 'type', get(parent,'type'));
           plocation = find(ismember(parents,parent));
           set(item,'parent',parents(plocation-1));

           uistack(item,'bottom');
        end
      end

      varargout{1} = 0;

    case 'doMoveBackward'
      fig = varargin{1};
      item = varargin{2};
      parent = get(item,'Parent');

      parents = findobj(get(get(parent,'parent'),'Children'), 'flat', 'type', get(parent,'type'));
      plocation = find(ismember(parents,parent));
      set(item,'parent',get(parent,'parent'));

      uistack(item,'bottom');

      uistack(item,'up', length(parents)+1 - plocation);

      varargout{1} = 0;

    case 'doMoveForward'
      fig = varargin{1};
      item = varargin{2};
      parent = get(item,'Parent');

      children = findobj(get(parent,'Children'), 'flat', 'type', get(item,'type'));
      mylocation = find(ismember(children,item));
      set(item,'parent',children(mylocation + 1));

      uistack(item,'top');

      varargout{1} = 0;
      
    case 'viewCallback'
      guidefunc('editCallback',varargin{:});
     
  end

%************************************************
function start = getMenuStructure(handle, node, isRoot, isCMenu, startNum)
  start=startNum;
  if (isCMenu)
    % get the uicontextmenus
    if (isRoot)
      menus = findobj(allchild(handle), 'flat', 'type', 'uicontextmenu');
      for i = length(menus):-1:1
        adapter = requestJavaAdapter(menus(i));
        child = newMenuNode(2, menus(i), adapter,getProperty(menus(i)));
        node.addChild(child);
        tail = getUntitledTail(menus(i));
        if (tail > start)
            start = tail;
        end
        start = getMenuStructure(menus(i), child, 0, 0, start);
      end
    end
  else
    if (isRoot)
      menus = findobj(allchild(handle), 'flat', 'type', 'uimenu', 'serializable', 'on');
    else
      menus = get(handle, 'children');
    end

    % get the uimenus
    for i = length(menus):-1:1
      adapter = requestJavaAdapter(menus(i));
      child = newMenuNode(1, menus(i), adapter,getProperty(menus(i)));
      node.addChild(child);
        tail = getUntitledTail(menus(i));
        if (tail > start)
            start = tail;
        end
      start = getMenuStructure(menus(i), child, 0, 0, start);
    end
  end

%************************************************
% have to use the fully qualified path to
% MenuNode because just using MenuNode(type, adapter)
% attempts to call a method "MenuNode" on the
% object "adapter", rather than calling the constructor
% of "MenuNode" with "adapter" as an argument
function node = newMenuNode(varargin)
  if (nargin == 0)
    node = com.mathworks.ide.layout.menueditor.MenuNode;
  else
    node = com.mathworks.ide.layout.menueditor.MenuNode(varargin{1}, ...
                                                        varargin{2}, ...
                                                        varargin{3}, ...
                                                        varargin{4});
  end

%************************************************
function [names, handles] = getCMenuData(adapter)
  fig = getEnclosingFigure(double(handle(adapter)));
  handles = findobj(allchild(fig), 'flat', 'type', 'uicontextmenu');
  names = get(handles, 'tag');

%************************************************
function fig = getEnclosingFigure(fig)
  while ~isempty(fig) & ~strcmp(get(fig, 'type'), 'figure'),
    fig = get(fig, 'parent');
  end;

function str = AUTOMATIC
str = '%automatic';

function tail = getUntitledTail(handle)

tail=0;
tag = [];
try tag = get(handle,'Tag'); end
if (~isempty(tag))
    where = findstr('Untitled',tag);
    wherel = findstr('Untitled_',tag);
    if (~isempty(wherel))
        number = str2num(tag(length('Untitled_')+1:length(tag)));
        if (~isempty(number) & number > tail)
            tail = number;
        end
    else
        if (~isempty(where))
            number = str2num(tag(length('Untitled')+1:length(tag)));
            if (~isempty(number) & number > tail)
                tail = number;
            end
        end
    end
end

tag = [];
try tag = get(handle,'Label'); end
if (~isempty(tag))
    where = findstr('Untitled',tag);
    wherel = findstr('Untitled_',tag);
    if (~isempty(wherel))
        number = str2num(tag(length('Untitled_')+1:length(tag)));
        if (~isempty(number) & number > tail)
            tail = number;
        end
    else
        if (~isempty(where))
            number = str2num(tag(length('Untitled')+1:length(tag)));
            if (~isempty(number) & number > tail)
                tail = number;
            end
        end
    end
end

function out = getProperty(handle)

properties = get(handle);
name = fieldnames(properties);
value = get(handle,name)';

out = {name value};