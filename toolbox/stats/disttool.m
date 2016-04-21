function disttool(action,flag)
%DISTTOOL Demonstration of many probability distributions.
%   DISTTOOL creates interactive plots of probability distributions.
%   This is a demo that displays a plot of the cdf or pdf of
%   the distributions in the Statistics Toolbox.
%
%   Use popup menus to change the distribution (Normal to Binomial) or
%   the function (cdf to pdf). 
%
%   You can change the parameters of the distribution by typing
%   a new value or by moving a slider.    
%
%   You can interactively calculate new values by dragging a reference 
%   line across the plot.
%
%   Call DISTTOOL without arguments.
   
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.34.4.1 $  $Date: 2004/01/24 09:33:23 $

if nargin < 1
    action = 'start';
end

%On recursive calls get all necessary handles and data.
if ~strcmp(action,'start')   
   childList = allchild(0);
   distfig = childList(childList == gcbf);
   ud = get(distfig,'Userdata');
   if isempty(ud) && strcmp(action,'motion')
      return
   end
  
   iscdf = 2 - get(ud.functionpopup,'Value');
   newx = str2double(get(ud.xfield,'string'));
   newy = str2double(get(ud.yfield,'string'));
   popupvalue = get(ud.popup,'Value');
   if popupvalue == 2 || popupvalue == 4 || popupvalue == 9 || ...
      popupvalue == 11 || popupvalue == 16,
       discrete = 1;
   else
       discrete = 0;
   end

   if popupvalue == 2  || popupvalue == 4 || popupvalue == 11 
       intparam1 = 1;
   else 
       intparam1 = 0;
   end

   intparam2 = 0;
   intparam3 = 0;

   switch action,
      case 'motion',ud = mousemotion(ud,discrete,flag,newx,newy);
      case 'down',  ud = mousedown(ud,discrete,flag);
      case 'up',    mouseup;
      case 'setpfield',
         switch flag
             case 1, ud = setpfield(1,intparam1,ud,newx);
             case 2, ud = setpfield(2,intparam2,ud,newx);
             case 3, ud = setpfield(3,intparam3,ud,newx);
         end
      case 'setpslider',
         switch flag
             case 1, ud = setpslider(1,intparam1,ud,newx);
             case 2, ud = setpslider(2,intparam2,ud,newx);
             case 3, ud = setpslider(3,intparam3,ud,newx);
         end
      case 'setphi',
         switch flag
            case 1, ud = setphi(1,intparam1,ud,newx);
            case 2, ud = setphi(2,intparam2,ud,newx);
            case 3, ud = setphi(3,intparam3,ud,newx);
         end
      case 'setplo',
         switch flag
            case 1, ud = setplo(1,intparam1,ud,newx);
            case 2, ud = setplo(2,intparam2,ud,newx);
            case 3, ud = setplo(3,intparam3,ud,newx);
         end
      case 'changedistribution', 
         ud = changedistribution(iscdf,popupvalue,ud,discrete,[intparam1 intparam2 intparam3]);
      case 'changefunction', 
         ud = changefunction(iscdf,popupvalue,ud,discrete,newx,[intparam1 intparam2 intparam3]);
      case 'editx', ud = editx(ud);
      case 'edity', ud = edity(ud);
   end
