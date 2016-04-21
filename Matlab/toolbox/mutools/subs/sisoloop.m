% function out = sisoloop(P,K,sgnfb,sgnff)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%

%   Form the interconnection structure as shown in the

%    Robust Control Short Course example 2_9. The default

%    is negative feedback (sgnfb = 'neg', sgnff = 'pos').

%

%    Inputs:			Output:

%	    P - plant			out - closed-loop system

%           K - controller

%           sgn - feedback sign

%                ('neg' or 'pos')

%

%   See also: STARP, SYSIC



function out = sisoloop(P,K,sgnfb,sgnff)

 if nargin < 2

   disp('usage: out = formloop(P,K,''sgnfb'',''sgnff'')')

   return

 end



 ff = 1;

 fb = -1;

 if nargin == 3

    if strcmp(sgnfb,'pos')

        fb = 1;

    end

 elseif nargin==4

     if strcmp(sgnfb,'pos')

          fb = 1;

    end

    if strcmp(sgnff,'neg')

          ff = -1;

    end

end



 ic = madd([0 0 1;0 0 0;ff 0 0],mmult([0;1;fb],P,[0 1 1]));

 out = starp(ic,K,1,1);

%

%