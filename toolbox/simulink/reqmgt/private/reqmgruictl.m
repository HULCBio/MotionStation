function rstat = reqmgruictl(action, filename, id, blockname, reqsys)
%REQMGRUICTL GUI controller to REQMGR requirements dispatcher.
%   REQMGRUICTL(ACTION) sends an entire model (export) or selects 
%   specific items of the current model.  E.g.,
%   reqmgruictl('send') will export the current model.
%
%   REQMGRUICTL(ACTION, FILENAME) is used for sending an entire 
%   model (export) or selecting specific items. For example, 
%   reqmgruictl('send', 'clutch') 
%   will export the clutch model in the simdemos directory.
%
%   REQMGRUICTL(ACTION, FILENAME) to highlight a specific requirement
%   of the currently selected block in Simulink.  Use, e.g.,
%   reqmgruictl('select', 'clutch')
%   should select specific requirements to highlight.
%
%   REQMGRUICTL(ACTION, FILENAME, ID, BLOCKNAME) is used 
%   to test a requirements system call to MATLAB/Simulink) to highlight
%   a specific block in a block diagram.  Normally this call would be
%   made from the requirements system. For example, 
%   reqmgruictl('display', 'clutch', '13', ...
%      'clutch/Friction Mode Logic/Break Apart Detection')
%   will open the "Friction Mode Logic" subsystem and highlight 
%   the "Break Apart Detection" block.
%
%   REQSYS is optional.  If not supplied, the default will be used
%   from REQMGROPTS.  If it's empty, an error is thrown.
%   
%   Return value is a string for all successful completions.  Errors are thrown.
%

%  Author(s): M. Greenstein, 09/17/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:31 $

rstat = 0;
n = 0;

% Minimum number of arguments.
if (nargin < 1)
   error('No arguments specified.');
end

% Check for configured requirements system.
if (~exist('reqsys') | ~length(reqsys))
   reqsys = reqmgropts;
end
if (~length(reqsys)),
   error('No default requirements system has been configured.');
end

% Take appropriate "action."
action = lower(action);
switch (action),
   case 'send',
      % Export entire model to requirements system.
      %%%%if (~exist('filename') | ~length(filename))
      if (~exist('filename'))
         error('No filename has been specified.');
      end

      reqmgr('Init', reqsys);

      n = reqmgr('SendStart', filename);

      m = 0;
      for i = 1:n
         m = reqmgr('Send');
      end

      reqmgr('SendEnd');
      if (n ~= m),
         error([filename ' not properly synchronized.  Processed ' num2str(m) ' of ' num2str(n) ' items.']);
      end

      rstat = n;

   case 'select',
      % Select the current block in the requirements system.
      if (~exist('filename')) % Can be an empty string.
         error('No filename has been specified.');
      end
      if (~exist('blockname') | ~length(blockname))
         %error('No blockname has been specified.');
      end
      %%%%if (~exist('id') | ~length(id))
      if (~exist('id')) % Can be an empty string.
         error('No id has been specified.');
      end

      reqmgr('Init', reqsys);
      reqmgr('SelectStart', filename);
      reqmgr('Select', id, blockname);
      reqmgr('SelectEnd');

   case 'display',
      % Test of select blocks to navigate to MATLAB/Simulink from reqirements system.
		if (nargin < 4)
			error('Insufficient number of arguments.');
		end

      dmiSelectBlockStart_(filename);
      dmiSelectBlock_(id, blockname);
      dmiSelectBlockEnd_;
      
   case 'getmodifieddate',
      if (~exist('filename') | ~length(filename))
         error('No filename has been specified.');
      end
      
      reqmgr('Init', reqsys);
		reqmgr('SelectStart', filename);
		rstat = reqmgr('GetModifiedDate');
      reqmgr('SelectEnd');

   otherwise,
      error(['Unknown action type: ' action '.']);
end % switch (action),

% Everything returns from here or errors out.
if (isnumeric(rstat))
   rstat = num2str(rstat);
end
