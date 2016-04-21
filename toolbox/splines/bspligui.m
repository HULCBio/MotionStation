function bspligui(arg,topic)
%BSPLIGUI B-spline experimentation tool (GUI).
%
%   BSPLIGUI starts this GUI, for experimentation with how a B-spline depends
%   on its knots, using the knot sequence -1:.5:1.
%   Click on the Help Menu for detailed information.
%
%   BSPLIGUI(KNOTS) starts with the knot sequence KNOTS, but translated
%   and scaled to have -1 and 1 as the extreme knots.
%
%   BSPLIGUI(ARG), with ARG equal to 'close','exit','finish', or 'quit',
%   terminates this GUI, as does clicking on the button marked Close,
%   or simply closing the GUI's window.
%
%   See also BSPLINE, BSPLIDEM, SPCOL.

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
%   $Revision: 1.15 $  $Date: 2003/04/25 21:12:47 $

updated = '10jun02';
abouttext = {'Spline Toolbox 3.2'; ...
            'Copyright 1987-2003 C. de Boor and The Mathworks, Inc.'};

if nargin==0 % we are starting from scratch

   if ~isempty(findobj(allchild(0),'filename','bspligui.m'))
      errordlg('BSPLIGUI is already running','No need to start another one ...')
      return
   end
   
   t = []; arg = 'start';

elseif  ischar(arg)
   hand = get(gcbf,'Userdata');

else % we take arg to be a knot sequence to be used
   diffa = diff(arg);
   if isempty(diffa)||~any(diffa)
      errordlg('Need at least two distinct knots'), return
   end
   t = arg(:).';
   if any(diffa<0) % need to sort
      t = sort(t);
   end
   bspligui('exit'), arg = 'start';
   
end

switch arg

case 'add'
   
   [tadd,ignored] = ginput(1); 
   t = get(hand.shmarker,'Xdata');
   tadd = max(t(1),min(t(end),tadd));
   [t,index] = sort([tadd,t]);
   set(hand.shmarker,'Xdata',t)
   V = find(index==1);
   set(hand.shknots,'Userdata',V,'Xdata',t([V V]))
   set(hand.shslider,'Value',t(V))
   if length(t)<4, set(hand.shknots,'Visible','on'), end

   bsplshw(t,hand)

case {'close','exit','finish','quit'}
   close(findobj(allchild(0),'Filename','bspligui.m'))

case 'delete' % delete the marked knot
   if strcmp(get(hand.shknots,'Visible'),'on')
      t = get(hand.shmarker,'Xdata');
      V = get(hand.shknots,'Userdata'); 
      t(V)=[];
         ks = .07; % controls spacing for multiple knot display
      set(hand.shmarker,'Xdata',t,'Ydata',knt2mlt(t)*ks)
      if length(t)<3
         set(hand.shknots,'Visible','off','Userdata',1)
      else
         V = min(V, length(t)-1);
         set(hand.shknots,'Userdata', V, 'Xdata',t([V V]))
         set(hand.shslider,'Value',t(V))
      end
      bsplshw(t,hand)
   end

case 'help'

   titlestring = ['Explanation: ',topic];
   switch topic

   case 'about'
      titlestring = 'About the Spline Toolbox';
      mess = abouttext;

   otherwise
      mess = spterms(topic);
   end

   msgbox(mess,titlestring)

case 'mark'  % action when one of the axes is clicked

   % only react here to LEFT clicks
   temp = get(gcbf,'SelectionType');
   if temp(1)=='n'

      % get the location of the latest click in data coordinates:
      clickp = get(gca,'CurrentPoint');
      
      % find the nearest interior knot, if any
      t = get(hand.shmarker,'Xdata');
      if length(t)>2
         [ignored,V] = min(abs(clickp(1,1)-t(2:end-1)));
         set(hand.shknots,'Userdata',V+1,'Xdata',t([V+1 V+1]))
         set(hand.shslider,'Value',t(V+1))
      end
   end

