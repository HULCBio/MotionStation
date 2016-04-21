function h = probplot(varargin)
%PROBPLOT Probability plot
%   PROBPLOT(Y) produces a normal probability plot comparing the
%   distribution of the data Y to the normal distribution.  Y can
%   be a single vector, or a matrix with a separate sample in each column.
%   The plot includes a reference line useful for judging whether the
%   data follow a normal distribution.
%
%   PROBPLOT('DISTNAME',Y) creates a probability plot for the specified
%   distribution.
%
%   PROBPLOT(Y,CENS,FREQ) or PROBPLOT('DISTNAME',Y,CENS,FREQ) requires
%   a vector Y.  CENS is a vector of the same size as Y and contains
%   1 for observations that are right-censored and 0 for observations
%   that are observed exactly.  FREQ is a vector of the same size as Y,
%   containing integer frequencies for the corresponding elements in Y.
%
%   PROBPLOT(AX,Y) takes a handle AX to an existing probability plot, and
%   adds additional lines for the samples in Y.  AX is a handle for a
%   set of axes.
%
%   PROBPLOT(...,'noref') omits the reference line.
%
%   PROBPLOT(AX,FUN,PARAMS) takes a function FUN and a set of parameters
%   PARAMS, and adds fitted lines to the axes specified by AX.  FUN is
%   a function to compute a cdf function, and is specified with @
%   (such as @weibcdf).  PARAMS is the set of parameters required to
%   evaluate FUN, and is specified as a cell array or vector.  The
%   function must accept a vector of X values as its first argument,
%   then the optional parameters, and must return a vector of cdf
%   values evaluated at X.
%
%   H=PROBPLOT(...) returns handles to the plotted lines.
%
%   See also NORMPLOT, ECDF.

%   Copyright 2003-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.9 $  $Date: 2004/03/14 15:33:05 $

% Check for a special flag at the end to skip reference lines
if nargin>0 && isequal(varargin{end},'noref')
    addrefline = false;
    varargin(end) = [];
else
    addrefline = true;
end

% Now check number of arguments, possibly after removing flag
error(nargchk(1,Inf,nargin,'struct'));

% Get probability distribution info from input name, input handle, or default
[hAxes,newdist,dist,param,varargin] = getdistname(varargin);
if length(dist)~=1
    error('stats:probplot:InvalidDistribution','Invalid distribution name.');
end

% Get some properties of this distribution
distname = dist.name;
distcode = dist.code;
if dist.uselogpp
    invcdffunc = dist.loginvfunc;
    cdffunc = dist.logcdffunc;
else
    invcdffunc = dist.invfunc;
    cdffunc = dist.cdffunc;
end

% Plot either a data sample or a user-supplied fit
if isempty(varargin)
    % Just setting up empty plot
    x = [];
    addfit = false;
elseif isnumeric(varargin{1})
    % Plot the sample or samples in X
    [x,cens,freq] = checkdata(dist,varargin{:});
    addfit = false;
elseif isequal(class(varargin{1}),'function_handle') || ischar(varargin{1})
    % Must be plotting a fit rather than a data sample
    x = [];
    addfit = true;
    fitcdffunc = varargin{1};
    if length(varargin)>=2
        if iscell(varargin{2})
            param = varargin{2};
        else
            param = num2cell(varargin{2});
        end
    end
else
    error('stats:probplot:InvalidData','Invalid Y or FUN argument.')
end

% Create probability plot of the proper type
if newdist
    hAxes = createprobplot(hAxes,distcode,distname,param,dist,...
                                 cdffunc,invcdffunc);
end

% Plot a data sample
hfit = [];
href = [];
hdata = [];
if ~isempty(x)
    % Get plotting positions and expanded x data vector for plot
    [xData,ppos] = getppos(x,cens,freq);
    hdata = adddatapoints(hAxes,xData,ppos);

    if addrefline
        % Add lines representing fits
        nsamples = size(xData,2);
        href = zeros(nsamples,1);
        for j=1:nsamples
           % Get some points on the reference line
           if isempty(cens) && isempty(freq)
              probpoints = [];
           else
              probpoints = ppos;
           end
           refxy = getrefxy(distcode,xData(:,j),probpoints,...
                                     invcdffunc,dist.uselogpp);

           if ~isempty(refxy)
              % Create a function that will put a line through these points
              %      A = y1 - x1*(y2-y1)/(x2-x1)
              %      B = (y2-y1)/(x2-x1)
              B = (refxy(2,2)-refxy(1,2)) ./ (refxy(2,1)-refxy(1,1));
              A = refxy(1,2) - refxy(1,1) .* B;
              if dist.uselogpp
                 % The reference x1 and x2 values are already on the log scale
                 linefun = @(x)(A+B*log(x));
              else
                 linefun = @(x)(A+B*x);
              end

              % Create a reference line based on this function
              href(j) = graph2d.functionline(linefun, ...
                  'Parent',hAxes);

              % Start off with reasonable default properties
              set(href(j),'XLimInclude','off','YLimInclude','off',...
                          'Color','k','LineStyle','--');
           else
              href(j) = NaN;
           end
        end
    
        % With multiple samples, make sure fit color matches data color
        if nsamples>1
            for j=1:nsamples
                if ~isnan(href(j))
                    set(href(j),'Color',get(hdata(j),'Color'));
                end
            end
        end
    end
