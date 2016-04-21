function randtool(action,flag)
%RANDTOOL Demonstration of many random number generators.
%   RANDTOOL creates a histogram of random samples from many
%   distributions. This is a demo that displays a histograms of random
%   samples from the distributions in the Statistics Toolbox. 
%
%   Change the parameters of the distribution by typing in a new
%   value or by moving a slider.
%
%   Export the current sample to a variable in the workspace by pressing
%   the export button.
%
%   Change the sample size by typing any positive integer in the
%   sample size edit box.
%
%   Change the distribution type using the popup menu.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.32.6.4 $  $Date: 2004/04/01 16:23:59 $

if nargin < 1
    action = 'start';
end

%On recursive calls get all necessary handles and data.
if ~strcmp(action,'start')   
   childList = allchild(0);
   rand_fig = childList(childList == gcf);
   ud = get(rand_fig,'Userdata');

   switch action
      case {'setpfield', 'setpslider', 'setphi', 'setplo'}
         ud = feval(action,flag,ud);
      case 'changedistribution', 
         ud = changedistribution(ud);
      case 'setsample',
         ud=updategui(ud,[]); 
      case 'output',
         outrndnum(ud); 
   end
   set(rand_fig,'UserData',ud);
end
% Initialize all GUI objects. Plot Normal CDF with sliders for parameters.
if strcmp(action,'start'),
   % Set positions of graphic objects
   axisp   = [.11 .35 .86 .58];

   pos = cell(7,3);
   pos{5,1} = [.10 .144 .08 .04];   % text
   pos{1,1} = [.19 .145 .12 .04];   % parameter
   pos{3,1} = [.19 .085 .12 .04];   % lower bound
   pos{4,1} = [.32 .085 .03 .16];   % slider
   pos{2,1} = [.19 .205 .12 .04];   % upper bound
   pos{7,1} = [.11 .085 .07 .05];   % lower bound label
   pos{6,1} = [.11 .205 .07 .05];   % upper bound label
   
   pos{5,2} = [.41 .144 .08 .04];   % text
   pos{1,2} = [.50 .145 .12 .04];   % parameter
   pos{3,2} = [.50 .085 .12 .04];   % lower bound
   pos{4,2} = [.63 .085 .03 .16];   % slider
   pos{2,2} = [.50 .205 .12 .04];   % upper bound
   pos{7,2} = [.42 .085 .07 .05];   % lower bound label
   pos{6,2} = [.42 .205 .07 .05];   % upper bound label
   
   pos{5,3} = [.72 .144 .08 .04];   % text
   pos{1,3} = [.81 .145 .12 .04];   % parameter
   pos{3,3} = [.81 .085 .12 .04];   % lower bound
   pos{4,3} = [.94 .085 .03 .16];   % slider
   pos{2,3} = [.81 .205 .12 .04];   % upper bound
   pos{7,3} = [.73 .085 .07 .05];   % lower bound label
   pos{6,3} = [.73 .205 .07 .05];   % upper bound label

   % Distribution Data
   ud.distcells.name = {'Beta','Binomial','Chi-square',...
                        'Discrete Uniform','Exponential', 'Extreme Value', ...
                        'F', 'Gamma', 'Geometric', ...
                        'Lognormal', 'Negative Binomial','Noncentral F', ...
                        'Noncentral T', 'Noncentral Chi-square', 'Normal', ...
                        'Poisson', 'Rayleigh', 'T', ...
                        'Uniform', 'Weibull'};

   ud.distcells.rvname = {'betarv','binorv','chi2rv',...
                          'unidrv', 'exprv', 'evrv',...
                          'frv', 'gamrv', 'georv', ...
                          'lognrv', 'nbinrv', 'ncfrv', ...
                          'nctrv', 'ncx2rv', 'normrv', ...
                          'poissrv', 'raylrv', 'trv', ...
                          'unifrv', 'weibrv'};

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
                       [10 10], [5 5], 0.99, ...
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

   ud.distcells.discrete = [0 1 0 1 0 0 0 0 1 0 1 0 0 0 0 1 0 0 0 0];

   ud.distcells.intparam = {[0 0 0], [1 0 0], [0 0 0], ...
                            [1 0 0], [0 0 0], [0 0 0], ...
                            [0 0 0], [0 0 0], [0 0 0], ...
                            [0 0 0], [0 0 0], [0 0 0], ...
                            [0 0 0], [0 0 0], [0 0 0], ...
                            [0 0 0], [0 0 0], [0 0 0], ...
                            [0 0 0], [0 0 0]};

   % Set axis limits and data
   rand_fig = figure('Tag', 'randfig', 'pos', [304 380 625 605], ...
                     'visible', 'off');
   figcolor  = get(rand_fig,'Color');
   set(rand_fig,'Units','Normalized','Backingstore','off');
   rand_axes = axes;
   xrange = [-8 8];
   set(rand_axes,'DrawMode','fast',...
      'Position',axisp,'XLim',xrange,'Box','on');
   paramtext  = str2mat('Mu','Sigma','  ');
   set(rand_fig,'UserData',ud);

   % Define graphics objects
   for idx = 1:3
       intparam = ud.distcells.intparam{15}(idx);
       nstr = int2str(idx);
       ud.pfhndl(idx) =uicontrol('Style','edit','Units','normalized','Position',pos{1,idx},...
          'String',num2str(ud.distcells.parameters{15}(2-rem(idx,2))),'BackgroundColor','white',...
          'CallBack',['randtool(''setpfield'',',nstr,')']);
         
       ud.hihndl(idx)   =uicontrol('Style','edit','Units','normalized','Position',pos{2,idx},...
         'String',num2str(ud.distcells.phi{15}(2-rem(idx,2))),'BackgroundColor','white',...
         'CallBack',['randtool(''setphi'',',nstr,')']);
         
       ud.lohndl(idx)   =uicontrol('Style','edit','Units','normalized','Position',pos{3,idx},...
         'String',num2str(ud.distcells.plo{15}(2-rem(idx,2))),'BackgroundColor','white',... 
         'CallBack',['randtool(''setplo'',',nstr,')']);

       ud.pslider(idx)=uicontrol('Style','slider','Units','normalized','Position',pos{4,idx},...
         'Value',ud.distcells.parameters{15}(2-rem(idx,2)),'Max',ud.distcells.phi{15}(2-rem(idx,2)),...
         'Min',ud.distcells.plo{15}(2-rem(idx,2)),'Callback',['randtool(''setpslider'',',nstr,')']);

       ud.ptext(idx) =uicontrol('Style','text','Units','normalized','Position',pos{5,idx},...
         'BackgroundColor',figcolor,'ForegroundColor','k','String',paramtext(idx,:));
       
       ud.lowerboundtext(idx) =uicontrol('Style','text','Units','normalized', ...
         'Position', pos{7,idx},...
         'ForegroundColor','k','BackgroundColor',figcolor,'String', 'Lower bound' ); 
   
       ud.upperboundtext(idx) =uicontrol('Style','text','Units','normalized', ...
         'Position', pos{6,idx},...
         'ForegroundColor','k','BackgroundColor',figcolor,'String', 'Upper bound'); 

       setincrement(ud.pslider(idx), intparam);
   end      
   
   enableParams(ud, 3, 'off');

   ud.popup=uicontrol('Style','Popup','String',...
'Beta|Binomial|Chi-square|Discrete Uniform|Exponential|Extreme Value|F|Gamma|Geometric|Lognormal|Negative Binomial|Noncentral F|Noncentral T|Noncentral Chi-square|Normal|Poisson|Rayleigh|T|Uniform|Weibull',...
        'Units','normalized','Position',[.28 .945 .25 .04],'UserData','popup','Value',15,...
        'BackgroundColor','white',...
        'CallBack','randtool(''changedistribution'')');

   ud.samples_field = uicontrol('Style','edit','Units','normalized',...
         'Position',[.71 .945 .15 .04], 'String','100',...
         'BackgroundColor','white',...
         'CallBack','randtool(''setsample'',1)');

   uicontrol('Style','Pushbutton',...
         'Units','normalized','Position',[.70 .02 .13 .04],...
         'Callback','randtool(''setsample'',1)','String','Resample');

   uicontrol('Style','Pushbutton','Units','normalized',...
         'Position',[.84 .02 .13 .04],...
         'Callback','randtool(''output'',2);','String','Export ...');

