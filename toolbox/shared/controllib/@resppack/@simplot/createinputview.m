function [data, view] = createinputview(this, Nu)
%CREATEINPUTVIEW  Creates data/view for input signal.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:52 $
if strcmp(this.InputStyle,'tiled')
   % Tiled display
   for ct = Nu:-1:1
      % Create @respdata objects
      data(ct,1) = resppack.siminputdata;
      % Create @respview objects
      view(ct,1) = resppack.siminputviewTiled;
   end
else
   % Input/output pairing (e.g., ref -> y)
   data = wavepack.timedata;
   view = resppack.siminputviewPaired;
end
set(view,'AxesGrid',this.AxesGrid)