function rinfo = hdfraster8info(filename,imid,anID)
%HDFRASTER8INFO Information about HDF 8-bit Raster image
%
%   RINFO=RASTER8INFO(FILENAME,IMID) returns a structure whose fields contain
%   information about an 8-bit raster image in an HDF file.  FILENAME
%   is a string that specifies the name of the HDF file.  IMID is a string
%   specifying the name of the raster image or a number specifying the
%   image's reference number.  
%
%   The fields of RINFO are:
%
%   Filename       A string containing the name of the file
%
%   Name           A string containing the name of the image
%
%   Width          An integer indicating the width of the image
%                  in pixels
%
%   Height         An integer indicating the height of the image
%                  in pixels
%
%   HasPalette     1 if the image has an associated palette, 0 otherwise
%
%   Ref            Reference number of the raster image
%
%   Label          A cell array containing an Annotation label
%
%   Description    A cell array containing an Annotation description
%  
%   Type           A string describing the type of HDF object 
%

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:13 $

%Check input arguments
error(nargchk(3, 3, nargin, 'struct'));

if ~ischar(filename)
  error('MATLAB:hdfraster8info:badFilename', ...
        'FILENAME must be a string.');
end

if ~hdfh('ishdf',filename)
  error('MATLAB:hdfraster8info:invalidHDF', ...
        'Invalid HDF file.');
end

if ~isnumeric(imid)
  error('MATLAB:hdfraster8info:badREF', ...
        'REF must be a number.');
end

% Chose RIG because the annotations seemed to be linked to this tag.  The
% raster images could be described with all tags, even obsolete ones.
tag =hdfml('tagnum','DFTAG_RIG');

status = hdfdfr8('readref',filename,imid);
if status == -1

  warning('MATLAB:hdfraster8info:readref', ...
          'Unable to read image.  The image may not exist or the file may be corrupt.');
  rinfo = [];

else
  [width, height, hasMap, status] = hdfdfr8('getdims',filename);
  hdfwarn(status);

  %Get annotations
  [label,desc] = hdfannotationinfo(anID,tag,imid);
  
  % Use reference number to name the image: "8-bit Raster Image #refnum".
  % Other browsers use the first data label as the name if it exists. 
  
  name = sprintf('8-bit Raster Image #%d', imid);
  
  %Populate output structure
  rinfo.Filename = filename;
  rinfo.Name = name;
  rinfo.Ref = imid;
  rinfo.Width = width;
  rinfo.Height = height;
  rinfo.HasPalette = hasMap;
  rinfo.Label = label;
  rinfo.Description = desc;
  rinfo.Type = '8-Bit Raster Image';
end
return;