ud = updategui(ud,[]);

placetitlebar(rand_fig);
set(rand_fig,'UserData',ud,'HandleVisibility','callback',...
    'InvertHardCopy', 'on', 'PaperPositionMode', 'auto', 'visible', 'on')
end

% End of initialization.
% END OF randtool MAIN FUNCTION.

% Begin of helper function 
% Supply x-axis range for each distribution. GETXDATA
function xrange = getxdata(popupvalue,ud)
phi = ud.distcells.phi{popupvalue};
plo = ud.distcells.plo{popupvalue};
parameters = ud.distcells.parameters{popupvalue};
switch popupvalue
    case 1, % Beta 
       xrange  = [0 1];
    case 2, % Binomial 
       xrange  = [0 phi(1)];
	case 3, % Chi-square
       xrange  = [0 phi + 4 * sqrt(2 * phi)];
    case 4, % Discrete Uniform
       xrange  = [0 phi];
    case 5, % Exponential
       xrange  = [0 4*phi];
    case 6, % Extreme Value
       xrange = [plo(1)-5*phi(2), phi(1)+2*phi(2)];
    case 7, % F 
       xrange  = [0 finv(0.995,plo(1),plo(1))];
    case 8, % Gamma
       hixvalue = phi(1) * phi(2) + 4*sqrt(phi(1) * phi(2) * phi(2));
       xrange  = [0 hixvalue];
    case 9, % Geometric
       hixvalue = geoinv(0.99,plo(1));
       xrange  = [0 hixvalue];       
    case 10, % Lognormal
       xrange = [0 logninv(0.99,phi(1),phi(2))];
    case 11, % Negative Binomial
       xrange = [0 nbininv(0.99,phi(1),plo(2))];
    case 12, % Noncentral F
       xrange = [0 phi(3)+30];
    case 13, % Noncentral T
       xrange = [phi(2)-14 phi(2)+14];
    case 14, % Noncentral Chi-square
       xrange = [0 phi(2)+30];
    case 15, % Normal
       xrange   = [plo(1) - 3 * phi(2) phi(1) + 3 * phi(2)];
    case 16, % Poisson
      xrange  = [0 4*phi(1)];
    case 17, % Rayleigh
       xrange = [0 raylinv(0.995,phi(1))];
    case 18, % T
       lowxvalue = tinv(0.005,plo(1));
       xrange  = [lowxvalue -lowxvalue];
    case 19, % Uniform
       xrange  = [plo(1) phi(2)];
    case 20, % Weibull
       xrange  = [0 wblinv(0.995,plo(1),plo(2))];
