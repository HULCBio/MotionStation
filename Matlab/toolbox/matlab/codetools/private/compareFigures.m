function figuresToSnap = compareFigures(oldFigures)
%COMPAREFIGURES	Compare figures to baseline.
%   FIGURESTOSNAP lists the figures that are different from the baseline

% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/04/10 23:24:45 $

% The publishing tools and Notebook uses this 

% Set this global variable and PUBLISH displays debugging info.
global PUBLISHING_DEBUGGING_FLAG
if isempty(PUBLISHING_DEBUGGING_FLAG)
    debug = false;
else
    debug = PUBLISHING_DEBUGGING_FLAG;
end

figuresToSnap = [];

% Capture the new state
figureList = flipud(findall(0,'type','figure','visible','on'));
for figureListNumber = 1:length(figureList)
    fig = figureList(figureListNumber);
    pos = find([oldFigures.number] == fig);
    if isempty(pos)
        figuresToSnap(end+1) = fig;
        if debug
            disp(['New figure.  Snapping #' num2str(fig) '.'])
        end
    else
        oldObjectList = oldFigures(pos).objectList;
        oldProperties = oldFigures(pos).properties;
        newObjectList = findall(fig);
        figureChanged = false;
        if isequal(oldObjectList,newObjectList)
            for i = 1:length(oldObjectList)
                newProperties = get(newObjectList(i));
                switch newProperties.Type
                    case 'figure'
                        newProperties.CurrentPoint = 'IGNORE';
                        % The windowing system can move a figure after it is
                        % created, so ignore the position of the figure on the
                        % screen.
                        newProperties.Position(1) = 0;
                        newProperties.Position(2) = 0;
                        % The figure dimensions are also not reliable.  See 
                        % g197164 for more information.
                        newProperties.Position(3) = 0;
                        newProperties.Position(4) = 0;
                    case 'text'
                        % Extent is unreliable, yet unneeded.  See g143468.
                        newProperties.Extent = 'IGNORE';
                end
                if ~isidentical(oldProperties{i},newProperties)
                    figureChanged = true;
                    if debug
                        disp(['Property changed.  Snapping #' num2str(fig) '.'])
                        oldValues = oldProperties{i};
                        newValues = newProperties;
                        structdiff(oldValues,newValues)
                    end
                    break;
                end
            end
        else
            figureChanged = true;
            if debug
                disp(['Object list changed.  Snapping #' num2str(fig) '.'])
                removed = setdiff(oldObjectList,newObjectList);
                if ~isempty(removed)
                    disp('Removed objects:')
                    disp(removed)
                end
                new = get(setdiff(newObjectList,oldObjectList),'type');
                if ~isempty(new)
                    disp('New objects:')
                    disp(new)
                end
            end
        end
        % Tally the figures that are different from the baseline
        if figureChanged
            figuresToSnap(end+1) = fig;
        end
    end
end

% If it is empty, this M-file probably created it.  Clean it up.
if isempty(PUBLISHING_DEBUGGING_FLAG)
    clear global PUBLISHING_DEBUGGING_FLAG
end

%===============================================================================
function structdiff(s1,s2);
n1 = inputname(1);
n2 = inputname(2);
f1 = fieldnames(s1);
f2 = fieldnames(s2);

for i = 1:length(f1);
    if isempty(strmatch(f1{i},f2))
    	disp(sprintf('Only in %s: %s',n1,f1{i}));
    end
end

for i = 1:length(f2);
    if isempty(strmatch(f2{i},f1))
    	disp(sprintf('Only in %s: %s',n2,f2{i}));
    end 
end

for i = 1:length(f1);
    if ~isempty(strmatch(f1{i},f2))
        v1 = getfield(s1,f1{i});
        v2 = getfield(s2,f1{i});
        if ~isequalwithequalnans(v1,v2)
            disp(sprintf('In %s, %s = ',n1,f1{i}));
            disp(v1);
            disp(sprintf('In %s, %s = ',n2,f1{i}));
            disp(v2);
        end
    end
end
