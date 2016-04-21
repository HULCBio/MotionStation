function sout = sformat(s,sep,linemax)
% SFORMAT    Splits a long string S into several lines of maximum 
%            length LINEMAX.  The line break occur after the 
%            delimiters defined in SEP

%      Author: P. Gahinet, 5-1-96
%      Copyright 1986-2002 The MathWorks, Inc.
%      $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:18:03 $

sout='';
s = strrep(s,'e+','e');
ls = length(s);

if ls<=linemax+10,  sout = s;  return,  end

while ls>linemax+10,
  if any(s(linemax+1)==sep),
    endline = '';  rmdr = s(linemax+1:ls);
  else
    % Find first occurrence of SEP delimiters
    [endline,rmdr] = strtok(s(linemax+1:ls),sep);
    if any(endline(length(endline))=='^e'), 
       % Handle e-** and ^-** strings
       [end2,rmdr] = strtok(rmdr(2:end),sep);
       endline = [endline , '-' , end2];
    end
  end
  % Add new line to SOUT
  sout = strvcat(sout,[s(1:linemax) , endline]);%,' '); %% This removes the extra line
  s = [blanks(8) , rmdr];
  ls = length(s);
end

if any(s~=' '),
    sout = strvcat(sout,[blanks(linemax+10-ls) s],...
                                    blanks(~isempty(sout))); %% may remove the last line
end

% end sformat
