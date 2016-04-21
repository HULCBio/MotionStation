function v = getVisible(this)
%GETVISIBLE Return visible property of layer.
%
%   V = GETVISIBLE returns 'on' if the layer is visible or 'off' otherwise.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:16 $

v = this.Visible;


%if strcmp(lower(this.Visible),'on')
%  v = true;
%elseif strcmp(lower(this.Visible),'off')
%  v = false;
%end