end

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


%-----------------------------------------------------------------------------
% For uniform, pvalue "max" must be greater than pvalue "min"
function ok = uniformcheckok(popupvalue, cv, fieldno, ud)
    ok = true;
    if popupvalue == 19    %uniform distribution
        if fieldno == 1
            pv = str2double(get(ud.pfhndl(2),'String'));
            if cv >= pv
                ok = false;
            end
        else % fieldno == 2
            pv = str2double(get(ud.pfhndl(1),'String'));
            if cv <= pv
                ok = false;
            end
        end
    end
% END of helper function

% BEGIN CALLBACK FUNCTIONS.
% Callback for changing probability distribution function. CHANGEDISTRIBUTION
function ud = changedistribution(ud)
text1 = {'A','Trials','df','Number','Mu','Mu','df1','A','Prob','Mu','R','df1','df',...
            'df','Mu','Lambda','B','df','Min','A'}; 
text2 = {'B','Prob',[],[],[],'Sigma','df2','B',[],'Sigma','Prob','df2','delta','delta',...
            'Sigma',[],[],[],'Max','B'};
% text3 is effectively the assignment set(ud.ptext(3),...) below

popupvalue = get(ud.popup,'Value');
set(ud.ptext(1),'String',text1{popupvalue});
name       = ud.distcells.name{popupvalue};
parameters = ud.distcells.parameters{popupvalue};
pmax       = ud.distcells.pmax{popupvalue};
pmin       = ud.distcells.pmin{popupvalue};
phi        = ud.distcells.phi{popupvalue};
plo        = ud.distcells.plo{popupvalue};

