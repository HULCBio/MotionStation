function [x,map] = parsebinary(o,f)
%PARSEBINARY Write binary object to disk and display if image.
%   [X,MAP] = PARSEBINARY(O,F) writes the binary object in O to disk
%   in the format specified by F.   If the object is an image, the
%   image is displayed.   This file was released for demonstration
%   purposes only.   Test image data was stored in a MS Access database and
%   read using the MS Access ODBC driver.  Temporary files created by this
%   routine are written to the current working directory.
%
%   Valid file formats are:
%
%   BMP     Bitmap
%   DOC     MS Word document
%   GIF     GIF file
%   PPT     MS Powerpoint file
%   TIF     TIF file
%   XLS     MS Excel spreadsheet

% Copyright 2003 The MathWorks, Inc.

%Transform object into vector of data
v = java.util.Vector;
v.addElement(o);
bdata = v.elementAt(0);

%Open file to write data to disk
fid = fopen(['testfile.' lower(f)],'wb');

%N specifies end point of data written to disk
n = length(bdata);

%File type determines how many bytes of header data ODBC driver prepended
%to data.
switch lower(f)
    
    case 'bmp'
      m = 79;
      
    case 'doc'
      m = 86;
      
    case 'gif'
      m = 5722;
      
    case 'ppt'
      m = 94;
     
    case 'tif'  
      m = 6472;
      
    case 'xls'
      m = 83;
    
    otherwise
      error('Unknown format.')
      
end

%Write data to disk
fwrite(fid,bdata(m:n),'int8');
fclose(fid);

%Display if image
switch lower(f)
   
  case {'bmp','tif','gif'}

    [x,map] = imread(['testfile.' lower(f)]);
    imagesc(x)
    colormap(map)
    
  case {'doc','xls','ppt'}
      
    %MS Office formats  
    %Insert path to MS Word or MS Excel executable here to run from MATLAB prompt.
    %For example,
    %
    %  !d:\msoffice\winword testfile.doc
    
end
