function str = maketip(this,tip,info)
%MAKETIP  Build data tips for StepPeakRespView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:44 $

r = info.Carrier;
cData = info.Data;
AxGrid = info.View.AxesGrid;

str{1,1} = sprintf('Response: %s',r.Name);
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col); 
if any(AxGrid.Size(1:2)>1) | ShowFlag 
   % Show if MIMO or non trivial 
   str{end+1,1} = iotxt; 
end

YNorm = strcmp(AxGrid.YNormalization,'on');
XDot = tip.Position(1);

if YNorm
   XDot = cData.Time(info.Row,info.Col);
   YDot = cData.PeakResponse(info.Row,info.Col);
   Xauto = strcmp(AxGrid.XlimMode,'auto');
   
   % Parent axes and limits
   ax = info.View.Points(info.Row,info.Col).Parent;
   Xlim = get(ax,'Xlim');
   Ylim = get(ax,'Ylim');
   
   % Adjust dot position based on the X limits
   if Xauto(ceil(info.Col)) & (XDot<Xlim(1) | XDot>Xlim(2) | isnan(XDot))
      XDot = max(Xlim(1),min(Xlim(2),XDot));
      YDot = interp1(cData.Parent.Time,cData.Parent.Amplitude(:,info.Row,info.Col),XDot);
   end
else    
   YDot = tip.Position(2);
end

if XDot < cData.Time(info.Row,info.Col)
   if YDot>=0
      str{end+1,1} = sprintf('Peak amplitude > %0.3g',YDot);
   else
      str{end+1,1} = sprintf('Peak amplitude < %0.3g',YDot);
   end
   str{end+1,1} = sprintf('Overshoot (%s): %0.3g', '%',cData.OverShoot(info.Row,info.Col));
   str{end+1,1} = sprintf('At time (%s) > %0.3g', AxGrid.XUnits, XDot);
else    
   str{end+1,1} = sprintf('Peak amplitude: %0.3g',YDot);
   str{end+1,1} = sprintf('Overshoot (%s): %0.3g', '%',cData.OverShoot(info.Row,info.Col));
   str{end+1,1} = sprintf('At time (%s): %0.3g', AxGrid.XUnits, XDot);
end
