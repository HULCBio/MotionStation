% Mapping Toolbox Projections.
%
% Map Projection Properties.
%   defaultm    - Initialize or reset projection properties to default values.
%   geotiff2mstruct - Convert GeoTIFF info to a map projection structure.
%
% Available Map Projections (in addition to PROJ.4 library). 
%   maps        - List available map projections and verify names.
%   maplist     - List the map projections available in the Mapping Toolbox.
%
% Map Projection Transformations.
%   mfwdtran    - Process forward transformation.
%   minvtran    - Process inverse transformation.
%   projfwd     - Forward map projection using the PROJ.4 library.
%   projinv     - Inverse map projection using the PROJ.4 library.
%
% Angles, Scales and Distortions.
%   vfwdtran    - Transform azimuth to direction angle on map plane.
%   vinvtran    - Transform direction angle from map plane to azimuth.
%   distortcalc - Calculate distortion parameters for a map projection.
%
% Cylindrical Projections.
%   balthsrt    - Balthasart Projection.
%   behrmann    - Behrmann Projection.
%   bsam        - Bolshoi Sovietskii Atlas Mira Projection.
%   braun       - Braun Perspective Projection.
%   cassini     - Cassini Projection.
%   ccylin      - Central Cylindrical Projection.
%   eqacylin    - Equal Area Projection.
%   eqdcylin    - Equidistant Projection.
%   giso        - Gall Isographic Projection.
%   gortho      - Gall Orthographic Projection.
%   gstereo     - Gall Stereographic Projection.
%   lambcyln    - Lambert Projection.
%   mercator    - Mercator Projection.
%   miller      - Miller Projection.
%   pcarree     - Plate Carree Projection.
%   tranmerc    - Transverse Mercator Projection.
%   trystan     - Trystan Edwards Projection.
%   wetch       - Wetch Projection.
%
% Pseudocylindrical Projections.
%   apianus     - Apianus II Projection.
%   collig      - Collignon Projection.
%   craster     - Craster Parabolic Projection.
%   eckert1     - Eckert I Projection.
%   eckert2     - Eckert II  Projection.
%   eckert3     - Eckert III Projection.
%   eckert4     - Eckert IV Projection.
%   eckert5     - Eckert V Projection.
%   eckert6     - Eckert VI Projection.
%   flatplrp    - Flat-Polar Parabolic Projection.
%   flatplrq    - Flat-Polar Quartic Projection.
%   flatplrs    - Flat-Polar Sinusoidal Projection.
%   fournier    - Fournier Projection.
%   goode       - Goode Homolosine Projection.
%   hatano      - Hatano Assymmetrical Equal Area Projection.
%   kavrsky5    - Kavraisky V Projection.
%   kavrsky6    - Kavraisky VI Projection.
%   loximuth    - Loximuthal Projection.
%   modsine     - Modified Sinusoidal Projection.
%   mollweid    - Mollweide Projection.
%   putnins5    - Putnins P5 Projection.
%   quartic     - Quartic Authalic Projection.
%   robinson    - Robinson Projection.
%   sinusoid    - Sinusoidal Projection.
%   wagner4     - Wagner IV Projection.
%   winkel      - Winkel I Projection.
%
% Conic Projections.
%   eqaconic    - Albers Equal Area Conic Projection.
%   eqdconic    - Equidistant Conic Projection.
%   lambert     - Lambert Conformal Conic Projection.
%   murdoch1    - Murdoch I Conic Projection.
%   murdoch3    - Murdoch III Minimum Error Conic Projection.
%
% Polyconic and Pseudoconic Projections.
%   bonne       - Bonne Projection.
%   polycon     - Polyconic Projection.
%   vgrint1     - Van Der Grinten I Projection.
%   werner      - Werner Projection.
%
% Azimuthal, Pseudoazimuthal and Modified Azimuthal Projections.
%   aitoff      - Aitoff Projection
%   breusing    - Breusing Harmonic Mean Projection.
%   bries       - Briesemeister's Projection
%   eqaazim     - Lambert Equal Area Azimuthal Projection.
%   eqdazim     - Equidistant Azimuthal Projection.
%   gnomonic    - Gnomonic Azimuthal Projection.
%   hammer      - Hammer Projection
%   ortho       - Orthographic Azimuthal Projection.
%   stereo      - Stereographic Azimuthal Projection.
%   vperspec    - Vertical Perspective Azimuthal Projection
%   wiechel     - Weichel Equal Area Projection.
%
% UTM and UPS Systems.
%   ups         - Universal Polar Stereographic (UPS) Projection
%   utm         - Universal Transverse Mercator (UTM) Projection.
%   utmgeoid    - Select ellipsoid for a given UTM zone.
%   utmzone     - Select a UTM zone.
%
% Three Dimensional Globe Display.
%   globe       - Render Earth as a sphere in 3-D graphics.
%
% See also MAP, MAPDEMOS, MAPDISP, MAPFORMATS.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.12.4.2 $ $Date: 2003/12/13 02:55:27 $
