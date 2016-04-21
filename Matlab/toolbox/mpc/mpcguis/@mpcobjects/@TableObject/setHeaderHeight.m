function setHeaderHeight(this, Height)

% Set table's header height.  Only works if the table has already been written.

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2004/04/10 23:37:31 $

import javax.swing.*;
import com.mathworks.toolbox.mpc.*;

Header = this.Table.getTableHeader;
if isempty(Header)
    % Can come here if header hasn't been created yet
    return
end
HeaderSize = Header.getSize;
if round(HeaderSize.height) ~= Height
    this.Table.setHeaderHeight(java.awt.Dimension(HeaderSize.width, Height));
end
