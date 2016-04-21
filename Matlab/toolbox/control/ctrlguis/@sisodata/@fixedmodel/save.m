function SavedData = save(Component)
%SAVE   Creates backup of model data.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 04:54:58 $

SavedData = struct('Name',Component.Name,'Model',Component.Model);
