function load_open_subsystem(sys,subsys)
% LOAD_OPEN_SUBSYSTEM Directly open a subsystem within a system
%  LOAD_OPEN_SUBSYSTEM('SYS','SUBSYS') - Executes the equivalent of an
%  OPEN_SYSTEM('SYS') followed by a LOAD_SYSTEM('SUBSYS').
%  
%  This special function is used to simplify the job of the Simulink
%  browser in locating relvant blocks.  If this function appears in the 
%  OpenFcn of a subsystem, the sSimulink Browser will follow the path to
%  all blocks in SUBSYS.
%
%  See also OPEN_SYSTEM, LOAD_SYSTEM

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/02 03:04:02 $
error(nargchk(2,2,nargin));
load_system(sys);
open_system(subsys);