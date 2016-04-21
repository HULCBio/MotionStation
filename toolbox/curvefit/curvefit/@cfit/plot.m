function H = plot(obj,varargin)
%PLOT  PLOT a CFIT object.
%   PLOT(F) plots F over the x range of the current axes, if any, or
%   otherwise over the range of the data used in the fit.
%
%   PLOT(F,XDATA,YDATA) plots YDATA versus XDATA and plots F over the range of
%   XDATA.
%
%   PLOT(F,XDATA,YDATA,EXCLUDEDATA) plots the excluded data in a different
%   color. EXCLUDEDATA is a logical array where 1 represents an outlier.
%
%   PLOT(F,'S1',XDATA,YDATA,'S2',EXCLUDEDATA,'S3') uses the strings
%   'S1', 'S2', and 'S3' to control the line types, plotting symbols,
%   and colors for the preceeding line.  Any of these strings may be
%   omitted.
%
%   PLOT(F,...,'PTYPE')
%   PLOT(F,...,'PTYPE',CONFLEV)
%   PLOT(F,...,'PTYPE1',...,'PTYPEN',CONFLEV) control the plot type
%   and confidence level.  CONFLEV is a positive value less than 1
%   and has a default of 0.95 (for 95% confidence).  'PTYPE' can be
%   any of the following strings, or a cell array of several of
%   these strings:
%     'fit'         plot the data and fitted curve (default)
%     'predfunc'    same as 'fit' with prediction bounds for function
%     'predobs'     same as 'fit' with prediction bounds for a new observation
%     'residuals'   plot the residuals, fit is the zero line
%     'stresiduals' plot standardized residuals, fit is the zero line
%     'deriv1'      plot the first derivative
%     'deriv2'      plot the second derivative
%     'integral'    plot the integral
%
%   H = PLOT(F,...) returns a vector of handles of the plotted objects.
%
%   See also PLOT, EXCLUDEDATA.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.19.2.2 $  $Date: 2004/02/01 21:39:31 $

% Read stuff out of varargin
alltypes = {'fit' 'predfunc' 'predobs' 'residuals' 'stresiduals' ...
            'deriv1' 'deriv2' 'integral'};
[err,S1,xdata,ydata,S2,outliers,S3,ptypes,conflev, errid] = ...
                                 parseinput(alltypes,varargin);
error(errid, err);

if ~isempty(outliers)
   outliers = outliers(:);
   if length(outliers) < length(xdata)
      outliers(end+1:(length(xdata)),1) = logical(zeros(length(xdata)-length(outliers),1));
   elseif length(outliers) > length(xdata)
      error('curvefit:plot:excludeDataBadLength',... 
            'EXCLUDEDATA has greater length than XDATA.')
   end
end

% Need data to compute residuals
if any(ismember(ptypes, alltypes(4:5))) && (isempty(xdata) || isempty(ydata))
   error('curvefit:plot:cannotPlotResids', ...
         'Cannot plot residuals if XDATA and YDATA are missing or empty');
end

% Sort data by X value
if ~isempty(xdata) && ~isempty(ydata)
   if any(diff(xdata)<0)
      [xdata,idx]=sort(xdata);
      ydata = ydata(idx);
      if ~isempty(outliers)
         outliers = outliers(idx);
      end
   end
   xlim = [xdata(1), xdata(end)];

% If no input X data, figure out the appropriate X range
elseif isempty(xdata) && isempty(ydata)
   ax = get(gcf,'CurrentAxes');
   if (~isempty(ax))
      xlim = get(ax,'xlim');
   elseif ~isempty(obj.xlim)
      xlim = obj.xlim;
   else
      xlim = [-pi, pi];
   end
end

% Compute values of the fitted function if needed
minx = xlim(1);
xfit = minx + .001*diff(xlim)*(0:1000)';
if ~isempty(xdata)
   xfit = [xfit; xdata(:)];
   xfit = sort(xfit);
   xfit(diff(xfit)==0) = [];
end
yfit = [];
d1y = [];
if ismember(alltypes{2},ptypes)
   try
      [yconf,yfit] = predint(obj,xfit,conflev,'functional');
   catch
      error('curvefit:plot:predictionBndsError', ...
            'Error evaluating prediction bounds:\n%s',lasterr);
   end