end
% Initialize all GUI objects. Plot Normal CDF with sliders for parameters.
if strcmp(action,'start'),
   % Set positions of graphic objects
   axisp   = [.23 .35 .75 .55];
   pos = cell(7,3);
   pos{6,1} = [.15 .155 .07 .06];   % upper bound label
   pos{5,1} = [.14 .075 .08 .05];   % text
   pos{7,1} = [.15 .015 .07 .06];   % lower bound label
   pos{2,1} = [.23 .155 .10 .05];   % upper bounds
   pos{1,1} = [.23 .085 .10 .05];   % parameter
   pos{3,1} = [.23 .015 .10 .05];   % lower bounds
   pos{4,1} = [.34 .015 .03 .19];   % slider
   
   pos{6,2} = [.455 .155 .07 .06];   % upper bound label
   pos{5,2} = [.445 .075 .08 .05];   % text
   pos{7,2} = [.455 .015 .07 .06];   % lower bound label
   pos{2,2} = [.535 .155 .10 .05];   % upper bound
   pos{1,2} = [.535 .085 .10 .05];   % parameter
   pos{3,2} = [.535 .015 .10 .05];   % lower bound
   pos{4,2} = [.645 .015 .03 .19];   % slider
   
   pos{6,3} = [.76 .155 .07 .06];   % upper bound label
   pos{5,3} = [.75 .075 .08 .05];   % text
   pos{7,3} = [.76 .015 .07 .06];   % lower bound label
   pos{2,3} = [.84 .155 .10 .05];   % upper bound
   pos{1,3} = [.84 .085 .10 .05];   % parameter
   pos{3,3} = [.84 .015 .10 .05];   % lower bound
   pos{4,3} = [.95 .015 .03 .19];   % slider

   xfieldp = [.54 .245 .13 .05];
   xlabelp = [.50 .235 .04 .05];
   yfieldp = [0.04 .62 .13 .05];

   % Distribution Data
   ud.distcells.name = {'Beta','Binomial','Chisquare',...
                        'Discrete Uniform','Exponential', 'Extreme Value', ...
                        'F', 'Gamma', 'Geometric', ...
                        'Lognormal', 'Negative Binomial', 'Noncentral F', ...
                        'Noncentral T', 'Noncentral Chi-square', 'Normal', ...
                        'Poisson', 'Rayleigh', 'T', ...
                        'Uniform', 'Weibull'};

   ud.distcells.parameters = {[2 2], [10 0.5], 2, ...
                              20, 1, [0 1], ...
                              [5 5], [2 2], 0.5, ...
                              [0.5 0.25], [2 0.6], [5 5 1], ...
                              [5 1], [5 1], [0 1], ...
                              5,  2,  5, ...
                              [0 1], [1 2]};

   ud.distcells.pmax = {[Inf Inf], [Inf 1], Inf, ...
                        Inf, Inf, [Inf Inf], ...
                        [Inf Inf], [Inf Inf], 1, ...
                        [Inf Inf], [Inf 1], [Inf Inf Inf], ...
                        [Inf Inf], [Inf Inf], [Inf Inf], ...
                        Inf, Inf, Inf, ...
                        [Inf Inf], [Inf Inf]};

   ud.distcells.pmin = {[0 0], [0 0], 0, ...
                        0, 0, [-Inf 0], ...
                        [0 0], [0 0], 0, ...
                        [-Inf 0], [0 0], [0 0 0], ...
                        [0 -Inf], [0 0], [-Inf 0], ...
                        0, 0, 0, ...
                        [-Inf -Inf], [0 0]}; 

   ud.distcells.phi = {[4 4], [10 1], 10, ...
                       20, 2, [5 2], ...
                       [10 10], [5 5], 1, ...
                       [1 0.3], [3 0.99], [10 10 5], ...
                       [10 5], [10 5], [2 2], ...
                       5, 5, 10, ...
                       [0.5 2], [3 3]};

   ud.distcells.plo = {[0.5 0.5], [1 0], 1, ...
                       1, 0.5, [-5 .5], ...
                       [5 5], [2 2], 0.25, ...
                       [0 0.1], [1 0.5], [5 5 0], ...
                       [2 0], [2 0], [-2 0.5], ...
                       1, 1, 2, ...
                       [0 1], [.5 .5]}; 

   % Set axis limits and data
   xrange   = [-8 8];
   yrange   = [0 1.1];
   xvalues  = linspace(-8,8);
   yvalues  = cdf('Normal',xvalues,0,1);
   paramtext  = str2mat('Mu','Sigma','  ');
   newx  = 0;
   newy  = 0.5;

   %   Create Cumulative Distribution Plot
   ud.dist_fig = figure('Tag','distfig');
   set(ud.dist_fig,'Units','Normalized','Backingstore','off','InvertHardcopy','on',...
        'PaperPositionMode','auto');
   figcolor = get(ud.dist_fig,'Color');
   if isunix  % default unix size is a little small
        unixpos = get(ud.dist_fig, 'Position');
        newheight = .49;
        hdif = newheight - unixpos(4);
        unixpos(2) = unixpos(2) - hdif;
        unixpos(3) = .4865;
        unixpos(4) = newheight;
        set(ud.dist_fig, 'Position', unixpos);
   end

   dist_axes = axes;
   set(dist_axes,'NextPlot','add','DrawMode','fast',...
      'Position',axisp,'XLim',xrange,'YLim',yrange,'Box','on');
   ud.dline = plot(xvalues,yvalues,'b-','LineWidth',2);

