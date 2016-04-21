function h = tooleditor(Dialog,Container)
%TOOLEDITOR  Constructor for @tooleditor adapter.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $ $Date: 2002/04/10 05:12:49 $

h = plotconstr.tooleditor;
h.Dialog = Dialog;  % @tooldlg handle
h.Container = Container;