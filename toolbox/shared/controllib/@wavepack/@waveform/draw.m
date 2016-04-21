function draw(this,varargin)
%DRAW  (Re)draws @waveform object.
%
%  DRAW(WF) draws the waveform WF and all its dependencies.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:09 $

% RE: first argument = NoCheckFlag
if nargin==1 && ~isvisible(this) % for speed
   return
end
RespPlot = this.Parent;
NormalRefresh = strcmp(this.RefreshMode,'normal');

% Update the response data
if ~isempty(this.DataFcn)
   % RE: For optimal performance, DataFcn should only recompute 
   %     MIMO responses that are visible and have been cleared. 
   feval(this.DataFcn{:});
end

% Set data exception boolean to flag invalid data
for ct=1:length(this.Data)
   this.Data(ct).Exception = ~(this.checksize(this.Data(ct)));
end

% Draw response curves 
VisibleView = strcmp(get(this.View, 'Visible'), 'on');
for ct = find(VisibleView)'
   if this.Data(ct).Exception
      % Invalid data: clear graphics
      set(double(ghandles(this.View(ct))),'XData',[],'YData',[],'ZData',[])
   else
      % Valid data: proceed with draw
      this.View(ct).draw(this.Data(ct),NormalRefresh)
   end
end

% Draw characteristics objects
if ~isempty(this.Characteristics)
   for c=find(this.Characteristics,'Visible','on')'
      draw(c,varargin{:})
   end
end

% Limit management
if NormalRefresh
   % Issue ViewChanged event to trigger limit picker
   % RE: Ignored when @axesgrid's LimitManager is off, e.g., during @waveplot/draw
   RespPlot.AxesGrid.send('ViewChanged')
   if ~isempty(find(this.Data,'Exception',true)) && ...
         strcmp(RespPlot.DataExceptionWarning,'on')
      warning('Some data is missing or cannot be plotted due to size mismatch.')
   end
else
   % Redraw g-objects whose updating is normally tied to the 'PostLimitChanged' event
   adjustview(this,'postlim')
   %    if strcmp(RespPlot.AxesGrid.YNormalization,'on')
   %       % Normalize Y data
   %       adjustview(this,'postlim')
   %    else
   %       % Fast limit update (just keeping y data in range)
   %       % REVISIT: HG is too slow to do this!
   %       RespPlot.yframe(this)
   %    end
end
