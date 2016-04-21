function rs = webpeaks(h)
%WEBPEAKS sample application of surf peaks.
% RS = WEBPEAKS(H) creates a surf peaks plot and
% returns HTML output in string RS.  Handle H is the
% structure created by matweb.  It contains variables
% from the HTML input form in peaksplot.html.
%

%   Author(s): Y. Habibzai 01-01-98
%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.12 $   $Date: 2001/04/25 18:49:30 $

% Get unique identifier (to form file name)
mlid = getfield(h, 'mlid');

% Set directory path for storage of graphic files.
cd(h.mldir);

% Cleanup jpegs older than 1 hour.
wscleanup('ml*peaks.jpeg', 1);

% Get the colors.
rcolor = str2double(h.red);
gcolor = str2double(h.green);
bcolor = str2double(h.blue);

% Get perspective.
azimuth = str2double(h.AZ);
elevation = str2double(h.EL);
 
% Get the shading value
if (isfield(h, 'shading'))
   shdng = getfield(h, 'shading');
   if strcmp(shdng, 'Interpolated');  
      shdng = 'interp';
   end
end
 
% Create the graphic.
f = figure('visible','off');
z = peaks;
surf(z);
pos = get(gcf, 'position');
pos(3) = 380;
pos(4) = 310;

l = light('color', [rcolor gcolor bcolor]);
shading(lower(shdng));
lighting phong;
set(gcf, 'Position', pos, 'PaperPosition', [.25 .25 4 3]);
view(azimuth, elevation);

%Render jpeg and write to file.
drawnow;
s.GraphFileName = sprintf('%speaks.jpeg', mlid);
wsprintjpeg(f, s.GraphFileName);
s.GraphFileName = sprintf('/icons/%speaks.jpeg', mlid);
close all;

% Put name of graphic file into HTML template file.
templatefile = which('webpeaks2.html');
rs = htmlrep(s, templatefile);
     


