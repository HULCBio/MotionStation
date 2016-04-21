%WK1CONST WK1 record type definitions.
%
%   See also WK1READ, WK1WRITE.

%   Brian M. Bourgault 10/22/93
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.8.4.1 $  $Date: 2004/03/26 13:26:35 $

if 0
LOTTABLE    = [ 24 24 ];
LOTQRANGE   = [ 25 25 ];
LOTPRANGE   = [ 26 8 ];
LOTSRANGE   = [ 27 8 ];
LOTFRANGE   = [ 28 8 ];
LOTKRANGE1  = [ 29 9 ];
LOTDRANGE   = [ 32 0 ];
LOTKRANGE2  = [ 35 9 ];
LOTPROTECT  = [ 36 1 ];
LOTFOOTER   = [ 37 242 ];
LOTHEADER   = [ 38 242 ];
LOTSETUP    = [ 39 40 ];
LOTTITLES   = [ 42 16 ];
LOTGRAPH    = [ 45 437 ];
LOTNGRAPH   = [ 46 455 ];
LOTFORMAT   = [ 48 1 ];
LOTWINDOW   = [ 50 144 ];
LOTSTRING   = [ 51 0 ];
LOTLOCKPASS = [ 55 0 ];
LOTLOCKED   = [ 56 0 ];
LOTQSET     = [ 60 0 ];
LOTCQUERY   = [ 61 0 ];
LOTPSET     = [ 62 0 ];
LOTCPRINT   = [ 63 0 ];
LOTSGRAPH   = [ 64 0 ];
LOTCGRAPH   = [ 65 0 ];
LOTZOOM     = [ 66 0 ];
LOTNSPLIT   = [ 67 0 ];
LOTNSROWS   = [ 68 0 ];
LOTNSCOLS   = [ 69 0 ];
LOTRULER    = [ 70 0 ];
LOTSNRANGE  = [ 71 0 ];
LOTACOMM    = [ 72 0 ];
LOTAMACRO   = [ 73 0 ];
LOTQPARSE   = [ 74 0 ];
LOTWKSPASS  = [ 75 0 ];
LOTHIDCOL2  = [ 101 32 ];
LOTPARSE    = [ 102 16 ];
LOTRRANGES  = [ 103 25 ];
LOTMRANGES  = [ 105 40 ];
else
%
% currently used
%
LOTBEGIN    = [ 0 0 ];
LOTEND      = [ 1 0 ];
LOTCALCMOD  = [ 2 1 ];
LOTCALCORD  = [ 3 1 ];
LOTSPLTWM   = [ 4 1 ];
LOTSPLTWS   = [ 5 1 ];
LOTDIMENSIONS   = [ 6 8 ];
LOTWINDOW1  = [ 7 32 ];
LOTCOLWID1      = [ 8 3 ];
LOTCOLW1        = [ 8 3 ];
LOTCOLW2    = [ 10 3 ];
LOTNMRNG    = [ 11 24 ];
LOTNRANGE   = [ 11 24 ];
LOTBLANK    = [ 12 5 ];
LOTINTEGER  = [ 13 7 ];
LOTNUMBER   = [ 14 13 ];
LOTLABEL    = [ 15 -1 ];
LOTFORMULA  = [ 16 -1 ];
%
LOTMARGINS  = [ 40 10 ];
LOTLABELFMT = [ 41 1 ];
%
LOTCALCCNT  = [ 47 1 ];
%
LOTCURSORW12    = [ 49 1 ];
%
LOTHIDCOL   = [ 100 32 ];
LOTCPI      = [ 150 6 ];
end
%
% constants
%
LOTWK1BOFSTR = [0 0 2 0 6 4];
LOTEOFSTR   = [1 0 0 0];


