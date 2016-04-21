function [indn,errflag,flagmea,flagall,flagnoise,flagboth] = ...
   indmatch(ind,names,nn,nameflag,lam)
%INDMATCH  
% Help function to SUBSREF and SUBNDECO to decode input indices.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2001/08/03 14:23:45 $

errflag =[];
indn = [];
flagnoise = 0;
flagmea = 0;
flagall = 0;
flagboth = 0;
%% case 1
if isa(ind,'double')
   indn = ind;
   if isempty(indn)
      if strcmp(lower(nameflag),'input')
         flagnoise = 1;
      else
         errflag = ['No matching ',nameflag,' channels found.']
      end
   end
   if any(indn>nn)|(~isempty(indn)&any(indn<1))
      errflag = [nameflag,' channel index outside model''s range.'];
      
   end
   return
end
if strcmp(ind,':'), 
   indn=1:nn;
   return
end
if ischar(ind)
   ind = {ind};
end
indtemp =[];
for kk = 1:length(ind)
   tf = strmatch(ind{kk},names,'exact');
   indtemp =[indtemp,tf];
end
if ~isempty(indtemp)
   indn = indtemp;
   return 
end
if strcmp(lower(nameflag),'input') % test for 'measured', 'noise' and 'allx9'
   ind = ind{1};
   nt = idchnona(ind);
   if strcmp(nt,'noise')
       indn=[];
       flagnoise = 1;
   elseif strcmp(nt,'measured')
       indn=1:nn;
       flagmea = 1;
   elseif strcmp(ind,'allx9')|strcmp(ind,'all') % all allowed for compatibility
       indn=1:nn;
       if norm(lam)>0,flagall = 1;end
   elseif strcmp(ind,'bothx9')
       indn=1:nn;
       if norm(lam)>0,flagboth = 1;end
   end
end

%    if ~isempty(nt),ind = nt;end
%    try
%       if strcmp(lower(ind(),'n')
%          indn = [];
%          flagnoise = 1;
%       end
%    catch
%    end
%    flagmea = 0;
%    try
%       if strcmp(lower(ind(1)),'m'),
%          indn=1:nn;
%          flagmea=1;
%       end
%    catch
%    end
%    flagall=0;
%    try
%       if strcmp(lower(ind(1)),'a'),
%          indn=1:nn;,
%          if norm(lam)>0,flagall=1;end
%       end
%    catch
%    end
%    try
%       if strcmp(lower(ind(1)),'b'),
%          indn=1:nn;,
%          if norm(lam)>0,flagboth=1;end
%       end
%    catch
%    end
% 
% end
if isempty(indn)&(~flagnoise)
   errflag = ['No matching ',nameflag,' channels found.'];
end
