function [h,atab,ctab,outstats] = aoctool(x,y,g,alpha,xname,yname,gname,displayopt,model)
%AOCTOOL Fits a one-way anocova model and displays an interactive graph.
%   AOCTOOL(X,Y,G,ALPHA) carries out a one-way analysis of covariance
%   (anocova) using X as the predictor, Y as the response, and G as
%   the grouping variable.  It displays three figures; one contains an
%   interactive graph of the data and prediction curves, another
%   contains an anova table, and a third contains parameter estimates.
%   The graph figure can display predictions for all groups, or
%   predictions and confidence bounds for a single group.  The confidence
%   level is 100(1-ALPHA) percent, with ALPHA=0.05 as the default.
%
%   AOCTOOL(X,Y,G,ALPHA,XNAME,YNAME,GNAME) allows you to enter the
%   names of the X, Y, and G variables.
%
%   AOCTOOL(X,Y,G,ALPHA,XNAME,YNAME,GNAME,DISPLAYOPT,MODEL) includes
%   two additional arguments.  DISPLAYOPT controls whether the graph
%   is displayed ('on', the default) or not ('off').  MODEL controls
%   the initial fit and can be one of the following numbers or
%   phrases:
%       1    'same mean'
%       2    'separate means'
%       3    'same line'
%       4    'parallel lines'
%       5    'separate lines'
%
%   [H,ATAB,CTAB,STATS] = AOCTOOL(...) returns several items.  H is a
%   vector of handles to the line objects in the plot.  ATAB and CTAB
%   are an anova table and a coefficients table.  STATS is a structure
%   containing statistics useful for performing a multiple comparison
%   of means with the MULTCOMPARE function.
%
%   You can drag the dotted white reference line in the graph figure
%   and watch the predicted values update for the current X value.
%   Alternatively, you can get a specific prediction by typing the "X"
%   value into an editable text field.  Pop-up menus let you change
%   the current value of the grouping variable or change the model. A push
%   button allows you to export variables into the base workspace.  A menu 
%   controls the confidence bounds.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.16.4.1 $  $Date: 2003/11/01 04:24:58 $

action = 'start';
if (nargin > 0), if (ischar(x)), action = x; end; end

%On initial call check for arguments, then weed out NaNs
if (strcmp(action, 'start'))
   if (nargin == 0)
      msg = sprintf(['To use AOCTOOL with your own data, type:\n' ...
                     '    aoctool(x, y, g)\n\n' ...
                     'Type "help aoctool" for more information\n\n' ...
                     'Click OK to analyze sample data.']);
      try
         s = load('carsmall');
      catch
         s = [];
      end
      hmsg = warndlg(msg, 'Analysis of Covariance');

      if (~isempty(s))
         aoctool(s.Weight, s.MPG, s.Model_Year, 0.05, 'Weight', ...
                 'MPG','Model Year');
      end
      if ishandle(hmsg), figure(hmsg); end
      return
   end

   if (nargin < 3)
      error('stats:aoctool:TooFewInputs',...
            'AOCTOOL requires at least three arguments.');
   end

   dodisp = 1;
   if (nargin >= 8 && isequal(displayopt, 'off')), dodisp = 0; end

   if (size(x,1)==1), x=x(:); end
   if (size(y,1)==1), y=y(:); end
   if (size(g,1) == 1), g = g(:); end
   n = length(x);
   if (size(g,1) ~= n) || (length(y) ~= n)
      error('stats:aoctool:InputSizeMismatch',...
           'The first three arguments must have the same number of elements.');
   end
   if (ischar(g)), g = cellstr(g); end
   
   nanrow = (isnan(x) | isnan(y));
   if (isnumeric(g))
      nanrow = (nanrow | isnan(g));
   else
      nanrow = (nanrow | strcmp(g,''));
   end
   
   wasnan = zeros(size(y));
   if (any(nanrow))
      wasnan(nanrow) = 1;
      y(nanrow) = [];
      x(nanrow) = [];
      g(nanrow,:) = [];
      if (dodisp)
         disp(sprintf(...
          'Note: %d observations with missing values have been removed.', ...
                   sum(nanrow(:))));
      end
   end

   [gi,gn] = grp2idx(g);
   ngroups = size(gn,1);
   n = length(x);
   curgroup = 0;

   if (var(x) == 0)
      error('stats:aoctool:BadX','X variable has zero variance.');
   end
   if (ngroups < 2)
      error('stats:aoctool:BadGroup',...
            'Grouping variable G must have at least two groups.');
   end
end

%On recursive calls get all necessary handles and data.
if ~strcmp(action,'start')

   if nargin == 2, flag = y; end
   
   aoc_fig = gcbf;       % callback from aoc figure or from dialog
   if (isequal(get(gcbf,'Tag'), 'aocdlg'))
      aoc_fig = get(gcbf, 'UserData');
   end
   if (~isequal(get(aoc_fig,'Tag'), 'aocfig')), return; end
   ud = get(aoc_fig,'Userdata');
   
   uiHandles    = ud.uicontrolHandles;
   x_field      = uiHandles.x_field;
   y_field      = uiHandles.y_field;
   grouppopup   = uiHandles.grouppopup;
   modelpopup   = uiHandles.modelpopup;

   stats        = ud.stats;
   x            = ud.data(:,1);
   y            = ud.data(:,2);
   gi           = ud.data(:,3);
   model        = ud.model;
   alpha        = ud.alpha;
   xmat         = ud.xmat;
   aoc_axes     = ud.axes;
   xname        = ud.xname;
   yname        = ud.yname;
   gname        = ud.gname;
   wasnan       = ud.wasnan;
   badbeta      = ud.badbeta;
   oldgroup     = ud.curgroup;

   gn           = get(grouppopup, 'String');
   gn           = gn(2:end,:);
   ngroups      = size(gn, 1);
   curgroup     = get(grouppopup, 'Value') - 1;
   
   fitline        = ud.plotHandles.fitline;
   dataline       = ud.plotHandles.dataline;
   reference_line = ud.plotHandles.reference_line;
   
   % See if there are other figures connected to this one
   coef_fig = checkfig(ud.coef_fig, aoc_fig);
   aov_fig  = checkfig(ud.aov_fig,  aoc_fig);
   
   xrange = get(aoc_axes,'XLim');
   yrange = get(aoc_axes,'YLim');

   newx = str2double(get(x_field,'String'));  
   newy = str2double(get(y_field(1),'String'));  
   deltay = str2double(get(y_field(2),'String'));
