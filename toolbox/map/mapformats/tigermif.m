function [patchstruc,textstruc] = tigermif(namesstruc,filename,patchstruc,textstruc,fipsIDs)
% TIGERMIF Read the TIGER MIF thinned boundary file.
%
%   TIGERMIF(namesstruc) reads a TIGER thinned boundary file in the Mapinfo
%   Interchange Format (MIF) format.  The user selects the file
%   interactively, but must provide the structure containing the names (as
%   returned by FIPSNAME).  The patch data is returned in a Mapping Toolbox
%   geographic data structure.
%
%   TIGERMIF(namesstruc,filename) reads the MIF file named in string
%   filename. The filename is provided with the '.MIF' extension.
%
%   TIGERMIF(namesstruc,filename,pstruc) appends the patch data to the
%   existing structure.
%
%   TIGERMIF(namesstruc,filename,pstruc,tstruc) appends the data the file
%   to the existing patch and text geographic data structures.  The text
%   structure contains labels for the patches.  This form would be used
%   with two output arguments.  The argument for the existing structure can
%   be set to an empty matrix if none is available.
%
%   TIGERMIF(namesstruc,filename,pstruc,tstruc,getcodes) returns only the
%   data matching the scalar or vector of FIPS codes.  The argument for the
%   existing structure can be set to an empty matrix if none is available.
%
%   pstruc = TIGERMIF(...) saves the returned patch data in pstruc
%
%   [pstruc,tstruc] = TIGERMIF(...)  saves the returned patch data in
%   pstruc and text labels in tstruc. Both are geographic data structures.
% 
%   The data files are available over the internet from 
%   (ftp://ftp.census.gov/pub/tiger/boundary).  Extremely limited 
%   documentation on the files is available on the World-Wide Web from 
%   (http://www.census.gov/ftp/pub/geo/www/tiger/mif.txt) and 
%   (http://www.census.gov/ftp/pub/geo/www/tiger/resource.html)
%
%   See also TIGERP, FIPSNAME, TGRLINE, DCWDATA

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%  $Revision: 1.1.6.1 $    $Date: 2003/08/01 18:24:01 $

if nargin == 1
	[filename, path] = uigetfile('*.MIF', 'select a MIF file');
	if filename == 0 ; return; end
	filename = [path filename];
	patchstruc = [];textstruc = [];
elseif nargin >= 1 & nargin <= 5
	if nargin ==2; patchstruc = [];textstruc = []; end
	if nargin ==3; textstruc = []; end
	fid = fopen(filename,'r');
	if fid == -1
		[filename, path] = uigetfile('*.MIF', 'select a MIF file');
		if filename == 0 ; return; end
		filename = [path filename];
	else
		fclose(fid);                                     % verify that the file exists
	end
else
    error('Incorrect number of input arguments.')
end

% measure the number of elements in the structure already.
% We'll append ours to the end so that there are no empty elements

noldpatch = length(patchstruc);
noldtext = length(textstruc);

% extract the indices of the name structure, so we may find the
% index to extract a particular name

namesind =  cat(1,namesstruc(:).id) ;

% First construct the filename of the .MID file, open it
% and read the id strings. The are associated with the blocks
% of data in the .MIF file

miffilename = strrep(filename,'.MIF','.MID');
miffilename = strrep(miffilename,'.mif','.mid'); % in case the case was lower

ids=dlmread(miffilename) ;

% if not asking for selected regions, return what's in the file

if nargin < 5; fipsIDs = ids(:,1); end

% Now open and read the selected .MIF file. This one has the lat-longs

fid = fopen(filename,'r');
if fid == -1
   error('Error opening MIF file')
end

%Line 1: Version
rd = fscanf(fid,'%s',1); vers = fscanf(fid,'%i',1);

%Line 2: Delimiter
rd = fscanf(fid,'%s',1); delimstr = fscanf(fid,'%s',1);

%Line 3: CoordSys
rd   = fscanf(fid,'%s',3);
int1 = fscanf(fid,'%i',1);
rd   = fscanf(fid,'%s',1);
int2 = fscanf(fid,'%i',1);

%Line 4
rd    = fscanf(fid,'%s',1);
ncols = fscanf(fid,'%i',1);

%Block of codes
for i=1:ncols
	rd   = fscanf(fid,'%s',2);
end

%Data
rd   = fscanf(fid,'%s',1);

sz = size(ids);

k=0;
for j=1:sz(1)

%Region
    rd   = fscanf(fid,'%s',1);
    nreg = fscanf(fid,'%i',1);

% The data
    ll = [NaN NaN];
    for i=1:nreg
        nrows = fscanf(fid,'%i',1);
    	rd = fscanf(fid,'%g',[2,nrows]);
        ll = [ll; rd'; NaN NaN]	;
    end

%
% only return data for requested regions
%
	if ismember( ids(j,1) , fipsIDs)

		k = k+1;
		indxinnames = find( namesind  == ids(j,1));
	    patchstruc(noldpatch+k).lat = ll(:,2);
	    patchstruc(noldpatch+k).long = ll(:,1);
	    patchstruc(noldpatch+k).type = 'patch';
	    patchstruc(noldpatch+k).otherproperty = {};
	    patchstruc(noldpatch+k).tag = namesstruc(indxinnames).name;
	    patchstruc(noldpatch+k).altitude = [];

		lat = ll(:,2);
		lon = ll(:,1);
		indx = find(~isnan(lat) & ~isnan(lon));

		[latmean,lonmean] = meanm(lat(indx),lon(indx));
	    textstruc(noldtext+k).lat = latmean;
	    textstruc(noldtext+k).long = lonmean;
	    textstruc(noldtext+k).type = 'text';
	    textstruc(noldtext+k).tag = 'maptext';
	    textstruc(noldtext+k).otherproperty = {'fontsize' ,   [9]};
	    textstruc(noldtext+k).string = {namesstruc(indxinnames).name};
	    textstruc(noldtext+k).altitude = [];

	end % if
end % for

fclose(fid);
