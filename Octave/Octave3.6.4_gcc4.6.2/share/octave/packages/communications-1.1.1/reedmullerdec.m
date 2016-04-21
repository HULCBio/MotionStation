## Copyright (C) 2007, 2011 Muthiah Annamalai <muthiah.annamalai@uta.edu>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {}  reedmullerdec (@var{VV},@var{G},@var{R},@var{M})
##
## Decode the received code word @var{VV} using  the RM-generator matrix @var{G},
## of order @var{R}, @var{M}, returning the code-word C. We use the standard
## majority logic vote method due to Irving S. Reed. The received word has to be
## a matrix of column size equal to to code-word size (i.e @math{2^m}). Each row
## is treated as a separate received word.
##
## The second return value is the message @var{M} got from @var{C}.
##
## G is obtained from definition type construction of Reed Muller code,
## of order @var{R}, length @math{2^M}. Use the function reedmullergen,
## for the generator matrix for the (@var{R},@var{M}) order RM code.
## 
## Faster code constructions (also easier) exist, but since 
## finding permutation order of the basis vectors, is important, we 
## stick with the standard definitions. To use decoder
## function reedmullerdec,  you need to use this specific
## generator function.
##
## see: Lin & Costello, Ch.4, "Error Control Coding", 2nd Ed, Pearson.
##
## @example
## @group
## G=reedmullergen(2,4);
## M=[rand(1,11)>0.5];
## C=mod(M*G,2);
## [dec_C,dec_M]=reedmullerdec(C,G,2,4)
##
## @end group
## @end example
##
## @end deftypefn
## @seealso{reedmullergen,reedmullerenc}

## FIXME: make possible to use different generators, if permutation
## matrix (i.e polynomial vector elements of rows of G are given
function [C,CMM]=reedmullerdec(VV,G,R,M)
    if ( nargin < 4 )
       print_usage();
    end
    
   %
   % we do a R+1 level majority logic decoding.
   % at each order of polynomial modifying the code-word.
   %
   U=0:M-1; %allowed basis vectors in V2^M.
   C=-1*ones(size(VV)); %preset the output word.
   [Rows,Cols]=size(G);%rows shadows 'rows()'

   %
   %first get the row index of G & its corresponding permutation
   %elements.
   %   
   P{1}=[0];
   for idx=1:M
     P{idx+1}=idx;
   end
   idx=idx+1;
   
   Ufull=1:M;
   r=2;
   while r <= R
     TMP=nchoosek(Ufull,r);
     for idy=1:nchoosek(M,r)
       P{idx+idy}=TMP(idy,:);
     end
     idx=idx+idy;
     r=r+1;
   end
   
  %
  %enter majority logic decoding loop, R+1 order polynomial,
  %but we do it here for n-k times, both are equivalent.
  % 
  
  NCODES=size(VV);
  NCODES=NCODES(1);
  v_adjust=[];
  
  for row_v=1:1:NCODES
   V=VV(row_v,:);
   CM=-1*ones(1,Rows);
   
   %
   %Now start at bottom row, and get the index set,
   %for each until the 2nd most row.
   %

   %special case, r=0, parity check, so just sum-up.
   if ( R == 0 )
      wt=__majority_logic_vote(V);
      CMM(row_v,:)=wt;
      C(row_v,:)=mod(wt*G,2);
      continue;
   end
   
   order=R;
   Gadj=G;
   prev_len=length(P{Rows});
   for idx=Rows:-1:1
     %
     %adjust the 'V' received vector, at change of each order.
     %
     if ( prev_len ~= length(P{idx})  || idx == 1 ) %force for_ idx=1
         v_adjust=mod(CM(idx+1:end)*Gadj(idx+1:end,:),2);
         Gadj(idx+1:end,:)=0;
         V=mod(V+ v_adjust,2); % + = - in GF(2).
         order = order - 1;
         if ( order == 0 ) %special handling of the all-1's basis vector.
           CM(idx)=__majority_logic_vote(V);
           break
         end
      end

      prev_len=length(P{idx});
      Si=P{idx};% index identifier
      Si=sort(Si,'descend');

      %generate index elements
      B=__binvec(0:(2.^length(Si)-1));
      WTS=2.^[Si-1];
      %actual index set elements.
      S=sum(B.*repmat(WTS,[2^length(Si),1]),2);
      
      %doing the operation set difference U \ S to get SCi
      SCi=U;
      Si_diff=Si-1;
      rmidx=[];
      for idy=1:M
        if( any( Si_diff==SCi(idy) ) )
          rmidx=[rmidx, idy];
        end
      end
      SCi(rmidx)=[];
      SCi=sort(SCi,'descend');
      
      %corner case RM(r=m,m) case 
      if (length(SCi) > 0 )
        %generate the set SC,
        B=__binvec(0:(2.^length(SCi)-1));
        WTS=2.^[SCi];
        %actual index set elements.
        SC=sum(B.*repmat(WTS,[2^length(SCi),1]),2);
      else
        SC=[0]; %default, has to be empty set mathematically;
      end

      %
      %next compute the checksums & form the weights.
      %
      wts=[]; %clear prev history
      for id_el = 1:length(SC)
        sc_el=SC(id_el);
        elems=sc_el + S;
        elems=elems+1; %adjust indexing
        wt=mod(sum(V(elems)),2);%add elements of V, rx vector.
        wts(id_el)= wt;%this is checksum
      end

      %
      %do the majority logic vote.
      %
      CM(idx)=__majority_logic_vote(wts);
  end  
  
  CMM(row_v,:)=CM;
  C(row_v,:)=mod(CM*G,2);
  end
  return;