nparams = length(parameters);
if nparams > 1
    set(ud.ptext(2),'String',text2{popupvalue});
    if popupvalue == 12
           set(ud.ptext(3),'String','delta');
    end
end

offs = (nparams+1):3;
ons = 1:nparams;
if ~isempty(offs)
   enableParams(ud, offs, 'off');
end
if ~isempty(ons)
   enableParams(ud, ons, 'on');
end

intparam = ud.distcells.intparam{popupvalue};
for idx = 1:nparams
    set(ud.pfhndl(idx),'String',num2str(parameters(idx)));
    set(ud.lohndl(idx),'String',num2str(plo(idx)));
    set(ud.hihndl(idx),'String',num2str(phi(idx)));
    set(ud.pslider(idx),'Min',plo(idx),'Max',phi(idx),'Value',parameters(idx));
    setincrement(ud.pslider(idx), intparam(idx));
end

xrange = getxdata(popupvalue,ud);
set(gca,'Xlim',xrange);

ud=updategui(ud,xrange);

% End of changedistribution function.

% Callback for controlling lower bound of the parameters using editable
% text boxes.
function ud = setplo(fieldno,ud)
popupvalue = get(ud.popup,'Value');
intparam = ud.distcells.intparam{popupvalue}(fieldno);
cv   = str2double(get(ud.lohndl(fieldno),'String'));
pv = str2double(get(ud.pfhndl(fieldno),'String'));
cmax = str2double(get(ud.hihndl(fieldno),'String'));

if intparam
    cv = round(cv);
    set(ud.lohndl(fieldno),'String',num2str(cv));
end
if cv >= cmax
  set(ud.lohndl(fieldno),'String',get(ud.pslider(fieldno),'Min'));
elseif cv > pv
  if uniformcheckok(popupvalue, cv, fieldno, ud)
      set(ud.lohndl(fieldno),'String',num2str(cv));
      set(ud.pslider(fieldno),'Min',cv);
      set(ud.pfhndl(fieldno),'String',num2str(cv));
      ud = setpfield(fieldno,ud);
  else
      set(ud.lohndl(fieldno),'String',num2str(ud.distcells.plo{popupvalue}(fieldno)));
  end
else
  pmin = ud.distcells.pmin{popupvalue}(fieldno);
  pmax = ud.distcells.pmax{popupvalue}(fieldno);
  if okwithminmax(cv, pmin, pmax, popupvalue, fieldno)
    set(ud.pslider(fieldno),'Min',cv);
    ud.distcells.plo{popupvalue}(fieldno) = cv;
  else
    set(ud.lohndl(fieldno),'String',num2str(ud.distcells.plo{popupvalue}(fieldno)));
  end
end
setincrement(ud.pslider(fieldno), intparam);
xrange = getxdata(popupvalue,ud);
ud = updategui(ud,xrange);

