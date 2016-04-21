function SavedData = save(CompData)
%SAVE   Creates backup of compensator data.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 04:54:31 $

SavedData = struct('Name',CompData.Name,'Model',zpk(CompData));