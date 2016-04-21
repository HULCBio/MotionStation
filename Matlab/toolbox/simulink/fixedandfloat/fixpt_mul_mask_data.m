function out = fixpt_mul_mask_data(curBlock,mulstr,doX,MatrixMult);
% FIXPT_MUL_MASK_DATA is a helper function used by the Fixed Point Blocks.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.8 $  
% $Date: 2002/04/10 18:59:05 $

if MatrixMult == 1
  out =0;
else
if length(mulstr) == 1
  if mulstr == '/'
     xx = [0.1 0.7 NaN 0.4 0.4 NaN ...
           0.22 0.58 NaN 0.3 0.3  NaN 0.5 0.5 NaN .28 .32 NaN .48 .52];
     yy = [0.55 0.55 NaN 0.65 0.95 NaN ...'
           0.47 0.47 NaN 0.15 0.47 NaN 0.15 0.47 NaN .15 .15 NaN .15 .15];
  elseif mulstr == '*'
     xx = [0.2 0.8 NaN 0.35 0.35 NaN 0.65 0.65 NaN .32 .38 NaN .62 .68];
     yy = [0.9 0.9 NaN 0.4 0.9 NaN 0.4 0.9 NaN .4 .4 NaN .4 .4];
  elseif mulstr == '+'
     xx = [.7 .7 .3 .5 .3 .7 .7];
     yy = [0.78 0.98 0.98 0.68 0.38 0.38 0.58];
  elseif mulstr == '-'
     xx = [.7 .7 .3 .5 .3 .7 .7 NaN .1 .25];
     yy = [0.78 0.98 0.98 0.68 0.38 0.38 0.58 NaN .68 .68];
  end
elseif length(mulstr) > 1 & mulstr == '*'
  xx = [0.25 0.75 NaN 0.25 0.75 ];
  yy = [0.9 0.4 NaN 0.4 0.9 ];
else
    mulx = [-0.05 0.05 NaN -0.05  0.05 ];
    muly = [-0.05 0.05 NaN  0.05 -0.05 ];
    divx = [-0.05 0.05 ];
    divy = [-0.05 0.05 ];
    addx = [-0.05 0.05 NaN  0     0    ];
    addy = [ 0    0    NaN  0.05 -0.05 ];
    subx = [-0.05 0.05 ];
    suby = [ 0    0    ];

    n = length(mulstr);
    
    block_orient = get_param(curBlock,'Orientation');
    if strcmp(block_orient,'right')
       yadj = -1/n;
       yoff = 1+yadj/2;
       xadj = 0;
       xoff = 0.06;
    elseif strcmp(block_orient,'left')
       yadj = -1/n;
       yoff = 1+yadj/2;
       xadj = 0;
       xoff = 0.94;
    elseif strcmp(block_orient,'up')
       yadj = 0;
       yoff = 0.06;
       xadj = 1/n;
       xoff = xadj/2;
    else
       yadj = 0;
       yoff = 0.94;
       xadj = 1/n;
       xoff = xadj/2;
    end

    for i=1:n
    
        if mulstr(i) == '*'
            x = mulx+xoff;
            y = muly+yoff;
        elseif mulstr(i) == '/'
            x = divx+xoff;
            y = divy+yoff;
        elseif mulstr(i) == '+'
            x = addx+xoff;
            y = addy+yoff;
        else
            x = subx+xoff;
            y = suby+yoff;
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
end        
    
if doX == 1
  out = xx;
else
  out = yy;
end


end