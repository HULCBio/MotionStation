function Ds = wpthcoef(Ds,Ts,keepapp,sorh,thr)
%WPTHCOEF Wavelet packet coefficients thresholding.
%   NDATA = WPTHCOEF(DATA,TREE,KEEPAPP,SORH,THR) 
%   returns new data structure obtained from the wavelet
%   packet decomposition structure [DATA,TREE] (see MAKETREE) 
%   by coefficients thresholding.
%
%   If KEEPAPP = 1, approximation coefficients are not
%   thresholded, otherwise it is possible.
%   If SORH = 's', soft thresholding is applied,
%   if SORH = 'h', hard thresholding is applied
%   (see WTHRESH).
%   THR is the threshold value.
%
%   See also MAKETREE, WPDEC, WPDEC2, WPDENCMP, WTHRESH.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 04-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $

% Check arguments.
if errargn(mfilename,nargin,[5],nargout,[0:1]), error('*'), end

[tnods,ltor] = tnodes(Ts);   % Keep terminal nodes.
tnods = tnods(ltor);         % Sort terminal nodes
                             % from left to right.
                             % Approximation index is 1.
if keepapp==1
    % Save approximation.
    app_coefs = wdatamgr('read_cfs',Ds,Ts,tnods(1));
end

coefs = wdatamgr('rallcfs',Ds);
coefs = wthresh(coefs,sorh,thr);
Ds = wdatamgr('replace',Ds,coefs);

if keepapp==1
    % Restore approximation.
    Ds = wdatamgr('write_cfs',Ds,Ts,tnods(1),app_coefs);
end
