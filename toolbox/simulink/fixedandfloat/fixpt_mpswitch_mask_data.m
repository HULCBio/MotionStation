function out = fixpt_mpswitch_mask_data(curBlock,NumInputPorts,doX);
% FIXPT_MUL_MASK_DATA is a helper function used by the Fixed Point Blocks.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.6 $  
% $Date: 2002/04/10 18:59:02 $

  n=NumInputPorts+1;
  
  block_orient = get_param(curBlock,'Orientation');
  
  
  if strcmp(block_orient,'right')
    yadj = -1/n;
    yoff = 1+yadj/2;
    xadj = 0;
    xoff = 0.06;
    addx = [-0.08 0.18 NaN 0.18 0.18 NaN 0.18 0.20 NaN 0.18 0.20 NaN 0.20 0.20];
    addy=[0 0 NaN -0.03 0.03 NaN -0.03 -0.03 NaN 0.03 0.03 NaN 0.03 -0.03];
    
    
  elseif strcmp(block_orient,'left')
    yadj = -1/n;
    yoff = 1+yadj/2;
    xadj = 0;
    xoff = 0.94;
    addx = [-0.18 -0.18 NaN  -0.18  0.18 NaN -0.18 -0.20 NaN -0.18 -0.20 ...
	    NaN -0.20 -0.20];
    addy = [ 0.03  -0.03 NaN  0  0 NaN -0.03 -0.03 NaN 0.03 0.03 NaN 0.03 ...
	     -0.03];
  elseif strcmp(block_orient,'up')
    yadj = 0;
    yoff = 0.06;
    xadj = 1/n;
    xoff = xadj/2;
    addx = [0 0 NaN  -0.03  0.03 NaN -0.03 -0.03 NaN 0.03 0.03 NaN -0.03 0.03];
    
    addy = [ -0.08  0.18 NaN  0.18  0.18 NaN 0.18 0.16 NaN 0.18 0.16 NaN 0.16 ...
	     0.16];
  else
    yadj = 0;
    yoff = 0.94;
    xadj = 1/n;
    xoff = xadj/2;
    addx = [0 0 NaN  -0.03  0.03 NaN -0.03 -0.03 NaN 0.03 0.03 NaN -0.03 0.03];
    addy = [ -0.16  0.18 NaN  -0.18  -0.18 NaN -0.18 -0.16 NaN -0.18 -0.16 NaN ...
	     -0.16 -0.16];
  end
  
  
  
  for i=1:n
    
    if i==1
      if strcmp(block_orient,'right')
	addx1 = [-0.08 0.08 NaN    0.08  0.08];
	addy1 = [ 0    0    NaN   -0.03  0.03];
      elseif strcmp(block_orient,'left')
	addx1 = [-0.08 -0.08 NaN  -0.08  0.08];
	addy1 = [ 0.03  -0.03 NaN  0  0];
      elseif strcmp(block_orient,'up')
	addx1 = [0 0 NaN  -0.03  0.03];
	addy1 = [ -0.08  0.08 NaN  0.08  0.08];
      else
	addx1 = [0 0 NaN  -0.03  0.03];
	addy1 = [ -0.08  0.08 NaN  -0.08  -0.08];
      end
      x=addx1+xoff;
      y=addy1+yoff;
    end
    
    if i~=1
      x = addx+xoff;
      y = addy+yoff;
      if i==2
	x2=x;
	y2=y;
	if strcmp(block_orient,'right')
	  xpoint=x2(end);
	  ypoint=y2(1);
	end
	if strcmp(block_orient,'left')
	  xpoint=x2(end);
	  ypoint=y2(5);
	end
	if strcmp(block_orient,'up')
	  xpoint=x2(1);
	  ypoint=y2(end);
	end
	if strcmp(block_orient,'down')
	  xpoint=x2(1);
	  ypoint=y2(1);
	end
	
	
      end
    end
    
    if i==1
      xx = x;
      yy = y;
    else
      xx = [xx NaN x];
      yy = [yy NaN y];
    end
    xoff = xoff + xadj;
    yoff = yoff + yadj;
    
    
  end  
  
  if strcmp(block_orient,'right')
    xx= [xx NaN xpoint 0.75 NaN 0.75 1];
    yy=[yy NaN ypoint 0.5 NaN 0.5 0.5];
  end
  if strcmp(block_orient,'left')
    xx= [xx NaN xpoint 0.25 NaN 0.25 0];
    yy=[yy NaN ypoint 0.5 NaN 0.5 0.5];
  end
  if strcmp(block_orient,'up')
    xx= [xx NaN xpoint 0.5 NaN 0.5 0.5 ];
    yy=[yy NaN ypoint 0.75 NaN 0.75 1];
  end
  if strcmp(block_orient,'down')
    xx= [xx NaN xpoint 0.5 NaN 0.5 0.5 ];
    yy=[yy NaN ypoint 0.25 NaN 0.25 0];
  end
  
  
  if doX
    out = xx;
  else
    out = yy;
  end




