function [frame_type,frame_disp,disabled,dispstr,estring] = ...
    vector_rx_mask(tag, frame_type_in, output_time)
%VECTOR_RX_MASK mask initialization for the Vector CAN RX block
%   Called from the mask initialization fo this block

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.2 $
%   $Date: 2004/04/19 01:20:21 $
	
dispstr = sprintf('Vector CAN \nReceive \n(%s)', tag);

frame_type = frame_type_in - 1;
if (frame_type==0)
   frame_disp = 'Standard';
else
   frame_disp = 'Extended';
end;
% 
% find our config. block.
% disable warnings whilst doing find_system because there may be unintialised parameters
%
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
% no error yet.
estring = 'null';
if (found == 0)
   % note: estring is passed back to the mask and an error is thrown
   % allows mask display to be updated correctly.
   estring = sprintf('Configuration block with Tag %s was not found in %s.\nPlace a configuration Block with matching tag in the model or change the tag in the TX/RX blocks.',tag,sysroot);
end;






