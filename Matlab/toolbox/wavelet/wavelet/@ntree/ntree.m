function [t,nbtn] = ntree(varargin)
%NTREE Constructor for the class NTREE.
%   T = NTREE(ORD,D) returns an NTREE object, which is
%   a complete tree of order ORD and depth D.
%
%   T = NTREE is equivalent to T = NTREE(2,0).
%   T = NTREE(ORD) is equivalent to T = NTREE(ORD,0).
%
%   With T = NTREE(ORD,D,S) you may set a "split scheme" 
%   for nodes.
%   The Split scheme S is an ORD by 1 logical array.
%   The root of the tree may be split and it has ORD children.
%   You may split the j-th child if S(j) = 1.
%   Each node that you may split has the same property as
%   the root node.
%
%   With T = NTREE(ORD,D,S,U) you may set a userdata field.
%
%   Another usage is:
%   T = NTREE('order',ORD,'depth',D,'spsch',S,'ud',U).
%   For "missing" inputs the defaults are:
%        ORD = 2, D = 0, S = ones([1:ORD]), U = [] 
%
%   [T,NB] = NTREE(...) returns also the number of
%   terminal nodes (leaves) of T.
%
%   The function NTREE returns a NTREE object.
%   For more information on object fields, type: help ntree/get.  
%
%   See also WTBO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-96.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/03/15 22:38:30 $

%===============================================
% Class NTREE (Parent objects: WTBO)
% Fields:
%   wtbo  - Parent object
%   order - Tree order
%   depth - Tree depth
%   spsch - Split scheme for nodes
%   tn    - Column Vector with terminal nodes indices
%===============================================

% Check arguments.
nbIn = nargin;
if nbIn > 8
  error('Too many input arguments.');
end

% Defaults;
order = 2;
depth = 0;
ud    = [];
spsch = true(order,1);

% Check.
argNam = {'order','depth','spsch','ud'};
argFlg = zeros(length(argNam),1);
k = 1;
while k<=nbIn
   j = min(find(argFlg==0));
   if isempty(j) , break; end  
   if ischar(varargin{k}) && (j<5)
       j = find(strcmp(argNam,varargin{k}));
       if isempty(j)
           if (argFlg(1:3)==[1 1 1]') && (k==nbIn)
               j = 4; k = k-1;
           else
               msg = sprintf('Invalid argument name: %s', varargin{k});
               error(msg);
           end
       end
       k = k+1;
   end
   argFlg(j) = 1;
   field = argNam{j};
   eval([field ' = varargin{' sprintf('%0.f',k) '};'])    
   k = k+1;    
end

if errargt(mfilename,order,'in0') | errargt(mfilename,depth,'in0')
    error('Invalid values for order or depth.');
elseif (order==0 && depth>0)
    error('Invalid values for order or depth.');
end
if  order>0 , spDEF = true(order,1); else , spDEF = false; end
try 
  spsch = logical(spsch);
  spsch = spsch(:);
  if ~isequal(length(spsch),order) , spsch = spDEF; end 
catch
  spsch = spDEF;
end

% Built object.
t = struct('order',order,'depth',depth,'spsch',spsch,'tn',0);
[t.tn,nbtn] = getTN(order,depth,spsch);
t = class(t,'ntree',wtbo(ud));
t = set(t,'wtboInfo',class(t));

%----------------------------------------------------------------------
function [tn,nbtn] = getTN(order,depth,spsch)

nbtn  = order^depth;
switch order
  case 0    , tn = 0;
  case 1    , tn = depth;
  otherwise , tn = [(nbtn-1)/(order-1):(order*nbtn-order)/(order-1)]';
end
if (order<2) | (depth<2) , return; end

asc = zeros(nbtn,depth);
asc(:,1) = tn;
for j = 1:depth-1
    asc(:,j+1) = floor((asc(:,j)-1)/order);
end
tab   = spsch(asc-order*floor((asc-1)/order));
icol  = ones(nbtn,1);
for ic=depth:-1:2
    ir = find(icol<ic);
    j  = find(tab(ir,ic)==0);
    K  = ir(j);
    icol(K) = ic;
    tn(K)   = asc(K,ic);
end
tn = tn([1;1+find(diff(tn))]);
nbtn = length(tn);
%----------------------------------------------------------------------