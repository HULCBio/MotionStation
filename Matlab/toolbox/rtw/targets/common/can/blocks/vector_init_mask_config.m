function vector_init_mask_config(action,block,varargin)
%VECTOR_INIT_MASK_CONFIG sets mask params for Vector CAN config block
%   Callback function used to disable/enable mask parameters
%   according to other settings in the mask dialog
%
%   VECTOR_INIT_MASK_CONFIG(action,block) performs the
%   the specified action

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $
%   $Date: 2004/04/19 01:20:20 $

  switch lower(action)
   case 'channel'
    disabled = vector_config_params(block);
    switch disabled
     case 1
      local_disable(block);
     case 0
      local_enable(block);
      % this may have affected bit timing fields so need to reset them
      vector_init_mask_config('timing',block);
    end
   case 'timing'
    d=get_param(block,'manual_bit_timings');
    switch d
     case 'on'
      local_enable_manual_bit_timing(block);
     case 'off'
      local_disable_manual_bit_timing(block);
      % we've moved back to pre-calculated baud rate
      % update bit timing params. in the mask
      baud_rate = get_param(block,'baud_rate');
      local_update_displayed_values(baud_rate);
    end
   case 'baud_rate'
     % pre-calculated baud rate has been changed - need to update
     % bit timing parameters in the mask
     % must check that we are not in manual bit timing mode though!!!
     man_bit_timings=get_param(block,'manual_bit_timings');
     if (strcmp(man_bit_timings,'off') == 1) 
        baud_rate = get_param(block,'baud_rate');
        local_update_displayed_values(baud_rate);
     end;
   case 'copyfcn_callback'
       % display a warning that this is the old block and
       % the mask has been updated in the new block
       newline = sprintf('\n');
       warnstring = ['The Vector CAN Configuration block has been superseded. ' ...
                     'The new block allows the specification of arbitrary CAN bit '...
                     'rates in the mask.' newline newline...
                     'Please use the new block from the CAN Drivers (Vector) library.'];
       warndlg(warnstring, 'Vector CAN Configuration Superseded');
       
       
  end

function local_update_displayed_values(baud_rate) 
    switch baud_rate
     case '1 MBaud',
      presc = 1;
      sjw = 1;
      tseg1 = 4;
      tseg2 = 3;
      sam = 0;
     case '500 kBaud',
      presc = 1;
      sjw = 1;
      tseg1 = 8;
      tseg2 = 7;
      sam = 0;
     case '100 kBaud',
      presc = 4;
      sjw = 4;
      tseg1 = 12;
      tseg2 = 7;
      sam = 1;
     case '10 kBaud',
      presc = 32;
      sjw = 4;
      tseg1 = 16;
      tseg2 = 8;
      sam = 1;
    end;
    
    set_param(gcb,'presc_in',num2str(presc));
    set_param(gcb,'sjw_in',num2str(sjw));
    set_param(gcb,'tseg1_in',num2str(tseg1));
    set_param(gcb,'tseg2_in',num2str(tseg2));
    if sam==0
        set_param(gcb,'sam_in','1 sample per bit');
    elseif sam==1
        set_param(gcb,'sam_in','3 samples per bit');
    end
    
function local_enable_manual_bit_timing(block)
  
  simUtil_maskParam('hide',block,'baud_rate');
  simUtil_maskParam('enable',block,'presc_in');
  simUtil_maskParam('enable',block,'sjw_in');
  simUtil_maskParam('enable',block,'tseg1_in');
  simUtil_maskParam('enable',block,'tseg2_in');
  simUtil_maskParam('enable',block,'sam_in');
  
  
function local_disable_manual_bit_timing(block)
  
  simUtil_maskParam('show',block,'baud_rate');
  simUtil_maskParam('disable',block,'presc_in');
  simUtil_maskParam('disable',block,'sjw_in');
  simUtil_maskParam('disable',block,'tseg1_in');
  simUtil_maskParam('disable',block,'tseg2_in');
  simUtil_maskParam('disable',block,'sam_in');
  
  
function local_enable(block)
  
  simUtil_maskParam('enable',block,'baud_rate');
  simUtil_maskParam('enable',block,'manual_bit_timings');
  simUtil_maskParam('enable',block,'presc_in');
  simUtil_maskParam('enable',block,'sjw_in');
  simUtil_maskParam('enable',block,'tseg1_in');
  simUtil_maskParam('enable',block,'tseg2_in');
  simUtil_maskParam('enable',block,'sam_in');
  
function local_disable(block)
  simUtil_maskParam('disable',block,'baud_rate');
  simUtil_maskParam('disable',block,'manual_bit_timings');
  simUtil_maskParam('disable',block,'presc_in');
  simUtil_maskParam('disable',block,'sjw_in');
  simUtil_maskParam('disable',block,'tseg1_in');
  simUtil_maskParam('disable',block,'tseg2_in');
  simUtil_maskParam('disable',block,'sam_in');
  



