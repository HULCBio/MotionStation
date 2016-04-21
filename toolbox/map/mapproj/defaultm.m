function [mstruct,msg] = defaultm(mstruct)
%DEFAULTM Initialize or reset projection properties to default values.
%
%  MSTRUCT = DEFAULTM initializes the map structure.
%
%  MSTRUCT = DEFAULTM(PROJECTION) initializes the map structure for the
%  requested PROJECTION string.
%
%  MSTRUCT= DEFAULTM(MSTRUCT) checks the map structure contents and sets
%  appropriate defaults.
%
%  [MSTRUCT, MSG] = DEFAULTM(...) returns a string indicating any error
%  encountered.
%
%  See also AXESM, MAPLIST, MAPS, MFWDTRAN, MINVTRAN, PROJFWD, PROJINV,
%  PROJLIST.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.1.6.2 $    $Date: 2004/02/01 21:59:00 $

%  Initialize the output argument if necessary

if nargout == 2;   msg = [];    end


clrstr = get(0,'DefaultAxesXcolor');   %  Set the default color value

if nargin == 0 | isstr(mstruct)
         if nargin == 0;              mstruct.mapprojection = [];
            elseif isstr(mstruct);    mstruct.mapprojection = mstruct;
            else;                     mstruct.mapprojection = [];
         end

     mstruct.zone             = [];
     mstruct.angleunits       = 'degrees';
     mstruct.aspect           = 'normal';
	 mstruct.falsenorthing    = [];
	 mstruct.falseeasting     = [];
	 mstruct.fixedorient      = [];
	 mstruct.geoid            = [1 0];
	 mstruct.maplatlimit      = [];
	 mstruct.maplonlimit      = [];
	 mstruct.mapparallels     = [];
	 mstruct.nparallels       = 0;
	 
	 mstruct.origin           = [];
	 mstruct.scalefactor      = [];
     mstruct.trimlat          = [];
	 mstruct.trimlon          = [];

	 mstruct.frame      = [];
	 mstruct.ffill      = 100;
	 mstruct.fedgecolor = clrstr;
	 mstruct.ffacecolor = 'none';
	 mstruct.flatlimit  = [];
	 mstruct.flinewidth = 2;
     mstruct.flonlimit  = [];

	 mstruct.grid        = [];       %  Initialized empty to differ if user sets
	 mstruct.galtitude   = inf;      %  Inf is a signal to put the grid at
	 mstruct.gcolor      = clrstr;   %  the upper z axis limit
	 mstruct.glinestyle  = ':';
	 mstruct.glinewidth  = 0.5;

	 mstruct.mlineexception    = [];
	 mstruct.mlinefill         = 100;
	 mstruct.mlinelimit        = [];
	 mstruct.mlinelocation     = [];
	 mstruct.mlinevisible      = 'on';

	 mstruct.plineexception    = [];
	 mstruct.plinefill         = 100;
	 mstruct.plinelimit        = [];
	 mstruct.plinelocation     = [];
	 mstruct.plinevisible      = 'on';

     mstruct.fontangle   = 'normal';
	 mstruct.fontcolor   = clrstr;
     mstruct.fontname    = 'helvetica';
     mstruct.fontsize    = 9;
     mstruct.fontunits   = 'points';
     mstruct.fontweight  = 'normal';
	 mstruct.labelformat = 'compass';
	 mstruct.labelrotation = 'off';
	 mstruct.labelunits  = [];

     mstruct.meridianlabel   = [];
     mstruct.mlabellocation  = [];
	 mstruct.mlabelparallel  = [];
	 mstruct.mlabelround     = 0;

     mstruct.parallellabel   = [];
     mstruct.plabellocation  = [];
	 mstruct.plabelmeridian  = [];
	 mstruct.plabelround     = 0;

     if ~isempty(mstruct.mapprojection)
          mstruct = feval(mstruct.mapprojection,mstruct);
     end
     return

end

%  Ensure that the read only properties are filled in
%  Simply stop if they are empty

if length(mstruct.trimlat) ~= 2
	 error('ReadOnly TRIMLAT must be a 2 element vector')
elseif length(mstruct.trimlon) ~= 2
	 error('ReadOnly TRIMLON must be a 2 element vector')
elseif length(mstruct.nparallels) ~= 1
     error('ReadOnly NPARALLELS must be a scalar')
end

%  Ensure that a projection file is specified

if isempty(mstruct.mapprojection)
    msg = 'No projection specified';
	if nargout ~= 2;   error(msg);   end
	return