% Define graphics objects
   for idx = 1:3
       nstr = int2str(idx);
       ud.pfhndl(idx) =uicontrol('Style','edit','Units','normalized','Position',pos{1,idx},...
          'String',num2str(ud.distcells.parameters{15}(2-rem(idx,2))),'BackgroundColor','white',...
          'CallBack',['disttool(''setpfield'',',nstr,')']);
         
       ud.hihndl(idx)   =uicontrol('Style','edit','Units','normalized','Position',pos{2,idx},...
         'String',num2str(ud.distcells.phi{15}(2-rem(idx,2))),'BackgroundColor','white',...
         'CallBack',['disttool(''setphi'',',nstr,')']);
         
       ud.lohndl(idx)   =uicontrol('Style','edit','Units','normalized','Position',pos{3,idx},...
         'String',num2str(ud.distcells.plo{15}(2-rem(idx,2))),'BackgroundColor','white',... 
         'CallBack',['disttool(''setplo'',',nstr,')']);

       ud.pslider(idx)=uicontrol('Style','slider','Units','normalized','Position',pos{4,idx},...
         'Value',ud.distcells.parameters{15}(2-rem(idx,2)),'Max',ud.distcells.phi{15}(2-rem(idx,2)),...
         'Min',ud.distcells.plo{15}(2-rem(idx,2)),'Callback',['disttool(''setpslider'',',nstr,')']);

       ud.ptext(idx) =uicontrol('Style','text','Units','normalized','Position',pos{5,idx},...
         'ForegroundColor','k','BackgroundColor',figcolor,'String',paramtext(idx,:)); 
   
       ud.lowerboundtext(idx) =uicontrol('Style','text','Units','normalized', ...
         'Position', pos{7,idx},...
         'ForegroundColor','k','BackgroundColor',figcolor,'String', 'Lower bound' ); 
   
       ud.upperboundtext(idx) =uicontrol('Style','text','Units','normalized', ...
         'Position', pos{6,idx},...
         'ForegroundColor','k','BackgroundColor',figcolor,'String', 'Upper bound'); 
   end      

   enableParams(ud, 3, 'off');

   ud.yaxistext=uicontrol('Style','Text','Units','normalized','Position',yfieldp + [0 0.05 0 -0.01],...
        'ForegroundColor','k','BackgroundColor',figcolor,'String','Probability:'); 
		
   ud.distribution=uicontrol('Style', 'Text', 'String', 'Distribution:', ...
                             'ForegroundColor','k','BackgroundColor',figcolor,...
                             'Units','normalized', 'Visible', 'off');
   dist_extent =  get(ud.distribution, 'extent');
   xpos = .23;
   temp_pos = [xpos .915 dist_extent(3) .06];
   set(ud.distribution, 'Position', temp_pos, 'Visible', 'on');
   xpos = xpos + dist_extent(3) + .01;
        
   ud.popup=uicontrol('Style','Popup','String',...
'Beta|Binomial|Chi-square|Discrete Uniform|Exponential|Extreme Value|F|Gamma|Geometric|Lognormal|Negative Binomial|Noncentral F|Noncentral T|Noncentral Chi-square|Normal|Poisson|Rayleigh|T|Uniform|Weibull',...
        'Units','normalized','Position',[xpos .92 .25 .06],...
        'UserData','popup','Value',15,'BackgroundColor','w',...
        'CallBack','disttool(''changedistribution'')');
        
   ud.type=uicontrol('Style', 'Text', 'String', 'Function type:', ...
                     'ForegroundColor','k','BackgroundColor',figcolor,...
                     'Units','normalized', 'Visible', 'off');
   type_extent = get(ud.type, 'extent');
   xpos = xpos + .25 + .03;
   temp_pos = [xpos, .915, type_extent(3), .06];
   set(ud.type, 'Position', temp_pos, 'Visible', 'on');
        
   xpos = xpos + type_extent(3) + .01;
   ud.functionpopup=uicontrol('Style','Popup','String',...
        'CDF|PDF','Value',1,'Units','normalized',...
        'Position',[xpos .92 .15 .06],'BackgroundColor','w',...
        'CallBack','disttool(''changefunction'')');
        
   ud.Xlabel=uicontrol('Style', 'Text', 'String', 'X:', ...
                             'ForegroundColor','k','BackgroundColor',figcolor,...
                             'Units','normalized', 'Position', xlabelp);     
        
   ud.xfield=uicontrol('Style','edit','Units','normalized','Position',xfieldp,...
         'String',num2str(newx),'BackgroundColor','white',...
         'CallBack','disttool(''editx'')','UserData',newx);
         
   ud.yfield=uicontrol('Style','edit','Units','normalized','Position',yfieldp,...
         'BackgroundColor','white','String',num2str(newy),...
		 'UserData',newy,'CallBack','disttool(''edity'')');

   %   Create Reference Lines
   ud.vline = plot([0 0],yrange,'r-.','EraseMode','xor');
   ud.hline = plot(xrange,[0.5 0.5],'r-.','EraseMode','xor');

   set(ud.vline,'ButtonDownFcn','disttool(''down'',1)');
   set(ud.hline,'ButtonDownFcn','disttool(''down'',2)');

   set(ud.dist_fig,'Backingstore','off','WindowButtonMotionFcn','disttool(''motion'',0)',...
      'WindowButtonDownFcn','disttool(''down'',1)','Userdata',ud,'HandleVisibility','callback');
end

% End of initialization.
set(ud.dist_fig,'UserData',ud);
% END OF disttool MAIN FUNCTION.

