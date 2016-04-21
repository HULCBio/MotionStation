function r = genrloc(a,b,c,d,Gains,z,p,SortFlag)
%GENRLOC Generates points along root locus
%
%   R = GENRLOC(A,B,C,D,G,ZEROS,POLES) computes the poles R of the 
%   negative feedback loop
%   
%        ---->o-->| (A,B,C,D) |--+--->
%             |                  |
%             +<------| G |------+
%
%   for the values of the gain G specified in the vector G.  
%   The vector ZEROS and POLES contain the open-loop zeros and poles.
%   The output matrix R is N-by-length(K) where N is the number 
%   of closed-loop poles.
%
%   R = GENRLOC(A,B,C,D,G,ZEROS,POLES,'sort') further sorts the 
%   roots into separate locus branches (rows of R).
%
%   See also ROCUS.

%   Author(s): A. Potvin, 12-1-93, 
%              P. Gahinet 97-99
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15.4.1 $  $Date: 2002/11/11 22:21:56 $

% RE: Expects [D C;B A] is Hessenberg form (avoids chaotic behavior
%     of roots as G->Inf when deg(Num)<<deg(Den)).

% Pre-allocate space for R
ng = length(Gains);
n = size(a,1);
r = zeros(n,ng);

% Distinguish d=0 and d~=0
if d,
   % Nonzero feedthrough. 
   % Closed-loop roots are the eigenvalues of A-G/(1+d*G)*B*C
   for i=1:(n>0)*ng,
      g = Gains(i);
      switch g
         case 0
            clr = p;
         case Inf
            clr = z;
         case -1/d
            % If g->-1/d, roots tend to zeros of (A,B,C,0)
            clr = sisozero([0 c;b a],[],100*eps);
         otherwise
            g = g/(1+g*d);
            clr = eig(a-(g*b)*c);
      end
      nclr = length(clr);
      r(1:nclr,i) = clr;
      r(nclr+1:n,i) = Inf;
   end
   
else
   % Zero feedthrough 
   for i=1:(n>0)*ng,
      g = Gains(i);
      switch g
      case 0
         clr = p;
      case Inf
         clr = z;
      otherwise
         clr = eig(a-(g*b)*c);
      end
      nclr = length(clr);
      r(1:nclr,i) = clr;
      r(nclr+1:n,i) = Inf;
   end
   
end

% Sort roots if requested
if ng>1 & nargin>7,
   for i=2:ng, 
      r(:,i) = matchlsq(r(:,i-1),r(:,i)); 
   end
end
