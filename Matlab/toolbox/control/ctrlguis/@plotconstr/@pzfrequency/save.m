function SavedData = save(Constr)
%SAVE  Saves constraint data

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 05:10:17 $

SavedData = struct(...
    'Frequency',Constr.Frequency,...
    'Type',Constr.Type);

    