end

%  Note that 'DMS' angle units can not be added or subtracted.  So, where
%  necessary on all the following calculations, angles are transformed
%  into degrees for calculation purposes.  The user may have switched
%  the angle units to 'DMS'.  Although DMS can't be added or subtracted,
%  it does just fine on min and max operations.

%  UTM projection zone

if strcmp(mstruct.mapprojection,'utm')
	
	if isempty(mstruct.zone)
		mstruct.zone = '31N';
	end

	[ltlim,lnlim,txtmsg] = utmzone(mstruct.zone);
	
	if isempty(txtmsg)
		if isempty(mstruct.geoid)
			geoid = utmgeoid(mstruct.zone);
			mstruct.geoid = geoid(1,:);
		end
		if isempty(mstruct.maplatlimit)
			mstruct.maplatlimit = angledim(ltlim,'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.maplonlimit)
			mstruct.maplonlimit = angledim(lnlim,'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.flatlimit)
			mstruct.flatlimit = angledim(ltlim,'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.flonlimit)
			mstruct.flonlimit = angledim([-3 3],'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.origin)
			mstruct.origin = angledim([0 min(lnlim)+3 0],'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.mlinelocation)
			mstruct.mlinelocation = angledim(1,'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.plinelocation)
			mstruct.plinelocation = angledim(1,'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.mlabellocation)
			mstruct.mlabellocation = angledim(1,'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.plabellocation)
			mstruct.plabellocation = angledim(1,'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.falsenorthing)
			if min(ltlim)>=0 & max(ltlim)>0		% zone in northern hemisphere
				mstruct.falsenorthing = 0;
			elseif min(ltlim)<0 & max(ltlim)<=0	% zone in southern hemisphere
				mstruct.falsenorthing = 1e7;
			else								% zone in both
				mstruct.falsenorthing = 0;	%*% set to this for now
			end
		end
	end
end

%  UPS projection zone

if strcmp(mstruct.mapprojection,'ups')
	
	if isempty(mstruct.zone)
		mstruct.zone = 'north';
	end

	if isempty(mstruct.geoid)
		mstruct.geoid = almanac('earth','international','m');
	end

	if strmatch(mstruct.zone,'north')

		mstruct.zone = 'north';
		if isempty(mstruct.maplatlimit)
			mstruct.maplatlimit = angledim([84 90],'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.flatlimit)
			mstruct.flatlimit = angledim([-Inf 6],'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.origin)
			mstruct.origin = angledim([90 0 0],'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.mlinelimit)
			mstruct.mlinelimit = angledim([84 89],'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.mlabelparallel)
			mstruct.mlabelparallel = angledim(84,'degrees',mstruct.angleunits);
		end

	elseif strmatch(mstruct.zone,'south')

		mstruct.zone = 'south';
		if isempty(mstruct.maplatlimit)
			mstruct.maplatlimit = angledim([-90 -80],'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.flatlimit)
			mstruct.flatlimit = angledim([-Inf 10],'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.origin)
			mstruct.origin = angledim([-90 0 0],'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.mlinelimit)
			mstruct.mlinelimit = angledim([-89 -80],'degrees',mstruct.angleunits);
		end
		if isempty(mstruct.mlabelparallel)
			mstruct.mlabelparallel = angledim(-80,'degrees',mstruct.angleunits);
		end

	end

	if isempty(mstruct.maplonlimit)
		mstruct.maplonlimit = angledim([-180 180],'degrees',mstruct.angleunits);
	end
	if isempty(mstruct.flonlimit)
		mstruct.flonlimit = angledim([-180 180],'degrees',mstruct.angleunits);
	end
	if isempty(mstruct.mlineexception)
		mstruct.mlineexception = angledim(-180:90:180,'degrees',mstruct.angleunits);
	end
	if isempty(mstruct.mlinelocation)
		mstruct.mlinelocation = angledim(15,'degrees',mstruct.angleunits);
	end
	if isempty(mstruct.plinelocation)
		mstruct.plinelocation = angledim(1,'degrees',mstruct.angleunits);
	end
	if isempty(mstruct.mlabellocation)
		mstruct.mlabellocation = angledim(15,'degrees',mstruct.angleunits);
	end
	if isempty(mstruct.plabellocation)
		mstruct.plabellocation = angledim(1,'degrees',mstruct.angleunits);
	end
	
end

%  Geoid

if isempty(mstruct.geoid)
      mstruct.geoid = [1 0];
end

%  Latitude Frame limits

if isempty(mstruct.flatlimit)
      mstruct.flatlimit = mstruct.trimlat;
elseif length(mstruct.flatlimit) == 1
	  mstruct.flatlimit = min(mstruct.flatlimit,max(mstruct.trimlat));
      mstruct.flatlimit = [-inf mstruct.flatlimit];
else
     latup  = min(max(mstruct.flatlimit),max(mstruct.trimlat));
     latlow = max(min(mstruct.flatlimit),min(mstruct.trimlat));
     mstruct.flatlimit = [latlow latup];
end


%  Longitude Frame limits

if isempty(mstruct.flonlimit)
      mstruct.flonlimit = mstruct.trimlon;
else
     lonup  = min(max(mstruct.flonlimit),max(mstruct.trimlon));
     lonlow = max(min(mstruct.flonlimit),min(mstruct.trimlon));
     mstruct.flonlimit = [lonlow lonup];
end


%  Default latitude and longitude limits

if isempty(mstruct.maplatlimit)
    mstruct.maplatlimit = angledim([-90 90],'degrees',mstruct.angleunits);
end

if isempty(mstruct.maplonlimit)
	mstruct.maplonlimit = angledim([-180 180],'degrees',mstruct.angleunits);
end

%  Origin property.  Default is [0 lat, centered lon,  0 orientation]
%  If only one element is provided, it is assumed to be a center longitude

if isempty(mstruct.origin)
    lonlimit       = angledim(mstruct.maplonlimit,mstruct.angleunits,'degrees');
    centerlon      = min(lonlimit)+diff(lonlimit)/2;
    mstruct.origin = angledim([0   centerlon  0],'degrees',mstruct.angleunits);

elseif length(mstruct.origin) == 1
    mstruct.origin = [0 mstruct.origin 0];

elseif length(mstruct.origin) == 2
    mstruct.origin = [mstruct.origin  0];
end

% False easting and northing, scalefactor

if isempty(mstruct.falseeasting); 	mstruct.falseeasting = 0; 	end
if isempty(mstruct.falsenorthing); 	mstruct.falsenorthing = 0;	end
if isempty(mstruct.scalefactor); 	mstruct.scalefactor = 1; 	end


%  Transform some data into degress for further calculations

origin   = angledim(mstruct.origin,mstruct.angleunits,'degrees');
lonlimit = angledim(mstruct.maplonlimit,mstruct.angleunits,'degrees');
latlimit = angledim(mstruct.maplatlimit,mstruct.angleunits,'degrees');
framelon = angledim(mstruct.flonlimit,mstruct.angleunits,'degrees');
framelat = angledim(mstruct.flatlimit,mstruct.angleunits,'degrees');


%  Parallel property.  Default is +- 1/3 of latitude range.
%  If the projection does not use parallels, then this property
%  is ignored by the projection

if isempty(mstruct.mapparallels)
	upperlat = max(latlimit)-diff(latlimit)/6;
	lowerlat = min(latlimit)+diff(latlimit)/6;

	middlelat = max(latlimit)-diff(latlimit)/3;


    if mstruct.nparallels == 1
	    mstruct.mapparallels = angledim(middlelat,'degrees',mstruct.angleunits);
    elseif mstruct.nparallels == 2
	    mstruct.mapparallels = angledim([upperlat  lowerlat],'degrees',mstruct.angleunits);
    end
end

%  Set the map and frame limits based upon features of the origin.
%  Only a local hour angle shift can be provided for this calculation to work.
%  In this case, the map and limits are truncated to the smaller of
%  the frame limits or current map limits.

if all(mstruct.origin([1,3]) == 0) & all(~isinf(framelat))
    lowerlat = max(min(latlimit),min(framelat));
	upperlat = min(max(latlimit),max(framelat));

    upperdel = max(lonlimit)-origin(2);   %  Compute the upper and lower
	upperrem = max(0,upperdel-180);       %  longitude limts from the
	lowerdel = min(lonlimit)-origin(2);   %  map origin.  Account for
	lowerrem = min(0,lowerdel+180);	      %  wrapping at 180 degrees
	upperdel = upperdel - upperrem + abs(lowerrem);
	lowerdel = lowerdel - lowerrem - abs(upperrem);

	lowerlondel = max(lowerdel,min(framelon));  %  Take smaller of frame limits
	upperlondel = min(upperdel,max(framelon));  %  or map delta from origin

	framelon = [lowerlondel upperlondel];  %  Save the degree version for
    framelat = [lowerlat upperlat];        %  potential later usage
	lonlimit = framelon + origin(2);   %  Account for local hr angle shift
    latlimit = [lowerlat upperlat];

%  Convert back to the proper units

    mstruct.flonlimit = angledim(framelon,'degrees',mstruct.angleunits);
    mstruct.flatlimit = angledim(framelat,'degrees',mstruct.angleunits);
    mstruct.maplonlimit = angledim(lonlimit,'degrees',mstruct.angleunits);
    mstruct.maplatlimit = angledim(latlimit,'degrees',mstruct.angleunits);

end


%  Default Frame Properties

if isempty(mstruct.frame);           mstruct.frame = 'off';          end
if isempty(mstruct.fedgecolor);      mstruct.fedgecolor = clrstr;    end
if isempty(mstruct.ffacecolor);      mstruct.ffacecolor = 'none';    end
if isempty(mstruct.flinewidth);      mstruct.flinewidth = 2;         end
if isempty(mstruct.ffill);           mstruct.ffill = 100;            end

%  Default Grid Properties

if isempty(mstruct.grid);           mstruct.grid = 'off';          end
if isempty(mstruct.galtitude);      mstruct.galtitude = inf;       end
if isempty(mstruct.gcolor);         mstruct.gcolor = clrstr;       end
if isempty(mstruct.glinestyle);     mstruct.glinestyle = ':';      end
if isempty(mstruct.glinewidth);     mstruct.glinewidth = 0.5;      end
if isempty(mstruct.mlinefill);      mstruct.mlinefill = 100;       end
if isempty(mstruct.plinefill);      mstruct.plinefill = 100;       end

if isempty(mstruct.mlinevisible);   mstruct.mlinevisible = 'on';   end
if isempty(mstruct.plinevisible);   mstruct.plinevisible = 'on';   end

if isempty(mstruct.plinelocation)
    mstruct.plinelocation = angledim(15,'degrees',mstruct.angleunits);
end

if isempty(mstruct.mlinelocation)
    mstruct.mlinelocation = angledim(30,'degrees',mstruct.angleunits);
end

%  Default label units

if isempty(mstruct.labelunits);      mstruct.labelunits = mstruct.angleunits;  end

%  Default Meridian Label Properties

if isempty(mstruct.meridianlabel);   mstruct.meridianlabel = 'off';             end

if isempty(mstruct.mlabelparallel)
	mstruct.mlabelparallel = max(mstruct.maplatlimit);
elseif ~isstr(mstruct.mlabelparallel)
     upper = max(mstruct.maplatlimit);    lower = min(mstruct.maplatlimit);
	 mstruct.mlabelparallel = max(min(mstruct.mlabelparallel,upper),lower);
elseif isstr(mstruct.mlabelparallel)
     switch mstruct.mlabelparallel
	     case 'north',    mstruct.mlabelparallel = max(mstruct.maplatlimit);
	     case 'south',    mstruct.mlabelparallel = min(mstruct.maplatlimit);
	     case 'equator',  mstruct.mlabelparallel = 0;
     end
end

if isempty(mstruct.mlabellocation)
    mstruct.mlabellocation = mstruct.mlinelocation;
end

%  Default Parallel Label Properties

if isempty(mstruct.parallellabel);   mstruct.parallellabel = 'off';   end

if isempty(mstruct.plabelmeridian)
	 mstruct.plabelmeridian = min(mstruct.maplonlimit);
elseif ~isstr(mstruct.plabelmeridian)
     upper = max(mstruct.maplonlimit);    lower = min(mstruct.maplonlimit);
	 mstruct.plabelmeridian = max(min(mstruct.plabelmeridian,upper),lower);
elseif isstr(mstruct.plabelmeridian)
     switch mstruct.plabelmeridian
	     case 'east',    mstruct.plabelmeridian = max(mstruct.maplonlimit);
	     case 'west',    mstruct.plabelmeridian = min(mstruct.maplonlimit);
	     case 'prime',   mstruct.plabelmeridian = 0;
     end
end

if isempty(mstruct.plabellocation)
    mstruct.plabellocation = mstruct.plinelocation;
end

%  Override any orientation setting if fixedorient is not blank

if ~isempty(mstruct.fixedorient);
     if length(mstruct.fixedorient) == 1
	      mstruct.origin(3) = mstruct.fixedorient(1);
	 else
          msg = 'FixedOrient must be a scalar';
	      if nargout ~= 2;   error(msg);   end
	 end
end
