function SavedData = save(Constr)
%SAVE   Saves constraint data

%   Author(s): Bora Eryilmaz
%   Revised: 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 05:11:02 $

SavedData = struct('OriginPha',  Constr.OriginPha, ...
		   'MarginGain', Constr.MarginGain);
