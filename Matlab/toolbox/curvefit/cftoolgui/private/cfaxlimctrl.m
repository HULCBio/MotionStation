function cfaxlimctrl(cffig,onoff,opt)
%CFAXLIMCTRL Turn on or off the controls for adjusting axis limits

%   $Revision: 1.7.2.1 $  $Date: 2004/02/01 21:39:39 $ 
%   Copyright 2001-2004 The MathWorks, Inc.

% Remove controls from figure if requested
if isequal(onoff,'off')
   a = findall(cffig,'Tag','axlimctrl');
   delete(a);
   return
end

% Add controls to figure.
% First find all axes in figure and their limits
ax1 = findall(cffig,'Type','axes','Tag','main');
ax2 = findall(cffig,'Type','axes','Tag','resid');
lims = get(ax1,'XLim');
lims(3:4) = get(ax1,'YLim');
if isempty(ax2)
   ax = ax1;
else
   ax = ax2;
   lims(5:6) = get(ax2,'YLim');
end

% Create an arrow for labeling button controls
fcolor = get(cffig,'Color');
ar = ...
[1 1 1 1 1 1 1 1
 1 0 1 1 1 1 1 1
 1 0 0 1 1 1 1 1
 1 0 0 0 1 1 1 1
 1 0 0 0 0 1 1 1
 1 0 0 0 0 0 1 1
 1 0 0 0 0 0 0 1
 1 0 0 0 0 0 1 1
 1 0 0 0 0 1 1 1
 1 0 0 0 1 1 1 1
 1 0 0 1 1 1 1 1
 1 0 1 1 1 1 1 1
 1 1 1 1 1 1 1 1];
ar = repmat(ar,[1 1 3]);
ar(:,:,1) = min(ar(:,:,1),fcolor(1));
ar(:,:,2) = min(ar(:,:,2),fcolor(2));
ar(:,:,3) = min(ar(:,:,3),fcolor(3));

% Find axes position in pixel units
oldaxunits = get(ax1,'Units');
set(ax1,'Units','pixel');
axpos = get(ax1,'Position');
if ~isempty(ax2)
   set(ax2,'Units','pixel');
   ax2pos = get(ax2,'Position');
   axbottom = ax2;
   axbottompos = ax2pos;
else
   axbottom = ax1;
   axbottompos = axpos;
end

% Compute the dimensions to use for text fields

% First get the longest axis limit and measure it in an edit control
samptxt= '';
for j=1:length(lims)
   newtxt = num2str(lims(j));
   if length(newtxt)>length(samptxt)
      samptxt = newtxt;
   end
end
if length(samptxt)<7
   samptxt = samptxt(min(length(samptxt),1:7));
end
temph = uicontrol(cffig,'style','edit','string',samptxt,...
                  'position',[1 1 300 10],'Visible','off');
extent = get(temph,'extent');
delete(temph);

% Next measure the y axis tick labels in a text control
ytxt = get(ax1,'YTickLabel');
ytxt(:,end+1) = ' ';
a = uicontrol(cffig,'style','text','string',ytxt,...
              'position',[1 1 300 10],'visible','off');
e = get(a,'Extent');
tickwidth = e(3);
if ~isempty(ax2)
   ytxt = get(ax2,'YTickLabel');
   ytxt(:,end+1) = ' ';
   set(a,'String',ytxt);
   e = get(a,'Extent');
   tickwidth = max(tickwidth,e(3));
end
delete(a);

% Reserve room for the controls
oldunits = get(axbottom,'Units');
set(axbottom,'Units','pixel');
bht = ceil(extent(4)/2);     % arrow button height
bwd = ceil(1.5*bht);         % arrow button width
if axbottompos(2)<6*bht
   oldtop = axbottompos(2)+axbottompos(4);
   axbottompos(2) = 6*bht;
   axbottompos(4) = max(1,oldtop - axbottompos(2));
   set(axbottom,'Position',axbottompos);
   if isempty(ax2)
      axpos = axbottompos;
   else
      ax2pos = axbottompos;
   end
