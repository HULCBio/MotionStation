function mat = almanac(object,parm,units,refbody)
%ALMANAC Almanac data for the Solar System.
%   ALMANAC, without any input arguments, displays a list of the heavenly
%   objects recognized by ALMANAC.
%
%   ALMANAC('object') displays recognized parameters, units, and reference
%   body strings for the planet.
%
%   ALMANAC('object','parameter') returns the specified parameter from the
%   almanac.  Available parameters are the spherical radius of the planet,
%   surface area and volume of the sphere, the definition of the ellipsoid
%   (semimajor axis and eccentricity), the volume and surface area of the
%   ellipsoid, and tabulated surface area and volume.
%
%   ALMANAC('object','parameter','units') returns the corresponding
%   parameter in the units defined by 'units'.  If omitted, kilometers are
%   used.
%
%   ALMANAC('object','parameter','units','referencebody') returns the
%   corresponding parameter given the spherical and or elliptical reference
%   body specified by 'referencebody'.  If omitted, a sphere is assumed
%   where appropriate.

%   Copyright 1996-2004 The MathWorks, Inc.
%   Written by:  E. Byrns, E. Brown, W. Stumpf
%   $Revision: 1.1.6.2 $  $Date: 2004/03/24 20:41:03 $

validObjects = {...
    'sun',...
    'mercury',...
    'venus',...
    'earth',...
    'moon',...
    'mars',...
    'jupiter',...
    'saturn',...
    'uranus',...
    'neptune',...
    'pluto'};

checknargin(0,4,nargin,mfilename);

if nargin == 0;
    S=[{'The heavenly objects recognized by ALMANAC are:'; '  '}; ...    
       cellstr([repmat('  ',[length(validObjects) 1]) char(validObjects)])];
    disp(sprintf('%s\n',S{:}));
else
    object = checkstrs(object, validObjects, mfilename, 'object', 1);
    switch nargin
        case 1, feval(object);
        case 2, mat = feval(object,parm);
        case 3, mat = feval(object,parm,units);
        case 4, mat = feval(object,parm,units,refbody);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat = earth(parm,units,refbody)

%EARTH Calculate almanac data for the planet Earth.
%
%  EARTH, without any input arguments, displays recognized
%  parameters, units and reference body strings.
%
%  EARTH('parameter') returns the specified parameter from the almanac.
%  Available parameters are the spherical radius of the planet, surface
%  area and volume of the sphere, the definition of the ellipsoid
%  (semimajor axis and eccentricity), the volume and surface area of the
%  ellipsoid, and actual surface area and volume.
%
%  EARTH('parameter','units') returns the corresponding parameter in
%  the units defined by 'units'.  If omitted, kilometers are used.
%
%  EARTH('parameter','units','referencebody') returns the corresponding
%  parameter given the spherical and or elliptical reference body
%  specified by 'referencebody'.  If omitted, a sphere is assumed
%  where appropriate.

%  Define the default geoid as a string

defaultgeoid = 'grs80';

%  Define valid parameter strings.  Pre-padding is
%  much faster than strvcat

validparm = [
             'list     '
			 'radius   '
             'ellipsoid'
			 'geoid    '
			 'sphere   '
			 'surfarea '
			 'volume   '
		    ];

%  Define valid reference body strings

validref = [
            'sphere   '
            'ellipsoid'
			'geoid    '
			'actual   '
		   ];

%  Define valid ellipsoid strings

validelps = [
             'everest      '
			 'bessel       '
			 'airy         '
			 'clarke66     '
			 'clarke80     '
			 'international'
			 'krasovsky    '
			 'wgs60        '
			 'iau65        '
			 'wgs66        '
			 'iau68        '
			 'wgs72        '
			 'grs80        '
			];

%  Test the input arguments

if nargin == 0;           parm    = [];     units   = [];     refbody = [];
    elseif nargin == 1;   units   = [];     refbody = [];
    elseif nargin == 2;   refbody = [];
end

%  Initialize output argument
%  Initialization needed for to avoid warning with isempty test at end

mat = [];

%  Empty units tests

if isempty(units);     units   = 'km';       end

%  Test if parameter input, then search for a match

if isempty(parm)
     parm = 'list';

elseif ~ischar(parm)
     eid = sprintf('%s:%s:invalidString', getcomp, mfilename);
     error(eid,'%s','Input argument PARAMETER must be a string');
