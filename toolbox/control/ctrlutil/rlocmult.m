function kmult = rlocmult(Zero,Pole,Gain,varargin)
%RLOCMULT  Finds gain values for which locus branches cross.
%
%   KMULT = RLOCMULT(Zero,Pole,Gain)
%   
%   KMULT = RLOCMULT(Zero,Pole,Gain,A,B,C) uses the state-space
%   data to compute the crossing points.
%
%   See also ROCUS, SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 06:38:56 $

% Algorithm: Find positive gains that produce multiple roots by solving
% D'(s)*N(s)-D(s)*N'(s)=0 and looking for roots such that D(s)/N(s)<0.
% Note that D'(s)*N(s)-D(s)*N'(s)=0 is equivalent to 
%    dH/ds = c*(sI-A)^(-2)*b = 0   where H(s) = N(s)/D(s)

if nargin>3
    % State-space model supplied: use it to compute candidate crossings
    [a,b,c] = deal(varargin{:});
    na = size(a,1);
    MultRoots = tzero(...
        [a eye(na);zeros(na) a],[zeros(na,1);b],[c zeros(1,na)],0);
else
    % Compute numerator and denominator
    Num = poly(Zero);  % leave gain out (normalization)
    Den = poly(Pole);
    
    % Find roots of D'(s)*N(s)-D(s)*N'(s)=0
    DpN = conv(polyder(Den),Num);
    DNp = conv(Den,polyder(Num));
    gap = length(DpN)-length(DNp);
    MultRoots = roots([zeros(1,-gap),DpN]-[zeros(1,gap),DNp]);
end
    
% Evaluate N(s) and D(s) at MULTROOTS
MultRoots = MultRoots.';
AllNum = prod(MultRoots(ones(1,length(Zero)),:) - Zero(:,ones(1,length(MultRoots))),1);
AllDen = prod(MultRoots(ones(1,length(Pole)),:) - Pole(:,ones(1,length(MultRoots))),1);

% Discard roots for which Den=0 or Num=0 (mult. poles at k=0 or k=Inf)
keep1 = find(min(abs(AllNum),abs(AllDen))>1e3*eps);  

% Keep only real positive gains
kmult = -(AllDen(:,keep1)./AllNum(:,keep1)) / Gain;
keep2 = abs(imag(kmult))<=1e-2*abs(kmult) & real(kmult)>0;
kmult = abs(kmult(:,keep2));
