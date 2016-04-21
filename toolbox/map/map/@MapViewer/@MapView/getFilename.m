function filename = getFilename(this)
%GETFILENAME Standard MapView import from file dialog.
%
%   FILENAME = getFileName is the standard user interface for choosing a file
%   for MapView.  If the dialog is cancelled, FILENAME is an empty string.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:56:58 $

if isempty(this.CurrentPath)
  d = [pwd filesep];
else
  d = [this.CurrentPath filesep];
end

% $$$ fmts = {'*.tif;*.jpg;*.shp;*.grd;*.ddf'};
% $$$ ufmts = upper(fmts);
% $$$ [f, p] = uigetfile({[ufmts{:},';',fmts{:}]},'Import Data',d);
[f, p] = uigetfile({'*.tif;*.TIF;*.tiff;*.TIFF','TIFF Files (*.tif)';...
                    '*.png;*.PNG','PNG Files (*.png)';...
                    '*.jpg;*.JPG','JPEG Files (*.jpg)';...
                    '*.shp;*.SHP','SHP Files (*.shp)';...
                    '*.grd;*.GRD','GRD Files (*.grd)';...
                    '*.ddf;*.DDF','DDF Files (*.ddf)'},'Import Data',d);

if isequal(f,0) | isequal(p,0)
  filename = '';
else
  filename = fullfile(p,f);
end
