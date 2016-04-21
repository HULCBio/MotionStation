%  CALLED BY LMIINFO
%
%  [blck_str,n_ab,n_c] = blckcont(LMI_var,LMI_term,data,nr_lmi,...
%                                 r_l,ind_row,ind_col,n_ab,n_c)
%
%  Writes in a string the symbolic form of a block from an LMI's
%  inner factor
%
%  Input:
%    NR_LMI              the number of the LMI we are intrested in
%    R_L                 indicates the side of the LMI ('r' or 'l')
%    IND_ROW, IND_COL    the row and column indices of the block
%    N_AB, N_C           indices of the coefficients A, B, C
%
%  Output:
%    BLCK_STR     the string containing the symbolic form of the
%                 (IND_ROW,IND_COL) block of the R_L inner factor
%                 of LMI no. NR_LMI
%    N_AB, N_C    the new indices for A, B, C

% Author: A. Ignat  1/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [blck_str,n_ab,n_c] = blckcont(LMI_var,LMI_term,data,...
                                     nr_lmi,r_l,ind_row,ind_col,n_ab,n_c)


change = 0;
if ind_col > ind_row
  change = ind_col ; ind_col = ind_row ; ind_row = change ; change = -1;
end
if r_l == 'r' | r_l == 'R'
  i_lmi = find (LMI_term(1,:) == -nr_lmi & ...
                LMI_term(2,:) == ind_row & LMI_term(3,:) == ind_col);
else
  i_lmi = find (LMI_term(1,:) == nr_lmi & ...
                LMI_term(2,:) == ind_row & LMI_term(3,:) == ind_col);
end

lmiterm = [] ; is_c = 0 ; tconst = [] ;
for j = 1:size(i_lmi,2)
   if LMI_term(4,i_lmi(j)) ~= 0
     lmiterm = [ lmiterm LMI_term(:,i_lmi(j)) ];
   else
     tconst = LMI_term(:,i_lmi(j)) ;
   end
end
blck_str = [' ']  ;


if ~isempty(tconst),   % constant term
  shft=tconst(5);
  rows=data(shft+1); cols=data(shft+2);
  is_c=3;
  if rows==1 & cols==1,   % handle scalar case
    is_c=data(shft+3);
    if abs(is_c)~=1, is_c=2; end
  end
  if is_c == 3,
   blck_str = [blck_str,'C',num2str(n_c),' '] ;
  elseif is_c == 1,
   blck_str = [blck_str,'I '] ;
  elseif is_c == -1,
   blck_str = [blck_str,'-I '] ;
  elseif is_c == 2,
   blck_str = [blck_str,'c',num2str(n_c),'.I '] ;
  end
  if is_c ~= 0, n_c = n_c + 1; end
end


% treat case of variable terms (lmiterm non empty)

if isempty(lmiterm), return, end

