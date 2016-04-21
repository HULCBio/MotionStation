function GeneralInit(h)
%   GENERALINIT is the init method get called by RTW.makertw constructor.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/15 00:23:49 $


% General initialization %
h.BuildDirectory     	      = '';
h.StartDirToRestore 	      = '';
h.GeneratedTLCSubDir   	      = '';
h.AnsiDataTypeTable           = [];
h.mexOpts                     = [];
