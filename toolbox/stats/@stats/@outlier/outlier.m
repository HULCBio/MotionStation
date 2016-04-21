function h = outlier(name, dataset, yl, yh, yle, yhe)

% $Revision: 1.1.8.3 $  $Date: 2004/01/24 09:34:59 $
% Copyright 2003-2004 The MathWorks, Inc.

h = stats.outlier;

if nargin==0
   h.YLow='';
   h.YHigh='';
   h.YLowLessEqual=0;
   h.YHighGreaterEqual=0;
   h.name = '';
   h.dataset = '';
else
   h.YLow=yl;
   h.YHigh=yh;
   h.YLowLessEqual=yle;
   h.YHighGreaterEqual=yhe;
   h.dataset=dataset;
   
   % assumes name is unique
   h.name = name;
end

% add it to the list of outliers
connect(h,dfswitchyard('getoutlierdb'),'up');


