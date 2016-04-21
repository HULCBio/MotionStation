function savtoner( state, fig )
%SAVTONER Modify figure to save printer toner.
%   SAVTONER(STATE,FIG) modifies the color of graphics objects to print
%   them on a white background (thus saving printer toner).  STATE is
%   either 'save' to set up colors for a white background or 'restore'.
%   If the Color property of FIG is 'none', nothing is done.
%
%   SAVTONER(STATE) operates on the current figure.
%
%   See also NODITHER, PRINT.

%   When printing your Figure window, it is not usually dersirable
%   to draw using the background color of the Figure and Axes. Dark
%   backgrounds look good on screen but tend to over-saturate the
%   output page. SAVTONER will Change the Color, MarkerFaceColor,
%   MarkerEdgeColor, FaceColor, and EdgeColor property values of all 
%   objects and the X, Y, and Z Colors of all Axes to black if the 
%   Figure and Axes are not already white. SAVTONER will also restore
%   the original colors of the objects with the correct input argument.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.46.4.3 $  $Date: 2004/04/10 23:29:15 $

persistent SaveTonerOriginalColors;

if nargin == 0 ...
        | ~isstr( state ) ...
        | ~(strcmp(state, 'save') | strcmp(state, 'restore'))
    error('SAVTONER needs to know if it should ''save'' or ''restore''')
elseif nargin ==1
    fig = gcf;
end

%for use in sub-functions
global NONE FLAT
NONE = [NaN NaN 0];
FLAT = [NaN 0 NaN];
BLACK = [0 0 0];
WHITE = [1 1 1];

