function [str, ic] = dspblkdelay(action,varargin)
% DSPBLKDELAY Mask dynamic dialog function for delay block

% Copyright 1995-2004 The MathWorks, Inc.
% $Date: 2004/04/12 23:06:15 $ $Revision: 1.1.4.2 $
if nargin==0
   action = 'dynamic';   % mask callback
end
blk     = gcbh;
switch action
case 'init'
    delayUnitSamps = strncmp(varargin{1},'Samples',1);
    delay_eval = varargin{2};
    ic = varargin{3};
    
    if (delayUnitSamps && ~isempty(delay_eval) && length(delay_eval)==1)
       	str = ['-' mat2str(delay_eval)]; 
    else
       str = ['-N'];
    end
    % for cell array IC, we first process the cell array in the mask helper
    % function. From edit box we get a cell array which must have 'nChans'
    % cells (nChans = # of channels) and each cell must be a vector. The S
    % function gets the cell info in the following format:
    % a cell array consisting of 3 cells {[1st_cell] [2nd_cell] [3rd_cell]}
    % 1st_cell: all 'nChans' cells are concatenated to get this cell.
    %           In this mask helper function we do not get the value of
    %           'nChans'. M,N in 2nd_cell provide this info to S function.
    % 2nd_cell: it has 3 elements [size of cell array (M N) 'mf']
    %           The definitiion of M,N,'mf' are given hereafter.
    % 3rd_cell: one element (non-zero value identifies a specific error)
    
    % Since S function doesn't get the info of each cell, we need to check
    % the validity of each cell in this mask helper function
    
    %%%%%%%validity checking and pre-processing for ONLY cell array IC.%%%%%%%    
    if (iscell(ic))
        %checking 1: double checking (see delay validity checking in S function)
        if ( isempty(delay_eval)|| (~isnumeric(delay_eval)) )
            ic = {[] [] [1]}; %errFlag = 1 for empty or non-numeric delay                                 
            return;
        end 
        %checking 2
        [Mic, Nic] = size(ic);
        [Md, Nd] = size(delay_eval);
        
        DelayIsVector = (Md == 1 || Nd == 1); %supporting row convenience
        IcIsVector    = (Mic == 1 || Nic == 1); %supporting row convenience
        
        % Since it is not possible to get nChans here, it is not possible
        % to verify IC in accordance with delay for scalar delay.
        % we have to do that checking in S function using the size of the
        % delay that is passed from this mask helper function.
        if ( length(delay_eval)~= 1 )
            if (DelayIsVector)
                if (~IcIsVector) 
                    ic = {[0] [0] [2]}; %errFlag = 2 for DelayIsVector(non scalar) but IcIsNotVector
                    return;
                %else IC is vector    
                elseif  (length(delay_eval) ~= length(ic))
                    % ecah channel must have a vector
                    ic = {[0] [0] [3]}; %errFlag = 3 for Delay and IC both are Vector but length(delay_eval) ~= length(ic)
                    return;
                else % DelayIsVector and ICisVector
                    if Mic == 1 % if DelayIsRowVector, IC must be RowVector, else make IC rowVector
                        if (Md~=1) delay_eval = delay_eval'; end
                    else% Nic must be 1. if DelayIsColVector, IC must be ColVector, else make IC ColVector  
                        if (Nd~=1) delay_eval = delay_eval'; end                        
                    end                        
                end 
            % delay is matrix        
            elseif (Mic ~= Md || Nic ~= Nd)
                ic = {[0] [0] [4]}; %errFlag = 4: if delayIsMatrix IC must be matrix of the same dim.
                return;
            end     
        end 

        a=[];
        b=[];
        first_time = 1;
        lst_quotient = 0;%values used when (delay_value == 0-> delay Unit sample or frame), or (delay_unit_sample)
		for j=1:Nic,
            for i=1:Mic,
                [m, n] = size(ic{i,j});
                if ((m  ~= 1) && (n  ~= 1)) %empty vector throws this error
                    ic = {[0] [0] [5]}; %ic = {[a] [M N] [errFlag]}; errFlag = 5 for non-vector cell
                    return; %set the errFlag and return to the invoking function
                end
                if (length(delay_eval) == 1)  
                    delay_value = delay_eval; 
                else
                    delay_value = delay_eval(i,j); 
                end
                if (delay_value == 0 && length(ic{i,j}) ~= 1) %true whether delay unit is sample or frame 
                    ic = {[0] [0] [6]};  %errFlag = 6, for zero delay length(ic{i,j} ~= 1
                    return;
                elseif (delay_value ~= 0)
                    if (iscell(ic{i,j}))
                        ic = {[0] [0] [7]};  %errFlag = 7, cell contains a cell, but it must be a vector
                        return;    
                    end                        
                    %when delay unit sample: The length of each cell vector
                    %must equal to the delay value of the corresponding
                    %channel.
                    %when delay unit frame: The length of each cell vector
                    %must be an integer multiple of the delay value of the
                    %corresponding channel. The multiplying factor (mf)
                    %must be the same for each channel. It is not possible
                    %to verify the value of 'mf' (which is equal to the
                    %frame length). So when delay unit frame, this 'mf' is
                    %passed to the S function for validity checking.                 
                    
                    if strcmp(get_param(blk,'dly_unit'),'Samples'),
                       if (length(ic{i,j}) ~= delay_value)
                          ic = {[0] [0] [8]};  %errFlag = 8, length(ic{i,j} ~= delay_value
                          return;
                       end
                    else  % delay unit frame.  
                       quotient = length(ic{i,j})/ delay_value;
                       if (quotient ~= floor(quotient)) % quotient is not an integer 
                           ic = {[0] [0] [9]};  %errFlag = 9, for delay unit = frame, 
                                                %length of each cell ~= FrmLen*delay value, exception zero delay case.
                           return;
                       end
                       if (first_time)
                           lst_quotient = quotient; %quotient = length(ic{1,1})/ delay_value;
                           first_time = 0;
                       end
                       if (quotient ~= lst_quotient)
                           ic = {[0] [0] [9]};  %same as above(errFlag = 9)
                           return;    
                       end
                    end  
                end    
                    
                if (m ~= 1) 
                    ic{i,j} = (ic{i,j}).'; % guard against transpose
                end
                if (delay_value ~= 0) a=[a ic{i,j}]; end % for zero delay value, skip the corresponding cell vector.
            end    
		end
		ic = {[a] [Mic Nic lst_quotient] [0]}; % nChan = Mic*Nic; errFlag = 0--> means No error, 
                                               % lst_quotient = multiplying factor
                                               % when 1st_quotient=0,no need to check it, else check (if 1st_quotient=FrmLen)                                               )
		%{a} for RTP. {nChan}, {b} & errFlag for error checking
    elseif  isempty(ic)
        ic = [0];        
    end % if (iscell(ic))
case 'icDetail'
    ShowHideICdetails(blk);    
case 'dynamic'
    DelayUnitChange(blk);
otherwise
    error('unhandled case');
      
end
%*********************************************************%
function ShowHideICdetails(blk)
  mask_visib   = get_param(blk,'MaskVisibilities');
  if (strcmp(get_param(blk,'ic_detail'),'off') && ...
      strcmp (mask_visib(4), 'on') )
        mask_visib(4:7)   = {'off'};
        set_param(blk,'MaskVisibilities', mask_visib);
  elseif (strcmp(get_param(blk,'ic_detail'),'on') && ...
          strcmp (mask_visib(4), 'off') )
            mask_visib(4:7)   = {'on'};
            set_param(blk,'MaskVisibilities', mask_visib);
  end
 %*********************************************************%
 function   DelayUnitChange(blk)
   mask_prompts = get_param(blk,'maskPrompts');
   if (strcmp(get_param(blk,'dly_unit'),'Samples') && ...
       strcmp (mask_prompts(2), 'Delay (frames):') )     
          mask_prompts(2) = {'Delay (samples):'};
          set_param(blk,'maskPrompts',mask_prompts); 
   elseif (strcmp(get_param(blk,'dly_unit'),'Frames') && ...
           strcmp (mask_prompts(2), 'Delay (samples):') )     
             mask_prompts(2) = {'Delay (frames):'};
             set_param(blk,'maskPrompts',mask_prompts); 
   end          

% [EOF] dspblkdelay.m
