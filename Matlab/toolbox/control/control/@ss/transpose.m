function tsys = transpose(sys)
%TRANSPOSE  Transpose operation for state-space models.
%
%   TSYS = TRANSPOSE(SYS) is invoked by TSYS = SYS.'
%
%   Given the state-space model SYS with data (A,B,C,D), 
%   TSYS = SYS.' returns the state-space model with data 
%   (A.',C.',B.',D.').  In terms of the transfer function 
%   H of SYS, the transfer function of resulting model 
%   TSYS is H(s).' (or H(z).' for discrete-time systems).
%
%   See also CTRANSPOSE, SS, LTIMODELS.

%   Author(s): A. Potvin, 3-1-94, P. Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/10 06:00:06 $

sizes = size(sys.d);
tsys = sys;
tsys.d = permute(sys.d,[2 1 3:length(sizes)]);
for k=1:prod(sizes(3:end)),
   tsys.a{k} = sys.a{k}.';
   tsys.e{k} = sys.e{k}.';
   tsys.b{k} = sys.c{k}.';
   tsys.c{k} = sys.b{k}.';
end

% Delete state names
tsys.StateName(:) = {''};

% LTI property management
tsys.lti = (sys.lti).';
