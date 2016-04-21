function update(Editor,varargin)
%UPDATE  Updates Root Locus Editor and regenerates plot.

%   Authors: P. Gahinet and K. Gondoly
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.45 $  $Date: 2002/05/11 17:35:41 $

if strcmp(Editor.EditMode,'off') | strcmp(Editor.Visible,'off')
    % Editor is inactive
    return
end

%%%%%%%%%%%%%%%%%%%%
% Update Locus Data
%%%%%%%%%%%%%%%%%%%%

% Get normalized open-loop and loop gain
% RE: zpk gain of C replaced by its sign in normalized open-loop
NormOpenLoop = getopenloop(Editor.LoopData);
Editor.SingularLoop = (~isfinite(NormOpenLoop));
if Editor.SingularLoop
   % Open loop is not defined, e.g., when minor loop cannot be closed in config 4
   clear(Editor),  return
end
GainMag = getzpkgain(Editor.EditedObject,'mag');

% Compute root locus for normalized open-loop model and current closed-loop poles 
[Roots,Gains] = rlocus(NormOpenLoop);
CLpoles = fastrloc(NormOpenLoop,GainMag);

% Make sure the locus extends beyond the current CL poles, and that 
% the locus goes through the red squares
[NewGain,RefRoot] = extendlocus(Gains,Roots,GainMag);
if ~isempty(NewGain)
   % Extend locus
   NewRoot = matchlsq(RefRoot,fastrloc(NormOpenLoop,NewGain));
   Roots = [NewRoot,Roots];
   [Gains,is] = sort([NewGain,Gains]);
   Roots = Roots(:,is);
elseif length(Gains) & ~any(Gains==GainMag)
   % Insert current gain in locus data 
   idx = find(Gains>GainMag);
   Gains = [Gains(:,1:idx(1)-1) , GainMag , Gains(:,idx(1):end)];
   Roots = [Roots(:,1:idx(1)-1) , ...
         matchlsq(Roots(:,idx(1)-1),CLpoles) , Roots(:,idx(1):end)];
end

% Update locus data 
Editor.LocusRoots = Roots;
Editor.LocusGains = Gains;
Editor.ClosedPoles = CLpoles;  % triggers update of optimal X/Y lims


%%%%%%%%%%%%%%%%%%%%
% Render Locus Data
%%%%%%%%%%%%%%%%%%%%
LoopData = Editor.LoopData;
PlotAxes = getaxes(Editor.Axes);
HG = Editor.HG;
Style = Editor.LineStyle;
UIC = get(PlotAxes,'uicontextmenu'); % axis ctx menu

% Clear existing plot 
clear(Editor);

% Plot the fixed poles and zeros (plant+sensor)  (Z level = 2)
[FixedZeros, FixedPoles] = fixedpz(LoopData);
nz = length(FixedZeros);
np = length(FixedPoles);
HG.System = zeros(nz+np,1);
Zlevel = Editor.zlevel('system');
for ct=1:nz
   HG.System(ct) = line(real(FixedZeros(ct)),imag(FixedZeros(ct)),Zlevel,...
      'XlimInclude','off','YlimInclude','off',...
      'LineStyle','none','Marker','o','MarkerSize',5,'Color',Style.Color.System,...
      'Parent',PlotAxes,'UIContextMenu',UIC,...
      'ButtonDownFcn',{@LocalShowData Editor},...
      'HelpTopicKey','sisosystempolezero');
end % for ct
for ct=1:np,
   HG.System(nz+ct) = line(real(FixedPoles(ct)),imag(FixedPoles(ct)),Zlevel,...
      'XlimInclude','off','YlimInclude','off',...
      'LineStyle','none','Marker','x','MarkerSize',6,'Color',Style.Color.System,...
      'Parent',PlotAxes,'UIContextMenu',UIC,...
      'ButtonDownFcn',{@LocalShowData Editor},...
      'HelpTopicKey','sisosystempolezero');
end % for ct

