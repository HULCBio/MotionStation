function varargout = lwt2(x,LS,varargin)
%LWT2 Lifting wavelet decomposition 2-D.
%   LWT2 performs a 2-D lifting wavelet decomposition
%   with respect to a particular lifted wavelet that you specify.
%
%   [CA,CH,CV,CD] = LWT2(X,W) computes the approximation
%   coefficients matrix CA and detail coefficients matrices
%   CH, CV and CD obtained by a lifting wavelet decomposition, 
%   of the matrix X. W is a lifted wavelet name (see LIFTWAVE).
%
%   X_InPlace = LWT2(X,LS) computes the approximation and
%   detail coefficients. These coefficients are stored in-place:
%       CA = X_InPlace(1:2:end,1:2:end)
%       CH = X_InPlace(2:2:end,1:2:end)
%       CV = X_InPlace(1:2:end,2:2:end)
%       CD = X_InPlace(2:2:end,2:2:end)
%
%   LWT2(X,W,LEVEL) computes the lifting wavelet decomposition
%   at level LEVEL.
%
%   X_InPlace = LWT2(X,W,LEVEL,'typeDEC',typeDEC) or
%   [CA,CH,CV,CD] = LWT2(X,W,LEVEL,'typeDEC',typeDEC) with
%   typeDEC = 'w' or 'wp' compute the wavelet or the
%   wavelet packet decomposition using lifting at level LEVEL.
%
%   Instead of a lifted wavelet name, you may use the associated
%   lifting scheme LS:
%     LWT2(X,LS,...) instead of LWT2(X,W,...).
%
%   For more information about lifting schemes type: lsinfo.
%
%   See also ILWT2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Feb-2000.
%   Last Revision: 10-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:39:58 $

% Check arguments.
nbIn = nargin;
switch nbIn
    case {2,3,5} , 
    case {0,1} , error('Not enough input arguments.');
    case {4}   , error('Invalid number of input arguments.');
    otherwise  , error('Too many input arguments.');
end
nbOut = nargout;
switch nbOut
    case {0,1,4,5} , 
    case {2,3} , error('Invalid number of output arguments.');
    otherwise  , error('Too many output arguments.');
end

% Default: level and typeDEC.
level = 1; typeDEC = 'w';
firstIdxAPP = 1; firstIdxDET = 1+mod(firstIdxAPP,2);
if nargin>2
    level = varargin{1};
    for k = 2:2:length(varargin)-1
      argName = lower( varargin{k});
      switch argName
        case 'typedec' , typeDEC = varargin{k+1};
      end
    end
end
if ischar(LS) , LS = liftwave(LS); end

%===================%
% LIFTING ALGORITHM %
%===================%
% Splitting.
L = x(:,firstIdxAPP:2:end);
H = x(:,firstIdxDET:2:end);
sL = size(L);
sH = size(H);

% Lifting.
NBL = size(LS,1);
LStype = LS{NBL,3};
for k = 1:NBL-1
    liftTYPE = LS{k,1};
    liftFILT = LS{k,2};
    DF       = LS{k,3};
    switch liftTYPE
      case 'p' , L = L + lsupdate('r',H,liftFILT,DF,sL,LStype);
      case 'd' , H = H + lsupdate('r',L,liftFILT,DF,sH,LStype);
    end
end

% Splitting.
a = L(firstIdxAPP:2:end,:); h = L(firstIdxDET:2:end,:); clear L
v = H(firstIdxAPP:2:end,:); d = H(firstIdxDET:2:end,:); clear H
sa = size(a); sh = size(h);
sv = size(v); sd = size(d);

% Lifting.
for k = 1:NBL-1
    liftTYPE = LS{k,1};
    liftFILT = LS{k,2};
    DF       = LS{k,3};
    switch liftTYPE
      case 'p'
        a = a + lsupdate('c',h,liftFILT,DF,sa,LStype);
        v = v + lsupdate('c',d,liftFILT,DF,sv,LStype);

      case 'd'
        h = h + lsupdate('c',a,liftFILT,DF,sh,LStype);
        d = d + lsupdate('c',v,liftFILT,DF,sd,LStype);
    end
end
% Normalization.
if isempty(LStype)
    a = LS{end,1}*LS{end,1}*a;
    h = LS{end,1}*LS{end,2}*h;
    v = LS{end,2}*LS{end,1}*v;
    d = LS{end,2}*LS{end,2}*d;
end
%========================================================================%


% Recursion if level > 1.
if level>1
   level = level-1;
   a = lwt2(a,LS,level,'typeDEC',typeDEC);
   if isequal(typeDEC,'wp')
       h = lwt2(h,LS,level,'typeDEC',typeDEC);
       v = lwt2(v,LS,level,'typeDEC',typeDEC);
       d = lwt2(d,LS,level,'typeDEC',typeDEC);
   end
end

% Store in place.
x(firstIdxAPP:2:end,firstIdxAPP:2:end) = a;
x(firstIdxDET:2:end,firstIdxAPP:2:end) = h;
x(firstIdxAPP:2:end,firstIdxDET:2:end) = v;
x(firstIdxDET:2:end,firstIdxDET:2:end) = d;

switch nargout
  case 1 , varargout = {x};
  case 4 , varargout = {a,h,v,d};
  case 5 , varargout = {x,a,h,v,d};
end
