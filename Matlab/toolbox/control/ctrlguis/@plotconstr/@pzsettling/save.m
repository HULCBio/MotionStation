function SavedData = save(Constr)
%SAVE  Saves constraint data

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 05:08:40 $

SavedData = struct(...
    'SettlingTime',Constr.SettlingTime);

    