for k = 1:size(LMI_var,2)

   klb=LMI_var(1,k);
   i_lmi=find(lmiterm(4,:) == klb | lmiterm(4,:) == -klb);

   if all(LMI_var(5:6,k)==[1;1]),
     tx = ['x',num2str(klb)];
     if length(blck_str)>1, blck_str = [blck_str,'+ ']; end
     for i=1:length(i_lmi)
       tq = ['A',num2str(n_ab)];
       blck_str=[blck_str,tx,'*',tq,' + '];
       n_ab = n_ab+1;
     end
     blck_str = blck_str(1:length(blck_str)-2);

   else
     tx = ['X',num2str(klb)];
     for i = 1:size(i_lmi,2)
        ta = ['A',num2str(n_ab)];
        tb = ['B',num2str(n_ab)];
        newstr = [] ;
        [tca,tcb,tsym] = coeftype(lmiterm(:,i_lmi(i)),data,LMI_var(2,k));
        if length(blck_str) > 1, blck_str = [blck_str,'+ ']; end
        if ind_col == ind_row,
          if tca + tcb == 0,
            if abs(tsym) ~= 1
               if any(LMI_var(2,k) == [1 31]),
                 newstr = [newstr,'a',num2str(n_ab),'*',tx] ;
               elseif LMI_var(2,k) == 2
                 newstr = [newstr,'a',num2str(n_ab),'.(',tx,' + ',tx,''')'];
               end
               n_ab = n_ab + 1;
            elseif tsym == 1
               newstr = [newstr,tx];
               if LMI_var(2,k) == 2, newstr = [newstr,' + ',tx,'''']; end
            elseif tsym == -1
               if length(blck_str) > 1
                  blck_str(size(blck_str,2)-1) = '-';
               else blck_str = [' -']; end
               newstr = [newstr,tx];
               if LMI_var(2,k) == 2, newstr = [newstr,' - ',tx,'''']; end
            end
            blck_str = [ blck_str, newstr];

          elseif tca + tcb == 1
            blck_str = [blck_str,ta,'*',tx] ;
            if LMI_var(2,k) == 2,
               blck_str = [blck_str,' + ',tx,'''*',ta,''''];
            else
               blck_str = [blck_str,' + ',tx,'*',ta,''''];
            end
            n_ab = n_ab + 1;
          elseif tca +tcb == 2
            if any(LMI_var(2,k) == [1 31]) & tsym ~= -Inf,
               if tsym < 0,
                  if length(blck_str) > 1
                     blck_str(size(blck_str,2)-1) = '-';
                  else blck_str = [' -']; end
               end
               if tsym ~= 0
                  blck_str = [blck_str,ta,'*',tx,'*',ta,''''] ;
                  n_ab = n_ab + 1 ;
               end
            else
               blck_str = [blck_str,ta,'*',tx,'*',tb,' + ',tb,'''*',tx];
               if LMI_var(2,k) == 2 blck_str = [blck_str,'''']; end
               blck_str = [ blck_str,'*',ta,''''];
               n_ab = n_ab + 1;
            end
          end

        elseif ~change,

          if lmiterm(4,i_lmi(i)) == -klb, tx = [tx,''''];end
          if tca + tcb == 2
             blck_str = [blck_str,ta,'*',tx,'*',tb];
             n_ab = n_ab + 1;
          elseif tca + tcb == 0
             if abs(tsym) ~= 1
               blck_str = [blck_str,'a',num2str(n_ab),'*',tx] ;
               n_ab = n_ab + 1;
             elseif tsym == 1
               blck_str = [blck_str,tx] ;
             elseif tsym == -1
               if length(blck_str) > 1
                  blck_str(size(blck_str,2)-1) = '-';
               else blck_str = [' -'] ; end
               blck_str = [ blck_str, tx]  ;
             end
          elseif tca == 0
             blck_str = [blck_str,tx,'*',tb] ; n_ab = n_ab + 1;
          else
             blck_str = [blck_str,ta,'*',tx] ; n_ab = n_ab + 1;
          end

        else

          if lmiterm(4,i_lmi(i))==klb & LMI_var(2,k)==2, tx = [tx,''''];end
          if tca + tcb == 2
             blck_str = [blck_str,tb,'''*',tx,'*',ta,''''];
             n_ab = n_ab + 1;
          elseif tca + tcb == 0,
             if abs(tsym) ~= 1,
               blck_str = [blck_str,'a',num2str(n_ab),'*',tx] ;
               n_ab = n_ab + 1;
             elseif tsym == 1,
               blck_str = [blck_str,tx] ;
             elseif tsym == -1,
               if length(blck_str) > 1
                  blck_str(size(blck_str,2)-1) = '-';
               else blck_str = [' -'] ;end
               blck_str = [ blck_str, tx]  ;
             end
          elseif tcb == 0
             blck_str = [blck_str,tx,'*',ta,''''] ; n_ab = n_ab + 1;
          else
             blck_str = [blck_str,tb,'''*',tx] ; n_ab = n_ab + 1;
          end

        end
        blck_str = [ blck_str, ' '] ;
     end
  end
end

if blck_str == [' '],  blck_str = [' 0  ']; end



