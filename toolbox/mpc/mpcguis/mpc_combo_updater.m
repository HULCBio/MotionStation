function mpc_combo_updater(Combo,List,SelectedItem)

%  mpc_combo_updater(Combo,List,SelectedItem)
%
% Refresh the information displayed in a combo box.
% Combo = MJComboBox handle
% List = Cell array of strings containing the items to be displayed in
%        the combo box.
% SelectedItem = string specifying item to be selected.

%	Copyright 1986-2003 The MathWorks, Inc. 
%	$Revision: 1.1.6.2 $  $Date: 2004/04/19 01:16:34 $
%   Author:  Larry Ricker

import javax.swing.*;
import java.awt.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.mpc.*;

if nargin < 3
    SelectedItem = [];
end

% Clear the combo box
SwingUtilities.invokeLater(MLthread(Combo, 'removeAllItems',{}));

ItemFound = false;
for i = 1:length(List)
    % Make sure SelectedItem is in List
    if strcmp(List{i}, SelectedItem)
        ItemFound = true;
    end
    % Add item to combo box
    SwingUtilities.invokeLater(MLthread(Combo, 'addItem', ...
        {java.lang.String(List{i})},'java.lang.Object'));
end
if isempty(SelectedItem)
    % Don't attempt to set the selected item if the input wasn't supplied
    return
end
if ~ItemFound
    Message = sprintf('Item "%s" was not in ComboBox List', SelectedItem);
    error(Message);
else
    SwingUtilities.invokeLater(MLthread(Combo, 'setSelectedItem', ...
        {java.lang.String(SelectedItem)},'java.lang.Object'));
end
