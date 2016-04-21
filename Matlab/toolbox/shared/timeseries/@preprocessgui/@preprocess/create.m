function create(h, withclose)
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:32:44 $

% Apply and OK java button callback to create modified data set
if isempty(h.TargetNode)
    errordlg('No destination node has been defined', 'Data Preprocessing Tool',...
        'modal')
else    
	% Build new data set and refresh everything. Note that the "srcisjava"
    % flag is set to true since the source of this event is the java 
    % apply button, so the java side is aleady updated. Changing
    % srcisjava to false will create a race condition
	newdataset = h.update(h.ManExcludedpts{h.Position},true);
 
    % Modify the headings/labels with an additional *
    headings = h.Datasets(h.Position).Headings;
    newheadings = cell(1,length(headings));
    for k=1:length(headings)
        
        thisheading = localdeblank(headings{k});
        
        if length(thisheading)>=1 && thisheading(end)~='*'
            newheadings{k} = [thisheading '*'];
        else
            newheadings{k} = thisheading;
        end
    end
    
    % Check that the specified variables are valid and not in the workspace
    set(newdataset,'Name',h.Datasets(h.Position).Name,'datavariable',...
        h.Datasets(h.Position).datavariable, 'timevariable',...
        h.Datasets(h.Position).timevariable, 'Headings',newheadings);
    
    
    % Add the new dataset to the gui object at the end because it 
    % should be complete when SPE listeners use it to add a new node to the tree
    h.Newdatasets = newdataset;
       
end

function strout = localdeblank(strin)

% Eliminate starting and ending blanks and check for zero length
strout = deblank(strin(end:-1:1));
strout = deblank(strout(end:-1:1));
