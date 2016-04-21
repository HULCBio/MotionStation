function rstool(x,y,model,alpha,xname,yname)
%RSTOOL Interactive fit and plot of a multidimensional response surface (RSM).
%   RSTOOL(X,Y,MODEL,ALPHA) is a prediction plot that provides a 
%   multiple input polynomial fit to (X,y) data. It plots a 100(1 - ALPHA) 
%   percent global confidence interval for predictions as two red curves. 
%   The default model is linear. MODEL can be following strings:
%   interaction - includes constant, linear, and cross product terms.
%   quadratic - interactions plus squared terms.
%   purequadratic - includes constant, linear and squared terms.
%   The default value for ALPHA is 0.05, which produces 95% confidence 
%   intervals.
%
%   RSTOOL(X,Y,MODEL,ALPHA,XNAME,YNAME) The optional inputs XNAME and 
%   YNAME contain strings for the X and Y variables respectively.
%
%   Drag the dashed blue reference line and watch the predicted
%   values update simultaneously. Alternatively, you can get a specific
%   prediction by typing the "X" value into an editable text field.
%   Use the pop-up menu labeled model to interactively change the model.
%
%   Use the push button labeled Export to move specified variables to
%   the base workspace.  Exported coefficients appear in the order
%   defined by the X2FX function.
   
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.27.4.2 $  $Date: 2004/01/16 20:10:27 $

if (nargin<1) || ~ischar(x) 
    action = 'start';
else
    action = x;
end

%On recursive calls get all necessary handles and data.
if ~strcmp(action,'start')
   if nargin == 2,
      flag = y;
   end
   lin_fig = findobj(0,'Tag','linfig');
   if strcmp(action,'down')
       set(lin_fig,'WindowButtonMotionFcn','rstool(''motion'',1)');
    end

   k = gcf;
   idx = find(lin_fig == k);
   if isempty(idx)
      return
   end
   lin_fig = lin_fig(idx);      
   ud = get(lin_fig,'Userdata');
   
   rmse          = ud.rmse;
   residuals     = ud.residuals;
   alpha         = ud.alpha;
   modelpopup    = ud.modelpopup;
      
   beta          = ud.beta;
   model         = ud.model;
   x_field       = ud.x_field;
   lin_axes      = ud.lin_axes;
   xsettings     = ud.xsettings;
   y_field1      = ud.y_field(:,1);
   last_axes     = ud.last_axes;  
   x             = ud.x;
   y             = ud.y;  
   [m,n]         = size(x);
   ny            = size(y,2);

   xrange         = zeros(n,2);
   newx           = zeros(n,1);
   for k = 1:n         
      xrange(k,1:2) = get(lin_axes(k,1),'XLim');
   end

   newy = y_field1;
   for j = 1:length(newy)
      newy(j) = str2double(get(y_field1(j),'String'));
   end
end

switch action

case 'start'

if (nargin<2)
   error('stats:rstool:InputSizeMismatch',...
         'At least two arguments are required.');
end
 
% Remove Nan if necessary
if (size(y,1) == 1), y = y(:); end
good = (sum(isnan(y),2) == 0) & (sum(isnan(x),2) == 0);
if (any(~good))
   y = y(good,:);
   x = x(good,:);
end
 
[m,n]  = size(x);
ny = size(y,2);

if nargin < 4, 
    alpha = 0.05;
end
if isempty(alpha)
    alpha = 0.05;
end

