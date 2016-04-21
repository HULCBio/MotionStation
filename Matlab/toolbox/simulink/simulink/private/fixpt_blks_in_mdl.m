function hasFixPtBlks = fixpt_blks_in_mdl(model,linksToo)
%FIXPT_BLKS_IN_MDL determines if a model contains blocks from the Fixed-Point
%  blockset.
%  The linksToo boolean input determines library links are followed in the
%  search for fixed point blocks.  The default is no

%   Because of shared licenses, must be very careful to NOT cause an unwarranted
%   checkout of a fixed point license.  An inadequate approach is only checking 
%   to see if fixed point functions exist.  Suppose a company owns 500 shared
%   licenses to Simulink, but only one shared license to Fixed Point Blockset.
%   Hundreds of users will simultaneously see Fixed Point Blockset functions
%   on their path, but only one can actually use the Fixed Point Blockset.
%   Detective work is needed to determine if the users model actual involves
%   fixed point blocks.  This detective work must be careful not to 
%   accidentally involke a function in the toolbox/fixpoint because this
%   would check out a license.
%
% The following is robust to updates in the name of the fixed point library
% provided the name always begins with the string 'fixpt'.  This has been
% true for all releases from 2.0 on.  It is not robust to third party librarys
% that begin with the same string.
%

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.3 $

if nargin < 1
  model = bdroot(gcs);
end

if nargin < 2
  linksToo = 0;
end

% Make sure the model is loaded
if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',model))
  preloaded = 0;
  load_system(model);
else 
  preloaded = 1;
end 

if linksToo
  hasFixPtBlks=~isempty(find_system(model,'FollowLinks','on','LookUnderMasks','all','Regexp','on','ReferenceBlock','^fixpt'));
else
  hasFixPtBlks=~isempty(find_system(model,                   'LookUnderMasks','all','Regexp','on','ReferenceBlock','^fixpt'));
end

% close model if not previously loaded
if preloaded == 0
  close_system(model,0);
end
