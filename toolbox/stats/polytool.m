function h = polytool(x,y,n,alpha,xname,yname)
%POLYTOOL Fits a polynomial to (x,y) data and displays an interactive graph.
%   POLYTOOL(X,Y,N,ALPHA) is a prediction plot that provides a Nth degree
%   polynomial curve fit to (x,y) data. It plots a 100(1 - ALPHA) percent
%   global confidence interval for predictions as two red curves.  The
%   default value for N is 1 (for a linear model) and the default value
%   for ALPHA is 0.05.  For any value X, the default curves define a
%   nonsimultaneous 95% confidence interval for a new observation of Y
%   taken at that X value.  (This differs from NLPREDCI, which computes
%   confidence intervals for the regression function.)
%
%   POLYTOOL(X,Y,N,ALPHA,XNAME,YNAME) labels the x and y values on the 
%   graphical interface using the strings XNAME and YNAME. Specify N and 
%   ALPHA as [] to use their default values. 
%
%   H = POLYTOOL(X,Y,N,ALPHA,XNAME,YNAME) outputs a vector of handles, H,
%   to the line objects (data, fit, lower bounds and upper bounds) in the plot.
%
%   You can drag the dashed black reference line and watch the predicted
%   values update simultaneously. Alternatively, you can get a specific
%   prediction by typing the "X" value into an editable text field.
%   A text field at the top allows you to change the degree of the 
%   polynomial fit. Use the push button labeled Export to move 
%   specified variables to the base workspace. Use the Bounds menu
%   to change the type of confidence bounds. Use the Method menu to
%   change the fitting method from least squares to robust.
   
%   Copyright 1993-2004 The MathWorks, Inc. 
% $Revision: 2.31.4.3 $  $Date: 2004/01/16 20:10:05 $

action = 'start';
if (nargin > 0)
   if (ischar(x))
      action = x;
   end
end

%On initial call weed out NaNs
if (strcmp(action, 'start'))
   if (nargin == 0)
      msg = sprintf(['To use POLYTOOL with your own data, type:\n' ...
                     '   polytool(x, y, n)\n\n' ...
                     'Type "help polytool" for more information\n\n' ...
                     'Click OK to fit a polynomial to sample data.']);
      hmsg = warndlg(msg, 'Polynomial Fitting');
      x = (1:10)';
      y = 50 + 4*x - 0.75*x.^2 + randn(10,1);
      polytool(x,y);
      figure(hmsg);
      return
   end

   if (nargin < 2)
      error('stats:polytool:TooFewInputs',...
            'POLYTOOL requires at least two arguments.');
   end
   [anybad wasnan y x] = statremovenan(y,x);
   if (anybad==2)
     error('stats:polytool:InputSizeMismatch',...
           'Lengths of X and Y must match.');
   end
   if (any(wasnan(:)))
      warning('stats:polytool:RemovedMissingValues',...
              'Removed (X,Y) pairs where either value was NaN.')
   end
end

%On recursive calls get all necessary handles and data.
if ~strcmp(action,'start')

   if nargin == 2,
      flag = y;
   end
   
   poly_fig = findobj(0,'Tag','polyfig');
   k = gcf;
   idx = find(poly_fig == k);
   if isempty(idx)
      return
   end
   poly_fig = poly_fig(idx);
   poly_axes = get(poly_fig,'CurrentAxes');      
   ud = get(poly_fig,'Userdata');
   
   uiHandles    = ud.uicontrolHandles;
   x_field      = uiHandles.x_field;
   y_field      = uiHandles.y_field;
   degreetext   = uiHandles.degreetext;

   stats        = ud.stats;
   x            = ud.data(:,1);
   y            = ud.data(:,2);
   wasnan       = ud.wasnan;
   
   fitline        = ud.plotHandles.fitline;
   reference_line = ud.plotHandles.reference_line;
 
   degree         = str2double(get(degreetext,'String'));
   
   xrange = get(poly_axes,'XLim');
   yrange = get(poly_axes,'YLim');

   newx = str2double(get(x_field,'String'));  
end

switch action

case 'start',

if nargin < 3, 
   degree = 1;
else
   if isempty(n)
      n = 1;
   end
   degree = n;
end

if degree == 1
    model = 'Linear';
elseif degree == 2
    model = 'Quadratic';
elseif degree == 3
    model = 'Cubic';
elseif degree == 4
    model = 'Quartic';
elseif degree == 5
    model = 'Quintic';
else
    model = [num2str(double(degree)),'th Order'];
end   

if nargin < 4 || isempty(alpha), 
    alpha = 0.05;
end
if isempty(alpha)
   alpha = 0.05;
