function [pstruc,tstruc] = tigerp(namesstruc,filename,pstruc,tstruc,fipsIDs)
%TIGERP Read TIGER p and pa thinned boundary files (ArcInfo format).
%   TIGERP(namesstruc) reads a TIGER thinned boundary file in the
%   ArcInfo format.  The user selects the file interactively, but must
%   provide the structure containing the names (as returned by
%   FIPSNAME).  The patch data is returned in a Mapping Toolbox
%   geographic data structure.
%
%   TIGERP(namesstruc,filename) reads the ArcInfo file named in
%   string filename. The filename is provided without the '_p' or
%   '_pa' extension.
%
%   TIGERP(namesstruc,filename,pstruc) appends the patch data to the
%   existing structure.
%
%   TIGERP(namesstruc,filename,pstruc,tstruc) appends the data the file
%   to the existing patch and text geographic data structures.  The text
%   structure contains labels for the patches.  This form would be used
%   with two output arguments.  The argument for the existing structure
%   can be set to an empty matrix if none is available.
%
%   TIGERP(namesstruc,filename,pstruc,tstruc,getcodes) returns only the data
%   matching the scalar or vector of FIPS codes.  The argument for the
%   existing structure can be set to an empty matrix if none is available.
%
%   pstruc = TIGERP(...) saves the returned patch data in pstruc
%
%   [pstruc,tstruc] = TIGERP(...)  saves the returned patch data in
%   pstruc and text labels in tstruc. Both are geographic data structures.
%
%   The data files are available over the internet from 
%   (ftp://ftp.census.gov/pub/tiger/boundary).  Documentation on the files is 
%   available from (ftp://ftp.census.gov/pub/tiger/boundary/readme.txt)
% 
%   See also TIGERMIF, FIPSNAME, TGRLINE, DCWDATA.

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by:  W. Stumpf
%   $Revision: 1.1.6.1 $    $Date: 2003/08/01 18:24:02 $

if nargin == 1
	[filename, path] = uigetfile('*_p.dat', 'select a *_p.dat file');
	if filename == 0 ; return; end
	filename = [path filename];
	pstruc = [];tstruc = [];
elseif nargin >= 1 & nargin <= 5
	if nargin ==2; pstruc = [];tstruc = []; end
	if nargin ==3; tstruc = []; end
	fid = fopen(filename,'r');
	if fid == -1
		[filename, path] = uigetfile('*_p.dat', 'select a *_p.dat file');
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

noldpatch = length(pstruc);
noldt = length(tstruc);

% extract the indices of the name structure, so we may find the
% index to extract a particular name

namesind =  cat(1,namesstruc(:).id) ;

% First construct the filename of the .MID file, open it
% and read the id strings. The are associated with the blocks
% of data in the .MIF file

pafilename = strrep(filename,'_p.dat','_pa.dat');
ids=spcread(pafilename) ;

% Now open and read the selected _p file. This one has the lat-longs

fid = fopen(filename,'r');
fid;
if fid == -1
   error(['Couldn''t open file: ' filename])
end



% Read data into a Geographic Data Structure. Combine separate pieces into
% single nan-clipped patches.

jpatch = 0;
jtext = 0;
readindices = [];
while 1
	ll = [NaN NaN];
	i = fscanf(fid,'%i',1)    ;    						% index
	if isstr(i) ; break; end							% if we didn't get a number, assume that was the end of the file
    % also terminate operation if variable is empty
    if isempty(i)
        break;
    end							% if we didn't get a number, assume that was the end of the file
	if i ~=  -99999; ctr = fscanf(fid,'%g',[2,1]); end 	% lat-longs of an excluded region in the interior of patch
	rd = fscanf(fid,'%g',[2,inf]); 						% lat-longs
	ll = [ll; rd']	;
	rd   = fscanf(fid,'%s',1);     						% END

	if i >= 1 & i <= length(ids)
		id = ids(i,2);
		indxinnames = find( namesind  == id);
	else												% handle the interior index (-9999)
		id = i;
		indxinnames = [];
	end

	if isempty(readindices);
		addto = [];
	else
		addto = find(readindices == id)	;
	end

	if  nargin<5 | (nargin==5 & ismember(id,fipsIDs) )

		if isempty(addto)
%
% haven't got a piece of this polygon yet in the current file, so just save it
%

			jpatch = jpatch+1;
			readindices = [readindices; id];

	    	pstruc(noldpatch+jpatch).lat = ll(:,2);
	    	pstruc(noldpatch+jpatch).long = ll(:,1);
	    	pstruc(noldpatch+jpatch).type = 'patch';
	    	pstruc(noldpatch+jpatch).otherproperty = {};
	  		pstruc(noldpatch+jpatch).altitude = [];

			if isempty(indxinnames)
	    		pstruc(noldpatch+jpatch).tag = 'name not found';
			else
				pstruc(noldpatch+jpatch).tag = namesstruc(indxinnames).name;
	 		end

%
% now take the interior point and put the name string there
%
	 		jtext = jtext+1;

			tstruc(noldt+jtext).lat  = ctr(2);
		    tstruc(noldt+jtext).long = ctr(1);
		    tstruc(noldt+jtext).type = 'text';
		    tstruc(noldt+jtext).tag = 'maptext';
		    tstruc(noldt+jtext).otherproperty = {'fontsize' ,   [9]};
		  	tstruc(noldt+jtext).altitude = 0.05;

			if isempty(indxinnames)
		    	tstruc(noldt+jtext).string = {'name not found'};
			else
				tstruc(noldt+jtext).string = {namesstruc(indxinnames).name};
		 	end

			if i ==  -99999 ;tstruc(noldt+jtext).string = {'interior exclusion'};end
		else
%
% have already got a piece of this polygon, so append this one
% with a NaN between chunks
%
 	   		pstruc(noldpatch+addto).lat  = [pstruc(noldpatch+addto).lat;  ll(:,2)];
 	   		pstruc(noldpatch+addto).long = [pstruc(noldpatch+addto).long; ll(:,1)];

		end % if
	end % if

end


fclose(fid);