% BEGIN HELPER  FUNCTIONS.
%-----------------------------------------------------------------------------
% Update graphic objects in GUI. UPDATEGUI
function ud = updategui(ud,xvalues,yvalues,xrange,yrange,newx,newy)
if ~isempty(xvalues) && ~isempty(yvalues)
   set(ud.dline,'XData',xvalues,'Ydata',yvalues,'Color','b');
   xrange = get(gcba,'Xlim');
   if max(xvalues) > xrange(2)
      set(gcba,'Xlim',[xrange(1) max(xvalues)])
      set(ud.hline,'Xdata',[xrange(1) max(xvalues)])
   end
   if min(xvalues) < xrange(1)
      set(gcba,'Xlim',[min(xvalues) xrange(2)])
      set(ud.hline','Xdata',[min(xvalues) xrange(2)])
   end
end
if isempty(xrange)
   xrange = get(gcba,'Xlim');
end
if isempty(yrange)
   yrange = get(gcba,'Ylim');
end
if ~isempty(newy), 
    set(ud.yfield,'String',num2str(newy),'UserData',newy); 
    set(ud.hline,'XData',xrange,'YData',[newy newy]);
end
if ~isempty(newx), 
    set(ud.xfield,'String',num2str(newx),'UserData',newx); 
    set(ud.vline,'XData',[newx newx],'YData',yrange);
end

%-----------------------------------------------------------------------------
% Calculate new probability or density given a new "X" value. GETNEWY
function newy = getnewy(newx,ud)
iscdf = 2 - get(ud.functionpopup,'Value');
popupvalue = get(ud.popup,'Value');
name = ud.distcells.name{popupvalue};
if strcmpi(name,'weibull')  % use new name to avoid warning
   name = 'wbl';
end

nparams = length(ud.distcells.parameters{popupvalue});
pval = zeros(1, nparams);
for idx = 1:nparams
    pval(idx) = str2double(get(ud.pfhndl(idx),'String'));
end
if iscdf
   switch nparams
        case 1, newy = cdf(name,newx,pval(1));
        case 2, newy = cdf(name,newx,pval(1),pval(2));
        case 3, newy = cdf(name,newx,pval(1),pval(2),pval(3));
   end
else
   switch nparams
        case 1, newy = pdf(name,newx,pval(1));
        case 2, newy = pdf(name,newx,pval(1),pval(2));
        case 3, newy = pdf(name,newx,pval(1),pval(2),pval(3));
    end
end

%-----------------------------------------------------------------------------
% Supply x-axis range and x data values for each distribution. GETXDATA
function [xrange, xvalues] = getxdata(iscdf,popupvalue,ud)
phi = ud.distcells.phi{popupvalue};
plo = ud.distcells.plo{popupvalue};
parameters = ud.distcells.parameters{popupvalue};
switch popupvalue
    case 1, % Beta 
       xrange  = [0 1];
       xvalues = 0.01:0.01:0.99;
    case 2, % Binomial 
       xrange  = [0 phi(1)];
       xvalues = 0:phi(1);
       if iscdf
          xvalues = [xvalues - sqrt(eps);xvalues];
          xvalues = xvalues(:)';
       end
	case 3, % Chi-square
       xrange  = [0 phi + 4 * sqrt(2 * phi)];
       xvalues = linspace(0,xrange(2),101);
    case 4, % Discrete Uniform
       xrange  = [0 phi];
       xvalues = 0:phi;
       if iscdf
          xvalues = [xvalues - sqrt(eps);xvalues];
          xvalues = xvalues(:)';
       end
    case 5, % Exponential
       xrange  = [0 4*phi];
       xvalues = 0:0.1*parameters:4*phi;
       
    case 6, % Extreme Value
       xrange = [plo(1)-5*phi(2), phi(1)+2*phi(2)];
       xvalues = linspace(xrange(1),xrange(2));
  
    case 7, % F 
       xrange  = [0 finv(0.995,plo(1),plo(1))];
       xvalues = linspace(xrange(1),xrange(2));
    case 8, % Gamma
       hixvalue = phi(1) * phi(2) + 4*sqrt(phi(1) * phi(2) * phi(2));
       xrange  = [0 hixvalue];
       xvalues = linspace(0,hixvalue);
    case 9, % Geometric
       hixvalue = geoinv(0.99,plo(1));
       xrange  = [0 hixvalue];       
       xvalues = 0:round(hixvalue);
       if iscdf
          xvalues = [xvalues - sqrt(eps);xvalues];
          xvalues = xvalues(:)';
       end
    case 10, % Lognormal
       xrange = [0 logninv(0.99,phi(1),phi(2))];
       xvalues = linspace(0,xrange(2));
    case 11, % Negative Binomial
       xrange = [0 nbininv(0.99,phi(1),plo(2))];
       xvalues = 0:xrange(2);
       if iscdf,
          xvalues = [xvalues - sqrt(eps);xvalues];
          xvalues = xvalues(:)';
       end
    case 12, % Noncentral F
       xrange = [0 phi(3)+30];
       xvalues = linspace(sqrt(eps),xrange(2));
    case 13, % Noncentral T
       xrange = [phi(2)-14 phi(2)+14];
       xvalues = linspace(xrange(1),xrange(2));
    case 14, % Noncentral Chi-square
       xrange = [0 phi(2)+30];
       xvalues = linspace(sqrt(eps),xrange(2));
    case 15, % Normal
       xrange   = [plo(1) - 3 * phi(2) phi(1) + 3 * phi(2)];
       xvalues  = plo(1) - 3 * phi(2):0.2*parameters(2):phi(1) + 3 * phi(2);
    case 16, % Poisson
      xrange  = [0 4*phi(1)];
      xvalues = 0:round(4*parameters(1));
      if iscdf
         xvalues = [xvalues - sqrt(eps);xvalues];
         xvalues = xvalues(:)';
      end
    case 17, % Rayleigh
       xrange = [0 raylinv(0.995,phi(1))];
       xvalues = linspace(xrange(1),xrange(2),101);
    case 18, % T
       lowxvalue = tinv(0.005,plo(1));
       xrange  = [lowxvalue -lowxvalue];
       xvalues = linspace(xrange(1),xrange(2),101);
    case 19, % Uniform
       xrange  = [plo(1) phi(2)];
       if iscdf
          xvalues = [plo(1) ...
                     parameters(1)-eps*abs(parameters(1)) ...
                     parameters(1)+eps*abs(parameters(1)) ...
                     parameters(2)-eps*abs(parameters(2)) ...
                     parameters(2)+eps*abs(parameters(2)) ...
                     phi(2)];
       else
          xvalues = [parameters(1)+eps*abs(parameters(1)) ...
                     parameters(2)-eps*abs(parameters(2))];
       end
    case 20, % Weibull
       xrange  = [0 wblinv(0.995,plo(1),plo(2))];
       xvalues = linspace(xrange(1),xrange(2));
end

%------------------------------------------------------------------------------
function h = gcba
  h = get(gcbf,'CurrentAxes');

%------------------------------------------------------------------------------
% Enable or disable parameters, upper and lower bounds and sliders
function enableParams(ud, p, state)
   if strcmp(state, 'off')
        color =  [0.831373 0.815686 0.784314];
        set(ud.pfhndl(p),'String', '');
        set(ud.hihndl(p),'String', '');
        set(ud.lohndl(p),'String', '');
        set(ud.ptext(p),'String', '');
   else
        color = 'white';
   end
   set(ud.pfhndl(p),'Enable', state, 'Backgroundcolor', color);
   set(ud.hihndl(p),'Enable', state, 'Backgroundcolor', color);
   set(ud.lohndl(p),'Enable',state, 'Backgroundcolor', color);
   set(ud.pslider(p),'Enable', state);
   set(ud.ptext(p),'Enable',state);
   set(ud.lowerboundtext(p),'Enable',state);
   set(ud.upperboundtext(p),'Enable',state);

%------------------------------------------------------------------------------
% set sliders to use integer or continuous values as appropriate
function setsliderstep(pslider, intparam)
ss = [0.01 0.1];       % MATLAB default
if (intparam) && strcmp(get(pslider, 'Enable'), 'on')
   d = max(1, get(pslider,'Max') - get(pslider,'Min'));

   ss = max(1, round(ss * d));
   if (ss(2) <= ss(1)), ss(2) = ss(1) + 1; end
   ss = ss ./ d;
end
set(pslider, 'SliderStep', ss);

%-----------------------------------------------------------------------------
% Determine validity of value with respect to min
% Binomial p, NC Chi-sq delta, and NC F delta all may be greater than OR 
% equal to the lower bound, all others must be greater than the lower bound
function valid = okwithmin(cv, pmin, dist, fieldnum)
    valid = false;
    if  (dist == 2 && fieldnum == 2) || (dist == 13 && fieldnum == 2) || ...
        (dist == 11 && fieldnum == 3)
         if ( cv >= pmin) 
            valid = true;
         end
    elseif cv > pmin
        valid = true; 
    end

%-----------------------------------------------------------------------------
% Determine validity of value with respect to max
% Binomial p may be less than OR equal to the lower bound, all others must be 
% less than the upper bound
function valid = okwithmax(cv, pmax, dist, fieldnum)
    valid = false; 
    if (dist == 2 && fieldnum == 2)
        if cv <= pmax 
            valid = true;
        end
    elseif cv < pmax
        valid = true;
    end

%-----------------------------------------------------------------------------
% Determine validity of value with respect to min and max
function valid = okwithminmax(cv, pmin, pmax, dist, fieldnum)
    if okwithmin(cv, pmin, dist, fieldnum) && okwithmax(cv, pmax, dist, fieldnum)
        valid = true;
    else
        valid = false;
    end

% END HELPER FUNCTIONS.

% BEGIN CALLBACK FUNCTIONS.

%-----------------------------------------------------------------------------
% Track a mouse moving in the GUI. MOUSEMOTION
function ud = mousemotion(ud,discrete,flag,newx,newy) 
popupvalue = get(ud.popup,'Value');
parameters = ud.distcells.parameters{popupvalue};
name = ud.distcells.name{popupvalue};
xrange = get(gcba,'Xlim');
yrange = get(gcba,'Ylim');

if flag == 0,
    cursorstate = get(gcbf,'Pointer');
    cp = get(gcba,'CurrentPoint');
    cx = cp(1,1);
    cy = cp(1,2);
    fuzzx = 0.01 * (xrange(2) - xrange(1));
    fuzzy = 0.01 * (yrange(2) - yrange(1));
    online = cy > yrange(1) & cy < yrange(2) & cx > xrange(1) & cx < xrange(2) &...
           ((cy > newy - fuzzy & cy < newy + fuzzy) | (cx > newx - fuzzx & cx < newx + fuzzx));
    if online && strcmp(cursorstate,'arrow'),
         set(gcbf,'Pointer','crosshair');
    elseif ~online && strcmp(cursorstate,'crosshair'),
         set(gcbf,'Pointer','arrow');
    end
    
elseif flag == 1 || flag == 3
    cp = get(gcba,'CurrentPoint');
    if ~isinaxes(cp, gcba)
        if flag == 1
            set(gcbf,'Pointer','arrow');
            set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',3)');
        end
        return;
    elseif flag == 3
        set(gcbf,'Pointer','crosshair');
        set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',1)');
    end
        
    newx=cp(1,1);
    if discrete,
         newx = round(newx);
    end
    if newx > xrange(2)
         newx = xrange(2);
    end
    if newx < xrange(1)
         newx = xrange(1);
    end

    newy = getnewy(newx,ud);
	ud = updategui(ud,[],[],xrange,yrange,newx,newy);    

