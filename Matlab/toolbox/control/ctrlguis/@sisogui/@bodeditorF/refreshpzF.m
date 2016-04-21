function refreshpzF(Editor,event,varargin)
%REFRESHPZF  Refreshes plot during dynamic edit of F's poles and zeros.

%   Author(s): P. Gahinet
%   Revised:   N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/10 05:04:08 $

%RE: Do not use persistent variables here (several bodeditorF's
%    could track gain changes in parallel).

% Process events
switch event 
case 'init'
   % Initialization for dynamic gain update (drag).
   PZGroup = varargin{1};     % Modified PZGROUP
   
   % Find related PZVIEW objects
   ig = find(Editor.EditedObject.PZGroup==PZGroup); 
   PZView = Editor.EditedPZ(ig,:);
   
   % Switch editor's RefreshMode to quick
   Editor.RefreshMode = 'quick';
   
   % Save initial data (units = rad/sec,abs,deg)
   InitData = struct(...
      'PZGroup',get(PZGroup),...
      'Frequency',Editor.Frequency,...
      'Magnitude',Editor.Magnitude,...
      'Phase',Editor.Phase);
   
   % Configuration-specific optimizations
   LoopData = Editor.LoopData;
   if strcmp(Editor.ClosedLoopVisible,'on') & ...
         any(LoopData.Configuration==[3 4])
      % Precompute frequency response to speed up closed loop update
      S = freqresp(LoopData,Editor.ClosedLoopFrequency);
      S.C = S.C * getzpkgain(LoopData.Compensator,'mag');
   else 
      S = [];
   end
  
   % Install listener on PZGROUP data and store listener reference 
   % in EditModeData property
   L = handle.listener(PZGroup,'PZDataChanged',...
      {@LocalUpdatePlot Editor InitData PZView S});
   L.CallbackTarget = PZGroup;
   Editor.EditModeData = L;
   
case 'finish'
   % Clean up after dynamic gain update (drag)
   % Return editor's RefreshMode to normal
   Editor.RefreshMode = 'normal';
   
   % Delete gain listener
   delete(Editor.EditModeData);
   Editor.EditModeData = [];
   
end


%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(PZGroup,event,Editor,InitData,PZView,S)
% Update plot

% RE:  * PZGroup: current PZGROUP data
%      * Working units are (rad/sec,abs,deg)
LoopData = Editor.LoopData;
Ts = LoopData.Ts;

% Natural and peaking frequencies for new pole/zero locations (in rad/sec)
[W0,Zeta] = damp([PZGroup.Zero;PZGroup.Pole],Ts);
if Ts,
   % Keep root freq. below Nyquist freq.
   W0 = min(W0,pi/Ts);
end
t = W0.^2 .* (1 - 2 * Zeta.^2);
Wpeak = sqrt(t(t>0,:));

% Update filter mag and phase data
% RE: Update editor properties (used by INTERPY)
[Editor.Frequency,Editor.Magnitude,Editor.Phase] = ...
   LocalUpdateData(Editor,InitData.Frequency,InitData.Magnitude,InitData.Phase,...
   InitData.PZGroup,PZGroup,[Wpeak;W0]);

% Update the filter plot
Editor.redrawpz(PZGroup,PZView,W0);

% Update closed-loop plot
if strcmp(Editor.ClosedLoopVisible,'on')   
   GainF = getzpkgain(Editor.EditedObject,'mag');
   switch LoopData.Configuration      
   case {1,2}
      % A pre-filter setup is being used so a lightweight update calculation is possible   REVISIT
      [W,Mag,Phase] = LocalUpdateData(Editor,Editor.ClosedLoopFrequency,...
         Editor.ClosedLoopMagnitude,Editor.ClosedLoopPhase,...
         InitData.PZGroup,PZGroup,[Wpeak;W0]);
      CLMag   = unitconv(GainF*Mag,'abs',Editor.Axes.YUnits{1});
      CLPhase = unitconv(Phase,'deg',Editor.Axes.YUnits{2});
      
   case {3,4}
      % Update PZ group's contribution to F's frequency response
      W = Editor.ClosedLoopFrequency;
      [MagF, PhaseF] = subspz(Editor, W, ...
         abs(S.F), (180/pi)*angle(S.F), InitData.PZGroup, PZGroup);
      F = GainF * MagF .* exp((1i*pi/180)*PhaseF);

      % Compute updated closed-loop response
      CG = S.C .* S.G; 
      FG = F .* S.G;
      ReturnDifference = (1 - LoopData.FeedbackSign * CG .* S.H);
      switch LoopData.Configuration
      case 3
         CL = (FG + CG) ./ ReturnDifference;
      case 4
         CL = CG ./ (ReturnDifference - FG .* S.H);            
      end
      
      CLMag   = unitconv(abs(CL),'abs',Editor.Axes.YUnits{1});
      CLPhase = unitconv(unwrap(angle(CL)),'rad',Editor.Axes.YUnits{2});
   end
   
   % Update line data
   FreqCL = unitconv(W,'rad/sec',Editor.Axes.XUnits);
   Zdata = Editor.zlevel('curve',[length(FreqCL) 1]);
   set(Editor.HG.BodePlot(1,2),'Xdata',FreqCL,'Ydata',CLMag,'Zdata',Zdata);
   set(Editor.HG.BodePlot(2,2),'Xdata',FreqCL,'Ydata',CLPhase,'Zdata',Zdata)
end


%%%%%%%%%%%%%%%%%%%
% LocalUpdateData %
%%%%%%%%%%%%%%%%%%%
function [w,mag,phase] = LocalUpdateData(Editor,w,mag,phase,PZold,PZnew,wpz)
% Updates mag and phase data by applying multiplicative correction for moved PZ group

mag = [mag ; Editor.interpmag(w,mag,wpz)];
phase = [phase ; interp1(w,phase,wpz)];
[w,iu] = LocalUniqueWithinTol([w;wpz],1e3*eps);  % sort + unique

% REVISIT
[mag,phase] = subspz(Editor, w,mag(iu),phase(iu),PZold,PZnew);


%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUniqueWithinTol %
%%%%%%%%%%%%%%%%%%%%%%%%
function [w,iu] = LocalUniqueWithinTol(w,rtol)
% Eliminates duplicates within RTOL (relative tolerance)
% Helps prevent reintroducing duplicates during unit conversions

% Sort W
[w,iu] = sort(w);

% Eliminate duplicates
lw = length(w);
dupes = find(w(2:lw)-w(1:lw-1)<=rtol*w(2:lw));
w(dupes,:) = [];
iu(dupes,:) = [];
