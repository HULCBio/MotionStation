function [LoDN,HiDN,LoRN,HiRN] = liftfilt(LoD,HiD,LoR,HiR,varargin)
%LIFTFILT Apply elementary lifting steps on filters.
%   [LoDN,HiDN,LoRN,HiRN] = LIFTFILT(LoD,HiD,LoR,HiR,ELS) 
%   returns the four filters LoDN, HiDN, LoRN, HiRN 
%   obtained by an "elementary lifting step" (ELS) starting  
%   from the four filters LoD, HiD, LoR and HiR.
%   The four input filters are supposed to verify the 
%   perfect reconstruction condition. 
%
%   ELS is a structure such that:
%     - TYPE = ELS.type contains the "type" of the elementary   
%       lifting step. The valid values for TYPE are: 
%          'p' (primal) or 'd' (dual).
%     - VALUE = ELS.value contains the Laurent polynomial T   
%       associated to the elementary lifting step (see LP).
%       If VALUE is a vector, the associated Laurent polynomial
%       T is equal to laurpoly(VALUE,0).
%
%   In addition, ELS may be a "scaling step". In that case,
%   TYPE is equal to 's' (scaling) and VALUE is a scalar 
%   different from zero.
%
%   LIFTFILT(...,TYPE,VALUE) gives the same outputs.
%
%   Remark:
%     If TYPE = 'p' , HiD and LoR are unchanged.
%     If TYPE = 'd' , LoD and HiR are unchanged.
%     If TYPE = 's' , the four filters are changed.
%
%   If ELS is an array of elementary lifting steps,
%   LIFTFILT(...,ELS) performs each step successively.
%
%   LIFTFILT(...,flagPLOT) plots the successive "biorthogonal"
%   pairs: ("scaling function" , "wavelet").
%
%   See also LP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 27-May-2003.
%   Last Revision: 04-Sep-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:39:47 $

% Check arguments.
nbIn = nargin;
if nbIn < 4
  error('Not enough input arguments.');
elseif nbIn > 7
  error('Too many input arguments.');
end

[Ha,Ga,Hs,Gs,PRCond,AACond] = filters2lp('b',LoR,LoD);

% Control inputs.
[LoDN,HiDN,LoRN,HiRN] = lp2filters(Ha,Ga,Hs,Gs);
OKLo = isequal(LoD,LoDN) && isequal(LoR,LoRN);
OKHi = (isequal(HiD,HiDN) && isequal(HiR,HiRN)) || ...
       (isequal(HiD,-HiDN) && isequal(HiR,-HiRN));
OKFilters = OKLo && OKHi;
if ~OKFilters
    % error('Invalid input filters');
end

[Ha,Ga,Hs,Gs] = wlift(Ha,Ga,Hs,Gs,varargin{:});
[LoDN,HiDN,LoRN,HiRN] = lp2filters(Ha,Ga,Hs,Gs);
