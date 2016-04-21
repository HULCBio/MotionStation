function h = biplot(coefs,varargin)
%BIPLOT Biplot of variable/factor coefficients and scores.
%   BIPLOT(COEFS) creates a biplot of the coefficients in the matrix
%   COEFS.  The biplot is 2D if COEFS has two columns, or 3D if it has
%   three columns.  COEFS usually contains principal component coefficients
%   created with PRINCOMP or PCACOV, or factor loadings estimated with
%   FACTORAN.  The axes in the biplot represent the principal components or
%   latent factors (columns of COEFS), and the observed variables (rows of
%   COEFS) are represented as vectors.
%
%   BIPLOT(COEFS, ..., 'Scores', SCORES) plots both COEFS and the scores in
%   the matrix SCORES in the biplot.  SCORES usually contains principal
%   component scores created with PRINCOMP or factor scores estimated with
%   FACTORAN.  Each observation (row of SCORES) is represented as a point
%   in the biplot.
%
%   A biplot allows you to visualize the magnitude and sign of each
%   variable's contribution to the first two or three principal components,
%   and how each observation is represented in terms of those components.
%
%   BIPLOT imposes a sign convention, forcing the element with largest
%   magnitude in each column of COEFS is positive.
%
%   BIPLOT(COEFS, ..., 'VarLabels',VARLABS) labels each vector (variable)
%   with the text in the character array or cell array VARLABS.
%
%   BIPLOT(COEFS, ..., 'Scores', SCORES, 'ObsLabels', OBSLABS) uses the
%   text in the character array or cell array OBSLABS as observation names
%   when displaying data cursors.
%
%   BIPLOT(COEFFS, ..., 'PropertyName',PropertyValue, ...) sets properties
%   to the specified property values for all line graphics objects created
%   by BIPLOT.
%
%   H = BIPLOT(COEFS, ...) returns a column vector of handles to the
%   graphics objects created by BIPLOT.  H contains, in order, handles
%   corresponding to variables (line handles, followed by marker handles,
%   followed by text handles), to observations (if present, marker
%   handles), and to the axis lines.
%
%   Example:
%
%      load carsmall
%      X = [Acceleration Displacement Horsepower MPG Weight];
%      X = X(all(~isnan(X),2),:);
%      [coefs,score] = princomp(zscore(X));
%      vlabs = {'Accel','Disp','HP','MPG','Wgt'};
%      biplot(coefs(:,1:3), 'scores',score(:,1:3), 'varlabels',vlabs);
%
%   See also FACTORAN, PRINCOMP, PCACOV, ROTATEFACTORS.

%   References:
%     [1] Seber, G.A.F. (1984) Multivariate Observations, Wiley.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $ $Date: 2004/03/02 21:49:05 $

if nargin < 1
    error('stats:biplot:TooFewInputs', ...
          'At least one input argument required.');
end
[p,d] = size(coefs);
if (d < 2) || (d > 3)
    error('stats:biplot:WrongNumberOfDimensions', ...
          'COEFS must have 2 or 3 columns');
end
in3D = (d == 3);

% Process input parameter name/value pairs, assume unrecognized ones are
% graphics properties for PLOT.
pnames = {'scores' 'varlabels' 'obslabels'};
dflts =  {     []        []        []};
[errid,errmsg,scores,varlabs,obslabs,plotArgs] = ...
                    statgetargs(pnames, dflts, varargin{:});
if ~isempty(errid)
    error(sprintf('stats:biplot:%s',errid), errmsg);
end

if ~isempty(scores)
    [n,d2] = size(scores);
    if d2 ~= d
        error('stats:biplot:WrongNumberOfDimensions', ...
              'SCORES must have the same number of columns as COEFS');
    end
end

cax = newplot;
dataCursorBehaviorObj = hgbehaviorfactory('DataCursor');
set(dataCursorBehaviorObj,'UpdateFcn',@dataCursorCallback);

if nargout > 0
    varTxtHndl = [];
    obsHndl = [];
    axisHndl = [];
end

% Force each column of the coefficients to have a positive largest element.
% This tends to put the large var vectors in the top and right halves of
% the plot.
[dum,maxind] = max(abs(coefs),[],1);
colsign = sign(coefs(maxind + (0:p:(d-1)*p)));
coefs = coefs .* repmat(colsign, p, 1);

% Plot a line with a head for each variable, and label them.  Pass along any
% extra input args as graphics properties for plot.
%
% Create separate objects for the lines and markers for each row of COEFS.
zeroes = zeros(p,1); nans = NaN(p,1);
arx = [zeroes coefs(:,1) nans]';
ary = [zeroes coefs(:,2) nans]';
if in3D
    arz = [zeroes coefs(:,3) nans]';
    varHndl = [line(arx(1:2,:),ary(1:2,:),arz(1:2,:), 'Color','b', 'LineStyle','-', plotArgs{:}, 'Marker','none'); ...
               line(arx(2:3,:),ary(2:3,:),arz(2:3,:), 'Color','b', 'Marker','.', plotArgs{:}, 'LineStyle','none')];
