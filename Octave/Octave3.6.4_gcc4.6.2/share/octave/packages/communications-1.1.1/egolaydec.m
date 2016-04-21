## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
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
## @deftypefn {Function File} {}  egolaydec (@var{R})
## 
## Given @var{R}, the received Extended Golay code, this function tries to
## decode @var{R} using the Extended Golay code parity check matrix.
## Extended Golay code (24,12) which can correct upto 3 errors.
##
## The received code @var{R}, needs to be of length Nx24, for encoding. We can
## decode several codes at once, if they are stacked as a matrix of 24columns,
## each code in a separate row.
##
## The generator G used in here is same as obtained from the
## function egolaygen. 
##
## The function returns the error-corrected code word from the received
## word. If decoding failed, the second return value is 1, otherwise it is 0.
## 
## Extended Golay code (24,12) which can correct upto 3
## errors. Decoding algorithm follows from Lin & Costello.
## 
## Ref: Lin & Costello, pg 128, Ch4, 'Error Control Coding', 2nd ed, Pearson.
##
## @example
## @group
##  M=[rand(10,12)>0.5]; 
##  C1=egolayenc(M); 
##  C1(:,1)=mod(C1(:,1)+1,2)
##  C2=egolaydec(C1)
## @end group
## @end example
##
## @end deftypefn
## @seealso{egolaygen,egolayenc}

function [C,dec_error]=egolaydec(R)

  if ( nargin < 1 )
    error('usage: C=egolaydec(R)');
  elseif ( columns(R) ~= 24 )
    error('extended golay code is (24,12), use rx codeword of 24 bit column size');
  end

  I=eye(12);
                                %P is 12x12 matrix
  P=[1 0 0 0 1 1 1 0 1 1 0 1;
     0 0 0 1 1 1 0 1 1 0 1 1;
     0 0 1 1 1 0 1 1 0 1 0 1;
     0 1 1 1 0 1 1 0 1 0 0 1;
     1 1 1 0 1 1 0 1 0 0 0 1;
     1 1 0 1 1 0 1 0 0 0 1 1;
     1 0 1 1 0 1 0 0 0 1 1 1;
     0 1 1 0 1 0 0 0 1 1 1 1;
     1 1 0 1 0 0 0 1 1 1 0 1;
     1 0 1 0 0 0 1 1 1 0 1 1;
     0 1 0 0 0 1 1 1 0 1 1 1;
     1 1 1 1 1 1 1 1 1 1 1 0;];

  H=[I; P]; %partiy check matrix transpose.

  dec_error=[];
  C=zeros(size(R));

  for rspn=1:rows(R)
    RR=R(rspn,:);
    S=mod(RR*H,2);
    wt=sum(S);
    done=0;
    if (wt <= 3)
      E=[S, zeros(1,12)];
      done=1;
    else
      SP = mod(repmat(S,[12, 1])+P,2);
      idx = find( sum(SP,2) <= 2 );    
      if ( idx )
        idx=idx(1); %pick first of matches.
        Ui=zeros(1,12); Ui(idx)=1;
        E=[SP(idx,:),Ui];
        done=1;
      end
    end

    if ( ~done )
      X=mod(S*P,2);
      wt=sum(X);
      if (wt==2 || wt==3)
        E=[zeros(1,12), X];
        done=1;
      else
        SP = mod(repmat(X,[12, 1])+P,2);
        idx = find( sum(SP,2) == 2 );
        if ( idx )
          idx=idx(1);
          Ui=zeros(1,12); Ui(idx)=1;
          E=[Ui,SP(idx,:)];
          done=1;
        end
      end
    end

    dec_error=[dec_error; 1-done];
    C(rspn,:)=mod(E+RR,2);
  end

  return;
end
                                %!
                                %!assert(egolaydec([1 1 1 zeros(1,21)]),zeros(1,24))
                                %!assert(egolaydec([1 0 1 zeros(1,20) 1]),zeros(1,24))
                                %!