end
if ismember(alltypes{3},ptypes)
   try
      [ypred,yfit] = predint(obj,xfit,conflev,'observation');
   catch
      error('curvefit:plot:predictionBndsError', ...
            'Error evaluating prediction bounds:\n%s',lasterr);
   end
end
if isempty(yfit) && ismember(alltypes{1},ptypes)
   try
      yfit= feval(obj, xfit);
   catch
      error('curvefit:plot:cfitFncError', ...
            'Error evaluating CFIT function:\n%s',lasterr);
   end
end
if ismember(alltypes{7},ptypes)
   try
      [d1y,d2y] = differentiate(obj, xfit);
   catch
      error('curvefit:plot:cfitDerivError', ...
            'Error evaluating CFIT derivative:\n%s',lasterr);
   end
end
if isempty(d1y) && ismember(alltypes{6},ptypes)
   try
      d1y = differentiate(obj, xfit);
   catch
      error('curvefit:plot:cfitDerivError', ...
            'Error evaluating CFIT derivative:\n%s',lasterr);
   end
end
if ismember(alltypes{8},ptypes)
   try
      yint = integrate(obj, xfit, minx);
   catch
      error('curvefit:plot:cfitIntegralError', ...
            'Error evaluating CFIT integral:\n%s',lasterr);
   end
end


% Compute residuals if needed
if any(ismember(ptypes, alltypes(4:5)))   % these types involve residuals
   try
      yresid = ydata - feval(obj, xdata);
   catch
      error('curvefit:plot:evaluatingResidsError', ...
            'Error evaluating residuals:\n%s',lasterr);
   end
end

if nargout>0, H = []; end

for j=1:length(ptypes)
   if length(ptypes)>1
      subplot(length(ptypes),1,j);
   end
   thistype = ptypes{j};
   ylab = dependnames(obj);
   ylab = ylab{1};
   
   switch thistype
    case {'deriv1' 'deriv2' 'integral'}
     xpoints = [];
     ypoints = [];
     xcurve = xfit;
     if isequal(thistype,'deriv1')
        fitlab = 'first derivative';
        ycurve = d1y;
     elseif isequal(thistype,'deriv2')
        fitlab = 'second derivative';
        ycurve = d2y;
     else
        fitlab = sprintf('integral from %g to x',minx);
        ycurve = yint;
     end
     ubound = [];
     lbound = [];

    case {'fit' 'predfunc' 'predobs'}
     xpoints = xdata;
     ypoints = ydata;
     xcurve = xfit;
     ycurve = yfit;
     fitlab = 'fitted curve';
     switch thistype
      case 'fit'
       ubound = [];
       lbound = [];
      case 'predfunc'
       ubound = yconf(:,2);
       lbound = yconf(:,1);
      case 'predobs'
       ubound = ypred(:,2);
       lbound = ypred(:,1);
     end
     
    case {'residuals' 'stresiduals'}
     xpoints = xdata;
     xcurve = xfit;
     ycurve = zeros(size(xfit));
     ubound = [];
     lbound = [];
     fitlab = 'zero line';
     switch thistype
      case 'residuals'
       ypoints = yresid;
       ylab = sprintf('%s residual',ylab);
      case 'stresiduals'
       sigma = std(yresid);
       if ~isempty(obj.dfe) && obj.dfe>0
          sigma = sigma * sqrt((length(yresid)-1)/obj.dfe);
       end
       ypoints = yresid ./ sigma;
       ylab = sprintf('%s standardized residual',ylab);
     end
   end

   % Plot whatever we have now
   if isempty(xpoints) && isempty(ypoints)
      handles = plot(xcurve,ycurve,S1);
      legh = handles;
      legtxt = {fitlab};
   elseif isempty(outliers)
      handles = plot(xpoints,ypoints,S2, xcurve,ycurve,S1);
      legh = handles;
      legtxt = {'data',fitlab};
   else
      handles = plot(xpoints(~outliers),ypoints(~outliers),S2,...
                     xpoints(outliers),ypoints(outliers),S3,...
                     xcurve,ycurve,S1);
      legh = handles;
      legtxt = {'data','excluded data',fitlab};
   end   

   % Add bounds if requested and available
   if ~isempty(lbound)
      washold = ishold;
      hold on;
      h = plot(xcurve,lbound,S1, xcurve,ubound,S1);
      set(h,'LineStyle',':');
      if ~washold, hold off; end
      handles = [handles; h(:)];
      legh = [legh; h(1)];
      legtxt{length(legtxt)+1} = 'prediction bounds';
   end
   
   xlabel(indepnames(obj));
   if ismember(thistype, {'fit' 'predfunc' 'predobs'})
      ylabel(ylab)
   end
   updatelegend(legh, legtxt);

   if nargout > 0
      H = [H; handles(:)];
   end
