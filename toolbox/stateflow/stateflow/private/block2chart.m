function chart = block2chart(blockH)
% BLOCK2CHART returns the Stateflow chart ID for a Simulink block handle
% Handles both library and non-libray charts

%   J. Breslau
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/04/15 00:56:02 $

if(is_an_sflink(blockH))
    chart = sflink2chart(blockH);
else
    chart = local_block2chart(blockH);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chart = sflink2chart(blockH)
% first get the reference block and then force open the
% libray machine to get at the source chart.

ref = get_param(blockH, 'ReferenceBlock');
rootName = get_root_name_from_block_path(ref);
sf_force_open_machine(rootName);
refH = get_param(ref, 'handle');
chart = local_block2chart(refH);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chart = local_block2chart(blockH)
    chart = sf('get', get_param(blockH, 'userdata'), 'instance.chart');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rootName = get_root_name_from_block_path(blkpath)
%
	ind = min(find(blkpath=='/'));
	rootName = blkpath(1:(ind(1)-1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isLink = is_an_sflink(blockH),
%
% Determine if a block is a link
%
if isempty(get_param(blockH, 'ReferenceBlock')),
   isLink = 0;
else,
   isLink = 1;
end;
