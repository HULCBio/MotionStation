function dspblkdspconst(action)
% DSPBLKDSPCONST Signal Processing Blockset DSP Constant block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.13.4.6 $ $Date: 2004/04/12 23:06:19 $
  
  blk     = gcbh;
  obj     = get_param(blk,'object');
  fullblk = getfullname(blk);

  if nargin==0, action = 'dynamic'; end

  % Some constant values for the params that have their visibility
  % switched on and off
  [DISC_OUT,CONT_OUT,SAMP_TIME,FRAME_PERIOD] = deal(3,4,5,6);
  ON  = {'on'};
  OFF = {'off'};
  % NOTE: FRAME_POPUP is defined in insert_zoh_block subfunction as well
  FRAME_POPUP = 'Frame-based'; 
  SAMPLE_1D_POPUP = 'Sample-based (interpret vectors as 1-D)';
  SAMPLE_2D_POPUP = 'Sample-based';
        
  % Note that everything besides the Value parameter is non-tunable

  sampMode     = obj.SampleMode;
  isContinuous = strcmp(sampMode,'Continuous');

  vis         = obj.MaskVisibilities;
  lastVis     = vis;

  % Set the Simulink Constant block to mirror what is set in the
  % DSP Constant
  switch action
   case 'init'
    % Normally, we need to make sure that fields are turned on before
    % accessing them, else we will get the last applied settings
    % instead of the last chosen ones - but, that's good enough, here
    % (because we're not in the 'dynamic' case)

    onoff = {'off','on'};
    % First thing to check - is this an old (pre-R13) block?
    % If so, we need to translate the old information to the new
    % format
    oldBlock = (~strcmp(obj.Ts,              '-inf') || ...
                ~strcmp(obj.FramebasedOutput,'-inf') || ...
                ~strcmp(obj.InterpretAs1D,   '-inf'));
    if oldBlock
      % If oldblock && isempty(userdata), then either
      %     (a) this block was just loaded, or
      %     (b) it's actually a new block that someone is trying to access
      %         like an old block
      % No real way to tell the difference, but it shouldn't matter - treat
      % them the same: update 'new' params and initialize the user data

      ud = obj.userdata;
      if iscell(ud),
          % liblinks modifies the user data. To be compatible with liblinks
          % consider the following special case
          udBlk = ud{2};
      else
          udBlk = ud;
      end    
      oldTs  = obj.Ts;
      oldFbo = lower(obj.FramebasedOutput);
      old1D  = lower(obj.InterpretAs1D);
      if isempty(udBlk)
        % check for lingering -inf's and update params as necessary
        if strcmp(old1D,'-inf') 
          if (isContinuous && strcmp(obj.continuousOutput,SAMPLE_1D_POPUP))...
           || (~isContinuous && strcmp(obj.discreteOutput,SAMPLE_1D_POPUP))
            dspsafe_set_param(blk,'InterpretAs1D','on');
          else
            dspsafe_set_param(blk,'InterpretAs1D','off');
          end
        else
          if strcmp(old1D,'on')
            popupVal = SAMPLE_1D_POPUP;
          else
            popupVal = SAMPLE_2D_POPUP;
          end
          if isContinuous
            dspsafe_set_param(blk,'continuousOutput',popupVal);
          else
            dspsafe_set_param(blk,'discreteOutput',popupVal);
          end
        end
        if strcmp(oldFbo,'-inf') 
          if isContinuous || ...
                ~strcmp(obj.discreteOutput,FRAME_POPUP)
            dspsafe_set_param(blk,'FramebasedOutput','off');
          else
            dspsafe_set_param(blk,'FramebasedOutput','on');
          end
        else
          if strcmp(oldFbo,'on')
            dspsafe_set_param(blk,'discreteOutput',FRAME_POPUP);
          else
            if strcmp(old1D,'on')
              dspsafe_set_param(blk,'discreteOutput',SAMPLE_1D_POPUP);
            else
              dspsafe_set_param(blk,'discreteOutput',SAMPLE_2D_POPUP);
            end
          end
        end
        if strcmp(oldTs,'-inf') 
          if strcmp(oldFbo,'on') || strcmp(obj.discreteOutput,FRAME_POPUP);
            oldTs = obj.framePeriod;
          else
            oldTs = obj.sampTime;
          end
        else
          dspsafe_set_param(blk,'framePeriod',oldTs);
          dspsafe_set_param(blk,'sampTime',oldTs);
        end
      else
        % If ~isempty(userdata), then check to see if there have been any 
        %changes, and react appropriately
        if isContinuous
          Ts = obj.sampTime;
          oneD = onoff{strcmp(obj.continuousOutput, SAMPLE_1D_POPUP)+1};
          fbo  = 'off';
        else
          fbo  = onoff{strcmp(obj.discreteOutput,FRAME_POPUP)+1};
          if strcmp(fbo,'on')
            Ts = obj.framePeriod;
          else
            Ts = obj.sampTime;
          end
          oneD = onoff{strcmp(obj.discreteOutput, ...
                              SAMPLE_1D_POPUP)+1};
        end
        if (~isequal(udBlk.fbo,oldFbo) || ~isequal(udBlk.Ts,oldTs) || ~isequal(udBlk.oneD,old1D))
          % Someone changed this like an old block - update new widgets
          if ~isequal(udBlk.Ts,oldTs)
            dspsafe_set_param(blk,'sampTime',oldTs);
            dspsafe_set_param(blk,'framePeriod',oldTs);
          end
          if strcmp(old1D,'on')
            cPopupVal = SAMPLE_1D_POPUP;
            dPopupVal = SAMPLE_1D_POPUP;
          else
            cPopupVal = SAMPLE_2D_POPUP;
            dPopupVal = SAMPLE_2D_POPUP;
          end
          if strcmp(oldFbo,'on')
            dPopupVal = FRAME_POPUP;
          end
          dspsafe_set_param(blk,'continuousOutput',cPopupVal);
          dspsafe_set_param(blk,'discreteOutput',dPopupVal);
        elseif ~isequal(udBlk.fbo,fbo) || ~isequal(udBlk.Ts,Ts) || ~isequal(udBlk.oneD,oneD)
          % Someone changed this like a new block - update old widgets
          if isContinuous
            dspsafe_set_param(blk,'FramebasedOutput','off');
            dspsafe_set_param(blk,'Ts', obj.sampTime);
            if strcmp(obj.continuousOutput,SAMPLE_1D_POPUP)
              dspsafe_set_param(blk,'InterpretAs1D','on');
            else
              dspsafe_set_param(blk,'InterpretAs1D','off');
            end
          else
            switch get_param(blk,'discreteOutput')
             case SAMPLE_1D_POPUP
              dspsafe_set_param(blk,'FramebasedOutput','off');
              dspsafe_set_param(blk,'InterpretAs1D','on');
              dspsafe_set_param(blk,'Ts',obj.sampTime);
             case SAMPLE_2D_POPUP
              dspsafe_set_param(blk,'FramebasedOutput','off');
              dspsafe_set_param(blk,'InterpretAs1D','off');
              dspsafe_set_param(blk,'Ts',obj.sampTime);
             case FRAME_POPUP
              dspsafe_set_param(blk,'FramebasedOutput','on');
              dspsafe_set_param(blk,'InterpretAs1D','off');
              dspsafe_set_param(blk,'Ts',obj.framePeriod);
            end %switch
          end   %if isContinuous
        end     %old block/new block change
      end       %isempty(udBlk)
      % update userdata cache
      udBlk.fbo = obj.FramebasedOutput;
      udBlk.Ts = obj.Ts;
      udBlk.oneD = obj.InterpretAs1D;
      if iscell(ud),
          ud{2} = udBlk;
      else
          ud = udBlk;
      end  
      dspsafe_set_param(blk,'userdata',ud);
    end         %if oldBlock

    % Now to set the underlying blocks
    frame_blk_str = [fullblk '/Frame Status Conversion'];
    frame_obj = get_param(frame_blk_str,'object'); 
    const_blk_str = [fullblk '/Constant'];
    const_obj = get_param(const_blk_str,'object');
    
    frameStr  = frame_obj.outframe;
	
    if isContinuous
      % Continuous time -> SAMPLE-BASED:
      % CONT_OUT will be visible here
      outMode = obj.continuousOutput;
      % frame-ness
      if ~strcmp(frameStr,'Sample-based')
        frame_obj.outframe = 'Sample-based';
      end
    else
      % DISC_OUT will be visible here
      outMode = obj.discreteOutput;
      if strcmp(outMode,FRAME_POPUP)
        % frame-based
         if ~strcmp(frameStr,'Frame-based')
          frame_obj.outframe = 'Frame-based'; 
        end
      else
        % Sample-based:
        if ~strcmp(frameStr,'Sample-based')
          frame_obj.outframe = 'Sample-based';
        end
      end
    end
    
    % 1-D checkbox
    if strcmp(outMode,SAMPLE_1D_POPUP)
      if ~strcmp(const_obj.VectorParams1D,'on')
        const_obj.VectorParams1D = 'on';
      end
    else
      if ~strcmp(const_obj.VectorParams1D,'off')
        const_obj.VectorParams1D = 'off';
      end
    end
   
    % SL Constant data type
    dType = obj.dataType;
    switch dType
     case 'Fixed-point'
      % set the mode
      const_obj.OutDataTypeMode = 'Specify via dialog';
      % set the data type
      wordLen = obj.wordLen;
      if strcmpi(obj.isSigned,'on')
        outDType = ['sfix(' wordLen ')'];
      else
        outDType = ['ufix(' wordLen ')'];
      end
      const_obj.OutDataType = outDType;
      % set the scaling
      fracBitsMode = obj.fracBitsMode;
      if strcmp(fracBitsMode,'Best precision')
        const_obj.conRadixGroup = 'Best precision: Vector-wise';
      else
        const_obj.conRadixGroup = 'Use specified scaling';
        numBits = obj.numFracBits;
        outScaling = ['2^(-(' numBits '))'];
        const_obj.OutScaling = outScaling;
      end
     case 'User-defined'
      % set the mode
      const_obj.OutDataTypeMode = 'Specify via dialog';
      % set the data type
      udDataType = obj.udDataType;
      const_obj.OutDataType = udDataType;
      % set the scaling, if necessary
      if ~dspDataTypeDeterminesFracBits(obj.udDataType)
        fracBitsMode = obj.fracBitsMode;
        if strcmp(fracBitsMode,'Best precision')
          const_obj.conRadixGroup = 'Best precision: Vector-wise';
        else
          const_obj.conRadixGroup = 'Use specified scaling';
          numBits = obj.numFracBits;
          outScaling = ['2^(-(' numBits '))'];
          const_obj.OutScaling = outScaling;
        end
      end
     otherwise
      % DSP Constant choice maps one-to-one to Simulink Constant choice
      const_obj.OutDataTypeMode = dType;
    end
    
   case 'dynamic'
    if isContinuous
      vis(DISC_OUT) = OFF;
      vis(SAMP_TIME) = OFF;
      vis(FRAME_PERIOD) = OFF;
      vis(CONT_OUT) = ON;
    else
      vis(DISC_OUT) = ON;
      vis(CONT_OUT) = OFF;
      % update visibilities before accessing DISC_OUT
      obj.maskvisibilities = vis;
      lastVis = vis;
      outMode = obj.discreteOutput;
      if strcmp(outMode,FRAME_POPUP)
        vis(SAMP_TIME)    = OFF;
        vis(FRAME_PERIOD) = ON;
      else
        vis(SAMP_TIME)    = ON;
        vis(FRAME_PERIOD) = OFF;
      end              
    end
    
    % Update visibilities before processing fixpt params
    if ~isequal(vis,lastVis)
      obj.maskvisibilities = vis;
      lastVis = vis;
    end
   
    [vis,lastVis] = dspProcessFixptSourceParams(obj,9,1,vis);
    
    if ~isequal(vis,lastVis)
      obj.maskvisibilities = vis;
    end
   
   case 'update'    
  	%%%%% Insert/Remove Zero-Order Hold block %%%%
  	if isContinuous
      remove_zoh_block(blk);
  	else
      insert_zoh_block(blk);       
  	end     

  end   % switch

  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function insert_zoh_block(blk)
% If the block doesn't exist, then insert it

  FRAME_POPUP = 'Frame-based';
  fullblk  = getfullname(blk);
  zoh_blk  = [fullblk '/zoh'];

  if ~exist_block(blk, 'zoh')
    delete_line(fullblk,'Constant/1','Frame Status Conversion/1');
    add_block('built-in/Zero-Order Hold',zoh_blk);
    
    set_param(zoh_blk,'Position',[90 22 120 48]);                        

    add_line(fullblk,'Constant/1','zoh/1');  
    add_line(fullblk,'zoh/1','Frame Status Conversion/1');    
  end

  % DISC_OUT will be visible here
  outMode = get_param(blk,'discreteOutput');
  if strcmp(outMode,FRAME_POPUP)
    dspsafe_set_param(zoh_blk,'SampleTime','framePeriod');
  else
    dspsafe_set_param(zoh_blk,'SampleTime','sampTime');
  end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function remove_zoh_block(blk)
%If the block exists, then remove it

  fullblk   = getfullname(blk);
  zoh_blk  = [fullblk '/zoh'];

  if exist_block(blk, 'zoh')
    delete_line(fullblk,'Constant/1','zoh/1');
    delete_line(fullblk,'zoh/1','Frame Status Conversion/1');

    delete_block(zoh_blk);
    add_line(fullblk,'Constant/1','Frame Status Conversion/1')
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function present = exist_block(sys, name)

  present = ~isempty(find_system(sys,'searchdepth',1,...
                                 'followlinks','on','lookundermasks','on','name',name));


% [EOF] dspblkdspconst.m