end


% --------- helper function to parse inputs
function [err,S1,xdata,ydata,S2,outliers,S3,ptypes,conflev,errid] = ...
                                                  parseinput(alltypes,C)
% PARSEINPUT Parse varargin cell array into variables needed here

% Set up defaults
err = '';
errid = '';
S1 = 'r-';
S2 = 'b.';
S3 = 'g+';
outliers = [];
xdata = [];
ydata = [];
nc = length(C);
conflev = 0.95;
ptypes = {};
argnum = 2:(1+length(C));

% Pick inputs apart one at a time

% First check for ptypes somewhere in the argument list
wasptype = logical(zeros(1,nc));
for j=1:nc
   t = C{j};
   if ischar(t)
      p = getptype(t,alltypes);
      if ~isempty(p)
         ptypes{length(ptypes)+1} = p;
         wasptype(j) = 1;
      end
   elseif iscell(t)
      wasptype(j) = 1;
      for k=1:length(t)
         p = getptype(t{k},alltypes);
         if ~isempty(p)
            ptypes{length(ptypes)+1} = p;
         else
            err = 'Cell array does not contain valid plot types.';
            errid = 'curvefit:plot:invalidPlotTypes';
            return
         end
      end
   end
end

C(wasptype) = [];
argnum(wasptype) = [];
nc = length(C);

% Check for a confidence level if there were plot types before the end
if any(wasptype) && wasptype(end)==0
   t = C{end};
   if isnumeric(t) && numel(t)==1 && t>0 && t<1
      conflev = t;
      C(end) = [];
      nc = nc-1;
   else
      err = 'Confidence level (last argument) must satisfy 0<CONFLEV<1';
      errid = 'curvefit:plot:invalidConfLevel';
      return
   end
end

% Done if there's nothing left
if length(ptypes)==0, ptypes = {'fit'}; end
if (nc == 0), return; end

% Get fit line type and color
j = 1;
if (ischar(C{j}))
   S1 = C{j}; j = j+1;
end
if (nc < j), return, end

% Get x and y data
if (nc < j+1)
   err = 'Must specify both XDATA and YDATA.';
   errid = 'curvefit:plot:mustSpecifyBothXY';
   return
end
xdata = C{j}; j = j+1;
ydata = C{j}; j = j+1;
if (nc < j), return, end

% Get data line type and color
if (ischar(C{j}))
   S2 = C{j}; j = j+1;
end
if (nc < j), return, end

% Get outliers
outliers = C{j}; j = j+1;
if (nc < j), return, end

% Get outlier line type and color
if (ischar(C{j}))
   S3 = C{j}; j = j+1;
end

if j<=length(C)
   err = sprintf('Argument %d is incorrect', argnum(j));
   errid = 'curvefit:plot:incorrectArg';
end

% --------------- helper function for legend
function updatelegend(h,oldstr)
% UPDATELEGEND Update legend with labels for new plot items
%    H = handles to new items
%    VARARGIN has one label per element of H

% Get old legend handles and strings
[legh,objh,oldh,str] = legend(gca);

% Watch out for handles that have been deleted
if any(~ishandle(oldh))
   if length(oldh)==length(str)
      t = ishandle(oldh);
      oldh = oldh(t);
      str = str(t);
   end
end

% Combine old ones (if any) with new ones
n = length(str);
if n==0
   str = oldstr;
else
   h = [oldh(:); h(:)];
   for j=length(oldstr):-1:1
      str{n+j} = oldstr{j};
   end
end

% Create new legend with combined stuff
legend(h,str);


% --------------- helper function to decode plot types
function ptype = getptype(t,alltypes)
%GETPTYPE Get a plot type from a string

k = find(strncmpi(t,alltypes,3));
if length(k)>1
   kk = find(strncmpi(t,alltypes(k),6));
   k = k(kk);
end
if length(k)==0
   ptype = '';
elseif length(k)==1
   ptype = alltypes{k};
else
   error('curvefit:plot:ambiguousPlotType', ...
          'Ambiguous plot type:  %s', t);
end
