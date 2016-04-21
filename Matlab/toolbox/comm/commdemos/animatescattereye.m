function varargout = animatescattereye(rcv_a, N, pausetime, ...
                                       numShifts, action, separation)
% ANIMATESCATTEREYE - Does animation of moving offsets for
%                     scattereyedemo
%
%   ANIMATESCATTEREYE(X, N, PAUSETIME, NUMSHIFTS, ACTION, SEPARATION)
%   synchronously animates eye diagram and scatter plots to support the
%   SCATTEREYEDEMO demonstration in comm/commdemos.  This file brings up an eye
%   diagram in the upper right corner of the screen and a scatter plot in the
%   lower left corner of the screen.  Then, it plots the data in X into the
%   figures.  The required arguments are as follows:
%
%   X is a real or complex modulated, filtered signal with or without noise.
%
%   N is the decimation factor for scatter plot and the period for the eye
%   diagram.  It is usually set to the oversampling factor (number of samples
%   per symbol).  It can be set to a small multiple of the oversampling factor
%
%   PAUSETIME is the time to pause between animation steps.
%
%   NUMSHIFTS is the number of animation steps to execute.
%
%   ACTION determines the type of animation.  The choices are
%
%       'lin' - linear animation increments the offset starting at zero and
%       plots the eye and scatter plot until NUMSHIFTS animation steps is
%       reached.  This allow the eye diagram to shift to the right.
%
%       'lr' - shift right then left increments and decrements the offset in the
%       range of -4 to 4 to show dithering of timing for sampling the signal X.
%
%   SEPARATION - determines the separation of the dots on the scatter plot.
%   These dots are in addition to the usual plot for the scatter plot, which
%   include a cyan line type scatter plot and a blue asterisk plot of the moving
%   symbol sampling time.
%
%   SEPARATION > 0 - scatterplot plots a black dot at the sampling point, plots
%   a red dot at the sampling point + SEPARATION and plots a red dot at the
%   sampling point - SEPARATION.
%
%   SEPARATION == 0 - scatterplot plots a black dot at the sampling point only.
%
%   SEPARATION < 0 - no additional dots.
%
%   See also SCATTERPLOT, EYEDIAGRAM, SCATTEREYEDEMO.

%   Author(s): Michael Clune
%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2002/03/27 00:17:12 $

error(nargchk(6,6,nargin));
error(nargoutchk(0,2,nargout));

set(0,'ShowHiddenHandles','on');
ss = get(0,'ScreenSize');
set(0,'ShowHiddenHandles','off');
h = [];
h1 = [];
shifts = mod([0 1 2 3 4 3 2 1 0 -1 -2 -3 -4 -3 -2 -1 0]+N,N);
lenshifts = length(shifts);
for idx = [0:numShifts]
    switch(action)
    case 'lr'
        i = shifts(rem(idx,lenshifts)+1);
    case 'lin'
        i = rem(idx,N);
    otherwise
        error('bad value for ACTION');
    end

    ilate = rem(i-separation+N,N);
    iearly = rem(i+separation+N,N);

    h = scatterplot(rcv_a, ...
              1, ...
              0, ...
              'c-', ...
              h);
    fp = get(h,'position');
    set(h,'position',[ss(3)*.01 ss(4)*.01 fp(3) fp(4)])
    hold on;
    if(separation >= 0)
        h = scatterplot(rcv_a, ...
                  N, ...
                  0, ...
                  'k.', ...
                  h);
    end
    h = scatterplot(rcv_a, ...
              N, ...
              i, ...
              'b*', ...
              h);
    if((ilate > 0)&(separation > 0))
        h = scatterplot(rcv_a, ...
                  N, ...
                  ilate, ...
                  'm.', ...
                  h);
    end
    if((iearly > 0)&(separation > 0))
        h = scatterplot(rcv_a, ...
                  N, ...
                  iearly, ...
                  'r.', ...
                  h);
    end
    hold off;
    h1 = eyediagram(rcv_a, ...
              N, ...
              1, ...
              i, ...
              'b-', ...
              h1);
    set(h1,'position',[ss(3)*.99-fp(3) ss(4)*.8-fp(4) fp(3) fp(4)]);
    pause(.01)
end
if(nargout >= 1)
    varargout(1) = {h};
end

if(nargout >= 2)
    varargout(2) = {h1};
end


