function d = readfk5(filename,d)
% READFK5 Read the Fifth Fundamental Catalog of stars and its extension.
%
% d = READFK5(filename) reads the FK5 file and returns the contents in a
% structure. Each star is an element in the structure, with the star
% properties stored in appropriately named fields.
%
% d = READFK5(filename,d) appends the data in the file to an existing
% structure.
%
% See also: SCATTERM, HMS2HR, DMS2DEG

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $
% Written by:  W. Stumpf

% NOTE: Don't use this file as an example of how to read fixed format files.
% Use READFIELDS instead. Someday this function should be reimplemented using
% READFIELDS.


if nargin == 1 ;
	d = [];
elseif nargin ~= 2
	error('Incorrect number of input arguments');
end

fid = fopen(filename,'r');

if fid == -1 ;	error('Couldn''t open file');end

fseek(fid,0,1);
eof = ftell(fid);
fseek(fid,0,-1);
pos = ftell(fid);

%
% Can't vectorize reading this file, because some fields are blank.
% So do it one field at a time, incrementing the index i for each row of data.
% Columns of data will be assigned to structure fields
%

i=length(d);

while( pos ~= eof);

	t = fgetl(fid);

	i=i+1;

	d(i).FK5 = sscanf(t(1:4),'%d',1); % *[1/1670]+ FK5 number
	d(i).RAh = sscanf(t(6:7),'%d',1); % Right ascension, hours,  Equinox=J2000, Epoch=J2000
	d(i).RAm = sscanf(t(9:10),'%d',1); % Right ascension minutes (J2000.0)
	d(i).RAs = sscanf(t(12:17),'%f',1); % *Right ascension seconds (J2000.0)

   sgn     = readplusminus(t(19));
	d(i).pmRA	 = sgn*sscanf(t(20:25),'%f',1);     % Proper motion in RA (J2000.0)

   sgn     = readplusminus(t(27));
	d(i).DEd = sgn*sscanf(t(28:29),'%d',1); % Declination degrees (J2000.0)
	d(i).DEm = sscanf(t(31:32),'%d',1); % Declination arcminutes (J2000.0)
	d(i).DEs = sscanf(t(34:38),'%f',1); % *Declination arcseconds (J2000.0)


   sgn     = readplusminus(t(40));
	d(i).pmDE = sgn*sscanf(t(41:46),'%f',1);       % Proper motion in DE (J2000.0)

	d(i).RAh1950 = sscanf(t(48:49),'%d',1); % Right ascension, hours Equinox=B1950, Epoch=B1950
	d(i).RAm1950 = sscanf(t(51:52),'%d',1); % Right ascension minutes (B1950.0)
	d(i).RAs1950 = sscanf(t(54:59),'%f',1); % *Right ascension seconds (B1950.0)

   sgn     = readplusminus(t(61));
	d(i).pmRA1950	 = sgn*sscanf(t(62:67),'%f',1);     % Proper motion in RA (B1950.0)

	sgn     = readplusminus(t(69));
	d(i).DEd1950 = sgn*sscanf(t(70:71),'%d',1); % Declination degrees (B1950.0)
	d(i).DEm1950 = sscanf(t(73:74),'%d',1); % Declination arcminutes (B1950.0)
	d(i).DEs1950 = sscanf(t(76:80),'%f',1); % *Declination arcseconds (B1950.0)

   sgn     = readplusminus(t(82));
	d(i).pmDE1950 = sgn*sscanf(t(83:88),'%f',1);       % Proper motion in DE (B1950.0)

 	d(i).EpRA1900 = sscanf(t(90:94),'%f',1);       % *Mean Epoch of observed RA
 	d(i).e_RAs = sscanf(t(96:99),'%f',1);       % *Mean error in RA
	d(i).e_pmRA = sscanf(t(101:105),'%f',1); % Mean error in pmRA
	d(i).EpDE1900 = sscanf(t(107:111),'%f',1); % *Mean Epoch of observed DE
	d(i).e_DEs = sscanf(t(113:116),'%f',1); %*Mean error in Declination
	d(i).e_pmDE = sscanf(t(118:122),'%f',1); % Mean error in pmDE
	d(i).Vmag = sscanf(t(124:128),'%f',1); %*V magnitude

 	d(i).n_Vmag = deblank(leadblnk(t(129))); % *[VvD] Magnitude flag

 	d(i).SpType = deblank(leadblnk(t(131:137))); %*Spectral type(s)

 	sgn     = readplusminus(t(139));
   d(i).plx = sgn*sscanf(t(140:144),'%f',1); %*?Parallax

 	sgn     = readplusminus(t(147));
   d(i).RV = sgn*sscanf(t(148:152),'%f',1); %*?Radial velocity

	d(i).AGK3R = deblank(leadblnk(t(155:159))); %AGK3R number (Catalog <I/72>)
	d(i).SRS   = deblank(leadblnk(t(161:165))); %SRS number (Catalog <I/138>)
	d(i).HD    = deblank(leadblnk(t(167:172))); %HD number (Catalog <III/135>)
	d(i).DM    = deblank(leadblnk(t(174:183))); %*DM identifier
	d(i).GC    = deblank(leadblnk(t(186:190))); %GC number (Catalog <I/113>)

	pos = ftell(fid);

end

%	d(i). = fscanf(fid,'%f',1) %

fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sgn = readplusminus(t)

   ch     = sscanf(t,'%1s',1);
	if strcmp(ch,'-')
		sgn = - 1;
	elseif strcmp(ch,'+')
		sgn = 1;
	elseif isempty(ch)
		sgn = 1;
	else
		error('error reading file: character was not a plus or a minus or empty')
	end

