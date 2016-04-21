function cfupdatelegend(cffig,reset)
%CFUPLDATELEGEND Update legend in curve fitting plot

%   $Revision: 1.20.2.3 $  $Date: 2004/03/02 21:46:12 $ 
%   Copyright 2001-2004 The MathWorks, Inc. 

if nargin<2, reset=false; end

% If figure not passed in, find figure that contains this thing
while ~isequal(get(cffig,'parent'),0),
  cffig = get(cffig,'parent');
end

% Remember info about old legend, if any
ax = findall(cffig,'Type','axes','Tag','main');
legh = legend(ax);
if ~isempty(legh) && ishandle(legh) && ~reset
   legendpos = get(legh,'Location');
else
   legendpos = 'none';
end
legend(ax, 'off');

% Remember info about old residuals legend, if any
ax2 = findall(cffig,'Type','axes','Tag','resid');
rlegendpos = 'none';
if ~isempty(ax2)
   legh = legend(ax2);
   if ~isempty(legh) && ishandle(legh) && ~reset
      rlegendpos = get(legh,'Location');
   end
   legend(ax2, 'off');
end

% Maybe no legend has been requested
if isequal(cfgetset('showlegend'),'off')
   return
end

% Get data line handles and labels
hh = flipud(findobj(ax,'Type','line'));
h1 = findobj(hh,'flat','Tag','cfdata');
n = length(h1);
c1 = cell(n,1);
for j=1:length(h1)
   nm = '';
   ud = get(h1(j),'UserData');
   if ~isempty(ud) && ishandle(ud) && ~isempty(findprop(ud,'name'))
      nm = ud.name;
   end
   if isempty(nm)
      h1(j) = NaN;
   else
      c1{j} = nm;
   end
end
t = ~isnan(h1);
c1 = c1(t);
h1 = h1(t);
s1 = 1000*(1:length(h1));
if isempty(s1)
   maxnum = 0;
else
   maxnum = max(s1) + 1000;
end

% Indent fits if there are two or more data lines
if (length(h1)>1)
   pre = '  ';
else
   pre = '';
end

% Get fit line handles and labels
h2 = findobj(hh,'flat','Tag','curvefit');
s2 = NaN*h2;
n = length(h2);
c2 = cell(n,1);
nms = cell(n,1);
for j=1:length(h2)
   nm = get(handle(h2(j)),'String');
   if isempty(nm)
      h2(j) = NaN;
   else
      nms{j} = nm;
      c2{j} = [pre nm];
      
      % Find the dataset for this fit
      ua = get(handle(h2(j)),'UserArgs');
      if iscell(ua) && length(ua)>0
         ds = ua{1};
         s2j = maxnum + j;
         for k=1:length(h1)
            if isequal(ds,c1{k})
               s2j = s1(k) + j;
               break;
            end
         end
         s2(j) = s2j;
      end
   end
end
t = ~isnan(h2);
nms = nms(t);
c2 = c2(t);
h2 = h2(t);
s2 = s2(t);

% Remember just one confidence bound for each fit
hconf = zeros(size(h2));
for j=1:length(hconf)
   b = get(handle(h2(j)),'BoundLines');
   if ~isempty(b)
      hconf(j) = b(1);
   end
end

% Indent bounds if there are two or more fits
if (length(h2)>1)
   pre = [pre '  '];
end

% Get confidence bound line handles and labels
h3 = findobj(hh,'flat','Tag','cfconf');
n = length(h3);
c3 = cell(n,1);
s3 = zeros(size(h3));
for j=1:length(h3)
   if isempty(hconf)
      k = [];
   else
      k = find(h3(j)==hconf);
   end
   if ~isempty(k) && ~isempty(get(h3(j),'XData'))
      c3{j} = sprintf('%sPred bnds (%s)',pre,nms{k});
      s3(j) = s2(k) + 0.5;
   else
      h3(j) = NaN;
   end
end
t = ~isnan(h3);
c3 = c3(t);
h3 = h3(t);
s3 = s3(t);

% Combine everything together for the legend
h = [h1(:); h2(:); h3(:)];
c = [c1; c2; c3];
s = [s1(:); s2(:); s3(:)];

% Sort so related things are together
[s,j] = sort(s);
c = c(j);
h = h(j);

% Create the legend
if (length(h)>0)
   ws = warning;
   lw = lastwarn;
   warning('off');
   try
      if isequal(legendpos,'none')
         [legh,objh] = legend(ax,h,c);
      else
         [legh,objh] = legend(ax,h,c,'Location',legendpos);
      end
   catch
   end
   warning(ws);
   lastwarn(lw);
   
   % Avoid treating ds/fit names as TeX strings
   objh = findobj(objh,'flat','Type','text');
   set(objh,'Interpreter','none','Hittest','off');
else
   legend(ax,'off');
end

% Set a resize function that will handle legend and layout
set(cffig,'resizefcn','cftool(''adjustlayout'');');

% Fix residual legend; this is a lot simpler
if ~isempty(ax2)
   h = flipud(findobj(ax2,'Type','line'));
   c = cell(length(h),1);
   for j=length(h):-1:1
      t = get(h(j),'UserData');
      if iscell(t) && length(t)>0 && ischar(t{1}) && ~isempty(t{1})
         c{j} = t{1};
      else
         c(j) = [];
         h(j) = [];
      end
   end
   
   if (length(h)>0)
   ws = warning;
   lw = lastwarn;
   warning('off');
   try
      if isequal(rlegendpos,'none')
         [legh,objh] = legend(ax2,h,c);
      else
         [legh,objh] = legend(ax2,h,c,'Location',rlegendpos);
      end
   catch
   end
   warning(ws);
   lastwarn(lw);

      % Avoid treating ds/fit names as TeX strings
      objh = findobj(objh,'flat','Type','text');
      set(objh,'Interpreter','none','Hittest','off');
   else
      legend(ax2,'off');
   end
end

% Hack to make sure moving the legend does not disable data tips
% When the moveaxis function sets the windowbuttonmotionfcn to
% null, it also changes the pointer.  We listen for that and
% restore the windowbuttonmotionfcn to the value we need.
b = handle.listener(handle(cffig), findprop(handle(cffig),'pointer'), ...
          'PropertyPostSet',...
             'if isequal(cfgetset(''showdftips''),''on''),set(cfgetset(''cffig''),''WindowButtonMotionFcn'',@cftips);end');
setappdata(cffig,'RestoreTipHandler',b);