elseif flag == 2 || flag == 4
    
    cp = get(gcba,'CurrentPoint');
    if ~isinaxes(cp, gcba)
        if flag == 2
            set(gcbf,'Pointer','arrow');
            set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',4)');
        end
        return;
    elseif flag == 4
        set(gcbf,'Pointer','crosshair');
        set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',2)');
    end
        
    newy=cp(1,2);
    if newy > yrange(2)
        newy = yrange(2);
    end
    if newy < yrange(1)
        newy = yrange(1);
    end

    nparams = length(parameters);
    pval = zeros(1,nparams);
    for idx = 1:nparams
       pval(idx) = str2double(get(ud.pfhndl(idx),'String'));
    end
    switch nparams
        case 1, newx = icdf(name,newy,pval(1));
        case 2, newx = icdf(name,newy,pval(1),pval(2));
        case 3, newx = icdf(name,newy,pval(1),pval(2),pval(3));
    end
    ud = updategui(ud,[],[],xrange,yrange,newx,newy);
end
%----------------------------------------------------------------------------
% Callback for mousing down in the GUI. MOUSEDOWN
function ud = mousedown(ud,discrete,flag)

cp = get(gcba,'CurrentPoint');

if ~isinaxes(cp, gcba)
    return;
end

xrange = get(gcba,'Xlim');
yrange = get(gcba,'Ylim');
   
set(gcbf,'Pointer','crosshair');
newx=cp(1,1);
if discrete,
   newx = round(newx);
end
if newx > xrange(2)
   newx = xrange(2);
end
if newx < xrange(1)
   newx = xrange(1);
end
newy = getnewy(newx,ud);
    
ud = updategui(ud,[],[],xrange,yrange,newx,newy);
      
if flag == 1
   set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',1)');
elseif flag == 2
   set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',2)');
