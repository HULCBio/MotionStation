function moved = screenpos( window, requestedPosition )
%SCREENPOS Position Figure using Points units but keep it on screen.
%   SCREENPOS( H, POS ) places Figure H at Position POS in Points units.
%   If any part of POS is off the screen, position is recalculated to
%   keep Figure on screen and return value is TRUE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 17:09:17 $

origRootU = get(0,'units');
set(0,'units','points')
newPosition = LocalRectInRect( requestedPosition, get(0,'screensize') );

oldPos = get(window, 'Position');
units =  get(window, 'units');
resizeFcn =  get(window, 'ResizeFcn');

% compute newPosition in old units
set( window, 'ResizeFcn', '' );
set( window, 'units', 'points' );
set( window, 'position', newPosition );
set( window, 'units', units );
newPosition = get( window, 'position' );
set( window, 'position', oldPos );

% set newPosition in old units with ResizeFcn
set( window, 'ResizeFcn', resizeFcn );
set( window, 'position', newPosition );

set(0,'units',origRootU)

moved = ~isequal( newPosition, requestedPosition );



function rect = LocalRectInRect( rect, in )
%RECTINRECT Returns rect if inside limits, moves around or clips if necessary.
%    Each rectangle is [lower-left-x lower-left-y width height]

%get absolute coordinates
ra = [ rect(1:2) rect(1:2)+rect(3:4) ];
ri = [ in(1:2) in(1:2)+in(3:4) ];

%insideness early exit
if ra(1) >= in(1) &ra(1) >= in(2) & ra(2) >= in(1) ...
    &ra(3) <= in(3) & ra(4) <= in(4)
    return
end

%clip rect if can not fit inside
if rect(3) > in(3)
    rect(3) = in(3);
    ra(3) = rect(1) + rect(3);
end
if rect(4) > in(4)
    rect(4) = in(4);
    ra(4) = rect(2) + rect(4);
end


%Move rect if edge is outside
if rect(1) < in(1)
    right = in(1) - rect(1);
    rect(1) = rect(1) + right;
elseif ra(3) > ri(3)
    left = ra(3) - ri(3);
    rect(1) = rect(1) - left;
end
if rect(2) < in(2)
    up = in(2) - rect(2);
    rect(2) = rect(2) + up;
elseif ra(4) > ri(4)
    down = ra(4) - ri(4);
    rect(2) = rect(2) - down;
end
