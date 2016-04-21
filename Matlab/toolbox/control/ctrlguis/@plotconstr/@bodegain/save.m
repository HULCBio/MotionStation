function SavedData = save(Constr)
%SAVE  Saves constraint data

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 05:08:01 $

SavedData = struct(...
    'Frequency',Constr.Frequency,...
    'Magnitude',Constr.Magnitude,...
    'Type',Constr.Type);