case 'move'
   
   if strcmp(get(hand.shknots,'Visible'),'on') % only move if there are more
                                               % than two knots...
      t = get(hand.shmarker,'Xdata');
      told = t(get(hand.shknots,'Userdata'));
      toldi = find(t==told); t(toldi) = []; others = length(toldi)-1;
      ta = max(hand.interv(1),min(hand.interv(2), get(hand.shslider,'Value')));
      [distance,j] = min(abs(ta-t));
      if distance < hand.tol, ta = t(j); end
      if get(hand.toggle,'Value') 
             % must make sure to leave an end behind
         tamore = repmat(ta,1,others);
         if any(hand.interv==told), tamore(end)=told; end
      else
         tamore = repmat(told,1,others);
      end
      [t,index] = sort([ ta, tamore, t]);
      V = find(index==1);
      set(hand.shknots,'Userdata',V)
      set(hand.shslider,'Value',t(V))
      set(hand.shmarker,'Xdata',t)
      bsplshw(t,hand)
   end 

case 'start'

   if isempty(t), t = -1:.5:1;
   else  t = -1 +(2/(t(end)-t(1)))*(t-t(1));
   end
   lt = length(t);
   bspliguifig = figure('Color',[.8 .8 .8], ...
          'Filename','bspligui.m',...
          'Units','normalized', ...
          'Position',[.25 .10 .48 .75], ...
          'numbertitle','off', ...
          'name','Experiment with a B-spline as a function of its knots',...
          'doublebuffer','on', ...
          'Menubar','none', ...
          'Toolbar','none');

   hand = struct('knotline',zeros(1,4), 'shder',zeros(1,4),'text',0, ...
                 'shmarker',0,'shknots',0,'shslider',0,'interv',[-1 1], ...
                 'tol',.01);
   ss = .225; % controls vertical spacing of displays
   ds = .02; % controls space between displays
   xs = .48; % controls left corner of displays
   dx = .48; % controls width of displays
   dxl = .044; % controls the needed overwidth of the slider control
   dxr = .034; % controls the needed overwidth of the slider control
   ys = .1; % controls bottom of displays
   lw = 2; % controls linewidth used in displays
   lc = 'b'; % controls line color
   ks = .07; % controls spacing for multiple knot display
   axesbspline = axes('Position',[xs ys+3*ss dx ss-ds], ...
              'ButtonDownFcn','bspligui ''mark''', ...
       'Fontsize',8, ...
       'Xticklabel',[]);
   hand.knotline(1) = line('Xdata',NaN,'Ydata',NaN,'color',[.8 .8 .8], ...
              'linew',2, ...
              'ButtonDownFcn','bspligui ''mark''');
   XX = linspace(hand.interv(1),hand.interv(2),101);
   hand.shder(1) = line('Xdata',XX,'Ydata',zeros(1, 101), ...
               'color',lc,'linew',lw);
   hand.shmarker = line(t,knt2mlt(t)*ks,'marker','x','color','r', ...
               'Linestyle','none', ...
               'Userdata',ks);
   hand.shknots = line(t([2 2]),[0 1],'color','r','linew',2, ...
               'Visible','on', ...
               'Userdata',2);
   if length(t)<3, set(hand.shknots,'Visible','off'), end
   axis([hand.interv(1), hand.interv(2), 0, 1]);
   vals = segplot([t;repmat(0,1,lt);t;repmat(1,1,lt)]);
   set(hand.knotline(1),'Xdata',vals(1,:),'Ydata',vals(2,:))
   
   for j=2:4
      a = axes('Position',[xs ys+(4-j)*ss dx ss-ds],...
                 'ButtonDownFcn','bspligui ''mark''', ...
                 'Fontsize',8);
      if j<4, set(a, 'Xticklabel',[]), end
      line(t([1 end]),[0 0],'color','k','linewidth',.5)
      hand.knotline(j) = line('Xdata',NaN,'Ydata',NaN,'color',[.8 .8 .8], ...
                 'linew',2, ...
                 'ButtonDownFcn','bspligui ''mark''');
      hand.shder(j) = line('Xdata',XX,'Ydata',zeros(1,101),'color',lc, ...
                           'linew',lw);
   end
   
   wl = .01; ww = .40; hh = .08;  dh = .02; lifts = .1;
   hand.text = uicontrol('Style','text', ...
     'Units','normalized','Position',[wl ys+3*ss ww ss-ds], ...
     'HorizontalAlignment','Left');
   uicontrol('Style','text', ...
     'Units','normalized','Position',[wl ys+3*ss-dh-hh ww hh], ...
     'String', ...
  'Also shown are the 1st, 2nd, and 3rd derivative of the B-spline.',...
     'HorizontalAlignment','Left');

   bsplshw(t,hand)
   
   hand.shslider = uicontrol('Style','Slider',...
        'Units','normalized','Position',[xs-dxl,.02,dx+dxl+dxr,.04], ...
        'Min',hand.interv(1),'Max',hand.interv(2),'Value',t(2),...
        'TooltipString','move the marked knot', ...
        'Callback', 'bspligui ''move''');
   uicontrol('Units','normalized','Position',[wl, lifts+4*(hh+dh), ww, hh], ...
        'String','Add a knot', ...
        'Callback', 'bspligui ''add''');
   uicontrol('Style','text', ...
        'Units','normalized','Position',[wl, lifts+3*(hh+dh), ww, hh], ...
        'String',{'';'Mark a knot by (left)clicking near it'});
   uicontrol('Units','normalized','Position',[wl, lifts+2*(hh+dh), ww, hh], ...
        'String','Delete the marked knot', ...
        'Callback', 'bspligui ''delete''');
   hand.toggle = uicontrol('Style','togglebutton', ...
        'Units','normalized','Position',[wl, lifts+(hh+dh), ww, hh], ...
        'String','Move the marked KNOT with the slider',...
        'TooltipString','toggle between moving knots and breaks', ...
        'Callback','bspligui ''toggle''','Value',0);
   uicontrol('Units','normalized','Position',[wl, lifts, ww, hh], ...
        'String','Close', ...
        'Callback', 'bspligui ''close''');
   
    h1 = uimenu(gcf,'Label','&Help');
     uimenu(h1,'Label','&B-Spline GUI Help', ...
                           'Callback','doc splines/bspligui');
     uimenu(h1,'Label','&Spline Toolbox Help', ...
                           'Callback','doc splines/');
     uimenu(h1,'Label','&Demos', ...
                           'Separator','on', ...
                           'Callback','demo toolbox spline');