end

if nargin >= 5
   xstr = xname;
   if isempty(xname)
      xstr = 'X Values';
   end  
else
   xstr = 'X Values';
end

if nargin == 6
   ystr = yname;
else
   ystr = 'Y Values';
end


% Create plot figure and axes.
poly_fig = figure('Visible','off','Units','Normalized','Tag','polyfig');
set(poly_fig,'Name',['Prediction Plot of ',model,' Model']);
poly_axes = axes;

% Fit data.
nobs = max(size(y));
ncoeffs = 2:(nobs-1);
dflist = nobs - ncoeffs;
stats.crit = tinv(1 - alpha/2,dflist);
stats.fcrit = sqrt(ncoeffs .* finv(1-alpha, ncoeffs, dflist));
stats = dofit(x,y,degree,stats,0);

% Define the first of the UserData components.
ud.stats = stats;
ud.data  = [x(:) y(:)];
ud.wasnan = wasnan;
ud.texthandle = [];
ud.simflag = 0;        % nonsimultaneous confidence intervals
ud.obsflag = 1;        % for new observation, not for mean
ud.confflag = 1;       % show confidence bounds
ud.robflag = 0;        % not a robust fit
% Call local function to create plots.
[ud.plotHandles, newx] = makeplots(x,y,stats,degree,poly_axes,ud);
fitline = ud.plotHandles.fitline;
% Call local function to create uicontrols.
ud.uicontrolHandles = makeuicontrols(newx,xstr,ystr,stats,degree,ud);
setconf(ud);           % initialize settings on Bounds menu
setfit(ud);            % initialize settings on Method menu

set(poly_fig,'Backingstore','off','WindowButtonMotionFcn','polytool(''motion'',0)',...
    'WindowButtonDownFcn','polytool(''down'')','UserData',ud,'Visible','on',...
	'HandleVisibility','callback');
% Finished with polytool initialization.

case 'motion',
    [minx, maxx] = plotlimits(xrange);
     
    if flag == 0,
        cursorstate = get(poly_fig,'Pointer');
        cp = get(poly_axes,'CurrentPoint');
        cx = cp(1,1);
        cy = cp(1,2);
        fuzz = 0.01 * (maxx - minx);
        online = cy > yrange(1) & cy < yrange(2) & cx > newx - fuzz & cx < newx + fuzz;
        if online && strcmp(cursorstate,'arrow'),
            set(poly_fig,'Pointer','crosshair');
        elseif ~online && strcmp(cursorstate,'crosshair'),
            set(poly_fig,'Pointer','arrow');
        end
    elseif flag == 1 || flag == 2,
        cp = get(poly_axes,'CurrentPoint');
        if ~isinaxes(cp, poly_axes)
            if flag == 1
                set(poly_fig,'Pointer','arrow');
                set(poly_fig,'WindowButtonMotionFcn','polytool(''motion'',2)');
            end
            return;
        elseif flag == 2
            set(poly_fig,'Pointer','crosshair');
            set(poly_fig,'WindowButtonMotionFcn','polytool(''motion'',1)');
        end
        newx=cp(1,1);
        if newx > maxx
            newx = maxx;
        end
        if newx < minx
            newx = minx;
        end

		[newy, deltay] = getyvalues(newx,stats,degree,ud);
        set(x_field,'String',num2str(double(newx)));
	    setyfields(newy,deltay,y_field,ud.confflag);
	    setreferencelines(newx,newy,reference_line);
    end

case 'down',
    p = get(poly_fig,'CurrentPoint');
    if p(1) < .21 || p(1) > .96 || p(2) > 0.86 || p(2) < 0.18
       return
    end

    set(poly_fig,'Pointer','crosshair');
    cp = get(poly_axes,'CurrentPoint');
    [minx, maxx] = plotlimits(get(poly_axes,'Xlim'));
    newx=cp(1,1);
    if newx > maxx
       newx = maxx;
    end
    if newx < minx
       newx = minx;
    end
	[newy, deltay] = getyvalues(newx,stats,degree,ud);
    set(x_field,'String',num2str(double(newx)));
	setyfields(newy,deltay,y_field,ud.confflag)
	setreferencelines(newx,newy,reference_line);
    set(gcf,'WindowButtonMotionFcn','polytool(''motion'',1)','WindowButtonUpFcn','polytool(''up'')');

case 'up',
    set(poly_fig,'WindowButtonMotionFcn','polytool(''motion'',0)','WindowButtonUpFcn','');

