% update_rtb
%   This function update rate transition block icon.
%


%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/09 19:36:29 $
function update_rtb(block)
  local_set_icon(block);

% set the icon
%
function icon=local_set_icon(block)
  
  position = get_param(block, 'position');
  size     = [position(3)-position(1), position(4)-position(2)];
  fontsize = get_param(block, 'FontSize');
  if (fontsize == -1)
    fontsize = get_param(bdroot, 'DefaultBlockFontSize');
  end;
  
  if (any(size<35))
    icon = local_mini_icon; 
  else
    icon = ['image(imread(''', 'rt', '.bmp'',''bmp''),''center'')'];
  end;
  
  if (~isempty(icon))
    set_param(block, 'MaskDisplay', sprintf(icon));
  end;

%
% set the mini icon
%
function icon = local_mini_icon()
  icon = ['text(0.4, 0.5, ''Ts'')'];