%BLKBUILD  Builds a block-diagonal state-space structure from a block 
%       diagram of transfer functions and state models.  This is a 
%       SCRIPT FILE.
%
%  INPUTS:
%    nblocks      is the number of blocks in the diagram.
%
%    ni and di    are the numerator and denominator polynomials for 
%                 the ith block if it is a transfer function.
%
%    ai,bi,ci,di  are the state matrices for the ith block if it is a
%                 state model.
%
%  OUTPUTS:
%    a,b,c,d      is the resulting state space structure. The matrices
%                 are built up by progressive APPENDs of the state 
%                 space representations of each block.
%
%  Note: If both ni,di and ai,bi,ci,di exist for the same block then
%  an error is generated.
%
%  See also  CONNECT.

%   Clay M. Thompson
%   Revised by Wes Wang 8-5-92
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 06:35:07 $

if (exist('a1') == 1) & (exist('b1') == 1) & (exist('c1') == 1)
  if (exist('n1') == 1) & (exist('d1') == 1)
    error('Both state space and transfer function forms for block 1 exist.')
  end
  a=a1; b=b1; c=c1;
  if exist('d1') == 1
    d = d1;
  else
    [ii9,mm9]=size(b1);
    [pp9,ii9]=size(c1);
    d = zeros(pp9,mm9);
  end
elseif exist('n1') == 1
  [a,b,c,d]=tf2ss(n1,d1);
else
  error('Block 1 is not defined.');
end
    
for ibb9=2:nblocks
   xxist = int2str(ibb9);
   if (exist(['a' xxist]) == 1) & (exist(['b' xxist]) == 1) & ...
      (exist(['c' xxist]) == 1)
     % if ai,bi,ci,di exist
     if (exist(['n' xxist]) == 1) & (exist(['d' xxist]) == 1)
       error(sprintf('Both state space and transfer function forms for block %s exist.',xxist));
     end
     smstr = sprintf('a%s,b%s,c%s',xxist,xxist,xxist);
     if exist(['d' xxist]) == 1
       dd9 = eval(['d' xxist]);
     else
       [ii9,mm9]=size(eval(['b' xxist']));
       [pp9,ii9]=size(eval(['c' xxist']));
       dd9 = zeros(pp9,mm9);
     end
     eval([ '[a,b,c,d] = append(a,b,c,d,' smstr ',dd9);']);
   elseif (exist(['n' xxist]) == 1) & (exist(['d' xxist]) == 1)
     ii9 = int2str(ibb9);        % Convert ibb9 to string representation
     [aa9,bb9,cc9,dd9] = eval(['tf2ss(n',ii9,',d',ii9,')']);
     [a,b,c,d] = append(a,b,c,d,aa9,bb9,cc9,dd9);
   else
     error(sprintf('Block %s is not defined.',xxist));
   end
end

[pp9,mm9]=size(d);
disp(sprintf('State model [a,b,c,d] of the block diagram has %d inputs and %d outputs.',mm9,pp9));

clear aa9 bb9 cc9 dd9 ii9 ibb9 xxist smstr pp9 mm9
