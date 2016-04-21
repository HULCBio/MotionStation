function [msg,A,B,C,D] = abcdchk(A,B,C,D)
%ABCDCHK Checks dimensional consistency of A,B,C,D matrices.
%   ERROR(ABCDCHK(A,B,C,D)) checks that the dimensions of A,B,C,D
%   are consistent for a linear, time-invariant system model.
%   An error occurs if the nonzero dimensions are not consistent.
%
%   [MSG,A,B,C,D] = ABCDCHK(A,B,C,D) also alters the dimensions
%   any 0-by-0 empty matrices to make them consistent with the others.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.22.4.2 $  $Date: 2004/01/24 09:22:39 $

if nargin < 4, D = []; end
if nargin < 3, C = []; end
if nargin < 2, B = []; end
if nargin < 1, A = []; end

[ma,na] = size(A);
[mb,nb] = size(B);
[mc,nc] = size(C);
[md,nd] = size(D);

if mc==0 && nc==0 && (md==0 || na==0)
   mc = md; nc = na; C = zeros(mc,nc);
end
if mb==0 && nb==0 && (ma==0 || nd==0)
   mb = ma; nb = nd; B = zeros(mb,nb);
end
if md==0 && nd==0 && (mc==0 || nb==0)
   md = mc; nd = nb; D = zeros(md,nd);
end
if ma==0 && na==0 && (mb==0 || nc==0)
   ma = mb; na = nc; A = zeros(ma,na);
end

if ma~=na && nargin>=1
    msg = makeMsg('The A matrix must be square', ...
                  'AMustBeSquare');
elseif ma~=mb && nargin>=2
    msg = makeMsg('The A and B matrices must have the same number of rows.', ...
                  'AAndBNumRowsMismatch');
elseif na~=nc && nargin>=3
    msg = makeMsg('The A and C matrices must have the same number of columns.', ...
                  'AAndCNumColumnsMismatch');
elseif md~=mc && nargin>=4
    msg = makeMsg('The C and D matrices must have the same number of rows.', ...
                  'CAndDNumRowsMismatch');
elseif nd~=nb && nargin>=4
    msg = makeMsg('The B and D matrices must have the same number of columns.', ...
                  'BAndDNumColumnsMismatch');
else
    msg.message = '';
    msg.identifier = '';
    msg = msg(zeros(0,1));
end

function msg = makeMsg(message, identifier)
msg.message = message;
msg.identifier = ['MATLAB:abcdchk:' identifier];
