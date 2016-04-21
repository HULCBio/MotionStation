function [ymat,xmat] = undotrim(ymat,xmat,trimpts,object)

%UNDOTRIM  Removes object trims introduced by TRIMDATA
%
%  [ymat,xmat] = undotrim(ymat,xmat,trimpts,'object') will remove the
%  object trims introduced by TRIMDATA.  This function is necessary to
%  properly invert projected data from the cartesian space to the
%  original lat, long data points.  The input variable, trimpts, must
%  be constructed by the function TRIMDATA.
%
%  Allowable object string are:  'surface' for undoing trimmed graticules;
%  'light' for undoing trimmed lights; 'line' for undoing trimmed lines;
%  'patch' for undoing trimmed patches; and 'text' for undoing trimmed
%  text object location points.
%
%  See also CLIPDATA, TRIMDATA, UNDOCLIP

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.8.4.1 $    $Date: 2003/08/01 18:23:07 $


%  Argument tests

if nargin ~= 4;  error('Incorrect number of arguments');  end

%  Return if nothing to undo

if isempty(trimpts);    return;   end

%  Switch according to the correct object

switch object
    case 'surface'
	      ymat(trimpts(:,1)) = trimpts(:,2);
	      xmat(trimpts(:,1)) = trimpts(:,3);
    case 'light'
	      xmat = xmat;   ymat = ymat;

    case 'line'
	      if size(trimpts,2) == 3
		      ymat(trimpts(:,1)) = trimpts(:,2);
	          xmat(trimpts(:,1)) = trimpts(:,3);
		  elseif size(trimpts,2) == 4
		      ymat(trimpts(:,1)) = trimpts(:,3);
	          xmat(trimpts(:,1)) = trimpts(:,4);
		  end
    case 'patch'
	      trimpts = flipud(trimpts);          % undo them in reverse order, important when off both bottom and side
          ymat(trimpts(:,1)) = trimpts(:,3);
          xmat(trimpts(:,1)) = trimpts(:,4);
    case 'text'
	      if size(trimpts,2) == 3
		      ymat(trimpts(:,1)) = trimpts(:,2);
	          xmat(trimpts(:,1)) = trimpts(:,3);
		  elseif size(trimpts,2) == 4
		      ymat(trimpts(:,1)) = trimpts(:,3);
	          xmat(trimpts(:,1)) = trimpts(:,4);
		  end
    otherwise
         error(['Unrecognized object:  ',object])
end
