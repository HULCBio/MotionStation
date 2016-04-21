function Ds = entrupd(Ts,Ds,ent,in4)
%ENTRUPD Entropy update (wavelet packet).
%   ND = ENTRUPD(T,D,ENT) or 
%   ND = ENTRUPD(T,D,ENT,PAR) returns for a
%   given wavelet packet decomposition structure
%   [T,D] (see MAKETREE), the updated data structure
%   ND corresponding to entropy function ENT with
%   optional parameter PAR (see WENTROPY).
%
%   [T,ND] is the resulting decomposition structure.
%
%   See also WENTROPY, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 02-Aug-2000.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.12 $

% Check arguments.
if errargn(mfilename,nargin,[3 4],nargout,[0 1]), error('*'), end
if nargin==3 , par = 0; else par = in4; end
if strcmp(lower(ent),'user') & ~ischar(par)
    error('*** Invalid function name for user entropy ***');
end

% Keep tree nodes.
nods      = (allnodes(Ts))';
ent_nods  = zeros(size(nods));
ento_nods = NaN;
ento_nods = ento_nods(ones(size(nods)));

% Update entropy.
for i = 1:length(nods)
    % read or reconstruct packet coefficients.
    if wtreemgr('istnode',Ts,nods(i))
        coefs = wdatamgr('read_cfs',Ds,Ts,nods(i));
    else
        coefs = wpcoef(Ts,Ds,nods(i));
    end
    % compute entropy.
    ent_nods(i) = wentropy(coefs,ent,par);
end

% Update data structure.
Ds = wdatamgr('write_tp_ent',Ds,ent,par);
Ds = wdatamgr('write_ent',Ds,ent_nods,nods);
Ds = wdatamgr('write_ento',Ds,ento_nods,nods);
