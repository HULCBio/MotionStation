function nn=sectionrange(Hq,sec);
%SECTIONRANGE Index to range of sections in filter object.
%   SECTIONRANGE(Hq,I) returns a valid range of sections for filter object
%   Hq.  When I is a scalar, then it returns section I if Hq has enough
%   sections.  When I is a vector, then it returns the range of sections
%   contained in I.  When I is empty, then it returns the range of all
%   sections.  If I contains an integer outside of the number of sections for
%   Hq, then an error is given.
%
%   Example:
%     Hq = qfilt('fir',{{1:5},{1:5},{1:5}});
%     NN = sectionrange(Hq,[1 3]);
%   returns NN = [1 3], and 
%     NN = sectionrange(Hq,4)
%   issues an error.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 15:27:52 $ 
nsecs = numberofsections(Hq);
if isempty(sec)
  nn=1:nsecs;
else
  if isnumeric(sec)
    sec = floor(real(sec(:)))';
  else
    error('Section number must be numeric');
  end
  if max(sec)>nsecs | min(sec)<1
    s = 's';
    if nsecs==1
      s = '';
    end
    error(['Filter has ',num2str(nsecs),' section',s,...
      ' and you have asked for section ',num2str(sec),'.']);
  end
  nn=sec;
end
