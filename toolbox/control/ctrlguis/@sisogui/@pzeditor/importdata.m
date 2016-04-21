function importdata(Editor)
%IMPORTDATA  Syncs up PZ editor data with main database.

%   Author: P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 04:55:25 $

% Sync up with pole/zero data of edited object
% RE: triggers editor update
if isempty(Editor.EditedObject.PZGroup)
    Editor.PZGroup = zeros(0,1);
else
    % Import new data
    Editor.PZGroup = copy(Editor.EditedObject.PZGroup); 
end

% Clear all Delete check boxes
HG = Editor.HG;
if ~isempty(HG)
    set([HG.ZeroEdit(:,1);HG.PoleEdit(:,1)],'Value',0)
end
