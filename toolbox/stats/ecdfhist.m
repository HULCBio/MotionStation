function [Nout,Cout] = ecdfhist(F,X,varargin)
%ECDFHIST Create histogram from ecdf output.
%   N = ECDFHIST(F,X) takes a vector F of empirical cdf values and a vector
%   X of evaluation points, and returns a vector N containing the heights of
%   histogram bars for 10 equally spaced bins.  The bar heights are computed
%   from the increases in the empirical cdf, and are normalized so the area
%   for each bar represents the probability for the corresponding interval.
%   If F is computed from a censored sample, the total probability may be less
%   than 1.  In contrast, HIST produces bars whose heights are bin counts and
%   whose areas do not represent probabilities.
%
%   N = ECDFHIST(F,X,M), where M is a scalar, uses M bins.
%
%   N = ECDFHIST(F,X,C), where C is a vector, uses bins with centers
%   specified by C.
%
%   [N,C] = ECDFHIST(...) also returns the position of the bin centers in C.
%
%   ECDFHIST(...) without output arguments produces a histogram bar plot of
%   the results.
%
%   Example:  Generate random failure times and random censoring times,
%   and compare the empirical pdf with the known true pdf:
%
%       y = exprnd(10,50,1);     % random failure times are exponential(10)
%       d = exprnd(20,50,1);     % drop-out times are exponential(20)
%       t = min(y,d);            % we observe the minimum of these times
%       censored = (y>d);        % we also observe whether the subject failed
%
%       % Calculate the empirical cdf and plot a histogram from it
%       [f,x] = ecdf(t,'censoring',censored);
%       ecdfhist(f,x);
%
%       % Superimpose a plot of the known true pdf
%       hold on;
%       xx = 0:.1:max(t); yy = exp(-xx/10)/10; plot(xx,yy,'g-');
%       hold off;
%
%   See also ECDF, HIST, HISTC.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.6 $  $Date: 2004/01/24 09:33:24 $

% Accept an axes as the first arg, and plot into it.
if nargin>0 && isscalar(F) && ishandle(F)
    % Get the axes, and shift the remaining args down by one.
    cax = F;
    F = X;
    if nargin > 2
        X = varargin{1};
        varargin = varargin(2:end);
    end
    nargs = nargin - 1;
else
    cax = [];
    nargs = nargin;
end

if nargs<2
    error('stats:ecdfhist:TooFewInputs','Requires both F and X.');
end

% Inputs should look like they came from ecdf.
if ischar(F) | ischar(X)
    error('stats:ecdfhist:NotNumeric',...
          'Input arguments must be numeric.')
end
if numel(F)~=length(F) || numel(X)~=length(X)
    error('stats:ecdfhist:VectorRequired',...
          'Both F and X must be vectors produced by the ecdf function.');
elseif length(F)<2 || length(X)<2
    error('stats:ecdfhist:TooFewElements',...
          'Both F and X must have two or more elements.');
elseif any(diff(X)<0)
    error('stats:ecdfhist:NotSorted','X must be non-decreasing.');
end

% For convenience, accept F as a survivor function by converting to cdf
wassurv = (F(1)==1);
if wassurv
    F = 1-F;
end
diffF = diff(F);
if any(diff(F)<0)
    if wassurv
        error('stats:ecdfhist:NotSurvivor',...
              'The survivor function F must be non-increasing')
    else
        error('stats:ecdfhist:NotCdf','The cdf F must be non-decreasing')
    end
end

% Chop off extra 1st X value, then get min/max.
X = X(2:end);
lo = min(X);
hi = max(X);

% May have bin count, bin centers, or bin edges.  Default is 10 bins.  If
% third arg is a string, it specifies how to interpret the fourth arg as a
% bin specification.  If third arg is a scalar, assume nbins.  Otherwise,
% assume ctrs.
useCenters = true;
if nargs < 3
    binSpec = 'nbins';
    nbins = 10;
else
    binSpec = varargin{1};
    if ischar(binSpec)
        if nargs < 4
            error('stats:ecdfhist:TooFewInputs', ...
                  'Wrong number of input arguments.');
        end
        switch binSpec
        case 'ctrs'  % ecdfhist(F,X,'ctrs',C)
            ctrs = varargin{2}(:)'; % force a row
        case 'edges' % ecdfhist(F,X,'edges',E)
            edges = varargin{2}(:)'; % force a row
            useCenters = false;
        case 'nbins' % ecdfhist(F,X,'nbins',M)
            nbins = varargin{2};
        otherwise
            error('stats:ecdfhist:BadBinSpec', ...
                  'You must specify ''nbins'', ''ctrs'', or ''edges''.');
        end
    elseif length(binSpec) == 1  % ecdfhist(F,X,M)
        nbins = binSpec;
        binSpec = 'nbins';
    else                         % ecdfhist(F,X,C)
        ctrs = binSpec(:)'; % force a row
        binSpec = 'ctrs';
    end
