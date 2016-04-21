function traceplot(this,Test,DataLog,LogName)
% Updates optimization trace

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision $  $Date: 2004/04/11 00:44:53 $
Colors = {'b','g','r','m','c','y'};
idxt = find([this.TestViews.Test]==Test);
SignalSize = this.Constraint.SignalSize;

% Optimized runs
if isempty(Test.Runs)
   idxRuns = 1;
   LineStyle = '-';
else
   idxRuns = find(Test.Runs.Optimized);
   LineStyle = ':';
end
Nruns = length(idxRuns);

% Get handles of optimization traces
Trace = this.TestViews(idxt).Optimization;
nt = size(Trace,3) * (~isempty(Trace));
c = Colors{1+rem(nt,length(Colors))};

% Fading of previous traces
set(Trace(:,:,2:nt),'LineWidth',1)

% Add new trace
ax = getaxes(this);
sLine = [prod(SignalSize) , Nruns];
L = zeros(sLine);
for ct=1:numel(L)
   L(ct) = line('Parent',ax,'Color',c,...
      'LineWidth',1.5,'LineStyle',LineStyle,'HitTest','off');
   b = hggetbehavior(L(ct),'DataCursor');
   Context = struct(...
      'SignalSize',SignalSize,...
      'Channel',1 + rem(ct-1,sLine(1)),...
      'Iteration',nt);
   b.UpdateFcn = @(tip,cursor) LocalMakeTip(tip,cursor,Context);
end
this.TestViews(idxt).Optimization = cat(3,Trace,L);

% Loop over each run and update plot
for ct=1:Nruns
   % Extract data
   Log = utFindLog(DataLog{idxRuns(ct)},LogName);
   if isempty(Log) || isempty(Log.Time)
      set(L(:,ct),'XData',[],'YData',[],'ZData',[])
   else
      % Plot data 
      [y,t] = utGetLogData(Log);
      z = 0.5 + zeros(length(t),1);
      for ch=1:size(L,1)
         set(L(ch,ct),'XData',t,'YData',y(:,ch),'ZData',z)
      end
   end
end

% Update limits
this.Axes.send('ViewChanged')


%--------------- Local Functions

function str = LocalMakeTip(DataTip,DataCursor,Context)
% Cursor position
Location = {sprintf('Time: %.3g',DataCursor.Position(1)) ; 
   sprintf('Amplitude: %.3g',DataCursor.Position(2))};

% Signal size
SigSize = Context.SignalSize;
if all(SigSize==1)
   ChStr = '';
elseif any(SigSize==1)
   ChStr = sprintf(', channel %d ',Context.Channel);
else
   [i,j] = ind2sub(SigSize,Context.Channel);
   ChStr = sprintf(', channel (%d,%d) ',i,j);
end

% Header
if Context.Iteration==0
   Head = {sprintf('Initial response')};
else
   Head = {sprintf('Response at iteration %d',Context.Iteration)};
end
str = cat(1,Head,Location);
