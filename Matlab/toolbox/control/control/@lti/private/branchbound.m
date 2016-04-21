function [intnew,wcnew] = branchbound(x1,x2,y1,y2,eymax,rtol,LogScale)
%BRANCHBOUND  Branch and bound algorithm for crossing detection.
%
%   See also GAINCROSS, PHASECROSS.

%   Author(s): P.Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 05:54:11 $

wcnew = zeros(1,0);
if LogScale
   lnx1 = x1;
   lnx2 = x2;
else
   lnx1 = log(x1);
   lnx2 = log(x2);
end

% Check if exhausting floating point resolution
if lnx2-lnx1<2*eps*(abs(lnx1)+abs(lnx2)),
    if abs(y1)<rtol
        wcnew = x1;
    end
    intnew = zeros(2,0);
    
else  
    % Get slope and x location of crossing with y=0
    if y1==y2
        % Zero slope
        xc = Inf;   
        exmax = Inf;
        if abs(abs(y1)-rtol)>eymax
            xce = [x2,Inf];  % no crossing
        else
            xce = [x1,x2];   % may need splitting
        end
    else
        slope = (y2-y1)/(x2-x1);
        xc = x1-y1/slope;            % crossing of linear interpolant with y=0
        exmax = eymax/abs(slope);    % max error between XC and true crossing
        xce = [max(xc-exmax,x1) , min(xc+exmax,x2)];  % range of possible crossing values
        % Set EXMAX to relative error on XC (only used when y1*y2<0, in which case EXMAX<(X2-X1)/|Xc|)
        % RE: Bounding EXMAX by X2-X1 is essential for fast convergence when YMAX<RTOL
        exmax = min(exmax,x2-x1)/(1+abs(xc));
    end
    ymax = max(abs(y1),abs(y2));
    
    % Branch and bound
    if (xc>=x1) & (xc<=x2) & (exmax+eymax<2*rtol | eymax<10*eps | exmax<10*eps)
        % Terminate: found crossing with adequate accuracy in x and y
        % RE: When YMAX<RTOL, termination occurs when |X2-X1|<RTOL*|XC|. Otherwise [x1,x2]
        %     is split in halves, one of which is discarded below at the next iteration
        wcnew = xc(:,xc<x2); % xc=x2 (y2=0) is xc=x1 (y1=0) for adjacent interval (avoid duplicating crossings)
        intnew = zeros(2,0);
        
    elseif (xce(2)<=x1) | (xce(1)>=x2) | (ymax+eymax<rtol & (y1*y2>0 | ymax<1e3*eps))
        % Discard interval if either max|y|<RTOL (infinite number of potential crossings) or
        % min|y|>0 (no crossing)
        % RE: Discard intervals when max|y|<RTOL and either y1*y2>0 or y1,y2 are both o(eps). Keep
        %     refining otherwise (e.g., to compute gain margin of zpk(-1,[0 -1000],-1000) correctly)
        intnew = zeros(2,0);
        
    else
        % One of the extreme points of XCE (range of possible locations of crossing XC)
        % falls in [X1,X2]. Use XCE as next test interval, and split it in two halves 
        % if its length exceeds half that of [X1,X2] (guarantees shrinks at geometric rate)
        if LogScale
            if xce(2)-xce(1)<=(x2-x1)/2
                intnew = xce(:);
            else
                xc = (xce(1)+xce(2))/2; 
                intnew = [xce(1) xc;xc xce(2)];
            end
        else
            if log(xce(2)/xce(1))<=(lnx2-lnx1)/2
                intnew = xce(:);
            else
                xc = sqrt(xce(1)*xce(2)); 
                intnew = [xce(1) xc;xc xce(2)];
            end
        end
    end
    
    % Return absolute values
    if LogScale
        intnew = exp(intnew);
        wcnew = exp(wcnew);
    end
end