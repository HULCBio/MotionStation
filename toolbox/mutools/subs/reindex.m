%function [Or,Oc,Ur,Uc,K,I,J] = reindex(blk)
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

 function [Or,Oc,Ur,Uc,K,I,J] = reindex(blk)

%	Create a set of index vectors for
%	the block structure blk to create
%	the block structure specified by K, I, and J.
%	Or, Oc, Ur, and Uc are index vectors so that
%	MO = M(Oc,Or), and M = MO(Uc,Ur).
%       Authors:  Matthew P. Newlin and Peter M. Young


if length(blk)==0
	K  = []; 	I  = []; 	J  = [];
	Oc = [];	Or = [];	Uc = [];	Ur = [];
	return
end

b = blk;
ab = abs(b);
fb = [b(:,2)==0&b(:,1)<0, b(:,2)==0&b(:,1)>0, b(:,2)>0, 1+(b(:,2)>0)];
%	real/rep		complex/rep	complex/full	complex
Ir1 = []; Ir2 = []; Ir3 = []; Ic1 = []; Ic2 = []; Ic3 = [];

Lfb = fb;

for ii = 1:length(b(:,2))
	oner = ones(ab(ii,      1),1);
	onec = ones(ab(ii,fb(ii,4)),1);
	Ir1 = [Ir1; oner*fb(ii,1)];
	Ir2 = [Ir2; oner*fb(ii,2)];
	Ir3 = [Ir3; oner*fb(ii,3)];
	Ic1 = [Ic1; onec*fb(ii,1)];
	Ic2 = [Ic2; onec*fb(ii,2)];
	Ic3 = [Ic3; onec*fb(ii,3)];
end

if fb(:,1)==0, K = []; else, K = ab(logical(Lfb(:,1)),1); end
if fb(:,2)==0, I = []; else, I =  b(logical(Lfb(:,2)),1); end
if fb(:,3)==0, J = []; else, J =  b(logical(Lfb(:,3)),:)*[1; 0.001]; end

Or = [find(Ir1);find(Ir2);find(Ir3)];
Oc = [find(Ic1);find(Ic2);find(Ic3)];
[ii,Ur] = sort(Or);
[ii,Uc] = sort(Oc);