end

%
% utility functions
%
function bvec=__binvec(dec_vec)
     maxlen=ceil(log2(max(dec_vec)+1));
     x=[]; bvec=zeros(length(dec_vec),maxlen);
     for idx=maxlen:-1:1
         tmp=mod(dec_vec,2);
         bvec(:,idx)=tmp.';
         dec_vec=(dec_vec-tmp)./2;
     end
     return
end

%
% crude majority logic decoding; force the = case to 0 by default.
%
function wt=__majority_logic_vote(wts)
      wt=sum(wts)-sum(1-wts);%count no of 1's - no of 0's.
      if ( wt ~= 0 )
         wt = (wt > 0);
         %else
         %wt = rand() > 0.5; %break the tie.
	%end
      end
end

%
% majority logic decoding, tie-break using random.
%
function wt=__majority_logic_vote_random(wts)
    wt=(1+sign( sum(wts)-sum(1-wts) ))/2;
    if ( wt == 0.5 ) 
        wt = (rand()>0.5);
    end
end

% test cases
%G=[1 1 1 1,1 1 1 1;
%   0 1 0 1,0 1 0 1; 
%   0 0 1 1,0 0 1 1;
%   0 0 0 0 1 1 1 1];
%m=[1 0 0 1];
%c=mod(m*G,2);
%c(1)=1-c(1); %corrects errors!
%[dc,dm]=reedmullerdec(c,G,1,3)
%pause
%
%G=reedmullergen(1,4);
%m=[1 0 0 0 1];
%c=mod(m*G,2);
%[dc,dm]=reedmullerdec(c,G,1,4)
%pause
%
%G=reedmullergen(3,4);
%m=[ones(1,15)];
%c=mod(m*G,2);
%[dc,dm]=reedmullerdec(c,G,3,4)
%pause
%
%G=reedmullergen(2,3);
%m=[0 0 0 1 1 1 1]
%c=mod(m*G,2)
%[dc,dm]=reedmullerdec(c,G,2,3)
%pause
%
%G=reedmullergen(3,3);
%c1=mod([ones(1,8)]*G,2);
%c2=mod([ones(1,4),zeros(1,4)]*G,2);
%[dC,dM]=reedmullerdec([c2;c2;c1;c2],G,3,3)
%
% %special case of repetition code.
% G=reedmullergen(0,3);
% G
% c1=1*G; 
% c2=0*G; C=[c1; c2]
% [dC,dM]=reedmullerdec(C,G,0,3)
%
