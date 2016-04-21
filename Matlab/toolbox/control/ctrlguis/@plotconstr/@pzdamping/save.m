function SavedData = save(Constr)
%SAVE  Saves constraint data

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 05:10:47 $

SavedData = struct(...
    'Format',Constr.Format,...
    'Damping',Constr.Damping);

    