end

% Translate the bin spec into bin centers and edges.
switch binSpec
case 'nbins'
    % If the bin count is specified:
    if lo == hi
        lo = lo - floor(nbins/2) - 0.5;
        hi = hi + ceil(nbins/2) - 0.5;
    end
    binwidth = (hi - lo) ./ nbins;
    edges = lo + binwidth*(0:nbins);
    edges(length(edges)) = hi;
    C = edges(1:end-1) + binwidth/2;
case 'ctrs'
    % Bin centers specified.  Create edges midway between the centers, and
    % symmetric about the extreme centers.
    C = ctrs;
    binwidth = diff(C);
    if any(binwidth<=0)
        error('stats:ecdfhist:NotSorted',...
              'The vector C of bin centers must be increasing.');
    end
    binwidth = [binwidth binwidth(end)];
    edges = [C(1)-binwidth(1)/2 C+binwidth/2];
    % Make sure the edges span the data.
    edges(1) = min(edges(1),lo);
    edges(end) = max(edges(end),hi);
case 'edges'
    % Bin edges are specified.
    binwidth = diff(edges);
    if any(binwidth<=0)
        error('stats:ecdfhist:NotSorted',...
              'The vector E of bin edges must be increasing.');
    end
    if nargout > 1
        % Create centers that have the edges midway between them.
        C = zeros(size(binwidth));
        C(1) = edges(1) + binwidth(1)/2;
        for j = 2:length(C)
            C(j) = 2*edges(j) - C(j-1);
        end
        % It may not be possible to find centers for which the edges are
        % midpoints.  Warn if that's the case.
        if any(C <= edges(1:end-1)) || ...
           abs(C(end) - (edges(end)-binwidth(end)/2)) > 1000*eps(binwidth(end));
            warning('stats:ecdfhist:InconsistentEdges', ...
                    'Cannot compute centers that are consistent with EDGES.');
            C = edges(1:end-1) + binwidth/2;
        end
    end
    % The edges may or may not span the data.
    if (lo < edges(1)) || (edges(end) < hi)
        warning('stats:ecdfhist:DataNotSpanned',...
                'The vector E of bin edges does not span the range of X.');
    end
end

% Update bin widths for internal bins
binwidth = diff(edges);
nbins = length(edges) - 1;

if useCenters
    % Shift bins so the internal is ( ] instead of [ ).
    edges = edges + eps(edges);
    % Map each jump location to a bin number. -Inf accounts for the above
    % shift, +Inf keeps things out of histc's degenerate rightmost bin.
    [ignore,binnum] = histc(X,[-Inf edges(2:end-1) Inf]);
else
    % Map each jump location to a bin number.  Only jumps that are within
    % the closed interval from edges(1) to edges(end) get counted.
    [ignore,binnum] = histc(X,edges);
    % Merge histc's degenerate rightmost bin with the last "real" bin, and
    % ignore anything out of range.
    binnum(binnum==nbins+1) = nbins;
    if any(binnum==0)
        diffF(binnum==0) = [];
        binnum(binnum==0) = [];
    end
end

% Compute the probability for each bin
binnum = binnum(:);
P = accumarray([ones(size(binnum)),binnum],diffF,[1,nbins]);

% Convert to bar heights
N = (P ./ binwidth);

% Plot if no outputs requested
if nargout == 0
    if isempty(cax), cax = gca; end
    if useCenters
        h = bar(cax,C,N,'hist');
        % Make sure the first and last bars extend to full width of the
        % data.  Setting the vertices also updates the XData property.
        v = get(h,'Vertices');
        v(1:3,1) = edges(1);
        v(end-2:end,1) = edges(end);
        set(h,'Vertices',v);
    else
        % For edges, we'll use the histc version of bar.  But we'll trick
        % it into making nbins bars instead of nbins+1, because we don't
        % want that extra last one.  We won't tell it about the (nbins+1)st
        % edge, and won't tack on a zero for the (nbins+1)st count.  It
        % will make the last bar the same size as the penultimate one.
        h = bar(cax,edges(1:end-1), N, 'histc');
        % Now make that last bar have the correct upper edge.
        v = get(h,'Vertices');
        v(end-2:end,1) = edges(end);
        set(h,'Vertices',v);
        % Plus if there's markers, put up another at the last edge.
        children = get(get(h,'parent'),'children');
        if length(children) > 1
            set(children(1),'XData',edges,'Ydata',zeros(1,nbins+1));
        end
    end
else
    Nout = N;
    if nargout>=2
        Cout = C;
    end
end
