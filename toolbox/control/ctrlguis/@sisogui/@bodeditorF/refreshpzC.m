function refreshpzC(Editor,event,varargin)
%REFRESHPZC  Refreshes plot during dynamic edit of C's poles and zeros.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 05:04:06 $

%RE: Do not use persistent variables here (several rleditor's
%    might track gain changes in parallel).

% Nothing to do if closed-loop plot is not shown
if strcmp(Editor.ClosedLoopVisible,'off')
   return
end

% Process events
switch event 
case 'init'
   % Initialization for dynamic gain update (drag).
   PZGroup = varargin{1};     % Modified PZGROUP
   InitPZ = get(PZGroup);
   Editor.RefreshMode = 'quick';
   
   % Compute frequency response of loop components
   S = Editor.LoopData.freqresp(Editor.ClosedLoopFrequency);
   S.F = S.F * getzpkgain(Editor.LoopData.Filter,'mag');
   
   % Install listener on PZGROUP data and store listener reference 
   % in EditModeData property
   L = handle.listener(PZGroup,'PZDataChanged',...
      {@LocalUpdatePlot Editor InitPZ S});
   L.CallbackTarget = PZGroup;
   Editor.EditModeData = L;
   
   
case 'finish'
   % Return editor's RefreshMode to normal
   Editor.RefreshMode = 'normal';
   
   % Delete listener
   delete(Editor.EditModeData);
   Editor.EditModeData = [];
   
end

%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(PZGroup,event,Editor,InitPZ,S)
% Update closed-loop plot

% RE:  * PZGroup: current PZGROUP data
%      * Working units are (rad/sec,abs,deg)
LoopData = Editor.LoopData;

% Update PZ group's contribution to C's frequency response
[MagC, PhaseC] = subspz(Editor, Editor.ClosedLoopFrequency, ...
   abs(S.C), (180/pi)*angle(S.C), InitPZ, PZGroup);
C = MagC .* exp((1i*pi/180)*PhaseC);
C = getzpkgain(LoopData.Compensator,'mag') * C;

% Compute updated closed-loop response
CG = C .* S.G; 
FG = S.F .* S.G;
ReturnDifference = (1 - LoopData.FeedbackSign * CG .* S.H);
switch LoopData.Configuration
case 1
   CL = S.F .* CG ./ ReturnDifference;
case 2
   CL = FG ./ ReturnDifference;
case 3
   CL = (FG + CG) ./ ReturnDifference;
case 4
   CL = CG ./ (ReturnDifference - FG .* S.H);    
end

% Update closed-loop plot
set(Editor.HG.BodePlot(1,2),'Ydata',...
   unitconv(abs(CL),'abs',Editor.Axes.YUnits{1}))
set(Editor.HG.BodePlot(2,2),'Ydata',...
   unitconv(unwrap(angle(CL)),'rad',Editor.Axes.YUnits{2}))
