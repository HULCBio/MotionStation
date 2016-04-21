function [sam,disabled,dispstr,estring] = ...
    vector_init_mask(tag,baud_rate,presc_in,sjw_in,tseg1_in,tseg2_in,...
		     sam_in,manual_bit_timings,block)
%VECTOR_INIT_MASK mask initialization for the Vector CAN config block
%   Called from the mask initialization fo this block
%
%   VECTOR_INIT_MASK(tag,presc,sjw,tseg1,tseg2,sam,disabled)

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $
%   $Date: 2004/04/19 01:20:19 $

%
% if disabled set params accordingly 
%

% Get the derived parameters
[disabled] = vector_config_params(block);

if disabled==1
  baud_rate_name = 'Undefined';
  presc=0;
  sjw=0;
  tseg1=0;
  tseg2=0;
  sam=0;
else 
  
  switch manual_bit_timings
   case 0
    % use pre-calculated baud rate
    % the callback function now deals with
    % setting the bit timing params.
     switch baud_rate
     case 1,
      baud_rate_name = '1M';
     case 2,
      baud_rate_name='500k';
     case 3,
      baud_rate_name='100k';
     case 4,
      baud_rate_name = '10k';
     end;
   case 1
    % use manual bit timings
    baud_rate_name='manual';
    % save warning status
    warning_status = warning('query', 'all');                                                   
    try
      lasterr('');
      % disable a warning about these comparisons to 0
      warning off;
      if ((presc_in==0) | (sjw_in==0) | (tseg1_in==0) | (tseg2_in==0))
        %default to 1M
        presc = 1;
        sjw=1;
        tseg1 = 4;
        tseg2=3;
        sam=0;
        % update the displayed values
        local_update_displayed_values(presc, sjw,tseg1,tseg2,sam)
      end
    end
    %restore warning status
    warning(warning_status);                                                                
    % error(lasterr) does nothing when lasterr is empty
    error(lasterr);
  end  
  % must return the correct value for sam 
  % since it differs from the sam_in parameter.
  sam_in = get_param(block,'sam_in');
  if (strcmp(sam_in,'1 sample per bit') == 1)
      sam = 0;
  elseif (strcmp(sam_in,'3 samples per bit') == 1)
      sam = 1;
  end;
end

% Mask display string

dispstr = sprintf('Vector CAN \nConfiguration \n(%s)', tag);

% make sure the config tag for this block is unique!
% search for config blocks.
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

% initially no error
estring = 'null';
for i=1:length(configblock)
    % skip if it is the current block!
    if (strcmp(get_param(configblock{i},'Name'),get_param(gcbh,'Name'))==1)
      continue;
    end;
    if (strcmp(get_param(configblock{i},'tag_param'), tag)==1)
      % note: error string is passed back for evaluation in the mask.
      % this allows the mask display to be updated correctly.
      estring = sprintf('Another configuration block exists with tag %s. \n Change the tag in one of the configuration blocks and associate the required TX and RX blocks with that tag.',tag);
    end;
end;
% 

% update the displayed values
function local_update_displayed_values(presc, sjw,tseg1,tseg2,sam)
    
  set_param(gcb,'presc_in',num2str(presc));
  set_param(gcb,'sjw_in',num2str(sjw));
  set_param(gcb,'tseg1_in',num2str(tseg1));
  set_param(gcb,'tseg2_in',num2str(tseg2));
  if sam==0
    set_param(gcb,'sam_in','1 sample per bit');
  elseif sam==1
    set_param(gcb,'sam_in','3 samples per bit');
  end
