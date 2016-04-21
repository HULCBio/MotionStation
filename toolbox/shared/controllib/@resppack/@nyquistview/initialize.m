function initialize(this,Axes)
%INITIALIZE  Initializes @nyquistview graphics.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:56 $

% Create Nyquist curves and arrows (Axes = HG axes to which curves are plotted)
[ny,nu] = size(Axes);  % Ny-by-Nu
PosCurves = zeros(ny,nu);
NegCurves = zeros(ny,nu);
PosArrows = zeros(ny,nu);
NegArrows = zeros(ny,nu);
for ct=ny*nu:-1:1
   PosCurves(ct) = line('XData', NaN, 'YData', NaN, ...
      'Parent', Axes(ct), 'Visible', 'off');
   NegCurves(ct) = line('XData', NaN, 'YData', NaN, ...
      'Parent', Axes(ct), 'Visible', 'off');
   hasbehavior(NegCurves(ct),'legend',false);
   PosArrows(ct) = patch([NaN NaN NaN],[NaN NaN NaN],'w',...
                    'Parent',Axes(ct),'Visible','off',...
                    'HitTest','off','HandleVisibility','off');
   NegArrows(ct) = patch([NaN NaN NaN],[NaN NaN NaN],'w',...
                    'Parent',Axes(ct),'Visible','off',...
                    'HitTest','off','HandleVisibility','off');
end
this.PosCurves = reshape(handle(PosCurves),[ny nu]);
this.NegCurves = reshape(handle(NegCurves),[ny nu]);
this.PosArrows = reshape(handle(PosArrows),[ny nu]);
this.NegArrows = reshape(handle(NegArrows),[ny nu]);
