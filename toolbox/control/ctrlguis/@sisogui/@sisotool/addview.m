function addview(sisodb,ViewID)
%ADDVIEW  Adds a data view to the SISO Tool.
%
%   See also SISOTOOL.

%   Author: P. Gahinet  
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.21 $  $Date: 2002/04/10 04:59:01 $

% Quick exit if no data
if isempty(sisodb.LoopData.Plant.Model)
    return
end

% Find out if requested view already exists
ViewHandle = findview(sisodb,ViewID);

if isempty(ViewHandle)
    % Create requested view
    % REVISIT: workaround segV in sisodb.DataViews(end+1,:) = handle
    Views = sisodb.DataViews;
    switch lower(ViewID)
    case 'clview'
        % Show closed-loop pole data
        Views(end+1,:) = clview(sisodb);
    case 'systemview'
        % Show system data
        Views(end+1,:) = systemview(sisodb);
    case 'historyview'
        % Show command history
        Views(end+1,:) = histview(sisodb);
    end
    sisodb.DataViews = Views;
else
    % Requested view already exists... Just bring it to font
    figure(ViewHandle)
end
