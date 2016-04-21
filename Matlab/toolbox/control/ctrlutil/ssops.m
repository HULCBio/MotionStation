function [a,b,c,d,e]=ssops(op,a1,b1,c1,d1,e1,a2,b2,c2,d2,e2)
%SSOPS  Centralized function for basic operations on state-space 
%       models.
%
%   [A,B,C,D,E] =  
%        SSOPS('operation',A1,B1,C1,D1,E1,A2,B2,C2,D2,E2)
%
%   LOW-LEVEL UTILITY.

%	Pascal Gahinet  5-9-97
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.12 $  $Date: 2002/04/10 06:38:50 $

% RE: No dimension checking + assumes empty matrices
%     correctly dimensioned

% Determine array sizes and preallocate A,B,C,E when inputs
% are cell arrays
CellData = isa(a1,'cell');
if CellData,
   sa1 = size(a1);  nsys1 = prod(sa1);
   sa2 = size(a2);  nsys2 = prod(sa2);
   if nsys1>=nsys2,
      ArraySizes = sa1;
   else
      ArraySizes = sa2;
   end  
   a = cell(ArraySizes);
   b = cell(ArraySizes);
   c = cell(ArraySizes);
   e = cell(ArraySizes);
end

% Perform operation
sd1 = size(d1);
sd2 = size(d2);
switch op, 
case 'add'
   % Addition (parallel)
   if CellData,
      d = zeros([sd1(1:2) ArraySizes]);
      for k=1:prod(ArraySizes),
         k1 = min(k,nsys1);
         k2 = min(k,nsys2);
         a{k} = blkdiag(a1{k1},a2{k2});
         b{k} = [b1{k1} ; b2{k2}];
         c{k} = [c1{k1} , c2{k2}];
         d(:,:,k) = d1(:,:,k1) + d2(:,:,k2);
      end
   else
      a = blkdiag(a1,a2);
      b = [b1 ; b2];
      c = [c1 , c2];
      d = d1 + d2;
   end
   
case 'mult'
   % Multiplication (series sys1*sys2)
   %     [ a1  b1*c2 ]       [ b1*d2 ]
   % A = [  0    a2  ]   B = [   b2  ]
   %
   % C = [ c1  d1*c2 ]   D =  d1*d2
   %
   if CellData,
      d = zeros([sd1(1) sd2(2) ArraySizes]);
      for k=1:prod(ArraySizes),
         k1 = min(k,nsys1);
         k2 = min(k,nsys2);
         na1 = size(a1{k1},1);
         na2 = size(a2{k2},1);
         a{k} = [a1{k1} , b1{k1}*c2{k2} ; zeros(na2,na1) , a2{k2}];
         b{k} = [b1{k1}*d2(:,:,k2) ; b2{k2}];
         c{k} = [c1{k1} , d1(:,:,k1)*c2{k2}];
         d(:,:,k) = d1(:,:,k1) * d2(:,:,k2);
      end
   else
      na1 = size(a1,1);
      na2 = size(a2,1);
      a = [a1 , b1*c2 ; zeros(na2,na1) , a2];
      b = [b1*d2 ; b2];
      c = [c1 , d1*c2];
      d = d1 * d2;
   end
   
case 'append'
   % Appending
   if CellData,
      d = zeros([sd1(1:2)+sd2(1:2) ArraySizes]);
      for k=1:prod(ArraySizes),
         k1 = min(k,nsys1);
         k2 = min(k,nsys2);
         a{k} = blkdiag(a1{k1},a2{k2});
         b{k} = blkdiag(b1{k1},b2{k2});
         c{k} = blkdiag(c1{k1},c2{k2});
         d(:,:,k) = blkdiag(d1(:,:,k1),d2(:,:,k2));
      end
   else
      a = blkdiag(a1,a2);
      b = blkdiag(b1,b2);
      c = blkdiag(c1,c2);
      d = blkdiag(d1,d2);
   end
   
case 'vcat'
   % Vertical concatenation
   %     [ a1  0 ]       [ b1 ]
   % A = [  0 a2 ]   B = [ b2 ]
   %
   %     [ c1  0 ]       [ d1 ]
   % C = [  0 c2 ]   D = [ d2 ]
   %
   if CellData,
      d = zeros([sd1(1)+sd2(1) max(sd1(2),sd2(2)) ArraySizes]);
      for k=1:prod(ArraySizes),
         k1 = min(k,nsys1);
         k2 = min(k,nsys2);
         a{k} = blkdiag(a1{k1},a2{k2});
         b{k} = [b1{k1} ; b2{k2}];
         c{k} = blkdiag(c1{k1},c2{k2});
         d(:,:,k) = [d1(:,:,k1) ; d2(:,:,k2)];
      end
   else
      a = blkdiag(a1,a2);
      b = [b1 ; b2];
      c = blkdiag(c1,c2);
      d = [d1 ; d2];
   end
   
case 'hcat'

   % Horizontal concatenation
   %     [ a1  0 ]       [ b1  0 ]
   % A = [  0 a2 ]   B = [  0 b2 ]
   %
   % C = [ c1 c2 ]   D = [ d1 d2]
   %
   if CellData,
      d = zeros([max(sd1(1),sd2(1)) sd1(2)+sd2(2) ArraySizes]);
      for k=1:prod(ArraySizes),
         k1 = min(k,nsys1);
         k2 = min(k,nsys2);
         a{k} = blkdiag(a1{k1},a2{k2});
         b{k} = blkdiag(b1{k1},b2{k2});
         c{k} = [c1{k1} , c2{k2}];
         d(:,:,k) = [d1(:,:,k1) , d2(:,:,k2)];
      end
   else
      a = blkdiag(a1,a2);
      b = blkdiag(b1,b2);
      c = [c1 , c2];
      d = [d1 , d2];
   end

end


% Set E matrix
if CellData,
   EmptyE1 = cellfun('isempty',e1);
   EmptyE2 = cellfun('isempty',e2);
   if ~all(EmptyE1(:)) | ~all(EmptyE2(:)),
      for k=1:prod(ArraySizes),
         k1 = min(k,nsys1);
         k2 = min(k,nsys2);
         e{k} = blkdiag(e1{k1},e2{k2});
      end
   end
else
   e = blkdiag(e1,e2);
end


