function [mag, phase] = subspz(Editor,w,mag,phase,PZold,PZnew)
%SUBSPZ  Updates mag/phase by swapping pole/zero groups.
%
%   [MAG,PHASE] = SUBSPZ(EDITOR,W,MAG,PHASE,PZold,PZnew)
%   returns the updated MAG,PHASE data when swapping the 
%   pole/zero group PZOLD for PZNEW.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 04:56:39 $

% RE: MAG, PHASE is associated to a (normalized) ZPK model and the 
%     update is therefore independent of the format.
Ts = Editor.LoopData.Ts;

% Construct corrective factor
zcorr = [PZold.Pole ; PZnew.Zero];
pcorr = [PZold.Zero ; PZnew.Pole];

% S or Z vectors
s = 1i*w(:).';
if Ts,
   s = exp(Ts * s);
end
ls = length(s);

% Compute correction. Corrective term is prod(s-zj)/prod(s-pj)
sz = s(ones(1,length(zcorr)),:) - zcorr(:,ones(1,ls));
sp = s(ones(1,length(pcorr)),:) - pcorr(:,ones(1,ls));
a = prod(sz,1);
b = prod(sp,1);
Correction = ones(size(a));
nzb = find(b);
Correction(:,nzb) = a(:,nzb)./b(:,nzb);

% Update mag and phase
mag = mag .* abs(Correction(:));
phase = phase + (180/pi) * unwrap(angle(Correction(:)));
