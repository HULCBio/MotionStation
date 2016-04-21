function [no,xo] = hist(varargin)
%HIST  Histogram.
%   N = HIST(Y) bins the elements of Y into 10 equally spaced containers
%   and returns the number of elements in each container.  If Y is a
%   matrix, HIST works down the columns.
%
%   N = HIST(Y,M), where M is a scalar, uses M bins.
%
%   N = HIST(Y,X), where X is a vector, returns the distribution of Y
%   among bins with centers specified by X.  Note: Use HISTC if it is
%   more natural to specify bin edges instead.
%
%   [N,X] = HIST(...) also returns the position of the bin centers in X.
%
%   HIST(...) without output arguments produces a histogram bar plot of
%   the results.
%
%   HIST(AX,...) plots into AX instead of GCA.
%
%   Class support for inputs Y, X: 
%      float: double, single
%
%   See also HISTC.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.20.4.5 $  $Date: 2004/03/09 16:16:21 $

% Parse possible Axes input
error(nargchk(1,inf,nargin));
[cax,args,nargs] = axescheck(varargin{:});

y = args{1};

if nargs == 1
    x = 10;
else
    x = args{2};
end

if min(size(y))==1, y = y(:); end
if ischar(x) || ischar(y)
    error('MATLAB:hist:InvalidInput', 'Input arguments must be numeric.')
end

[m,n] = size(y);
if isempty(y),
    if length(x) == 1,
       x = 1:double(x);
    end
    nn = zeros(size(x)); % No elements to count
else
    if length(x) == 1
        miny = min(min(y));
        maxy = max(max(y));
    	  if miny == maxy,
    		  miny = miny - floor(x/2) - 0.5; 
    		  maxy = maxy + ceil(x/2) - 0.5;
     	  end
        binwidth = (maxy - miny) ./ x;
        xx = miny + binwidth*(0:x);
        xx(length(xx)) = maxy;
        x = xx(1:length(xx)-1) + binwidth/2;
    else
        xx = x(:)';
        miny = min(min(y));
        maxy = max(max(y));
        binwidth = [diff(xx) 0];
        xx = [xx(1)-binwidth(1)/2 xx+binwidth/2];
        xx(1) = min(xx(1),miny);
        xx(end) = max(xx(end),maxy);
    end
    nbin = length(xx);
    % Shift bins so the internal is ( ] instead of [ ).
    xx = full(real(xx)); y = full(real(y)); % For compatibility
    bins = xx + eps(xx);
    nn = histc(y,[-inf bins],1);
    
    % Combine first bin with 2nd bin and last bin with next to last bin
    nn(2,:) = nn(2,:)+nn(1,:);
    nn(end-1,:) = nn(end-1,:)+nn(end,:);
    nn = nn(2:end-1,:);
end

if nargout == 0
    if ~isempty(cax)
        bar(cax,x,nn,'hist');
    else
        bar(x,nn,'hist');
    end
else
  if min(size(y))==1, % Return row vectors if possible.
    no = nn';
    xo = x;
  else
    no = nn;
    xo = x';
  end
end
