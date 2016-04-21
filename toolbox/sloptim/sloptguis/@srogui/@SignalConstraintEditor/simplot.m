function simplot(this,Test,DataLog,LogName)
% Plots current response

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision $  $Date: 2004/04/11 00:44:51 $
idxt = find([this.TestViews.Test]==Test);
SignalSize = this.Constraint.SignalSize;
   
% Number of runs
if isempty(Test.Runs)
   Nruns = 1;
   LineStyle = '-';
else
   Nruns = prod(getGridSize(Test.Runs));
   LineStyle = ':';
end

% Create lines if needed
L = this.TestViews(idxt).Response;
sLine = [prod(SignalSize) , Nruns];
if ~isequal(size(L),sLine)
   % Delete existing lines
   L = this.TestViews(idxt).Response;
   delete(L(ishandle(L)));
   % Create appropriate set of lines
   ax = getaxes(this);
   L = zeros(sLine);
   for ct=1:prod(sLine)
      L(ct) = line('Parent',ax,'Color',[1.0 1.0 1.0],...
         'LineWidth',1.5,'LineStyle',LineStyle,'HitTest','off');
      b = hggetbehavior(L(ct),'DataCursor');
      Context = struct(...
         'SignalSize',SignalSize,...
         'Channel',1 + rem(ct-1,sLine(1)),...
         'Test',Test);
      b.UpdateFcn = @(tip,cursor) LocalMakeTip(tip,cursor,Context);
   end
   this.TestViews(idxt).Response = L;
end

% Loop over each run and update plot
for ct=1:Nruns
   % Extract data
   Log = utFindLog(DataLog{ct},LogName);
   if isempty(Log) || isempty(Log.Time)
      set(L(:,ct),'XData',[],'YData',[],'ZData',[])
   else
      % Plot data
      [y,t] = utGetLogData(Log);
      z = 2 + zeros(length(t),1);
      for ch=1:sLine(1)
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
if isempty(Context.Test.Runs)
   Head = {sprintf('Current response%s',ChStr)};
else
   Head = {sprintf('Current response%s (uncertainty)',ChStr)};
end
str = cat(1,Head,Location);