case 'edittext',
    if isempty(newx) 
      newx = get(x_field,'Userdata');
      set(x_field,'String',num2str(double(newx)));
      warndlg('The X value must be a number. Resetting to previous value.');
      return;
    end

    [minx, maxx] = plotlimits(xrange);
    if newx > maxx
        newx = maxx;
        set(x_field,'String',num2str(double(newx)));
    end
    if newx < minx
        newx = minx;
        set(x_field,'String',num2str(double(newx)));
    end

    [newy, deltay] = getyvalues(newx,stats,degree,ud);
	setyfields(newy,deltay,y_field,ud.confflag)
	setreferencelines(newx,newy,reference_line);

case 'change_degree',
    maxdf = length(stats.crit);
    if degree >= maxdf+1
       degree = get(degreetext,'Userdata');
       set(degreetext,'String',num2str(double(degree)));
       warndlg('Cannot fit model. Resetting to previous value.');
       return;
    end   
    if isempty(degree) 
       degree = get(degreetext,'Userdata');
       set(degreetext,'String',num2str(double(degree)));
       warndlg('The polynomial degree must be a positive integer. Resetting to previous value.');
       return;
    end
    if floor(degree) ~= degree || degree <= 0
       degree = get(degreetext,'Userdata');
       set(degreetext,'String',num2str(double(degree)));
       warndlg('The polynomial degree must be a positive integer. Resetting to previous value.');
       return;
    end
    ud.stats = dofit(x,y,degree,ud.stats,ud.robflag);
    updateplot(poly_axes,x,y,ud,degree,fitline,reference_line,newx,y_field);

    set(degreetext,'UserData',degree);
 	switch degree
	   case 1
          model = 'Linear';
       case 2
          model = 'Quadratic';
       case 3
          model = 'Cubic';
       case 4
          model = 'Quartic';
       case  5
          model = 'Quintic';
       otherwise
          model = [num2str(double(degree)),'th Order'];
    end   
    set(poly_fig,'Name',['Prediction Plot of ',model,' Model'],...
	   'UserData',ud);  

case 'output',
    bmf = get(poly_fig,'WindowButtonMotionFcn');
    bdf = get(poly_fig,'WindowButtonDownFcn');
    set(poly_fig,'WindowButtonMotionFcn','','WindowButtonDownFcn','');

    labels = {'Parameters', 'Parameter CI', 'Prediction', 'Prediction CI', 'Residuals'};
    varnames = {'beta', 'betaci', 'yhat', 'yci', 'residuals'};

	structure = stats.structure;
	beta = stats.beta;
    R = structure.R;
    df = structure.df;
    rmse = structure.normr / sqrt(df);
    Rinv = eye(size(R))/R;
    dxtxi = sqrt(sum(Rinv'.*Rinv'));
    dbeta = dxtxi*stats.crit(degree)*rmse;
    yhat = polyval(beta,x);
	[newy, deltay] = getyvalues(newx,stats,degree,ud);

    fullresid = y-yhat;
    if (any(wasnan))
       fullresid = statinsertnan(wasnan,fullresid);
    end
    
    items = {beta, [beta-dbeta; beta+dbeta], newy, [newy-deltay newy+deltay], fullresid};
    export2wsdlg(labels, varnames, items, 'Export to Workspace');
    set(poly_fig,'WindowButtonMotionFcn', bmf);
    set(poly_fig,'WindowButtonDownFcn', bdf);

case 'conf',
  if (nargin > 1), conf = flag; end
  switch(conf)
   case 1, ud.simflag = 1;             % simultaneous
   case 2, ud.simflag = 0;             % nonsimultaneous
   case 3, ud.obsflag = 0;             % for the mean (fitted line)
   case 4, ud.obsflag = 1;             % for a new observation
   case 5, ud.confflag = ~ud.confflag; % no confidence intervals
  end
  setconf(ud);
  set(poly_fig, 'UserData', ud);

  % Update bounds
    updateplot(poly_axes,x,y,ud,degree,fitline,reference_line,newx,y_field);

case 'method',
   if (nargin > 1), fittype = flag; end
   switch(fittype)
    case 1, ud.robflag = 0;             % least squares (not robust)
    case 2, ud.robflag = 1;             % robust fit
   end
   setfit(ud);

   % Update
   ud.stats = dofit(x,y,degree,ud.stats,ud.robflag);
   set(poly_fig, 'UserData', ud);
   updateplot(poly_axes,x,y,ud,degree,fitline,reference_line,newx,y_field);
end

if nargout == 1
   h = fitline;
end

function stats = dofit(x,y,degree,stats,robflag)
%DOFIT    Do fitting, either least squares or robust
if (~robflag)
   [stats.beta, stats.structure] = polyfit(x,y,degree);
