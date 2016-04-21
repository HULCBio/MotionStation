function SavedData = save(Constr)
%SAVE   Saves constraint data

%   Author(s): Bora Eryilmaz
%   Revised: 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 05:11:38 $

SavedData = struct('OriginPha', Constr.OriginPha, ...
		   'PeakGain',  Constr.PeakGain);
