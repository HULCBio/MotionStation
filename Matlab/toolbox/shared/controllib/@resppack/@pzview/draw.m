function draw(this, Data,NormalRefresh)
%  DRAW  Draw method for the @pzview class to generate the response curves.

%  Author(s): John Glass, Bora Eryilmaz, Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:16 $

% Recompute the curves
for ct = 1:prod(size(Data.Poles))
   set(double(this.PoleCurves(ct)), 'XData', real(Data.Poles{ct}), ...
      'YData', imag(Data.Poles{ct}));
   set(double(this.ZeroCurves(ct)), 'XData', real(Data.Zeros{ct}), ...
      'YData', imag(Data.Zeros{ct}));
end