end

switch action

 case 'start',

  if nargin < 4 || isempty(alpha), alpha = 0.05; end

  if (nargin < 5),   xname = ''; end
  if isempty(xname), xname = inputname(1); end
  if isempty(xname), xname = 'X Value'; end  

  if (nargin < 6),   yname = ''; end
  if isempty(yname), yname = inputname(2); end
  if isempty(yname), yname = 'Y Value'; end

  if (nargin < 7),   gname = ''; end
  if isempty(gname), gname = inputname(3); end
  if isempty(gname), gname = 'Group'; end  

  if (nargin < 9)
     model = 5;
  else
     if isequal(model, 'same mean')
        model = 1;
     elseif isequal(model, 'separate means')
        model = 2;
     elseif isequal(model, 'same line')
        model = 3;
     elseif isequal(model, 'parallel lines')
        model = 4;
     elseif isequal(model, 'separate lines')
        model = 5;
     elseif ~(isequal(model,1)||isequal(model,2)||isequal(model,3) ...
             ||isequal(model,4)||isequal(model,5))
             error('stats:aoctool:BadModel','Bad model specification.');
     end
  end

  if (dodisp)
     % Create plots.
     [ud.plotHandles, newx] = makeplots(x, y, g, ngroups);
     aoc_fig = gcf;
     aoc_axes = gca;
     ud.axes = aoc_axes;    % plot axes, not legend axes
     fitline = ud.plotHandles.fitline;
     dataline = ud.plotHandles.dataline;
     reference_line = ud.plotHandles.reference_line;
     ud.gcolors = get(dataline, 'Color');

     % Create uicontrols.
     curgroup = 0;
     ud.uicontrolHandles = makeuicontrols(newx, curgroup, gn, xname,...
                                          yname, gname, model);
     y_field      = ud.uicontrolHandles.y_field;
  else
     dataline = [];
     fitline = [];
  end

  % Fit data.
  p = 2*ngroups + 2;
  xmat = ones(n,p);
  idum = eye(ngroups);
  xmat(:,2:(ngroups+1)) = idum(gi,:);
  xmat(:,ngroups+2) = x;
  xmat(:,ngroups+3:end) = xmat(:,2:(ngroups+1)) .* x(:,ones(1, ...
                                                  ngroups));

  % If we get here we are guaranteed >=2 groups, some x variance
  badbeta = false(ngroups+1, 1);
  tmp = rank(xmat(:,[(2:(ngroups+1)) ((ngroups+3):(2*ngroups+2))]));
  if (tmp < (2*ngroups))
     % See which slopes are not estimable when grouped
     tmp = rank(xmat(:,2:(ngroups+2)));
     if (tmp < (ngroups+1)), badbeta(:) = 1;     % all slopes
     else
        for j=1:ngroups
           cols = [(1+j), (ngroups+2), (ngroups+2+j)];
           tmp = rank(xmat(:,cols));
           if (tmp < 3), badbeta(1+j) = 1; end   % slope for group j
        end
     end
  end
  
  [stats.beta, stats.structure] = aocfit(xmat,y,model,alpha,ngroups,badbeta);

  % Define the rest of the UserData components.
  ud.stats = stats;
  ud.xmat  = xmat;
  ud.data  = [x(:) y(:) gi(:)];
  ud.model = model;
  ud.texthandle = [];
  ud.curgroup = 0;
  ud.alpha = alpha;
  ud.confflag = 1;       % 1 for conf bounds, 0 for none
  ud.simflag = 1;        % simultaneous confidence intervals
  ud.obsflag = 0;        % for mean, not for new observation
  ud.xname = xname;
  ud.yname = yname;
  ud.gname = gname;
  ud.wasnan = wasnan;
  ud.badbeta = badbeta;

  % Create output tables if requested
  if (nargout > 1 || dodisp)
     % Create anova and coefficient tables
     [a0,c0] = maketabs(stats, gn, xname, gname, model, badbeta);
     if (nargout > 1), atab = a0; end
     if (nargout > 2), ctab = c0; end
  end

  % Create output stats structure if requested, used by MULTCOMPARE
  if (nargout > 2)
     struct = stats.structure;
     tmp = tabulate(gi);
     outstats.source = 'aoctool';
     outstats.gnames = gn;
     outstats.n      = tmp(:,2);
     outstats.df     = struct.df;   % residual df
     outstats.s      = struct.rmse;
     outstats.model  = model;
     sigmasq = struct.rmse^2;

     beta = stats.beta;
     Rinv = struct.Rinv;
     bcov = sigmasq * Rinv * (Rinv');   % covariance of short form of coeffs
     if (any(badbeta)), bcov = fixcovariance(bcov, model, badbeta, Inf); end

     % For model 5 we can test the slopes
     if (model == 5)
        j = (ngroups+1):(2*ngroups);
        outstats.slopes = beta(j);
        outstats.slopecov = bcov(j,j);
     end
     
     % For most models we can test the intercept
     if (model~=1 && model~=3)
        j = 1:ngroups;
        outstats.intercepts = beta(j);
        outstats.intercov = bcov(j,j);
     end
     
     % For most models we can test the pmm (population marginal means,
     % sometimes known as least squares means or adjusted means).
     if (model~=1 && model~=3)
        xmean = mean(x);
        allgrps = (1:ngroups)';
        allx = repmat(xmean, ngroups, 1);
        [newy, deltay, ycov] = getyvalues(allx, allgrps, model, stats, ud);
        outstats.pmm = newy;
        outstats.pmmcov = ycov;
     end
  end
  
  
  if (dodisp)
     % Initialize group and model
     setconf(ud);
     ud = setgroup(newx, curgroup, model, stats, ud, y_field);
     [newy, deltay] = getyvalues(newx, curgroup, model, stats, ud);
     setyfields(newy,deltay,y_field);
     setydata(fitline, model, stats, curgroup, 0, ud);
     setreferencelines(newx, newy, ud.plotHandles.reference_line);

     % Create figures for table displays
     [aov_fig,coef_fig] = updatedisplays(a0, c0, aoc_fig);
     set(aov_fig,  'HandleVisibility', 'callback');
     set(coef_fig, 'HandleVisibility', 'callback');

     % Connect these figures to the main figure
     ud.aov_fig = aov_fig;
     ud.coef_fig = coef_fig;
     set(aoc_fig,'Backingstore','off', 'PaperPositionMode','auto',...
                 'WindowButtonMotionFcn','aoctool(''motion'',0)',...
                 'WindowButtonDownFcn','aoctool(''down'')',...
                 'UserData',ud, 'Visible','on', 'HandleVisibility','callback');
     % Finished with AOCTOOL initialization.
     figure(aoc_fig);
  end

 case 'model',
  model = get(modelpopup, 'Value');
  [stats.beta, stats.structure] = aocfit(xmat,y,model,alpha,ngroups,badbeta);
  ud.stats = stats;
  ud.model = model;
  set(aoc_fig, 'UserData', ud);

  % Initialize group and model
  ud = setgroup(newx, curgroup, model, stats, ud, y_field);
  [newy, deltay] = getyvalues(newx, curgroup, model, stats, ud);
  setyfields(newy,deltay,y_field);
  setydata(fitline, model, stats, curgroup, 0, ud);
  setreferencelines(newx, newy, ud.plotHandles.reference_line);

  if ((~isempty(aov_fig)) || (~isempty(coef_fig)))
     [a0,c0] = maketabs(stats, gn, xname, gname, model, badbeta);
     [aov_fig,coef_fig] = updatedisplays(a0, c0, aoc_fig, aov_fig, coef_fig);
  end
  
 case 'conf',
  if (nargin > 1), conf = flag; end
  switch(conf)
   case 1, ud.simflag = 1;             % simultaneous
   case 2, ud.simflag = 0;             % non-simultaneous
   case 3, ud.obsflag = 0;             % for the mean (fitted line)
   case 4, ud.obsflag = 1;             % for a new observation
   case 5, ud.confflag = ~ud.confflag; % no confidence intervals
  end
  setconf(ud);
  set(aoc_fig, 'UserData', ud);

  % Initialize group and model
  ud = setgroup(newx, curgroup, model, stats, ud, y_field);

 case 'group',
  if (curgroup ~= oldgroup)
     ud = setgroup(newx, curgroup, model, stats, ud, y_field);
     set(aoc_fig, 'UserData', ud);
  end

 case 'motion',
  [minx, maxx] = plotlimits(xrange);
  
  if flag == 0,
     cursorstate = get(aoc_fig,'Pointer');
     cp = get(aoc_axes,'CurrentPoint');
     cx = cp(1,1);
     cy = cp(1,2);
     fuzz = 0.01 * (maxx - minx);
     online = cy>yrange(1) & cy<yrange(2) & cx>newx-fuzz & cx<newx+fuzz;
     if online && strcmp(cursorstate,'arrow'),
        set(aoc_fig,'Pointer','crosshair');
     elseif ~online && strcmp(cursorstate,'crosshair'),
        set(aoc_fig,'Pointer','arrow');
     end
  elseif flag == 1 || flag == 2,
    cp = get(aoc_axes,'CurrentPoint'); 
    if ~isinaxes(cp, aoc_axes)
        if flag == 1
            set(aoc_fig,'Pointer','arrow');
            set(aoc_fig,'WindowButtonMotionFcn','aoctool(''motion'',2)');
        end
        return;
    elseif flag == 2
        set(aoc_fig,'Pointer','crosshair');
        set(aoc_fig,'WindowButtonMotionFcn','aoctool(''motion'',1)');
    end

    newx = min(maxx, max(minx, cp(1,1)));

     [newy, deltay] = getyvalues(newx, curgroup, model, stats, ud);
     set(x_field,'String',num2str(newx));
     setyfields(newy,deltay,y_field);
     setreferencelines(newx,newy,reference_line);
  end

 case 'down',
  if (gca ~= aoc_axes), return; end
  p = get(aoc_fig,'CurrentPoint');
  if (p(1)<.21 || p(1)>.96 || p(2)>0.86 || p(2)<0.18), return; end

  set(aoc_fig,'Pointer','crosshair');
  cp = get(aoc_axes,'CurrentPoint');
  [minx, maxx] = plotlimits(get(aoc_axes,'Xlim'));
  newx = min(maxx, max(minx, cp(1,1)));
  [newy, deltay] = getyvalues(newx, curgroup, model, stats, ud);
  set(x_field,'String',num2str(newx));
  setyfields(newy,deltay,y_field);
  setreferencelines(newx,newy,reference_line);
  set(gcf,'WindowButtonMotionFcn','aoctool(''motion'',1)', ...
          'WindowButtonUpFcn','aoctool(''up'')');

 case 'up',
  set(aoc_fig,'WindowButtonMotionFcn','aoctool(''motion'',0)', ...
              'WindowButtonUpFcn','');

 case 'edittext',
  if isempty(newx) 
     newx = get(x_field,'Userdata');
     set(x_field,'String',num2str(newx));
     warndlg('The X value must be a number. Resetting to previous value.');
     return;
  end

  [minx, maxx] = plotlimits(xrange);
  oldx = newx;
  newx = min(maxx, max(minx, newx));
  if (oldx ~= newx)
     set(x_field,'String',num2str(newx));
  end
  [newy, deltay] = getyvalues(newx, curgroup, model, stats, ud);
  setyfields(newy,deltay,y_field)
  setreferencelines(newx,newy,reference_line);

 case 'output',
  bmf = get(aoc_fig,'WindowButtonMotionFcn');
  bdf = get(aoc_fig,'WindowButtonDownFcn');
  set(aoc_fig,'WindowButtonMotionFcn','','WindowButtonDownFcn','');

  labels = {'Parameters', 'Parameter CI', 'Prediction', 'Prediction CI', 'Residuals'};
  varnames = {'beta', 'betaci', 'yhat', 'yci', 'residuals'};

  structure = stats.structure;
  beta = stats.beta;
  Rinv = structure.Rinv;
  bcov = Rinv * (Rinv');      % covariance of short form of coefficients
  if (any(badbeta)), bcov = fixcovariance(bcov, model, badbeta, Inf); end
  [beta,bcov] = expandcoeffs(beta, bcov, ngroups, model, badbeta);

  rmse = structure.rmse;
  dbeta = sqrt(diag(bcov))*stats.structure.tcrit*rmse;
  yhat = getyvalues(x, gi, model, stats, ud);

  % Fix residuals to have the original x/y length
  resid = y - yhat;
  if (any(wasnan))
     resid = fixrows(resid, wasnan);
  end
  
  % Get fitted values for all groups if required
  if (curgroup == 0)
     allgrps = (1:ngroups)';
     allx = repmat(newx, ngroups, 1);
     [newy, deltay] = getyvalues(allx, allgrps, model, stats, ud);
  end

  items={beta, [beta-dbeta beta+dbeta], newy, [newy-deltay newy+deltay], resid};
  export2wsdlg(labels, varnames, items, 'Export to Workspace');
  
  set(aoc_fig,'UserData',ud, 'WindowButtonMotionFcn',bmf, ...
              'WindowButtonDownFcn',bdf);

 case 'closeall'
  if (~isempty(aov_fig)), close(aov_fig); end
  if (~isempty(coef_fig)), close(coef_fig); end
  close(gcbf);
  
end

if (nargout > 0), h = [dataline(:); fitline(:)]; end

function [atab,ctab] = maketabs(stats,grpnames,xname,gname,model,badbeta)
%MAKETABS creates anova and coefficients tables

structure = stats.structure;
beta      = stats.beta;
df   = structure.df;   % residual df
rmse = structure.rmse;
Rinv = structure.Rinv;
ng = size(grpnames, 1);

bcov1 = Rinv * (Rinv');      % covariance of short form of coefficients
bcov = bcov1;
if (any(badbeta)), bcov = fixcovariance(bcov, model, badbeta, 1); end

% ---------------------- create anova table --------------------
dfv = [(ng-1) 1 (ng-1)]';
ssv = zeros(3,1);

% Get H matrix defining hypotheses about groups
if (model==2 || model>3)
   H = zeros(ng-1,ng);
   H(1:ng:end) = 1;
   H(ng:ng:end) = -1;
end

% Compute sum of squares for interaction if the model includes it
if (model == 5)
   if (~badbeta(1))
      ng1 = sum(~badbeta(2:end));
      i3 = (ng+1):size(bcov,1);
      if (ng1 < ng)
         H1 = zeros(ng1-1,ng1);  % Need H for smaller set of coefficients
         H1(1:ng1:end) = 1;
         H1(ng1:ng1:end) = -1;
         i3 = i3(~badbeta(2:end));
      else
         H1 = H;
      end
      B = H1 * beta(i3);
      M = H1 * bcov(i3,i3) * H1';
      dfv(3) = max(0, ng1-1);
      ssv(3) = B' * pinv(M) * B;
   else
      i3 = [];
      H1 = [];
      dfv(3) = 0;
      ssv(3) = 0;
   end
end

% Compute the sum of squares for slopes if the model includes any slope
if (model > 2)
   if (model > 3), ii = (ng+1):size(bcov,1);
   else            ii = 2;
   end
   
   if (model>3 && badbeta(1))
      ssv(2) = 0;
      dfv(2) = 0;
   else
      ssv(2) = beta(ii)' * pinv(bcov(ii, ii)) * beta(ii) - ssv(3);
   end
end

% Compute the sum of squares for groups if the model includes any grouping
if (model == 2 || model > 3)
   ii = 1:length(beta);
   if (model == 5)
      H = blkdiag(H, H1);
      ii = [(1:ng) i3];
   elseif (model == 4)
      H = [H, zeros(size(H,1),1)];
   end
   
   B = H * beta(ii);
   M = H * bcov(ii,ii) * H';
   ssv(1) = B' * pinv(M) * B - ssv(3);
end

if (df > 0)
   msv = repmat(Inf, size(dfv));
   msv(dfv>0) = ssv(dfv>0) ./ dfv(dfv>0);
   mse = rmse^2;
else
   msv = repmat(NaN, size(ssv));
   mse = 0;
end

if (mse > 0)
   fv = msv / mse;
else
   fv = repmat(NaN, size(msv));
end
pv = 1 - fcdf(fv, dfv, df);
sse = df * mse;

tmp = num2cell([dfv ssv msv fv pv; df sse mse NaN NaN]);
tmp(end,4:5) = {[]};
atab = [{'Source' 'd.f.' 'Sum Sq' 'Mean Sq' 'F' 'Prob>F'}; ...
        [{gname};{xname};{[gname '*' xname]};{'Error'}] tmp];

% Remove rows for terms that are not part of this model
collist = logical([1 (model==2 | model>3) (model>2) (model==5) 1]);
atab = atab(collist,:);


% ---------------- create coefficients table --------------------
if (any(badbeta)), bcov = fixcovariance(bcov1, model, badbeta, Inf); end
[beta,bcov] = expandcoeffs(beta, bcov, ng, model, badbeta);

% Make labels for coefficients
tmp = cellstr([repmat('  ',ng,1) char(grpnames)]);
lab1 = []; % label for groups if included in model
lab2 = []; % label for slope if included in model
lab3 = []; % label for slope*group if included in model
if (model==2 || model>3), lab1 = tmp; end
if (model>2),            lab2 = {'Slope'}; end
if (model==5),           lab3 = tmp; end
rowlabels = [{'Intercept'};lab1;lab2;lab3];

stderr = sqrt(diag(bcov)) * rmse;
tstat = beta ./ stderr;
pval = 2 * tcdf(-abs(tstat), df);
tmp = [beta stderr tstat pval];

% Fix up non-estimable entries
if (model>3 && badbeta(1))
   tmp(ng+2,:) = [0 Inf NaN NaN];
end
if (model==5 && any(badbeta(2:end)))
   rows = (ng+3):(2*ng+2);
   rows = rows(badbeta(2:end));
   tmp(rows,:) = repmat([0 Inf NaN NaN], length(rows), 1);
end

tmp = num2cell(tmp);
ctab = [{'Term' 'Estimate' 'Std. Err.' 'T' 'Prob>|T|'}; ...
        rowlabels tmp];

function setyfields(newy,deltay,y_field)
% SETYFIELDS Local function for changing the Y field values.
if (isnan(newy))
   ytxt = '';
else
   ytxt = num2str(newy);
end
set(y_field(1),'String',ytxt);

if (isnan(deltay))
   ytxt = '';
else
   ytxt = num2str(deltay);
end
set(y_field(2),'String',ytxt);

if (isnan(newy) || isnan(deltay))
   set(y_field(3), 'Visible', 'off');
else
   set(y_field(3), 'Visible', 'on');
end

function setreferencelines(newx,newy,reference_line)
% SETREFERENCELINES Local function for moving reference lines on figure.
set(reference_line(1),'YData',[],'Xdata',[]);   % vertical
set(reference_line(2),'XData',[],'Ydata',[]);   % horizontal
xrange = get(gca,'Xlim');
yrange = get(gca,'Ylim');
set(reference_line(1),'YData',yrange,'Xdata',[newx newx]);   % vertical
set(reference_line(2),'XData',xrange,'Ydata',[newy newy]);   % horizontal


function [yhat, deltay, ycov] = getyvalues(x, g, model, stats, ud)
% GETYVALUES Local function for generating predictions and conf intervals.

if (isequal(g, 0))
   yhat = repmat(NaN, size(x));
   if (nargout > 1), deltay = yhat; end
   return;
end

ng = stats.structure.ngroups;
if (length(g) == 1), g = repmat(g, size(x)); end

% Create X vector or matrix from x and g
x = x(:);
xx = zeros(length(x), stats.structure.p);
xx(:,1) = 1;
done = 1;
if (model == 2 || model == 4 || model == 5)     % add G term
   g2x = eye(ng);
   xx(:,done:(done+ng-1)) = g2x(g,:);
   done = done+ng-1;
end
if (model == 3 || model == 4 || model == 5)     % add X term
   xx(:,done+1) = x;
   done = done+1;
end
if (model == 5)                               % add X*G term
   xx(:,done:(done+ng-1)) = xx(:,1:ng) .* x(:,ones(1,ng));
end

yhat = xx * stats.beta;

if (nargout > 1 && (ud.confflag || nargout>2))
   alpha = ud.alpha;
   Rinv = stats.structure.Rinv;
   rmse = stats.structure.rmse;
   badbeta = ud.badbeta;
   if (~((model>3 && badbeta(1)) ...
        || (model==5 && any(badbeta(2:end))) ...
        || (nargout>2)))
      E = xx * Rinv;
      xfactor = sum(E.*E, 2);
   else
      bcov = Rinv * (Rinv');      % covariance of short form of coefficients
      bcov = fixcovariance(bcov, model, badbeta, Inf);
      ycov = xx * bcov * xx';
      xfactor = diag(ycov);
      if (nargout>2), ycov = ycov * rmse^2; end
   end
   if (ud.obsflag), xfactor = xfactor+1; end
   if (ud.simflag)
      % Simultaneous method of Lane/Dumouchel, Amer Statist, 1994 
      df2 = stats.structure.df; % denominator d.f. = n-p
      df1 = 1 + (model>2);      % numerator d.f. = #coeffs per group
      bonf = 1;
      if (model==1 || model==3), bonf = ng; end
      crit = sqrt(df1 * finv(1-alpha/bonf, df1, df2));
   else
      crit = stats.structure.tcrit;
   end
   deltay = sqrt(xfactor) * (rmse * crit);
elseif (nargout > 1)
   deltay = repmat(NaN, size(yhat));
end


function [minx, maxx] = plotlimits(x)
% PLOTLIMITS   Local function to control the X-axis limit values.
maxx = max(x(:));
minx = min(x(:));
xrange = maxx - minx;
maxx = maxx + 0.025 * xrange;
minx = minx - 0.025 * xrange;

function [plotHandles, newx] = makeplots(x,y,g,ng)
% MAKEPLOTS   Local function to create the plots.
[minx, maxx] = plotlimits(x);
xfit = linspace(minx,maxx,41)';

% Create figure window, position it, plot data
u = get(0, 'Units');
set(0, 'Units', 'pixels');
figp = get(0, 'DefaultFigurePosition');
ssiz = get(0, 'ScreenSize');
set(0, 'Units', u);
p = [0.01, (figp(2)/ssiz(4)), (figp(3)/ssiz(3)), (figp(4)/ssiz(4))];
aoc_fig = figure('Units','normalized', 'Tag','aocfig', ...
                 'Name','ANOCOVA Prediction Plot', 'Position',p);

plotHandles.dataline = gscatter(x,y,g,'','ox+*sdv^<>ph','','on','','');

% Adjust figure window
set(gca,'XLim',[minx maxx],'Box','on');
ppos = [.21 .18 .75 .72];
set(gca,'NextPlot','add','DrawMode','fast','Position',ppos);
h = findobj(gcf, 'Type', 'axes');
h(h==gca) = [];
if (length(h) == 1)        % this is the legend
   hpos = get(h, 'Position');
   hpos(1) = 0;
   hpos(2) = 1 - hpos(4);
   set(h, 'Position', hpos);
   u = get(h,'Units');
   set(h, 'Units', 'points');
   hpos = get(h, 'Position');
   hpos(1) = 1;
   hpos(2) = hpos(2) - 1;
   set(h, 'Position', hpos);
   set(h, 'Units', u);
   hpos = get(h, 'Position');

   % Fix any embedded positions
   lud = get(h, 'UserData');
   if ~isempty(h)
      if (isfield(lud,'AxesPosition') && isfield(lud,'PlotPosition') && ...
          isfield(lud,'LegendPosition') && isfield(lud,'legendpos'))
          lud.AxesPosition = ppos;
          lud.PlotPosition = ppos;
          lud.LegendPosition = hpos;
          u = get(h, 'Units');
          set(h, 'Units', 'points');
          lud.legendpos = get(h, 'Position');
          set(h, 'Units', u);
          set(h, 'UserData', lud);
      end
   end
end

yfitm = zeros(length(xfit), ng);
plotHandles.fitline = plot(xfit,yfitm(:,1:ng),'-', ...
                           xfit,yfitm(:,end-1:end),'--');

yrange = get(gca,'YLim');
xrange = get(gca,'XLim');

% Plot Reference Lines
newx = xfit(21);
newy = NaN;
reference_line = zeros(1, 2);
reference_line(1) = plot([newx newx],yrange,'k--','Erasemode','xor');
reference_line(2) = plot(xrange,[newy newy],'k:','Erasemode','xor');
set(reference_line(1),'ButtonDownFcn','aoctool(''down'')');
plotHandles.reference_line = reference_line;


function uich = makeuicontrols(newx,curgroup,gn,xname,yname,gname,model)
% MAKEUICONTROLS   Local function to create uicontrols.

if strcmp(computer,'MAC2')
   offset = -0.01;
else
   offset = 0;
end

fcolor = get(gcf,'Color');

xfieldp = [.50 .07 .15 .05];
yfieldp = [.01 .45 .13 .04];
gfieldp = [.70 .07 .15 .05];
mfieldp = [.25 .07 .20 .05];

uich.x_field = uicontrol('Style','edit', 'Units','normalized', ...
                         'Position',xfieldp, 'String',num2str(newx), ...
                         'BackgroundColor','white', 'UserData',newx, ...
                         'CallBack','aoctool(''edittext'')', ...
                         'String',num2str(newx));

ytext=uicontrol('Style','text','Units','normalized',...
                'Position',yfieldp + [0 0.20 0 0],'String',yname,...
                'BackgroundColor',fcolor,'ForegroundColor','k');

uich.y_field(1)= uicontrol('Style','text', 'Units','normalized',...
                           'Position',yfieldp + [0 .14 0 0], ...
                           'String','', ...
                           'BackgroundColor',fcolor, 'ForegroundColor','k');

uich.y_field(3) = uicontrol('Style','text','Units','normalized', ...
                            'Position',yfieldp + [0 .07 -0.01 0], 'String',' +/-', ...
                            'BackgroundColor',fcolor,'ForegroundColor','k');

uich.y_field(2)= uicontrol('Style','text', 'Units','normalized', ...
                           'Position',yfieldp, 'String','', ...
                           'BackgroundColor',fcolor, 'ForegroundColor','k');

uicontrol('Style','text','Units','normalized', ...
          'Position',xfieldp - [0 0.07 0 0], 'ForegroundColor','k', ...
          'BackgroundColor',fcolor, 'String',xname);

uicontrol('Style','text','Units','normalized', ...
          'Position',gfieldp - [0 0.07 0 0], 'ForegroundColor','k', ...
          'BackgroundColor',fcolor, 'String',gname);
uicontrol('Style','text','Units','normalized', ...
          'Position',mfieldp - [0 0.07 0 0], 'ForegroundColor','k', ...
          'BackgroundColor',fcolor, 'String','Model');

uich.outputpopup=uicontrol('String', 'Export...',...
                           'Value',1, 'Units','normalized', ...
                           'Position',[0.01 0.13 0.17 0.05], ...
                           'CallBack','aoctool(''output'')');

uich.grouppopup=uicontrol('Style','Popup', 'String', [{'All Groups'};gn], ...
                          'Value',curgroup+1, 'Units','normalized', ...
                          'Position',gfieldp, 'BackgroundColor','w', ...
                          'CallBack','aoctool(''group'')');

modstring = 'Same Mean|Separate Means|Same Line|Parallel Lines|Separate Lines';
uich.modelpopup=uicontrol('Style','Popup', 'String',modstring, ...
                          'Value',model, 'Units','normalized', ...
                          'Position',mfieldp, 'BackgroundColor','w', ...
                          'CallBack','aoctool(''model'')');

uicontrol('Style','Pushbutton','Units','normalized', ...
                         'Position',[0.01 0.07 0.17 0.05], ...
                         'Callback','close', 'String','Close');
uicontrol('Style','Pushbutton','Units','normalized', ...
          'Position',[0.01 0.01 0.17 0.05], ...
          'Callback','aoctool(''closeall'')', 'String','Close All');

f = uimenu('Label','&Bounds', 'Position', 4, 'UserData','conf');
uimenu(f,'Label','&Simultaneous', ...
       'Callback','aoctool(''conf'',1)', 'UserData',1);
uimenu(f,'Label','&Non-Simultaneous', ...
       'Callback','aoctool(''conf'',2)', 'UserData',2);
uimenu(f,'Label','&Line', 'Separator','on', ...
       'Callback','aoctool(''conf'',3)', 'UserData',3);
uimenu(f,'Label','&Observation', ...
       'Callback','aoctool(''conf'',4)', 'UserData',4);
uimenu(f,'Label','N&one', 'Separator','on', ...
       'Callback','aoctool(''conf'',5)', 'UserData',5);


function [b, struct] = aocfit(xmat, y, model, alpha, ng, badbeta)
% Local function to fit anocova model

n = length(y);
badslope = badbeta(1);
anybad = any(badbeta);
switch(model)
 case 1, cols = 1;
 case 2, cols = 2:(ng+1);
 case 3, cols = 1:(ng+1):(ng+2);
 case 4, cols = 2:(ng+2-badslope);
 case 5, tmp = (ng+3):(2*ng+2);
         if (anybad), tmp = tmp(~badbeta(2:end)); end
         cols = [(2:(ng+1)) tmp];
end
p = length(cols);

x = xmat(:,cols);

[Q,R] = qr(x,0);
b = R\(Q'*y);

Rinv = R\eye(p);
df = n-rank(R);                 % Residual degrees of freedom
yhat = x*b;                     % Predicted responses at each data point.
r = y-yhat;                     % Residuals.
if df ~= 0
   rmse = norm(r)/sqrt(df);     % Root mean square error.
else
   rmse = Inf;
end

% Store these for predictions and other activities
struct.df      = df;
struct.rmse    = rmse;
struct.ngroups = ng;
struct.p       = p;
struct.tcrit   = tinv(1-alpha/2, df);
struct.Rinv    = Rinv;

% Fix up results in case non-estimable coefficients were dropped
if (badslope && (model == 4))
   b = [b; 0];
elseif (anybad && (model == 5))
   bb = zeros(2*ng, 1);
   bb([logical(ones(ng,1)); ~badbeta(2:end)]) = b;
   b = bb;
end

% -----------------------
function udout = setgroup(newx, curgroup, model, stats, ud, y_field)
%SETGROUP sets the current group

% Set text fields
[newy, deltay] = getyvalues(newx, curgroup, model, stats, ud);
setyfields(newy, deltay, y_field);

% Adjust line colors
gcolors = ud.gcolors;
ng = length(gcolors);
fitline  = ud.plotHandles.fitline;
dataline = ud.plotHandles.dataline;
if (curgroup == 0)
   for j=1:ng
      set(fitline(j), 'Color', gcolors{j});
      set(dataline(j), 'Color', gcolors{j});
   end
   
   % Hide confidence bounds
   set(fitline(end-1:end), 'Visible', 'off');
   confmenu = 'off';
else
   grey = repmat(0.75, 3, 1);
   all = 1:ng;
   all(curgroup) = [];
   set(fitline(all), 'Color', grey);
   set(dataline(all), 'Color', grey);
   set(fitline(curgroup), 'Color', gcolors{curgroup});
   set(dataline(curgroup), 'Color', gcolors{curgroup});

   % Compute and show confidence bounds for this group
   setydata(fitline, model, stats, curgroup, 1, ud);
   set(fitline(end-1:end), 'Visible','on', 'Color',gcolors{curgroup});
   confmenu = 'on';
end

% Enable or disable menu items as appropriate
ma = findobj(gcf, 'Type','uimenu', 'UserData','conf');
hh = findobj(ma, 'Type','uimenu');
hh(hh==ma) = [];
set(hh, 'Enable', confmenu);

% May need to change extent of reference lines if axis limits changed
setreferencelines(newx, newy, ud.plotHandles.reference_line);

% Remember which group is on display
ud.curgroup = curgroup;
udout = ud;

% -----------------------
function setconf(ud)
%SETCONF Update menus to reflect confidence bound settings

ma = findobj(gcf, 'Type','uimenu', 'UserData','conf');
hh = findobj(ma, 'Type','uimenu');

set(hh, 'Checked', 'off');          % uncheck all menu items

hh = findobj(ma, 'Type', 'uimenu', 'UserData', 2-ud.simflag);
if (length(hh) == 1), set(hh, 'Checked', 'on'); end

hh = findobj(ma, 'Type', 'uimenu', 'UserData', 3+ud.obsflag);
if (length(hh) == 1), set(hh, 'Checked', 'on'); end

hh = findobj(ma, 'Type', 'uimenu', 'UserData', 5);
if (~ud.confflag), set(hh, 'Checked', 'on'); end

% -----------------------
function setydata(fitline, model, stats, curgroup, confonly, ud)
%SETYDATA Update Y data in graph

xfit = get(fitline(1), 'XData');
cg = max(curgroup, 1);

% Update fit and confidence bounds for current group
[yfit, deltay] = getyvalues(xfit(:), cg, model, stats, ud);
set(fitline(cg),    'YData', yfit);
set(fitline(end-1), 'YData', yfit - deltay);
set(fitline(end),   'YData', yfit + deltay);
if (nargin > 4 && confonly), return; end

% Update fit for remaining groups
ng = stats.structure.ngroups;
for j=1:ng
   if (j ~= cg)
      set(fitline(j), 'YData', getyvalues(xfit, j, model, stats, ud));
   end
end

% -----------------------------------
function hout = checkfig(hin, parenth)
%CHECKFIG Return handle if it is still properly connected to aoc figure

hout = [];
if (~ishandle(hin)), return; end
if (~isequal(get(hin,'Type'), 'figure')), return; end

ud = get(hin, 'UserData');
if (isempty(ud)), return; end
if (~isstruct(ud)), return; end
if (~isfield(ud, 'ParentHandle')), return; end
if (ud.ParentHandle ~= parenth), return; end

hout = hin;

% ---------------------------
function [outfiga,outfigc] = updatedisplays(a0, c0, parentfig, ...
                                            infiga, infigc)
%UPDATEDISPLAYS Create or update display of tables

if (nargin < 4)                        % will create new figures
   ppos = get(parentfig, 'Position');
   gap = 0.5 * (1 - ppos(2) - ppos(4));% half gap from top of screen
   ppos(1) = 0.01 + ppos(1) + ppos(3); % start new figure beside parent
   if (ppos(1) + .5*ppos(3) > 1)       % would be more than half off screen
      ppos(1) = max(.25,1-ppos(3));    % nudge it over so most of it shows
   end
   cpos = [ppos(1), (ppos(2)+ppos(4)/2), ppos(3), (ppos(4)/2)];
   apos = [ppos(1), max(0,ppos(2)-gap),  ppos(3), (ppos(4)/2)];
end

% Anova table, either create or update existing figure
outfiga = [];
digits = [-1 -1 -1 -1 2 4];
if (nargin < 4)
   outfiga  = statdisptable(a0, 'ANOCOVA Test Results', 'ANOVA Table', ...
                            '', digits, [], parentfig, ...
                            'Units','normalized','Position', apos);
elseif (~isempty(infiga))
   outfiga  = statdisptable(a0, 'ANOCOVA Test Results', 'ANOVA Table', ...
                            '', digits, infiga, parentfig);
end

% Same with coefficient table
outfigc = [];
digits = [-1 -1 -1 2 4];
if (nargin < 4)
   outfigc = statdisptable(c0, ...
                           'ANOCOVA Coefficients', 'Coefficient Estimates', ...
                           '', digits, [], parentfig, ...
                           'Units','normalized','Position', cpos);
elseif (~isempty(infigc))
   outfigc = statdisptable(c0, ...
                           'ANOCOVA Coefficients', 'Coefficient Estimates', ...
                           '', digits, infigc, parentfig);
end

% ----------------------
function [newbeta,newcov] = expandcoeffs(beta, bcov, ng, model, badbeta)
%EXPANDCOEFFS Expand full-rank coefficients to complete set for display

% Create E to transform long form to short form
anybad = 0;
if (model == 1 || model == 3), E = 1;
else
   nrows = ng + 1 + (model>3) + ng*(model==5);
   ncols = ng + (model==4) + ng*(model==5);
   E = zeros(nrows, ncols);
   avg = 1/ng;
   E(1,1:ng) = avg;
   E(2:(ng+1), 1:ng) = eye(ng) - avg;
   
   if (model == 4)
      E(ng+2, ng+1) = 1;
   elseif (model == 5)
      anybad = any(badbeta);
      goodcols = ~badbeta(2:end);
      ii = (ng+1):ncols;
      ibad = ii(~goodcols);
      ii = ii(goodcols);
      ngood = length(ii);
      E((ng+3):end, (ng+1):end) = eye(ng);
      if (ngood > 0)
         avg = 1/sum(goodcols);
         E(ng+2, ii) = avg;
         E(2+ii, ii) = eye(ngood) - avg;
      end
   end
end

% Expand coefficients and covariance matrix
newbeta = E * beta;
if (anybad), bcov(isinf(bcov)) = 1; end
newcov = E * bcov * (E');
if (anybad), newcov(2+ibad,2+ibad) = diag(repmat(Inf,length(ibad),1)); end

% ---------------------------
function vv = fixrows(v, b)
% helper to extend v to original length, NaNs are given by b

vv = repmat(NaN, size(b));
vv(~b) = v;

% ---------------------------
function bcov = fixcovariance(bcovin, model, badbeta, bigvariance)
% helper to fix covariance matrix to take non-estimable
% coefficients into account

bcov = bcovin;
if ((model == 4) && badbeta(1))
   r = size(bcovin,1) + 1;
   bcov(r,r) = bigvariance;
elseif ((model == 5) && any(badbeta(2:end)))
   ng = length(badbeta) - 1;
   bcov = zeros(2*ng);
   bcov(1:(2*ng+1):(4*ng^2)) = bigvariance;
   tmp = (ng+1):(2*ng);
   tmp = tmp(~badbeta(2:end));
   tmp = [(1:ng) tmp];
   bcov(tmp, tmp) = bcovin;
end
