function h = outlier(name, dataset, rd, dl, dh, rr, rl, rh, dle, dhe, rle, rhe, exclude, len)

% $Revision: 1.6.2.1 $  $Date: 2004/02/01 21:38:48 $
% Copyright 1999-2004 The MathWorks, Inc.

h = cftool.outlier;

if nargin==0
   h.dataset='';
   h.exclude=[];
   h.restrictDomain=logical(0);
   h.domainLow='';
   h.domainHigh='';
   h.restrictRange=logical(0);
   h.rangeLow='';
   h.rangeHigh='';
   h.domainLowLessEqual=0;
   h.domainHighLessEqual=0;
   h.rangeLowLessEqual=0;
   h.rangeHighLessEqual=0;
   h.length=0;
   h.name = '';
else
   h.dataset=dataset;
   
   if (len == 0)
      h.exclude=[];
   else
      h.exclude=exclude;
   end
   
   if (rd == 0)
      h.restrictDomain=logical(0);
      h.domainLow='';
      h.domainHigh='';
   else
      h.restrictDomain=logical(1);
      h.domainLow=dl;
      h.domainHigh=dh;
   end
   if (rr == 0)
      h.restrictRange=logical(0);
      h.rangeLow='';
      h.rangeHigh='';
   else
      h.restrictRange=logical(1);
      h.rangeLow=rl;
      h.rangeHigh=rh;
   end
   h.domainLowLessEqual=dle;
   h.domainHighLessEqual=dhe;
   h.rangeLowLessEqual=rle;
   h.rangeHighLessEqual=rhe;
   h.length=len;
   
   % assumes name is unique
   h.name = name;
end

% add it to the list of outliers
connect(h,getoutlierdb,'up');



