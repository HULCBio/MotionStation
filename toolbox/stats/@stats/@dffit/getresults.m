function txt = getresults(hFit)
%GETRESULTS Return text summarizing the results of the fit

%   $Revision: 1.1.6.5 $  $Date: 2004/01/24 09:32:47 $
%   Copyright 2003-2004 The MathWorks, Inc.

% Get text describing support of this fit
spt = hFit.support;
distspec = hFit.distspec;

% First see if inequalities are strict
if isempty(distspec)
   closedbound = [0 0];
else
   closedbound = distspec.closedbound;
end
ops = {'<' '<='};
op1 = ops{closedbound(1)+1};
op2 = ops{closedbound(2)+1};

if isequal(spt,'unbounded')
   spt = '-Inf < y < Inf';
elseif isequal(spt,'positive')
   spt = sprintf('0 %s y %s Inf', op1, op2);
else
   spt = sprintf('%g %s y %s %g', spt(1), op1, op2, spt(2));
end


% Get a cell array with lines that depend on the fit type
if isequal(hFit.fittype, 'smooth')
   t = getsmoothresults(hFit,spt);
else
   t = getparamresults(hFit,spt);
end

% Create a text string from this information
txt = '';
for j=1:length(t)
   a = t{j};
   for k=1:size(a,1)
      txt = sprintf('%s\n%s',txt,a(k,:));
   end
end

% Remove leading newline
nl = sprintf('\n');
if isequal(nl, txt(1:length(nl)))
   txt(1:length(nl)) = [];
end


% ------------------------------------
function t = getsmoothresults(hFit,spt)
%GETSMOOTHRESULTS Get results for smooth fit
% Fill cell array with some summary information
t = cell(1,4);
t{1} = sprintf('Kernel:     %s', hFit.kernel);
t{2} = sprintf('Bandwidth:  %g', hFit.bandwidth);
t{3} = sprintf('Domain:     %s', spt);


% ------------------------------------
function t = getparamresults(hFit,spt)
%GETPARAMRESULTS Get results for parametric fit
% Fill cell array with some summary information
t = cell(1,7);
dist = hFit.distspec;
t{1} = sprintf('Distribution:    %s', dist.name);
if isempty(hFit.loglik)
   t{2} = '';
else
   t{2} = sprintf('Log likelihood:  %g', hFit.loglik);
end
t{3} = sprintf('Domain:          %s', spt);
if isempty(dist.statfunc)
   t{4} = ' ';
else
   pcell = num2cell(hFit.params);
   [distmean,distvar] = feval(dist.statfunc,pcell{:});
   t{4} = sprintf('Mean:            %g\nVariance:        %g\n', ...
                  distmean,distvar);
end

% Add the parameter names, estimates, and standard errors
nparams = length(dist.pnames);
if isempty(hFit.pcov)
   t{5} = maketable('Parameter', dist.pnames, {'Estimate'}, hFit.params(:));
else
   t{5} = maketable('Parameter', dist.pnames, {'Estimate' 'Std. Err.'}, ...
                    [hFit.params(:) sqrt(diag(hFit.pcov))]);
end

% Add the covariance matrix, if any
if ~isempty(hFit.pcov)
   t{6} = sprintf('\nEstimated covariance of parameter estimates:');
   t{7} = maketable(' ', dist.pnames, dist.pnames, hFit.pcov);
end


% -----------------
function t = maketable(rcname, rnames, cnames, data)
%MAKETABLE Make display of a table with row and column names

r = size(data,1);
c = size(data,2);

% Provide empty column names if necessary
if isempty(rcname) && ~isempty(cnames)
   rcname = ' ';
elseif isempty(cnames) && ~isempty(rcname)
   cnames = repmat({' '},1,c);
end

% Blanks to go between columns
blanks = repmat(' ', r+~(isempty(cnames) | isempty(rcname)), 2);

if isempty(cnames)
   % Create body of table without column names
   t = num2str(data(:,1),'%10g');
   for j=2:c
      t = [t, blanks, num2str(data(:,j),'%10g')];
   end
else
   % Create body of table with column names
   t = strvcat(cnames{1}, num2str(data(:,1),'%10g'));
   for j=2:c
      t = [t, blanks, strvcat(cnames{j}, num2str(data(:,j),'%10g'))];
   end
end

if ~isempty(rcname)
   rnames = strvcat(rcname, rnames{:});
   t = [rnames, blanks, t];
end
