function varargout = dspblkFPA(action)
  
  if ~strcmp(action,'init')
    section = action;
    action = 'dynamic';
  end
    
  blk = gcb;
  
  [OUT_SRC,ACC_SRC,PO_SRC,MEM_SRC] = deal(1,4,7,10);
  [RND_MODE,OVER_MODE] = deal(14,15);

  switch(action)
   case 'init'
    varargout = dspGetFixptDataTypeInfo(blk,1);
   case 'dynamic'
    switch(section)
     case 'out'
      processParams('output',blk,OUT_SRC);
     case 'acc'
      processParams('accum',blk,ACC_SRC);
     case 'po'
      processParams('prodOutput',blk,PO_SRC);
     case 'mem'
      processParams('memory',blk,MEM_SRC);
     case 'misc'
      vis = get_param(blk,'maskvisibilities');
      lastVis = vis;
      if ~strcmp(get_param(blk,'miscSource'),'Local')
        vis([RND_MODE,OVER_MODE]) = {'off'};
      else
        vis([RND_MODE,OVER_MODE]) = {'on'};
      end
      if ~isequal(vis,lastVis)
        set_param(blk,'maskvisibilities',vis);
      end
    end
    
    varargout = {};
  end
  
  
%------------------------------------------------

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:05:54 $
function processParams(prefix,blk,index)
  
  sourceStr = [prefix 'Source'];
  wlStr     = [prefix 'WordLength'];
  flStr     = [prefix 'FracLength'];
  
  vis = get_param(blk,'maskvisibilities');
  lastVis = vis;
  vis(index+1) = {'on'};
  set_param(blk,'maskvisibilities',vis);
  lastVis = vis;
  if ~strcmp(get_param(blk,sourceStr),'Local')
    vis(index+1) = {'off'};
    vis(index+2) = {'off'};
  else
    vis(index+1) = {'on'};
    vis(index+2) = {'on'};
  end
  if ~isequal(vis,lastVis)
    set_param(blk,'maskvisibilities',vis);
  end
      
  