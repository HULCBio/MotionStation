function out=execute(c)
%EXECUTE returns a string during generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:31 $

out = [];

rptgenSF = c.zsfmethods;
id = rptgenSF.currentObject.id;
idTargetObject=id;
type = rptgenSF.currentObject.type;
typeStr = rptgenSF.currentObject.typeString;
% see if this object has enough children to deserve a picture
if rgsf( 'can_have_children', typeStr )
	% do this check only if appropriate.
	numberOfChildren = length(eval( 'sf( ''ObjectsIn'', id )', '[]' ));
	if numberOfChildren < c.att.picMinChildren
		return;
	end
end
imageSizing = c.att.imageSizing;

imDir = c.rptcomponent.ImageDirectory;
image = rptgenSF.propTable(type+1).image;
%imFormat = c.att.imageFormat;
imFormat = c.att.ImageFormat;
imStruct = getimgformat( c, imFormat );

% see if we should report the image
drawInfo = rptgenSF.currentLoop.drawInfo;

if image.imagePresent & ...
        (drawInfo.numLegibleKids( drawInfo.map( id ) ) > 0   | ...
        drawInfo.legibleIn( drawInfo.map( id ) ) == id )
    % do not draw the image if both are true:
    % 1. I look fine on my ancestor's picture 
    % 2. I have no children that I make legible
    
    if type == rgsf( 'type2num', 'junction' ) | ...
            type == rgsf( 'type2num', 'transition' ) | ...
            type == rgsf( 'type2num', 'note' )
        uniqueName = '';
    else
        uniqueName = sf( 'FullNameOf', id );
    end
    
    
    
    [fullImageName, imNew] = getimgname( c, imStruct, 'sf', uniqueName  );
    if imNew
        sfPortal = rptgenSF.sfportal;
        
        figH = sf('get',sfPortal,'.figH');
        
        rptgenSF.currentObject.hiddenContent = 1;
        
        pointers = drawInfo.pointers;
        pointers = pointers{drawInfo.map(id)};
        if c.att.isCallouts & ~isempty(pointers)
            vMargin=[25 25 25 25];
            usePointers=logical(1);
            %set margins for callouts
            %note that portal margins are [top, right, bottom, left]
        else
            vMargin=[5,5,5,5];
            usePointers=logical(0);
        end
        
        %setting the .viewObject is not smart enough to deal with
        %the case that the axis might be too small.  Make the figure
        %large enough so that the axes will have a width and height
        %greater than 0.  The reshape function (later) will size the
        %figure correctly.
        figPos = get(figH,'Position'); %presumably in same units as margin
        minHeight = vMargin(1) + vMargin(3)+60;
        minWidth  = vMargin(2) + vMargin(4)+60;
        if figPos(3)<minWidth | figPos(4)<minHeight 
            figPos(3)=minWidth;
            figPos(4)=minHeight;
            set(figH,'Position',figPos);
        end
        
        %clear out selection in chart
        switch type
            %case rgsf('type2num','machine')
            %noop - no graphical representation
        case rgsf('type2num','chart')
            sf('Select', id , []);
        otherwise
            chartID = sf('get',id,'.chart');
            sf('Select',chartID,[]);
        end
        
        sf('set',sfPortal,...
            '.viewObject',id,...
            '.margin',vMargin,...
            '.vis',c.rptcomponent.DebugMode);
        
        if strcmp( imageSizing,'manual')
            minFontSize=0;
        else
            minFontSize=rptgenSF.legibleSize;
        end
        
        pDims=c.att.PrintSizePoints;
        imSize=reshape_portal(sfPortal, minFontSize, pDims(1), pDims(2));
        
        axH = sf('get',sfPortal,'.axesH');
        axsXlim = get( axH, 'xlim' ); xd = axsXlim(2)-axsXlim(1);
        axsYlim = get( axH, 'ylim' ); yd = axsYlim(2)-axsYlim(1);
        axsPos  = get(axH,'position');
        ovlXlim = [ axsXlim(1) - vMargin(4) * xd/axsPos(3),...
                axsXlim(2) + vMargin(2) * xd/axsPos(3) ];
        ovlYlim = [ axsYlim(1) - vMargin(1) * yd/axsPos(4),...
                axsYlim(2) + vMargin(3) * yd/axsPos(4) ];
        
        sfCoords = [ ovlXlim(1), ovlYlim(1), ovlXlim(2)-ovlXlim(1), ovlYlim(2)-ovlYlim(1) ];
        if usePointers
            coCoords = position_pointers( pointers, sfCoords, imSize,axH );
        else
            coCoords=[];
        end

        %expand the background rectangle to fill the figure
        rectH = sf('get',sfPortal,'.backgroundH');
        set(rectH,'Position',sfCoords);
        set(figH,'inverthardcopy','off','color',[1 1 1]);

        %NOTE: I would like to be using -dpainters here, but both -painters
        %and -opengl are having problems with the internal renderer.  Geck 81740
        if iscell( imStruct.options )
            print( figH, imStruct.driver, imStruct.options{:}, '-zbuffer',fullImageName);
        else % imstruct.options is a string
            print( figH, imStruct.driver, imStruct.options, '-zbuffer', fullImageName);
        end
        
        if usePointers
            delete(findall(axH,'tag','csf_snapshot/callout'));
        end
    else
        sfCoords=[0 0 1 1];
        imSize=[1 1];
        coCoords=[];
    end
   %create the CalloutList

   [ppx,ppy]=pointsperpixel(c);
   %set up links for callout list
   if ~isempty(coCoords)
       linkComp = c.rptcomponent.comps.cfrlink;
       att = linkComp.att;
       att.LinkType = 'Link';
       
       for i=size(coCoords,1):-1:1
           id=coCoords(i,1);
           linkID = sf('get',id,'.rgTag');
           
           %column 1 = pixel coordinates of link
           calloutList{i,1}=round([coCoords(i,2:3)/ppx,coCoords(i,4:end)*ppx]);
           
           %column 2 = name for list text (optional)
           att.LinkID   = linkID;
           att.LinkText = rgsf( 'get_sf_obj_name', id );
           linkComp.att = att;
           calloutList{i,2} = runcomponent(linkComp,0);
           
           %column 3 = linkID for imagemap (optional)
           calloutList{i,3}= linkID;
       end
   else
       calloutList = cell(0,3);
   end

   %set up direct-click links
   coLen=size(calloutList,1);
   for i = length(pointers):-1:1
       id = pointers{i}{1};
       pos = pointers{i}{2}; 
       pos=[pos(1:2),pos(1:2)+pos(3:4)];
       
       %transform pos to image coords
       scaleMult=[imSize(1)/sfCoords(3), imSize(2)/sfCoords(4)];
       scaleAdd=[sfCoords(1),sfCoords(2)];
       
       pos(1:2:end-1)=(pos(1:2:end-1)-sfCoords(1))*(imSize(1)/sfCoords(3))/ppx;
       pos(2:2:end)  =(pos(2:2:end)  -sfCoords(2))*(imSize(2)/sfCoords(4))/ppy;
       
       calloutList{i+coLen,1} = round(pos);
       %leaving the second column empty will prevent a text list from being created
       calloutList{i+coLen,3} = sf('get',id,'.rgTag');
       
       %Note that transitions have their position recorded as a single point,
       %so direct-click links aren't terribly useful for them.
   end
   
   switch c.att.TitleType
   case 'none'
       iTitle='';
   case 'objname'
       iTitle = rgsf( 'get_sf_obj_name', idTargetObject );
   case 'fullsfname'
       iTitle = sprintf('%s/%s',...
           rgsf( 'get_sf_full_name', sf('ParentOf',idTargetObject),'/',''),...
           rgsf( 'get_sf_obj_name', idTargetObject ));
   case 'fullslsfname'
       iTitle = sprintf('%s/%s',...
           sf('FullNameOf', sf('ParentOf',idTargetObject),'/'),...
           rgsf( 'get_sf_obj_name', idTargetObject ));
   case 'manual'
       iTitle = parsevartext(c,c.att.TitleString);
   end
   
   imgComp = c.rptcomponent.comps.cfrimage;

   att = imgComp.att;
   att.FileName = fullImageName;
   if ~isempty(iTitle)
       att.isTitle='local';
       att.Title=iTitle;
   else
       att.isTitle='none';
   end
   att.CalloutList = calloutList;
   att.isIncrementFileName = logical(0);
   imgComp.att= att;
   
	out = runcomponent(imgComp, 0);
