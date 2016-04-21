function [t,nbtn] = dtree(varargin)
%DTREE Constructor for the class DTREE.
%   T = DTREE(ORD,D,X) returns a complete data tree
%   object of order ORD and depth D. The data associated 
%   with the tree T is X.
%
%   With T = DTREE(ORD,D,X,USERDATA) you may set a 
%   userdata field.
%
%   [T,NB] = DTREE(...) returns also the number of
%   terminal nodes (leaves) of T.
%
%   T = DTREE('PropName1',PropValue1,'PropName2',PropValue2,...)
%   is the most general syntax to construct a DTREE object.
%   The valid choices for 'PropName' are:
%     'order' : Order of tree.
%     'depth' : Depth of tree.
%     'data'  : Data associated to the tree.
%     'spsch' : Split scheme for nodes.
%     'ud'    : Userdata field.
%
%   The Split scheme field is an ORD by 1 logical array.
%   The root of the tree may be split and it has ORD children.
%   You may split the j-th child if SPSCH(j) = 1.
%   Each node that you may split has the same property as
%   the root node.
%
%   The function DTREE returns a DTREE object.
%   For more information on object fields, type: help dtree/get.  
%
%   See also NTREE, WTBO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/03/15 22:37:27 $

%===============================================
% Class DTREE (Parent objects: NTREE)
% Fields:
%   ntree - Parent object
%   allNI - All Nodes Information
%   terNI - Terminal Nodes Information
%===============================================

% Check arguments.
nbIn = nargin;
if nbIn > 12
  error('Too many input arguments.');
end

% Defaults;
order = 2;
depth = 0;
ud    = [];
spsch = true(order,1);
spflg = true;
data  = 0;

% Check.
argNam = {'order','depth','data','spflg','spsch','ud'};
argFlg = zeros(length(argNam),1);
k = 1;
while k<=nbIn
   j = min(find(argFlg==0));
   if isempty(j) , break; end
   if ischar(varargin{k}) && (j<7)
       j = find(strcmp(argNam,varargin{k}));
       if isempty(j)
           if isequal(argFlg(1:3),[1 1 1]') && (k==nbIn)
               j = 6; k = k-1;
           else
               msg = sprintf('Invalid argument name: %s', varargin{k});
               error(msg);
           end
       end
       k = k+1;
   elseif isequal(argFlg(1:3),[1 1 1]') && (k==nbIn)
       j = 6;  
   end
   argFlg(j) = 1;
   field = argNam{j};
   eval([field ' = varargin{' sprintf('%0.f',k) '};'])    
   k = k+1;    
end
flagexp = true;
try 
  spflg = logical(spflg);
  flagexp = spflg;
  if length(flagexp)~=1 , flagexp = true; end
catch
  if ischar(spflg)
     if ~strcmp(spflg,'expand') , flagexp = false; end
  end
end
[t,nbtn]  = ntree(order,depth,spsch,ud);
obj.allNI = [];
obj.terNI = [];
t = class(obj,'dtree',t);
t = set(t,'wtboInfo',class(t));
t = fmdtree('setinit',t,data);
if flagexp , t = expand(t); end
