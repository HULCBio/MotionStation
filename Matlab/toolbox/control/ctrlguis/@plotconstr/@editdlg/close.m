function close(h,varargin)
%CLOSE  Hides dialog.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:08:58 $

if h.isVisible
    h.Handles.Frame.setVisible(0);
    h.Constraint = [];
end