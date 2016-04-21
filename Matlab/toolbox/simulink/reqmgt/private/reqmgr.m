function retstat = reqmgr(command, varargin)
%REQMGR General requirements management interface.
%  RETSTAT = REQMGR(COMMAND) and 
%  RETSTAT = REQMGR(COMMAND, VARARGIN) calls result
%  in calls to the lower-level support functions.
%
%  Normally the caller would 1.) specify the requirements system,
%  2.) start a transaction block, 3.) perform some transactions,
%  and 4.) close the transaction block.  For example,
%
%  1. RETSTAT = REQMGR('INIT', 'DOORS'), e.g., to
%     specify the requirements system as DOORS.
%  2. RETSTAT = REQMGR('SENDSTART', 'F14.MDL') to open
%     the f14 model, connection to the requirements
%     system, and set up context.
%  3. RETSTAT = REQMGR('SEND') to send a block of the model
%     iteratively.  There may be several of these calls.
%  4. RETSTAT = REQMGR('SENDEND') to close the connection to
%     requirements system and to clean up.
%
%  SENDSTART, SEND, AND SENDEND can be replaced with SELECTSTART,
%  SELECT, and SELECTEND or DISPLAYSTART, DISPLAY, and DISPLAYEND.
%
%  Returns: status from REQMGRCTL and specifics codes (0 = success,
%  <0 = failures).
%
%  Design note:  This code was designed around the need for 1.)
%  persistence in repeated calls to iteratively operate on a
%  model, 2.) adding support for other requirements systems, and
%  3.) the fact that persistent variables in MATLAB must live
%  in a single function.
%
%  See also REQMGRCTL,  DMISELECTBLOCKSTART, DMISELECTBLOCK, 
%     DMISELECTBLOCKEND

%  Author(s): M. Greenstein, 07/17/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:28 $

retstat = 0;

% Main command switch
command = lower(command);
switch command,
   %--- SET ---%
   case 'init',
      retstat = reqmgrctl('init', varargin{1});

   %--- SEND ---%
   case 'sendstart',
      retstat = reqmgrctl('start', 'send', varargin{1});

   case 'send',
      retstat = reqmgrctl('send', 'send');

   case 'sendend',
      retstat = reqmgrctl('end', 'send');

   %--- SELECT ---%
   case 'selectstart',
      retstat = reqmgrctl('start', 'select', varargin{1});

   case 'select',
      retstat = reqmgrctl('send', 'select',  varargin{1}, varargin{2});

   case 'selectend',
      retstat = reqmgrctl('end', 'select');

   %--- DISPLAY ---%
   case 'displaystart',
      retstat = reqmgrctl('start', 'display', varargin{1});

   case 'display',
      retstat = reqmgrctl('send', 'display', varargin{1}, varargin{2});

   case 'displayend',
      retstat = reqmgrctl('end', 'display');
      
   %--- RUN ---%
   case 'run',   
       retstat = reqmgrctl('run', 'run', varargin{1}, varargin{2});
     
   %--- GETMODIFIEDDATE ---%
   case 'getmodifieddate',   
       retstat = reqmgrctl('getmodifieddate', 'getmodifieddate');
     

end % Main command switch

% end function retstat = reqmgr(command, varargin)

   
   
   








