function preferences = iptprefs
%IPTPREFS Image Processing Toolbox preference settings.
%   IPTPREFS returns a 3-column cell array containing the Image
%   Processing Toolbox preference settings.  Each row contains
%   information about a single preference.  
%   
%   The first column of each row contains a string indicating the
%   name of the preference.  The second column of each row is a
%   cell array containing the set of acceptable values for that
%   preference setting.  An empty cell array indicates that the
%   preference does not have a fixed set of values.  
%
%   The third column of each row contains a single-element cell
%   array containing the default value for the preference.  An
%   empy cell array indicates that the preference does not have a
%   default value.
%
%   See also IPTSETPREF, IPTGETPREF.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.14.4.2 $  $Date: 2003/05/03 17:52:07 $

preferences = { ...
      'ImshowBorder',               {'tight'; 'loose'},   {'loose'}
      'ImshowAxesVisible',          {'on'; 'off'},        {'off'}
      'ImshowTruesize',             {'auto'; 'manual'},   {'auto'}
      'TruesizeWarning',            {'on'; 'off'},        {'on'}
      'ImviewInitialMagnification', {100; 'fit'},         {100}
   };
        
