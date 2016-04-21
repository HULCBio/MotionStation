function draw(this, Data,NormalRefresh)
%DRAW  Draws root locus.
%
%  DRAW(VIEW,DATA) maps the data in DATA to the root locus in VIEW.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:03 $

% System dynamics
this.SystemZero.XData = real(Data.SystemZero);
this.SystemZero.YData = imag(Data.SystemZero);
this.SystemPole.XData = real(Data.SystemPole);
this.SystemPole.YData = imag(Data.SystemPole);

% Adjust number of locus curves
Nbranch = size(Data.Roots,2);
Nline = length(this.Locus);
if Nbranch>Nline
   % Add missing lines
   Locus = this.Locus;
   for ct=Nbranch:-1:Nline+1
      Locus(ct,1) = handle(copyobj(double(Locus(1)),Locus(1).Parent));
   end
   this.Locus = Locus;
end

% Set line data
for ct=1:Nbranch
   set(this.Locus(ct),'XData',real(Data.Roots(:,ct)),'YData',imag(Data.Roots(:,ct)))
end
set(this.Locus(Nbranch+1:end),'XData',NaN,'YData',NaN)

% Branch coloring option
Ncolors = length(this.BranchColorList);
if Ncolors>0
   idx = 1+rem(0:Nbranch-1,Ncolors);
   for ct=1:Nbranch
      set(this.Locus(ct),'Color',this.BranchColorList{idx(ct)})
   end
end
