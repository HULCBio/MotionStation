function flag_stop = plotbr(tr,name,epoch)
%PLOTBR Plot network performance for Bayesian regularization training.
%
%  Syntax
%
%    plotbr(tr,name,epoch)
%
%  Description
%
%    PLOTBR(TR,NAME,EPOCH) takes these inputs,
%      TR - Training record returned by train.
%      NAME - Training function name, default = ''.
%      EPOCH - Number of epochs, default = length of training record.
%    and plots the training sum squared error, the sum squared weights
%    and the effective number of parameters.
%
%  Example
%
%    Here are input values P and associated targets T.
%
%       p = [-1:.05:1];
%       t = sin(2*pi*p)+0.1*randn(size(p));
%
%    The code below creates a network and trains it on this problem.
%
%       net=newff([-1 1],[20,1],{'tansig','purelin'},'trainbr');
%      [net,tr] = train(net,p,t);
%
%    During training PLOTBR was called to display the training
%    record.  You can also call PLOTBR directly with the final
%    training record TR, as shown below.
%
%      plotbr(tr)

% Orlando De Jesus, 11-11-98, user stopping, etc.
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $ $Date: 2002/04/14 21:33:14 $

flag_stop = 0;

% Special case 1: 'stop' callback
if nargin < 2, name = ''; end
if nargin < 3, 
   % check if tr is a string for the stop condition.
   if ~isstr(tr)
      epoch = length(tr.epoch)-1; 
   end
end

% Changes introduced by Orlando De Jesus 11/11/98
fig2 = 0;
z = get(0,'children');
for i=1:length(z)
  typ = get(z(i),'type');
  if strcmp(typ,'figure')
    nam = get(z(i),'tag');
    if strcmp(nam,'train')
       fig2 = z(i);
     break
   end
  end
end
if length(get(fig2,'children')) == 0, fig2 = 0; end

% Get name from SIMULINK block if available
if (gcbh ~= -1)
  theName = get_param(gcbh,'Name');
else
  theName = name;
end

if fig2==0
   fig2 = figure('Units',          'pixel',...
                 'Name',           theName,...
                 'Tag',            'train',...
                 'NumberTitle',    'off',...
                 'IntegerHandle',  'off',...
                 'Toolbar',        'none');
end

if isstr(tr)
  if strcmp(tr,'stop') & (fig2)
     ud=get(fig2,'UserData');
     ud.stop=1;
     set(fig2,'UserData',ud);
     return
  end
end


if epoch==0
   z = get(fig2,'children');
   for i=1:length(z)
      delete (z(i));
   end
   figure(fig2);
   ud.TrainAxes1    = axes('Parent',fig2,'position',[0.13 0.70 0.77 0.22]);
   ud.TrainLine1    = plot(0,0,0,0,0,0,'EraseMode','None','Parent',ud.TrainAxes1);
   ud.TrainXlabel1  = xlabel('X Axis','Parent',ud.TrainAxes1);
   set(ud.TrainXlabel1,'string',' ');
   ud.TrainYlabel1  = ylabel('Y Axis','Parent',ud.TrainAxes1);
   ud.TrainTitle1   = get(ud.TrainAxes1,'Title');
   set(ud.TrainAxes1,'yscale','log');
   ud.TrainAxes2    = axes('Parent',fig2,'position',[0.13 0.40 0.77 0.22]);
   ud.TrainLine2    = plot(0,0,'EraseMode','None','Parent',ud.TrainAxes2);
   ud.TrainXlabel2  = xlabel('X Axis','Parent',ud.TrainAxes2);
   set(ud.TrainXlabel2,'string',' ');
   ud.TrainYlabel2  = ylabel('Y Axis','Parent',ud.TrainAxes2);
   ud.TrainTitle2   = get(ud.TrainAxes2,'Title');
   set(ud.TrainAxes2,'yscale','log');
   ud.TrainAxes3    = axes('Parent',fig2,'position',[0.13 0.10 0.77 0.22]);
   ud.TrainLine3    = plot(0,0,'EraseMode','None','Parent',ud.TrainAxes3);
   ud.TrainXlabel3  = xlabel('X Axis','Parent',ud.TrainAxes3);
   ud.TrainYlabel3  = ylabel('Y Axis','Parent',ud.TrainAxes3);
   ud.TrainTitle3   = get(ud.TrainAxes3,'Title');
   ud.XData      = [];
   ud.YData      = [];
   ud.Y2Data     = [];
   ud.stop_but = uicontrol('Parent',fig2, ...
  'Units','points', ...
  'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
  'Callback','plotbr(''stop'',''PLOTBR'');', ...
  'ListboxTop',0, ...
  'Position',[2 2 68.75 15], ...
  'String','Stop Training', ...
   'Tag','Pushbutton1');
   ud.stop=0;
   set(fig2,'UserData',ud);
