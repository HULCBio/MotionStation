% Wavelet Toolbox Demonstrations.
%
% Demos.
%   wavedemo    - Wavelet Toolbox demos.
%
% See also WAVELET.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Non-documented functions used in the toolbox. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%------------------
% Slide show driver.
%------------------
%   wshowdrv    - Wavelet Toolbox slide show helper.
%   whelpdem    - Help function for Demos.
%%-------------------------
% Command line mode Demos.
%-------------------------
%   democmdm    - Main command-line mode demos menu.
% 
%   dcmdcasc    - Demo for cascade algorithm.
%   dcmdcomp    - Demo for compression.
%   dcmdcw1d    - Demo for continuous wavelet transform 1-D.
%   dcmddeno    - Demo for de-noising.
%   dcmddw1d    - Demo for discrete wavelet 1-D.
%   dcmddw2d    - Demo for discrete wavelet 2-D.
%   dcmdextm    - Demo for border distortion.
%   dcmdmala    - Demo for Mallat algorithm.
%   dcmdwpck    - Demo for wavelet packets.
%----------------
% GUI mode Demos.
%----------------
%   demoguim    - Main for GUI mode demos menu.
%   demoguimwin - Figure for main for GUI mode demos menu.
%   demoguimwin.fig - Figure for main for GUI mode demos menu.
%   demolift    - Demonstrates Lifting functions in the Wavelet Toolbox.  
%
%   dguicw1d    - Demo for continuous wavelet transform 1-D.
%   dguicwim    - Demo for complex continuous wavelet transform 1-D.
%   dguicf1d    - Demo for Coefficients selection 1-D tool.
%   dguicf2d    - Demo for Coefficients selection 2-D tool.
%   dguide1d    - Demo for Density estimation 1-D tool.
%   dguidw1d    - Demo for discrete wavelet 1-D.
%   dguidw2d    - Demo for discrete wavelet 2-D.
%   dguiiext    - Demo for Image extension.
%   dguinwav    - Demo  for New wavelet tool.
%   dguire1d    - Demo for Regression estimation 1-D tool.
%   dguisext    - Demo for Signal extension.
%   dguisw1d    - Demo for SWT de-noising 1-D.
%   dguisw2d    - Demo for SWT de-noising 2-D.
%   dguiwfbm    - Demo for Fractional Brownian motion generation tool.
%   dguiwfus    - Demo for Image Fusion tool.
%   dguiwp1d    - Demo for wavelet packets 1-D.
%   dguiwp2d    - Demo for wavelet packets 2-D.
%   dguiwpdi    - Demo for wavelet packets display.
%   dguiwvdi    - Demo for wavelets display.
%----------------
% GUI mode Demos.
%----------------
%   demoscen    - Typical wavelet 1-D scenario demo.
%
%   dscedw1d    - Typical wavelet 1-D scenario demo (Auto Play).
%
%-----------------
% Demos utilities.
%------------------
%   demos 	    - Demo list for the Wavelet Toolbox.
%   dmsgfun     - Message function for demos.
%   wenamngr	- Enable settings for GUI demos.
%   wdfigutl	- Utilities for wavelet demos figures.
%
%-----------------------------------
% Examples: how to add new wavelets.
%-----------------------------------
%   binlwavf 	- Biorthogonal wavelet filters (binary wavelets: Binlets).
%   binlinfo	- Information on biorthogonal wavelets (Binlets).
%   lemwavf     - Lemarie wavelet filters.
%
%------------------------------------------
% Examples: Construct wavelet objects tree.
%------------------------------------------
%   wtree       - Constructor for the class WTREE.
%   merge       - Merge (recompose) the data of a node.
%   split       - Split (decompose) the data of a terminal node.
%------------------------------------------
%   rwvtree     - Constructor for the class RWVTREE.
%   merge       - Merge (recompose) the data of a node.
%   plot        - Plot RWVTREE object.
%   split       - Split (decompose) the data of a terminal node.
%------------------------------------------
%   wvtree      - Constructor for the class WVTREE.
%   get         - Get WVTREE object field contents.
%   plot        - Plot WVTREE object.
%   recons      - Reconstruct node coefficients.
%------------------------------------------
%   edwttree    - Constructor for the class EDWTTREE.
%   merge       - Merge (recompose) the data of a node.
%   plot        - Plot EDWTTREE object.
%   recons      - Reconstruct node coefficients.
%   split       - Split (decompose) the data of a terminal node.
%------------------------------------------
%   ex1_wt      - Example of 1-D wavelet tree (WTREE OBJECT).
%   ex2_wt      - Example of 2-D wavelet tree (WTREE OBJECT).
%   ex1_rwvt    - Example of 1-D wavelet tree (RWTREE OBJECT).
%   ex2_rwvt    - Example of 2-D wavelet tree (RWTREE OBJECT).
%   ex1_wvt     - Example of 1-D wavelet tree (WVTREE OBJECT).
%   ex2_wvt     - Example of 2-D wavelet tree (WVTREE OBJECT).
%   ex1_edwt    - Example of 1-D wavelet tree (EDWTTREE OBJECT).
%------------------------------------------
%

% Last Revision: 12-Nov-2003.
% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.18.4.2 $ $Date: 2004/03/15 22:36:56 $
