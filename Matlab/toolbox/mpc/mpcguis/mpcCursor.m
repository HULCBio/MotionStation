function mpcCursor(Frame, Type)

% MPCCURSOR  Sets a "wait" or "default" cursor on a gui frame.
%            Uses a thread-safe approach.

%	Author:  Larry Ricker
%	Copyright 1986-2003 The MathWorks, Inc. 
%	$Revision: 1.1.6.2 $  $Date: 2004/04/19 01:16:33 $

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;
import java.awt.*;

if isempty(Frame)
    return
end

switch Type
    case 'wait'
        NewCursor = java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.WAIT_CURSOR);
    case 'default'
        NewCursor = java.awt.Cursor.getPredefinedCursor(java.awt.Cursor.DEFAULT_CURSOR);
end

SwingUtilities.invokeLater(MLthread(Frame, 'setCursor', {NewCursor},'java.awt.Cursor'));
