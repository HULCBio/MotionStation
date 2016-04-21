function h = LTIsummary(nHor,nVer)

% h = LTIsummary(nHor,nVer)
%
% Construct the LTI model summary object.
% Uses nHor and nVer to set the preferred size

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc. 
%  $Revision: 1.1.8.3 $ $Date: 2003/10/15 18:48:57 $

import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.mpc.*;
import javax.swing.*;
import java.awt.*;

h = mpcobjects.LTIsummary;
jText = JLabel('');
h.jText = jText;
h.jScroll = JScrollPane(jText,JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED,...
    JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
h.jScroll.setPreferredSize(Dimension(nHor,nVer));
h.jScroll.setViewportBorder(BorderFactory.createLoweredBevelBorder);