end

% Add a fit
if addfit
    hfit = ppaddfit(hAxes,fitcdffunc,param);
end

% Now that y limits are established, define good y tick positions and labels
setprobticks(hAxes);

if nargout>0
   h = [hdata(:); href(:); hfit(:)];
end

% -------------------------------------
function hAxes = createprobplot(hAxes,dcode,dname,param,dist,cdffunc,invcdffunc);
%CREATEPROBPLOT Create an empty probability plot of a particular type

% Create a set of axes if none supplied
if isempty(hAxes)
   hAxes = cla('reset');
end

% Store information about the reference distribution
setappdata(hAxes,'ReferenceDistribution',dcode);
setappdata(hAxes,'CdfFunction',cdffunc);
setappdata(hAxes,'InverseCdfFunction',invcdffunc);
setappdata(hAxes,'DistributionParameters',param);
setappdata(hAxes,'LogScale',dist.uselogpp);
setappdata(hAxes,'DistSpec',dist);

% Add labels and a title
set(get(hAxes,'XLabel'),'String','Data');
set(get(hAxes,'YLabel'),'String','Probability');
if isempty(param)
    paramtext = '';
else
    fmt = repmat('%g,',1,length(param));
    fmt(end) = [];
    paramtext = sprintf(['(' fmt ')'],param{:});
end
set(get(hAxes,'Title'),'String',...
                     sprintf('Probability plot for %s%s distribution',...
                             dname,paramtext));

% Set X axis to log scale if this distribution uses that scale
if dist.uselogpp
   set(hAxes,'XScale','log');
end

% ------------------------------------
function hdata = adddatapoints(hAxes,x,ppos)
%ADDDATAPOINTS Add points representing data to a probability plot
%   x is already sorted

% Get information about the reference distribution
invcdffunc = getappdata(hAxes,'InverseCdfFunction');
param = getappdata(hAxes,'DistributionParameters');

% Compute y values for this distribution
q = feval(invcdffunc,ppos,param{:});

% Add to plot
hdata = line(x,q,'Parent',hAxes);

% Use log X scale if distribution requires it
xmin = min(x(1,:));
xmax = max(x(end,:));
if isequal(get(hAxes,'XScale'),'log')
    xmin = log(xmin);
    xmax = log(xmax);
    dx = 0.02 * (xmax - xmin);
    if (dx==0)
       dx = 1;
    end
    xmin = exp(xmin - dx);
    xmax = exp(xmax + dx);
    newxlim = [xmin xmax];
else
    dx = 0.02 * (xmax - xmin);
    if (dx==0)
       dx = 1;
    end
    newxlim = [xmin-dx, xmax+dx];
end
oldxlim = get(hAxes,'XLim');
set(hAxes,'XLim',[min(newxlim(1),oldxlim(1)), max(newxlim(2),oldxlim(2))]);

% Make sure they have different markers and no connecting line
markerlist = {'x','o','+','*','s','d','v','^','<','>','p','h'}';
set(hdata,'LineStyle','none',...
          {'Marker'},markerlist(1+mod((1:length(hdata))-1,length(markerlist))));

% -------------------------------------------
function setprobticks(hAxes)
%SETPROBTICKS Set the y axis tick marks to use a probability scale

invcdffunc = getappdata(hAxes,'InverseCdfFunction');
param = getappdata(hAxes,'DistributionParameters');

% Define tick locations
ticklevels = [.0001 .0005 .001 .005 .01 .05 .1 .25 .5 ...
              .75 .9 .95 .99 .995 .999 .9995 .9999];
tickloc = feval(invcdffunc,ticklevels,param{:});

% Remove ticks outside axes range
set(hAxes,'YLimMode','auto');
ylim = get(hAxes,'YLim');
t = tickloc>=ylim(1) | tickloc<=ylim(2);
tickloc = tickloc(t);
ticklevels = ticklevels(t);

