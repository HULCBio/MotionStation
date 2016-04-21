function [cros_inf,block_n] = blkxchk(layout,blklocs)
%BLKXCHK checks whether a line segment crosses a block.
%   [CORS_INF, BLOCK_N] = BLKXCHK(LAYOUT, BLKLOCS) checks if a line
%   segment in LAYOUT = [x1,y1;x2,y2] has crossed any block listed
%   in BLOCKS. BLOCKS is a nx4 matrix with each row of the matrix
%   representing a location of a block. CROS_INF provides the 
%   cross information:
%     cros_inf = 1 --> or <-- partial invate.
%     cros_inf = 2 >----< or <-------->
%     cros_inf = 3 turn 90 degree of cros_inf = 1
%     cros_inf = 4 turn 90 degree of cros_inf = 2
%     cros_inf = 6 crosed, none of the above listed direction.
%   BLOCK_N provides the crossed block number (row in BLKLOC). When
%   there is no cross, CROS_INF and BLOCK_N are empty. When the line
%   segment across more than one block, both CROS_INF and BLOCK_N
%   are vectors.

%   Wes Wang 10/30/92 at The MathWorks.
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.15 $

cros_inf = []; block_n = [];
k=0; x= zeros(4,1);
a = [min(layout);max(layout)];
if ~isempty(blklocs)
  [tmp1,tmp2]=size(blklocs);
  for i = 1:tmp1
    b=blklocs(i,:);
    x(1)=(a(1,1)<=b(1) & a(2,1)>=b(1)) & ~(a(1,2)>b(4) | a(2,2)<b(2));
    x(2)=(a(1,1)<=b(3) & a(2,1)>=b(3)) & ~(a(1,2)>b(4) | a(2,2)<b(2));
    x(3)=(a(1,2)<=b(2) & a(2,2)>=b(2)) & ~(a(1,1)>b(3) | a(2,1)<b(1));
    x(4)=(a(1,2)<=b(4) & a(2,2)>=b(4)) & ~(a(1,1)>b(3) | a(2,1)<b(1));
    %add a condition of line seg is within the block
    x(5)=(a(1,1)>=b(1) & a(2,1)<=b(3)) & ~(a(1,2)>b(4) | a(2,2)<b(2));
    x(6)=(a(1,2)>=b(2) & a(2,2)<=b(4)) & ~(a(1,1)>b(3) | a(2,1)<b(1));
    if sum(x)
      % there is a corss
      k = k+1;
      block_n(k) = i;
      z=find(x==1);
      if length(z) <=1
        cros_inf(k) = 1;
        if z <=2, cros_inf(k) = 3; end; %cross vertical
      else
        if z(1) >= 3      %cross horizental
          cros_inf(k) = 2;
        elseif z(2) <=2   %cross vertical
          cros_inf(k) = 4;
        else              % in this case layout is not a straight line
          cros_inf(k) = 6;
        end;
      end;
    end;
  end;
end;
