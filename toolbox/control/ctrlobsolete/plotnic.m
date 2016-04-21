function [BigAx,Axes] = plotnic(mag,phase,p,m,PlotToSameAxes)
%PLOTNIC Plots Nichols responses given the plotting data.
%       [BigAx,Axes] = PLOTNIC(MAG,PHASE,P,M,PlotToSameAxes)

%       Author(s): A. Potvin, 11-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:44 $

ni = nargin;
error(nargchk(5,5,ni))
% Check for quick exit
if isempty(mag),
   return
end
PlotToSameAxes = PlotToSameAxes | (p*m==1);

% Nichols set-up.  We want to constrain phase to (-360 0)
[rows,cols] = size(mag);
magdB = 20*log10(mag);
wrap = 360;
cutoff = 200;
phase = rem(phase+360,360)-360;
dp = [zeros(1,cols); diff(phase)];
jumps = (dp>cutoff) | (dp<-cutoff);

% Loop over I/O
NaNmat = NaN;
OnesMat = ones(rows+3*max(sum(jumps)),cols);
Pmat = NaNmat(OnesMat);
Gmat = NaNmat(OnesMat);
% REVISIT: May be able to vectorize this
for i=1:cols,
   % Form data for Nichols curve
   Phase = [];
   Gain = [];
   ind = 1;
   for JumpInd=(find(jumps(:,i)))',
      % At each jump point, add three points
      %  - the next point off the chart
      %  - a NaN
      %  - the previous point
      NewPts = phase([JumpInd-1 JumpInd],i) +[wrap; -wrap]*(phase(JumpInd,i)>wrap/2);
      Phase = [Phase; phase(ind:JumpInd-1,i); NewPts(1); NaN; NewPts(2)];      
      Gain = [Gain; magdB(ind:JumpInd,i); NaN; magdB(JumpInd,i)];
      ind = JumpInd;      
   end
   Phase = [Phase; phase(ind:rows,i)];
   Gain = [Gain; magdB(ind:rows,i)];
   l = length(Phase);
   Pmat(1:l,i) = Phase;
   Gmat(1:l,i) = Gain;
end

% Plot Nichols chart which always shows Phase from (-360,0)
if PlotToSameAxes,
   h = plot(Pmat,Gmat);
   Axes = get(h(1),'Parent');
   BigAx = Axes;
   AllAxes = Axes;
   title('Nichols plot')
else
   [h,Axes,BigAx] = miniplot(p,m,Pmat,Gmat);
   set(BigAx,'Box','on')
   AllAxes = [BigAx; Axes];
   title('Nichols plots for outputs (rows) vs inputs (columns)')
end
set(AllAxes,'XLim',[-360 0],'XTick',[-360 -270 -180 -90 0])

% Make labels
xlabel('Open Loop Phase (deg)')
ylabel('Open Loop Gain (dB)')

% end plotnic
