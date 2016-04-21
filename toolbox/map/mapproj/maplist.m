function [list,defproj] = maplist
%MAPLIST List the map projections available in the Mapping Toolbox.
%   list = MAPLIST returns a structure which defines the map projections
%   available in the Mapping Toolbox.  The list structure is list.Name,
%   list.IdString, list.Classification, list.ClassCode. This list structure
%   is used by the function MAPS and AXESMUI, when processing map
%   projection identifiers during operation of the toolbox functions.
%
%   [list,defproj] = MAPLIST also returns IdString of the 
%   default projection.
%
%   list.Name defines the full name of the projection.  This entry is used
%   in the command line table display and in the Projection Control Box.
%
%   list.IdString defines the name of the m-file which computes the
%   projection.
%
%   list.Classification defines the projection classification which is used
%   in the command line table display.
%
%   list.ClassCode defines the character string which is used to label the
%   classes of projections in the Projection Control Box.
%
%   If map projections are to be added to the toolbox, the list structure
%   must be extended and the appropriate field data entered.  For example,
%   if a new projection was added to the default list, then a new entry in
%   the list structure would be:
%            list.Name(61)           = 'My Projection'
%            list.IdString(61)       = 'newprojection';
%            list.Classification(61) = 'New Projection Type';
%            list.ClassCode(61)      = 'Code';
%
%   See also MAPS, AXESMUI.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2003/12/13 02:55:32 $
%   Written by:  E. Byrns, W. Stumpf

%  The default projection

defproj = 'robinson';

%  Define the projection names, types and full names
i=0;

i=i+1;
list(i).IdString       = 'balthsrt';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Balthasart Cylindrical';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'behrmann';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Behrmann Cylindrical';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'bsam';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Bolshoi Sovietskii Atlas Mira*';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'braun';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Braun Perspective Cylindrical*';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'cassini';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Cassini Cylindrical';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'ccylin';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Central Cylindrical*';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'eqacylin';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Equal Area Cylindrical';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'eqdcylin';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Equidistant Cylindrical';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'giso';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Gall Isographic';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'gortho';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Gall Orthographic';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'gstereo';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Gall Stereographic*';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'lambcyln';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Lambert Cylindrical';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'mercator';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Mercator Cylindrical';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'miller';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Miller Cylindrical*';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'pcarree';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Plate Carree';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'tranmerc';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Transverse Mercator';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'trystan';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Trystan Edwards Cylindrical';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'utm';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Universal Transverse Mercator (UTM)';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'wetch';
list(i).Classification = 'Cylindrical';
list(i).Name           = 'Wetch Cylindrical*';
list(i).ClassCode      = 'Cyln';

i=i+1;
list(i).IdString       = 'apianus';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Apianus II*';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'collig';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Collignon';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'craster';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Craster Parabolic';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'eckert1';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Eckert I*';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'eckert2';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Eckert II';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'eckert3';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Eckert III*';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'eckert4';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Eckert IV';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'eckert5';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Eckert V*';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'eckert6';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Eckert VI';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'flatplrp';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Flat-Polar Parabolic';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'flatplrq';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Flat-Polar Quartic';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'flatplrs';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Flat-Polar Sinusoidal';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'fournier';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Fournier';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'goode';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Goode Homolosine';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'hatano';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Hatano Assymmetrical Equal Area';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'kavrsky5';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Kavraisky V';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'kavrsky6';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Kavraisky VI';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'loximuth';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Loximuthal*';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'modsine';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Modified Sinusoidal (Tissot)*';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'mollweid';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Mollweide';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'putnins5';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Putnins P5*';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'quartic';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Quartic Authalic';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'robinson';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Robinson*';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'sinusoid';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Sinusoidal';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'wagner4';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Wagner IV';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'winkel';
list(i).Classification = 'Pseudocylindrical';
list(i).Name           = 'Winkel I*';
list(i).ClassCode      = 'Pcyl';

i=i+1;
list(i).IdString       = 'eqaconic';
list(i).Classification = 'Conic';
list(i).Name           = 'Equal Area Conic (Albers)';
list(i).ClassCode      = 'Coni';

i=i+1;
list(i).IdString       = 'eqdconic';
list(i).Classification = 'Conic';
list(i).Name           = 'Equidistant Conic';
list(i).ClassCode      = 'Coni';