end
set(gcbf,'WindowButtonUpFcn','disttool(''up'')');
% End mousemotion function.

%-----------------------------------------------------------------------------
% Callback for mousing up in the GUI. MOUSEUP
function mouseup
set(gcbf,'WindowButtonMotionFcn','disttool(''motion'',0)');
set(gcbf,'WindowButtonUpFcn','');

% Callback for editing x-axis text field. EDITX
function ud = editx(ud)
    newx=str2double(get(ud.xfield,'String'));
    if isempty(newx) 
       newx = get(ud.xfield,'Userdata');
       set(ud.xfield,'String',num2str(newx));
       warndlg('Critical values must be numeric. Resetting to previous value.');
       return;
    end
    xrange = get(gcba,'Xlim');
    if newx > xrange(2)
        newx = xrange(2);
        set(ud.xfield,'String',num2str(newx));
    end
    if newx < xrange(1)
        newx = xrange(1);
        set(ud.xfield,'String',num2str(newx));
    end
    newy = getnewy(newx,ud);    
    ud = updategui(ud,[],[],[],[],newx,newy);

%-----------------------------------------------------------------------------
% Callback for editing y-axis text field. EDITY
function ud = edity(ud)
popupvalue = get(ud.popup,'Value');
parameters = ud.distcells.parameters{popupvalue};
name = ud.distcells.name{popupvalue};
newy=str2double(get(ud.yfield,'String'));
if isempty(newy) 
   newy = get(ud.yfield,'Userdata');
   set(ud.yfield,'String',num2str(newy));
   warndlg('Probabilities must be numeric. Resetting to previous value.');
   return;
end

if newy > 1
    newy = 1;
    set(ud.yfield,'String',num2str(newy),'UserData',newy);
end
if newy < 0
    newy = 0;
    set(ud.yfield,'String',num2str(newy),'UserData',newy);
end
nparams = length(parameters);
pval = zeros(1,nparams);
for idx = 1:nparams
    pval(idx) = str2double(get(ud.pfhndl(idx),'String'));
end
switch nparams
    case 1, newx = icdf(name,newy,pval(1));
    case 2, newx = icdf(name,newy,pval(1),pval(2));
    case 3, newx = icdf(name,newy,pval(1),pval(2),pval(3));
end
ud = updategui(ud,[],[],[],[],newx,newy);

%-----------------------------------------------------------------------------
% Callback for changing probability distribution function. CHANGEDISTRIBUTION
function ud = changedistribution(iscdf,popupvalue,ud,discrete, intparams)
text1 = {'A','Trials','df','Number','Mu','Mu','df1','A','Prob','Mu','R','df1','df',...
            'df','Mu','Lambda','B','df','Min','A'}; 
text2 = {'B','Prob',[],[],[],'Sigma','df2','B',[],'Sigma','Prob','df2','delta','delta',...
            'Sigma',[],[],[],'Max','B'};
set(ud.ptext(1),'String',text1{popupvalue});

name       = ud.distcells.name{popupvalue};
parameters = ud.distcells.parameters{popupvalue};
pmax       = ud.distcells.pmax{popupvalue};
pmin       = ud.distcells.pmin{popupvalue};
phi        = ud.distcells.phi{popupvalue};
plo        = ud.distcells.plo{popupvalue};

[xrange, xvalues] = getxdata(iscdf,popupvalue,ud);
set(gcba,'Xlim',xrange);
newx = mean(xrange);

nparams = length(parameters);
if nparams > 1
    set(ud.ptext(2),'String',text2{popupvalue});
    if popupvalue == 11
           set(ud.ptext(3),'String','delta');
    end
end

switch nparams
   case 1,
        enableParams(ud, 2:3, 'off');
   case 2,
        enableParams(ud, 1:2, 'on');
        enableParams(ud, 3, 'off');
   case 3
        enableParams(ud, 1:3, 'on');
end
    
set(ud.dline,'Marker','none','LineStyle','-');   
    
if iscdf,
    set(ud.hline,'Visible','on');
else
    set(ud.hline,'Visible','off');
    if discrete,
        set(ud.dline,'Marker','+','LineStyle','none');
    end
end
for idx = 1:nparams
    set(ud.pfhndl(idx),'String',num2str(parameters(idx)));
    set(ud.lohndl(idx),'String',num2str(plo(idx)));
    set(ud.hihndl(idx),'String',num2str(phi(idx)));
    set(ud.pslider(idx),'Min',plo(idx),'Max',phi(idx),'Value',parameters(idx));
    setsliderstep(ud.pslider(idx),intparams(idx));
end

if iscdf,
   newy = getnewy(newx,ud);
   yvalues = getnewy(xvalues,ud);
   yrange = [0 1.1];
   ud = updategui(ud,xvalues,yvalues,[],yrange,newx,newy);
else
   ud = changefunction(iscdf,popupvalue,ud,discrete,newx, intparams);
end
% End of changedistribution function.

%-----------------------------------------------------------------------------
% Toggle CDF/PDF or PDF/CDF. CHANGEFUNCTION 
function ud = changefunction(iscdf,popupvalue,ud,discrete,newx,intparams)
name       = ud.distcells.name{popupvalue};
parameters = ud.distcells.parameters{popupvalue};
pmax       = ud.distcells.pmax{popupvalue};
pmin       = ud.distcells.pmin{popupvalue};
phi        = ud.distcells.phi{popupvalue};
plo        = ud.distcells.plo{popupvalue};