else
   % Construct Vandermonde matrix
   V = ones(length(x),degree+1);
   if (degree>0), V(:,end-1) = x; end
   for j = degree-1:-1:1
      V(:,j) = x.*V(:,j+1);
   end
   [beta, other] = robustfit(V,y,'bisquare',[],0);
   
   % Compute robust version of stuff polyfit places into structure
   S.R = other.R;
   S.df = other.dfe;
   S.normr = sqrt(other.dfe) * other.s;
   stats.beta = beta';
   stats.structure = S;
end


function setyfields(newy,deltay,y_field,confflag)
% SETYFIELDS Local function for changing the Y field values.
set(y_field(1),'String',num2str(double(newy)));
if (isnan(deltay) || ~confflag)
   set(y_field(2),'String','');
   set(y_field(3),'String','');
else
   set(y_field(2),'String',num2str(double(deltay)));
   set(y_field(3),'String',' +/-');
end

function setreferencelines(newx,newy,reference_line)
% SETREFERENCELINES Local function for moving reference lines on polytool figure.
xrange = get(gca,'Xlim');
yrange = get(gca,'Ylim');
set(reference_line(1),'YData',yrange,'Xdata',[newx newx]);   % vertical reference line.
set(reference_line(2),'XData',xrange,'Ydata',[newy newy]);   % horizontal reference line.
 

function [yhat, deltay] = getyvalues(x,stats,degree,ud)
% GETYVALUES Local function for generating Y predictions and confidence intervals.
S = stats.structure;
[yhat, deltay]=polyval(stats.beta,x,S);
df = S.df;
normr = S.normr;
if (ud.obsflag || S.normr==0)
   dy = deltay;
else
   e = (deltay * sqrt(df) / normr).^2;
   e = sqrt(max(0, e-1));
   dy = normr/sqrt(df)*e;
end
if (ud.simflag)
   crit = stats.fcrit(degree);
else
   crit = stats.crit(degree);
end
deltay = dy * crit;


function [minx, maxx] = plotlimits(x)
% PLOTLIMITS   Local function to control the X-axis limit values.
maxx = max(x(:));
minx = min(x(:));
xrange = maxx - minx;
maxx = maxx + 0.025 * xrange;
minx = minx - 0.025 * xrange;

function [plotHandles, newx] = makeplots(x,y,stats,degree,poly_axes,ud)
% MAKEPLOTS   Local function to create the plots in polytool.
[minx, maxx] = plotlimits(x);
xfit = linspace(minx,maxx,41)';
[yfit deltay] = getyvalues(xfit,stats,degree,ud);

set(poly_axes,'UserData','poly_axes','XLim',[minx maxx],'Box','on');
set(poly_axes,'NextPlot','add','DrawMode','fast','Position',[.21 .18 .75 .72]);

% Plot prediction function with uncertainty bounds.
plotHandles.fitline = plot(x,y,'b+',xfit,yfit,'g-',xfit,yfit-deltay,'r--',...
                           xfit,yfit+deltay,'r--');
yrange = get(poly_axes,'YLim');
xrange = get(poly_axes,'XLim');

% Plot Reference Lines
newx = xfit(21);
newy = yfit(21);
reference_line = zeros(1,2);
reference_line(1) = plot([newx newx],yrange,'k--','Erasemode','xor');
reference_line(2) = plot(xrange,[newy newy],'k:','Erasemode','xor');
set(reference_line(1),'ButtonDownFcn','polytool(''down'')');
plotHandles.reference_line = reference_line;

function uicontrolHandles = makeuicontrols(newx,xstr,ystr,stats,degree,ud)
% MAKEUICONTROLS   Local function to create uicontrols for polytool. 

if strcmp(computer,'MAC2')
  offset = -0.01;
else
  offset = 0;
end

fcolor = get(gcf,'Color');

xfieldp = [.50 .07 .15 .05];
yfieldp = [.01 .45 .13 .04]; 

[newy, deltay] = getyvalues(newx,stats,degree,ud);

uicontrolHandles.x_field = uicontrol('Style','edit','Units','normalized','Position',xfieldp,...
         'String',num2str(double(newx)),'BackgroundColor','white','UserData',newx,...
         'CallBack','polytool(''edittext'')','String',num2str(double(newx)));

ytext=uicontrol('Style','text','Units','normalized',...
      'Position',yfieldp + [0 0.20 0 0],'String',ystr,...
	  'BackgroundColor',fcolor,'ForegroundColor','k');

uicontrolHandles.y_field(1)= uicontrol('Style','text','Units','normalized',...
         'Position',yfieldp + [0 .14 0 0],'String',num2str(double(newy)),...
         'BackgroundColor',fcolor,'ForegroundColor','k');