else
	out = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = axs2fig( pt, figH, axsH )
%
% the function translates the axes coordinate into normalized figure coords
%
figPos = get( figH, 'Position' );
axsPos = get( axsH, 'Position' );
xlim = get( axsH, 'xlim' ); xd = xlim(2)-xlim(1);
ylim = get( axsH, 'ylim' ); yd = ylim(2)-ylim(1);
% both axes and figure size are in points
x = axsPos(1) + (pt(1)-xlim(1))*axsPos(3)/xd;
y = axsPos(2) + (pt(2)-ylim(1))*axsPos(4)/yd;

res = [ x, y ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function coCoords = position_pointers(pointers, sfCoords, imageCoords, axH )
%pointers
%sfCoords - axes coordinates of full figure - x y w h
%imageCoords - the total size of the image - w h;
%axH - handle to parent axes
%
%coCoords - column 1 = SF ID.  column 2-end: callout position X,Y,R

% first, find out how many pointers we can have with this image size
tagLength = 3;
scale = sfCoords(3)/imageCoords(1);
fontSize = 12*scale;
arrowHeadSize = 3*scale;
tagLengthPix = fontSize * 0.65 * ( tagLength );
tagHeightPix = fontSize * 2.1;
imW = imageCoords(1);
imH = imageCoords(2);

numHorTags  = floor( sfCoords(3) / tagLengthPix );
numVertTags = floor( sfCoords(4) / tagHeightPix );
totalTags = 2 * ( numHorTags + numVertTags );
ptrsToSkip = 0;
if totalTags < length( pointers )
    % have to reduce the number of pointers
    %warning( 'Too many objects to be pointed to. Dropping some of them.' );
    ptrsToSkip = length( pointers ) - totalTags;
end
% now we know that the number of requested pointers is less than or equal to
% the number of available spaces

coCoords=zeros(0,4);
if length( pointers ) > 0
    % calculate tag positions now, to save time later
    tagSpaceLeft = (sfCoords(3) - numHorTags * tagLengthPix)/2;
    for tagNo = 1:numHorTags*2
        if tagNo < numHorTags+1 %top
            yTag = sfCoords( 2 ) + fontSize*1.3;
            labelPosYOffset = -fontSize*1.1;
        else %bottom
            yTag = sfCoords(2) +sfCoords(4) - fontSize*1.5;
            labelPosYOffset = fontSize*0.1;			
        end
        %yTag = -floor( tagNo / (numHorTags+1) ) * (h+10) + spaceLeft + 5;
        xTag = sfCoords(1) + ...
            tagLengthPix * ( rem( tagNo-1, numHorTags ) + 0.5 ) + tagSpaceLeft;
        labelPos = [xTag - tagLengthPix * 0.3, yTag + labelPosYOffset];
        tagCoords{tagNo} = {[xTag, yTag], labelPos };
    end
    
    for tagNo = numHorTags*2+1:totalTags
        tagNo1 = tagNo - numHorTags * 2;
        %xTag = ( 1 - floor( tagNo1 / (numVertTags+1) ) ) * (w+leftMargin*0.2) + picLeftSideCoord-leftMargin*0.1;
        if tagNo1 < numVertTags+1
            xTag = sfCoords(1)+sfCoords(3)-tagLengthPix;
        else xTag = sfCoords(1)+tagLengthPix;
        end
        yTag = sfCoords(2) + tagHeightPix * ( rem( tagNo1-1, numVertTags ) + 0.5 );
        if tagNo1 <= numVertTags  % on the right side of the picture
            labelPosX = xTag+fontSize * 0.4; % take it a little to the right of xTag
        else
            labelPosX = sfCoords(1) + fontSize * 0.3; %- tagLength * fontSize * 0.65;
        end
        labelPos = [labelPosX yTag-fontSize/4];
        tagCoords{tagNo} = {[xTag, yTag], labelPos };
    end
    tags = zeros( 1, totalTags );
end

% define the sideOfTag array
sideOfTag(1:numHorTags) = 1;
sideOfTag(numHorTags+1:numHorTags*2) = 2;
sideOfTag(numHorTags*2+1:numHorTags*2+numVertTags) = 3;
sideOfTag(numHorTags*2+numVertTags+1:totalTags) = 4;

for p = 1:length( pointers )
    id = pointers{p}{1};
    % don't draw this pointer if there is not enough space for tags and 
    % this is not a state
    if ptrsToSkip > 0 & type2num( 'state' ) ~= whoami( id ) & p <= length(pointers)
        ptrsToSkip = ptrsToSkip - 1;
    else
        rect = pointers{p}{2};
        % Now find the shortest distance between
        
        leftX = sfCoords(1);
        bottomY = sfCoords(2)+sfCoords(4);
        rightX = leftX+sfCoords(3);
        topY = sfCoords(2);
        
        distances = [rect(2)-topY, bottomY - (rect(2)+rect(4)), ...
                rightX - (rect(1)+rect(3)), rect(1) - leftX ];
        [sortedDistances, order] = sort( distances );
        notLookedAt = [];
        for i = 1:length(order) % must be 1:4
            side = order(i);
            switch side,		
            case 1,
                sideTags = 1:numHorTags;
            case 2,
                sideTags = numHorTags+1:numHorTags*2;
            case 3,
                sideTags = numHorTags*2+1:numHorTags*2+numVertTags;
            case 4	
                sideTags = numHorTags*2+numVertTags+1:totalTags;
            end
            % now find the tag position that is the closest to the rect
            sideTagsLength = length( sideTags );
            if side > 2
                bestPos = ( (topY - (rect(2)+rect(4)/2) )/(topY-bottomY) ) * sideTagsLength;
            else
                bestPos = ( (rect(1)+rect(3)/2-leftX )/(rightX-leftX) ) * sideTagsLength;
            end
            bestPos = floor( bestPos ) + 1;
            
            tagNo = 0;
            for j = 1:sideTagsLength
                % calculate the adjustment from the best possible position
                if mod( (j-1), 2 ) == 0
                    adjustment = -( j-1 )/2;
                else
                    adjustment = j/2;
                end
                curTag = bestPos + adjustment;
                if curTag < 1;
                    notLookedAt = [ notLookedAt, sideTags( j:sideTagsLength ) ]; 
                    break;
                end
                if curTag > sideTagsLength;
                    notLookedAt = [ notLookedAt, sideTags( 1:sideTagsLength-j+1 ) ]; 
                    break;
                end
                % if we are here then we can go further.
                if tags( sideTags( curTag ) ) == 0
                    % all right, we have found a place
                    tagNo = sideTags( curTag );
                    break;
                end
            end
            if tagNo ~= 0, 
                break;
            end
        end
        
        if tagNo == 0
            % our goal is to find first non-occupied place in notLookedAt list
            % 
            notLookedAtVec = zeros(1,length(tags));
            notLookedAtVec(notLookedAt) = 1;
            ind = find(notLookedAtVec & (~tags));
            if length( ind ) < 1
                error( 'error in laying out pointers' );
            end
            tagNo = ind( 1 );
            side = sideOfTag( tagNo );
        end
        tags( tagNo ) = 1;
        
        % Now tagNo and side contain the information about where the arrow
        % comes to and from.
        
        % Draw the pointer from the tag to the the middle of the side
        label = num2str(p);
        switch side,
        case 1,
            xSide = rect(1) + rect(3)/2;
            ySide = rect(2);			
        case 2,
            xSide = rect(1) + rect(3)/2;
            ySide = rect(2)+rect(4);			
        case 3,
            xSide = rect(1) + rect(3);
            ySide = rect(2) + rect(4) / 2;			
        case 4,
            xSide = rect(1);
            ySide = rect(2) + rect(4) / 2;			
        end
        labelPos = tagCoords{tagNo}{2};
        xTag = tagCoords{tagNo}{1}(1);
        if xTag < sfCoords(1) + sfCoords(3) / 2
            % for the left side of the image, update the pointer origin
            xTag = labelPos(1) + (length( label ) ) * 0.65 * fontSize;
        end
        yTag = tagCoords{tagNo}{1}(2);
        % draw the arrowhead
        vec = [xTag-xSide, yTag-ySide];
        vec = vec / sqrt( vec * vec' ) * arrowHeadSize;
        perpVec = [ vec(2), -vec(1) ] / 3;
        basePoint = [xSide, ySide] + vec;
        point1 = basePoint - perpVec;
        point2 = basePoint + perpVec;
        
        allProp.Parent=axH;
        allProp.Clipping='off';
        allProp.Tag='csf_snapshot/callout';
        
        %now actually draw
        line1 = line( [xTag, basePoint(1)], [yTag, basePoint(2)], ...
            allProp,...
            'LineStyle','-',...
            'Color', [0.5 0.5 0.5] );
        line2 = line( [point2(1), point1(1)], [point2(2), point1(2)], ...
            allProp,...
            'Color', [0.5 0.5 0.5] );
        line3 = line( [point1(1), xSide], [point1(2), ySide], ...
            allProp,...
            'Color', [0.5 0.5 0.5] );
        line4 = line( [point2(1), xSide], [point2(2), ySide], ...
            allProp,...
            'Color', [0.5 0.5 0.5] );
        
        labelObj = text( labelPos(1), labelPos(2), label,...
            'FontSize',fontSize/scale,...
            'Color',[0 0.3 0],...
            allProp, ...
            'VerticalAlignment', 'top', ...
            'horizontalAlignment', 'left', ...
            'FontName','Helvetica' );

        ext = get( labelObj, 'Extent');
        lc = [ ext(1) + ext(3)/2, labelPos(2) + ext(4)/2 ]; % label center
        rad = max( ext(3)/2, ext(4)/2) * 1.1;
        
        marker = line( [lc(1), lc(1)],[lc(2), lc(2)],...
            allProp, ...
            'color',[.01 .01 .05], ...
            'linestyle','none',...
            'marker','o',...
            'markersize',rad/scale*2 );
        
        %calculate the HTML imagemap coordinates of the marker.
        %X,Y,R where X,Y is the center of the circle
        %X,Y is relative to upper-left corner
        coCoords(p,:)=[id,...
                (lc(1)-sfCoords(1))/scale,...
                (lc(2)-sfCoords(2))/scale,...
                rad];
    end 
end 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function figSize=reshape_portal(portal, minFontSize, maxW, maxH)
%reshape_portal(portal, minFontSize, maxW, maxH)
% reshape a portal wrt the viewObject's legibility
%
 
figH  = sf('get', portal, '.figH');
axesH = sf('get',portal, '.axesH');
pos   = get(figH, 'position');
obj   = sf('get', portal, '.viewObject');

viewLim = sf('get', portal, '.viewLim');
xlim = [viewLim(1) viewLim(2)];
ylim = [viewLim(3) viewLim(4)];

%xlim = get(axesH, 'xlim');
%ylim = get(axesH, 'ylim');

dx = abs(xlim(2) - xlim(1));
dy = abs(ylim(1) - ylim(2)); % reverse y-dir

aspect = dx/dy;

dx = max(dx, 40);
dy = dx/aspect;

if minFontSize>0
    fontSize = get_obj_fontsize(obj);
    targetZoomFactor = fontSize/minFontSize;
    
    dx = dx/targetZoomFactor;
    dy = dx/aspect;
    
    dx = min(dx, maxW);
    dy = dx/aspect;
    
    dy = min(dy, maxH);
    dx = dy*aspect;
else
    dy = min(maxW/aspect,maxH);
    dx = dy*aspect;
end

margin = sf('get', portal, '.margin');

%
% set figure aspect 
%
W = margin(2) + margin(4) + dx;
H = margin(1) + margin(3) + dy;

pos(3:4) = [W H];

if isequal(pos,get(figH,'position'))
    %we need to make sure that the figure updates
    set(figH,'position',pos+[0 0 25 25]);
end
set(figH, 'position', pos);

figSize=[W H];

%-------------------------------------------------------------  
function fontSize = get_obj_fontsize(obj)
%
%
%
fontSize = 12;

STATE = sf('get', 'default', 'state.isa');
JUNCT = sf('get', 'default', 'junction.isa');
TRANS = sf('get', 'default', 'transition.isa');
CHART = sf('get', 'default', 'chart.isa');

ISA = sf('get', obj, '.isa');

switch ISA,
case CHART
    states = sf('get', obj, '.states');
    if ~isempty(states),
        firstLayerStates = sf('find', states, '.treeNode.parent', obj);
        fontSizes        = sf('get', firstLayerStates, '.fontSize');
        fontSize = min(fontSizes);
    end;
case STATE
    chart = sf('get', obj, '.chart');
    viewObj = sf('get', chart, '.viewObj');
    
    % if this is a subchart AND it's not currently being viewed, 
    % then dig the correct fontsize out of the subviewS    
    
    if isequal(sf('get', obj, '.superState'), 2) & ~isequal(obj, viewObj),
        fontSize = sf('get', obj, '.subviewS.fontSize');
    else,
        fontSize = sf('get', obj, '.fontSize');
    end;
case TRANS
    fontSize = sf('get', obj, '.fontSize');
case JUNCT
    fontSize = sf('get', obj, '.position.radius');
end


