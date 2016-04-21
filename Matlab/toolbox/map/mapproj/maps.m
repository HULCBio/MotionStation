function [idstr,msg] = maps(projin)

%MAPS  Lists available map projections and verifies id strings
%
%  MAPS lists the available map projections.
%
%  s = MAPS IDLIST returns the list of all available map
%  projection id strings.
%
%  s = MAPS NAMELIST returns the list of all available map
%  projection names.
%
%  s = MAPS CLASSCODES returns the list of codes for the projection
%  classes of all available maps projections.
%
%  str = MAPS('str') verifies and standardizes the map projection
%  id string.
%
%  [str,msg] = MAPS(...) returns the string indicating any error
%  condition encountered.
%
%  See also AXESM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.1.6.1 $    $Date: 2003/12/13 02:55:33 $

%  Get the map list structure
%  The map list structure is of the form:
%        list.Name
%        list.IdString
%        list.Classification
%        list.ClassCode

list = maplist;

%  Initialize outputs if necessary

if nargout ~= 0;   idstr = [];   msg = [];  end

%**************************************************
if nargin == 0     %  Display available projections
%**************************************************

     formatstr = '%-20s  %-32s    %-15s  \n';
     fprintf('\n%-20s \n\n','MapTools Projections')
     fprintf(formatstr,'CLASS','NAME','ID STRING');


     for i = 1:length(list)
          fprintf(formatstr,list(i).Classification,...
                            list(i).Name,...
                            list(i).IdString);
     end

     fprintf('\n%s\n','* Denotes availability for sphere only')
     fprintf('\n\n');


%**********************************************************************************
elseif strcmp(projin,'namelist')          %  Return the list of available map names
%**********************************************************************************

	 idstr = strvcat(list(:).Name);
     indx = find(idstr == '*');        %  Eliminate the astericks in the names
     if ~isempty(indx);   idstr(indx) = ' ';   end

%*********************************************************************************
elseif strcmp(projin,'idlist')          %  Return the list of available id strings
%*********************************************************************************

     idstr = strvcat(list(:).IdString);

%*********************************************************************************
elseif strcmp(projin,'classcodes')          %  Return the list of available id strings
%*********************************************************************************

     idstr = strvcat(list(:).ClassCode);

%*****************************************************************************
elseif isstr(projin)          %  Convert from string name to projection number
%*****************************************************************************

    projin = projin(:)';     %  Enforce row string vector
    idstring = strvcat(list(:).IdString);

    strindx = strmatch(projin,idstring);  %  Test for a match

    if length(strindx) == 1
         idstr = deblank(idstring(strindx,:));   %  Set the name string
    elseif length(strindx) > 1
         msg = ['Nonunique projection name:  ',projin];
         if nargout < 2;  error(msg);  end
    elseif isempty(strindx)
         msg = ['Projection name not found:  ',projin];
         if nargout < 2;  error(msg);  end
    end

%********************************
else        %  Not a valid option
%********************************

     msg = 'Unrecognized projection string';
     if nargout < 2;  error(msg);   end
end
