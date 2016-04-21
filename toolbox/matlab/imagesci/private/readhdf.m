function [X,map] = readhdf(filename, ref)
%READHDF Read an image from an HDF file.
%   [X,MAP] = READHDF(FILENAME) reads the first raster image data
%   set from the HDF file FILENAME.  X will be a 2-D uint8 array
%   if the specified data set contains an 8-bit image.  It will
%   be an M-by-N-by-3 uint8 array if the specified data set
%   contains a 24-bit image.  MAP may be empty if the data set
%   does not have an associated colormap.
%
%   ... = READHDF(FILENAME, 'Reference', ref) reads the raster
%   image data set with the specified reference number.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:46 $

info = imhdfinfo(filename);

if (nargin < 2)
    idx = 1;   % ref not specified, so get the first one.
else
    refNums = [info.Reference];            % comma-separated list syntax
    idx = find(ref == refNums);
    if (isempty(idx))
        error('MATLAB:readhdf:noRasterAtReference', ...
              'No raster image found with the specified reference number');
    end
    idx = idx(1);
end

ref = info(idx).Reference;
ncomp = info(idx).NumComponents;
il = info(idx).Interlace;

FAIL = -1;

if (ncomp == 1)
    hdf('DFR8', 'restart');

    status = hdf('DFR8', 'readref', filename, ref);
    if (status == FAIL)
        error('MATLAB:readhdf:readref', hdferror);
    end
    
    [X, map, status] = hdf('DFR8', 'getimage', filename);
    if (status == FAIL)
        error('MATLAB:readhdf:getimage', hdferror);
    end
    
    X = X';  % HDF uses C-style dimension ordering
    map = double(map')/255;
    
elseif (ncomp == 3)
    hdf('DF24', 'restart');
    
    %
    % The following line is a work-around for the fact that
    % DF24restart apparently does not reset the reqil.
    % Also, reqil of other than 'pixel' doesn't appear
    % to supported in HDF v4r1.
    %
    status = hdf('DF24', 'reqil', 'pixel');
    if (status == FAIL)
        error('MATLAB:readhdf:reqil', hdferror);
    end
    
    status = hdf('DF24', 'readref', filename, ref);
    if (status == FAIL)
        error('MATLAB:readhdf:readref', hdferror);
    end
    
    [X, status] = hdf('DF24', 'getimage', filename);
    if (status == FAIL)
        error('MATLAB:readhdf:getimage', hdferror);
    end
    
    % Compensate for file's interlace and the fact that
    % HDF uses C-style dimension ordering
    switch il
    case 'pixel'
        X = permute(X,[3 2 1]);  % HDF uses C-style dimension ordering
        
    case 'line'
        X = permute(X,[3 1 2]);
        
    case 'component'
        X = permute(X,[2 1 3]);
    end
        
    map = [];
    
else
    error('MATLAB:readhdf:wrongNumberOfComponents', ...
          'Can only read 1- or 3-component HDF raster images');
    
end

%%%
%%% Function hdferror
%%%
function str = hdferror()
%HDFERROR The current HDF error string.

str = sprintf('The NCSA HDF library reported the following error:\n%s', ...
              hdf('HE', 'string', hdf('HE', 'value', 1)));