else
   ud=get(fig2,'UserData');
end

ind = 1:(epoch+1);
doTest = ~isnan(tr.tperf(1));
doValidation = ~isnan(tr.vperf(1));

set(ud.TrainLine3,...
      'Xdata',tr.epoch(ind),...
      'Ydata',tr.gamk(ind),...
      'linewidth',2,'color','b');

set(ud.TrainYlabel3,'string','# Parameters');
if epoch~=0
  set(ud.TrainAxes3,'xlim',[0 epoch],'ylim',[min(tr.gamk(ind)) max(tr.gamk(ind))]);
end

if doTest
  set(ud.TrainLine1(2),...
      'Xdata',tr.epoch(ind),...
      'Ydata',tr.tperf(ind),...
      'linewidth',2,'color','r');
end
if doValidation
  set(ud.TrainLine1(3),...
      'Xdata',tr.epoch(ind),...
      'Ydata',tr.vperf(ind),...
      'linewidth',2,'color','g');
end
set(ud.TrainLine1(1),...
      'Xdata',tr.epoch(ind),...
      'Ydata',tr.perf(ind),...
      'linewidth',2,'color','b');

ystring = 'Tr-Blue';
if (doValidation)
  ystring = [ystring '  Val-Green'];
end
if (doTest)
  ystring = [ystring '  Tst-Red'];
end

set(ud.TrainYlabel1,'string',ystring);
set(ud.TrainAxes1,'xticklabel',[]);

if epoch~=0
  set(ud.TrainAxes1,'xlim',[0 epoch],'ylim',[10^fix(log10(min([tr.perf(ind) tr.tperf(ind) ...
            tr.vperf(ind)]))-1) 10^ceil(log10(max([tr.perf(ind) tr.perf(ind) tr.vperf(ind)])))]);
end

set(ud.TrainLine2,...
      'Xdata',tr.epoch(ind),...
      'Ydata',tr.ssX(ind),...
      'linewidth',2,'color','b');

set(ud.TrainYlabel2,'string','SSW');
set(ud.TrainAxes2,'xticklabel',[]);

if epoch~=0
  set(ud.TrainAxes2,'xlim',[0 epoch],'ylim',[10^fix(log10(min(tr.ssX(ind)))-1) 10^ceil(log10(max(tr.ssX(ind))))]);
end


tstring = sprintf('Training SSE = %g',tr.perf(epoch+1));
if (doTest)
  tstring = [tstring sprintf('    Test SSE = %g',tr.tperf(epoch+1));];
end
if (doValidation)
  tstring = [tstring sprintf('    Validation SSE = %g',tr.vperf(epoch+1));];
end
set(ud.TrainTitle1,'string',tstring);

tstring = sprintf('Squared Weights = %g',tr.ssX(epoch+1));
set(ud.TrainTitle2,'string',tstring);

tstring = sprintf('Effective Number of Parameters = %g',tr.gamk(epoch+1));
set(ud.TrainTitle3,'string',tstring);

if epoch == 0
   set(ud.TrainXlabel3,'string','Zero Epochs');
elseif epoch == 1
   set(ud.TrainXlabel3,'string','One Epoch');
else
   set(ud.TrainXlabel3,'string',[num2str(epoch) ' Epochs']);
end


if length(name)
  set(fig2,'name',['Training with ' name],'numbertitle','off')
end
if epoch > 0
   %  set(gca,'xlim',[0 epoch])
else
   figure(fig2);
end
drawnow

if ud.stop
   flag_stop = 1;
end