if ~iscdf
  xrange = get(gcba,'Xlim'); 
  switch popupvalue
    case 1,   % Beta   
       tempx = [0.01 0.1:0.1:0.9 0.99];
       temp1 = linspace(plo(1),phi(1),21);
       temp2 = linspace(plo(2),phi(2),21);
       [x p1 p2] = meshgrid(tempx,temp1,temp2);
       maxy = pdf(name,x,p1,p2);
    case 2,  % Binomial
       maxy = 1;
    case 3,  % Chisquare
       tempx = linspace(xrange(1),xrange(2),101);
       maxy = pdf(name,tempx,plo);
    case 4,  % Discrete Uniform  
       maxy = 1 ./ plo;
    case 5,  % Exponential 
       maxy = 1 / plo;
    case 6,  % Extreme Value
       maxy = 1 / (exp(1) * plo(2));
    case 7,  % F
       tempx = linspace(xrange(1),xrange(2),101);
       temp1 = plo(1):phi(1);
       temp2 = plo(2):plo(2);
       [x p1 p2] = meshgrid(tempx,temp1,temp2);                
       maxy = 1.05*pdf(name,x,p1,p2);
    case 8,  % Gamma
       tempx = [0.1 linspace(xrange(1),xrange(2),101)];
       temp1 = linspace(plo(1),phi(1),11);
       temp2 = linspace(plo(2),phi(2),11);
       [x p1 p2] = meshgrid(tempx,temp1,temp2);
       maxy = pdf(name,x,p1,p2);
    case 9,  % Geometric  
       maxy = phi(1);
    case 10,  % Lognormal
       x = exp(linspace(plo(1),plo(1)+0.5*plo(2).^2));
       maxy = pdf(name,x,plo(1),plo(2));
    case 11, % Negative Binomial   
       maxy = 0.91;      
    case 12, % Noncentral F
       maxy = 0.4;
    case 13, % Noncentral T
       maxy = 0.4;
    case 14, % Noncentral Chisquare
       maxy = 0.4;
    case 15, % Normal 
       maxy = pdf(name,0,0,plo(2));
    case 16, % Poisson  
       maxy = pdf(name,[0 plo(1)],plo(1));
    case 17, % Rayleigh
       maxy = 0.6;  
    case 18, % T
       maxy = 0.4;  
    case 19, % Uniform  
       maxy = 1 ./ (plo(2) - phi(1));
    case 20, % Weibull
       tempx = [0.05 linspace(xrange(1),xrange(2),21)];
       temp1 = linspace(plo(1),phi(1),21);
       temp2 = linspace(plo(2),phi(2),21);
       [x p1 p2] = meshgrid(tempx,temp1,temp2);
       maxy = pdf('wbl',x,p1,p2);
  end
  ymax = abs(1.1 .* nanmax(maxy(:)));
  if ~isempty(ymax) && ~isnan(ymax) && ~isinf(ymax)
      yrange = [0 abs(1.1 .* max(ymax(:)))];
  else
      yrange = [0 1.1];
  end
  set(gcba,'Ylim',yrange);
end
[xrange, xvalues] = getxdata(iscdf, popupvalue, ud);
nparams = length(parameters);
for idx = 1:nparams
    set(ud.pfhndl(idx),'String',num2str(parameters(idx)));
end  
yvalues = getnewy(xvalues,ud);
newy = getnewy(newx,ud);
if iscdf;
    ud = changedistribution(iscdf,popupvalue,ud,discrete, intparams);
    set(ud.yaxistext,'String','Probability');
    set(ud.yfield,'Style','edit','BackgroundColor','white');
    set(ud.hline,'Visible','on');
    yrange = [0 1.1];
    set(gcba,'YLim',yrange);
    set(ud.dline,'LineStyle','-','Marker','none');
else
    set(ud.yaxistext,'String','Density');
    set(ud.yfield,'Style','text','BackgroundColor',[0.8 0.8 0.8]);
    set(ud.hline,'Visible','off');
    if discrete,
        set(ud.dline,'Marker','+','LineStyle','none');
    else
        set(ud.dline,'Marker','none','LineStyle','-');
    end
   yvalues = getnewy(xvalues,ud);
   ud = updategui(ud,xvalues,yvalues,xrange,yrange,newx,newy);
end
% End changefunction.

%-----------------------------------------------------------------------------
% Callback for controlling lower bound of the parameters using editable text boxes.
function ud = setplo(fieldno,intparam,ud,newx)
iscdf = 2 - get(ud.functionpopup,'Value');
popupvalue = get(ud.popup,'Value');
cv   = str2double(get(ud.lohndl(fieldno),'String'));
pv   = str2double(get(ud.pfhndl(fieldno),'String'));
pmin = ud.distcells.pmin{popupvalue}(fieldno);
pmax = ud.distcells.pmax{popupvalue}(fieldno);
cmax = str2double(get(ud.hihndl(fieldno),'String'));

if intparam    
    cv = round(cv);
    set(ud.lohndl(fieldno),'String',num2str(cv));
end
if okwithminmax(cv, pmin, pmax, popupvalue, fieldno)
	if cv >= cmax
	   cv = get(ud.pslider(fieldno),'Min');
       set(ud.lohndl(fieldno),'String',num2str(cv));
    elseif cv > pv
        set(ud.pfhndl(fieldno),'String',num2str(cv));
        set(ud.lohndl(fieldno),'String',num2str(cv));
        ud = setpfield(fieldno,intparam,ud,newx);
    end

    set(ud.pslider(fieldno),'Min',cv);
    ud.distcells.plo{popupvalue}(fieldno) = cv;
    [xrange, xvalues] = getxdata(iscdf,popupvalue,ud);
    yvalues = getnewy(xvalues,ud);
    newy = getnewy(newx,ud);
    [xrange, xvalues] = getxdata(iscdf,popupvalue,ud);
    yvalues = getnewy(xvalues,ud);
    ud = updategui(ud,xvalues,yvalues,xrange,[],newx,newy); 