if (nargin < 5), xname = []; end
if (isempty(xname))
   xname = [repmat('X',n,1) strjust(int2str((1:n)'),'left')];
end
xstr = cellstr(xname(1:n,:));

if (nargin < 6), yname = []; end
if (isempty(yname))
   yname = [repmat('Predicted Y',ny,1) strjust(int2str((1:ny)'),'left')];
end
ystr = cellstr(yname(1:ny,:));

ud.usermodel = [];
if nargin < 3, model = ''; end
if isempty(model) || strcmp(model,'linear') || strcmp(model,'l')
   model = 'linear';
   mval  = 1;
   name  = 'Linear';
elseif strcmp(model,'purequadratic') || strcmp(model,'p'),
   mval  = 2;
   name  = 'Pure Quadratic';
elseif strcmp(model,'interaction') || strcmp(model,'i'),
   mval  = 3;
   name  = 'Interactions';
elseif strcmp(model,'quadratic') || strcmp(model,'q'),
   mval  = 4;
   name  = 'Full Quadratic';
elseif ~ischar(model)
   mval  = 5;
   name  = 'UserSpecified';
   ud.usermodel = model;
else
   if any(exist(model,'file') == [2 3])
      mval  = 5;
      name  = model;
      ud.usermodel = model;
   else
      error('stats:rstool:BadModel','Cannot find MODEL %s.',model);
   end
end

design = x2fx(x,model);

% Fit response surface model design
if size(design,2) > size(x,1)
    error('stats:rstool:NotEnoughData',...
          'Insufficient data to fit model %s.',name);
end

[Q, R] = qr(design,0);
if rcond(R) < 1E-12
    error('stats:rstool:NotEnoughData',...
          'Insufficient data to fit model %s.',name);
end

[beta yhat residuals p df rmse crit] = endfit(Q,R,y,design,alpha);

ud.beta = beta;
ud.crit = crit;
ud.R    = R;
ud.model = model;
ud.good = good;

% Set positions of graphic objects
maxx = max(x);
minx = min(x);
xrange = maxx - minx;
maxx = maxx + 0.025 .* xrange;
minx = minx - 0.025 .* xrange;
xrange = 1.05*xrange;

lin_axes       = zeros(n,ny);
fitline        = zeros(3,n,ny);
reference_line = zeros(2,n,ny);

xfit      = xrange(ones(41,1),:)./40;
xfit(1,:) = minx;
xfit      = cumsum(xfit);

avgx      = mean(x);

xsettings = avgx(ones(42,1),:);

ud.xfit = xfit;
ud.xsettings = xsettings;


lin_fig = figure('Units','Normalized','Interruptible','on',...
             'Position',[0.05 0.45 0.90 0.5],...
             'Name',['Prediction Plot of ',name,' Model'],'Tag','linfig');
set(lin_fig,'BusyAction','queue','WindowButtonMotionFcn','rstool(''motion'',0)');
set(lin_fig,'WindowButtonDownFcn','rstool(''down'')');
set(lin_fig,'WindowButtonUpFcn','rstool(''up'')','Interruptible','on');
set(0,'CurrentFigure',lin_fig);

% Set up axes
xtmp = 0:1;
for k = 1:n
   for j = 1:ny
      % Create an axis for each pair of input (x) and output (y) variables
      axisp   = [.18+(k-1)*.80/n  .22+(j-1)*.76/ny  .80/n  .76/ny];
      lin_axes(k,j) = axes;
      set(lin_axes(k,j),'XLim',[minx(k) maxx(k)],'Box','on',...
                        'NextPlot','add','DrawMode','fast',...
                        'Position',axisp,'Gridlinestyle','none');
      if k>1, set(lin_axes(k,j),'Yticklabel',[]); end
      if j>1, set(lin_axes(k,j),'Xticklabel',[]); end

      % Add curves
      fitline(1:3,k,j) = plot(xtmp,xtmp,'g-', xtmp,xtmp,'r--', xtmp,xtmp,'r--');
      
      % Add reference Lines
      reference_line(1,k,j) = plot(xtmp, xtmp,'--', 'Erasemode','xor');
      reference_line(2,k,j) = plot(xtmp, xtmp,':', 'Erasemode','xor');
      set(reference_line(1,k,j),'ButtonDownFcn','rstool(''down'')');
   end
end

ud.fitline = fitline;
ud.lin_axes = lin_axes;
ud.reference_line = reference_line;

uihandles = MakeUIcontrols(xstr,lin_fig,ystr,avgx,mval,ud.usermodel);

ud.export = uihandles.export;
ud.modelpopup = uihandles.modelpopup;
ud.x_field = uihandles.x_field; 
ud.y_field = uihandles.y_field;

% Update curves and reference lines on all graphs
calcy(n,ny,ud);

ud.texthandle = [];
ud.residuals = residuals;
ud.reference_line = reference_line;
ud.last_axes = zeros(1,n);
ud.x = x;
ud.y = y;
ud.rmse = rmse;
ud.alpha = alpha;
set(lin_fig,'UserData',ud,'HandleVisibility','callback');
% Finished with plot startup function.

case 'motion',
   p = get(lin_fig,'CurrentPoint');
   k = floor(1+n*(p(1)-0.18)/.80);
   j = floor(1+ny*(p(2)-.22)/.76);
   if k < 1 || k > n || p(2) > 0.90 || p(2) < 0.22 || j < 1 || j > ny
      return
   end
   newx(k) = str2double(get(x_field(k),'String'));        
   maxx = xrange(k,2);
   minx = xrange(k,1);
   set(lin_fig,'CurrentAxes',lin_axes(k,j));
   if flag == 0,
        cursorstate = get(lin_fig,'Pointer');
        cp = get(lin_axes(k,j),'CurrentPoint');
        cx = cp(1,1);
        fuzz = 0.02 * (maxx - minx);
        online = cx > newx(k) - fuzz & cx < newx(k) + fuzz;
        if online && strcmp(cursorstate,'arrow'),
            cursorstate = 'crosshair';
        elseif ~online && strcmp(cursorstate,'crosshair'),
            cursorstate = 'arrow';
        end
        set(lin_fig,'Pointer',cursorstate);
        return

   elseif flag == 1,
        if last_axes(k) == 0, return; end
        updateref(k, j, ud, maxx, minx);
   
   end  % End of code for dragging reference lines

case 'down',
   p = get(lin_fig,'CurrentPoint');
   k = floor(1+n*(p(1)-0.18)/.80);
   j = floor(1+ny*(p(2)-.22)/.76);
   if k < 1 || k > n || p(2) > 0.90 || p(2) < 0.22 || j < 1 || j > ny
      return
   end
   ud.last_axes(k) = 1;
   set(lin_fig,'Pointer','crosshair');
   xrange = get(lin_axes(k,j),'Xlim');
   maxx = xrange(2);
   minx = xrange(1);
   updateref(k, j, ud, maxx, minx);

case 'up',
   p = get(lin_fig,'CurrentPoint');
   k = floor(1+n*(p(1)-0.18)/.80);
   lk = find(last_axes == 1);
   if isempty(lk)
      return
   end
   if k < lk
      set(x_field(lk),'String',num2str(xrange(lk,1)));
   elseif k > lk
      set(x_field(lk),'String',num2str(xrange(lk,2)));
   end

   cx    = str2double(get(x_field(lk),'String'));  
   xsettings(:,lk) = cx(ones(42,1));
   ud.xsettings = xsettings;

   % Update graph
   calcy(n, ny, ud, lk, cx);
   
   ud.last_axes = zeros(n,1);
   set(lin_fig,'WindowButtonMotionFcn','rstool(''motion'',0)','Pointer','arrow','Userdata',ud);

case 'edittext',
   cx    = str2double(get(x_field(flag),'String'));  
   if isempty(cx)
       set(x_field(flag),'String',num2str(xsettings(1,flag)));
       % Create Bad Settings Warning Dialog.
       warndlg('Please type only numbers in the editable text fields.');
       return
   end  
   
   xl = get(lin_axes(flag,1),'Xlim');
   if cx < xl(1) || cx > xl(2)
       % Create Bad Settings Warning Dialog.
       warndlg('This number is outside the range of the data for this variable.');
       set(x_field(flag),'String',num2str(xsettings(1,flag)));
       return
   end
   
   xsettings(:,flag) = cx(ones(42,1));
   ud.xsettings = xsettings;            

   % Update graph
   calcy(n, ny, ud, flag, cx);

   set(lin_fig,'Userdata',ud);       

case 'output',
     bmf = get(lin_fig,'WindowButtonMotionFcn');
     bdf = get(lin_fig,'WindowButtonDownFcn');
     set(lin_fig,'WindowButtonMotionFcn','');
     set(lin_fig,'WindowButtonDownFcn','');
 
    checkLabels = {'Save fitted paramters to a MATLAB variable named: ', ...
                   'Save RSME to a MATLAB variable named: ',...
                   'Save residuals to a MATLAB variable named: '};
    defaultVarNames = {'beta', 'rmse', 'residuals'};
 
    if (all(ud.good))
        fullresid = residuals;
    else
        fullresid = repmat(NaN, length(ud.good), size(residuals,2));
        fullresid(ud.good,:) = residuals;
    end
    
    items = {beta, rmse, fullresid};
     
    export2wsdlg(checkLabels, defaultVarNames, items, 'Export to Workspace');
    
     set(lin_fig,'WindowButtonMotionFcn',bmf);
     set(lin_fig,'WindowButtonDownFcn',bdf);

case 'changemodel',
   cases = get(modelpopup,'Value');
   if cases == 1
      model = 'linear';
   elseif cases == 2
      model = 'purequadratic';
   elseif cases == 3
      model = 'interaction';
   elseif cases == 4
      model = 'quadratic';
   elseif cases == 5
      if ischar(model)
         if isempty(ud.usermodel)
            disp('Call RSTOOL with a numeric model matrix to use the User Specified model.');
            disp('See the help for X2FX.');            
            disp('Fitting a linear model.');
            model = 'linear';
            set(modelpopup,'Value',1);
         else
            model = ud.usermodel;
			if ischar(ud.usermodel)
			   set(lin_fig,'Name',['Prediction Plot of ',ud.usermodel,' Model'])
            else
	           set(lin_fig,'Name', 'Prediction Plot of User Specified Model')
			end
         end
      end
   end
    
   % Fit response surface model design
   design = x2fx(x,model);
   [Q, R] = qr(design,0);
 
   if rcond(R) < 1E-12
       % Create Model Warning Figure.
       s = ['Your data is insufficient to fit a ',model, ' model. Resetting to previous model.'];
       warndlg(s);
       mval = get(modelpopup,'Userdata');
       set(modelpopup,'Value',mval);

       if mval == 1
          set(lin_fig,'Name','Prediction Plot of Linear Model')
       elseif mval == 2
          set(lin_fig,'Name','Prediction Plot of Pure Quadratic Model')
       elseif mval == 3
          set(lin_fig,'Name','Prediction Plot of Interactions Model')
       elseif mval == 4
          set(lin_fig,'Name','Prediction Plot of Full Quadratic Model')
       end
       drawnow;
       return;
    end
   
    [beta yhat residuals p df rmse crit] = endfit(Q,R,y,design,alpha);
    
    ud.crit      = crit;
    ud.rmse      = rmse;
    ud.R         = R;
    ud.beta      = beta;
    ud.model     = model;
    ud.residuals = residuals;
    set(lin_fig,'Userdata',ud);   

    % Update graph
    calcy(n, ny, ud);

   if cases == 1
      set(lin_fig,'Name','Prediction Plot of Linear Model')
   elseif cases == 2
      set(lin_fig,'Name','Prediction Plot of Pure Quadratic Model')
   elseif cases == 3
      set(lin_fig,'Name','Prediction Plot of Interactions Model')
   elseif cases == 4
      set(lin_fig,'Name','Prediction Plot of Full Quadratic Model')
   end
   set(modelpopup,'Userdata',cases);
end

function uihandles = MakeUIcontrols(xstr,lin_fig,ystr,avgx,mval,usermodel)
% Local function for Creating uicontrols for rstool.
n = length(xstr);
fcolor = get(lin_fig,'Color');
for k = 1:n
   xfieldp = [.18 + (k-0.5)*.80/n - 0.5*min(.5/n,.15) .09 min(.5/n,.15) .07];
   xtextp  = [.18 + (k-0.5)*.80/n - 0.5*min(.5/n,.18) .02 min(.5/n,.18) .05];
   uicontrol(lin_fig,'Style','text','Units','normalized',...
        'Position',xtextp,'BackgroundColor',fcolor,...
        'ForegroundColor','k','String',xstr{k});

   uihandles.x_field(k)  = uicontrol(lin_fig,'Style','edit',...
         'Units','normalized','Position',xfieldp,'String',num2str(avgx(k)),...
         'BackgroundColor','white',...
         'CallBack',['rstool(''edittext'',',int2str(k),')']);
end

ny = length(ystr);
oldu = get(uihandles.x_field(1),'FontUnits');
set(uihandles.x_field(1), 'FontUnits', 'normalized');
halfsize = 0.6 * get(uihandles.x_field(1), 'FontSize') * .07;
set(uihandles.x_field(1), 'FontUnits', oldu);
yfieldp = [.01 0 .10 2*halfsize];

for j = 1:ny
   ycenter = .22+(j-.5)*.76/ny;

   % y value field
   yfieldp(2) = ycenter + halfsize;
   uihandles.y_field(j,1) =uicontrol(lin_fig,'Style','text',...
         'Units','normalized', 'Position',yfieldp,...
         'String','', 'ForegroundColor','k', 'BackgroundColor',fcolor);

   % y delta field
   yfieldp(2) = ycenter - 3 * halfsize;
   uihandles.y_field(j,2) =uicontrol(lin_fig,'Style','text',...
         'Units','normalized', 'Position',yfieldp,...
         'String','', 'ForegroundColor','k', 'BackgroundColor',fcolor);

   % plus or minus field
   yfieldp(2) = ycenter - halfsize;
   uicontrol(lin_fig,'Style','text','Units','normalized',...
          'Position',yfieldp, 'String',' +/-',...
          'ForegroundColor','k','BackgroundColor',fcolor);

   % y name field
   yfieldp(2) = ycenter + 3 * halfsize;
   uicontrol(lin_fig,'Style','text','Units','normalized',...
          'Position',yfieldp, 'BackgroundColor',fcolor,...
          'ForegroundColor','k','String',ystr(j));
end
   
uihandles.export     = uicontrol(lin_fig,'Style','Pushbutton','String',...
              'Export...', 'Units','normalized','Position', ...
              [0.01 0.14 0.13 0.05], 'CallBack','rstool(''output'')');

if isempty(usermodel)
   modellist = 'Linear|Pure Quadratic|Interactions|Full Quadratic';
else
   modellist = 'Linear|Pure Quadratic|Interactions|Full Quadratic|User Specified';
end

uihandles.modelpopup = uicontrol(lin_fig,'Style','Popup','String',...
        modellist, ...
          'Value',mval,'BackgroundColor','w',...
              'Units','normalized','Position',[0.01 0.08 0.13 0.05],...
              'CallBack','rstool(''changemodel'')','Userdata',mval);

uicontrol('Style','Pushbutton','Units','normalized',...
         'Position',[0.01 0.02 0.13 0.05],'Callback','close','String','Close');

% ---- helper to create or update prediction curves
function deltay = calcy(n,ny,ud, xk, xval)

crit      = ud.crit;
beta      = ud.beta;
R         = ud.R;
model     = ud.model;
xsettings = ud.xsettings;
xfit      = ud.xfit;
fitline   = ud.fitline;
lin_axes  = ud.lin_axes;
reference_line = ud.reference_line;

% Get info stored in figure
yextremes = zeros(n,ny,2);

for k = 1:n
   % Calculate y values for fitted line plot.
   ith_x      = xsettings;
   xi         = xfit(:,k);
   ith_x(1:41,k) = xi;
   if (nargin > 4)
      ith_x(42, xk) = xval;  % otherwise row 42 stays at current setting
   end
   
   % Calculate y values for confidence interval lines.
   xpred = x2fx(ith_x,model);
   yfit  = xpred(1:41,:)*beta;
   newy  = xpred(42,:)*beta;
   E     = xpred(1:41,:)/R;
   tmp   = sqrt(sum((E.*E)'));
   dy    = repmat(tmp',1,length(crit)) .* repmat(crit, length(tmp), 1);

   for j = 1:ny
      % Plot prediction line with confidence intervals
      yfitj = yfit(:,j);
      dyj = dy(:,j);
      t1 = yfitj - dyj;
      t2 = yfitj + dyj;
      set(gcf,'CurrentAxes',lin_axes(k,j));
      set(fitline(1,k,j),'Xdata',xi,'Ydata',yfitj);
      set(fitline(2,k,j),'Xdata',xi,'Ydata',t1);
      set(fitline(3,k,j),'Xdata',xi,'Ydata',t2);

      % No x ticks right near the end, they might overlap the next axis
      xl = get(lin_axes(k,j),'Xlim');
      xr = diff(xl);
      xt = get(lin_axes(k,j),'XTick');
      lowtick = xl(1) + .1*xr;
      hitick  = xl(2) - .1*xr;
      xt = xt(xt>lowtick & xt<hitick);
      set(lin_axes(k,j),'Xtick',xt);
      
      % Calculate data for vertical reference lines, allow for dyj=NaN
      yextremes(k,j,1) = min(min(yfitj), min(t1));
      yextremes(k,j,2) = max(max(yfitj), max(t2));

      if (k == 1)
         E = xpred(42,:)/R;
         deltay = sqrt(E*E')*crit;
      end
   end

end  % End of the plotting loop over all the axes.

ymin = min(yextremes(:,:,1), [], 1);
ymax = max(yextremes(:,:,2), [], 1);

for k = 1:n
   t1 = xsettings([1 1], k);
   t2 = get(lin_axes(k,1),'XLim');
   for j = 1:ny
      set(lin_axes(k,j), 'XLim', t2);
      set(reference_line(1,k,j),'Xdata', t1);
      set(reference_line(2,k,j),'XData', t2);
   end
end
for j = 1:ny
   t1 = [ymin(j) ymax(j)];
   t2 = newy([j j]);
   for k = 1:n
      set(lin_axes(k,j), 'YLim', t1);
      set(reference_line(1,k,j),'Ydata', t1);
      set(reference_line(2,k,j),'YData', t2);
   end
end

% Update labels
for j = 1:ny
   set(ud.y_field(j,1),'String',num2str(newy(j)));
   set(ud.y_field(j,2),'String',num2str(deltay(j)));
end


% ------- helper to compute fit results
function [b,yhat,res,p,df,rmse,crit]=endfit(Q,R,y,design,alpha)
% complete fit after the QR decomposition 

b = R\(Q'*y);

yhat = design*b;
res = y - yhat;

p = length(b);
df = max(size(y,1)) - p;

if (df > 0)
   rmse = sqrt(sum(res.*res)./df);
   crit = sqrt(p*finv(1 - alpha,p,df))*rmse;
else
   rmse = NaN;
   crit = NaN;
end

% -------- helper to update reference lines
function updateref(k, j, ud, maxx, minx)
% Update reference line on axis (k,j) using current settings

cp = get(ud.lin_axes(k,j),'CurrentPoint');
cx = min(maxx, max(minx, cp(1,1)));

xrow  = ud.xsettings(1,:);
xrow(k) = cx;
      
drow = x2fx(xrow, ud.model);
yrow = drow * ud.beta;
E = drow / ud.R;
deltay = sqrt(E*E') * ud.crit;

ud.xsettings(:,k) = cx(ones(42,1));
set(gcf,'Userdata',ud);       
set(ud.x_field(k),'String',num2str(cx));
set(ud.y_field(j,1),'String',num2str(yrow(j)));
set(ud.y_field(j,2),'String',num2str(deltay(j)));
set(ud.reference_line(1,k,j),'XData',cx*ones(2,1));
set(ud.reference_line(2,k,j),'YData',[yrow(j); yrow(j)]);