% Callback for controlling upper bound of the parameters using editable text boxes.
function ud = setphi(fieldno,ud)
popupvalue = get(ud.popup,'Value');
intparam = ud.distcells.intparam{popupvalue}(fieldno);
cv   = str2double(get(ud.hihndl(fieldno),'String'));
pv = str2double(get(ud.pfhndl(fieldno),'String'));
cmin = str2double(get(ud.lohndl(fieldno),'String'));

if intparam
    cv = round(cv);
    set(ud.hihndl(fieldno),'String',num2str(cv));
end

if cv <= cmin
  set(ud.hihndl(fieldno),'String',get(ud.pslider(fieldno),'Max'));
elseif cv < pv
  if uniformcheckok(popupvalue, cv, fieldno, ud)
      set(ud.hihndl(fieldno),'String',num2str(cv));
      set(ud.pslider(fieldno),'Max',cv);
      set(ud.pfhndl(fieldno),'String',num2str(cv));
      ud = setpfield(fieldno,ud);
  else
      set(ud.hihndl(fieldno),'String',num2str(ud.distcells.phi{popupvalue}(fieldno)));
  end
else
  pmin = ud.distcells.pmin{popupvalue}(fieldno);
  pmax = ud.distcells.pmax{popupvalue}(fieldno);
  if okwithminmax(cv, pmin, pmax, popupvalue, fieldno)
    set(ud.pslider(fieldno),'Max',cv);
    ud.distcells.phi{popupvalue}(fieldno) = cv;
  else
    set(ud.hihndl(fieldno),'String',num2str(ud.distcells.phi{popupvalue}(fieldno)));
  end
end
setincrement(ud.pslider(fieldno), intparam);
xrange = getxdata(popupvalue,ud);
ud=updategui(ud,xrange);

% Callback for controlling the parameter values using sliders.
function ud = setpslider(sliderno,ud)
popupvalue = get(ud.popup,'Value');
intparam = ud.distcells.intparam{popupvalue}(sliderno);

cv = get(ud.pslider(sliderno),'Value');
if intparam
    cv = round(cv);
end
set(ud.pfhndl(sliderno),'String',num2str(cv));
ud.distcells.parameters{popupvalue}(sliderno) = cv;
ud=updategui(ud,[]);

% Callback for controlling the parameter values using editable text boxes.
function ud = setpfield(fieldno,ud)
popupvalue = get(ud.popup,'Value');
intparam = ud.distcells.intparam{popupvalue}(fieldno);
cv = str2double(get(ud.pfhndl(fieldno),'String'));
pmin = ud.distcells.pmin{popupvalue}(fieldno);
pmax = ud.distcells.pmax{popupvalue}(fieldno);
phivalue = str2double(get(ud.hihndl(fieldno),'String'));
plovalue = str2double(get(ud.lohndl(fieldno),'String'));

if intparam
    cv = round(cv);
    set(ud.pfhndl(fieldno),'String',num2str(cv));
end
if uniformcheckok(popupvalue, cv, fieldno, ud) && ... 
   okwithminmax(cv, pmin, pmax, popupvalue, fieldno)
    set(ud.pslider(fieldno),'Value',cv);
    ud.distcells.parameters{popupvalue}(fieldno) = cv;
    if (cv >= phivalue), 
        set(ud.hihndl(fieldno),'String',num2str(cv));
        ud = setphi(fieldno,ud); 
        set(ud.pslider(fieldno),'Max',cv);
        setincrement(ud.pslider(fieldno), intparam);
        return; % this return is to avoid using updategui twice.
    end
    if (cv <= plovalue), 
        set(ud.lohndl(fieldno),'String',num2str(cv));
        ud = setplo(fieldno,ud); 
        set(ud.pslider(fieldno),'Min',cv);
        setincrement(ud.pslider(fieldno), intparam);
        return; 
    end
else
    set(ud.pfhndl(fieldno),'String',num2str(ud.distcells.parameters{popupvalue}(fieldno)));
end
xrange = getxdata(popupvalue,ud);
updategui(ud, xrange);

