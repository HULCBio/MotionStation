function varargout = dspblkdspgain(action)
% DSPBLKDSPGAIN Signal Processing Blockset DSP Gain block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.3.4.4 $ $Date: 2004/04/12 23:06:21 $
  
  if nargin == 0
    action = 'dynamic';
  end
  
  [ALLOW_OVER,GAIN_MODE,GAIN_WL,GAIN_FL] = deal(3,4,5,6);
  [OUT_MODE,OUT_WL,OUT_FL,R_MODE,O_MODE] = deal(7,8,9,10,11);
  
  blk = gcb;
  prodBlk = [blk '/Product'];
  constPropBlk = [blk '/Input Data Type' char(10) 'Propagation'];
  outPropBlk   = [blk '/Output Data Type' char(10) 'Propagation'];
  
  switch (action)
   case 'icon'
    wsVars = get_param(blk,'maskwsvariables');
    gainVal = wsVars(find(strcmp({wsVars.Name},'gainValue'))).Value;
    if numel(gainVal) == 1
      varargout = {num2str(gainVal)};
    else
      varargout = {'-K-'};
    end
   case 'init'
    attrs = [];
    
    outMode = get_param(blk,'prodOutputMode');
    if strcmp(outMode,'User-defined')
      set_param(outPropBlk,'NumBitsMult','0');
      set_param(outPropBlk,'NumBitsAdd','prodOutputWordLength');
      set_param(outPropBlk,'SlopeMult','0');
      set_param(outPropBlk,'SlopeAdd','2^-(prodOutputFracLength)');
    else
      set_param(outPropBlk,'NumBitsMult','1');
      set_param(outPropBlk,'NumBitsAdd','0');
      set_param(outPropBlk,'SlopeMult','1');
      set_param(outPropBlk,'SlopeAdd','0');
    end
    
    gainMode = get_param(blk,'gainMode');
    if strcmp(gainMode,'User-defined')
      set_param(constPropBlk,'NumBitsMult','0');
      set_param(constPropBlk,'NumBitsAdd','gainWordLength');
      set_param(constPropBlk,'SlopeMult','0');
      set_param(constPropBlk,'SlopeAdd','2^-(gainFracLength)');
    else
      set_param(constPropBlk,'NumBitsMult','1');
      set_param(constPropBlk,'NumBitsAdd','0');
      set_param(constPropBlk,'SlopeMult','1');
    set_param(constPropBlk,'SlopeAdd','0');
    end

    set_param(prodBlk,'RndMeth',get_param(blk,'roundingMode'));
    set_param(prodBlk,'saturateOnIntegerOverflow', ...
                      get_param(blk,'overflowMode'));
   
   case 'dynamic'
    addlParams = get_param(blk,'additionalParams');
    curVis = get_param(blk,'maskvisibilities');
    lastVis = curVis;
    
    curVis(ALLOW_OVER) = {'off'};
    
    if strcmp(addlParams,'on')
      curVis(GAIN_MODE)  = {'on'};
      curVis(OUT_MODE)   = {'on'};
      curVis(R_MODE)     = {'on'};
      curVis(O_MODE)     = {'on'};
      if ~isequal(curVis,lastVis)
        set_param(blk,'maskvisibilities',curVis);
        lastVis = curVis;
      end
      gainMode = get_param(blk,'gainMode');
      if strcmp(gainMode,'User-defined')
        curVis(GAIN_WL) = {'on'};
        curVis(GAIN_FL) = {'on'};
      else
        curVis(GAIN_WL) = {'off'};
        curVis(GAIN_FL) = {'off'};
      end
      outMode = get_param(blk,'prodOutputMode');
      if strcmp(outMode,'User-defined')
        curVis(OUT_WL) = {'on'};
        curVis(OUT_FL) = {'on'};
      else
        curVis(OUT_WL) = {'off'};
        curVis(OUT_FL) = {'off'};
      end
    else
      curVis(ALLOW_OVER:O_MODE) = {'off'};
    end
    if ~isequal(curVis,lastVis)
      set_param(blk,'maskvisibilities',curVis);
    end
  end