else
     strmat = str2mat(validparm,validelps);
     strindx = strmatch(lower(parm),strmat);  %  String match

     if length(strindx) == 1
	       parm = deblank(strmat(strindx,:));
           if strcmp(parm,'ellipsoid')
               parm = 'geoid';
           end
		   if strcmp(parm,'geoid') && isempty(refbody);  parm = defaultgeoid; end
	 else
         eid = sprintf('%s:%s:invalidParam', getcomp, mfilename);
	      error(eid,'%s %s','Unrecognized parameter:  ',parm);
     end
end


%  Test if parameter input, then search for a match

if isempty(refbody)
     strindx = strmatch(parm,validelps);  %  String match on ellipsoids
	 if length(strindx) == 1   
       refbody = parm;
	 else
       refbody = 'sphere';
	 end

elseif ~ischar(refbody)
     eid = sprintf('%s:%s:invalidString', getcomp, mfilename);
     error(eid,'%s','Input argument REFBODY must be a string');
else
     strmat = str2mat(validref,validelps);
     strindx = strmatch(lower(refbody),strmat);  %  String match

     if length(strindx) == 1
	       refbody = deblank(strmat(strindx,:));
           if strcmp(refbody,'ellipsoid')
               refbody = 'geoid';
           end
		   if strcmp(refbody,'geoid');  refbody = defaultgeoid;  end
	 else
         eid = sprintf('%s:%s:invalidRefBody', getcomp, mfilename);
	      error(eid,'%s %s','Unrecognized reference body:  ',refbody);
     end
end

%  Parameters
%    radius, geoid definitions
%    actual volume,  actual surface area
%    spherical volume,  spherical surface area
%    geoid volume, geoid surface area

%  Basic surface area data taken from Encyclopaedia Britannica, 1995.
%  The earth radius is that of a sphere with a volume equivalent to that
%  of an ellipsoid with the equatorial and polar radii tabulated in the
%  Encyclopaedia Britannica. The volume is based on the same ellipsoid.

volume   = 1.0832e+12;     %  Earth volume in kilometers^3
surfarea = 510100000;      %  Earth surface area in kilometers^2
radius   = 6.3710e+03;     %  Earth radius in kilometers


%  Ellipsoid definitions with semimajor axes in kilometers.
%  From:  D. H. Maling, Coordinate Systems and Map Projections, 2nd Edition
%         Pergamon Press, 1992, pp. 10-11, Table 1.01, except for the
%         Clarke 1866 (for which this reference contains an error). Clarke
%         1866 is from DMA Technical Manual 8358.1, "Datums, Ellipsoids,
%         Grids and Grid Reference Systems," 1990.  Note that the Clarke
%         1866 is defined in terms of its two axes rather than its
%         semimajor axis and inverse flattening.


everest1830   = [6377.276345   flat2ecc(1/300.8017)];
bessel1841    = [6377.397155   flat2ecc(1/299.1528128)];
airy1849      = [6377.563396   flat2ecc(1/299.3249)];
clarke1866    = [6378.2064     axes2ecc(6378.2064,6356.5838)];
clarke1880    = [6378.249145   flat2ecc(1/293.465)];
internatl1924 = [6378.388      flat2ecc(1/297.0)];
krasovsky1940 = [6378.245      flat2ecc(1/298.3)];
wgs60         = [6378.165      flat2ecc(1/298.3)];
iau65         = [6378.160      flat2ecc(1/298.25)];
wgs66         = [6378.145      flat2ecc(1/298.25)];
iau68         = [6378.16000    flat2ecc(1/298.2472)];
wgs72         = [6378.135      flat2ecc(1/298.26)];
grs80         = [6378.13700    flat2ecc(1/298.257222101)];

