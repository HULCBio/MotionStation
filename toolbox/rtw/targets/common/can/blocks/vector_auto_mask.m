function varargout = vector_auto_mask(action,block,varargin)
%VECTOR_AUTO_MASK sets mask params for Vector CAN config block
%   Callback function used to disable/enable mask parameters
%   according to other settings in the mask dialog
%
%   VECTOR_AUTO_MASK(action,block) performs the
%   the specified action

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:20:15 $
switch lower(action)
    case 'init'
        % mask initialisation
        varargout{1} = i_init(block, varargin{1});
    case 'channel_callback'
        % enable / disable the mask parameters
        disabled = i_isBlockDisabled(block);
        switch disabled
            case 1
                i_disable(block);
            case 0
                i_enable(block);
        end
    case 'update_timing_params_callback'
        i_update_bit_timing_params(block);
  end;
return;
  
% has a Vector channel been selected in the mask?
function disabled = i_isBlockDisabled(block) 
    % get the string name of the channel
    channel_param = get_param(block,'channel_param'); 
    if strcmp(channel_param, 'None')
        % no channel has been selected
        disabled = 1;
    else
        % channel has been selected
        disabled = 0;
    end;
return;

% this function is called by mask initialisation - note, it should not call
% set_param
% this will handle work space / mask parameters correctly
% the only things we are interested in changing are the return arguments
% from this function
function out = i_init(block, in)
    % get input parameters
    bit_rate = in.bit_rate;
    nq = in.nq;
    sample_point = in.sample_point;
    tag = in.tag;
                        
    % call the shared (between callbacks and mask init) function
    [presc, tseg1, tseg2] = i_automatic_bit_timings(bit_rate, sample_point, nq);

    % make sure the config tag for this block is unique!
    % search for config blocks.
    % disable warnings whilst doing find_system because there may be unintialised parameters
    %
    sysroot=strtok(block,'/');
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
        if (strcmp(get_param(configblock{i},'Name'),get_param(block,'Name'))==1)
            continue;
        end;
        if (strcmp(get_param(configblock{i},'tag_param'), tag)==1)
            % note: error string is passed back for evaluation in the mask.
            % this allows the mask display to be updated correctly.
            estring = sprintf('Another configuration block exists with tag %s. \n Change the tag in one of the configuration blocks and associate the required TX and RX blocks with that tag.',tag);
        end;
    end;
    
    % set output parameters
    out.presc = presc;
    out.tseg1 = tseg1;
    out.tseg2 = tseg2;
    out.disabled = i_isBlockDisabled(block);
    out.estring = estring;
return;

% this function is shared between mask init and mask callbacks
% calculate the timing parameters from the bit_rate
function [presc, tseg1, tseg2] = i_automatic_bit_timings(bit_rate, sample_point, nq) 
    % Vector chip frequency is 16 MHz
    fsys = 16e6;
    % note, we halve the frequency so that presc comes out correctly
    % for the vector CAN hardware
    [propseg, pseg1, pseg2, presc, sample] = can_bit_timing(fsys / 2, bit_rate, nq, sample_point);
    tseg1 = propseg + pseg1;
    tseg2 = pseg2;
return;

% callback could not evaluate owing to mask
% parameters being used - blank the dependant fields
% the mask init code will deal with it
function i_exit_bit_timing_callback(block)
    set_param(block, 'presc', '');
    set_param(block, 'tseg1', '');
    set_param(block, 'tseg2', '');   
return;

function i_update_bit_timing_params(block)
    % bit timing parameters are set automatically - this is the
    % only option allowed by the new block
    bit_rate = str2num(get_param(block, 'bit_rate'));
    sample_point = str2num(get_param(block, 'sample_point'));
    nq = str2num(get_param(block, 'nq'));

    if isempty(bit_rate) || isempty(sample_point) || isempty(nq)
        % mask init code will deal with this
        i_exit_bit_timing_callback(block);
        return;
    end;

    % call the shared (between callbacks and mask init) function
    [presc, tseg1, tseg2] = i_automatic_bit_timings(bit_rate, sample_point, nq);

    set_param(block, 'presc', num2str(presc));
    set_param(block, 'tseg1', num2str(tseg1));
    set_param(block, 'tseg2', num2str(tseg2));
return;

function i_enable(block)
  simUtil_maskParam('enable',block,'bit_rate');
  simUtil_maskParam('enable',block,'nq');
  simUtil_maskParam('enable',block,'sample_point');
  simUtil_maskParam('enable',block,'sjw');
  simUtil_maskParam('enable',block,'sam');
  simUtil_maskParam('disable',block,'presc');
  simUtil_maskParam('disable',block,'tseg1');
  simUtil_maskParam('disable',block,'tseg2');
  
function i_disable(block)
  simUtil_maskParam('disable',block,'bit_rate');
  simUtil_maskParam('disable',block,'nq');
  simUtil_maskParam('disable',block,'sample_point');
  simUtil_maskParam('disable',block,'presc');
  simUtil_maskParam('disable',block,'sjw');
  simUtil_maskParam('disable',block,'tseg1');
  simUtil_maskParam('disable',block,'tseg2');
  simUtil_maskParam('disable',block,'sam');
 