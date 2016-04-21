function strout = angl2str(angin,format,units,digits)
%ANGL2STR Convert an angle to a string.
%
%   str = ANGL2STR(ang) converts a numerical vector of angles to
%   a string matrix.  The output string matrix is useful for the
%   display of angles.
%
%   str = ANGL2STR(ang,'format') uses the specified format input
%   to construct the string matrix.  Allowable format strings are
%   'ew' for east/west notation; 'ns' for north/south notation;
%   'pm' for plus/minus notation; and 'none' for blank/minus notation.
%   If omitted or blank, 'none' is assumed.
%
%   str = ANGL2STR(ang,'format','units') defines the units in which
%   the input angles are supplied.  This string also controls the
%   units in which the string matrix is constructed.  Any valid
%   angle units string can be entered.  If omitted or blank,
%   'degrees' are assumed.
%
%   str = ANGL2STR(ang,'format',digits) uses the input digits to
%   determine the number of decimal digits in the output matrix.
%   n = -2 uses accuracy in the hundredths position, n = 0 uses
%   accuracy in the units position.  Default is n = -2.  For further
%   discussion of the input n, see ROUNDN.
%
%   str = ANGL2STR(ang,'format','units',digits) uses all the inputs
%   to construct the output string matrix.
%
%   See also STR2ANGLE, ANGLEDIM.

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by:  E. Byrns, E. Brown
%   $Revision: 1.14.4.2 $    $Date: 2003/12/13 02:50:03 $

checknargin(1,4,nargin,mfilename);

switch(nargin)
    case 1
        format = [];
        units  = [];
        digits = [];
    case 2
	    units  = [];
        digits = [];
    case 3
        if ischar(units)
	        digits = [];
	    else
	        digits = units;
            units  = [];
	    end
    otherwise
end

%  Empty argument tests

if isempty(digits)
    digits  = -2;
end

if isempty(format)
    format = 'none';
end

checkinput(format,{'char'},{},mfilename,'FORMAT',2);

format = lower(format);


if isempty(units)
    units  = 'degrees';
else
    [units,msg]  = unitstr(units,'angles');
    if ~isempty(msg)
        eid = sprintf('%s:%s:unitstrErr', getcomp, mfilename);
        error(eid, '%s', msg);
    end
end

%  Prevent complex angles
angin = ignoreComplex(angin,mfilename,'angin');

%  Ensure that inputs are a column vector
angin = angin(:);

%  Compute the radian or degree character for this computer

if strcmp(units,'radians')
    unitsymbol = '*R';         unitsymbol = unitsymbol(ones(size(angin)),:);
else
    unitsymbol = degchar;      unitsymbol = unitsymbol(ones(size(angin)),:);
end

%  Compute the prefix and suffix matrices.
%  Note that the * character forces a space in the output

switch format
   case 'ns'
      prefix = [];
      suffix = '**';    suffix = suffix(ones(size(angin)),:);

      indx = find(angin>0);  if ~isempty(indx);   suffix(indx,2) = 'N';   end
      indx = find(angin<0);  if ~isempty(indx);   suffix(indx,2) = 'S';   end

   case 'ew'
      prefix = [];
      suffix = '**';    suffix = suffix(ones(size(angin)),:);

      indx = find(angin>0);  if ~isempty(indx);   suffix(indx,2) = 'E';   end
      indx = find(angin<0);  if ~isempty(indx);   suffix(indx,2) = 'W';   end

   case 'pm'
      prefix = ' ';     prefix = prefix(ones(size(angin)),:);
      suffix = [];

      indx = find(angin>0);  if ~isempty(indx);   prefix(indx) = '+';   end
      indx = find(angin<0);  if ~isempty(indx);   prefix(indx) = '-';   end

   case 'none'
      prefix = ' ';     prefix = prefix(ones(size(angin)),:);
      suffix = [];

      indx = find(angin<0);  if ~isempty(indx);   prefix(indx) = '-';   end

   otherwise
      eid = sprintf('%s:%s:uknownFormatString', getcomp, mfilename);
      error(eid,'%s','Unrecognized format string')

end


%  Convert the angle vector to a string format

switch units
%************************************************
   case 'dms'     %  Degree Minute Seconds format
%************************************************

      spacestr    = '*';   spacestr    = spacestr( ones(size(angin)) );
      quotestr    = '''';  quotestr    = quotestr( ones(size(angin)) );
      dblquotestr = '"';   dblquotestr = dblquotestr( ones(size(angin)) );

%  Convert to matrix format.  Work with only the absolute values
%  since the sign is taken care of by the prefix string

      [d,m,s] = dms2mat(angin,digits);
      d = abs(d);      m = abs(m);        s = abs(s);

%  Construct the format string for converting seconds

	  rightdigits  = abs(min(digits,0));
      if rightdigits > 0;   totaldigits = 3+ rightdigits;
	      else              totaldigits = 2+ rightdigits;
	  end
	  formatstr = ['%0',num2str(totaldigits),'.',num2str(rightdigits),'f'];

%  Degrees, minutes and seconds

      d_str = num2str(d,'%4g');        %  Convert degrees to a string
      m_str = num2str(m,'%02g');       %  Convert minutes to a string
      s_str = num2str(s,formatstr);    %  Convert seconds to a padded string

%  Construct the display string

      strout = [prefix  leadblnk(d_str) unitsymbol    spacestr ...
	                    m_str quotestr      spacestr ...
		                s_str dblquotestr   suffix];

%***************************************
   case 'dm'     %  Degree Minute format
%***************************************

      spacestr    = '*';   spacestr    = spacestr( ones(size(angin)) );
      quotestr    = '''';  quotestr    = quotestr( ones(size(angin)) );

%  Convert to matrix format.  Work with only the absolute values
%  since the sign is taken care of by the prefix string

      [d,m,s] = dms2mat(dms2dm(angin));
	  d = abs(d);      m = abs(m);

%  Construct the strings

      d_str = num2str(d,'%4g');      %  Convert degrees to a string
      m_str = num2str(m,'%02g');     %  Convert minutes to a string

%  Construct the display string

      strout = [prefix leadblnk(d_str) unitsymbol spacestr ...
	                   m_str quotestr   suffix];

%*************************************
   case 'degrees'     %  Degree format
%*************************************

    formatstr = ['%20.',num2str(abs(min(digits,0)) ),'f'];
    str = num2str(abs(angin),formatstr);      %  Convert to a string
    strout = [prefix leadblnk(str) unitsymbol suffix];  %  Construct output string

%*************************************
   case 'radians'     %  Radian format
%*************************************

    formatstr = ['%20.',num2str(abs(min(digits,0)) ),'f'];
    str = num2str(abs(angin),formatstr);      %  Convert to a string
    strout = [prefix leadblnk(str) unitsymbol suffix];  %  Construct output string

end     %  End of units switch


%  Right justify each row of the output matrix.  This places
%  all extra spaces in the leading position.  Then strip these
%  lead zeros.  Left justifying and then a DEBLANK call will
%  not ensure that all strings line up.  LEADBLNK only strips
%  leading blanks which appear in all rows of a string matrix,
%  thereby not messing up any right justification of the string matrix.

strout = strjust(strout);
strout = leadblnk(strout,' ');

%  Replace the hold characters with a space

indx = find(strout == '*');
if ~isempty(indx);  strout(indx) = ' ';  end

%  Pad matrix with a space at front and back to avoid touching
%  the Map frame:

strout = [ char(32*ones(size(strout,1),1)) strout char(32*ones(size(strout,1),1))];
