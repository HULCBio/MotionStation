function x = ilwt(varargin)
%ILWT Inverse 1-D lifting wavelet transform.
%   ILWT performs a 1-D wavelet reconstruction using lifting
%   with respect to a particular lifted wavelet that you specify.
%
%   X = ILWT(AD_In_Place,W) computes the reconstructed vector X
%   using the approximation and detail coefficients vector 
%   AD_In_Place obtained by a lifting wavelet decomposition.
%   W is a lifted wavelet name (see LIFTWAVE).
%
%   X = ILWT(CA,CD,W) computes the reconstructed vector X
%   using the approximation coefficients vector CA and detail
%   coefficients vector CD obtained by a lifting wavelet 
%   decomposition.
%
%   X = ILWT(AD_In_Place,W,LEVEL) or X = ILWT(CA,CD,W,LEVEL)
%   compute the lifting wavelet reconstruction, at level LEVEL.
%
%   X = ILWT(AD_In_Place,W,LEVEL,'typeDEC',typeDEC) or
%   X = ILWT(CA,CD,W,LEVEL,'typeDEC',typeDEC) with
%   typeDEC = 'w' or 'wp' compute the wavelet or the
%   wavelet packet decomposition using lifting, at level LEVEL.
%
%   Instead of a lifted wavelet name, you may use the associated
%   lifting scheme LS:
%     X = ILWT(...,LS,...) instead of X = ILWT(...,W,...).
%
%   For more information about lifting schemes type: lsinfo.
%
%   See also LWT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Feb-2000.
%   Last Revision: 10-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:39:42 $

% Check arguments.
nbIn = nargin;
if nbIn < 2
  error('Not enough input arguments.');
elseif nbIn > 6
  error('Too many input arguments.');
end

% Default: level and typeDEC.
level = 1; typeDEC = 'w';
firstIdxAPP = 1; firstIdxDET = 1+mod(firstIdxAPP,2);

% Check arguments.
x_in_place = iscell(varargin{2}) || ischar(varargin{2});
if x_in_place
    [x,LS] = deal(varargin{1:2});
    nextArg = 3;
else
    [a,d,LS] = deal(varargin{1:3});
    x = zeros(1,length(a)+length(d));
    x(firstIdxAPP:2:end) = a;
    x(firstIdxDET:2:end) = d;
    if (size(a,1)>1) || (size(d,1)>1) , x = x'; end
    clear a d
    nextArg = 4;
end
if nargin>=nextArg
    level = varargin{nextArg};
    for k = nextArg+1:2:length(varargin)-1
      argName = lower( varargin{k});
      switch argName
        case 'typedec' , typeDEC = varargin{k+1};
      end
    end
end
if ischar(LS) , LS = liftwave(LS); end

% Splitting.
lx = length(x);
idxAPP = firstIdxAPP:2:lx;
idxDET = firstIdxDET:2:lx;
lenAPP = length(idxAPP);
lenDET = length(idxDET);

% Recursion if level > 1.
if level>1
   x(idxAPP) = ilwt(x(idxAPP),LS,level-1,'typeDEC',typeDEC);
   if isequal(typeDEC,'wp')
       x(idxDET) = ilwt(x(idxDET),LS,level-1,'typeDEC',typeDEC);
   end
end


%===================%
% LIFTING ALGORITHM %
%===================%
NBL = size(LS,1);
LStype = LS{NBL,3};

% Normalization.
if isempty(LStype)
    x(idxAPP) = x(idxAPP)/LS{NBL,1};
    x(idxDET) = x(idxDET)/LS{NBL,2};
end

% Reverse Lifting.
for k = NBL-1:-1:1
    liftTYPE = LS{k,1};
    liftFILT = -LS{k,2};
    DF       = LS{k,3};
    switch liftTYPE
       case 'p'
           x(idxAPP) = x(idxAPP) + ...
               lsupdate('v',x(idxDET),liftFILT,DF,lenAPP,LStype);
       case 'd'
           x(idxDET) = x(idxDET) + ...
               lsupdate('v',x(idxAPP),liftFILT,DF,lenDET,LStype);
    end
end
%=========================================================================%
