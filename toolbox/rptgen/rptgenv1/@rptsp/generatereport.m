function reportname=generatereport(p)
%GENERATEREPORT generates a report
%   REPORTNAME=GENERATEREPORT(RPTSP)
%    *Initializes pointer data structures
%    *Executes coutline component
%    *Cleans up pointer data structures
%   
%   GENERATEREPORT is called by clicking on the 
%   Setup File Editor button or when using
%   "report" from the command line.
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:20 $

coutlineHandle=children(p);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine which helper objects exist in the
% current report.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
   methList=getzxxmethodslist(coutlineHandle);
catch
   methList={'rptcomponent';'zhgmethods'};
end

%The general component helper and the HG helper are
%always initialized.
numMeth=length(methList);

methObj{numMeth}=[];
oldStored{numMeth}=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% perform data pointer initializations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for i=1:numMeth
   try
      methObj{i}=eval(methList{i});
      oldStored{i}=rgstoredata(methObj{i});
      initialize(methObj{i},coutlineHandle.h);
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% generate report
%%% All the heavy lifting involved in generating
%%% a report takes place in the execute method
%%% of the first component.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

reportname=runcomponent(coutlineHandle,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% perform data pointer cleanups
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=numMeth:-1:1
   if ~isempty(methObj{i})
      try
         cleanup(methObj{i});
         rgstoredata(methObj{i},oldStored{i});
      end
   end
end

