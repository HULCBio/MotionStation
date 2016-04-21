function a = col2im(b,block,mat,kind)
%COL2IM Rearrange matrix columns into blocks.
%   A = COL2IM(B,[M N],[MM NN],'distinct') rearranges each column
%   of B into a distinct M-by-N block to create the matrix A of
%   size MM-by-NN.  If B = [A11(:) A12(:) A21(:) A22(:)], where
%   each column has length M*N, then A = [A11 A12; A21 A22] where
%   each Aij is M-by-N.
%
%   A = COL2IM(B,[M N],[MM NN],'sliding') rearranges the row
%   vector B into a matrix of size (MM-M+1)-by-(NN-N+1). B must
%   be a vector of size 1-by-(MM-M+1)*(NN-N+1). B is usually the
%   result of processing the output of IM2COL(...,'sliding')
%   using a column compression function (such as SUM).
%
%   COL2IM(B,[M N],[MM NN]) is the same as COL2IM(B,[M N],[MM
%   NN],'sliding').
%
%   Class Support
%   -------------
%   B can be logical or numeric.  A is of the same class as B.
%
%   Example
%   -------
%       B = reshape(uint8(1:25),[5 5])'
%       C = im2col(B,[1 5])
%       A = col2im(C,[1 5],[5 5],'distinct')
%  
%   See also BLKPROC, COLFILT, IM2COL, NLFILTER.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.22.4.2 $  $Date: 2003/08/23 05:52:11 $

%   I/O Spec
%   ========
%   IN
%      B          - any numeric class or logical
%      M,N,MM,NN  - double, integer
%   OUT 
%      A          - same class as B

checknargin(3,4,nargin,mfilename);
checkinput(b,{'numeric' 'logical'},{'nonsparse'},mfilename,'B',1);
checkinput(block,{'double'},{'integer' 'real' 'positive'},mfilename,'[M N]',2);
checkinput(mat,{'double'},{'integer' 'real' 'positive'},mfilename,'[MM NN]',3);

if nargin < 4,          % Try to determine which block type is assumed.
  kind = 'sliding';
end

if ~isstr(kind), 
  error('Images:col2im:wrongBlockType',...
        'The block type parameter must be either ''distinct'' or ''sliding''.');
end

kind = [lower(kind) ' ']; % Protect against short string

if kind(1)=='d', % Distinct
  % Check argument sizes
  [m,n] = size(b);
  if prod(block)~=m, error('Images:col2im:wrongSize','The row size of B must be M*N.'); end
  
  % Find size of padded A.
  mpad = rem(mat(1),block(1)); if mpad>0, mpad = block(1)-mpad; end
  npad = rem(mat(2),block(2)); if npad>0, npad = block(2)-npad; end
  mpad = mat(1)+mpad; npad = mat(2)+npad;
  if mpad*npad/prod(block)~=n, 
    error('Images:col2im:inconsistentSize','The column size of b not consistent with BLK2COL size.');
  end
  
  mblocks = mpad/block(1);
  nblocks = npad/block(2);
  aa = mkconstarray(class(b), 0, [mpad npad]);
  x = mkconstarray(class(b), 0, block);
  rows = 1:block(1); cols = 1:block(2);
  for i=0:mblocks-1,
    for j=0:nblocks-1,
      x(:) = b(:,i+j*mblocks+1); 
      aa(i*block(1)+rows,j*block(2)+cols) = x;
    end
  end
  a = aa(1:mat(1),1:mat(2));
  
elseif kind(1)=='s', % sliding
  a = reshape(b,mat(1)-block(1)+1,mat(2)-block(2)+1);
else
  error('Images:col2im:unknownBlockType',[deblank(kind),' is a unknown block type']);

end

