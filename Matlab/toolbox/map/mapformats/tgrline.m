function [CL,PR,SR,RR,H,AL,PL] = tgrline(fname,year,cname)
%TGRLINE Read TIGER/Line data.
%
% [CL,PR,SR,RR,H,AL,PL] = TGRLINE(filename) reads the set of 1994
% TIGER/line files which share the same filename, but different extensions.
% The results are returned in a set of geographic data structures
% containing the county boundaries, primary roads, secondary roads,
% railroads, hydrography, area landmarks and point landmarks, respectively.
% The data is tagged with the name of the features.
%
% [CL,PR,SR,RR,H,AL,PL] = TGRLINE(fname,year) reads the TIGER line files in
% the format from that year. TIGER/Line files are updated periodically, and
% the format and filename extensions may change from year to year. Valid
% years are 1990, 1992, 1994, 1995, and 2000.
%
% [CL,PR,SR,RR,H,AL,PL] = TGRLINE(fname,year,countyname) uses the string
% countyname to tag the county data
%
% TIGER/Line example files are available over the internet at
% (ftp://ftp.census.gov/pub/tiger/line/).
%
% See also: DCWDATA, TIGERP, TIGERMIF

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:24:00 $
%  Written by:  A. Kim

%  Ascii data file

if nargin==1
	year = 1994;
	cname = 'County';
elseif nargin==2
	cname = 'County';
elseif nargin~=3
	error('Incorrect number of arguments')
end

switch year
    case 2000, ext = '.RT';
	case 1995, ext = '.BW';
	case 1994, ext = '.F6';
	case 1992, ext = '.F5';
	case 1990, ext = '.F4';
	otherwise, error('Invalid year');
end

%  Extract data from raw TIGER/Line files

filename = [fname ext '1'];
[rt1mat,rt_1cl,rt_1a1,rt_1a2,rt_1a3,rt_1b,rt_1h] = readrt1(filename);

filename = [fname ext '2'];
[rt_2,lat_2,long_2] = readrt2(filename);

filename = [fname ext '7'];
rt_7 = readrt7(filename);

filename = [fname ext '8'];
rt_8 = readrt8(filename);

filename = [fname ext 'I'];
rt_i = readrti(filename);

%  Process data into map structures

CL = county(rt_1cl,rt_2,lat_2,long_2,cname);
PR = roadp(rt_1a1,rt_1a2,rt_2,lat_2,long_2);
SR = roads(rt_1a3,rt_2,lat_2,long_2);
RR = roadr(rt_1b,rt_2,lat_2,long_2);
[H,AL,PL] = landmk(rt1mat,rt_2,lat_2,long_2,rt_7,rt_8,rt_i);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SecondaryRoad = roads(rt_1a3,rt_2,lat_2,long_2)

%ROADS  Secondary road chains
%
%	Purpose
%		Processes information into a data structure containing
%		secondary road chains.
%
%	Synopsis
%
%		SecondaryRoad = roads(rt_1a3,rt_2,lat_2,long_2)
%

SecondaryRoad = [];

if ~isempty(rt_1a3)

	for n=1:length(rt_1a3)

		frlat = rt_1a3(n).frlat;
		frlong = rt_1a3(n).frlong;
		tolat = rt_1a3(n).tolat;
		tolong = rt_1a3(n).tolong;

		indx2 = find(rt_2(:,1)==rt_1a3(n).tlid);
		if isempty(indx2)
			SecondaryRoad(n).lat = [frlat tolat];
			SecondaryRoad(n).long = [frlong tolong];
		else
			templat = [];
			templong = [];
			rtsq = rt_2(indx2,2);
			[rtsq,order] = sort(rtsq);
			for i=1:length(rtsq)
				templat = [templat lat_2{indx2(order(i))}];
				templong = [templong long_2{indx2(order(i))}];
			end
			SecondaryRoad(n).lat = [frlat templat tolat];
			SecondaryRoad(n).long = [frlong templong tolong];
		end
		if isempty(rt_1a3(n).fename)
			fename = 'unknown';
		else
			i = findstr(rt_1a3(n).fename,'-');
			fename = rt_1a3(n).fename;
			if ~isempty(i)
				fename(i) = [];
			end
		end
		if isempty(rt_1a3(n).fetype)
			SecondaryRoad(n).tag = [fename];
		else
			SecondaryRoad(n).tag = [fename ' ' rt_1a3(n).fetype];
		end

	end

end

% Combine chains with same name
i = 1;

while i<length(SecondaryRoad)

     name = SecondaryRoad(i).tag;
     SecondaryRoad(i).lat = SecondaryRoad(i).lat';
	 SecondaryRoad(i).long = SecondaryRoad(i).long';

     delindx = [];
	 for j = i+1:length(SecondaryRoad)
         if strcmp(SecondaryRoad(j).tag,name)
		       SecondaryRoad(i).lat = [SecondaryRoad(i).lat;
			                           NaN;
									   SecondaryRoad(j).lat'];
		       SecondaryRoad(i).long = [SecondaryRoad(i).long;
			                           NaN;
									   SecondaryRoad(j).long'];
			   delindx = [delindx; j];
	     end
     end
     if ~isempty(delindx);  SecondaryRoad(delindx) = [];  end
	 i = i + 1;
end

for n=1:length(SecondaryRoad)
	SecondaryRoad(n).type = 'line';
	SecondaryRoad(n).altitude = 0.3;
	SecondaryRoad(n).otherproperty = {'g--'};
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function RailRoad = roadr(rt_1b,rt_2,lat_2,long_2)

%ROADR  Railroad chains
%
%	Purpose
%		Processes information into a data structure containing
%		railroad chains.
%
%	Synopsis
%
%		RailRoad = roadr(rt_1b,rt_2,lat_2,long_2)
%

RailRoad = [];

if ~isempty(rt_1b)

	for n=1:length(rt_1b)

		frlat = rt_1b(n).frlat;
		frlong = rt_1b(n).frlong;
		tolat = rt_1b(n).tolat;
		tolong = rt_1b(n).tolong;

		indx2 = find(rt_2(:,1)==rt_1b(n).tlid);
		if isempty(indx2)
			RailRoad(n).lat = [frlat tolat];
			RailRoad(n).long = [frlong tolong];
		else
			templat = [];
			templong = [];
			rtsq = rt_2(indx2,2);
			[rtsq,order] = sort(rtsq);
			for i=1:length(rtsq)
				templat = [templat lat_2{indx2(order(i))}];
				templong = [templong long_2{indx2(order(i))}];
			end
			RailRoad(n).lat = [frlat templat tolat];
			RailRoad(n).long = [frlong templong tolong];
		end
		if isempty(rt_1b(n).fename)
			fename = 'unknown';
		else
			i = findstr(rt_1b(n).fename,'-');
			fename = rt_1b(n).fename;
			if ~isempty(i)
				fename(i) = [];
			end
		end
		if isempty(rt_1b(n).fetype)
			RailRoad(n).tag = [fename];
		else
			RailRoad(n).tag = [fename ' ' rt_1a3(n).fetype];
		end

	end

end

i = 1;

while i<length(RailRoad)

     name = RailRoad(i).tag;
     RailRoad(i).lat = RailRoad(i).lat';
	 RailRoad(i).long = RailRoad(i).long';

     delindx = [];
	 for j = i+1:length(RailRoad)
         if strcmp(RailRoad(j).tag,name)
		       RailRoad(i).lat = [RailRoad(i).lat;
			                           NaN;
									   RailRoad(j).lat'];
		       RailRoad(i).long = [RailRoad(i).long;
			                           NaN;
									   RailRoad(j).long'];
			   delindx = [delindx; j];
	     end
     end
     if ~isempty(delindx);  RailRoad(delindx) = [];  end
	 i = i + 1;
end

for n=1:length(RailRoad)
	RailRoad(n).type = 'line';
	RailRoad(n).altitude = 0.3;
	RailRoad(n).otherproperty = {'k-.'};
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PrimaryRoad = roadp(rt_1a1,rt_1a2,rt_2,lat_2,long_2)

%ROADP  Primary road chains
%
%	Purpose
%		Processes information into a data structure containing
%		primary road chains.
%
%	Synopsis
%
%		PrimaryRoad = roadp(rt_1a1,rt_1a2,rt_2,lat_2,long_2)
%

PrimaryRoad = [];

count = 0;

if ~isempty(rt_1a1)

	for n=1:length(rt_1a1)

		count = count + 1;

		frlat = rt_1a1(n).frlat;
		frlong = rt_1a1(n).frlong;
		tolat = rt_1a1(n).tolat;
		tolong = rt_1a1(n).tolong;

		indx2 = find(rt_2(:,1)==rt_1a1(n).tlid);
		if isempty(indx2)
			PrimaryRoad(count).lat = [frlat tolat];
			PrimaryRoad(count).long = [frlong tolong];
		else
			templat = [];
			templong = [];
			rtsq = rt_2(indx2,2);
			[rtsq,order] = sort(rtsq);
			for i=1:length(rtsq)
				templat = [templat lat_2{indx2(order(i))}];
				templong = [templong long_2{indx2(order(i))}];
			end
			PrimaryRoad(count).lat = [frlat templat tolat];
			PrimaryRoad(count).long = [frlong templong tolong];
		end
		if isempty(rt_1a1(n).fename)
			fename = 'unknown';
		else
			i = findstr(rt_1a1(n).fename,'-');
			fename = rt_1a1(n).fename;
			if ~isempty(i)
				fename(i) = [];
			end
		end
		if isempty(rt_1a1(n).fetype)
			PrimaryRoad(count).tag = [fename];
		else
			PrimaryRoad(count).tag = [fename ' ' rt_1a1(n).fetype];
		end

	end

end

if ~isempty(rt_1a2)

	for n=1:length(rt_1a2)

		count = count + 1;

		frlat = rt_1a2(n).frlat;
		frlong = rt_1a2(n).frlong;
		tolat = rt_1a2(n).tolat;
		tolong = rt_1a2(n).tolong;

		indx2 = find(rt_2(:,1)==rt_1a2(n).tlid);
		if isempty(indx2)
			PrimaryRoad(count).lat = [frlat tolat];
			PrimaryRoad(count).long = [frlong tolong];
		else
			templat = [];
			templong = [];
			rtsq = rt_2(indx2,2);
			[rtsq,order] = sort(rtsq);
			for i=1:length(rtsq)
				templat = [templat lat_2{indx2(order(i))}];
				templong = [templong long_2{indx2(order(i))}];
			end
			PrimaryRoad(count).lat = [frlat templat tolat];
			PrimaryRoad(count).long = [frlong templong tolong];
		end
		if isempty(rt_1a2(n).fename)
			fename = 'unknown';
		else
			i = findstr(rt_1a2(n).fename,'-');
			fename = rt_1a2(n).fename;
			if ~isempty(i)
				fename(i) = [];
			end
		end
		if isempty(rt_1a2(n).fetype)
			PrimaryRoad(count).tag = [fename];
		else
			PrimaryRoad(count).tag = [fename ' ' rt_1a2(n).fetype];
		end

	end

end

% Combine chains with same name
i = 1;

while i<length(PrimaryRoad)

     name = PrimaryRoad(i).tag;
     PrimaryRoad(i).lat = PrimaryRoad(i).lat';
	 PrimaryRoad(i).long = PrimaryRoad(i).long';

     delindx = [];
	 for j = i+1:length(PrimaryRoad)
         if strcmp(PrimaryRoad(j).tag,name)
		       PrimaryRoad(i).lat = [PrimaryRoad(i).lat;
			                           NaN;
									   PrimaryRoad(j).lat'];
		       PrimaryRoad(i).long = [PrimaryRoad(i).long;
			                           NaN;
									   PrimaryRoad(j).long'];
			   delindx = [delindx; j];
	     end
     end
     if ~isempty(delindx);  PrimaryRoad(delindx) = [];  end
	 i = i + 1;
end

for n=1:length(PrimaryRoad)
	PrimaryRoad(n).type = 'line';
	PrimaryRoad(n).altitude = 0.3;
	PrimaryRoad(n).otherproperty = {'b-'};
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rt_i = readrti(filename)

%READRTI  TIGER/Line Record Type I data extraction
%
%  Purpose
%
%  Reads data from the Record Type I TIGER/Line data file.
%
%  Synopsis
%
%       rt_i = readrti(filename)
%
%  rt_i is a matrix with tlid in the first column, polyidl in
%  the second, and polyidr in the third.  polyidl and polyidr
%  contain nans if they are empty in the data files.
%

%  Ascii data file

if nargin~=1;  error('Incorrect number of arguments');  end

rt = 'i';
linelength = 52;

eof = 0;
line = 0;

rt_i = [];

fid = fopen(filename);
if fid==-1
	error('TIGER/Line Record Type I file not found')
end

while ~eof

	t = setstr(fread(fid,1,'uchar'))';

	if strcmp(lower(t),rt)

		line = line + 1;

		t = [t setstr(fread(fid,linelength,'uchar'))'];

		rt_i(line,1) = str2num(t(6:15));

		if isempty(find(~isspace(t(27:36))))
			rt_i(line,2) = nan;
		else
			rt_i(line,2) = str2num(t(27:36));
		end

		if isempty(find(~isspace(t(42:51))))
			rt_i(line,3) = nan;
		else
			rt_i(line,3) = str2num(t(42:51));
		end

	elseif isempty(t) | strcmp(lower(t),char(26))

		eof = 1;

	end

end

status = fclose(fid);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rt_8 = readrt8(filename)

%READRT8  TIGER/Line Record Type 8 data extraction
%
%  Purpose
%
%  Reads data from the Record Type 8 TIGER/Line data file.
%
%  Synopsis
%
%       rt_8 = readrt8(filename)
%
%  rt_8 is a matrix with polyid in the first column and land in
%  the second.
%

%  Ascii data file

if nargin~=1;  error('Incorrect number of arguments');  end

rt = '8';
linelength = 36;

eof = 0;
line = 0;

rt_8 = [];

fid = fopen(filename);
if fid==-1
	error('TIGER/Line Record Type 8 file not found')
end

while ~eof

	t = setstr(fread(fid,1,'uchar'))';

	if strcmp(lower(t),rt)

		line = line + 1;

		t = [t setstr(fread(fid,linelength,'uchar'))'];

		rt_8(line,1) = str2num(t(16:25));

		rt_8(line,2) = str2num(t(26:35));

	elseif isempty(t) | strcmp(lower(t),char(26))

		eof = 1;

	end

end

status = fclose(fid);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rt_7 = readrt7(filename)

%READRT7  TIGER/Line Record Type 7 data extraction
%
%  Purpose
%
%  Reads data from the Record Type 7 TIGER/Line data file.
%
%  Synopsis
%
%       rt_7 = readrt7(filename)
%

%  Ascii data file

if nargin~=1;  error('Incorrect number of arguments');  end

rt = '7';
linelength = 74;

eof = 0;
line = 0;

rt_7 = [];

fid = fopen(filename);
if fid==-1
	error('TIGER/Line Record Type 7 file not found')
end

while ~eof

	t = setstr(fread(fid,1,'uchar'))';

	if strcmp(lower(t),rt)

		line = line + 1;

		t = [t setstr(fread(fid,linelength,'uchar'))'];

		land = str2num(t(11:20));

		rt_7(land,1).land = land;

		rt_7(land,1).cfcc = t(22:24);

		laname = t(25:54);
		indx = find(~isspace(laname));
		if isempty(indx)
			rt_7(land,1).laname = [];
		else
			rt_7(land,1).laname = laname(1:max(indx));
		end

		if isempty(find(~isspace(t(55:64))))
			rt_7(land,1).lalong = [];
			rt_7(land,1).lalat = [];
		else
			rt_7(land,1).lalong = fixnum(str2num(t(55:64)));
			rt_7(land,1).lalat = fixnum(str2num(t(65:73)));
		end

	elseif isempty(t) | strcmp(lower(t),char(26))

		eof = 1;

	end

end

status = fclose(fid);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [rt_2,lat_2,long_2] = readrt2(filename)

%READRT2  TIGER/Line Record Type 2 data extraction
%
%  Purpose
%		Reads data from the Record Type 2 TIGER/Line data file.
%
%  Synopsis
%
%       rt_2 = readrt2(filename)
%
%  rt_2 is a matrix with tlid in the first column and rtsq in
%  the second.
%

%  Ascii data file


if nargin~=1;  error('Incorrect number of arguments');  end

rt = '2';
linelength = 208;

eof = 0;
line = 0;

rt_2 = []; lat_2 = []; long_2 = [];

fid = fopen(filename);
if fid==-1
	error('TIGER/Line Record Type 2 file not found')
end

while ~eof

	t = setstr(fread(fid,1,'uchar'))';

	if strcmp(lower(t),rt)

		line = line + 1;

		t = [t setstr(fread(fid,linelength,'uchar'))'];

		rt_2(line,1) = str2num(t(6:15));

		rt_2(line,2) = str2num(t(16:18));

		long(1) = fixnum(str2num(t(19:28)));
		long(2) = fixnum(str2num(t(38:47)));
		long(3) = fixnum(str2num(t(57:66)));
		long(4) = fixnum(str2num(t(76:85)));
		long(5) = fixnum(str2num(t(95:104)));
		long(6) = fixnum(str2num(t(114:123)));
		long(7) = fixnum(str2num(t(133:142)));
		long(8) = fixnum(str2num(t(152:161)));
		long(9) = fixnum(str2num(t(171:180)));
		long(10) = fixnum(str2num(t(190:199)));
		long_2{line,1} = long(find(long));

		lat(1) = fixnum(str2num(t(29:37)));
		lat(2) = fixnum(str2num(t(48:56)));
		lat(3) = fixnum(str2num(t(67:75)));
		lat(4) = fixnum(str2num(t(86:94)));
		lat(5) = fixnum(str2num(t(105:113)));
		lat(6) = fixnum(str2num(t(124:132)));
		lat(7) = fixnum(str2num(t(143:151)));
		lat(8) = fixnum(str2num(t(162:170)));
		lat(9) = fixnum(str2num(t(181:189)));
		lat(10) = fixnum(str2num(t(200:208)));
		lat_2{line,1} = lat(find(lat));

	elseif isempty(t) | strcmp(lower(t),char(26))

		eof = 1;

	end

end

status = fclose(fid);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [rt1mat,rt_1cl,rt_1a1,rt_1a2,rt_1a3,rt_1b,rt_1h] = readrt1(filename)

%READRT1  TIGER/Line Record Type 1 data extraction
%
%  Purpose
%		Reads data from the Record Type 1 TIGER/Line data file.
%

%  Ascii data file

if nargin~=1;  error('Incorrect number of arguments');  end

rt = '1';
linelength = 228;

eof = 0;
line = 0;
c1 = 0; c2 = 0; c3 = 0; c4 = 0; c5 = 0; c6 = 0;

rt1mat = []; rt_1cl = [];
rt_1a1 = []; rt_1a2 = []; rt_1a3 = [];
rt_1b = []; rt_1h = [];

fid = fopen(filename);
if fid==-1
	error('TIGER/Line Record Type 1 file not found')
end

while ~eof

	t = setstr(fread(fid,1,'uchar'))';
%
% forms part of county line
%
	if strcmp(lower(t),rt)

		line = line + 1;

		t = [t setstr(fread(fid,linelength,'uchar'))'];

		if strcmp(lower(t(16)),'1')

			c1 = c1 + 1;

			rt_1cl(c1,1).tlid = str2num(t(6:15));

			fename = t(20:49);
			indx = find(~isspace(fename));
			if isempty(indx)
				rt_1cl(c1,1).fename = [];
			else
				rt_1cl(c1,1).fename = fename(1:max(indx));
			end

			fetype = t(50:53);
			indx = find(~isspace(fetype));
			if isempty(find(~isspace(fetype)))
				rt_1cl(c1,1).fetype = [];
			else
				rt_1cl(c1,1).fetype = fetype(1:max(indx));
			end

			rt_1cl(c1,1).cfcc = t(56:58);

			rt_1cl(c1,1).frlong = fixnum(str2num(t(191:200)));
			rt_1cl(c1,1).frlat = fixnum(str2num(t(201:209)));
			rt_1cl(c1,1).tolong = fixnum(str2num(t(210:219)));
			rt_1cl(c1,1).tolat = fixnum(str2num(t(220:228)));

		end

		if strcmp(lower(t(56:57)),'a1')

			c2 = c2 + 1;

			rt_1a1(c2,1).tlid = str2num(t(6:15));

			fename = t(20:49);
			indx = find(~isspace(fename));
			if isempty(indx)
				rt_1a1(c2,1).fename = [];
			else
				rt_1a1(c2,1).fename = fename(1:max(indx));
			end

			fetype = t(50:53);
			indx = find(~isspace(fetype));
			if isempty(find(~isspace(fetype)))
				rt_1a1(c2,1).fetype = [];
			else
				rt_1a1(c2,1).fetype = fetype(1:max(indx));
			end

			rt_1a1(c2,1).cfcc = t(56:58);

			rt_1a1(c2,1).frlong = fixnum(str2num(t(191:200)));
			rt_1a1(c2,1).frlat = fixnum(str2num(t(201:209)));
			rt_1a1(c2,1).tolong = fixnum(str2num(t(210:219)));
			rt_1a1(c2,1).tolat = fixnum(str2num(t(220:228)));

		elseif strcmp(lower(t(56:57)),'a2')

			c3 = c3 + 1;

			rt_1a2(c3,1).tlid = str2num(t(6:15));

			fename = t(20:49);
			indx = find(~isspace(fename));
			if isempty(indx)
				rt_1a2(c3,1).fename = [];
			else
				rt_1a2(c3,1).fename = fename(1:max(indx));
			end

			fetype = t(50:53);
			indx = find(~isspace(fetype));
			if isempty(find(~isspace(fetype)))
				rt_1a2(c3,1).fetype = [];
			else
				rt_1a2(c3,1).fetype = fetype(1:max(indx));
			end

			rt_1a2(c3,1).cfcc = t(56:58);

			rt_1a2(c3,1).frlong = fixnum(str2num(t(191:200)));
			rt_1a2(c3,1).frlat = fixnum(str2num(t(201:209)));
			rt_1a2(c3,1).tolong = fixnum(str2num(t(210:219)));
			rt_1a2(c3,1).tolat = fixnum(str2num(t(220:228)));

		elseif strcmp(lower(t(56:57)),'a3')

			c4 = c4 + 1;

			rt_1a3(c4,1).tlid = str2num(t(6:15));

			fename = t(20:49);
			indx = find(~isspace(fename));
			if isempty(indx)
				rt_1a3(c4,1).fename = [];
			else
				rt_1a3(c4,1).fename = fename(1:max(indx));
			end

			fetype = t(50:53);
			indx = find(~isspace(fetype));
			if isempty(find(~isspace(fetype)))
				rt_1a3(c4,1).fetype = [];
			else
				rt_1a3(c4,1).fetype = fetype(1:max(indx));
			end

			rt_1a3(c4,1).cfcc = t(56:58);

			rt_1a3(c4,1).frlong = fixnum(str2num(t(191:200)));
			rt_1a3(c4,1).frlat = fixnum(str2num(t(201:209)));
			rt_1a3(c4,1).tolong = fixnum(str2num(t(210:219)));
			rt_1a3(c4,1).tolat = fixnum(str2num(t(220:228)));

		elseif strcmp(lower(t(56)),'b')

			c5 = c5 + 1;

			rt_1b(c5,1).tlid = str2num(t(6:15));

			fename = t(20:49);
			indx = find(~isspace(fename));
			if isempty(indx)
				rt_1b(c5,1).fename = [];
			else
				rt_1b(c5,1).fename = fename(1:max(indx));
			end

			fetype = t(50:53);
			indx = find(~isspace(fetype));
			if isempty(find(~isspace(fetype)))
				rt_1b(c5,1).fetype = [];
			else
				rt_1b(c5,1).fetype = fetype(1:max(indx));
			end

			rt_1b(c5,1).cfcc = t(56:58);

			rt_1b(c5,1).frlong = fixnum(str2num(t(191:200)));
			rt_1b(c5,1).frlat = fixnum(str2num(t(201:209)));
			rt_1b(c5,1).tolong = fixnum(str2num(t(210:219)));
			rt_1b(c5,1).tolat = fixnum(str2num(t(220:228)));

		elseif strcmp(lower(t(56)),'h')

			c6 = c6 + 1;

			rt_1h(c6,1).tlid = str2num(t(6:15));

			fename = t(20:49);
			indx = find(~isspace(fename));
			if isempty(indx)
				rt_1h(c6,1).fename = [];
			else
				rt_1h(c6,1).fename = fename(1:max(indx));
			end

			fetype = t(50:53);
			indx = find(~isspace(fetype));
			if isempty(find(~isspace(fetype)))
				rt_1h(c6,1).fetype = [];
			else
				rt_1h(c6,1).fetype = fetype(1:max(indx));
			end

			rt_1h(c6,1).cfcc = t(56:58);

			rt_1h(c6,1).frlong = fixnum(str2num(t(191:200)));
			rt_1h(c6,1).frlat = fixnum(str2num(t(201:209)));
			rt_1h(c6,1).tolong = fixnum(str2num(t(210:219)));
			rt_1h(c6,1).tolat = fixnum(str2num(t(220:228)));

		end

		rt1mat(line,1) = str2num(t(6:15));
		rt1mat(line,2) = fixnum(str2num(t(201:209)));
		rt1mat(line,3) = fixnum(str2num(t(191:200)));
		rt1mat(line,4) = fixnum(str2num(t(220:228)));
		rt1mat(line,5) = fixnum(str2num(t(210:219)));

	elseif isempty(t) | strcmp(lower(t),char(26))

		eof = 1;

	end

end

status = fclose(fid);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [polylat,polylong] = linkp(chainlat,chainlong)

%LINKP Links together lat/long chains to form polygons
%
%  Purpose
%		Links together lat/long chains to form polygons.  The
%		chains are separated by nans, and the whole array of
%		chains must begin and end with a nan.
%
%  Synopsis
%
%       [plat,plong] = linkp(clat,clong)


if nargin~=2;  error('Incorrect number of arguments');  end

%  form data
nanindx = find(isnan(chainlat));
nchains = length(nanindx) - 1;
lim = [nanindx(1:nchains)+1 nanindx(2:nchains+1)-1];
pts1 = [chainlat(lim(:,1)) chainlong(lim(:,1))];
pts2 = [chainlat(lim(:,2)) chainlong(lim(:,2))];

%  initialize link
if nchains==1
	initpt = pts1(1,:);
	endpt = pts2(1,:);
	newlim = lim(1,:);
	done = 1;
elseif all(pts1==pts2)
	newlim = lim(1,:);
	for n=2:length(pts1)
		newlim = [newlim; nan nan; lim(n,:)];
	end
	done = 1;
else
	found = 0;
	count = 0;
	while ~found
		count = count + 1;
		if pts1(count,1)~=pts2(count,1) | pts1(count,2)~=pts2(count,2)
			initpt = pts1(count,:);
			endpt = pts2(count,:);
			newlim = lim(count,:);
			found = 1;
		end
	end
	indx = (1:nchains)';
	rowindx = find(indx~=count);
	done = 0;
end

%  link chains
while ~done

	lim = lim(rowindx,:);
	pts1 = pts1(rowindx,:);
	pts2 = pts2(rowindx,:);

	indx = (1:length(rowindx))';

	indx1 = find(pts1(:,1)==endpt(1) & pts1(:,2)==endpt(2));
	indx2 = find(pts2(:,1)==endpt(1) & pts2(:,2)==endpt(2));

	if (length(indx1)+length(indx2))==1

		if ~isempty(indx1)
			row = indx1;
			newlim = [newlim; lim(row,:)];
			endpt = pts2(row,:);
		else
			row = indx2;
			newlim = [newlim; fliplr(lim(row,:))];
			endpt = pts1(row,:);
		end
		rowindx = find(indx~=row);

	elseif (length(indx1)+length(indx2))==2

		if ~isempty(indx1) & ~isempty(indx2)
			if indx1==indx2
				newlim = [newlim; lim(indx1,:)];
				rowindx = find(indx~=indx1);
			end
		else
			if ~isempty(indx1)
				newlim = [newlim; lim(indx1(1),:)];
				rowindx = find(indx~=indx1(1));
			elseif ~isempty(indx2)
				newlim = [newlim; lim(indx2(1),:)];
				rowindx = find(indx~=indx2(1));
			else
				if indx1<indx2
					newlim = [newlim; lim(indx1(1),:)];
					rowindx = find(indx~=indx1(1));
				else
					newlim = [newlim; lim(indx2(1),:)];
					rowindx = find(indx~=indx2(1));
				end
			end
		end

	elseif (length(indx1)+length(indx2))==3

		indxmat = [indx1 ones(size(indx1)); ...
				   indx2 2*ones(size(indx2))];
		for n=1:3
			if indxmat(n,2)==1
				temppt(n,:) = pts2(indxmat(n,1),:);
			elseif indxmat(n,2)==2
				temppt(n,:) = pts1(indxmat(n,1),:);
			end
		end
		found = 0; count = 0;
		while ~found & count<3
			count = count + 1;
			i = find(temppt(:,1)==temppt(count,1) & ...
					 temppt(:,2)==temppt(count,2));
			if length(i)>1
				found = 1;
				indxmat = indxmat(i,:);
			end
		end
		if ~found & count==3
			indxmat = [];
		end
		if ~isempty(indxmat)
			if indxmat(1,2)==1
				newlim = [newlim; lim(indxmat(1,1),:)];
			elseif indxmat(1,2)==2
				newlim = [newlim; fliplr(lim(indxmat(1,1),:))];
			end
			if indxmat(2,2)==1
				newlim = [newlim; fliplr(lim(indxmat(2,1),:))];
				endpt = pts1(indxmat(2,1),:);
			elseif indxmat(2,2)==2
				newlim = [newlim; lim(indxmat(2,1),:)];
				endpt = pts2(indxmat(2,1),:);
			end
			rowindx = find(indx~=indxmat(1,1) & ...
						   indx~=indxmat(2,1));
		else
			if ~isempty(indx1) & ~isempty(indx2)
				if indx1(1)<indx2(1)
					i = indx1(1);
					newlim = [newlim; lim(i,:)];
					endpt = pts2(i,:);
				else
					i = indx2(1);
					newlim = [newlim; fliplr(lim(i,:))];
					endpt = pts1(i,:);
				end
			elseif isempty(indx1)
				i = indx2(1);
				newlim = [newlim; fliplr(lim(i,:))];
				endpt = pts1(i,:);
			elseif isempty(indx2)
				i = indx1(1);
				newlim = [newlim; lim(i,:)];
				endpt = pts2(i,:);
			end
			rowindx = find(indx~=i);
		end
		clear temppt

	elseif (length(indx1)+length(indx2))==5

		indxmat = [indx1 ones(size(indx1)); ...
				   indx2 2*ones(size(indx2))];
		for n=1:5
			if indxmat(n,2)==1
				temppt(n,:) = pts2(indxmat(n,1),:);
			elseif indxmat(n,2)==2
				temppt(n,:) = pts1(indxmat(n,1),:);
			end
		end
		found = 0; count = 0;
		while ~found & count<5
			count = count + 1;
			i = find(temppt(:,1)==temppt(count,1) & ...
					 temppt(:,2)==temppt(count,2));
			if length(i)>1
				found = 1;
				indxmat = indxmat(i,:);
			end
		end
		if ~found & count==5
			indxmat = [];
		end
		if ~isempty(indxmat)
			if indxmat(1,2)==1
				newlim = [newlim; lim(indxmat(1,1),:)];
			elseif indxmat(1,2)==2
				newlim = [newlim; fliplr(lim(indxmat(1,1),:))];
			end
			if indxmat(2,2)==1
				newlim = [newlim; fliplr(lim(indxmat(2,1),:))];
				endpt = pts1(indxmat(2,1),:);
			elseif indxmat(2,2)==2
				newlim = [newlim; lim(indxmat(2,1),:)];
				endpt = pts2(indxmat(2,1),:);
			end
			rowindx = find(indx~=indxmat(1,1) & ...
						   indx~=indxmat(2,1));
		else
			if ~isempty(indx1) & ~isempty(indx2)
				if indx1(1)<indx2(1)
					i = indx1(1);
					newlim = [newlim; lim(i,:)];
					endpt = pts2(i,:);
				else
					i = indx2(1);
					newlim = [newlim; fliplr(lim(i,:))];
					endpt = pts1(i,:);
				end
			elseif isempty(indx1)
				i = indx2(1);
				newlim = [newlim; fliplr(lim(i,:))];
				endpt = pts1(i,:);
			elseif isempty(indx2)
				i = indx1(1);
				newlim = [newlim; lim(i,:)];
				endpt = pts2(i,:);
			end
			rowindx = find(indx~=i);
		end
		clear temppt

% 	else
% 
% 		newlim
% 		error('case error')

	else
 
        val = length(indx1)+length(indx2);
		indxmat = [indx1 ones(size(indx1)); ...
				   indx2 2*ones(size(indx2))];
		for n=1:val
			if indxmat(n,2)==1
				temppt(n,:) = pts2(indxmat(n,1),:);
			elseif indxmat(n,2)==2
				temppt(n,:) = pts1(indxmat(n,1),:);
			end
		end
		found = 0; count = 0;
		while ~found & count<val
			count = count + 1;
			i = find(temppt(:,1)==temppt(count,1) & ...
					 temppt(:,2)==temppt(count,2));
			if length(i)>1
				found = 1;
				indxmat = indxmat(i,:);
			end
		end
		if ~found & count==val
			indxmat = [];
		end
		if ~isempty(indxmat)
			if indxmat(1,2)==1
				newlim = [newlim; lim(indxmat(1,1),:)];
			elseif indxmat(1,2)==2
				newlim = [newlim; fliplr(lim(indxmat(1,1),:))];
			end
			if indxmat(2,2)==1
				newlim = [newlim; fliplr(lim(indxmat(2,1),:))];
				endpt = pts1(indxmat(2,1),:);
			elseif indxmat(2,2)==2
				newlim = [newlim; lim(indxmat(2,1),:)];
				endpt = pts2(indxmat(2,1),:);
			end
			rowindx = find(indx~=indxmat(1,1) & ...
						   indx~=indxmat(2,1));
		else
			if ~isempty(indx1) & ~isempty(indx2)
				if indx1(1)<indx2(1)
					i = indx1(1);
					newlim = [newlim; lim(i,:)];
					endpt = pts2(i,:);
				else
					i = indx2(1);
					newlim = [newlim; fliplr(lim(i,:))];
					endpt = pts1(i,:);
				end
			elseif isempty(indx1)
				i = indx2(1);
				newlim = [newlim; fliplr(lim(i,:))];
				endpt = pts1(i,:);
			elseif isempty(indx2)
				i = indx1(1);
				newlim = [newlim; lim(i,:)];
				endpt = pts2(i,:);
			end
			rowindx = find(indx~=i);
		end
		clear temppt

	end

	if all(isempty(rowindx)) & all(endpt==initpt)

		done = 1;

	elseif ~all(isempty(rowindx)) & all(endpt==initpt)

		found = 0;
		while ~found
			newlim = [newlim; nan nan; lim(rowindx(1),:)];
			initpt = pts1(rowindx(1),:);
			endpt = pts2(rowindx(1),:);
			if length(rowindx)==1
				found = 1;
				done = 1;
			else
				rowindx = rowindx(2:length(rowindx));
				if initpt(1)~=endpt(1) | initpt(2)~=endpt(2)
					found = 1;
				end
			end
		end

	end

end

newlim = [newlim; nan nan];

polylat = [];
polylong = [];
initpt = [chainlat(newlim(1,1)) chainlong(newlim(1,1))];

for n=1:length(newlim(:,1))

	if ~all(isnan(newlim(n,:)))
		if newlim(n,1)<newlim(n,2)
			templat = chainlat(newlim(n,1):newlim(n,2)-1);
			templong = chainlong(newlim(n,1):newlim(n,2)-1);
		elseif newlim(n,1)>newlim(n,2)
			templat = chainlat(newlim(n,2)+1:newlim(n,1));
			templong = chainlong(newlim(n,2)+1:newlim(n,1));
			templat = flipud(templat);
			templong = flipud(templong);
		end
	else
		templat = [initpt(1); nan];
		templong = [initpt(2); nan];
		if n~=length(newlim(:,1))
			initpt = [chainlat(newlim(n+1,1)) ...
					  chainlong(newlim(n+1,2))];
		end
	end

	polylat = [polylat; templat];
	polylong = [polylong; templong];

end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [lat,long] = landpoly(land,rt1mat,rt_2,lat_2,long_2,rt_8,rt_i)

%LANDPOLY Produces all the polygons in an area landmark
%
%  Purpose
%		Produces all the polygons in an area landmark.  The
%		polygons are separated by nans and can be patched with
%		patchesm.
%
%  Synopsis
%
%       [lat,long] = landpoly(land,rt1mat,rt_2,lat_2,long_2,rt_8,rt_i)

if nargin~=7;  error('Incorrect number of arguments');  end

polyid = rt_8(find(rt_8(:,2)==land),1);						% list of polygon id #'s for this landmark

lat = [];
long = [];
for n=1:length(polyid)										% loop through each polygon

	indxl = find(rt_i(:,2)==polyid(n));
	indxr = find(rt_i(:,3)==polyid(n));
	tlid = [rt_i(indxl,1); rt_i(indxr,1)];					% list of tlid chain #'s for this polygon

% form chains in polygon (separated by nans)

	chain = [nan nan];
	for m=1:length(tlid)
		indx1 = find(rt1mat(:,1)==tlid(m));
		frlat = rt1mat(indx1,2);
		frlong = rt1mat(indx1,3);
		tolat = rt1mat(indx1,4);
		tolong = rt1mat(indx1,5);
		indx2 = find(rt_2(:,1)==tlid(m));
		if isempty(indx2)
			if tolat~=frlat | tolong~=frlong
				chain = [chain;frlat frlong;tolat tolong;nan nan];
			end
		else
			templat = [];
			templong = [];
			rtsq = rt_2(indx2,2);
			[rtsq,order] = sort(rtsq);
			for i=1:length(rtsq)
				templat = [templat lat_2{indx2(order(i))}];
				templong = [templong long_2{indx2(order(i))}];
			end
			chain = [chain;frlat frlong;templat' templong';...
					 tolat tolong;nan nan];
		end
	end

% link chains in polygon
	[lt,lg] = linkp(chain(:,1),chain(:,2));
	lat = [lat; lt];
	long = [long; lg];

end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Hydrography,AreaLandmark,PointLandmark] = landmk(rt1mat,rt_2,lat_2,long_2,rt_7,rt_8,rt_i)

%LANDMARK  Extracts landmark features from TIGER/Line files.
%
%	Purpose
%		Processes information into a data structure containing
%		hydrography patches, area landmark patches, and point
%		landmarks.
%
%	Synopsis
%
%		[Hydrography,AreaLandmark,PointLandmark] = landmk(rt1mat,rt_2,lat_2,long_2,rt_7,rt_8,rt_i)
%

c1 = 0; c2 = 0; c3 = 0;
h2oindx = []; areaindx = []; ptindx = [];
for n=1:length(rt_7)
	if strcmp(rt_7(n).cfcc(1),'H')
		c1 = c1 + 1;
		h2oindx(c1,1) = n;
	elseif strcmp(rt_7(n).cfcc(1),'D')
		if isempty(rt_7(n).lalat)
			c2 = c2 + 1;
			areaindx(c2,1) = n;
		else
			c3 = c3 + 1;
			ptindx(c3,1) = n;
		end
	end
end

Hydrography = []; AreaLandmark = []; PointLandmark = [];

h2ocount = 0;
for n=1:length(h2oindx)
	[lat,long] = landpoly(h2oindx(n),rt1mat,rt_2,lat_2,long_2,rt_8,rt_i);
	Hydrography(n,1).lat = lat;
	Hydrography(n,1).long = long;
	if isempty(rt_7(h2oindx(n)).laname)
		Hydrography(n,1).tag = 'unknown';
	else
		Hydrography(n,1).tag = rt_7(h2oindx(n)).laname;
	end
	Hydrography(n,1).type = 'patch';
	Hydrography(n,1).altitude = 0.2;
	Hydrography(n,1).otherproperty = {'c'};
end

for n=1:length(areaindx)

	[lat,long] = landpoly(areaindx(n),rt1mat,rt_2,lat_2,long_2,rt_8,rt_i);
	AreaLandmark(n,1).lat = lat;
	AreaLandmark(n,1).long = long;
	if isempty(rt_7(areaindx(n)).laname)
		AreaLandmark(n,1).tag = 'unknown';
	else
		AreaLandmark(n,1).tag = rt_7(areaindx(n)).laname;
	end
	AreaLandmark(n,1).type = 'patch';
	AreaLandmark(n,1).altitude = 0.1;
	AreaLandmark(n,1).otherproperty = {[1 .7 .12]};
end

for n=1:length(ptindx)
	PointLandmark(n,1).lat = rt_7(ptindx(n)).lalat;
	PointLandmark(n,1).long = rt_7(ptindx(n)).lalong;
	if isempty(rt_7(ptindx(n)).laname)
		PointLandmark(n,1).tag = 'unknown';
	else
		PointLandmark(n,1).tag = rt_7(ptindx(n)).laname;
	end
	PointLandmark(n,1).type = 'line';
	PointLandmark(n,1).altitude = 0.4;
	PointLandmark(n,1).otherproperty = {'r','markersize',12};
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = fixnum(x)

if nargin~=1
	error('Incorrect number of arguments.')
end

y = x*1e-6;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CountyLine = county(rt_1cl,rt_2,lat_2,long_2,countyname)

%COUNTYLINE  Extracts county line from TIGER/Line files
%
%	Purpose
%		Processes information into a data structure containing the
%		linked polygon of the county.
%
%	Synopsis
%
%		CountyLine = county(rt_1cl,rt_2,lat_2,long_2,countyname)
%

chain = [nan nan];
for n=1:length(rt_1cl)

	frlat = rt_1cl(n).frlat;
	frlong = rt_1cl(n).frlong;
	tolat = rt_1cl(n).tolat;
	tolong = rt_1cl(n).tolong;

	indx2 = find(rt_2(:,1)==rt_1cl(n).tlid);
	if isempty(indx2)
		chain = [chain;frlat frlong;tolat tolong;nan nan];
	else
		templat = [];
		templong = [];
		rtsq = rt_2(indx2,2);
		[rtsq,order] = sort(rtsq);
		for i=1:length(rtsq)
			templat = [templat lat_2{indx2(order(i))}];
			templong = [templong long_2{indx2(order(i))}];
		end
		chain = [chain;frlat frlong;templat' templong';...
				 tolat tolong;nan nan];
	end
end

[lt,lg] = linkp(chain(:,1),chain(:,2));

CountyLine.lat = lt;
CountyLine.long = lg;
CountyLine.tag = countyname;
CountyLine.type = 'patch';
CountyLine.altitude = -0.1;
CountyLine.otherproperty = {'y'};

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
