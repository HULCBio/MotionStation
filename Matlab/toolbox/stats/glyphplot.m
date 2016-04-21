function h = glyphplot(X,varargin)
%GLYPHPLOT Plot stars or Chernoff faces for multivariate data.
%   GLYPHPLOT(X) creates a star plot from the multivariate data in the
%   N-by-P matrix X.  Rows of X correspond to observations, columns to
%   variables.  A star plot represents each observation as a "star" whose
%   i-th spoke is proportional in length to the i-th coordinate of that
%   observation.  GLYPHPLOT standardizes X by shifting and scaling each
%   column separately onto the interval [.1,1] before making the plot, and
%   centers the glyphs on a rectangular grid that is as close to square as
%   possible.  GLYPHPLOT treats NaNs in X as missing values, and does not
%   plot the corresponding rows of X.  GLYPHPLOT(X, 'Glyph','star') is a
%   synonym for GLYPHPLOT(X).
%
%   GLYPHPLOT(X, 'Glyph','face') creates a face plot from X.  A face plot
%   represents each observation as a "face", whose i-th facial feature is
%   drawn with a characteristic proportional to the i-th coordinate of that
%   observation.  Up to 17 different features are available, as described
%   below.
%
%   GLYPHPLOT(X, 'Glyph','face', 'Features',F) creates a face plot where
%   the i-th element of the index vector F defines which facial feature
%   will represent the i-th column of X.  F must contain integers from 0
%   to 17, where zeros indicate that the corresponding column of X should
%   not be plotted.
%
%   GLYPHPLOT(X, ..., 'Grid',[ROWS,COLS]) organizes the glyphs into a
%   ROWS-by-COLS grid.
%
%   GLYPHPLOT(X, ..., 'Grid',[ROWS,COLS], 'Page',PAGE) organizes the glyph
%   into one or more pages of a ROWS-by-COLS grid, and displays the PAGE'th
%   page.  If PAGE is a vector, GLYPHPLOT displays multiple pages in
%   succession.  If PAGE is 'all', GLYPHPLOT displays all pages.  If PAGE
%   is 'scroll', GLYPHPLOT displays a single plot with a scrollbar.
%
%   GLYPHPLOT(X, ..., 'Centers',C) creates a plot with each glyph centered
%   at the locations in the N-by-2 matrix C.
%
%   GLYPHPLOT(X, ..., 'Centers',C,'Radius',R) creates a plot with glyphs
%   positioned using C, and scale the glyphs so the largest has radius R.
%
%   GLYPHPLOT(X, ..., 'ObsLabels',OBSLABS) labels each glyph with the text in
%   the character array or cell array of strings OBSLABS.  By default, the
%   glyphs are labelled 1:N.  Pass in '' for no labels.  Labels are not
%   plotted when the 'Centers' parameter is given, but appear only in data
%   cursors.
%
%   GLYPHPLOT(X, ..., 'VarLabels',VARLABS) uses the text in the character
%   array or cell array of strings VARLABS as variable names when
%   displaying data cursors.
%
%   GLYPHPLOT(X, ..., 'Standardize',METHOD) standardizes X before making
%   the plot.  Choices for METHOD are:
%      'column'  maps each column of X separately onto the interval [.1,1].
%                This is the default.
%      'matrix'  maps the entire matrix X onto the interval [.1,1].
%      'PCA'     transforms X to its principal component scores, in order
%                of decreasing eigenvalue, and maps each one onto the
%                interval [.1,1].
%      'off'     no standardization.  Data for stars must be in [0,1], and
%                data for faces must be in [.05,.95].
%
%   GLYPHPLOT(X, ..., 'PropertyName',PropertyValue, ...) sets properties to
%   the specified property values for all line graphics objects created by
%   GLYPHPLOT.
%
%   H = GLYPHPLOT(X, ...) returns a matrix of handles to the graphics
%   objects created by GLYPHPLOT.  For a star plot, H(:,1) and H(:,2)
%   contain handles to the line objects for each star's perimeter and
%   spokes, respectively.  For a face plot, H(:,1) and H(:,2) contain object
%   handles to the lines making up each face and to the pupils, respectively.
%   H(:,3) contains handles to the text objects for the labels, if present.
%
%   In a face plot, the columns of X correspond by default to these facial
%   features.  If X has fewer than 17 columns, unused features are
%   displayed at their default value.  Use the 'Features' input parameter
%   to change the default correspondence.
%
%   Column        Facial Feature
%   -------------------------------------
%      1      Size of face
%      2      Forehead/jaw relative arc length
%      3      Shape of forehead
%      4      Shape of jaw
%      5      Width between eyes
%      6      Vertical position of eyes
%      7      Height of eyes
%      8      Width of eyes (this also affects eyebrow width)
%      9      Angle of eyes (this also affects eyebrow angle)
%     10      Vertical position of eyebrows
%     11      Width of eyebrows (relative to eyes)
%     12      Angle of eyebrows (relative to eyes)
%     13      Direction of pupils
%     14      Length of nose
%     15      Vertical position of mouth
%     16      Shape of mouth
%     17      Mouth arc length
%
%   Examples:
%
%      load carsmall
%      X = [Acceleration Displacement Horsepower MPG Weight];
%      glyphplot(X, 'Standardize','column', 'ObsLabels',Model, ...
%                'grid',[2 2], 'page','scroll');
%      glyphplot(X, 'Glyph','face', 'ObsLabels',Model, 'grid',[2 3], 'page',9);
%
%   See also ANDREWSPLOT, PARALLELCOORDS.

