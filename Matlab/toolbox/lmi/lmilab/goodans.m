%  CALLED BY LMIINFO
%
%  answ = goodans(lim_inf,lim_sup,text,nr_ans)
%
%  Waits for input from the keyboard and checks if the answer
%  is in the interval [lim_inf,lim_sup]
%
%  Input:
%    LIM_INF, LIM_SUP     lower and upper bounds for data
%    TEXT                 text string printed before
%    NR_ANS               number of introduced data (1 or 2)
%
%  Output:
%    ANSW     variable containing a value between LIM_INF and LIM_SUP

% Author: A. Ignat  1/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function answ = goodans(lim_inf,lim_sup,text,nr_ans)

if lim_inf == -inf
  disp(sprintf(' data cannot take the value -inf\n')) ; return ;
end
if lim_inf > lim_sup
  disp(sprintf('error in function good_ans: lim_inf > lim_sup\n')); return;
end

if nr_ans == 1;
  answ = lim_inf - 1 ;
  while answ < lim_inf | answ > lim_sup

    writevar = [text,num2str(lim_inf),' and ', ...
                num2str(lim_sup),') ? '];
    answ = input(writevar) ;
    if isempty(answ)  answ = lim_inf-1;
    elseif answ < lim_inf | answ > lim_sup
       disp(sprintf('\n      data out of range'));
    end
  end
else
  writevar = [text,' (',num2str(lim_inf),' <= i,j <= ', ...
              num2str(lim_sup),') : '];
  disp(writevar);
  for i=1:2
     answh = lim_inf - 1 ;
     while answh < lim_inf | answh > lim_sup
       if i == 1 answh = input(' i = ') ;
       else answh = input(' j = ') ;
       end
       if isempty(answh) answh = lim_inf-1;
       elseif answh < lim_inf | answh > lim_sup
          disp(sprintf('\n      data out of range'));
        end
     end
     answ(i) = answh;
  end



end;

disp(' ');



