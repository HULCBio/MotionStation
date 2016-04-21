% called by LMIEDIT

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.8.2.3 $

function terms=parslsys(hdl,lminame,varlist)

str=char(get(hdl(14),'str'));  % symbolic LMI description

% main loop

lmi=[]; terms=[]; nlmi=0;
lminame=strrep(lminame,' ','');
header='lmiterm(';


for t=str',   % scan lines one at a time
  lmi=[lmi dblnk(t') ' '];
  [aux,rhs]=strtok(lmi,['<';'>']);

  % if complete lmi isolated...
  if length(dblnk(rhs))>1 & ...
     length(findstr(rhs,'['))==length(findstr(rhs,']')),

     nlmi=nlmi+1;

     % get lhs and rhs
     lmi=strrep(lmi,'=','');
     ind=find(lmi=='>' | lmi=='<');
     if lmi(ind)=='<',
        lhs=lmi(1:ind-1);
        rhs=lmi(ind+1:length(lmi));
     else
        rhs=lmi(1:ind-1);
        lhs=lmi(ind+1:length(lmi));
     end

     % get list of terms in lhs and rhs
     terms=strstack(terms,parslmi(hdl,dblnk(lhs),nlmi,varlist,header));
     terms=strstack(terms,parslmi(hdl,dblnk(rhs),-nlmi,varlist,header));
     terms=strstack(terms,' ');

     lmi=[];
  end
end

terms=strstack(terms,[lminame '=getlmis;']);

if strcmp(get(hdl(22),'str'),'Coding in progress...'),
  set(hdl(21:24),'vis','off');
end
