function [varargout] = sdtsdemread(filename)
% SDTSDEMREAD Read data from an SDTS raster/DEM data set.
% 
%   [Z, R] = SDTSDEMREAD(FILENAME) reads data from an SDTS raster or DEM 
%   data set.  Z is a matrix containing the elevation/data values.   R is a
%   referencing matrix (see MAKEREFMAT).  NaNs are assigned to elements of
%   Z corresponding to null data values or fill data values in the cell
%   module.
%
%   FILENAME can be the name of the SDTS Catalog Directory file (*CATD.DDF)
%   or the name of any of the other files in the data set.  FILENAME may
%   include the directory name, otherwise FILENAME will be searched for in
%   the current directory and the MATLAB path.  If any of the files
%   sepcified in the Catalog Directory are missing SDTSDEMREAD will fail. 
%    
%   Example
%   -------
%   [Z, R] = sdtsdemread('9129CATD.ddf');
%   mapshow(Z,R,'DisplayType','contour')
%
%   See also ARCGRIDREAD, MAKEREFMAT, MAPSHOW.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/01 16:12:10 $

error(nargoutchk(1,2, nargout));
error(nargchk(1,1,nargin));

if ~ischar(filename)
    errTxt = sprintf('Filename must be a string');
    error(errTxt);
end

% Converts the filename input to the catalog/directory file name
% and ensures that the extension is in upper case.
[pn,fn,xtn] = fileparts(filename);
fn1 = [fn(1:end-4) 'CATD'];
xtn = upper(xtn);
filename = fullfile(pn,[fn1 xtn]);

filename = checkfilename(filename, {'.DDF'}, mfilename, 1);


% Call SDTSMEX and returned both the INFO structure and the
% DEM data.
[info, Z] = sdtsmex(filename);


if isempty(Z)
    % Error if file is not a DEM
    error(sprintf('%s%s is not a SDTS DEM file.',fn, xtn));
    return
end

% Transpose the elevation data matrix
Z = Z';

d = info.ProfileStruct;

% Replace both void values and fill values with NaN
Z((Z==d.FillValue) |...
  (Z==d.VoidValue)) = NaN;

varargout{1} = Z;

if nargout == 2
    [ExtSpatialOrigin] = transInt2Ext([d.XScaleFactor, d.YScaleFactor],...
                                      [d.XTopLeft, d.YTopLeft],...
                                      [d.XOrigin, d.YOrigin]);

    R = makerefmat(ExtSpatialOrigin(1) + d.XHorizResolution/2,...
                   ExtSpatialOrigin(2) - d.YHorizResolution/2,...
                    d.XHorizResolution, -d.YHorizResolution);

    varargout{2} = R;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [extSpatial] = transInt2Ext(ScaleFactor,...
                                     IntSpatialAddress,...
                                     IntExtOrigin)
  
% This performs the transformation of a spatial address in the internal spatial 
% reference system to the external reference system.
% The parameters: "extSpatial", "ScaleFactor", "IntSpatialAddress" and 
% "IntExtOrigin" are vectors containing the X and Y components.
% This transformation is implemented by:
%
%  [X]   [SX  0 ]   [X']     [Xo]
%  [Y] = [0   SY] * [Y']  +  [Yo]
%
% where,
% X,Y   = geospatial components of spatial address in the external system 
% SX,SY = geospatial scaling factors for scaling to the external system, 
%         forming the diagonal elements of a diagonal matrix with off-diagonal 
%         zero elements
% X',Y' = geospatial components of spatial address in internal system 
% Xo,Yo = geospatial components of spatial address of origin of internal system 
%         in external system 

extSpatial = diag(ScaleFactor) * IntSpatialAddress' + IntExtOrigin';
