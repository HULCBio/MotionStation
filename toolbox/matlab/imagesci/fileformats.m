% Readable file formats.
%
%  Data formats                     Command    Returns
%   MAT  - MATLAB workspace         load       Variables in file.
%   CSV  - Comma separated numbers  csvread    Double array.
%   DAT  - Formatted text           importdata Double array.
%   DLM  - Delimited text           dlmread    Double array.
%   TAB  - Tab separated text       dlmread    Double array.
%
%  Spreadsheet formats
%   XLS  - Excel worksheet          xlsread    Double array and cell array.
%   WK1  - Lotus 123 worksheet      wk1read    Double array and cell array.
%
%  Scientific data formats
%   CDF  - Common Data Format               cdfread    Cell array of CDF records
%   FITS - Flexible Image Transport System  fitsread   Primary or extension table data
%   HDF  - Hierarchical Data Format         hdfread    HDF or HDF-EOS data set
%
%  Movie formats
%   AVI  - Movie                    aviread    MATLAB movie.
%
%  Image formats
%   TIFF - TIFF image               imread     Truecolor, grayscale or indexed image(s).
%   PNG  - PNG image                imread     Truecolor, grayscale or indexed image.
%   HDF  - HDF image                imread     Truecolor or indexed image(s).
%   BMP  - BMP image                imread     Truecolor or indexed image.
%   JPEG - JPEG image               imread     Truecolor or grayscale image.
%   GIF  - GIF image                imread     Indexed image.
%   PCX  - PCX image                imread     Indexed image.
%   XWD  - XWD image                imread     Indexed image.
%   CUR  - Cursor image             imread     Indexed image.
%   ICO  - Icon image               imread     Indexed image.
%   RAS  - Sun raster image         imread     Truecolor or indexed.
%   PBM  - PBM image                imread     Grayscale image.
%   PGM  - PGM image                imread     Grayscale image.
%   PPM  - PPM image                imread     Truecolor image.
% 
%  Audio formats
%   AU   - NeXT/Sun sound           auread     Sound data and sample rate.
%   SND  - NeXT/Sun sound           auread     Sound data and sample rate.
%   WAV  - Microsoft Wave sound     wavread    Sound data and sample rate.
%
% See also IOFUN

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/12/13 02:58:01 $ 
