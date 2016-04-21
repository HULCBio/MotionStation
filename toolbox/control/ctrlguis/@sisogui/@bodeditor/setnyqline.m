function setnyqline(Editor,NyqFreq)
%SETNYQLINE  Positions Nyquist line in Bode Diagrams.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $ $Date: 2002/04/10 04:57:10 $

HG = Editor.HG;
if isfinite(NyqFreq)
   % Mag line
   % RE: Update Y data to track abs vs. dB
   Zlevel = Editor.zlevel('backgroundline');
   YData = unitconv(infline(0,Inf),'abs',Editor.Axes.YUnits{1});
   npts = length(YData);
   set(HG.NyquistLine(1),'Xdata',NyqFreq(:,ones(1,npts)),...
      'YData', YData, 'ZData', Zlevel(:,ones(1,npts)))
   % Phase line
   npts = length(get(HG.NyquistLine(2),'YData'));
   set(HG.NyquistLine(2),'Xdata',NyqFreq(:,ones(1,npts)),'Visible','on')
else
   set(HG.NyquistLine(1),'XData',[],'YData',[],'ZData',[])
   set(HG.NyquistLine(2),'Visible','off')
end
