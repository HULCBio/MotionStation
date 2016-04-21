function [geoid,geoidstr] = utmgeoid(zone)

%UTMGEOID  Recommended UTM geoids for zone
%
%  GEOID = UTMGEOID without any arguments opens the UTMZONEUI interface 
%  for selecting a UTM zone.  This zone is then used to return the
%  recommended ellipsoid definition(s) for that particular zone.
%
%  GEOID = UTMGEOID(Zone) uses the input ZONE to return the recommended 
%  ellipsoid definition(s).
%
%  [GEOID,GEOIDSTR] = UTMGEOID(...) returns the geoid string used by 
%  the almanac function.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.4.4.1 $
%  Written by A. Kim

if nargin==0
	zone = utmzoneui;
end	

% latzones = char([67:72 74:78 80:88]');
	
zone = upper(zone);

[ltlim,lnlim,msg] = utmzone(zone);

% if length(zone)==2
% 	lnindx = str2num(zone(1));    ltindx = strmatch(zone(2),latzones);
% elseif length(zone)==3
% 	lnindx = str2num(zone(1:2));  ltindx = strmatch(zone(3),latzones);
% else
% 	lnindx = [];	ltindx = [];
% end

if ~isempty(msg),  error(msg),  end

if isempty(str2num(zone))	% number and letter zone designation
	code = utmgcode(zone); 
else  						% number zone designation
	code = 5;  % set to international
end

switch code

	case 1, geoidstr = 'clarke66';
	case 2, geoidstr = 'clarke80';
	case 3, geoidstr = 'everest';
	case 4, geoidstr = 'bessel';
	case 5, geoidstr = 'international';
	case 14, geoidstr = strvcat('clarke66','bessel');
	case 15, geoidstr = strvcat('clarke66','international');
	case 25, geoidstr = strvcat('clarke80','international');
	case 34, geoidstr = strvcat('everest','bessel');
	case 345, geoidstr = strvcat('everest','bessel','international');
	case 35, geoidstr = strvcat('everest','international');
	case 45, geoidstr = strvcat('bessel','international');

end

for n=1:length(geoidstr(:,1))
	geoid(n,:) = almanac('earth',deblank(geoidstr(n,:)));
	geoid(n,1) = geoid(n,1)*1000;  % UTM units in meters
end


%**************************************************************************
%**************************************************************************
%**************************************************************************

function code = utmgcode(zone)

% Usage:
%
%	code = utmgcode(zone)

% Ellipsoid definitions:
%
%	#1 - Clarke 1866
%	#2 - Clarke 1880
%	#3 - Everest
%	#4 - Bessel
%	#5 - International

% initialize ellipsoid matrix with ellipsoid #5 (International)
ellps = 5*ones(20,60);

% ellipsoid #1 (Clarke 1866) *ones(1,8)
r1 = [12 12 12 13*ones(1,8) 14*ones(1,10) 15*ones(1,12) 16*ones(1,12) 17*ones(1,17) 18*ones(1,19) 19*ones(1,18) 20*ones(1,15)];
c1 = [16 17 51 13:20        11:20         9:20          9:20          1 2 9:22 60   2:20          3:20          3:17];

% ellipsoid #2 (Clarke 1880)
r2 = [7 7 7 7 8 8 8 8 9*ones(1,6) 10*ones(1,6) 11*ones(1,9) 12*ones(1,12) 13*ones(1,13) 14*ones(1,6)];
c2 = [33:36   33:36   32:37       32:37        30:38        28:39         28:40         35:40];

% ellipsoid #3 (Everest)
r3 = [12 12 12 13*ones(1,6) 14*ones(1,6)];
c3 = [44 47 48 43:48        41:46];

% ellipsoid #4 (Bessel)
r4 = [10 10 10 10 11 11 15 15 15 16*ones(1,5)];
c4 = [48:51       49 50 52:54    51:55];

% ellipsoid #1 & ellipsoid #4 (Clarke 1866 & Bessel)
r14 = 11; c14 = 51;

% ellipsoid #1 & ellipsoid #5 (Clarke 1866 & International)
r15 = [11 11 12*ones(1,6)      13 13 13 13 14 14 16 16 16 17*ones(1,6) 18*ones(1,5)  20 20];
c15 = [17 52 14 15 19 20 50 52 11 12 50 51  9 10  1 21 22 3:5 7 8 59   1 21 22 59 60 18 19];

% ellipsoid #2 & ellipsoid #5 (Clarke 1880 & International)
r25 = [6 6 6 6  7  8  8 10 10 11 11 11 12 12 13 14 14 14 15*ones(1,6)];
c25 = [33:36   37 32 37 31 38 28 29 39 27 40 27 29 31 33 35:40];

% ellipsoid #3 & ellipsoid #4 (Everest & Bessel)
r34 = [11 11]; c34 = [47 48];

% ellipsoid #3, ellipsoid #4 & ellipsoid #5 (Everest, Bessel & International)
r345 = 12; c345 = 49;

% ellipsoid #3 & ellipsoid #5 (Everest & International)
r35 = [11 11 12 12 12 12 13 13 13 14 14 15*ones(1,6)];
c35 = [43 44 42 43 45 46 41 42 49 47 48 41:46];

% ellipsoid #4 & ellipsoid #5 (Bessel & International)
r45 = [9 9 9 9 9 10 10 11 14 14 14 15 15 16 16 17*ones(1,7)];
c45 = [48:52     47 52 46 52:54    50 51 50 56 50:52 54:57];

% encode rest of ellipsoid matrix
ellps(sub2ind([20 60],r1,c1)) = 1;
ellps(sub2ind([20 60],r2,c2)) = 2;
ellps(sub2ind([20 60],r3,c3)) = 3;
ellps(sub2ind([20 60],r4,c4)) = 4;
ellps(sub2ind([20 60],r14,c14)) = 14;
ellps(sub2ind([20 60],r15,c15)) = 15;
ellps(sub2ind([20 60],r25,c25)) = 25;
ellps(sub2ind([20 60],r34,c34)) = 34;
ellps(sub2ind([20 60],r345,c345)) = 345;
ellps(sub2ind([20 60],r35,c35)) = 35;
ellps(sub2ind([20 60],r45,c45)) = 45;

% get geoid code based on input zone

latzones = char([67:72 74:78 80:88]');

if length(zone)==2
	lnindx = str2num(zone(1));    ltindx = strmatch(zone(2),latzones);
elseif length(zone)==3
	lnindx = str2num(zone(1:2));  ltindx = strmatch(zone(3),latzones);
end

code = ellps(ltindx,lnindx);

