function redrawpz(Editor,PZGroup,PZView,W0)
%REDRAWPZ  Refreshes edited Bode plot during move pole/zero.
%
%   EDITOR.REDRAWPZ(PZGroup,PZView,W0) refreshes the Bode plot 
%   associated with the moved poles and zeros (equivalently, EDITOR's
%   edited object). The @pzgroup instance PZGROUP specifes the new 
%   pole/zero locations and the vector W0 contains the frequencies 
%   of the new poles and zeros.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 04:56:41 $

HG = Editor.HG;

% Conversion factor
FreqConvert = unitconv(1,'rad/sec',Editor.Axes.XUnits);

% Update primary plot
Gain = getzpkgain(Editor.EditedObject,'mag');
MagData = unitconv(Gain*Editor.Magnitude,'abs',Editor.Axes.YUnits{1});
Zdata = Editor.zlevel('curve',[length(Editor.Frequency) 1]);
set(HG.BodePlot(1),'Xdata',FreqConvert*Editor.Frequency,'Ydata',MagData,'Zdata',Zdata)
PhaseData = unitconv(Editor.Phase,'deg',Editor.Axes.YUnits{2});
set(HG.BodePlot(2),'Xdata',FreqConvert*Editor.Frequency,'Ydata',PhaseData,'Zdata',Zdata)

% Update X location of moved roots
W0 = FreqConvert * W0;
PZMag = [PZView(1).Zero;PZView(1).Pole];
PZPhase = [PZView(2).Zero;PZView(2).Pole];
for ct=1:length(W0)
	set([PZMag(ct),PZPhase(ct)],'Xdata',W0(ct))
end

% Update location of notch width markers
if strcmp(PZGroup.Type,'Notch')
   Wm = FreqConvert*notchwidth(PZGroup,Editor.LoopData.Ts);
   % Markers
   Extras = get(PZView(1),'Extra');
   set(Extras(1),'Xdata',Wm(1))
   set(Extras(2),'Xdata',Wm(2))
   % Rulers
   Rulers = get(PZView(1),'Ruler');
   if ~isempty(Rulers)
      set(Rulers(1),'Xdata',Wm([1 1],:))
      set(Rulers(2),'Xdata',Wm([2 2],:));
   end
end

% Interpolate Y values
Editor.interpy(MagData,PhaseData);