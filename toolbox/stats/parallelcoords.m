function h = parallelcoords(X,varargin)
%PARALLELCOORDS Parallel coordinates plot for multivariate data.
%   PARALLELCOORDS(X) creates a parallel coordinates plot of the
%   multivariate data in the N-by-P matrix X.  Rows of X correspond to
%   observations, columns to variables.  A parallel coordinates plot is a
%   tool for visualizing high dimensional data, where each observation is
%   represented by the sequence of its coordinate values plotted against
%   their coordinate indices.  PARALLELCOORDS treats NaNs in X as missing
%   values, and those coordinate values are not plotted.
%
%   PARALLELCOORDS(X, ..., 'Standardize','on') scales each column of X to
%   have zero mean and unit standard deviation before making the plot.
%
%   PARALLELCOORDS(X, ..., 'Standardize','PCA') creates a parallel
%   coordinates plot from the principal component scores of X, in order of
%   decreasing eigenvalue.  PARALLELCOORDS removes rows of X containing
%   missing values (NaNs) for PCA standardization.
%
%   PARALLELCOORDS(X, ..., 'Quantile',ALPHA) plots only the median and the
%   ALPHA and (1-ALPHA) quantiles of f(t) at each value of t.  This is
%   useful if X contains many observations.
%
%   PARALLELCOORDS(X, ..., 'Group',GROUP) plots the data in different
%   groups with different colors.  Groups are defined by GROUP, a numeric
%   array containing a group index for each observation.  GROUP can also be
%   a character matrix, or cell array of strings, containing a group name
%   for each observation.
%
%   PARALLELCOORDS(X, ..., 'Labels',LABS) labels the coordinate tick marks
%   along the horizontal axis using LABS, a character array or cell array
%   of strings.
%
%   PARALLELCOORDS(X, ..., 'PropertyName',PropertyValue, ...) sets
%   properties to the specified property values for all line graphics
%   objects created by PARALLELCOORDS.
%
%   H = PARALLELCOORDS(X, ...) returns a column vector of handles to the
%   line objects created by PARALLELCOORDS, one handle per row of X.  If
%   you use the 'Quantile' input parameter, H contains one handle for each
%   of the three lines objects created.  If you use both the 'Quantile' and
%   the 'Group' input parameters,  H contains three handles for each group.
%
%   Examples:
%
%      % make a grouped plot of the raw data
%      load fisheriris
%      labs = {'Sepal Length','Sepal Width','Petal Length','Petal Width'};
%      parallelcoords(meas, 'group',species, 'labels',labs);
%
%      % plot only the median and quartiles of each group
%      parallelcoords(meas, 'group',species, 'labels',labs, 'quantile',.25);
%
%   See also ANDREWSPLOT, GLYPHPLOT.

%   References:
%     [1] Gnanadesikan, R. (1977) Methods for Statistical Dara Analysis
%         of Multivariate Observations, Wiley.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2004/01/24 09:34:49 $

if nargin < 1
    error('stats:parallelcoords:TooFewInputs', ...
          'At least one input argument required.');
end
[n,p] = size(X);

% Process input parameter name/value pairs, assume unrecognized ones are
% graphics properties for PLOT
pnames = {'quantile' 'standardize' 'group' 'labels'};
dflts =  {       []          'off'     []       [] };
[errid,errmsg,quantile,stdize,group,tcklabs,plotArgs] = ...
                             statgetargs(pnames, dflts, varargin{:});
if ~isempty(errid)
    error(sprintf('stats:parallelcoords:%s',errid), errmsg);
end

if ~isempty(quantile)
    if ~isnumeric(quantile) || ~isscalar(quantile) || ~(0 < quantile & quantile < 1)
        error('stats:parallelcoords:InvalidQuantileParam', ...
              'The ''quantile'' parameter value must be a scalar between 0 and 1.');
    end
    quantile = min(quantile,1-quantile);
end

% Grouping vector was not given, or it is empty to match an empty X.  Fake
% a group index vector.
if isempty(group)
    gidx = ones(n,1);
    ngroups = 1;
    
