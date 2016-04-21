function [N,ny,nu,ne]=sizedat(dat,dim)
% SIZEDAT  Size of IDDATA and IDFRD data sets
%
% [N,NY,NU,NE] = SIZEDAT(DAT)
%     Returns the number of data (N), the number of outputs (NY),
%     the number of inputs (NU), and the number of exeriments (NE).
%     For multiple expriments, N is a row vector, containing the number
%     of data in each experiment.
%
%     Nn = SIZE(DAT) returns Nn = [N,Ny,Nu] for single experiments and
%          Nn = [sum(N),Ny,Nu,Ne] for multiple experiments.

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/12/02 16:42:59 $

if isa(dat,'iddata')
    [N,ny,nu,ne] = size(dat);
elseif isa(dat,'idfrd')
    [ny,nu,N] = size(dat);
    ne = 1;
else
    error('Sizedat only applies to IDDATA and IDFRD objects.')
end
if nargout==1
    N = sum(N);
end