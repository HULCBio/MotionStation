function target(h,Constr)
%TARGET  Points edit dialog to a particular constraint.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:12:58 $

% RE: h = @tooleditor handle

% Retarget tooldlg to appropriate container/constraint
h.Dialog.target(h.Container,Constr);
