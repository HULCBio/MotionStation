function varargout = utmzone(varargin)

%UTMZONE  Universal Transverse Mercator zone
% 
%   ZONE = UTMZONE selects a Universal Transverse Mercator (UTM) zone with
%   a graphical user interface.
% 
%   ZONE = UTMZONE(lat,long) returns the UTM zone containing the geographic 
%   coordinates.  If lat and long are vectors, the zone containing the 
%   geographic mean of the data set is returned.  The geographic coordinates 
%   must be in units of degrees.
%   
%   ZONE = UTMZONE(mat), where mat is or the form [LAT LONG]
% 
%   [LATLIM,LONLIM] = UTMZONE('zone'), where zone is valid UTM zone 
%   designation, returns the geographic limits of the zone.  Valid UTM zones 
%   designations are numbers, or numbers followed by a single letter.  
%   Example: '31' or '31N'.  The returned limits are in units of degrees.
% 
%   LIM = UTMZONE('ZONE') returns the limits in a single vector output.
% 
%   [ZONE,MSG] = UTMZONE(...)  and [LATLIM,LONLIM,MSG] = UTMZONE(...)  
%   returns a message if there is an error.  MSG is empty when there are no 
%   errors.
% 
%   See also UTMZONEUI, UTMGEOID

%  Written by A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.5.4.1 $   $Date: 2003/08/01 18:24:40 $



if nargin == 0
	varargout{1} = utmzoneui;
	return
elseif nargin == 1
	if isstr(varargin{1})
		zone = upper(varargin{1});
		findit = 'limits';
	else
		ll = varargin{1};
		if size(ll,2) ~= 2
			error('Lat-long matrix must have two columns')
		end
		lat = ll(:,1);
		lon = ll(:,2);
		clear ll
		findit = 'zone';
	end
elseif nargin == 2
	lat = varargin{1};
	lon = varargin{2};
	findit = 'zone';
else
	error('Incorrect number of arguments')
end



if strcmp(findit,'zone')
		
	% find geographic centroid of data set
	if length(lat)>1
		lat = lat(~isnan(lat));
		lon = lon(~isnan(lon));
		[lat,lon] = meanm(lat,lon);
	end

	msg = []; zone = [];
	if (lat<-80 | lat>84) | (lon<-180 | lon>180)
		msg = 'Coordinates not within UTM zone limits';
	end

	% determine zone based on lat,lon
	% note: for coordinates on the boundaries of a zone, the zone corresponding
	%		to the lower/left coordinate it used, except for the case of the 
	%		upper/right boundaries.

	if isempty(msg)
		
		lts = [-80:8:72 84]'; lns = [-180:6:180]';
		latzones = char([67:72 74:78 80:88]');
		
		indx = find(lts<=lat);  ltindx = indx(max(indx));
		indx = find(lns<=lon);  lnindx = indx(max(indx));
		
		if ltindx<1 | ltindx>21,	ltindx = [];
		elseif ltindx==21,			ltindx = 20;	end
	
		if lnindx<1 | lnindx>61,	lnindx = [];
		elseif lnindx==61,			lnindx = 60;	end

		zone = [num2str(lnindx) latzones(ltindx)];

	else

		if nargout<2,  error(msg);	 end
	
	end

	varargout{1} = zone;
	if nargout==2,  varargout{2} = msg;  end

elseif strcmp(findit,'limits')

	msg = [];
	if isstr(zone) & length(zone)<=3 & length(zone)>=1
		latzones = char([67:72 74:78 80:88]');
		if length(zone)==1
			lnindx = str2num(zone);  ltindx = nan;
		elseif length(zone)==2
			num = str2num(zone);
			if isempty(num)
				lnindx = str2num(zone(1));
				ltindx = strmatch(zone(2),latzones);
			else
				lnindx = num;  ltindx = nan;
			end
		elseif length(zone)==3
			lnindx = str2num(zone(1:2));  ltindx = strmatch(zone(3),latzones);
		end
	else
		msg = 'UTM zone must be a 1-, 2-, or 3-element string';
	end

	if isempty(msg)
		if isempty(lnindx) | (lnindx<1 | lnindx>60) | isempty(ltindx)
			msg = sprintf('Incorrect UTM zone designation. Recognized zones are integers \nfrom 1 to 60 or numbers followed by letters from C to X.');
		end
	end

	latlim = [];  lonlim = [];
	
	if isempty(msg)
		
		latlims = [(-80:8:64)' (-72:8:72)'; 72 84];
		lonlims = [(-180:6:174)' (-174:6:180)'];
		
		if isnan(ltindx)
			latlim = [-80 84];
		else
			latlim = latlims(ltindx,:);
		end
		lonlim = lonlims(lnindx,:);
		
	end

	if nargout < 2
		if ~isempty(msg),  error(msg),  end
		varargout{1} = [latlim lonlim];
	elseif nargout==2
		varargout{1} = latlim;  varargout{2} = lonlim;
		if ~isempty(msg),  error(msg),  end
	elseif nargout==3
		varargout{1} = latlim;  varargout{2} = lonlim;  varargout{3} = msg;
	end

end