% Get the group index for each observation
else
    [gidx,gnames] = grp2idx(group);
    ngroups = length(gnames);
    if length(gidx) ~= n
        error('stats:parallelcoords:InputSizeMismatch', ...
              'The ''group'' parameter value must have one row for each row of X.');
    end
end

if isempty(tcklabs)
    tcklabs = 1:p;
elseif ischar(tcklabs) && size(tcklabs,1) == p
    % ok
elseif iscellstr(tcklabs) && length(tcklabs) == p
    % ok
else
    error('stats:parallelcoords:InvalidLabelParam', ...
          ['The ''labels'' parameter value must be a character array or a cell array' ...
           '\nof strings with one label for each column of X.']);
end

% Transform data if requested
pca = false;
if ischar(stdize)
    if strcmp(lower(stdize),'off')
        % leave X alone
        
    % Standardize each coordinate to unit variance
    elseif strcmp(lower(stdize),'on')
        if n > 1
            X = (X - repmat(nanmean(X),n,1))./ repmat(nanstd(X),n,1);
        elseif n == 1
            X(~isnan(X)) = 0; % prevent divide by zero, preserve NaNs
        else
            % leave empty X alone
        end
        
    % Transform the data to PC scores
    elseif strcmp(lower(stdize),'pca')
        % Remove NaNs from the data before PCA.
        nans = find(isnan(gidx) | any(isnan(X),2));
        if length(nans) > 0
            X(nans,:) = [];
            gidx(nans) = [];
            n = size(X,1);
        end
        if ~isempty(X)
            [dum,X] = princomp(X);
        end
        pca = true;

    else
        error('stats:parallelcoords:InvalidStandardizeParam', ...
              'The ''standardize'' parameter must be ''off'', ''on'', or ''pca''.');
    end
else
    error('stats:parallelcoords:InvalidStandardizeParam', ...
          'The ''standardize'' parameter value be a string.');
end

icoord = 1:p;

cax = newplot;
colors = get(cax,'ColorOrder');
ncolors = size(colors,1);

for grp = 1:ngroups
    color = colors(mod(grp-1,ncolors)+1,:);
    mbrs = find(gidx == grp);
    
    % Make an empty plot if no data.
    if isempty(mbrs)
        line(icoord,repmat(NaN,size(icoord)), 'LineStyle','-', 'Color',color, plotArgs{:});
        
    % Plot the individual observations, or the median and the upper and
    % lower ALPHA-quantiles of the data.  Any unused input args are passed
    % to plot as graphics properties.
    elseif isempty(quantile)
        % Plot rows of X agin icoord.  If a group has p members, plot would
        % try to use columns of X, prevent that by always using X'.
        lineh = line(icoord,X(mbrs,:)', 'LineStyle','-', 'Color',color, plotArgs{:});

        % Save line handles ordered by observation, one per row of X
        if nargout > 0
            set(lineh,'Tag','coords');
            h(mbrs) = lineh;
        end
    else
        if length(mbrs) == 1
            q = repmat(X(mbrs,:),3,1); % no dim arg for prctile
        else
            q = prctile(X(mbrs,:), 100*[.50 quantile 1-quantile]);
        end
        lineh = [line(icoord,q(1,:), 'LineStyle','-', 'Color',color, plotArgs{:}); ...
                 line(icoord,q(2:3,:), 'LineStyle',':', 'Color',color, plotArgs{:})];
        
        % Save line handles, three for each group
        if nargout > 0
            set(lineh(1),'Tag','median');
            set(lineh(2),'Tag','lower quantile');
            set(lineh(3),'Tag','upper quantile');
            h((grp-1)*3 + (1:3)) = lineh;
        end
    end
    
    % Save line handles for the legend if the data are grouped
    if ~isempty(group) && ~isempty(mbrs)
        lgndh(grp) = lineh(1);
    end
end

if nargout > 0
    h = h(:);
end

% Label the axes
if ~ishold
    if ~pca
        xlabel('Coordinate'); ylabel('Coordinate Value');
    else
        xlabel('Principal Component'); ylabel('PC Score');
    end
    set(cax, 'XTick',icoord, 'XTickLabel',tcklabs);
end

% If the data are grouped, put up a legend
if ~isempty(group)
    legend(lgndh,gnames);
end
