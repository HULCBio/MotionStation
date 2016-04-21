function close(h,varargin)
%CLOSE  Hides dialog.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $ $Date: 2002/04/10 05:09:22 $

h.Handles.Frame.setVisible(0);
h.Client = [];
h.Constraint = [];
