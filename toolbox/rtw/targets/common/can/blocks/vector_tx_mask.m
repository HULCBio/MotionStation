function [disabled,disp_str,estring] = vector_tx_mask(tag)
%VECTOR_TX_MASK mask initialization for the Vector CAN TX block
%   Called from the mask initialization fo this block

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.2 $
%   $Date: 2004/04/19 01:20:22 $

% 
% find our config. block.
% disable warnings whilst doing find_system because there may be unintialised parameters
%
  
disp_str = sprintf('Vector CAN\nTransmit \n(%s)', tag);  
  
sysroot=strtok(gcs,'/');
sws = warning;
warning off
configblock = find_system(sysroot,'LookUnderMasks','on',...
			  'FollowLinks','on',...
			  'MaskType',...
			  'Vector CAN Configuration');
warning(sws);


%
% default values for outputs
%
disabled = 1;
found = 0;

for i=1:length(configblock)
   config_tag = get_param(configblock{i},'tag_param');
   % check for the correct tag.
   if (strcmp(config_tag,tag)==1)
     [disabled] = vector_config_params(configblock{i});
     found = 1;
     % we're done.
     break;
  end;
end;

% initialize the error string
estring = 'null';
if (found == 0)
   % this error string is returned to the calling mask --> allows the mask display to be updated correctly.
   estring = sprintf('Configuration block with tag %s was not found in %s.\nPlace a configuration block with matching tag in the model or change the tag in the TX/RX blocks.',tag,sysroot);
end;