uicontrolHandles.y_field(3)= uicontrol('Style','text','Units','normalized',...
         'Position',yfieldp + [0 .07 -0.01 0],'String',' +/-',...
         'BackgroundColor',fcolor,'ForegroundColor','k');

uicontrolHandles.y_field(2)= uicontrol('Style','text','Units','normalized',...
         'Position',yfieldp,'String',num2str(double(deltay)),...
         'BackgroundColor',fcolor,'ForegroundColor','k');

uicontrol('Style','text','Units','normalized',...
     'Position',xfieldp - [0 0.07 0 0],'ForegroundColor','k',...
	 'BackgroundColor',fcolor,'String',xstr);

uicontrol('Style','Text','String','Degree','Units','normalized',...
        'Position',xfieldp + [-0.03 0.87+offset -0.05 0],'ForegroundColor','k',...
		'BackgroundColor',fcolor);

uicontrolHandles.degreetext=uicontrol('Style','Edit','String',num2str(double(degree)),...
        'Units','normalized','Userdata',degree,'BackgroundColor','white',...
        'Position',xfieldp + [0.07 0.87 -0.10 0],...
        'CallBack','polytool(''change_degree'')');

uicontrolHandles.outputpopup=uicontrol('String', 'Export...',...
        'Units','normalized','Position',[0.01 0.07 0.17 0.05],...
        'CallBack','polytool(''output'')');


close_button = uicontrol('Style','Pushbutton','Units','normalized',...
               'Position',[0.01 0.01 0.17 0.05],'Callback','close','String','Close');

% Create menu for controlling confidence bounds
f = uimenu('Label','&Bounds', 'Position', 4, 'UserData','conf');
uimenu(f,'Label','&Simultaneous', ...
       'Callback','polytool(''conf'',1)', 'UserData',1);
uimenu(f,'Label','&Nonsimultaneous', ...
       'Callback','polytool(''conf'',2)', 'UserData',2);
uimenu(f,'Label','&Curve', 'Separator','on', ...
       'Callback','polytool(''conf'',3)', 'UserData',3);
uimenu(f,'Label','&Observation', ...
       'Callback','polytool(''conf'',4)', 'UserData',4);
uimenu(f,'Label','N&one', 'Separator','on', ...
       'Callback','polytool(''conf'',5)', 'UserData',5);

% Create menu for controlling fit type
f = uimenu('Label','&Method', 'Position', 5, 'UserData','method');
uimenu(f,'Label','&Least squares', ...
       'Callback','polytool(''method'',1)', 'UserData',1);
uimenu(f,'Label','&Robust', ...
       'Callback','polytool(''method'',2)', 'UserData',2);

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
function setfit(ud)
%SETFIT Update menus to reflect fit type

ma = findobj(gcf, 'Type','uimenu', 'UserData','method');
hh = findobj(ma, 'Type','uimenu');

set(hh, 'Checked', 'off');          % uncheck all menu items

hh = findobj(ma, 'Type', 'uimenu', 'UserData', 1+ud.robflag);
if (length(hh) == 1), set(hh, 'Checked', 'on'); end

% -----------------------------------
function updateplot(poly_axes,x,y,ud,degree,fitline,reference_line,newx,y_field)
%UPDATEPLOT Update plot after degree or confidence setting change

[minx maxx] = plotlimits(x);
xfit = linspace(minx,maxx,41);
[yfit, deltay] = getyvalues(xfit,ud.stats,degree,ud);
if (ud.confflag)
   ylo = yfit - deltay;
   yhi = yfit + deltay;
   [miny maxy] = plotlimits([yhi;ylo]);
else
   ylo = repmat(NaN, size(yfit));
   yhi = ylo;
   [miny maxy] = plotlimits(yfit);
end
ymax = max(y);
ymin = min(y);
delta = .05 * (ymax - ymin);
miny = min(miny, ymin - delta);
maxy = max(maxy, ymax + delta);

set(fitline(1),'XData',x,'YData',y,'Color','b','Marker','+');
set(fitline(2),'XData',xfit,'YData',yfit,'Color','g','Linestyle','-');
set(fitline(3),'XData',xfit,'YData',ylo,'Color','r','Linestyle','--');
set(fitline(4),'XData',xfit,'YData',yhi,'Color','r','Linestyle','--');

set(poly_axes,'YLim',[miny maxy]);
[newy, deltay] = getyvalues(newx,ud.stats,degree,ud);
setreferencelines(newx,newy,reference_line);
if (~ud.confflag), deltay = NaN; end	
setyfields(newy,deltay,y_field,ud.confflag)
