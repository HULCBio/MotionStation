function hilitediscblock(item, hilite, children, childrenhilite, forceopen)
%HILITEDISCBLOCK highlights Simulink item.
%	HILITEDISCBLOCK(ITEM, HILITE,CHILDREN,CHILDRENHILITE,FORCEOPEN) Selects or highlights ITEM.
%
%   HILITE -- 0: turn off hilite
%             1: hilite with 'different' scheme
%             2: hilite with 'unique' scheme
%             3: hilite with 'none' scheme
%   FORCEOPEN -- 1: force ITEM visible
%                0: leave ITEM as is

% $Revision: 1.5 $ $Date: 2002/05/18 02:39:51 $
% Copyright 1990-2002 The MathWorks, Inc.


if (~isempty(item))
  try
     dirtyflag = get_param(bdroot(item), 'dirty');
     hiliteItem(item, hilite, children, childrenhilite, forceopen);
     newdirtyflag = get_param(bdroot(item), 'dirty');
     if ~strcmpi(dirtyflag, newdirtyflag)
         set_param(bdroot(item), 'dirty', dirtyflag);
     end     
  catch
      
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HILITEMDITEM highlight Simulink item.
%	HILITEMDITEM(ITEM1, HILITE, CHILDREN) Selects or highlights ITEM 
%      along with all sepcified children
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hiliteItem(item, hilite, children, childrenhilite, forceopen)

if strcmp(get_param(item,'type'),'block_diagram')
    itemType = 'block_diagram';
else
    if strcmpi(get_param(item,'blocktype'),'SubSystem') & strcmpi(get_param(item,'mask'),'off')
        itemType = 'SubSystem';
    else
        itemType = 'block';
    end
end

switch itemType
  
case 'block_diagram'
  window 		      = findSystemWindow(item);	            % Find an open system window in the model.
  if (forceopen)
     if (isempty(window))							                        % No subsystem window is open.
       open_system(item);
     elseif (~strcmp(item, window))
       open_system(item, window, 'browse', 'force');
     end
  end
  
  hiliteChildren(children, childrenhilite);  
  closeScopes(item);
    
case 'SubSystem'
    parent              = get_param(item, 'parent');    
    window            = findSystemWindow(item);             % Find an open system window in the model.
    if(forceopen)
       if (isempty(window))
         model           = bdroot(item);
         open_system(model);
         open_system(parent, model, 'browse', 'force');
       else
         open_system(parent, window, 'browse', 'force');
       end
    end
%     hiliteChildren(children, childrenhilite); 
    hiliteType = getHiliteType(hilite);
    set_param(item, 'hiliteAncestors', hiliteType);
    if (hilite)  
       set_param(item, 'selected', 'on');
    else
      set_param(item, 'selected', 'off');
    end
    
    closeScopes(parent);
  
case 'block'
  parent              = get_param(item, 'parent');
  window              = findSystemWindow(item);             % Find an open system window in the model.
  if (forceopen)
     if (isempty(window))
       model             = bdroot(item);
       open_system(model);
       open_system(parent, model, 'browse', 'force');
     else
       open_system(parent, window, 'browse', 'force');
     end
  end
  
  hiliteType = getHiliteType(hilite);  
  set_param(item, 'hiliteAncestors', hiliteType);
  if (hilite)  
     set_param(item, 'selected', 'on');
  else
    set_param(item, 'selected', 'off');
  end
  closeScopes(parent);
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find a open system window in the given heirarchy that is open.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function window = findSystemWindow(item)

window 				  = [];
parent			      = item;

while (~isempty(parent))
  window			  = find_system(parent, 'BlockType', 'SubSystem', 'open', 'on');
  if (isempty(window))
    window		      = find_system(parent, 'Type', 'block_diagram', 'open', 'on');
  end
  if (~isempty(window))
    window		      = window{1};
    break;
  end
  parent		      = get_param(parent, 'Parent');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close all open scopes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closeScopes(subsystem)

scopeToClose        = find_system(subsystem, 'BlockType', 'Scope');
for i               = 1 : length(scopeToClose)                % Close all open scopes.
  figId             = get_param(scopeToClose{i}, 'figure');
  if (figId > 0)
    set(figId, 'visible', 'off');
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hilite all children blocks for a subsystem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hiliteChildren(children, hilite)
for i               = 1 : length (children)
  child             = children{i};
  hiliteType = getHiliteType(hilite{i});  
 set_param(child, 'hiliteancestors', hiliteType);
end

function hiliteType = getHiliteType(hilite)
   if hilite==2
       hiliteType = 'unique';
   elseif hilite==1
       hiliteType = 'different';
   elseif hilite==3
       hiliteType = 'none';
   else
       hiliteType = 'off';
   end