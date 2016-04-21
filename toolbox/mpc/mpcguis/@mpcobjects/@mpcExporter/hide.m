function hide(this)

% HIDE
%
% Hide the mpcExporter dialog

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2004/04/16 22:09:35 $

if ~isempty(this.Handles)
    % Dialog panel needs to be created
    awtinvoke(this.Handles.Dialog,'setVisible',false);
end