if strcmp( state, 'save' )
	  
    origFigColor = get(fig,'color');
    saveOrigFigColor = get(fig,'color');
	  
	if isequal( get(fig,'color'), 'none')
	   saveOrigFigColor = [NaN NaN NaN];
	end

	origFigWhite = 0;
    if isequal(WHITE, saveOrigFigColor)
    	origFigWhite = 1;
	end
    	   
    %Initialize all counts
    count.color = 0;
    count.facecolor = 0;
    count.edgecolor = 0;
    count.markeredgecolor = 0;
    count.markerfacecolor = 0;
    
    allAxes = findobj(fig,'type','axes');
    naxes = length(allAxes);
    for axnum = 1:naxes
        a = allAxes(axnum);
        origAxesColor = get(a,'color');
        chil = allchild(a);
        axesVisible = strcmp(get(a,'visible'), 'on');
        
        % Exclude Axes labels from chil because they are handled as a special
        % case below since they lie outside of the axes.
        excludedH = get(a, {'xlabel';'ylabel';'zlabel';'title'});
        excludedH = cat(1, excludedH{:})'; % turn cell array into row vector
        for hLabel = excludedH
            chil(find(chil == hLabel)) = []; % remove excluded handles
        end
        
        %Early exit criteria
        if isempty(chil) | (axesVisible & isequal(origAxesColor,WHITE)) ...
                | ((~axesVisible | strcmp(origAxesColor,'none')) & origFigWhite)
            
            % Do nothing
        else
            %Objects properties that are W will goto K to stay contrasting and those
            %  that match the ultimate background color goto W to stay invisible.
            if ~axesVisible | strcmp(origAxesColor,'none')
                bkgrndColor = origFigColor;
            else
                bkgrndColor = origAxesColor;
            end
            
            count.color = count.color + length(findobj(chil,'color',WHITE,'Visible','on'));
            count.facecolor = count.facecolor + length(findobj(chil,'facecolor',WHITE,'Visible','on'));
            count.edgecolor = count.edgecolor + length(findobj(chil,'edgecolor', WHITE,'Visible','on'));
            count.markeredgecolor = count.markeredgecolor + length(findobj(chil,'markeredgecolor',WHITE,'Visible','on'));
            count.markerfacecolor = count.markerfacecolor + length(findobj(chil,'markerfacecolor',WHITE,'Visible','on'));
            
            count.color = count.color + length(findobj(chil,'color', bkgrndColor,'Visible','on'));
            count.facecolor = count.facecolor + length(findobj(chil,'facecolor', bkgrndColor,'Visible','on'));
            count.edgecolor = count.edgecolor + length(findobj(chil,'edgecolor', bkgrndColor,'Visible','on'));
            count.markeredgecolor = count.markeredgecolor + length(findobj(chil,'markeredgecolor', bkgrndColor,'Visible','on'));
            count.markerfacecolor = count.markerfacecolor + length(findobj(chil,'markerfacecolor', bkgrndColor,'Visible','on'));
            
                        
        end  
        
        %Handle special case 
        %The Axes labels and title are outside the bounds of the
        %Axes and therefore contrastness needs to be checked with
        %the Figure.
        if ~origFigWhite  
            %Determine the number of labels which are white so that they 
            %can be changed to black before printing
            count.color = count.color + length( findobj( ...
                [get(a,'xlabel') get(a,'ylabel') get(a,'zlabel') get(a,'title') ], ...
                'flat', 'color', WHITE ,'Visible','on')' );
            %Determine the number of labels which are the same color as the figure window 
            %so that they can be changed to white before printing
            count.color = count.color + length( findobj( ...
                [get(a,'xlabel') get(a,'ylabel') get(a,'zlabel') get(a,'title') ], ...
                'flat', 'color', origFigColor ,'Visible','on')' );
        end
        
    end
    
    %Initialize counts based on color we now know we have to change
    storage.figure = [fig saveOrigFigColor];
    storage.axes = zeros(naxes,13);
    storage.color = zeros(count.color,4);
    storage.facecolor = zeros(count.facecolor,4);
    storage.edgecolor = zeros(count.edgecolor,4);
    storage.markeredgecolor = zeros(count.markeredgecolor,4);
    storage.markerfacecolor = zeros(count.markerfacecolor,4);
    
    turnMe.color = zeros(count.color,4);
    turnMe.facecolor = zeros(count.facecolor,4);
    turnMe.edgecolor = zeros(count.edgecolor,4);
    turnMe.markeredgecolor = zeros(count.markeredgecolor,4);
    turnMe.markerfacecolor = zeros(count.markerfacecolor,4);
    
    idx.color = 1;
    idx.facecolor = 1;
    idx.edgecolor = 1;
    idx.markeredgecolor = 1;
    idx.markerfacecolor = 1;
    
    for axnum = 1:naxes
        a = allAxes(axnum);
        chil = allchild(a);
        
        % Exclude Axes labels from chil because they are handled as a special
        % case below since they lie outside of the axes.
        excludedH = get(a, {'xlabel';'ylabel';'zlabel';'title'});
        excludedH = cat(1, excludedH{:})'; % turn cell array into row vector
        for hLabel = excludedH
            chil(find(chil == hLabel)) = []; % remove excluded handles
        end
        
        axesVisible = strcmp(get(a,'visible'), 'on');
        origAxesColor = get(a,'color');
        axc = get(a,'xcolor');
        ayc = get(a,'ycolor');
        azc = get(a,'zcolor');
        aXYZc = [axc ayc azc];  
        if ~axesVisible | strcmp(origAxesColor,'none')
            bkgrndColor = origFigColor;
        else
            bkgrndColor = origAxesColor;
        end
        
        storage.axes(axnum,:) = [a color2matrix(origAxesColor) aXYZc];
        
        %Early exit criteria
        if (axesVisible & isequal(origAxesColor,WHITE)) ...
                | ((~axesVisible | strcmp(origAxesColor,'none')) & origFigWhite)
            
            % Do nothing
        else
            %Objects properties that are W will goto K to stay contrasting and those
            %  that match the ultimate background color goto W to stay invisible.
            
            if (~strcmp(origAxesColor, 'none'))
                set(a,'color',WHITE)
            end
            
            for obj = findobj(chil,'color',WHITE,'Visible','on')'
                storage.color(idx.color,:) = [obj WHITE];
                turnMe.color(idx.color,:) = [obj BLACK];
                idx.color = idx.color + 1;
            end
            
            for obj = findobj(chil,'color', bkgrndColor,'Visible','on')'
                storage.color(idx.color,:) = [obj bkgrndColor];
                turnMe.color(idx.color,:) = [obj WHITE];
                idx.color = idx.color + 1;
            end
            
            %Face and Edge colors need to be considered together
            for obj = [findobj(chil,'type','surface','Visible','on') ; ...
                       findobj(chil,'type','patch','Visible','on') ; ...
                       findobj(chil,'type','rectangle','Visible','on')]'
                fc =  get(obj,'facecolor');
                ec =  get(obj,'edgecolor');
                if isequal( fc, bkgrndColor )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setfaceedge( obj, WHITE, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setfaceedge( obj, WHITE, WHITE, storage, turnMe, idx );
                    else,                              [storage, turnMe, idx] = setfaceedge( obj, WHITE, NaN, storage, turnMe, idx );
                    end
                    
                elseif isequal( fc, WHITE )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setfaceedge( obj, BLACK, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, 'none' ),      [storage, turnMe, idx] = setfaceedge( obj, BLACK, NaN, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setfaceedge( obj, NaN, BLACK, storage, turnMe, idx );
                    end
                    
                elseif isequal( fc, BLACK )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setfaceedge( obj, WHITE, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, 'flat' ),      [storage, turnMe, idx] = setfaceedge( obj, WHITE, NaN, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setfaceedge( obj, WHITE, BLACK, storage, turnMe, idx );
                    end
                    
                elseif isequal( fc, 'none' )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setfaceedge( obj, NaN, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setfaceedge( obj, NaN, WHITE, storage, turnMe, idx );
                    end
                    
                else %Face is 'flat' or RGB triplet
                    if isequal( ec, WHITE ) | isequal( ec, bkgrndColor )
                        [storage, turnMe, idx] = setfaceedge( obj, NaN, BLACK, storage, turnMe, idx );
                    end
                    
                end 
            end %face and edgecolor loop
            
            %Marker Face and Edge colors also need to be considered together
            for obj = [ findobj(chil,'type','line','Visible','on') ; ...
                        findobj(chil,'type','surface','Visible','on') ; ...
                        findobj(chil,'type','patch','Visible','on') ]'
                fc =  get(obj,'markerfacecolor');
                ec =  get(obj,'markeredgecolor');
                if isequal( fc, bkgrndColor )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setmfaceedge( obj, WHITE, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setmfaceedge( obj, WHITE, WHITE, storage, turnMe, idx );
                    else,                              [storage, turnMe, idx] = setmfaceedge( obj, WHITE, NaN, storage, turnMe, idx );
                    end
                    
                elseif isequal( fc, WHITE )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setmfaceedge( obj, BLACK, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, 'none' ),      [storage, turnMe, idx] = setmfaceedge( obj, BLACK, NaN, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setmfaceedge( obj, NaN, BLACK, storage, turnMe, idx );
                    end
                    
                elseif isequal( fc, BLACK )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setmfaceedge( obj, WHITE, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setmfaceedge( obj, WHITE, BLACK, storage, turnMe, idx );
                    end
                    
                elseif isequal( fc, 'none' )
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setmfaceedge( obj, NaN, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setmfaceedge( obj, NaN, WHITE, storage, turnMe, idx );
                    end
                    
                else %Face is RGB triplet
                    if isequal( ec, WHITE ),           [storage, turnMe, idx] = setmfaceedge( obj, NaN, BLACK, storage, turnMe, idx );
                    elseif isequal( ec, bkgrndColor ), [storage, turnMe, idx] = setmfaceedge( obj, NaN, WHITE, storage, turnMe, idx );
                    end
                    
                end 
            end %marker face and edge color loop
        end          
        
        %Handle special case #2
        %The Axes labels and title are outside the bounds of the
        %Axes and therefore contrastness needs to be checked with
        %the Figure.
        if ~origFigWhite
            %The labels that are white need to be set to black before printing.
            %After printing they need to be set back to their original color, white.
            for obj = findobj( [get(a,'xlabel') get(a,'ylabel') get(a,'zlabel') get(a,'title') ], 'flat', 'color', WHITE ,'Visible','on')'
                storage.color(idx.color,:) = [obj WHITE];
                turnMe.color(idx.color,:) = [obj BLACK];
                idx.color = idx.color + 1;
            end
            
            %The labels that are the same color as the Figure Window need to be
            %set to white before printing.  These labels don't appear on screen
            %and should not appear on the printout.
            for obj = findobj( [get(a,'xlabel') get(a,'ylabel') get(a,'zlabel') get(a,'title') ], 'flat', 'color', origFigColor ,'Visible','on')'
                storage.color(idx.color,:) = [obj origFigColor];
                turnMe.color(idx.color,:) = [obj WHITE];
                idx.color = idx.color + 1;
            end
        end
        
    end %for each Axes
    
    %Sets the axes labels color for printing
    
    for k = 1:count.color
        if ~strcmp( 'light', get(turnMe.color(k,1), 'type') )
            set(turnMe.color(k,1),'color',turnMe.color(k,2:4));
        end
    end
    
    
    % Adjust the axes object's XColor, YColor, and ZColor
    % When setting axis color, make sure label isn't affected.
    % This needs to occur after the label colors are set otherwise in 
    % some cases the axis color will reset the label color incorrectly.
        
    % A FOR loop is necessary so that all WHITEBG subplots are updated
    % correctly.  
    
    for axnum = 1:naxes
        a = allAxes(axnum);
        
        axc = get(a,'xcolor');
        ayc = get(a,'ycolor');
        azc = get(a,'zcolor');
        
        labelH = get(a,'xlabel');
        labelColor = get(labelH,'color');
        if (isequal(axc,origFigColor))
            set(a,'xcolor',WHITE)
        elseif (isequal(axc,WHITE))
            set(a,'xcolor',BLACK)
        end
        set( labelH, 'color', labelColor )
        
        labelH = get(a,'ylabel');
        labelColor = get(labelH,'color');
        if (isequal(ayc,origFigColor))
            set(a,'ycolor',WHITE)
        elseif (isequal(ayc,WHITE))
            set(a,'ycolor',BLACK)
        end
        set( labelH, 'color', labelColor )
        
        labelH = get(a,'zlabel');
        labelColor = get(labelH,'color');
        if (isequal(azc,origFigColor))
            set(a,'zcolor',WHITE)
        elseif (isequal(azc,WHITE))
            set(a,'zcolor',BLACK)
        end
        set( labelH, 'color', labelColor )
    end
    
    %Face and Edge color matrices may not be fully filled out
    used = find( turnMe.facecolor(:,1) );
    if ~isempty( used )
        storage.facecolor(used(end)+1:end,:) = [];
        for k = used'
            set(turnMe.facecolor(k,1),'facecolor',turnMe.facecolor(k,2:4));
        end
    else
        storage.facecolor = [];
    end
    used = find( turnMe.edgecolor(:,1) );
    if ~isempty( used )
        storage.edgecolor(used(end)+1:end,:) = [];
        for k = used'
            set(turnMe.edgecolor(k,1),'edgecolor',turnMe.edgecolor(k,2:4));
        end
    else
        storage.edgecolor = [];
    end
    
    %Marker Face and Edge color matrices may not be fully filled out
    used = find( turnMe.markerfacecolor(:,1) );
    if ~isempty( used )
        storage.markerfacecolor(used(end)+1:end,:) = [];
        for k = used'
            set(turnMe.markerfacecolor(k,1),'markerfacecolor',turnMe.markerfacecolor(k,2:4));
        end
    else
        storage.markerfacecolor = [];
    end
    used = find( turnMe.markeredgecolor(:,1) );
    if ~isempty( used )
        storage.markeredgecolor(used(end)+1:end,:) = [];
        for k = used'
            set(turnMe.markeredgecolor(k,1),'markeredgecolor',turnMe.markeredgecolor(k,2:4));
        end
    else
        storage.markeredgecolor = [];
    end
    
    % It might become important that this is LAST
    set(fig,'color',WHITE);
    
    SaveTonerOriginalColors = storage;
    
else % Restore colors
    
    orig = SaveTonerOriginalColors;
    
    origFig = orig.figure(1);
    origFigColor = orig.figure(2:4);
	if (sum(isnan(origFigColor)) == 3)
		origFigColor = 'none';
	end
    set(origFig,'color',origFigColor);
    
    for k = 1:size(orig.axes,1)
        a = orig.axes(k,1);
        set(a,'color',matrix2color(orig.axes(k,2:4)))
        
        %When setting axis color, make sure label isn't affected.
        labelH = get(a,'xlabel');
        labelColor = get(labelH,'color');
        set(a,'xcolor',orig.axes(k,5:7))
        set( labelH, 'color', labelColor )
        
        labelH = get(a,'ylabel');
        labelColor = get(labelH,'color');
        set(a,'ycolor',orig.axes(k,8:10))
        set( labelH, 'color', labelColor )
        
        labelH = get(a,'zlabel');
        labelColor = get(labelH,'color');
        set(a,'zcolor',orig.axes(k,11:13))
        set( labelH, 'color', labelColor )
    end
    
    for k = 1:size(orig.color,1)
        obj = orig.color(k,1);
        set(obj,'color',matrix2color(orig.color(k,2:4)))
    end
    
    for k = 1:size(orig.facecolor,1)
        obj = orig.facecolor(k,1);
        set(obj,'facecolor',matrix2color(orig.facecolor(k,2:4)))
    end
    
    for k = 1:size(orig.edgecolor,1)
        obj = orig.edgecolor(k,1);
        set(obj,'edgecolor',matrix2color(orig.edgecolor(k,2:4)))
    end
    
    for k = 1:size(orig.markeredgecolor,1)
        obj = orig.markeredgecolor(k,1);
        set(obj,'markeredgecolor',matrix2color(orig.markeredgecolor(k,2:4)))
    end
    
    for k = 1:size(orig.markerfacecolor,1)
        obj = orig.markerfacecolor(k,1);
        set(obj,'markerfacecolor',matrix2color(orig.markerfacecolor(k,2:4)))
    end
end

clear global NONE FLAT


%-------------------
function [storage, turnMe, idx] = setfaceedge( obj, newFace, newEdge, storage, turnMe, idx )
%SETFACEEDGE Set both FaceColor and EdgeColor and update structures

if ~isnan(newFace)
    storage.facecolor(idx.facecolor,:) = [obj color2matrix(get(obj,'facecolor')) ];
    turnMe.facecolor(idx.facecolor,:) = [obj newFace];
    idx.facecolor = idx.facecolor + 1;
end

if ~isnan(newEdge)
    storage.edgecolor(idx.edgecolor,:) = [obj color2matrix(get(obj,'edgecolor')) ];
    turnMe.edgecolor(idx.edgecolor,:) = [obj newEdge];
    idx.edgecolor = idx.edgecolor + 1;
end


%-------------------
function [storage, turnMe, idx] = setmfaceedge( obj, newFace, newEdge, storage, turnMe, idx )
%SETMFACEEDGE Set both MarkerFaceColor and MarkerEdgeColor and update structures

if ~isnan(newFace)
    storage.markerfacecolor(idx.markerfacecolor,:) = [obj color2matrix(get(obj,'markerfacecolor')) ];
    turnMe.markerfacecolor(idx.markerfacecolor,:) = [obj newFace];
    idx.markerfacecolor = idx.markerfacecolor + 1;
end

if ~isnan(newEdge)
    storage.markeredgecolor(idx.markeredgecolor,:) = [obj color2matrix(get(obj,'markeredgecolor')) ];
    turnMe.markeredgecolor(idx.markeredgecolor,:) = [obj newEdge];
    idx.markeredgecolor = idx.markeredgecolor + 1;
end


%-------------------
function color = color2matrix( color )
%COLOR2MATRIX Return a 1x3 for any color, including strings 'flat' and 'none'
%   Uses globals NONE and FLAT

global NONE FLAT

if isequal(color, 'none' )
    color = NONE;
    
elseif isequal(color, 'flat' )
    color = FLAT;
    
end


%-------------------
function color = matrix2color( color )
%MATRIX2COLOR Return a Color-spec for any a 1x3, possibly encoded for 'flat' and 'none'.
%   Uses globals NONE and FLAT

global NONE FLAT

if isequal(isnan(color), isnan(NONE) )
    color = 'none';
    
elseif isequal(isnan(color), isnan(FLAT) )
    color = 'flat';
    
end