%---Plot the root locus
HG.Locus = zeros(0,1);
HG.ClosedLoop = zeros(0,1); % needed because vector shrinks -> stale handles
if ~isempty(Gains)
   [Nline,Nroot] = size(Roots);
   for ct=Nline:-1:1
      HG.Locus(ct,1) = line(real(Roots(ct,:)),imag(Roots(ct,:)),...
         Editor.zlevel('curve',[1 Nroot]),...
         'XlimInclude','off',...
         'YlimInclude','off',...
         'Parent',PlotAxes, ...
         'UIContextMenu',UIC,...
         'ButtonDownFcn',{@LocalSelectGain Editor},...
         'HelpTopicKey','sisorootlocusplot',...
         'Color',Style.Color.Response); 
   end
   
   %---Plot the movable closed-loop poles
   Zlevel = Editor.zlevel('clpole');
   for ct=length(CLpoles):-1:1,
      HG.ClosedLoop(ct,1) = ...
         line(real(CLpoles(ct)),imag(CLpoles(ct)),Zlevel,...
         'Parent',PlotAxes, ...
         'LineStyle','none',...
         'Marker',Style.Marker.ClosedLoop,...
         'MarkerSize',5,...
         'MarkerFaceColor',Style.Color.ClosedLoop, ...
         'MarkerEdgeColor',Style.Color.ClosedLoop,...
         'HelpTopicKey','closedlooppoles',...
         'ButtonDownFcn',{@LocalMoveGain Editor 'init'});  
   end 
   % Always include origin to prevent o(eps) x-range
   set(HG.Origin,'XData',[0 0 0 0],'YData',[0 0 0 0])
else
   % Draw rectangle around origin to avoid [0 1],[0 1] limits
   set(HG.Origin,'XData',[-1 -1 1 1],'YData',[-1 1 -1 1])
end

% Update HG database
Editor.HG = HG;

% Update root locus extent as seen by limit picker
% REVISIT: Simply update XlimIncludeData
[XFocus,YFocus] = rloclims(Editor.LocusRoots,Editor.LoopData.Ts);
re = real(Roots(:));
im = imag(Roots(:));
InFocus = find(re>=XFocus(1) & re<=XFocus(2) & im>=YFocus(1) & im<=YFocus(2));
set(HG.LocusShadow,...
   'XData',re(InFocus),'YData',im(InFocus),'ZData',zeros(size(InFocus)))

% Plot the compensator poles and zeros
plotcomp(Editor);

% Update axis limits
updateview(Editor)


%-------------------------Callback Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSelectGain %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalSelectGain(hLine,event,Editor)
% Update gain by clicking on the locus
if ~strcmp(Editor.EditMode,'idle')
    % Redirect to editor axes
    Editor.mouseevent('bd',get(hLine,'parent'));
elseif strcmp(get(gcbf,'SelectionType'),'normal')
    selectgain(Editor);
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalShowData %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalShowData(hSrc,event,Editor)
% Show system data
if ~strcmp(Editor.EditMode,'idle')
    % Redirect to editor axes
    Editor.mouseevent('bd',get(hSrc,'parent'));
elseif strcmp(get(gcbf,'SelectionType'),'open')
    Editor.root.send('ShowData');  % notify parent of open request
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalMoveGain %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalMoveGain(hSrc,event,Editor,action)
% Callback for button down on closed-loop poles
% REVISIT: merge with trackgain when directed callback are available
persistent SISOfig WBMU

switch action
case 'init'
    % Initialize move
    SISOfig = gcbf;
    if ~strcmp(Editor.EditMode,'idle')
        % Redirect to editor axes
        Editor.mouseevent('bd',get(hSrc,'parent'));
    elseif strcmp(get(SISOfig,'SelectionType'),'normal')
        % Change pointer
        setptr(SISOfig,'closedhand')
        % Take over window mouse events
        WBMU = get(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
        set(SISOfig,'WindowButtonMotionFcn',{@LocalMoveGain Editor 'acquire'},...
            'WindowButtonUpFcn',{@LocalMoveGain Editor 'finish'});
        % Initialize tracking algorithm and notify peers
        Editor.trackgain('init');
    end
case 'acquire'
    % Track mouse location (move)
    Editor.trackgain('acquire');
case 'finish'
    % Restore initial conditions
    set(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},WBMU,'Pointer','arrow')
    % Clean up and update
    Editor.trackgain('finish');
end