i=i+1;
list(i).IdString       = 'lambert';
list(i).Classification = 'Conic';
list(i).Name           = 'Lambert Conformal Conic';
list(i).ClassCode      = 'Coni';

i=i+1;
list(i).IdString       = 'murdoch1';
list(i).Classification = 'Conic';
list(i).Name           = 'Murdoch I Conic*';
list(i).ClassCode      = 'Coni';

i=i+1;
list(i).IdString       = 'murdoch3';
list(i).Classification = 'Conic';
list(i).Name           = 'Murdoch III Minimum Error Conic*';
list(i).ClassCode      = 'Coni';

i=i+1;
list(i).IdString       = 'polycon';
list(i).Classification = 'PolyConic';
list(i).Name           = 'Polyconic';
list(i).ClassCode      = 'Poly';

i=i+1;
list(i).IdString       = 'vgrint1';
list(i).Classification = 'PolyConic';
list(i).Name           = 'Van Der Grinten I*';
list(i).ClassCode      = 'Poly';

i=i+1;
list(i).IdString       = 'bonne';
list(i).Classification = 'PseudoConic';
list(i).Name           = 'Bonne';
list(i).ClassCode      = 'Pcon';

i=i+1;
list(i).IdString       = 'werner';
list(i).Classification = 'PseudoConic';
list(i).Name           = 'Werner';
list(i).ClassCode      = 'Pcon';

i=i+1;
list(i).IdString       = 'breusing';
list(i).Classification = 'Azimuthal';
list(i).Name           = 'Breusing Harmonic Mean*';
list(i).ClassCode      = 'Azim';

i=i+1;
list(i).IdString       = 'eqaazim';
list(i).Classification = 'Azimuthal';
list(i).Name           = 'Equal Area Azimuthal (Lambert)';
list(i).ClassCode      = 'Azim';

i=i+1;
list(i).IdString       = 'eqdazim';
list(i).Classification = 'Azimuthal';
list(i).Name           = 'Equidistant Azimuthal*';
list(i).ClassCode      = 'Azim';

i=i+1;
list(i).IdString       = 'globe';
list(i).Classification = 'Azimuthal';
list(i).Name           = 'Globe';
list(i).ClassCode      = 'Azim';

i=i+1;
list(i).IdString       = 'gnomonic';
list(i).Classification = 'Azimuthal';
list(i).Name           = 'Gnomonic*';
list(i).ClassCode      = 'Azim';

i=i+1;
list(i).IdString       = 'ortho';
list(i).Classification = 'Azimuthal';
list(i).Name           = 'Orthographic*';
list(i).ClassCode      = 'Azim';

i=i+1;
list(i).IdString       = 'stereo';
list(i).Classification = 'Azimuthal';
list(i).Name           = 'Stereographic';
list(i).ClassCode      = 'Azim';

i=i+1;
list(i).IdString       = 'ups';
list(i).Classification = 'Azimuthal';
list(i).Name           = 'Universal Polar Stereographic';
list(i).ClassCode      = 'Azim';

i=i+1;
list(i).IdString       = 'vperspec';
list(i).Classification = 'Azimuthal';
list(i).Name           = 'Vertical Perspective*';
list(i).ClassCode      = 'Azim';

i=i+1;
list(i).IdString       = 'wiechel';
list(i).Classification = 'Pseudoazimuthal';
list(i).Name           = 'Wiechel Equal Area*';
list(i).ClassCode      = 'Pazi';

i=i+1;
list(i).IdString       = 'aitoff';
list(i).Classification = 'Modified Azimuthal';
list(i).Name           = 'Aitoff*';
list(i).ClassCode      = 'Mazi';

i=i+1;
list(i).IdString       = 'bries';
list(i).Classification = 'Modified Azimuthal';
list(i).Name           = 'Briesemeister*';
list(i).ClassCode      = 'Mazi';

i=i+1;
list(i).IdString       = 'hammer';
list(i).Classification = 'Modified Azimuthal';
list(i).Name           = 'Hammer*';
list(i).ClassCode      = 'Mazi';



%  Note:  The ordering of the displayed list in the Projection Control Box
%  and the command line table can be changed to be alphabetical by name using
% the following lines of code

% [y,i] = sortrows(strvcat(list.Name));
% list = list(i);

