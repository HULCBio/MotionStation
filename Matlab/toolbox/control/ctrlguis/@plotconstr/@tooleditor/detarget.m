function detarget(h,Constr)
%DETARGET  Detargets edit dialog when deleting constraint.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:13:04 $

% RE: h = @tooleditor handle

if isequal(h.Container,h.Dialog.Container)
    % Deleted constraint belongs to currently targeted container: retarget as appropriate
    h.Dialog.target(h.Container);
end

