function setJavaLogical(JavaObject,Method,Value)

% Utility to set a Java swing object's state in a thread-safe manner.
% The java Method must take a boolean input argument.

%	Author:  Larry Ricker
%	Copyright 1986-2003 The MathWorks, Inc. 
%	$Revision: 1.1.8.3 $  $Date: 2004/04/19 01:16:35 $

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

if Value
    SwingUtilities.invokeLater(MLthread(JavaObject,Method,{true},'boolean'));
else
    SwingUtilities.invokeLater(MLthread(JavaObject,Method,{false},'boolean'));
end