% Remove ticks that are too close together
j0 = ceil(length(tickloc)/2);
delta = .025*diff(ylim);
j = j0-1;
keep = true(size(tickloc));
while(j>0)
   if tickloc(j) > tickloc(j0)-delta
      keep(j) = false;
   else
      j0 = j;
   end
   j = j-1;
end
j = j0+1;
while(j<length(tickloc))
   if tickloc(j) < tickloc(j0)+delta
      keep(j) = false;
   else
      j0 = j;
   end
   j = j+1;
end

if ~all(keep)
   tickloc = tickloc(keep);
   ticklevels = ticklevels(keep);
end
set(hAxes,'YTick',tickloc,'YTickLabel',ticklevels);

% -------------------------------------------
function [x,ppos] = getppos(x,cens,freq);
%GETPPOS Get plotting positions for probability plot

if isempty(cens) && isempty(freq)
   % Use a simple definition compatible with the censored calculation.
   % Plot sorted x(i) against (i-1/2)/n.
   % This code supports X as a matrix or a vector.
   if ~any(isnan(x(:)))
       n = size(x,1);
       ppos = ((1:n)' - 0.5) / n;
   else
       % Any NaNs in X were sorted to the bottom, so we will fill in
       % ppos values starting at the top
       ppos = nan(size(x));
       for j=1:size(x,2)
           n = sum(~isnan(x(:,j)));
           ppos(1:n,j) = ((1:n)' - 0.5) / n;
       end
   end
else
   % Compute the empirical cdf
   [fecdf,xecdf,temp1,temp2,D] = ecdf(x,'cens',cens,'freq',freq);
   
   % Create outputs with one row for each observed failure
   N = sum(min(100,D));
   xout = zeros(N,1);
   ppos = zeros(N,1);
   
   % Fill in with points equally spaced at each jump of the cdf
   % If there are M failures at x(i), plot x(i) against the M values
   % equally spaced between F(x(i)-) and F(x(i)+)
   xbase = 0;
   for j=1:length(xecdf)-1;
      Dj = D(j);
      Npts = min(100,Dj);
      rownums = xbase+(1:Npts);
      xout(rownums) = xecdf(j+1);
      ppos(rownums) = fecdf(j) + ((1:Npts)-0.5) * (fecdf(j+1)-fecdf(j)) / Npts;
      xbase = xbase + Npts;
   end
   
   % Replace old data with the new version
   x = xout;
end

% -------------------------------------------
function refxy = getrefxy(dname,x,probpoints,invcdffunc,uselogpp);
%GETREFXY Get two points on a reference line

if isempty(probpoints)
   % If there is no censoring, we get the first and third quartiles
   P1 = .25;
   P3 = .75;
   DataQ = prctile(x,100*[P1; P3]);
   DataQ1 = DataQ(1);
   DataQ3 = DataQ(2);
else
   % Get upper quartile, or as high up as we can go
   P3 = min(.75,max(probpoints));
   j3 = sum(probpoints<=P3);
   DataQ3 = x(j3);
   
   % Get lower quartile or a substitute for it
   P1 = P3/3;
   j1 = min(j3-1,sum(probpoints<=P1));
   DataQ1 = x(j1);
end

% Use log scale if necessary
if uselogpp
   DataQ1 = log(DataQ1);
   DataQ3 = log(DataQ3);
end

% Get the y values for these x values
DistrQ = feval(invcdffunc, [P1 P3]);

% Package up the points and return them
if DataQ3 > DataQ1
   refxy = [DataQ1 DistrQ(1)
            DataQ3 DistrQ(2)];
else
   refxy = [];
end

% ------------------------------------------
function hfit = ppaddfit(hAxes,cdffunc,params)
%PPADDFIT Add fit to probability plot

if nargin<3 || isempty(params)
   params = {};
elseif isnumeric(params)
   params = num2cell(params);
end

% Define function using local function handle
hfit = graph2d.functionline(@calcfit,'-userargs',{hAxes,cdffunc,params},...
                            'Parent',hAxes);

% Start off with reasonable default properties
set(hfit,'XLimInclude','off','YLimInclude','off',...
         'Color','k','LineStyle','--');

% ------------------------------------------
function fx = calcfit(x,hAxes,cdffunc,fitparams)
%CALCFIT Calculated values of function for plot

% Get y values in units of the tick mark labels
p = feval(cdffunc,x,fitparams{:});

% Get y values in units of the real y axis
invcdffunc = getappdata(hAxes,'InverseCdfFunction');
plotparams = getappdata(hAxes,'DistributionParameters');
fx = feval(invcdffunc,p,plotparams{:});

% ------------------------------------------
function [hAxes,newdist,dist,param,vin] = getdistname(vin);
%GETDISTNAME Get probability distribution info from user input

% Check for probability plot axes handle as a first argument
if numel(vin{1})==1 && ishandle(vin{1})
   hAxes = vin{1};
   if ~isequal(get(hAxes,'Type'),'axes')
      error('stats:probplot:BadHandle','Invalid axes handle.');
   end
   vin(1) = [];
else
   hAxes = [];
end

% Now get the distribution name and parameters for it
if length(vin)>0 && (ischar(vin{1}) || iscell(vin{1}))
   % Preference is to use passed-in name, if any
   dname = vin{1};
   vin(1) = [];
   newdist = true;
   
   % May be passed in as a name or a {dist,param} array
   if iscell(dname)
      dist = dname{1};
      param = num2cell(dname{2});
   elseif ischar(dname)
      dist = dfgetdistributions(dname);
      if ~isscalar(dist)
         error('stats:probplot:BadDistribution',...
               'Unknown distribution name "%s".', dname);
      elseif ~dist.islocscale
         error('stats:probplot:InappropriateDistribution',...
               ['The %s distribution requires estimated parameters,\n' ...
                'so it cannot be used to create a probability plot.'], ...
               dname);
      end
      param = {};
   else
      error('stats:probplot:BadDistribution','Bad distribution name.');
   end   
elseif isempty(hAxes)
   % Use default if no axes passed in
   dname = 'normal';
   param = {};
   newdist = true;
   dist = dfgetdistributions(dname);
else
   % Otherwise use current distribution
   dname = getappdata(hAxes,'ReferenceDistribution');
   param = getappdata(hAxes,'DistributionParameters');
   if isempty(getappdata(hAxes,'InverseCdfFunction')) || ~iscell(param)
      error('stats:probplot:BadHandle','Not a probability plot.')
   end
   newdist = false;
   dist = dfgetdistributions(dname);
end

% ------------------------------------------
function [x,cens,freq] = checkdata(dist,varargin)
%CHECKDATA Get data and check that it works with this distribution

x = varargin{1};
if length(varargin)<2
   cens = [];
else
   cens = varargin{2};
end
if length(varargin)<3
   freq = [];
else
   freq = varargin{3};
end

if ~isempty(cens) || ~isempty(freq)
    % Remove NaNs now if we have to maintain x, cens, and freq in parallel.
    % Otherwise if we don't have cens and freq, we'll deal with NaNs in x
    % as required.  X must be a vector in this case.
    [ignore1,ignore2,x,cens,freq] = statremovenan(x,cens,freq);
end

% Follow the usual convention by treating a row vector as a column
if ndims(x)>2
   error('stats:probplot:InvalidData','Y must be a vector or matrix.')
end
if size(x,1)==1
   x = x';
end
[x,sortidx] = sort(x);
[nobs,nsamples] = size(x);
if ~isempty(cens)
   if length(cens)~=nobs || ~(isnumeric(cens) || islogical(cens))
      error('stats:probplot:InputSizeMismatch',...
            'Y and CENS must have the same number of observations.')
   end
   cens = cens(sortidx);
end
if ~isempty(freq)
   if length(freq)~=nobs || ~(isnumeric(freq) || islogical(freq))
      error('stats:probplot:InputSizeMismatch',...
            'Y and FREQ must have the same number of observations.')
   end
   freq = freq(sortidx);
end

% Check match between data and distribution.
xmin = min(x(1,:));
xmax = max(x(end,:));
if xmin==dist.support(1) && ~dist.closedbound(1)
    error('stats:probplot:InappropriateDistribution',...
          'The %s distribution requires data greater than %g.',...
          dist.name,dist.support(1));
elseif xmin<dist.support(1)
    error('stats:probplot:InappropriateDistribution',...
          'The %s distribution requires data no less than %g.',...
          dist.name,dist.support(1));
elseif xmax==dist.support(2) && ~dist.closedbound(2)
    error('stats:probplot:InappropriateDistribution',...
          'The %s distribution requires data less than %g.',...
          dist.name,dist.support(2));
elseif xmax>dist.support(2)
    error('stats:probplot:InappropriateDistribution',...
          'The %s distribution requires data no greater than %g.',...
          dist.name,dist.support(2));
elseif (nsamples>1) && ~dist.islocscale
    error('stats:probplot:InappropriateDistribution',...
          'Only a single sample is allowed with the %s distribution',...
          dist.name);
elseif (~isempty(cens) || ~isempty(freq)) && (nsamples>1)
    error('stats:probplot:InvalidData',...
          'Only a single sample is allowed with censoring or frequencies.');
end