elseif cv >= pmax
   set(ud.lohndl(fieldno),'String',get(ud.pslider(fieldno),'Min'));
else
   set(ud.lohndl(fieldno),'String',num2str(ud.distcells.plo{popupvalue}(fieldno)));
end
[xrange, xvalues] = getxdata(iscdf,popupvalue,ud);
yvalues = getnewy(xvalues,ud);
setsliderstep(ud.pslider(fieldno),intparam);
ud = updategui(ud,xvalues,yvalues,xrange,[],[],[]);

%-----------------------------------------------------------------------------
% Callback for controlling upper bound of the parameters using editable text boxes.
function ud = setphi(fieldno,intparam,ud,newx)
iscdf = 2 - get(ud.functionpopup,'Value');
popupvalue = get(ud.popup,'Value');
cv   = str2double(get(ud.hihndl(fieldno),'String'));
pv = str2double(get(ud.pfhndl(fieldno),'String'));
pmin = ud.distcells.pmin{popupvalue}(fieldno);
pmax = ud.distcells.pmax{popupvalue}(fieldno);
cmin = str2double(get(ud.lohndl(fieldno),'String'));
if intparam
    cv = round(cv);
    set(ud.hihndl(fieldno),'String',num2str(cv));
end
if okwithminmax(cv, pmin, pmax, popupvalue, fieldno)
	if cv <= cmin
	   cv = get(ud.pslider(fieldno),'Max');
       set(ud.hihndl(fieldno),'String',num2str(cv));
    elseif cv < pv
       set(ud.hihndl(fieldno),'String',num2str(cv));
       set(ud.pfhndl(fieldno),'String',num2str(cv));
       ud = setpfield(fieldno,intparam,ud,newx);
	end

    set(ud.pslider(fieldno),'Max',cv);
    ud.distcells.phi{popupvalue}(fieldno) = cv;
    [xrange, xvalues] = getxdata(iscdf,popupvalue,ud);
    yvalues = getnewy(xvalues,ud);
    newy = getnewy(newx,ud);
    ud = updategui(ud,xvalues,yvalues,xrange,[],newx,newy); 
elseif cv <= pmax
   set(ud.hihndl(fieldno),'String',get(ud.pslider(fieldno),'Max'));
else
    set(ud.hihndl(fieldno),'String',num2str(ud.distcells.phi{popupvalue}(fieldno)));
end
[xrange, xvalues] = getxdata(iscdf,popupvalue,ud);
yvalues = getnewy(xvalues,ud);
setsliderstep(ud.pslider(fieldno),intparam);
ud = updategui(ud,xvalues,yvalues,xrange,[],[],[]);

%-----------------------------------------------------------------------------
% Callback for controlling the parameter values using sliders.
function ud = setpslider(sliderno,intparam,ud,newx)
iscdf = 2 - get(ud.functionpopup,'Value');
popupvalue = get(ud.popup,'Value');

cv = get(ud.pslider(sliderno),'Value');
if intparam
    cv = round(cv);
end

% Set string value, then re-read in case of rounding
set(ud.pfhndl(sliderno),'String',num2str(cv));
cv = str2double(get(ud.pfhndl(sliderno),'String'));

ud.distcells.parameters{popupvalue}(sliderno) = cv;
[xrange, xvalues] = getxdata(iscdf,popupvalue,ud);
yvalues = getnewy(xvalues,ud);
newy = getnewy(newx,ud);
ud = updategui(ud,xvalues,yvalues,[],[],newx,newy); 

%-----------------------------------------------------------------------------
% Callback for controlling the parameter values using editable text boxes.
function ud = setpfield(fieldno,intparam,ud,newx)
iscdf = 2 - get(ud.functionpopup,'Value');
popupvalue = get(ud.popup,'Value');
cv = str2double(get(ud.pfhndl(fieldno),'String'));
pmin = ud.distcells.pmin{popupvalue}(fieldno);
pmax = ud.distcells.pmax{popupvalue}(fieldno);
phivalue = str2double(get(ud.hihndl(fieldno),'String'));
plovalue = str2double(get(ud.lohndl(fieldno),'String'));
if intparam
    cv = round(cv);
    set(ud.pfhndl(fieldno),'String',num2str(cv));
end
if okwithminmax(cv, pmin, pmax, popupvalue, fieldno)
    set(ud.pslider(fieldno),'Value',cv);
    if (cv > phivalue), 
        set(ud.hihndl(fieldno),'String',num2str(cv));
        set(ud.pslider(fieldno),'Max',cv);
        ud = setphi(fieldno,intparam,ud,newx);
    end
    if (cv < plovalue), 
        set(ud.lohndl(fieldno),'String',num2str(cv));
        set(ud.pslider(fieldno),'Min',cv);
        ud = setplo(fieldno,intparam,ud,newx);
    end
    ud.distcells.parameters{popupvalue}(fieldno) = cv;
    [xrange, xvalues] = getxdata(iscdf,popupvalue,ud);
	yvalues = getnewy(xvalues,ud);
    newy = getnewy(newx,ud);
    setsliderstep(ud.pslider(fieldno),intparam);
    ud = updategui(ud,xvalues,yvalues,xrange,[],newx,newy); 
else
    set(ud.pfhndl(fieldno),'String',num2str(ud.distcells.parameters{popupvalue}(fieldno)));
end

