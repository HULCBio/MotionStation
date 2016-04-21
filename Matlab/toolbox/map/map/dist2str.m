function strout = dist2str(distin,format,units,digits)

%DIST2STR  Distance conversion to a string
%
%  str = DIST2STR(dist) converts a numerical vector of distances to
%  a string matrix.  The output string matrix is useful for the
%  display of distances.
%
%  str = DIST2STR(dist,'format') uses the specified format input
%  to construct the string matrix.  Allowable format strings are
%  'pm' for plus/minus notation; and 'none' for blank/minus notation.
%  If omitted or blank, 'none' is assumed.
%
%  str = DIST2STR(dist,'format','units') defines the units which
%  the input distances are supplied.  This string also controls the
%  units in which the string matrix is constructed.  Any valid
%  distance units string can be entered.  If omitted or blank,
%  'kilometers' is assumed.
%
%  str = DIST2STR(dist,'format',digits) uses the input digits to
%  determine the number of decimal digits in the output matrix.
%  n = -2 uses accuracy in the hundredths position, n = 0 uses
%  accuracy in the units position.  Default is n = -2.  For further
%  discussion of the input n, see ROUNDN.
%
%  str = DIST2STR(dist,'format','units',digits) uses all the inputs
%  to construct the output string matrix.
%
%  See also DISTDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:15:50 $

if nargin == 0
    error('Incorrect number of arguments')

elseif nargin == 1
    format = [];              units  = [];     digits = [];

elseif nargin == 2
	units  = [];     digits = [];

elseif nargin == 3
    if isstr(units)
	    digits = [];
	else
	    digits = units;   units  = [];
	end
end

%  Empty argument tests

if isempty(digits);  digits  = -2;   end

if isempty(format);           format = 'none';
    elseif ~isstr(format);    error('FORMAT input must be a string')
	else;                     format = lower(format);
end

if isempty(units);        units  = 'kilometers';
    else;                 [units,msg]  = unitstr(units,'distance');
                          if ~isempty(msg);   error(msg);   end
end

%  Prevent complex distances

if ~isreal(distin)
    warning('Imaginary parts of complex DISTANCE argument ignored')
	distin = real(distin);
end

%  Ensure that inputs are a column vector

distin = distin(:);

%  Compute the prefix and suffix matrices.
%  Note that the * character forces a space in the output

switch format
   case 'pm'
      prefix = ' ';     prefix = prefix(ones(size(distin)),:);
      indx = find(distin>0);  if ~isempty(indx);   prefix(indx) = '+';   end
      indx = find(distin<0);  if ~isempty(indx);   prefix(indx) = '-';   end

   case 'none'
      prefix = ' ';     prefix = prefix(ones(size(distin)),:);
      indx = find(distin<0);  if ~isempty(indx);   prefix(indx) = '-';   end

   otherwise
      error('Unrecognized format string')

end


%  Compute the units suffix

switch units
	case 'degrees',         suffix = degchar;
    case 'kilometers',      suffix = '*km';
    case 'nauticalmiles',   suffix = '*nm';
	case 'statutemiles',    suffix = '*mi';
	case 'radians',         suffix = '*R';
end

%  Expand the suffix matrix to the same length as the input vector

suffix = suffix(ones(size(distin)),:);

%  Convert the distance vector to a string format

formatstr = ['%20.',num2str(abs(min(digits,0)) ),'f'];
str = num2str(abs(distin),formatstr);      %  Convert to a padded string
strout = [prefix str suffix];              %  Construct output string

%  Right justify each row of the output matrix.  This places
%  all extra spaces in the leading position.  Then strip these
%  lead zeros.  Left justifying and then a DEBLANK call will
%  not ensure that all strings line up.  LEADBLNK only strips
%  leading blanks which appear in all rows of a string matrix,
%  thereby not messing up any right justification of the string matrix.

strout = shiftspc(strout);
strout = leadblnk(strout,' ');

%  Replace the hold characters with a space

indx = find(strout == '*');
if ~isempty(indx);  strout(indx) = ' ';  end
