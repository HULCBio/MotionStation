function show(this)

% SHOW
%
% Display the mpcExporter dialog

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2004/04/16 22:09:36 $

if isempty(this.Handles)
    % Dialog panel needs to be created
    this.createObjectExporter;
    this.Handles.Dialog.setLocation(java.awt.Point(20,20));
end
awtinvoke(this.Handles.Dialog,'setVisible',true);
