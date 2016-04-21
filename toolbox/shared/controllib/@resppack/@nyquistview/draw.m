function draw(this, Data,NormalRefresh)
%DRAW  Draws Nyquist response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:53 $

[Ny, Nu] = size(this.PosCurves);
for ct = 1:Ny*Nu
   % REVISIT: remove conversion to double (UDD bug where XOR mode ignored)
   H = Data.Response(:,ct);
   set(double(this.PosCurves(ct)), 'XData', real(H), 'YData', imag(H));
   if this.ShowFullContour
      % REVISIT: incorrect for complex systems!
      set(double(this.NegCurves(ct)), 'XData', real(H), 'YData', -imag(H));
   else
      set(double(this.NegCurves(ct)), 'XData',[],'YData',[])
   end
end
set(double([this.PosArrows,this.NegArrows]),'XData',[],'YData',[])  % for quick refresh 