if strcmp(parm,'list')
    disp('Function Call:   mat = almanac(''earth'',''parameter'',''units'',''referencebody'')')
    disp(' ')
    disp('Valid parameter strings are:')
    disp('   ''radius''       for the planet radius')
    disp('   ''ellipsoid''    for the planet ellipsoid vector')
    disp('   ''volume''       for the planet volume')
    disp('   ''surfarea''     for the planet surface area')
	disp('   Or any valid ellipsoid definition string defined below')
    disp(' ')
    disp('Valid units strings are:')
    disp('   ''degrees''       or ''deg'' for degrees')
    disp('   ''kilometers''    or ''km''  for kilometers   (default)')
    disp('   ''nauticalmiles'' or ''nm''  for nautical miles')
    disp('   ''radians''       or ''rad'' for radians')
    disp('   ''statutemiles''  or ''sm''  for statute miles')
    disp(' ')
    disp('Valid reference body strings are:')
    disp('   ''sphere''       for a sphere (default)')
    disp('   ''ellipsoid''    for an ellipsoid')
    disp('   ''actual''       for the tabulated volume and surface area of the planet')
	disp('   Or any valid ellipsoid definition string defined below')
    disp(' ')
    disp('Valid ellipsoid definition strings are:')
    disp('   ''everest''        for the 1830 Everest ellipsoid')
    disp('   ''bessel''         for the 1841 Bessel ellipsoid')
    disp('   ''airy''           for the 1849 Airy ellipsoid')
    disp('   ''clarke66''       for the 1866 Clarke ellipsoid')
    disp('   ''clarke80''       for the 1880 Clarke ellipsoid')
    disp('   ''international''  for the 1924 International ellipsoid')
    disp('   ''krasovsky''      for the 1940 Krasovsky ellipsoid')
    disp('   ''wgs60''          for the 1960 World Geodetic System ellipsoid')
    disp('   ''iau65''          for the 1965 International Astronomical Union ellipsoid')
    disp('   ''wgs66''          for the 1966 World Geodetic System ellipsoid')
    disp('   ''iau68''          for the 1968 International Astronomical Union ellipsoid')
    disp('   ''wgs72''          for the 1972 World Geodetic System ellipsoid')
    disp('   ''grs80''          for the 1980 Geodetic Reference System ellipsoid')
    disp('   An input of ''ellipsoid'' is equivalent to ''grs80'' ')

    return
end

switch refbody
case 'actual'
    switch parm
	  case 'radius'
	    mat = distdim(radius,'km',units,'earth');
	  case {'geoid','ellipsoid'}
        eval(['mat = ',defaultgeoid,';']);
		mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'sphere'
	    mat = distdim(radius,'km',units,'earth');  mat = [mat 0];
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = volume * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = surfarea * fact^2;
	end

case 'sphere'
    switch parm
	  case 'radius'
	    mat = distdim(radius,'km',units,'earth');
	  case {'geoid','ellipsoid'}
	    mat = distdim(radius,'km',units,'earth');  mat = [mat 0];
	  case 'sphere'
	    mat = distdim(radius,'km',units,'earth');  mat = [mat 0];
	  case 'volume'
	    rad = distdim(radius,'km',units,'earth');
        mat = sphcalc(rad,parm);
	  case 'surfarea'
	    rad = distdim(radius,'km',units,'earth');
        mat = sphcalc(rad,parm);
	end