end
leftlim = 1 + extent(3) + bwd + tickwidth;
if axbottompos(1)<leftlim
   % Get figure width and make sure to stay in bounds
   figunits = get(cffig,'Units');
   set(cffig,'Units','pixels');
   figpos = get(cffig,'Position');
   set(cffig,'Units',figunits);
   
   oldright = min(axbottompos(1)+axbottompos(3),figpos(3)-bwd-extent(3)/2);
   axbottompos(1) = max(axbottompos(1),leftlim);
   axbottompos(3) = max(1,oldright - leftlim);
   set(axbottom,'Position',axbottompos);
   if isempty(ax2)
      axpos = axbottompos;
   else
      ax2pos = axbottompos;
      axpos([1 3]) = axbottompos([1 3]);
      set(ax1,'Position',axpos);
   end
end
set(ax1,'Units',oldaxunits);
if ~isempty(ax2), set(ax2,'Units',oldunits); end


% Add controls to axes as required
hgpkg = findpackage('hg');     % get handle to hg package
axesC = hgpkg.findclass('axes');
[h1,h0] = addctrl(ar,extent,ax1,'ylo',axpos,bht,bwd);
h2 = addctrl(ar,extent,ax1,'yhi',axpos,bht,bwd);
lsnr = handle.listener(ax1, axesC.findprop('ylim'), ...
                       'PropertyPostSet', {@localUpdateText ax1 'y' h1 h2});
ud = get(h1,'UserData');
ud{3} = lsnr;
set(h1,'UserData',ud);
if isempty(ax2)
   h1 = addctrl(ar,extent,ax1,'xlo',axpos,bht,bwd);
   h2 = addctrl(ar,extent,ax1,'xhi',axpos,bht,bwd);
   lsnr = handle.listener(ax1, axesC.findprop('xlim'), ...
                       'PropertyPostSet', {@localUpdateText ax1 'x' h1 h2});
   ud = get(h1,'UserData');
   ud{3} = lsnr;
   set(h1,'UserData',ud);
else
   h1 = addctrl(ar,extent,ax2,'ylo',ax2pos,bht,bwd);
   h2 = addctrl(ar,extent,ax2,'yhi',ax2pos,bht,bwd);
   lsnr = handle.listener(ax2, axesC.findprop('ylim'), ...
                       'PropertyPostSet', {@localUpdateText ax2 'y' h1 h2});
   ud = get(h1,'UserData');
   ud{3} = lsnr;
   set(h1,'UserData',ud);

   h1 = addctrl(ar,extent,ax2,'xlo',ax2pos,bht,bwd);
   h2 = addctrl(ar,extent,ax2,'xhi',ax2pos,bht,bwd);
   lsnr = handle.listener(ax1, axesC.findprop('xlim'), ...
                       'PropertyPostSet', {@localUpdateText ax2 'x' h1 h2});
   ud = get(h1,'UserData');
   ud{3} = lsnr;
   set(h1,'UserData',ud);
end


% ------------ Add a control to adjust an axis limit
function [htxt,h1,h2] = addctrl(ar,extent,ax,edge,axpos,bht,bwd)

f = get(ax,'Parent');

udtext = sprintf('%st',edge);
udup   = sprintf('%su',edge);
uddown = sprintf('%sd',edge);

xlim = get(ax,'XLim');
ylim = get(ax,'YLim');

% Compute desired text field position
if edge(1)=='x'
   if isequal(edge,'xlo')
      xcenter = axpos(1);
      txt = xlim(1);
      txtlabel = xlate('X Lower Limit');
   else
      xcenter = axpos(1) + axpos(3);
      txt = xlim(2);
      txtlabel = xlate('X Upper Limit');
   end
   extent(1) = xcenter - extent(3)/2;
   extent(2) = max(2*bht, axpos(2)-4*bht);
   extent(4) = 2*bht;
   labelpos = -1;
else
   if isequal(edge,'ylo')
      ycenter = axpos(2);
      txt = ylim(1);
      txtlabel = xlate('Y Lower Limit');
   else
      ycenter = axpos(2) + axpos(4);
      txt = ylim(2);
      txtlabel = xlate('Y Upper Limit');
   end
   extent(1) = 1;
   extent(2) = ycenter - bht;
   extent(4) = 2*bht;
   labelpos = 1;