%   References:
%     [1] Gnanadesikan, R. (1977) Methods for Statistical Dara Analysis of
%         Multivariate Observations, Wiley.
%     [2] Chernoff, H. (1973) "The Use of Faces to Represent Points in
%         k-Dimensional Space Graphically", J.Am.Stat.Assoc. 68:361-368.

%   The code for the individual faces was originally written by Herman Chernoff.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2004/04/06 01:11:06 $

if nargin < 1
    error('stats:glyphplot:TooFewInputs', ...
          'At least one input argument required.');
end
[n,p] = size(X);

% Process input parameter name/value pairs, assume unrecognized ones are
% graphics properties for PLOT
pnames = {'glyph' 'features' 'standardize' 'obslabels' 'varlabels' 'centers' 'radius' 'grid' 'page'};
dflts =  {'star'         []       'column'          []          []        []       []     []      1 };
[errid,errmsg,glyph,features,stdize,obslabs,varlabs,centers,...
       radius,grid,page,plotArgs] = statgetargs(pnames, dflts, varargin{:});
if ~isempty(errid)
    error(sprintf('stats:glyphplot:%s',errid), errmsg);
end

glyph = lower(glyph);
if isequal(glyph,'star')
    limX = [.1 .90]; % [min (max-min)] spoke length
elseif isequal(glyph,'face')
    % The features param is completely ignored for stars.
    if isempty(features)
        features = 1:p; % use all columns of X, in order.
        nullFeatures = (p+1):17;
    elseif isnumeric(features) && isvector(features) && (length(features) == p)
        features = features(:)'; % a row
        % Remove columns whose feature is zero.
        X(:,features==0) = [];
        features(features==0) = [];
        p = size(X,2);
        
        % Validation of the indices in features happens later.
        indices = 1:17;
        present = ismember(indices,features);
        if sum(present) < numel(features)
            error('stats:glyphplot:InvalidFeaturesParam', ...
                  ['The ''features'' parameter value must be a vector of ' ...
                   'unique integers from 0 to 17.']);
        end
        nullFeatures = indices(~present); % features not being used
    else
        error('stats:glyphplot:InvalidFeaturesParam', ...
              ['The ''features'' parameter value must be a vector of ' ...
              'indices with\none element for each column of X.']);
    end
    if p > 17
        error('stats:glyphplot:TooManyDims', ...
              'You can use a maximum of 17 columns from X when plotting faces.');
    end
    limX = [.05 .90]; % [min (max-min)] face values

else
    error('stats:glyphplot:InvalidGlyphParam', ...
          'The ''glyph'' parameter value must be the string ''star'' or ''face''.');
end

