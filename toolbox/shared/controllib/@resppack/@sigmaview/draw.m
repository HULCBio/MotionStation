function draw(this, Data,NormalRefresh)
%DRAW  Draw method for the @sigmaview class (Singular Value Plots).

%  Author(s): Kamesh Subbarao, Pascal Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:25 $

%  Frequency:   Nf x 1
%  Singular Values: Nf x Ns

AxGrid = this.AxesGrid;

% Adjust number of SV curves
Ns = size(Data.SingularValues,2);
Nline = length(this.Curves);
if Ns>Nline
   % Add missing lines
   Curves = this.Curves;
   NyqLines = this.NyquistLines;
   for ct=Ns:-1:Nline+1
      ax = Curves(1).Parent;
      Curves(ct,1) = handle(copyobj(double(Curves(1)),ax));
      NyqLines(ct,1) = handle(copyobj(double(NyqLines(1)),ax));
   end
   this.Curves = Curves;
   this.NyquistLines = NyqLines;
end
   
if Data.Ts
   nf = unitconv(pi/abs(Data.Ts),'rad/sec',AxGrid.XUnits);
else
   nf = NaN;
end
Freq = unitconv(Data.Frequency,Data.FreqUnits,AxGrid.XUnits);
SV = unitconv(Data.SingularValues,Data.MagUnits,AxGrid.YUnits);

% Eliminate zero frequencies in log scale
if strcmp(AxGrid.Xscale,'log')
   idxf = find(Freq>0);
   Freq = Freq(idxf);
   SV = SV(idxf,:);
end

% Map data to curves
for ct=1:Ns
   % REVISIT: remove conversion to double (UDD bug where XOR mode ignored)
   set(double(this.Curves(ct)), 'XData', Freq, 'YData', SV(:,ct));
end   
set(this.Curves(Ns+1:end),'XData',[],'YData',[])

% Nyquist lines (invisible to limit picker)
YData = unitconv(infline(0,Inf),'abs',AxGrid.YUnits);
XData = nf(:,ones(size(YData)));
set(this.NyquistLines(1:Ns),'XData',XData,'YData',YData)  
set(this.NyquistLines(Ns+1:end),'XData',[],'YData',[])