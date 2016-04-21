function [newlat,newlon]=crossfix(lat,long,az,in4,in5,in6,in7)

%CROSSFIX  Computes cross fix positions for bearings and ranges
%
%  [newlat,newlon] = CROSSFIX(lat,long,az) computes cross fixes
%  (intersections) to locate a point when its great circle azimuths
%  or ranges from fixed points are known.  Takes each input case
%  and pairs it with all other input cases.  Since circles
%  intersect twice, in general, two intersection points
%  are returned for each such pairing.  NaN's are returned
%  for pairings which do not intersect.
%
%  [newlat,newlon] = CROSSFIX(lat,long,az,case) uses the vector, case,
%  with a 1 (default) for each point designated by azimuth; a zero
%  indicates that "az" for that point is a range in angle units.
%
%  [newlat,newlon] = CROSSFIX(lat,long,az,case,drlat,drlong) uses
%  the dead reckoned latitude and longitude inputs to resolve
%  each intersection pair ambiguity.  The point closest to the
%  dead reckoned position is returned.  When this option is used,
%  any non-intersecting pair results in a "no fix" warning and
%  in empty output matrices.
%
%  [newlat,newlon] = CROSSFIX(lat,long,az,'units'),
%  [newlat,newlon] = CROSSFIX(lat,long,az,case,'units'),
%  [newlat,newlon] = CROSSFIX(lat,long,az,drlat,drlong,'units') and
%  [newlat,newlon] = CROSSFIX(lat,long,az,case,drlat,drlong,'units')
%  uses the input units to define the angle units of the inputs and
%  outputs.
%
%  mat = CROSSFIX(...) returns a single output, where mat = [newlat newlon].
%
%  See also SCXSC, GCXGC, GCXSC, RHXRH, POLYXPOLY

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.11.4.1 $ $Date: 2003/08/01 18:15:42 $
%  Written by:  E. Brown, E. Byrns



if nargin < 3
    error('Incorrect number of arguments')

elseif nargin==3
	case0 = [];    units = [];   drlat = [];   drlong = [];

elseif nargin==4
	if isstr(in4)
		units = in4;    case0 = [];   drlat = [];   drlong = [];
	else
		units = [];     case0=in4;    drlat = [];   drlong = [];
	end

elseif nargin==5
	case0=in4;      units=in5;   drlat = [];   drlong = [];

elseif nargin==6
	if isstr(in6)
		drlat = in4;    drlong = in5;   units  = in6;     case0  = [];
	else
		case0  = in4;    drlat  = in5;   drlong = in6;     units = [];
	end

elseif nargin==7
	case0 = in4;    drlat = in5;    drlong = in6;    units = in7;

end

%  Empty argument tests

if isempty(units);   units = 'degrees';         end
if isempty(case0);    case0  = ones(size(lat));   end

%  Input dimension tests

if any([ndims(lat) ndims(long) ndims(az)] > 2)
    error('Input matrices can not contain pages')

elseif ~isequal(size(lat),size(long),size(az))
	error('Latitude, longitude, and azimuth must be same size')

elseif max(size(lat)) == 1
	error('At least two geographic objects are required to crossfix')

elseif ~all(size(case0)==size(lat))
	error('Case vector must be empty or same size as latitude input')
end

%  Convert input angles to degrees

lat  = angledim(lat,units,'degrees');
long = angledim(long,units,'degrees');
az   = angledim(az,units,'degrees');

%  Convert dead reckoning coordinates to degrees

if ~isempty(drlat)
	if max(size(drlat)) ~= 1 | max(size(drlong)) ~= 1
		error('Dead reckoning coordinates must be scalars')
	end
	drlat  = angledim(drlat,units,'degrees');
	drlong = angledim(drlong,units,'degrees');
end

% Find those cases which are lines of position;
% these are great circles; convert them to small
% circle format.

indx=find(case0==1);

[lat(indx),long(indx),az(indx)]=gc2sc(lat(indx),long(indx),az(indx),'degrees');

pair=combntns(1:length(case0),2);

[newlat,newlon]=scxsc(lat(pair(:,1)),long(pair(:,1)),az(pair(:,1)),...
					  lat(pair(:,2)),long(pair(:,2)),az(pair(:,2)),'degrees');


% select best candidate intersections based on dead reckon positions

if nargin>5
	if any(isnan(newlat(:)))
		warning('No fix')
		newlat=[];      newlon=[];
	else
		for i=1:size(pair,1)
			select(i)=i;
			d1 = distance(newlat(i,1),newlon(i,1),drlat,drlong);
			d2 = distance(newlat(i,2),newlon(i,2),drlat,drlong);
			if d1 > d2
				select(i)=size(pair,1)+i;
			end
		end
		newlat=newlat(:);newlat=newlat(select);
		newlon=newlon(:);newlon=newlon(select);
	end
end

%  Convert outputs to desired units

newlat  = angledim(newlat,'degrees',units);
newlon = angledim(newlon,'degrees',units);

%  Set the output argument if necessary

if nargout < 2;  newlat = [newlat newlon];  end

