function info = sdtsinfo(filename)
% SDTSINFO  Information about an SDTS data set.
%    
%    INFO = SDTSINFO(FILENAME) returns a structure whose fields contain
%    information about the contents of an SDTS data set.  
% 
%    FILENAME is a string that specifies the name of the SDTS catalog 
%    directory file, such as 7783CATD.DDF.  The FILENAME may also include
%    the directory name.  If FILENAME does not include the directory, then
%    it must be in the current directory or in a directory on the MATLAB
%    path.  If SDTSINFO cannot find the SDTS catalog file an error will be
%    returned.
% 
%    If any of the other files in the data set as specified by the catalog
%    file is missing a warning message will be returned.  Also, subsequent
%    calls to read data from the file may fail.
%    
%    The INFO structure contains the following fields:
%    
%    Filename         A string containing the name of the catalog
%                     directory file of the SDTS transfer set. 
%    
%    Title            A string containing the name of the data set.
%    
%    ProfileID        A string containing the Profile Identifier e.g.
%                     'SRPE: SDTS RASTER PROFILE and EXTENSIONS'
%                 
%    ProfileVersion   A string containing the Profile Version Identifier.
%                     e.g.  'VER 1.1 1998 01'
%                              
%    MapDate          A string specifying the date associated with the 
%                     cartographic information contained in the data set.
%    
%    DataCreationDate A string specifying the creation date of the data set.
% 
%    HorizontalDatum  A string representing the Horizontal Datum to which the 
%                     data is referenced.
%
%    MapRefSystem     A string describing the projection and reference
%                     system used: 'GEO', 'SPCS', 'UTM', 'UPS', or ''.
% 
%    ZoneNumber	      A scalar value representing the Zone number.
%    
%    XResolution      A scalar value representing the X component of the 
%                     horizontal coordinate resolution.
%                 
%    YResolution      A scalar value representing the Y component of the 
%                     horizontal coordinate resolution.
%                
%    NumberOfRows     A scalar value representing the number of rows of the DEM.
%    
%    NumberOfCols     A scalar value representing the number of columns of the DEM.
%    
%    HorizontalUnits  A string specifying the units used for horizontal 
%                     coordinate values. 
% 
%    VerticalUnits    A string specifying the units used for the vertical 
%                     coordinate values.
%
%    MinElevation     A scalar value of the minimum elevation value for the
%                     data set.
%
%    MaxElevation     A scalar value of the maximum elevation value for the
%                     data set.
% 		     
%   Example
%   -------
%       info = sdtsinfo('9129CATD.DDF');
%
%   See also SDTSDEMREAD, MAKEREFMAT.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2004/04/01 16:12:11 $   


error(nargoutchk(0,1, nargout));
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


% Get the info structure from file.
info = getSDTSInfo(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function info  = getSDTSInfo(filename);

% Calls SDTSMEX to read Information about the SDTS data set.
%  and returns the information to info structure.

info = [];

pstruct = sdtsmex(filename);

[pn fn xtn] = fileparts(filename);

info.Filename       = [fn xtn];
info.Title          = pstruct.Title;
info.ProfileID      = pstruct.ProfileID;
info.ProfileVersion = pstruct.ProfileVersion;
info.MapDate        = pstruct.MapDate;
info.DataCreationDate     = pstruct.DataCreationDate;

d = pstruct.ProfileStruct;

if isempty(d) | ~isstruct(d)
   info.Msg = ('This SDTS Profile is currently unsupported.');
   return;
end


% These cell arrays enables mapping the reference datum abbreviations to 
% their actual description.
hDatumStr = {'NAS', 'North American 1927';
             'NAX', 'North American 1983';
             'WGA', 'World Geodetic System 1960';
             'WGB', 'World Geodetic System 1966';
             'WGC', 'World Geodetic System 1972';
             'WGE', 'World Geodetic System 1984'};

ind_h = find(strcmp(hDatumStr, d.HorizontalDatum));
if isempty(ind_h)
    str1 = d.HorizontalDatum;
else
    str1 = hDatumStr{ind_h,2};
end

info.HorizontalDatum     = str1;
info.MapRefSystem   = d.ReferenceSystem;
info.ZoneNumber     = d.ZoneNumber;
info.XResolution      = d.XHorizResolution;
info.YResolution      = d.YHorizResolution;
info.NumberOfRows   = d.NumberOfRows; 
info.NumberOfCols   = d.NumberOfCols;
info.HorizontalUnits     = d.HorizontalUnits;
info.VerticalUnits      = d.VerticalUnits;
info.MinElevation   = d.MinimumValue;
info.MaxElevation   = d.MaximumValue;
