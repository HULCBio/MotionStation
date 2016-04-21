function [sfVersion] = sfversion(arg)
%SFVERSION Returns the current Stateflow version.
%   [sfVersion] = SFVERSION
%   Returns the current Stateflow version in a readable string format with time-stamp.
%
%   [sfVersion] = SFVERSION('STRING')
%   Returns the current Stateflow version as a dot delimited string.
%
%   [sfVersion] = SFVERSION('NUMBER')
%   Returns the current Stateflow version as a double.
%
%   [sfVersion] = SFVERSION('FULL_STRING')
%   Returns the current Stateflow version as a dot delimited string of
%   numbers. The full version number is a 14 digit entity: sss.rr.pp.f.bbbbbb
%         sss -- Stateflow release number {<major>,<point release>,<bug release>}
%          rr -- MATLAB release e.g 11 for R11
%          pp -- MATLAB point release (e.g 03 for Beta 3)
%           f -- Final release flag this digit is 1 for an official final release its zero otherwise
%      bbbbbb -- 6 digit internal build number
%
%   [sfVersion] = SFVERSION('FULL_NUMBER')
%   Returns the current Stateflow full version number as a double.
%
%   See also STATEFLOW, SFSAVE, SFPRINT, SFEXIT, SFROOT, SFHELP, SFCLIPBOARD.

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/15 01:01:50 $

  sfVersion = sf('Version');
  
  if nargin > 0,
     if ischar(arg),
        dot = '.';
        switch (lower(arg)),
         case 'string',
           sfVersion = sf('Version', 'string');
           ind = find(sfVersion == dot);
           sfVersion = sfVersion(1:(ind(3)-1));
         case 'number',
           sfVersion = sf('Version', 'string');
           ind = find(sfVersion==dot);
           sfVersion = sfVersion(1:(ind(3)-1));
           sfVersion(ind(2)) = [];
           sfVersion = str2num(sfVersion);
	 case 'full_string',
	   sfVersion = sf('Version', 'string');
         case 'full_number',
           sfVersion = sf('Version', 1);
         otherwise,
         end;
     end;
  end;



