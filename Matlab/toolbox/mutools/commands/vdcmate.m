% function vout = vdcmate(vin,spacing)
%
%   The input VARYING matrix is decimated; i.e the output only
%   contains the input at the points specified by spacing.  If no
%   spacing argument is provided, the default is 10, in honour of
%   the original Roman punishment.
%
%   See also: DECIMATE, GETIV, SEL, VPCK and VUNPCK.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function vout = vdcmate(vin,spacing)

if nargin ~= 1 & nargin ~= 2,
    disp('usage: vout = vdcmate(vin,spacing')
    return
    end

if nargin == 1,
    spacing = 10;
    end

[type,nr,nc,npts] = minfo(vin);
if type == 'syst',
    error('cannot decimate a SYSTEM matrix')
    return
    end

if type == 'cons',
    vout = vin;
    return
else
    [data,ptr,iv] = vunpck(vin);
    ivsel = [0:spacing:npts-1];
    npts = length(ivsel);
    index = ones(nr,1)*(ivsel*nr) + [1:nr]'*ones(1,npts);
    index = reshape(index,npts*nr,1);
    vout = zeros(npts*nr+1,nc+1);
    vout(1:npts*nr,1:nc) = data(index,:);
    vout(nr*npts+1,nc+1) = inf;
    vout(nr*npts+1,nc) = npts;
    vout(1:npts,nc+1) = iv(ivsel+1);
    end

%--------------------------------------------------------------------------

%
%