else
    varHndl = [line(arx(1:2,:),ary(1:2,:), 'Color','b', 'LineStyle','-', plotArgs{:}, 'Marker','none'); ...
               line(arx(2:3,:),ary(2:3,:), 'Color','b', 'Marker','.', plotArgs{:}, 'LineStyle','none')];
end
set(varHndl(1:p),'tag','varline');
set(varHndl((p+1):(2*p)),'tag','varmarker');
set(varHndl,{'UserData'},num2cell(([1:p 1:p])'));
hgaddbehavior(varHndl,dataCursorBehaviorObj);

if ~isempty(varlabs)
    if ~(ischar(varlabs) && (size(varlabs,1) == p)) && ...
                           ~(iscellstr(varlabs) && (numel(varlabs) == p))
        error('stats:biplot:InvalidVarLabels', ...
              ['The ''varlabels'' parameter value must be a character array or ' ...
               'a cell array\nof strings with one label for each row of COEFS.']);
    end

    % Take a stab at keeping the labels off the markers.
    delx = .01*diff(get(cax,'XLim'));
    dely = .01*diff(get(cax,'YLim'));
    if in3D
        delz = .01*diff(get(cax,'ZLim'));
    end

    if in3D
        varTxtHndl = text(coefs(:,1)+delx,coefs(:,2)+dely,coefs(:,3)+delz,varlabs);
    else
        varTxtHndl = text(coefs(:,1)+delx,coefs(:,2)+dely,varlabs);
    end
    set(varTxtHndl,'tag','varlabel');
end

if ~isempty(scores)
    % Scale the scores so they fit on the plot, and change the sign of
    % their coordinates according to the sign convention for the coefs.
    scores = (scores ./ max(abs(scores(:)))) .* repmat(colsign, n, 1);
    
    % Create separate objects for each row of SCORES.
    nans = NaN(n,1);
    ptx = [scores(:,1) nans]';
    pty = [scores(:,2) nans]';
    % Plot a point for each observation, and label them.
    if in3D
        ptz = [scores(:,3) nans]';
        obsHndl = line(ptx,pty,ptz, 'Color','r', 'Marker','.', plotArgs{:}, 'LineStyle','none');
    else
        obsHndl = line(ptx,pty, 'Color','r', 'Marker','.', plotArgs{:}, 'LineStyle','none');
    end
    if ~isempty(obslabs)
        if ~(ischar(obslabs) && (size(obslabs,1) == n)) && ...
                           ~(iscellstr(obslabs) && (numel(obslabs) == n))
            error('stats:biplot:InvalidObsLabels', ...
                  ['The ''obslabels'' parameter value must be a character array or ' ...
                   'a cell array\nof strings with one label for each row of SCORES.']);
        end
    end
    set(obsHndl,'tag','obsmarker');
    set(obsHndl,{'UserData'},num2cell((1:n)'));
    hgaddbehavior(obsHndl,dataCursorBehaviorObj);
end

% Plot axes and label the figure.
if ~ishold
    view(d), grid on;
    if in3D
        axisHndl = line([-1 1 NaN 0 0 NaN 0 0],[0 0 NaN -1 1 NaN 0 0],[0 0 NaN 0 0 NaN -1 1], 'Color','black');
    else
        axisHndl = line([-1 1 NaN 0 0],[0 0 NaN -1 1], 'Color','black');
    end
    set(axisHndl,'tag','axisline');
    xlabel('Component 1');
    ylabel('Component 2');
    if in3D
        zlabel('Component 3');
    end
end

if nargout > 0
    h = [varHndl; varTxtHndl; obsHndl; axisHndl];
end

    % -----------------------------------------
    function dataCursorText = dataCursorCallback(obj,eventObj)
    clickPos = get(eventObj,'Position');
    clickTgt = get(eventObj,'Target');
    clickNum = get(clickTgt,'UserData');
    switch get(clickTgt,'tag')
    case 'obsmarker'
        if isempty(obslabs)
            clickLabel = ['Observation ' num2str(clickNum)];
        elseif ischar(obslabs)
            clickLabel = obslabs(clickNum,:);
        elseif iscellstr(obslabs)
            clickLabel = obslabs{clickNum};
        end
        dataCursorText = {clickLabel ['X: ' num2str(clickPos(1))] ['Y: ' num2str(clickPos(2))]};
    case {'varmarker' 'varline'}
        if isempty(varlabs)
            clickLabel = ['Variable ' num2str(clickNum)];
        elseif ischar(varlabs)
            clickLabel = varlabs(clickNum,:);
        elseif iscellstr(varlabs)
            clickLabel = varlabs{clickNum};
        end
        dataCursorText = {clickLabel ['X: ' num2str(clickPos(1))] ['Y: ' num2str(clickPos(2))]};
    otherwise
        dataCursorText = {['X: ' num2str(clickPos(1))] ['Y: ' num2str(clickPos(2))]};
    end
    if in3D
        dataCursorText{end+1} = ['Z: ' num2str(clickPos(3))];
    end
    end % dataCursorCallback

end % biplot
