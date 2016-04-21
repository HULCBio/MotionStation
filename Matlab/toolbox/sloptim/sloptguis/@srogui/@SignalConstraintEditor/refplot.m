function refplot(this)
% Plots the reference signal

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/11 00:44:48 $
L = this.Reference;
c = this.Constraint;
xref = c.ReferenceX;
yref = c.ReferenceY(:,:);
if size(yref,2)==1
   nch = 1;
else
   nch = prod(c.SignalSize);
end

if isempty(xref) || size(yref,2)~=nch
   % Clear current reference plot
   set(L,'XData',[],'YData',[],'ZData',[])
else
   % Adjust number of lines
   if numel(L)~=nch
      % Clean up
      delete(L(ishandle(L)))
      % Regenerate lines
      ax = getaxes(this);
      L = zeros(nch,1);
      for ct=1:nch
         L(ct,1) = line('Parent',ax,'Color',[.8 .8 .8],'LineStyle','-.','LineWidth',3);
         b = hggetbehavior(L(ct),'DataCursor');
         Context = struct(...
            'SignalSize',c.SignalSize,...
            'Channel',ct);
         b.UpdateFcn = @(tip,cursor) LocalMakeTip(tip,cursor,Context);
      end
      this.Reference = handle(L);
   end

   % Plot data
   z = 1+zeros(length(xref),1);
   for ct=1:nch
      set(L(ct),'XData',xref,'YData',c.ReferenceY(:,ct),'ZData',z)
   end
end


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
Head = {sprintf('Reference signal%s',ChStr)};
str = cat(1,Head,Location);