case 'everest'
    switch parm
	  case 'radius'
        mat = everest1830;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'everest'
        mat = everest1830;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = everest1830;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(everest1830,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(everest1830,parm);      mat = mat * fact^2;
	end

case 'bessel'
    switch parm
	  case 'radius'
        mat = bessel1841;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'bessel'
        mat = bessel1841;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = bessel1841;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(bessel1841,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(bessel1841,parm);      mat = mat * fact^2;
	end

case 'airy'
    switch parm
	  case 'radius'
        mat = airy1849;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'airy'
        mat = airy1849;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = airy1849;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(airy1849,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(airy1849,parm);      mat = mat * fact^2;
	end

case 'clarke66'
    switch parm
	  case 'radius'
        mat = clarke1866;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'clarke66'
        mat = clarke1866;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = clarke1866;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(clarke1866,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(clarke1866,parm);      mat = mat * fact^2;
	end

case 'clarke80'
    switch parm
	  case 'radius'
        mat = clarke1880;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'clarke80'
        mat = clarke1880;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = clarke1880;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(clarke1880,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(clarke1880,parm);      mat = mat * fact^2;
	end

case 'international'
    switch parm
	  case 'radius'
        mat = internatl1924;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'international'
        mat = internatl1924;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = internatl1924;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(internatl1924,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(internatl1924,parm);      mat = mat * fact^2;
	end

case 'krasovsky'
    switch parm
	  case 'radius'
        mat = krasovsky1940;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'krasovsky'
        mat = krasovsky1940;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = krasovsky1940;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(krasovsky1940,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(krasovsky1940,parm);      mat = mat * fact^2;
	end

case 'wgs60'
    switch parm
	  case 'radius'
        mat = wgs60;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'wgs60'
        mat = wgs60;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = wgs60;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(wgs60,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(wgs60,parm);      mat = mat * fact^2;
	end

case 'iau65'
    switch parm
	  case 'radius'
        mat = iau65;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'iau65'
        mat = iau65;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = iau65;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(iau65,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(iau65,parm);      mat = mat * fact^2;
	end

case 'wgs66'
    switch parm
	  case 'radius'
        mat = wgs66;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'wgs66'
        mat = wgs66;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = wgs66;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(wgs66,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(wgs66,parm);      mat = mat * fact^2;
	end

case 'iau68'
    switch parm
	  case 'radius'
        mat = iau68;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'iau68'
        mat = iau68;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = iau68;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(iau68,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(iau68,parm);      mat = mat * fact^2;
	end

case 'wgs72'
    switch parm
	  case 'radius'
        mat = wgs72;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'wgs72'
        mat = wgs72;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = wgs72;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(wgs72,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(wgs72,parm);      mat = mat * fact^2;
	end

case 'grs80'
    switch parm
	  case 'radius'
        mat = grs80;
		mat(1) = distdim(mat(1),'km',units,'earth');  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case 'grs80'
        mat = grs80;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case {'geoid','ellipsoid'}
        mat = grs80;    mat(1) = distdim(mat(1),'km',units,'earth');
	  case 'volume'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(grs80,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,'earth');
        mat = elpcalc(grs80,parm);      mat = mat * fact^2;
	end

otherwise
   eid = sprintf('%s:%s:invalidRefBody', getcomp, mfilename);
   error(eid,'%s','Unrecognized reference body string');
end

if isempty(mat)
   eid = sprintf('%s:%s:invalidRefBodyAndParam', getcomp, mfilename);
   error(eid,'%s','Unrecognized parameter and reference body combination');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat = jupiter(varargin)

%JUPITER Calculate almanac data for the planet Jupiter.
%
%  JUPITER, without any input arguments, displays recognized
%  parameters, units and reference body strings.
%
%  JUPITER('parameter') returns the specified parameter from the almanac.
%  Available parameters are the spherical radius of the planet, surface
%  area and volume of the sphere, the definition of the ellipsoid
%  (semimajor axis and eccentricity), the volume and surface area of the
%  ellipsoid, and actual surface area and volume.
%
%  JUPITER('parameter','units') returns the corresponding parameter in
%  the units defined by 'units'.  If omitted, kilometers are used.
%
%  JUPITER('parameter','units','referencebody') returns the corresponding
%  parameter given the spherical and or elliptical reference body
%  specified by 'referencebody'.  If omitted, a sphere is assumed
%  where appropriate.

%  Geoid data derived from polar and equatorial radii tabulated in the
%  Encyclopaedia Britannica, 1995.  Radius is the radius of the sphere
%  with the same volume as the ellipsoid.  Volume and surface area
%  are derived from the geoid.

geoid   = [71492    0.3574];
radius   = 6.9882e+04;           %  Jupiter radius in kilometers
volume   = 1.4295e+15;           %  Jupiter volume in kilometers^3
surfarea = 6.1419e+10;
mat = planet('jupiter',geoid,radius,volume,surfarea,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat = mars(varargin)

%MARS Calculate almanac data for the planet Mars.
%
%  MARS, without any input arguments, displays recognized
%  parameters, units and reference body strings.
%
%  MARS('parameter') returns the specified parameter from the almanac.
%  Available parameters are the spherical radius of the planet, surface
%  area and volume of the sphere, the definition of the ellipsoid
%  (semimajor axis and eccentricity), the volume and surface area of the
%  ellipsoid, and actual surface area and volume.
%
%  MARS('parameter','units') returns the corresponding parameter in
%  the units defined by 'units'.  If omitted, kilometers are used.
%
%  MARS('parameter','units','referencebody') returns the corresponding
%  parameter given the spherical and or elliptical reference body
%  specified by 'referencebody'.  If omitted, a sphere is assumed
%  where appropriate.

%  Geoid data derived from polar and equatorial radii tabulated in the
%  Encyclopaedia Britannica, 1995.  Radius is the radius of the sphere
%  with the same volume as the ellipsoid.  Volume and surface area
%  are from the Encyclopaedia Britannica.

geoid   = [3396.9    0.1105];
radius   = 3.39e+03;           %  Mars radius in kilometers
volume   = 1.63e+11;           %  Mars volume in kilometers^3
surfarea = 1.44e+08;           %  Mars surface area in kilometers^2
mat = planet('mars',geoid,radius,volume,surfarea,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat = mercury(varargin)

%MERCURY Calculate almanac data for the planet Mercury.
%
%  MERCURY, without any input arguments, displays recognized
%  parameters, units and reference body strings.
%
%  MERCURY('parameter') returns the specified parameter from the almanac.
%  Available parameters are the spherical radius of the planet, surface
%  area and volume of the sphere, the definition of the ellipsoid
%  (semimajor axis and eccentricity), the volume and surface area of the
%  ellipsoid, and actual surface area and volume.
%
%  MERCURY('parameter','units') returns the corresponding parameter in
%  the units defined by 'units'.  If omitted, kilometers are used.
%
%  MERCURY('parameter','units','referencebody') returns the corresponding
%  parameter given the spherical and or elliptical reference body
%  specified by 'referencebody'.  If omitted, a sphere is assumed
%  where appropriate.

%  Basic data taken from J.P. Synder, Map Projections A Working
%  Manual, U.S. Geological Survey Paper 1395, US Government Printing
%  Office, Washington, DC, 1987, Table 2, p. 14.  Volume and
%  surface area computed assuming a perfect sphere. Radius agrees
%  with the value tabulated in the Encyclopaedia Britannica. 1995.

radius   = 2439.0;         %  Mercury radius in kilometers
volume   = 6.0775e+10;     %  Mercury volume in kilometers^3
surfarea = 7.4754e+07;     %  Mercury surface area in kilometers^2
mat = planet('mercury',[radius 0],radius,volume,surfarea,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat = moon(varargin)

%MOON Calculate almanac data for the Moon.
%
%  MOON, without any input arguments, displays recognized
%  parameters, units and reference body strings.
%
%  MOON('parameter') returns the specified parameter from the almanac.
%  Available parameters are the spherical radius of the planet, surface
%  area and volume of the sphere, the definition of the ellipsoid
%  (semimajor axis and eccentricity), the volume and surface area of the
%  ellipsoid, and actual surface area and volume.
%
%  MOON('parameter','units') returns the corresponding parameter in
%  the units defined by 'units'.  If omitted, kilometers are used.
%
%  MOON('parameter','units','referencebody') returns the corresponding
%  parameter given the spherical and or elliptical reference body
%  specified by 'referencebody'.  If omitted, a sphere is assumed
%  where appropriate.

%  Basic data taken from J.P. Synder, Map Projections A Working
%  Manual, U.S. Geological Survey Paper 1395, US Government Printing
%  Office, Washington, DC, 1987, Table 2, p. 14. Radius agrees
%  with the value tabulated in the Encyclopaedia Britannica. 1995.

radius   = 1738.0;         %  Moon radius in kilometers
volume   = 2.1991e+10;     %  Moon volume in kilometers^3
surfarea = 3.7959e+07;     %  Moon surface area in kilometers^2
mat = planet('moon',[radius 0],radius,volume,surfarea,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat = neptune(varargin)

%NEPTUNE Calculate almanac data for the planet Neptune.
%
%  NEPTUNE, without any input arguments, displays recognized
%  parameters, units and reference body strings.
%
%  NEPTUNE('parameter') returns the specified parameter from the almanac.
%  Available parameters are the spherical radius of the planet, surface
%  area and volume of the sphere, the definition of the ellipsoid
%  (semimajor axis and eccentricity), the volume and surface area of the
%  ellipsoid, and actual surface area and volume.
%
%  NEPTUNE('parameter','units') returns the corresponding parameter in
%  the units defined by 'units'.  If omitted, kilometers are used.
%
%  NEPTUNE('parameter','units','referencebody') returns the corresponding
%  parameter given the spherical and or elliptical reference body
%  specified by 'referencebody'.  If omitted, a sphere is assumed
%  where appropriate.

%  Geoid data derived from 1 bar polar and equatorial radii tabulated in the
%  Encyclopaedia Britannica, 1995.  Radius is the radius of the sphere
%  with the same volume as the ellipsoid.  Volume and surface area
%  are derived from the geoid.

geoid   = [24764    0.1843];
radius   = 2.4622e+04;           %  Neptune radius in kilometers
volume   = 6.2524e+13;           %  Neptune volume in kilometers^3
surfarea = 7.6185e+09;           %  Neptune surface area in kilometers^2
mat = planet('neptune',geoid,radius,volume,surfarea,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mat = pluto(varargin)

%PLUTO Calculate almanac data for the planet Pluto.
%
%  PLUTO, without any input arguments, displays recognized
%  parameters, units and reference body strings.
%
%  PLUTO('parameter') returns the specified parameter from the almanac.
%  Available parameters are the spherical radius of the planet, surface
%  area and volume of the sphere, the definition of the ellipsoid
%  (semimajor axis and eccentricity), the volume and surface area of the
%  ellipsoid, and actual surface area and volume.
%
%  PLUTO('parameter','units') returns the corresponding parameter in
%  the units defined by 'units'.  If omitted, kilometers are used.
%
%  PLUTO('parameter','units','referencebody') returns the corresponding
%  parameter given the spherical and or elliptical reference body
%  specified by 'referencebody'.  If omitted, a sphere is assumed
%  where appropriate.

%  Radius is the value tabulated in the Encyclopaedia Britannica, 1995.
%  Volume and surface area are derived for a sphere.

radius   = 1151;            %  Pluto radius in kilometers
volume   = 6.3873e+09;      %  Pluto volume in kilometers^3
surfarea = 1.6648e+07;      %  Pluto surface area in kilometers^2
mat = planet('pluto',[radius 0],radius,volume,surfarea,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat = saturn(varargin)

%SATURN Calculate almanac data for the planet Saturn.
%
%  SATURN, without any input arguments, displays recognized
%  parameters, units and reference body strings.
%
%  SATURN('parameter') returns the specified parameter from the almanac.
%  Available parameters are the spherical radius of the planet, surface
%  area and volume of the sphere, the definition of the ellipsoid
%  (semimajor axis and eccentricity), the volume and surface area of the
%  ellipsoid, and actual surface area and volume.
%
%  SATURN('parameter','units') returns the corresponding parameter in
%  the units defined by 'units'.  If omitted, kilometers are used.
%
%  SATURN('parameter','units','referencebody') returns the corresponding
%  parameter given the spherical and or elliptical reference body
%  specified by 'referencebody'.  If omitted, a sphere is assumed
%  where appropriate.

%  Geoid data derived from 1 bar polar and equatorial radii tabulated in the
%  Encyclopaedia Britannica, 1995.  Radius is the radius of the sphere
%  with the same volume as the ellipsoid.  Volume and surface area
%  are derived from the geoid.

geoid   = [60268    0.4317];
radius   = 5.8235e+04;           %  Saturn radius in kilometers
volume   = 8.2711e+14;           %  Saturn volume in kilometers^3
surfarea = 4.2693e+10;           %  Saturn surface area in kilometers^2
mat = planet('saturn',geoid,radius,volume,surfarea,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mat = sun(varargin)

%SUN Calculate almanac data for the Sun.
%
%  SUN, without any input arguments, displays recognized
%  parameters, units and reference body strings.
%
%  SUN('parameter') returns the specified parameter from the almanac.
%  Available parameters are the spherical radius of the planet, surface
%  area and volume of the sphere, the definition of the ellipsoid
%  (semimajor axis and eccentricity), the volume and surface area of the
%  ellipsoid, and actual surface area and volume.
%
%  SUN('parameter','units') returns the corresponding parameter in
%  the units defined by 'units'.  If omitted, kilometers are used.
%
%  SUN('parameter','units','referencebody') returns the corresponding
%  parameter given the spherical and or elliptical reference body
%  specified by 'referencebody'.  If omitted, a sphere is assumed
%  where appropriate.

%  Basic radius data taken from Encyclopaedia Britannica, 1995.
%  Volume and surface area computed assuming a perfect sphere.

radius   = 6.9446e+05;    %  Sun radius in kilometers
volume   = 1.4029e+18;    %  Sun volume in kilometers^3
surfarea = 6.0604e+12;    %  Sun surface area in kilometers^2
mat = planet('sun',[radius 0],radius,volume,surfarea,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat = uranus(varargin)

%URANUS Calculate almanac data for the planet Uranus.
%
%  URANUS, without any input arguments, displays recognized
%  parameters, units and reference body strings.
%
%  URANUS('parameter') returns the specified parameter from the almanac.
%  Available parameters are the spherical radius of the planet, surface
%  area and volume of the sphere, the definition of the ellipsoid
%  (semimajor axis and eccentricity), the volume and surface area of the
%  ellipsoid, and actual surface area and volume.
%
%  URANUS('parameter','units') returns the corresponding parameter in
%  the units defined by 'units'.  If omitted, kilometers are used.
%
%  URANUS('parameter','units','referencebody') returns the corresponding
%  parameter given the spherical and or elliptical reference body
%  specified by 'referencebody'.  If omitted, a sphere is assumed
%  where appropriate.

%  Geoid data derived from equatorial radius (1 bar) and elipticity (flattening)
%  tabulated in the Encyclopaedia Britannica, 1995.  Radius is the radius
%  of the sphere with the same volume as the ellipsoid.  Volume and surface
%  area are derived from the geoid.

geoid   = [25559      flat2ecc(0.0229)];
radius   = 2.5362e+04;           %  Uranus radius in kilometers
volume   = 6.8338e+13;           %  Uranus volume in kilometers^3
surfarea = 8.0841e+09;           %  Uranus surface area in kilometers^2
mat = planet('uranus',geoid,radius,volume,surfarea,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mat = venus(varargin)

%VENUS Calculate almanac data for the planet Venus.
%
%  VENUS, without any input arguments, displays recognized
%  parameters, units and reference body strings.
%
%  VENUS('parameter') returns the specified parameter from the almanac.
%  Available parameters are the spherical radius of the planet, surface
%  area and volume of the sphere, the definition of the ellipsoid
%  (semimajor axis and eccentricity), the volume and surface area of the
%  ellipsoid, and actual surface area and volume.
%
%  VENUS('parameter','units') returns the corresponding parameter in
%  the units defined by 'units'.  If omitted, kilometers are used.
%
%  VENUS('parameter','units','referencebody') returns the corresponding
%  parameter given the spherical and or elliptical reference body
%  specified by 'referencebody'.  If omitted, a sphere is assumed
%  where appropriate.

%  Basic data taken from J.P. Synder, Map Projections A Working
%  Manual, U.S. Geological Survey Paper 1395, US Government Printing
%  Office, Washington, DC, 1987, Table 2, p. 14.  Volume and
%  surface area computed assuming a perfect sphere. Radius agrees
%  with the value tabulated in the Encyclopaedia Britannica. 1995.

radius   = 6051.0;          %  Venus radius in kilometers
volume   = 9.28047e+11;     %  Venus volume in kilometers^3
surfarea = 4.60113e+08;     %  Venus surface area in kilometers^2
mat = planet('venus',[radius 0],radius,volume,surfarea,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat = planet(...
    planetname, ellipsoid, radius, volume, surfarea, parm, units, refbody)

%PLANET Calculate almanac data for all bodies other than Earth.

%  Define valid parameter strings.  Pre-padding is
%  much faster than strvcat

validparm = [
             'list     '
			 'radius   '
             'ellipsoid'
			 'geoid    '
			 'sphere   '
			 'surfarea '
			 'volume   '
		    ];

%  Define valid reference body strings

validref = [
            'sphere   '
            'ellipsoid'
			'geoid    '
			'actual   '
		   ];

%  Test the input arguments

if (nargin - 5) == 0;           parm    = [];   units   = [];   refbody = [];
    elseif (nargin - 5) == 1;   units   = [];   refbody = [];
    elseif (nargin - 5) == 2;   refbody = [];
end

%  Initialize output argument
%  Initialization needed for to avoid warning(wid,'%s', with isempty test at end

mat = [];

%  Empty units tests

if isempty(units);     units   = 'km';       end

%  Test if parameter input, then search for a match

if isempty(parm)
    parm = 'list';
elseif ~ischar(parm)
    eid = sprintf('%s:%s:invalidString', getcomp, mfilename);
    error(eid,'%s','Input argument PARAMETER must be a string');
else
    strindx = strmatch(lower(parm),validparm);  %  String match
    if length(strindx) == 1
	    parm = deblank(validparm(strindx,:));
	else
        eid = sprintf('%s:%s:invalidParam', getcomp, mfilename);
	    error(eid,'%s %s','Unrecognized parameter:  ',parm);
    end
end

if strcmp(parm,'ellipsoid')
    parm = 'geoid';
end

%  Test if parameter input, then search for a match

if isempty(refbody)
	 if strcmp(parm,'geoid')
      refbody = 'geoid';
	 else
      refbody = 'sphere';
	 end
elseif ~ischar(refbody)
     eid = sprintf('%s:%s:invalidString', getcomp, mfilename);
     error(eid,'%s','Input argument REFBODY must be a string');
else
     strindx = strmatch(lower(refbody),validref);  %  String match
     if length(strindx) == 1
	       refbody = deblank(validref(strindx,:));
	 else
          eid = sprintf('%s:%s:invalidRefBody', getcomp, mfilename);
	       error(eid,'%s %s','Unrecognized reference body:  ',refbody);
     end
end

if strcmp(parm,'list')
    disp(sprintf('Function Call:   mat = almanac(''%s'',''parameter'',''units'',''referencebody'')',planetname))
    disp(' ')
    disp('Valid parameter strings are:')
    disp('   ''radius''       for the planet radius')
    disp('   ''geoid''        for the planet geoid vector')
    disp('   ''volume''       for the planet volume')
    disp('   ''surfarea''     for the planet surface area')
    disp(' ')
    disp('Valid units strings are:')
    disp('   ''degrees''       or ''deg'' for degrees')
    disp('   ''kilometers''    or ''km''  for kilometers   (default)')
    disp('   ''nauticalmiles'' or ''nm''  for nautical miles')
    disp('   ''radians''       or ''rad'' for radians')
    disp('   ''statutemiles''  or ''sm''  for statute miles')
    disp(' ')
    disp('Valid reference body strings are:')
    disp('   ''sphere''       for a sphere (default)')
    disp('   ''geoid''        for a ellipsoid')
    disp('   ''actual''       for the tabulated volume and surface area of the planet')


    return
end

switch refbody
case 'actual'
    switch parm
	  case 'radius'
	    mat = distdim(radius,'km',units,planetname);
	  case {'geoid','ellipsoid'}
        mat = ellipsoid;    mat(1) = distdim(mat(1),'km',units,planetname);
	  case 'sphere'
	    mat = distdim(radius,'km',units,planetname);  mat = [mat 0];
	  case 'volume'
        fact = distdim(1.0,'km',units,planetname);
        mat = volume * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,planetname);
        mat = surfarea * fact^2;
	end

case 'sphere'
    switch parm
	  case 'radius'
	    mat = distdim(radius,'km',units,planetname);
	  case {'geoid','ellipsoid'}
	    mat = distdim(radius,'km',units,planetname);  mat = [mat 0];
	  case 'sphere'
	    mat = distdim(radius,'km',units,planetname);  mat = [mat 0];
	  case 'volume'
	    rad = distdim(radius,'km',units,planetname);
        mat = sphcalc(rad,parm);
	  case 'surfarea'
	    rad = distdim(radius,'km',units,planetname);
        mat = sphcalc(rad,parm);
	end

case {'geoid','ellipsoid'}
    switch parm
	  case 'radius'
        mat = ellipsoid;
		mat(1) = distdim(mat(1),'km',units,planetname);  mat(2) = [];
      wid = sprintf('%s:%s:usingSemiMajorAxis', getcomp, mfilename);
		warning(wid,'%s','Semimajor axis returned for radius parameter')
	  case {'geoid','ellipsoid'}
        mat = ellipsoid;    mat(1) = distdim(mat(1),'km',units,planetname);
	  case 'volume'
        fact = distdim(1.0,'km',units,planetname);
        mat = elpcalc(ellipsoid,parm);      mat = mat * fact^3;
	  case 'surfarea'
        fact = distdim(1.0,'km',units,planetname);
        mat = elpcalc(ellipsoid,parm);      mat = mat * fact^2;
	end

otherwise
    eid = sprintf('%s:%s:invalidRefBody', getcomp, mfilename);
    error(eid,'%s','Unrecognized reference body string');
end

if isempty(mat)
    eid = sprintf('%s:%s:invalidRefBodyAndParam', getcomp, mfilename);
    error(eid,'%s','Unrecognized parameter and reference body combination');
end