% Update graphic objects in GUI. UPDATEGUI
function ud=updategui(ud,xrange)

if isempty(xrange)
   xrange = get(gca,'Xlim');
end

popupvalue = get(ud.popup,'Value');

name = ud.distcells.name{popupvalue};
if strcmpi(name,'weibull')  % use new name to avoid warning
   name = 'wbl';
end
nparams = length(ud.distcells.parameters{popupvalue});
samples = floor(str2double(get(ud.samples_field,'String')));
if isnan(samples) || samples <= 0
   samples = 100;
   set(ud.samples_field,'String','100');
   warning('stats:randtool:BadSampleSize',...
           'Sample size must be a positive integer. It has been reset to its default value of 100.');
end

pval = zeros(1,nparams);
for idx = 1:nparams
    pval(idx) = str2double(get(ud.pfhndl(idx),'String'));
end

set(gcf,'Pointer','watch');
ok = 1;
try
   switch nparams
    case 1, random_numbers = random(name,pval(1),samples,1);
    case 2, random_numbers = random(name,pval(1),pval(2),samples,1);
    case 3, random_numbers = random(name,pval(1),pval(2),pval(3),samples,1);
   end
   ud.random_numbers = random_numbers;

   % Create Histogram
   minrn = min(random_numbers);
   maxrn = max(random_numbers);
   crn = random_numbers - minrn + realmin;
   bins = floor(sqrt(samples));
   range = maxrn - minrn;
   if ud.distcells.discrete(popupvalue)
      range = maxrn - minrn + 1; 
      crn = crn + 1;
      bins = range;
   end

   intrn = ceil(bins*crn/range);

   %the above ceil function may push intrn to be one unit higher than bins
   %due to floating point problem, we will set it back to bins.
   if max(intrn) > bins
      intrn(intrn > bins) = bins;
   end
   %similarly, we may have a 0, and we want to push them to 1.
   if min(intrn) == 0
      intrn(intrn == 0) = 1;
   end
   counts = accumarray([ones(size(intrn)),intrn],1);
   binvec = (1:bins)';
   binwidth = range/bins;

   values = minrn + binvec*binwidth;

   if ud.distcells.discrete(popupvalue)
      values = values - 0.5;
   end

   histogram = bar(values,counts,1);

   %xrange   = [p1low - 3 * p2high p1high + 3 * p2high];
   %yvalues =get(histogram,'Ydata');
   %yrange = [0 1.3*max(max(yvalues))];
   set(gca,'XLim',xrange)

   text(-0.08, 0.45,'Counts','Unit','Normalized','EraseMode','none', 'rotation', 90);
   text(0.45,-0.10,'Values','Unit','Normalized','EraseMode','none');
   text(0.55, 1.06,'Samples','Unit','Normalized','EraseMode','none');
   text(0.01, 1.06,'Distribution','Unit','Normalized','EraseMode','none');

catch
   ok = 0;
end
set(gcf,'Pointer','arrow');
if (~ok)
   error('stats:randtool:GeneratorError',...
         'Error occurred while generating random sample.');
end

% output function
function outrndnum(ud)
popupvalue = get(ud.popup,'Value');
labelnames = get(ud.popup,'String');
def = {ud.distcells.rvname{popupvalue}};
label = {deblank(labelnames(popupvalue,:))};
item = {ud.random_numbers};
export2wsdlg(label, def, item, 'Export to Workspace');

%------------------------------------------------------------------------------
% set sliders to use integer or continuous values as appropriate
function setincrement(pslider, intparam)
ss = [0.01 0.1];       % MATLAB default
if (intparam)
   d = max(1, get(pslider,'Max') - get(pslider,'Min'));

   ss = max(1, round(ss * d));
   if (ss(2) <= ss(1)), ss(2) = ss(1) + 1; end
   ss = ss ./ d;
end

set(pslider, 'SliderStep', ss);

%------------------------------------------------------------------------------
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