%%%%%%%%%%%%%%%%%%   all specific help removed on Penny's advice
     uimenu(h1,'Label','&About the Spline Toolbox',...
                           'Separator','on', ...
                       'Callback','bspligui(''help'',''about'')');

   set(bspliguifig,'HandleVisibility','callback', 'Userdata',hand)

case 'toggle'
   if get(hand.toggle,'Value')
      set(hand.toggle, 'String','Move the marked BREAK with the slider')
   else
      set(hand.toggle, 'String','Move the marked KNOT with the slider')
   end

otherwise
  error('SPLINES:BSPLIGUI:unknowninarg',['unrecognizable input: ', arg])

end


function [pp4,k,l] = bsplget(t)
%BSPLGET values of a B-spline and its first three derivatives
%
%        [pp4,k,l] = bsplget(t)
%

pp = sp2pp(spmak(t,1));
%  put together values and first three derivatives, by first combining
%  values and second derivative, and then differentiating this to get
%  also first and third derivative
[breaks,coefs,l,k] = ppbrk(pp);
ddpp = fnder(pp,2);
if k>2
   pp2 = ...
     ppmak(breaks, reshape([coefs.';zeros(2,l);ppbrk(ddpp,'c').'],k,2*l).',2);
else
   pp2 = ppmak(breaks, reshape([coefs.';zeros(k,l)],k,2*l).',2);
end
if k>1
   pp4 = ppmak(breaks, ...
   reshape([ppbrk(pp2,'c').';zeros(1,2*l);ppbrk(fnder(pp2),'c').'],k,4*l).',4);
else
   pp4 = ppmak(breaks, ...
   reshape([ppbrk(pp2,'c').';zeros(1,2*l)],k,4*l).',4);
end

function bsplshw(t,hand)
%BSPLSHW redisplay b-spline and its derivatives

[pp4,k,l] = bsplget(t);
values = ppual(pp4,get(hand.shder(1),'Xdata'));

if l>1
   anzahl = [num2str(l),' polynomial pieces, each'];
else
   anzahl = 'one polynomial piece,';
end
set(hand.text,'String', ...
    {'',...
     ['The B-spline is of ORDER ',num2str(k),' since it is specified by ',...
      num2str(k+1),' knots.'],  ...
   '',['It consists of ',anzahl,' of DEGREE ',num2str(k-1),'.']}, ...
     'HorizontalAlignment','Left');

lt = length(t);
vals = segplot([t;repmat(0,1,lt);t;repmat(1,1,lt)]);
set(hand.knotline(1),'Xdata',vals(1,:),'Ydata',vals(2,:))
set(hand.shder(1),'ydata',values(1,:))
set(hand.shmarker,'Xdata',t, ...
                  'Ydata',knt2mlt(sort(t))*get(hand.shmarker,'Userdata'))
set(hand.shknots,'Xdata',t(repmat(get(hand.shknots,'Userdata'),1,2)))

for j=2:4
   set(hand.shder(j),'ydata',values(j,:))
   vals = segplot([t;repmat(min(values(j,:))-.1,1,lt); ...
                   t;repmat(max(values(j,:))+.1,1,lt)]);
   set(hand.knotline(j),'Xdata',vals(1,:),'Ydata',vals(2,:))
end

function segsout = segplot(s,arg2,arg3)
%SEGPLOT plot a collection of segments
%
%        segsout = segplot(s,arg2,arg3)
%
%  returns the appropriate sequences  SEGSOUT(1,:) and  SEGSOUT(2,:)
% (containing the segment endpoints properly interspersed with NaN's)
% so that PLOT(SEGSOUT(1,:),SEGSOUT(2,:)) plots the straight-line 
% segment(s) with endpoints  (S(1,:),S(2,:))  and  (S(d+1,:),S(d+2,:)) ,
% with S of size  [2*d,:].
%
%  If there is no output argument, the segment(s) will be plotted in
% the current figure (and nothing will be returned),
% using the linestyle and linewidth optionally specified by ARG2 and ARG3 
% as a string and a number, respectively.

% cb dec96, mar97, apr99; DIRFIELD is a good test for it.

[twod,n] = size(s); d = twod/2;
if d<2, error('SPLINES:BSPLIGUI:inputwrongsize',...
              'the input must be of size (2d)-by-n with d>1.'), end
if d>2, s = s([1 2 d+1 d+2],:); end

tmp = [s; repmat(NaN,1,n)];
segs = [reshape(tmp([1 3 5],:),1,3*n);
        reshape(tmp([2 4 5],:),1,3*n)];

if nargout==0
   symbol=[]; linewidth=[];
   for j=2:nargin
      eval(['arg = arg',num2str(j),';'])
      if ischar(arg), symbol=arg;
      else
         [ignore,d]=size(arg);
         if ignore~=1
            error('SPLINES:BSPLIGUI:wronginarg',...
                 ['arg',num2str(j),' is incorrect.'])
         else
            linewidth = arg;
         end
      end
   end
   if isempty(symbol) symbol='-'; end
   if isempty(linewidth) linewidth=1; end
   plot(segs(1,:),segs(2,:),symbol,'linewidth',linewidth)
   % plot(s([1 3],:), s([2 4],:),symbol,'linewidth',linewidth)
   % would also work, without all that extra NaN, but is noticeably slower.
else
   segsout = segs;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  the end
