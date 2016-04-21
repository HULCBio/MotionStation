function dispdelay(L,k,offset)
%DISPDELAY  Displays time delays

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 05:51:19 $

if ~hasdelay(L),
   return
end

% Input delays
id = L.InputDelay(:,:,min(k,end));
if any(id),
   disp([sprintf('%sInput delays (listed by channel): ',offset) sprintf('%0.3g  ',id')])
end

% Output delays
od = L.OutputDelay(:,:,min(k,end));
if any(od),
   disp([sprintf('%sOutput delays (listed by channel): ',offset) sprintf('%0.3g  ',od')])
end

% I/O delays
iod = L.ioDelay(:,:,min(k,end));
if any(iod(:)),
   if all(iod(:)==iod(1))
      disp(sprintf('%sI/O delay time (for all I/O pairs): %0.5g',offset,iod(1)))
   else
      disp(sprintf('%sI/O delays:',offset));
      siod = evalc('disp(iod)');
      disp(siod(1:end-2))
   end
end

disp(' ')