end

% Create the text-entry field and arrow buttons, and position them
htxt = uicontrol(f,'Style','edit','String',num2str(txt),...
                 'Position',extent,'Userdata',{udtext ax 0},...
                 'Tag','axlimctrl',...
                 'Callback',{@doscroll ax},'BackgroundColor','w');
xright = extent(1)+extent(3);
ybndry = extent(2);
h1 = makearrow(bht,bwd,ax,f,ar,'t',xright,ybndry+bht);
set(h1,'Userdata',{udup ax htxt});
h2 = makearrow(bht,bwd,ax,f,ar,'b',xright,ybndry);
set(h2,'Userdata',{uddown ax htxt});

% Place a label under the text field
extent(2) = extent(2) + labelpos*extent(4);
extent(3) = 10*extent(3);
h = uicontrol(f,'Style','text','Position',extent,...
                'Tag','axlimctrl','Visible','off');

[txtlabel,newpos] = textwrap(h,{txtlabel});
set(h,'String',txtlabel{1},'Position',newpos,'Visible','on');

% ----------- create an arrow control in the specified direction
function h = makearrow(bht,bwd,ax,f,ar,direct,pleft,pbot)

% Point cdata arrow in the right direction
switch direct
 case {'b' 'l'}, ar = permute(ar,[2 1 3]);
 case {'t' 'r'}, ar = permute(ar,[2 1 3]); ar = ar(end:-1:1,:,:);
end

% Position and size button correctly
pos = [pleft pbot bwd bht];
h = uicontrol(f,'Style','pushbutton','CData',ar,'Tag','axlimctrl',...
                'Units','pixel','Position',pos,...
                'Callback',{@doscroll ax});


% ------------- callback for these controls
function doscroll(btn,xxx,ax);

% Get current tick locations and axis limits
ud = get(btn,'Userdata');
opt = ud{1};
if opt(1)=='x'
   limname = 'XLim';
   locs = get(ax,'XTick');
else
   limname = 'YLim';
   locs = get(ax,'YTick');
end
lims = get(ax,limname);

% Get current value of this limit
if opt(2)=='h'
   limindex = 2;
   curtick = locs(end);
else
   limindex = 1;
   curtick = locs(1);
end

% Increment or decrement
curlim = lims(limindex);
delta = locs(2) - locs(1);
if opt(4)=='u'
   if opt(2)=='h'     % move hi limit up
      if curlim < curtick + 0.95*delta
         curval = curtick + delta;
      else
         curval = curlim + delta;
      end
   else               % move lo limit up
      if curlim > curtick - 0.05*delta
         curval = curtick + delta;
      else
         curval = curtick;
      end
   end
elseif opt(4)=='d'
   if opt(2)=='h'     % move hi limit down
      if curlim > curtick + 0.05*delta
         curval = curtick;
      else
         curval = curlim - delta;
      end
   else               % move lo limit down
      if curlim > curtick - 0.95*delta
         curval = curtick - delta;
      else
         curval = curlim - delta;
      end
   end
else
   try
      curval = str2double(get(btn,'String'));
   catch
      curval = [];
   end
   if isempty(curval) | ~isfinite(curval)
      return
   end
   if (limindex==1 & curval>=lims(2)) | (limindex==2 & curval<=lims(1))
      return
   end
end

% Update the axis limits
lims(limindex) = curval;
set(ax,limname,lims);


% ----------- update text fields when axis limits change
function localUpdateText(src, eventData, ax, xory, hlo, hhi)

% Show 0 if one limit is very small compared to the other

if xory=='x'
   lim = get(ax,'XLim');
else
   lim = get(ax,'YLim');
end

newval = lim(1);
if abs(newval)<abs(max(lim))*sqrt(eps)
   newval = 0;
end
set(hlo,'String',num2str(newval));

newval = lim(2);
if abs(newval)<abs(max(lim))*sqrt(eps)
   newval = 0;
end
set(hhi,'String',num2str(newval));
