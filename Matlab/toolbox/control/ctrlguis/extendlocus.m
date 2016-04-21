function [NewGain,RefRoot] = extendlocus(Gains,Roots,CurrentGM)
%EXTENDLOCUS  Extends asymptotes if current gain (red square)
%             is nearing asymptote end point.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 04:43:10 $

NewGain = [];
RefRoot = [];

ng = length(Gains);
iinf = find(any(isinf(Roots),1));  % roots at inf

if ~isempty(iinf)
   m = sum(isinf(Roots(:,iinf)));  % number of asymptotes
   factor2 = 2^m;   % must multiply max gain by 2^m to double asymptote length   
   switch iinf
   case 1
      % Asymptote at K=0
      if CurrentGM<2*Gains(2)
         NewGain = CurrentGM/factor2;
         RefRoot = Roots(:,2);
      end
   case ng
      % Asymptote at K=Inf
      if CurrentGM>Gains(ng-1)/2
         NewGain = factor2*CurrentGM;
         RefRoot = Roots(:,ng-1);
      end
   otherwise
      % Finite escape
      if CurrentGM>Gains(iinf-1) & CurrentGM<Gains(iinf+1) & CurrentGM~=Gains(iinf)
         NewGain = Gains(iinf) + (CurrentGM-Gains(iinf)) / factor2;
         RefRoot = Roots(:,iinf+1-2*(CurrentGM<Gains(iinf)));
      end
   end
end

