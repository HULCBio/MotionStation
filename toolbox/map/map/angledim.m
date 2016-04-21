function angmat = angledim(angmat,from,to)
%ANGLEDIM Convert angles from one unit system to another.
%
%   ANGMAT = ANGLEDIM(ANGMAT,FROM,TO) converts angles in ANGMAT
%   from units FROM to units TO.  FROM and TO may be any of the
%   following strings:
%
%       'degrees'
%       'dm'  (for deg:min)
%       'dms' (for deg:min:sec)
%       'radians'
%
%   and may be abbreviated.  FROM and TO are case-insensitive.
%
%   See also UNITSRATIO.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.3 $  $Date: 2004/02/01 21:57:21 $

if ~isa(angmat, 'double')
    id = sprintf('%s:%s:nonDoubleInput', getcomp, mfilename);
    error(id,'ANGMAT must be double.');
end

from = checkAngleStrings(from);
to   = checkAngleStrings(to);
% angleStrings = {'degrees','radians','dm','dms'};
% from = checkstrs(from, angleStrings, mfilename, 'FROM', 2);
% to   = checkstrs(to,   angleStrings, mfilename, 'TO',   3);

% Convert complex input.
if ~isreal(angmat)
    % warning('Imaginary parts of complex ANGLE argument ignored')
    angmat = real(angmat);
end

% Optimize slightly for no-op situation.
if strcmp(from,to)
    return
end

%  Find the appropriate string matches and transform the angles
switch from
    case 'degrees'
	      switch to
				case 'dm',        angmat = deg2dm(angmat);
				case 'dms',       angmat = deg2dms(angmat);
		        case 'radians',   angmat = angmat*pi/180;
	     end

	case 'radians'
	      switch to
		        case 'degrees',   angmat = angmat*180/pi;
				case 'dm',        angmat = rad2dm(angmat);
				case 'dms',       angmat = rad2dms(angmat);
	     end

	case 'dm'
	      switch to
		        case 'degrees',   angmat = dms2deg(angmat);
				case 'dms',       angmat = angmat;
				case 'radians',   angmat = dms2rad(angmat);
	     end

	case 'dms'
	      switch to
		        case 'degrees',   angmat = dms2deg(angmat);
				case 'dm',        angmat = dms2dm(angmat);
				case 'radians',   angmat = dms2rad(angmat);
	     end
end

%--------------------------------------------------------------------------

function out = checkAngleStrings(in)

if ~ischar(in)
    id = sprintf('%s:%s:nonStrInput', getcomp, mfilename);
    error(id,'FROM and TO must be strings.');
end

in = lower(in);
switch in
  case {'radians' 'r' 'ra' 'rad' 'radi' 'radia' 'radian'}
    out = 'radians';
    
  case {'degrees' 'de' 'deg' 'degr' 'degre' 'degree'}
    out = 'degrees';
    
  case {'dm'}
    out = 'dm';
    
  case {'dms'}
    out = 'dms';
    
  otherwise
    error('FROM and TO must be ''degrees'', ''dm'', ''dms'', or ''radians''.');
end