dfltObslabs = false;
if isempty(obslabs)
    if ischar(obslabs)
        % plot nothing
    else
        dfltObslabs = true;
        obslabs = cellstr(num2str((1:n)'));
    end
elseif ischar(obslabs) && size(obslabs,1) == n
    % cellstr will deblank the labels to make them plot centered.
    obslabs = cellstr(obslabs);
elseif iscellstr(obslabs) && numel(obslabs) == n
    obslabs = obslabs(:);
else
    error('stats:glyphplot:InvalidLabelParam', ...
          ['The ''obslabels'' parameter value must be a character array or ' ...
           'a cell array\nof strings with one label for each row of X.']);
end

if isempty(varlabs)
    varlabs = cellstr([repmat('Variable ',p,1) num2str((1:p)')]);
elseif ischar(varlabs) && size(varlabs,1) == p
    varlabs = cellstr(varlabs);
elseif iscellstr(varlabs) && numel(varlabs) == p
    varlabs = varlabs(:);
else
    error('stats:glyphplot:InvalidVarLabelParam', ...
          ['The ''varlabels'' parameter value must be a character array or ' ...
           'a cell array\nof strings with one label for each column of X.']);
end

% Remove NaNs from the data and labels.  There's no really good way to have
% the glyphs distinguish missing from min (stars) or from mid (faces).
nans = find(any(isnan(X),2));
if length(nans) > 0
    X(nans,:) = [];
    if ~isempty(obslabs)
        obslabs(nans) = [];
    end
    n = size(X,1);
end

if n == 0
    newplot
    h = [];
    return
end

% Transform data if requested
if ischar(stdize)
    stdizeNames = {'column','matrix','pca','off'};
    i = strmatch(lower(stdize), stdizeNames);
    if length(i) > 1
        error('stats:glyphplot:InvalidStandardizeParam', ...
              'Ambiguous ''standardize'' parameter value:  %s.', stdize);
    elseif isempty(i)
        error('stats:glyphplot:InvalidStandardizeParam', ...
              'Unknown ''standardize'' parameter value:  %s.', stdize);
    end
    stdize = stdizeNames{i};

    % Standardize each coordinate onto the range [limX(1) limX(2)].
    switch stdize
    case 'column'
        minX = min(X,[],1);
        rangeX = max(X,[],1) - minX;
        constCols = ~(rangeX > 0);
        rangeX(constCols) = 1; % prevent warning for these, fix up afterwards
        Xstd = limX(1) + limX(2)*(X - repmat(minX,n,1)) ./ repmat(rangeX,n,1);
        Xstd(:,constCols) = .5;

    % Standardize the entire matrix onto the range [limX(1) limX(2)].  This
    % is not done coordinate-wise.
    case 'matrix'
        minX = min(X(:));
        maxX = max(X(:));
        if maxX > minX
            Xstd = limX(1) + limX(2)*(X - minX) ./ (maxX - minX);
        else
            Xstd(:) = .5;
        end

    % Transform the data to PC scores, and standardize each coordinate onto
    % the range [limX(1) limX(2)].
    case 'pca'
        if ~isempty(X)
            [dum,X] = princomp(X);
        end
        minX = min(X,[],1);
        rangeX = max(X,[],1) - minX;
        constCols = ~(rangeX > 0);
        rangeX(constCols) = 1; % prevent warning for these, fix up afterwards
        Xstd = limX(1) + limX(2)*(X - repmat(minX,n,1)) ./ repmat(rangeX,n,1);
        Xstd(:,constCols) = .5;

    % No standardization, but we have to make sure the data can be plotted.
    case 'off'
        if isequal(glyph,'star') && any(X(:) < 0 | 1 < X(:))
            error('stats:glyphplot:InvalidData', ...
                  ['Data for stars must be in the interval [0,1].  Transform ' ...
                   'your data or\nuse one of the standardization options.']);
        elseif any(X(:) < 0.05 | 0.95 < X(:)) % isequal(glyph,'face')
            error('stats:glyphplot:InvalidData', ...
                  ['Data for faces must be in the interval [.05,.95].  Transform ' ...
                   'your data or\nuse one of the standardization options.']);
        end
        Xstd = X;
    end
else
    error('stats:glyphplot:InvalidStandardizeParam', ...
          'The ''standardize'' parameter value must be a string.');
end

% Figure out where everything will go on the plot, and how big.
if isempty(centers) && isempty(grid)
    % By default, put all the glyphs on one page.  ngridx-by-ngridy is big
    % enough to fit everything.
    ngridy = floor(sqrt(n));
    ngridx = ceil(n./ngridy);
    ngrid = ngridx*ngridy;
    pages = 1;
    ctrx = repmat(1:ngridx,1,ngridy);
    ctry = ngridy - reshape(repmat(1:ngridy,ngridx,1),1,ngrid) + 1;
    radius = 0.4;
    xlim = [1-1.5*radius ngridx+1.5*radius];
    ylim = [1-1.5*radius ngridy+1.5*radius];
elseif ~isempty(grid)
    if isnumeric(grid) && (numel(grid)==2) && all(grid>0) && all(grid==floor(grid))
        if isequal(page,'scroll')
            % Display one big page of glyphs, with an grid(2)-by-grid(1)
            % grid visible, and a vertical scrollbar if necessary.
            clf
            ngridx = grid(2);
            ngridy = max(ceil(n./ngridx), grid(1));
            nhiddeny = max(ngridy - grid(1),0);
            ngrid = ngridx*ngridy;
            pages = 1;
            ctrx = repmat(1:ngridx,1,ngridy);
            ctry = ngridy - reshape(repmat(1:ngridy,ngridx,1),1,ngrid) + 1;
            radius = 0.4;
            % start off showing ngridx-by-nvisibley glyphs
            xlim = [1-1.5*radius ngridx+1.5*radius];
            ylim = [nhiddeny+1-1.5*radius, ngridy+1.5*radius];

            % Add a slider to the right edge of the figure if necessary.
            if nhiddeny > 0
                f = gcf;
                % Get the figure position in pixels
                funits = get(f,'Units');
                set(f,'Units','pixels'); fpos = get(f,'Position'); set(f,'Units',funits);
                sliderwidth = 15; % pixels
                spos = [fpos(3)-sliderwidth 1 sliderwidth fpos(4)];
                hScrollbar = uicontrol(f, 'Style','slider', 'Tag','slider', ...
                    'Units','pixels', 'Position',spos, 'Value',nhiddeny+1, ...
                    'Min',1, 'Max',nhiddeny+1, 'SliderStep',[.1 1]/nhiddeny, ...
                    'Callback',{@scrollfig gca ngridy-nhiddeny radius});
                set(f,'ResizeFcn',{@resizefig hScrollbar})
            end

        else
            ngridx = grid(2);
            ngridy = grid(1);
            ngrid = ngridx*ngridy;
            if isnumeric(page) && isvector(page)
                % Show only the specified page(s) of glyphs, page 1 by default.
                pages = unique(max(1,min(round(page(:)'),ceil(n./ngrid))));
            elseif isequal(page,'all')
                % Show all pages.
                pages = 1:ceil(n./ngrid);
            else
                error('stats:glyphplot:InvalidPageParam', ...
                      ['The ''page'' parameter value be a numeric ' ...
                       'vector, or the strings ''all'' or ''scroll''.']);
            end
            ctrx = repmat(1:ngridx,1,ngridy);
            ctry = ngridy - reshape(repmat(1:ngridy,ngridx,1),1,ngrid) + 1;
            radius = 0.4;
            xlim = [1-1.5*radius ngridx+1.5*radius];
            ylim = [1-1.5*radius ngridy+1.5*radius];
        end
    else
        error('stats:glyphplot:InvalidGridParam', ...
              'The ''grid'' parameter value must be a 2 element vector of sizes.');
    end
elseif ~isempty(centers)
    if isnumeric(centers) && isequal(size(centers),[n,2])
        % Make a single page with glyphs at the specified center points.
        pages = 1;
        ngrid = n;
        ctrx = centers(:,1)';
        ctry = centers(:,2)';
        % The radius param is completely unless centers is given.
        if isempty(radius)
            % Choose a radius that will make the glyphs at least legible.
            % They might overlap.
            radius = .10*max(pdist(centers));
        else
            if ~isnumeric(radius) || ~isscalar(radius) || (radius<=0)
                error('stats:glyphplot:InvalidRadiusParam', ...
                      'The ''radius'' parameter value must be a positive scalar.');
            end
        end
        xlim = [min(ctrx)-1.5*radius, max(ctrx)+1.5*radius];
        ylim = [min(ctry)-1.5*radius, max(ctry)+1.5*radius];
    else
        error('stats:glyphplot:InvalidCentersParam', ...
              ['The ''centers'' parameter value must be a numeric matrix ' ...
               'with 2 columns,\nand one row for each row of X.']);
    end
end

if isequal(glyph,'face')
    % Expand X out to 17 columns with padding, and reorder the columns
    % to get the real data mapped to the right features.
    Xstd(:,[features, nullFeatures]) = [Xstd repmat(.5,n,17-p)];
    
    % Find the largest unscaled face.  They'll be scaled down to radius.
    largestFace = maxFaceSize(Xstd);
end

newplot;
dataCursorBehaviorObj = hgbehaviorfactory('DataCursor');
set(dataCursorBehaviorObj,'UpdateFcn',@dataCursorCallback);

for page = pages
    % Find the rows of X that will be displayed on this page.  On the last
    % page, there may be fewer glyphs to plot than centers.
    if page*ngrid <= n
        nglyphs = ngrid;
    else % final page not full
        nglyphs = mod(n,ngrid);
        ctrx = ctrx(1:nglyphs);
        ctry = ctry(1:nglyphs);
    end
    pagerows = (page-1)*ngrid + (1:nglyphs);

    % Plot the grid of glyphs for the current page.
    if isequal(glyph,'star')
        lineh = plotStars(Xstd(pagerows,:),pagerows,ctrx,ctry,radius,plotArgs);
    else
        lineh = plotFaces(Xstd(pagerows,:),pagerows,ctrx,ctry,radius,largestFace,plotArgs);
    end
    hgaddbehavior(lineh(:),dataCursorBehaviorObj);
    
    % Make the axes have equal scales, and set their limits explicitly.
    if ~ishold
        axis equal
        % With multiple pages, we may not be in the original figure window
        % any more.  Get whatever axes we are in.
        cax = get(lineh(1),'Parent');
        set(cax, 'Xlim',xlim, 'XlimMode','manual', ...
                 'Ylim',ylim, 'YlimMode','manual');
        if isempty(centers) % turn off ticks if this on a grid
            set(cax, 'XTick',[], 'YTick',[]);
        end
    end

    if ~isempty(obslabs) && isempty(centers)
        texth = text(ctrx,ctry-1.1*radius,obslabs(pagerows),...
                     'Clipping','on', 'HorizontalAlignment','Center');
        set(texth,'tag','obs label');
    else
        texth = zeros(nglyphs,0);
    end

    % If more than one page, bring the current one to the front, and prompt
    % for the next.
    if length(pages) > 1
        shg
        if page < max(pages)
            input('Press return for next page');
        end
    end
end

if nargout > 0
    % Return the line and label handles for glyphs on the last page.  If
    % there were multiple pages, handles from previous pages are invalid by
    % now, don't return them.
    h = [lineh texth];
end

    % -----------------------------------------
    function dataCursorText = dataCursorCallback(obj,eventObj)
    clickPos = get(eventObj,'Position');
    clickUserData = get(get(eventObj,'Target'),'UserData');
    clickObsNum = clickUserData(end);
    clickDx = clickPos(1)-clickUserData(1);
    clickDy = clickPos(2)-clickUserData(2);
    % The click position will be at a vertex.  If it is in a face, or at the
    % center of a star, display all the variables.
    if isequal(glyph,'face') || (sqrt(clickDx^2 + clickDy^2) < .001*radius)
        dataCursorText = cell(p+1,1);
        for clickVarNum = 1:p
            dataCursorText{clickVarNum+1} = ...
                [varlabs{clickVarNum} ': ' num2str(X(clickObsNum,clickVarNum))];
        end
        
    % If the click is on a point of a star, display only that variable.
    else
        dataCursorText = cell(2,1);
        clickVarNum = mod(round(atan2(clickDy,clickDx)*p/(2*pi)),p) + 1;
        dataCursorText{2} = [varlabs{clickVarNum} ': ' num2str(X(clickObsNum,clickVarNum))];
    end
    if dfltObslabs
        dataCursorText{1} = ['Observation ' num2str(clickObsNum)];
    else
        dataCursorText{1} = obslabs{clickObsNum};
    end
    end % dataCursorCallback

end % glyphplot


% -----------------------------------------
function lineh = plotStars(X,indices,ctrx,ctry,radius,plotArgs)
%PLOTSTARS Plot a grid of stars.

userData = num2cell([ctrx(:) ctry(:) indices(:)], 2);

[n,p] = size(X);
theta = 2*pi*(0:(p-1))' ./ p;

ctrx = ctrx(ones(1,p),:);
ctry = ctry(ones(1,p),:);

% Set up the perimeter of each star as a column.
tipx = radius * repmat(cos(theta),1,n).*X' + ctrx;
tipy = radius * repmat(sin(theta),1,n).*X' + ctry;

% Set up spokes for each star as column with NaNs separating each spoke.
spokesx = cat(1, reshape(ctrx,[1 p n]), reshape(tipx,[1 p n]), NaN(1,p,n));
spokesx = reshape(spokesx, [3*p n]);
spokesy = cat(1, reshape(ctry,[1 p n]), reshape(tipy,[1 p n]), NaN(1,p,n));
spokesy = reshape(spokesy, [3*p n]);

colors = get(gca,'ColorOrder');
lineh = plot(tipx([1:p 1],:), tipy([1:p 1],:),'-', spokesx, spokesy, '-', ...
             'Color',colors(1,:), plotArgs{:});
lineh = reshape(lineh,n,2); % return two columns
set(lineh(:,1),'tag','perimeter');
set(lineh(:,2),'tag','spokes');
set(lineh(:,1),{'userdata'},userData);
set(lineh(:,2),{'userdata'},userData);

end % plotStars

% -----------------------------------------
function h = plotFaces(X,indices,ctrx,ctry,radius,maxFaceSize,plotArgs)
%PLOTFACES Plot a grid of faces.

[n,p] = size(X);

% We assume that each column of X has been mapped onto [.05, .95], that the
% columns are in the desired feature order, and that X has exactly 17 columns.

% We'll set hold on, but later set it back as it was.
next = get(gca,'NextPlot');
holdState = ishold;

scale = .9 * radius ./ maxFaceSize;
h = NaN(n,2);
for i = 1:n
    h(i,:) = face(X(i,:),indices(i),ctrx(i),ctry(i),scale,plotArgs);
    hold on
end
if ~holdState
    hold off
    set(gca, 'NextPlot',next);
end

end % plotFaces

% -----------------------------------------
function maxSize = maxFaceSize(X)
%MAXFACESIZE Find the maximum size of faces to be plotted.
r = .5+1.5*X(:,1); t0 = .7*pi*(X(:,2)-.5); du = .5*(1+3*X(:,3)); dl = .5*(1+3*X(:,4));
ys = r.*sin(t0); xc = r.*cos(t0);
au = xc.^2+(ys./du).^2; ymax = du.*sqrt(au);
al = xc.^2+(ys./dl).^2; ymin = -dl.*sqrt(al);
ymt = .5*(ymax-ymin); yct = .5*(ymax+ymin);
ymn = max(ymt,[],1); xmn = max(sqrt(max(au,al)),[],1);
maxSize = max(xmn,ymn);
end % maxFaceSize

% -----------------------------------------
function lineh = face(x,index,ctrx,ctry,scale,plotArgs)
%FACE Plot a single face.

%
% shape of face  (x(1:4))
%
n0=20;
r=.5+1.5*x(1); t0=.7*pi*(x(2)-.5); du=.5*(1+3*x(3)); dl=.5*(1+3*x(4));
ys=r*sin(t0); xc=r*cos(t0);
au=xc^2+(ys/du)^2; ymax=du*sqrt(au);
al=xc^2+(ys/dl)^2; ymin=-dl*sqrt(al);
ymt=.5*(ymax-ymin); yct=.5*(ymax+ymin);
tyu=(sqrt(ymax-ys)/n0)*(0:n0); tyl=(sqrt(ys-ymin)/n0)*(0:n0);
yu=ymax-tyu.^2; yl=ymin+tyl.^2;
%  yu=ys+(0:n0)*((ymax-ys)/n0); yl=ys+(0:n0)*((ymin-ys)/n0);
xu1=sqrt(max(0,au-(yu/du).^2));
xl1=sqrt(max(0,al-(yl/dl).^2));
xu2=-xu1;xl2=-xl1;

%
% eyes  (x(5:9))
%
es=.25*(1+2*x(5))*xc; eh=.7*x(6)*ymt+yct;
elb=min(-.2*xc+es,.8*xc-es);
ewb=min(-yct+eh,.8*ymax+.2*yct-eh);
el=(.2+.8*x(7))*elb; ew=(.1+.9*x(8))*ewb; te=(.3*pi)*(x(9)-.5);
xe=(-n0:n0)*(el/n0); ye1=sqrt(max(0,1-(xe/el).^2))*ew; ye2=-ye1;
ct=cos(te); st=sin(te);
xe3=ct*xe-st*ye1+es; ye3=st*xe+ct*ye1+eh;
xe4=ct*xe-st*ye2+es; ye4=st*xe+ct*ye2+eh;

%
% brows  (x(10:12))
%
bh=.5*x(10)*ymax+(1-.5*x(10))*(eh+ew); bl=(.2+.8*x(11))*elb;
tb=(.1*pi)*(x(12)-.5);
stb=tan(tb+te);
xb=(bl/n0)*(-n0:n0);
yb=xb*stb+bh; xb=xb+es;

%
% pupils  (x(13))
%
p=(-.5+x(13))*el*1.5;
xpr=es+p; xpl=-es+p; yp=eh;

%
% nose  (x(14))
%
nl=x(14)*(eh-ymin)*.7;
xn=0*(0:n0); yn=eh-(0:n0)*(nl/n0);

%
% mouth  (x(15:17))
%
mh=(eh-nl)*x(15)+(1-x(15))*ymin;
mr=(-.9+2*x(16))*3;
ml=x(17);
mc=mh+mr; tm=(-n0:n0)*(.5*ml*pi/n0); ym=mc-mr*cos(tm);
xm=mr*sin(tm);

y1=yu-yct; y2=y1; y3=yl-yct; y4=y3; y5=ye3-yct; y6=ye4-yct;
y7=y5; y8=y6; y9=yb-yct; y10=y9; y11=yn-yct; y12=ym-yct;
y13=yp-yct; y14=y13;

X = [xu1,NaN, xu2,NaN, xl1,NaN,xl2,NaN,xe3,NaN,...
     xe4,NaN,-xe3,NaN,-xe4,NaN, xb,NaN,-xb,NaN,...
     xn, NaN,  xm];
Y = [ y1,NaN,  y2,NaN,  y3,NaN, y4,NaN, y5,NaN,...
      y6,NaN,  y7,NaN,  y8,NaN, y9,NaN,y10,NaN,...
     y11,NaN, y12];
Xeyes = [xpr xpl];
Yeyes = [y13 y14];

X = X*scale+ctrx;
Y = Y*scale+ctry;
Xeyes = Xeyes*scale+ctrx;
Yeyes = Yeyes*scale+ctry;

lineh = plot(X,Y,'-', Xeyes,Yeyes,'.', plotArgs{:});
lineh = lineh'; % return a row
userData = [ctrx ctry index];
set(lineh(1),'tag','face','userdata',userData);
set(lineh(2),'tag','pupils','userdata',userData);

end % face

% -----------------------------------------
function scrollfig(hScrollbar,ignore,axesh,nvisibley,radius)
%SCROLLFIG Callback to scroll the figure.
scrolled = get(hScrollbar,'Value');
ylim = [scrolled-1.5*radius, scrolled+nvisibley-1+1.5*radius];
set(axesh, 'Ylim',ylim);
end % scrollfig

% -----------------------------------------
function resizefig(f,ignore,hScrollbar)
%RESIZEFIG Callback to reposition the scrollbar on resize.
% The slider's units is pixels, get the figure position in pixels too.
funits = get(f,'Units');
set(f,'Units','pixels'); fpos = get(f,'Position'); set(f,'Units',funits);
spos = get(hScrollbar,'Position');
sliderwidth = spos(3);
spos = [fpos(3)-sliderwidth 1 sliderwidth fpos(4)];
set(hScrollbar,'Position',spos);
end % resizefig
