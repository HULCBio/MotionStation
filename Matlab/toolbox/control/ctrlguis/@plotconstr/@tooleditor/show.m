function show(h,Constr)
%SHOW  Points edit dialog to a particular constraint.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:12:55 $

% RE: h = @tooleditor handle

% Retarget tooldlg to appropriate container/constraint
h.Dialog.show(h.Container,Constr);
