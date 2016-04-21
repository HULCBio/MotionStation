function [thresh,rl2scr,n0scr,imin,suggthr] = wpcmpscr(Ts,IN2,IN3)
%WPCMPSCR Wavelet packets 1-D or 2-D compression scores.
%   [THR,RL2,NZ,IMIN,STHR] = WPCMPSCR(TREE) returns
%   for the input wavelet packets tree TREE compression scores
%   and suggested threshold when approximation is kept:
%   THR the vector of ordered thresholds.
%   and the corresponding vectors of scores induced by
%   a THR(i)-thresholding :
%   RL2 vector of 2-norm recovery score in percent.
%   NZ  vector of relative number of zeros in percent.
%   IMIN is the index of THR for which the two scores are
%   approximately the same.
%   STHR is a suggested threshold.
%
%   When used with two arguments WPCMPSCR(TREE,IN2) 
%   returns the same outputs but all coefficients can be 
%   thresholded.
%
%   See also KEY2INFO, WCMPSCR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $

%--------------%
% NEW VERSION  %
%--------------%
%   Internal uses for compatibility:
%   [THR,RL2,NZ,IMIN,STHR] = WPCMPSCR(TREE,TREE)
%     Approximation is kept.
%
%   [THR,RL2,NZ,IMIN,STHR] = WPCMPSCR(TREE,TREE,IN3)
%     All coefficients can be thresholded.
%
%--------------%
% OLD VERSION  %
%--------------%
%WPCMPSCR 1D or 2D Wavelet packets compression scores.
%   [THR,RL2,NZ,IMIN,STHR] = WPCMPSCR(TREE,DATA) returns
%   for the input wavelet packets decomposition structure 
%   [TREE,DATA], compression scores and suggested
%   threshold when approximation is kept:
%   THR the vector of ordered thresholds.
%   and the corresponding vectors of scores induced by
%   a THR(i)-thresholding :
%   RL2 vector of 2-norm recovery score in percent.
%   NZ  vector of relative number of zeros in percent.
%   IMIN is the index of THR for which the two scores are
%   approximately the same.
%   STHR is a suggested threshold.
%
%   When used with three arguments WPCMPSCR(TREE,DATA,IN3) 
%   returns the same outputs but all coefficients can be 
%   thresholded.
%
%   See also KEY2INFO, WCMPSCR.

% Check arguments and set problem dimension.
if isa(Ts,'wptree')
    keepapp = (nargin == 1) | (nargin == 2 & isa(IN2,'wptree'));
    if keepapp      % approximation is kept.
        tn      = leaves(Ts);
        app     = tn(1);
        sizapp  = read(Ts,'sizes',app);
        dimapp  = prod(sizapp);
    end 
    c = read(Ts,'allcfs');
else
    keepapp = (nargin == 2);
    if keepapp      % approximation is kept.
        [tn,sizes]  = wtreemgr('readall',Ts);
        dimapp = prod(sizes(1,:));
    end 
    % data    = IN2;
    c = wdatamgr('rallcfs',IN2,Ts);
end
order = treeord(Ts);
if order==2 , dim = 1; else , dim = 2;  end

% Set possible thresholds.
if keepapp      % approximation is kept.
    app    = c(1:dimapp);
    c      = c(dimapp+1:length(c));
    nl2app = sum(app.^2);
    n0app  = length(find(app==0));
else            % all coefs can be thresholded.
    dimapp = 0; nl2app = 0; n0app = 0;
end

% Compute compression scores.
thresh	= sort(abs(c));
lenthr	= length(thresh);
if (nl2app<eps & thresh(lenthr)<eps)
    rl2scr  = 100*ones(1,lenthr);
    n0scr   = 100*ones(1,lenthr);
    suggthr = 0;
    indmin  = 1;
    return
end

rl2scr = cumsum(thresh.^2) / (sum(thresh.^2)+nl2app);
n0det  = length(find(c==0));
n0scr  = ((n0app + n0det + ...
               [zeros(1,n0det+1) , 1:(lenthr-n0det)]) / (lenthr+dimapp));
rl2scr = 100 * (1 - rl2scr);
n0scr  = 100 * n0scr;
thresh = [0 thresh];
rl2scr = [100 rl2scr];

% Find threshold for which the two scores are the same.
[dummy,imin] = min(abs(rl2scr-n0scr));

% Set suggested threshold.
suggthr = thresh(imin);
if dim==2, suggthr = sqrt(suggthr); end

