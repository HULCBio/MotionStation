function ListObject = getBlockList(this);
%getValidBlock

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:35:52 $

import java.lang.* java.awt.* javax.swing.*;

%% Create an empty default list model
ListObject = DefaultListModel;

%% Find all SISO LTI blocks
for ct = 1:length(this.Blocks)
    ListObject.addElement(get_param(this.Blocks(ct).FullBlockName,'Name'));
end
