function [Li,Mi,Ni,n0,n1,Hi,d]=dsprprim(L,M,H)
% DSPRPRIM Relatively prime factors for SUPFRDN*
%
% [Li,Mi,Ni,n0,n1,Hi,d]=dsprprim(L,M,H)
% DSPRPRIM Compute relatively-prime integer ratio Li/Mi
% from given integer ration L/M, warning if L and M
% are not currently relative-prime integers.  This operation
% is required for efficient sample-rate conversion by an
% integer ratio.
%


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $ $Date: 2002/04/14 20:52:55 $

% Get conversion parameters:
blk=gcb;
blknam=blk; 
if ~isempty(blknam)
	blknam(find(blknam==sprintf('\n')))=' ';
end

if isempty(L) | isempty(M)
	d='x[ M * n / L]';
	msg = ['Undefined input in block ''',blknam,'''.'];
	warning(msg);
	return
end

if (L<1) | (M<1),
  msg = ['Conversion factors must be integers ' ...
         'greater than zero in block ''' blknam '''.'];
	warning(msg);
  Li=1; Mi=1; d='x[n]'; return;
end

[g,a,b]=gcd(L,M); Li=L/g; Mi=M/g;
while a>0  % This should happen in at most one step.
  a=a-Mi;  
  b=b+Li;
end
n0=abs(a);  % a must now be negative or zero, as desired
n1=b;       % b must now be positive

if (g > 1),
  msg = sprintf(['Integer conversion factors are \nnot ' ...
                 'relatively prime in block ''%s''.\n' ...
                 'Converting ratio %d/%d to %d/%d.'], ...
                 blknam, L,M,Li,Mi);
	warning(msg);
end

% Formulate icon string:
if (Li==1) & (Mi==1),
  d = 'x[n]';
elseif Li==1,
  d = ['x[' num2str(Mi) 'n]'];
elseif Mi==1,
  d = ['x[n/' num2str(Li) ']'];
else
  d = ['x[' num2str(Mi) 'n/' num2str(Li) ']'];
end

% The filter length, L*M*N, must be a multiple of L*M for the polyphase filter
% coefficients to be distributed properly.  The filter coefficients are zero-filled at 
% the end if necessary.  
Ni=ceil(length(H)/Li/Mi);
if Li*Mi*Ni>length(H)
  H=[H(:);zeros(Li*Mi*Ni-length(H),1)]; 
end

% Create the matrix of coefficients H(i,j,k), where
% i is the i'th element in a filter
% j is the j'th filter in a filter bank (there are L filter banks)
% k is the k'th filter bank (there are M filters in each bank)
% This lines things up in "columns" so it will make indexing easier when
% H(:) is passed to the C program.
H=reshape(H,Li,Mi*Ni);
Hi=zeros(Ni,Mi,Li);
for k=1:Li
  Hi(:,:,k)=reshape(H(k,:),Mi,Ni)';
end
Hi=Hi(:);

return

