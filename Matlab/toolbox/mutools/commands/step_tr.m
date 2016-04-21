%function out = step_tr(timedata,stepdata,tinc,lastt)
%
%  Creates a stairstep signal function of its INDEPENDENT
%  VARIABLE. The TIMEDATA vector indicates the "times" at
%  which the step changes occur, and the value of the
%  stairstep is given by the vector STEPDATA. The last two
%  variables, TINC and LASTT, correspond to the sample time
%  and length of the step signal.
%
%     TINC  - time increment
%     LASTT - final time
%
%  See also: COS_TR, SIGGEN, and SIN_TR.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function vt = step_tr(timedata,stepdata,tinc,lastt)
 if nargin == 0
   disp('usage: out = step_tr(timedata,stepdata,tinc,lastt)')
   return
 end

 if length(timedata) ~= length(stepdata)
   error('timedata and stepdata should be same length')
   return
 end
 [m,n] = size(timedata);
 if n == 1;
   timedata = timedata.';
 end

 iv = (0:tinc:lastt)';
 u = zeros(length(iv),1);
 num = length(find((0 <= iv) & (iv < timedata(1))));
 pointer = num;

 for i=1:length(stepdata)-1
   num = length(find((timedata(i) <= iv) & (iv < timedata(i+1))));
   u(pointer+1:pointer+num) = stepdata(i)*ones(num,1);
   pointer = pointer + num;
 end
 lu = length(u);
 u(pointer+1:lu) = stepdata(length(stepdata))*ones(lu-pointer,1);

 vt = vpck(u,iv);
%
%