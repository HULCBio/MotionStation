function [settings, X] = cordexch(nfactors,nruns,model,varargin)
%CORDEXCH D-Optimal design of experiments - coordinate exchange algorithm.
%   [SETTINGS, X] = CORDEXCH(NFACTORS,NRUNS,MODEL) generates a D-optimal
%   design having NRUNS runs for NFACTORS factors.  SETTINGS is the
%   matrix of factor settings for the design, and X is the matrix of
%   term values (often called the design matrix).  MODEL is an optional
%   argument that controls the order of the regression model.
%   MODEL can be any of the following strings:
%
%     'linear'        constant and linear terms (the default)
%     'interaction'   includes constant, linear, and cross product terms.
%     'quadratic'     interactions plus squared terms.
%     'purequadratic' includes constant, linear and squared terms.
%
%   Alternatively MODEL can be a matrix of term definitions as
%   accepted by the X2FX function.
%
%   [SETTINGS, X] = CORDEXCH(...,'PARAM1',VALUE1,'PARAM2',VALUE2,...)
%   provides more control over the design generation through a set of
%   parameter/value pairs.  Valid parameters are the following:
%
%      Parameter    Value
%      'display'    Either 'on' or 'off' to control display of
%                   iteration counter (default = 'on').
%      'init'       Initial design as an NRUNS-by-NFACTORS matrix
%                   (default is a randomly selected set of points).
%      'maxiter'    Maximum number of iterations (default = 10).
%
%   The CORDEXCH function searches for a D-optimal design using a coordinate
%   exchange algorithm.  It creates a starting design, and then iterates by
%   changing each coordinate of each design point in an attempt to reduce
%   the variance of the coefficients that would be estimated using this
%   design.
%
%   See also ROWEXCH, DAUGMENT, DCOVARY, X2FX.

%   The undocumented parameters 'start' and 'covariates' are used when
%   this function is called by the daugment and dcovary functions to
%   implement D-optimal designs with fixed rows or columns.
   
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.14.2.3 $  $Date: 2004/01/16 20:09:07 $

pnames = {'start' 'display' 'init' 'maxiter' 'covariates'};
pdefaults = {zeros(0,nfactors) 'on' [] 10 []};
[eid,emsg,startdes,dodisp,settings,maxiter,covariates] = ...
                  statgetargs(pnames, pdefaults, varargin{:});
if ~isempty(eid)
   error(sprintf('stats:cordexch:%s',eid),emsg);
end
quiet = isequal(dodisp,'off');

% Generate random starting design if none supplied
if isempty(settings)
   settings = unifrnd(-1,1,nruns,nfactors);
elseif size(settings,2)~=nfactors
   error('stats:cordexch:BadStart',...
         'Initial design must have one column for each factor.');
elseif size(settings,1)~=nruns
   error('stats:cordexch:BadStart',...
         'Initial design must have one row for each run.');
end

% Add initial set of rows never to change, if any
[nobs,startcols] = size(startdes);
if startcols>0 & startcols~=nfactors
   error('stats:cordexch:BadStart',...
         'Starting design must have one column for each factor.');
end
settings = [startdes; settings];

% Add fixed covariates, if any
if ~isempty(covariates)
   if size(covariates,1)~=nruns
      error('stats:cordexch:InputSizeMismatch',...
            'Must supply fixed covariate values for each run.');
   end
   settings = [settings covariates];
end

if nargin == 2
  model = 'linear';
end
if ~isstr(model)
   if size(settings,2) ~= size(model,2)
      error('stats:cordexch:InputSizeMismatch',...
            'The number of columns in a numeric model matrix must equal the number of factors.');
   end
   nxij = linspace(-1,1,max(model(:))+1)';
else
   nxij = (-1:1)';
end
nxijlen = length(nxij);
rowlist = zeros(nxijlen,1);

[X,flags] = x2fx(settings,model);
if size(X,2) > (size(X,1)+nobs)
   error('stats:cordexch:TooFewRuns',...
         'There are not enough runs to fit the specified model.');
end

[Q,R]=qr(X,0);

% Adjust starting design if it is rank deficient, because the algorithm
% will not proceed otherwise.
if rank(R)<size(R,2)
   warning('stats:cordexch:BadStartingDesign',...
           'Starting design is rank deficient');
   R = adjustr(R);
   wasbad = 1;
else
   wasbad = 0;
end
logdetX = 2*sum(log(abs(diag(R))));

iter = 0;
madeswitch = 1;
dcutoff = 1 + sqrt(eps);

% Create Iteration Counter Figure.
if ~quiet
   screen = get(0,'ScreenSize');
   f = figure('Units','Pixels','Visible', 'Off', 'Menubar','none',...
       'Position',[25 screen(4)-150 300 60]);
   ax = gca;
   set(ax,'Visible','off');
   t=text(0,0.7,'Coordinate exchange iteration counter');
   set(t,'FontName','Geneva','FontSize',12);
   a = get(t,'extent');
   set(f,'Position', [25,screen(4)-150,300*a(3), 60], 'Visible', 'On');
   sfmt='Iteration %4i';
   s=sprintf(sfmt,1);
   set(f,'CurrentAxes',ax);
   h=text(0,0.2,s);
   set(h,'FontName','Geneva','FontSize',12);
end

while madeswitch > 0 & iter < maxiter
   madeswitch = 0;
   iter = iter + 1;
   
   % Update iteration counter.
   if ~quiet & ishandle(h)
      set(h,'String',sprintf(sfmt,iter));
      drawnow;
   end
   
   %Loop over rows of factor settings matrix.
   for row = (nobs+1):(nobs+nruns)
      fx = X(row,:);
      E = [];
      %Loop over columns of factor settings matrix.
      for col = 1:nfactors
         xij = settings(row,col);
         rowlist(:) = row;
         xnew = settings(rowlist,:);
         xnew(:,col) = nxij;
         if isnumeric(model)
            % Update affected terms only
            t = model(:,col)>0;
            fxnew = fx(ones(nxijlen,1),:);
            fxnew(:,t) = x2fx(xnew,model(t,:),flags);
         else
            % Faster to compute full design matrix
            fxnew = x2fx(xnew,model,flags);
         end

         % Compute change in determinant.
         if isempty(E)
            E = fx/R;
            dxold = E*E';
         end
         F = fxnew/R;
         dxnew = sum(F.*F,2);
         dxno  = F*E';

         d = (1 + dxnew).*(1 - dxold) + dxno.^2;

         % Find the maximum change in the determinant, switch if >1
         [d,idx] = max(d);
         if d > dcutoff
            madeswitch = 1;
            logdetX = log(d) + logdetX;
            settings(row,:) = xnew(idx,:);
            X(row,:) = fxnew(idx,:);
            fx = X(row,:);
            [Q,R] = qr(X,0);
            if wasbad
               if rank(R)<size(R,2)
                  R = adjustr(R);
               else
                  wasbad = 0;
               end
            end
            E = [];
         end
      end
   end
end
if ~quiet & ishandle(f)
   close(f);
end
     
% --------------------------------------------
function R = adjustr(R)
%ADJUSTR Adjust R a little bit so it will be non-singular

diagr = abs(diag(R));
p = size(R,2);
smallval = sqrt(eps)*max(diagr);
t = (diagr < smallval);
if any(t)
   tind = (1:p+1:p^2);
   R(tind(t)) = smallval;
end
