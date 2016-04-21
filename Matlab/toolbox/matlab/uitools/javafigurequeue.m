function javafigurequeue(flag)
%JAVAFIGUREQUEUE Changes how Java Figures behave in regarding to whether
%using SwingUtilities directly and/or creating Java Figures asynchronously.
%   JAVAFIGUREQUEUE(FLAG) 
%
%  FLAG is an integer whose value can be empty or is one of the following.
%       0: Using Java Figure queue instead of SwingUtilities'.
%          Creating Java Figures asynchronously. This is the default.
%       1: Using Java Figure queue instead of SwingUtilities'.
%          Creating Java Figures synchronously.
%       2: Using SwingUtilities' invokeLater.
%          Creating Java Figures asynchronously.
%       3: Using SwingUtilities' invokeLater.
%          Creating Java Figures synchronously.

% Copyright 1984-2003 The MathWorks, Inc.

import com.mathworks.hg.util.*;

if nargin == 0
    flag = 0;
end

if (flag <0 | flag>3)
    return;
end

usingqueue = true;
synchronous = false;
switch flag
    case 0
    case 1
        synchronous = true;        
    case 2
        usingqueue = false;
    case 3
        usingqueue = false;
        synchronous = true;        
end

HGUtils.setUsingHGPeerQueue(usingqueue);
HGUtils.setMakingFigureCallSynchronous(synchronous);
