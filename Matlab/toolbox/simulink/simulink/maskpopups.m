function popups=maskpopups(block,newPopups)
%MASKPOPUPS Return and change masked block's popup menu items.
%   POPUPS = MASKPOPUPS(BLOCK) returns a cell array which contains in each 
%   element either a cell array of strings or an empty matrix.  In the 
%   first case, a cell array of strings is returned if the mask parameter 
%   is a popup menu, in which case the cell array of strings is a list of 
%   each popup menu command.
%
%   MASKPOPUPS(BLOCK,POPUPS) will change the popup menu strings for the
%   mask parameters to those specified by the cell array POPUPS.  Note
%   that POPUPS is required to contain an element for each mask parmaeter,
%   and those that are not popup parameters are ignored.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 18:24:00 $

%
% if there's a second argument, set the popup strings, otherwise,
% get them
if nargin > 1,
   LocalSetMaskPopups(block,newPopups);
else
   popups = LocalGetMaskPopups(block);
end

% end maskpopups

function LocalSetMaskPopups(block,popups)

%
% get the mask styles and determine which refer to popup menus
%
maskStyles = get_param(block,'MaskStyles');
pops = strncmp(maskStyles,'popup',5);

for i=1:length(maskStyles),
   if pops(i),
      style = popups{i};
      style(2,:) = { '|' };
      style = [ style{:} ];
      style(end)= '';
      maskStyles{i} = [ 'popup(' style ')'];
   end
end

set_param(block,'MaskStyles',maskStyles);

% end LocalSetMaskPopups

function popups = LocalGetMaskPopups(block)
%LOCALGETMASKPOPUPS Return the popup strings for a masked block.

%
% get the mask styles and determine which refer to popup menus
%
maskStyles = get_param(block,'MaskStyles');
pops = strncmp(maskStyles,'popup',5);

popups = cell(size(maskStyles));

%
% loop through each one and for each popup, call the local popup function
% to return a cell aray of strings for the menu
%
for i=1:length(maskStyles),
  if pops(i),
    popStr = maskStyles{i};
    lParen = find(popStr=='(');
    rParen = find(popStr==')');
    popStr([1:lParen(1) rParen(end):end]) = '';
    popups{i} = popup(popStr);
  end
end

% end LocalGetMaskPopups

function pops=popup(popupStr)
%POPUP Return a cell array of strings for a mask popup menu specification.

%
% popups are specified using item1|item2|item3|...|itemN, to turn this into
% a cell array of strings, build an expression that looks like a cell array
% and call eval.  This involves putting {' and '} around the expression,
% and then changing the | to ',' so that it ends up looking like
% {'item1','item2','item3',...'itemN'}
%
popupStr = ['{''' strrep(popupStr,'|',''',''') '''}'];
pops = eval(popupStr);

% end popup
