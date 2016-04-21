function cursys=gcs
%GCS Get the full path name of the current Simulink system.
%   GCS returns the full path name of the current system.  During editing,
%   the current system is the system or subsystem most recently clicked in.
%   During simulation of a system containing S-function blocks, the current
%   system is the system or subsystem containing the S-function block that
%   is currently being evaluated.
%   
%   See also GCB, GCBH.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $

cursys = get_param(0,'CurrentSystem');
