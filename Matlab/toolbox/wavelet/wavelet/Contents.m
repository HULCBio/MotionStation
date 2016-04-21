% Wavelet Toolbox
% Version 3.0 (R14) 05-May-2004
%
% Wavelet Toolbox GUI (Graphical User Interface).
%   wavemenu    - Start Wavelet Toolbox graphical user interface tools.
%
% Wavelets: General.
%   biorfilt    - Biorthogonal wavelet filter set.
%   centfrq     - Wavelet center frequency.
%   dyaddown    - Dyadic downsampling.
%   dyadup      - Dyadic upsampling.
%   intwave     - Integrate wavelet function psi.
%   orthfilt    - Orthogonal wavelet filter set.
%   qmf         - Quadrature mirror filter.
%   scal2frq    - Scale to frequency.
%   wavefun     - Wavelet and scaling functions.
%   wavefun2    - Wavelets and scaling functions 2-D.
%   wavemngr    - Wavelet manager. 
%   wfilters    - Wavelet filters.
%   wmaxlev     - Maximum wavelet decomposition level.
%
% Wavelet Families.
%   biorwavf    - Biorthogonal spline wavelet filters.
%   cgauwavf    - Complex Gaussian wavelet.
%   cmorwavf    - Complex Morlet wavelet.
%   coifwavf    - Coiflet wavelet filter.
%   dbaux       - Daubechies wavelet filter computation.
%   dbwavf      - Daubechies wavelet filters.
%   fbspwavf    - Complex Frequency B-Spline wavelet.
%   gauswavf    - Gaussian wavelet.
%   mexihat     - Mexican Hat wavelet.
%   meyer       - Meyer wavelet.
%   meyeraux    - Meyer wavelet auxiliary function.
%   morlet      - Morlet wavelet.
%   rbiowavf    - Reverse Biorthogonal spline wavelet filters.
%   shanwavf    - Complex Shannon wavelet.
%   symaux      - Symlet wavelet filter computation.
%   symwavf     - Symlet wavelet filter.
%
% Continuous Wavelet: One-Dimensional.
%   cwt         - Real or Complex Continuous wavelet coefficients 1-D.
%   pat2cwav    - Construction of a wavelet starting from a pattern.
%
% Discrete Wavelets: One-Dimensional.
%   appcoef     - Extract 1-D approximation coefficients.
%   detcoef     - Extract 1-D detail coefficients.
%   dwt         - Single-level discrete 1-D wavelet transform.
%   dwtmode     - Discrete wavelet transform extension mode.
%   idwt        - Single-level inverse discrete 1-D wavelet transform.
%   upcoef      - Direct reconstruction from 1-D wavelet coefficients.
%   upwlev      - Single-level reconstruction of 1-D wavelet decomposition.
%   wavedec     - Multi-level 1-D wavelet decomposition.
%   waverec     - Multi-level 1-D wavelet reconstruction.
%   wenergy     - Energy for 1-D wavelet decomposition.
%   wrcoef      - Reconstruct single branch from 1-D wavelet coefficients.
%
% Discrete Wavelets: Two-Dimensional.
%   appcoef2    - Extract 2-D approximation coefficients.
%   detcoef2    - Extract 2-D detail coefficients.
%   dwt2        - Single-level discrete 2-D wavelet transform.
%   dwtmode     - Discrete wavelet transform extension mode.
%   idwt2       - Single-level inverse discrete 2-D wavelet transform.
%   upcoef2     - Direct reconstruction from 2-D wavelet coefficients.
%   upwlev2     - Single-level reconstruction of 2-D wavelet decomposition.
%   wavedec2    - Multi-level 2-D wavelet decomposition.
%   waverec2    - Multi-level 2-D wavelet reconstruction.
%   wenergy2    - Energy for 2-D wavelet decomposition.
%   wrcoef2     - Reconstruct single branch from 2-D wavelet coefficients.
%
% Wavelets Packets Algorithms.
%   bestlevt    - Best level tree (wavelet packet).
%   besttree    - Best tree (wavelet packet).
%   entrupd     - Entropy update (wavelet packet).
%   wenergy     - Energy for a wavelet packet decomposition.
%   wentropy    - Entropy (wavelet packet).
%   wp2wtree    - Extract wavelet tree from wavelet packet tree.
%   wpcoef      - Wavelet packet coefficients.
%   wpcutree    - Cut wavelet packet tree.
%   wpdec       - Wavelet packet decomposition 1-D.
%   wpdec2      - Wavelet packet decomposition 2-D.
%   wpfun       - Wavelet packet functions.
%   wpjoin      - Recompose wavelet packet.
%   wprcoef     - Reconstruct wavelet packet coefficients.
%   wprec       - Wavelet packet reconstruction 1-D. 
%   wprec2      - Wavelet packet reconstruction 2-D.
%   wpsplt      - Split (decompose) wavelet packet.
%
% Discrete Stationary Wavelet Transform Algorithms.
%   iswt        - Inverse discrete stationary wavelet transform 1-D.
%   iswt2       - Inverse discrete stationary wavelet transform 2-D.
%   swt         - Discrete stationary wavelet transform 1-D.
%   swt2        - Discrete stationary wavelet transform 2-D.
%
% Lifting Functions
%   addlift     - Adding primal or dual lifting steps.
%   bswfun      - Biorthogonal scaling and wavelet functions.
%   displs      - Display lifting scheme.
%   filt2ls     - Filters to lifting scheme.
%   ilwt        - Inverse 1-D lifting wavelet transform.
%   ilwt2       - Inverse 2-D lifting wavelet transform.
%   liftfilt    - Apply elementary lifting steps on filters.
%   liftwave    - Lifting scheme for usual wavelets.
%   lsinfo      - Information about lifting schemes.
%   lwt         - Lifting wavelet decomposition 1-D.
%   lwt2        - Lifting wavelet decomposition 2-D.
%   lwtcoef     - Extract or reconstruct 1-D LWT wavelet coefficients.
%   lwtcoef2    - Extract or reconstruct 2-D LWT wavelet coefficients.
%   wave2lp     - Laurent polynomial associated to a wavelet.
%   wavenames   - Wavelet names information.
%
% Laurent Polynomial [OBJECT in @laurpoly directory]
%   laurpoly    - Constructor for the class LAURPOLY (Laurent Polynomial).
%
% Laurent Matrix [OBJECT in @laurmat directory]
%   laurmat     - Constructor for the class LAURMAT (Laurent Matrix).
%
% De-noising and Compression for Signals and Images.
%   ddencmp     - Default values for de-noising or compression.
%   thselect    - Threshold selection for de-noising.
%   wbmpen      - Penalized threshold for wavelet 1-D or 2-D de-noising.
%   wdcbm       - Thresholds for wavelet 1-D using Birge-Massart strategy.
%   wdcbm2      - Thresholds for wavelet 2-D using Birge-Massart strategy.
%   wden        - Automatic 1-D de-noising using wavelets.
%   wdencmp     - De-noising or compression using wavelets.
%   wnoise      - Generate noisy wavelet test data.
%   wnoisest    - Estimate noise of 1-D wavelet coefficients.
%   wpbmpen     - Penalized threshold for wavelet packet de-noising.
%   wpdencmp    - De-noising or compression using wavelet packets.
%   wpthcoef    - Wavelet packet coefficients thresholding.
%   wthcoef     - Wavelet coefficient thresholding 1-D.
%   wthcoef2    - Wavelet coefficient thresholding 2-D.
%   wthresh     - Perform soft or hard thresholding.
%   wthrmngr    - Threshold settings manager.
%
% Other Wavelet Applications.
%   wfbm        - Synthesize fractional Brownian motion.
%   wfbmesti    - Estimate fractal index.
%   wfusimg     - Fusion of two images.
%   wfusmat     - Fusion of two matrices or arrays.
%
% Tree Management Utilities.
%   allnodes    - Tree nodes.
%   cfs2wpt     - Wavelet packet tree construction from coefficients.
%   depo2ind    - Node depth-position to node index.
%   disp        - Display information of WPTREE object.
%   drawtree    - Draw wavelet packet decomposition tree (GUI).
%   dtree       - Constructor for the class DTREE.
%   get         - Get tree object field contents.
%   ind2depo    - Node index to node depth-position.
%   isnode      - True for existing node.
%   istnode     - Determine indices of terminal nodes.
%   leaves      - Determine terminal nodes.
%   nodeasc     - Node ascendants.
%   nodedesc    - Node descendants.
%   nodejoin    - Recompose node.
%   nodepar     - Node parent.
%   nodesplt    - Split (decompose) node.
%   noleaves    - Determine nonterminal nodes.
%   ntnode      - Number of terminal nodes.
%   ntree       - Constructor for the class NTREE.
%   plot        - Plot tree object.
%   read        - Read values in tree object fields.
%   readtree    - Read wavelet packet decomposition tree from a figure.
%   set         - Set tree object field contents.
%   tnodes      - Determine terminal nodes (obsolete - use LEAVES).
%   treedpth    - Tree depth.
%   treeord     - Tree order.
%   wptree      - Constructor for the class WPTREE.
%   wpviewcf    - Plot wavelet packets colored coefficients.
%   write       - Write values in tree object fields.
%   wtbo        - Constructor for the class WTBO.
%   wtreemgr    - NTREE object manager.
%
% General Utilities.
%   wcodemat    - Extended pseudocolor matrix scaling.
%   wextend     - Extend a Vector or a Matrix.
%   wkeep       - Keep part of a vector or a matrix.
%   wrev        - Flip vector.
%   wtbxmngr    - Wavelet Toolbox manager.
%
% Other.
%   wvarchg     - Find variance change points.
%
% Wavelets Information.
%   waveinfo    - Information on wavelets.
%
% Demonstrations.
%   wavedemo    - Wavelet Toolbox demos.
%   demolift    - Demonstrates Lifting functions in the Wavelet Toolbox.  
%
% See also WAVEDEMO.
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Non-documented functions used in the toolbox. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.x to Version 2.x Utilities.
%   convv1v2    - Convert Wavelet Toolbox Data Strutures.
%   wgfields    - Get object or structure field contents.
%   wsfields    - Set object or structure field contents.
%   wtbx_gbl.v1 - MATLAB file used by wtbxmngr for version 1.x (in waveobsolete).
%   wtbx_gbl.v2 - MATLAB file used by wtbxmngr for version 2.x (in wavedemo).
%   wtbx_gbl.v3 - MATLAB file used by wtbxmngr for version 3.x (in wavedemo).
%
% Objects functions.
%-------------------
% WTBO Object:
%   display     - Display information of WTBO object.
%   get         - Get WTBO object field contents.
%   getwtbo     - Get object field contents.
%   set         - Set WTBO object field contents.
%   setwtbo     - Set object field contents.
%   wtbo        - Constructor for the class WTBO.
%
% NTREE Object:
%   disp        - Display information of NTREE object.
%   findactn    - Find active nodes.
%   get         - Get NTREE object field contents.
%   locnumcn    - Local number for a child node.
%   nodejoin    - Recompose node(s).
%   nodesplt    - Split (decompose) node(s).
%   ntree       - Constructor for the class NTREE.
%   plot        - Plot ntree object.
%   set         - Set NTREE object field contents.
%   tabofasc    - Table of ascendants of nodes.
%   tlabels     - Labels for the nodes of a tree.
%   wtreemgr    - Manager for ntree object.
%
% DTREE Object:
%   defaninf    - Define node infos (all nodes).
%   disp        - Display information of DTREE object.
%   dtree       - Constructor for the class DTREE.
%   expand      - Expand data tree.
%   fmdtree     - Field manager for DTREE object.
%   get         - Get DTREE object field contents.
%   merge       - Merge (recompose) the data of a node.
%   nodejoin    - Recompose node.
%   nodesplt    - Split (decompose) node.
%   plot        - Plot dtree object.
%   read        - Read values in DTREE object fields.
%   recons      - Reconstruct node coefficients.
%   rnodcoef    - Reconstruct node coefficients.
%   set         - Set DTREE object field contents.
%   split       - Split (decompose) the data of a terminal node.
%   write       - Write values in DTREE object fields.
%
% WPTREE Object:
%   bestlevt    - Best level wavelet packet tree.
%   besttree    - Best wavelet packet tree.
%   defaninf    - Define node infos (all nodes).
%   disp        - Display information of WPTREE object.
%   entrupd     - Entropy update (wavelet packet tree).
%   get         - Get WPTREE object field contents.
%   merge       - Merge (recompose) the data of a node.
%   read        - Read values in WPTREE object fields.
%   recons      - Reconstruct wavelet packet coefficients.
%   set         - Set WPTREE object field contents.
%   split       - Split (decompose) the data of a terminal node.
%   tlabels     - Labels for the nodes of a wavelet packet tree.
%   wp2wtree    - Extract wavelet tree from wavelet packet tree.
%   wenergy     - Energy for a wavelet packet decomposition.
%   wpcoef      - Wavelet packet coefficients.
%   wpcutree    - Cut wavelet packet tree.
%   wpjoin      - Recompose wavelet packet.
%   wpplotcf    - Plot wavelet packets colored coefficients.
%   wprcoef     - Reconstruct wavelet packet coefficients.
%   wprec       - Wavelet packet reconstruction 1-D.
%   wprec2      - Wavelet packet reconstruction 2-D.
%   wpsplt      - Split (decompose) wavelet packet.
%   wpthcoef    - Wavelet packet coefficients thresholding.
%   wptree      - Constructor for the class WPTREE.
%   wpviewcf    - Plot wavelet packets colored coefficients.
%   write       - Write values in WPTREE object fields.
%
% Miscellaneous
%   wavetool    - Warning function (Strang-Nguyen's book refers to wavetool - see WAVEOBSOLETE directory).
%
% Wavelets Information.
%   biorinfo    - Information on biorthogonal spline wavelets.
%   cgauinfo    - Information on complex Gaussian wavelets.
%   cmorinfo    - Information on complex Morlet wavelets.
%   coifinfo    - Information on coiflets.
%   dbinfo      - Information on Daubechies wavelets.
%   dmeyinfo    - Information on "Discrete" Meyer wavelet.
%   fbspinfo    - Information on Frequency B-Spline wavelets.
%   gausinfo    - Information on Gaussian wavelets.
%   haarinfo    - Information on Haar wavelet.
%   infowave    - Information on wavelets.
%   infowsys    - Information on wavelet packets.
%   mexhinfo    - Information on Mexican Hat wavelet.
%   meyrinfo    - Information on Meyer wavelet.
%   morlinfo    - Information on Morlet wavelet.
%   rbioinfo    - Information on reverse biorthogonal spline wavelets.
%   shaninfo    - Information on Shannon wavelets.
%   syminfo     - Information on near symmetric wavelets.
%
% Graphical User Interface: Main Tools.
%   cf1dtool    - Wavelet Coefficients Selection 1-D tool.
%   cf2dtool    - Wavelet Coefficients Selection 2-D tool.
%   cw1dtool    - Continuous 1-D wavelet tool (Real).
%   cwimtool    - Complex continuous 1-D wavelet tool.
%   de1dtool    - Density estimation tool.
%   dw1dtool    - Discrete Wavelet 1-D tool.
%   dw2dtool    - Discrete Wavelet 2-D tool.
%   imgxtool    - Image extension tool.
%   nwavtool     - New wavelet for continuous analysis tool.
%   nwavtool.fig - New wavelet for continuous analysis tool.
%   re1dtool    - Regression  estimation tool.
%   sigxtool    - Signal extension tool.
%   sw1dtool    - Stationary Wavelet Transform 1-D tool.
%   sw2dtool    - Stationary Wavelet Transform 2-D tool.
%   wavemenu.fig - Wavemenu (figure).
%   wdretool    - Wavelet Density and Regression tool.
%   wfbmtool    - Fractional Brownian motion generation tool.
%   wfbmtool.fig  - Fractional Brownian motion generation tool.
%   wfustool    - Wavelet 2-D GUI tool for fusion.
%   wfustool.fig  - Wavelet 2-D GUI tool for fusion (.FIG).
%   wmoreres    - "More information" on wavelet residuals tool.
%   wp1dtool    - Wavelet packets 1-D tool.
%   wp2dtool    - Wavelet packets 2-D tool.
%   wpdtool     - Wavelet packets display tool.
%   wvdtool     - Wavelet display tool.
%
% Graphical User Interface: Wavelets 1-D and 2-D.
%   dw1dcfsm    - Discrete wavelet 1-D show and scroll (stemcfs) mode manager.
%   dw1dcomp    - Discrete wavelet 1-D compression.
%   dw1dcoor    - Discrete wavelet 1-D coordinates.
%   dw1ddecm    - Discrete wavelet 1-D full decomposition mode.
%   dw1ddeno    - Discrete wavelet 1-D de-noising.
%   dw1ddisp    - Discrete wavelet 1-D display mode options.
%   dw1dfile    - Discrete wavelet 1-D file manager.
%   dw1dhist    - Discrete wavelet 1-D histograms.
%   dw1dmisc    - Discrete wavelet 1-D miscellaneaous utilities.
%   dw1dmngr    - Discrete wavelet 1-D general manager.
%   dw1dscrm    - Discrete wavelet 1-D show and scroll mode manager.
%   dw1dsepm    - Discrete wavelet 1-D separate mode manager.
%   dw1dstat    - Discrete wavelet 1-D statistics.
%   dw1dstem    - Discrete wavelet 1-D stem.
%   dw1dsupm    - Discrete wavelet 1-D superimpose mode manager.
%   dw1dtrem    - Discrete Wavelet 1-D tree mode manager.
%   dw1dutil    - Discrete wavelet 1-D utilities.
%   dw1dvdrv    - Discrete wavelet 1-D view mode driver.
%   dw1dvmod    - Discrete wavelet 1-D view mode manager.
%   dw2darro    - Discrete wavelet 2-D arrows.
%   dw2dcomp    - Discrete wavelet 2-D compression.
%   dw2ddeno    - Discrete wavelet 2-D de-noising.
%   dw2dhist    - Discrete wavelet 2-D histograms.
%   dw2dimgs    - Discrete wavelet 2-D image selection.
%   dw2dmngr    - Discrete wavelet 2-D general manager.
%   dw2drwcd    - Discrete wavelet 2-D read-write Cdata for image.
%   dw2dstat    - Discrete wavelet 2-D statistics.
%   dw2dutil    - Discrete wavelet 2-D utilities.
%
% Graphical User Interface: Wavelets Packets 1-D and 2-D.
%   tlabels     - Labels for the nodes of a wavelet packet tree.
%   wp1dcomp    - Wavelet packets 1-D compression.
%   wp1dcoor    - Wavelet packets 1-D coordinates.
%   wp1ddeno    - Wavelet packets 1-D de-noising.
%   wp1ddraw    - Wavelet packets 1-D drawing manager.
%   wp1dmngr    - Wavelet packets 1-D general manager.
%   wp1dstat    - Wavelet packets 1-D statistics.
%   wp1dutil    - Wavelet packets 1-D utilities.
%   wp2dcomp    - Wavelet packets 2-D compression.
%   wp2dcoor    - Wavelet packets 2-D coordinates.
%   wp2ddeno    - Wavelet packets 2-D de-noising.
%   wp2ddraw    - Wavelet packets 2-D drawing manager.
%   wp2dmngr    - Wavelet packets 2-D general manager.
%   wp2dstat    - Wavelet packets 2-D statistics.
%   wp2dutil    - Wavelet packets 2-D utilities.
%   wpfrqord    - Frequential order for wavelet packets.
%   wpfullsi    - Manage full size for axes.
%   wpplotcf    - Plot wavelet packets colored coefficients.
%   wpplottr    - Plot wavelet packets tree.
%   wpposaxe    - Axes positions for wavelet packets tool.
%   wpssnode    - Plot wavelet packets synthesized node.
%   wptreeop    - Operations on wavelet packets tree.
%
% Graphical User Interface: Continuous Wavelets.
%   cw1dcoor    - Continuous wavelet 1-D coordinates.
%   cw1ddraw    - Continuous wavelet 1-D drawing manager (see WAVEOBSOLETE directory).
%   cw1dmngr    - Continuous wavelet 1-D manager.
%   cw1dutil    - Continuous wavelet 1-D utilities.
%
% Graphical User Interface: Wavelet Coefficients Selection 1-D and 2-D.
%   cf1dcoor    - Coefficients 1-D coordinates.
%   cf1dselc    - Callbacks coefficients 1-D selection box.
%   utnbcfs     - Utilities for Coefficients Selection 1-D and 2-D tool.
%
% Graphical User Interface: Utilities.
%   key2info    - Key driven retrieve from tables.
%   wcmpscr     - Wavelet 1-D or 2-D compression scores.
%   wimgcode    - Image coding mode.
%   wpcmpscr    - Wavelet packets 1-D or 2-D compression scores.
%   wrmcoef     - Reconstruct row matrix of single branches from 1-D wavelet coefficients.
%   wrepcoef    - Replication of coefficients.
%   wscrupd     - Update Compression scores using Wavelets thresholding.
%   xynodpos    - Computes graphical position of a node in a tree.
%
% General Graphical Utilities.
%   cbanapar    - Callbacks for wavelet analysis parameters.
%   cbcolmap    - Callbacks for colormap utilities.
%   cbthrw1d    - Callbacks for threshold utilities 1-D.
%   cbthrw2d    - Callbacks for threshold utilities 2-D.
%   getonoff    - Returns a matrix of strings with 'off' or 'on '.
%   mousefrm    - Manage the mouse representation on the screen.
%   redimfig    - Reset the size for a new figure.
%   txtinaxe    - Right and left texts for axes.
%   utanapar    - Utilities for wavelet analysis parameters.
%   utcolmap    - Colormap utilities.
%   utentpar    - Utilities for wavelet packets entropy.
%   utguidiv    - Utilities for testing inputs for different "TOOLS" files.
%   utposfra    - Utilities for setting frame position.
%   utstats     - Utilities for statistics tools.
%   utthrgbl    - Utilities for global thresholding (compression).
%   utthrset    - Utilities for threshold settings.
%   utthrw1d    - Utilities for thresholding 1-D.
%   utthrw2d    - Utilities for thresholding 2-D.
%   utthrwpd    - Utilities for thresholding (Wavelet Packet De-noising).
%   waxecp	    - Axes Current Point and Axes limits.
%   wboxtitl    - Box title for axes.
%   wdstem      - Plot discrete sequence data.
%   wfighelp    - Utilities for Help system functions and menus.
%   wfigmngr    - Utilities for creating figures.
%   wfigtitl    - Titlebar for figures.
%   wfigutil    - Utilities for figures.
%   whelpfun    - Help function.
%   wplothis    - Plots histogram obtained with WGETHIST.
%   wpropimg    - Give image proportions.
%   wtbutils    - Wavelet Toolbox (Ressources) Utilities.
%   wtmotion    - Wavelet Toolbox default WindowButtonMotionFcn.
%   wtxttitl    - Set a text as a super title in an axes.
%   wwaitans    - Wait for an answer to a question.
%   wwaiting    - Wait and Display a message.
%   wwarndlg	- Display warning dialog box (and block execution).
%
% Wavelet Applications Utilities
%   compwav       - New wavelet for continuous analysis tool.
%   compwav.fig   - New wavelet for continuous analysis tool (figure).
%   make_pattern  - Make patterns for New Wavelet Tool.
%   wfbmstat      - Fractional Brownian motion statistics Tool.
%   wfbmstat.fig  - Fractional Brownian motion statistics Tool.
%   wfusdec       - Fusion of two wavelet decompositions. 
%   wfusfun       - Template for USER defined method of fusion.
%   wfustree      - Create a wavelet decomposition TREE.
%
% WDECTREE Object:  === Under Development ===
%   wdectree    - Constructor for the class WDECTREE. 
%   get         - Get WDECTREE object field contents.
%   getdec      - Get decomposition components.
%   merge       - Merge (recompose) the data of a node.
%   plot        - Plot wdectree object.
%   read        - Read values in WDECTREE object fields.
%   recons      - Reconstruct node coefficients.
%   split       - Split (decompose) the data of a terminal node.
%   tlabels     - Labels for the nodes of a wavelet decomposition tree.
%   wdtcoef     - Wavelet decomposition tree reconstruction.
%   wdtjoin     - Recompose wavelet packet.
%   wdtrec      - Wavelet decomposition tree reconstruction.
%   wdtsplit    - Split (decompose) wavelet packet.
%   write       - Write values in WDECTREE object fields.
%
% WDECTREE Object utilities:  === Under Development ===
%   cfs2wdt     - Wavelet decomposition tree construction from coefficients.
%
% MATLAB Extended Objects Utilities.
%   cleanaxe    - Delete children of axes.
%   dynvtool    - Dynamic visualization tool.
%   dynvzaxe    - Dynamic visualization tool (Zoom of Axes).
%   mextglob    - Module of extended objects globals.
%   mngcoor     - Manage display of coordinates values.
%   mngmbtn     - Manage mouse buttons for the dynamical visualization tool.
%   utsetcol    - Utilities for setting colors.
%   utsetfon    - Utilities for setting fonts.
%   wsetxlab    - Plot xlabel.
%   wtitle      - Graph title.
%   wxlabel     - X-axis label.
%   wylabel     - Y-axis label.
%
% General Utilities.
%   deblankl    - Convert string to lowercase without blanks.
%   errargn     - Check function arguments number.
%   errargt     - Check function arguments type.
%   gendens     - Generate random samples.
%   gidxsint    - Get indices of elements in a set intersection.
%   instdfft    - Inverse non-standard 1-D fast Fourier transform.
%   nstdfft     - Non-standard 1-D fast Fourier transform.
%   num2mstr    - Convert number to string in maximum precision.
%   wcommon     - Find common elements.
%   wdumfun     - Dummy function (do nothing).
%   wfileinf	- Read variables info in a file.
%   wfindobj    - Find objects with specified property values.
%   wgethist    - Build values to plot histogram.
%   wimghist    - Compute histograms.
%   wmemtool    - Manage memory tool.
%   wmemutil    - Memory utilities.
%   wreadinf    - Read ascii files.
%   wstr2num    - Convert string to number.
%
% Other Utilities.
%   chgwname	- Change the name of wavelet in a WP data structure (see WAVEOBSOLETE directory).
%   upsaconv    - Upsample and convolution.
%   wconv       - 1-D or 2-D convolution.
%   wlagrang    - "Lagrange a trous" filters computation.
%   wmachdep    - Machine dependent values.
%   wnsubstr    - Convert number to TEX indices.
%   wpcf_wcf    - Wavelet tree and wavelet packet tree coefficients.
%   wpcfwcfo    - Wavelet tree and wavelet packet tree coefficients (Obsolete Version - see WAVEOBSOLETE directory).
%   wshift      - Shift a Vector or a Matrix.
%   wtbxicon    - About Wavelet toolbox MAT-file
%
% Demos.
%
%------------------
% Slide show driver.
%------------------
%   wshowdrv    - Wavelet toolbox slide show helper.
%   whelpdem    - Help function for Demos.
%-------------------------
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
%   demoguim    - Main GUI mode demos menu.
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
%   dguisw1d    - Demo for 1-D SWT de-noising.
%   dguisw2d    - Demo for 2-D SWT de-noising.
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
%   demos 	- Demo list for the Wavelet Toolbox.
%   dmsgfun     - Message function for demos.
%   wdfigutl	- Utilities for wavelet demos figures.
%   wenamngr	- Enable settings for GUI demos.
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
%   ex1_wt      - Example of 1-D wavelet tree (WTREE).
%   ex2_wt      - Example of 2-D wavelet tree (WTREE).
%   ex1_rwvt    - Example of 1-D wavelet tree (RWTREE).
%   ex2_rwvt    - Example of 2-D wavelet tree (RWTREE).
%   ex1_wvt     - Example of 1-D wavelet tree (WVTREE).
%   ex2_wvt     - Example of 2-D wavelet tree (WVTREE).
%   ex1_edwt    - Example of 1-D wavelet tree (EDWTTREE).
%------------------------------------------
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAT-files used in the toolbox.                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Coifman wavelets.
%   coif1       - Coiflet filter order 1.
%   coif2       - Coiflet filter order 2.
%   coif3       - Coiflet filter order 3.
%   coif4       - Coiflet filter order 4.
%   coif5       - Coiflet filter order 5.
%
% Daubechies wavelets.
%   db1         - Daubechies filter order 1.
%   db2         - Daubechies filter order 2.
%   db3         - Daubechies filter order 3.
%   db4         - Daubechies filter order 4.
%   db5         - Daubechies filter order 5.
%   db6         - Daubechies filter order 6.
%   db7         - Daubechies filter order 7.
%   db8         - Daubechies filter order 8.
%   db9         - Daubechies filter order 9.
%   db10        - Daubechies filter order 10.
%
% "Discrete" Meyer wavelet.
%   dmey        - "Discrete" Meyer filter approximation of the Meyer Wavelet.
%
% Haar wavelet.
%   haar        - Haar filter.
%
% Symlets.
%   sym2        - Symlet filter order 2.
%   sym3        - Symlet filter order 3.
%   sym4        - Symlet filter order 4.
%   sym5        - Symlet filter order 5.
%   sym6        - Symlet filter order 6.
%   sym7        - Symlet filter order 7.
%   sym8        - Symlet filter order 8.
%
% Testing signals (DWT or CWT or WP).
%   brkintri    - Near breakdowns in a triangle.
%   cnoislop    - Colored noisy slope.
%   cuspamax    - Cusp an regular maximum.
%   ex1cusp1    - Example 1 for density estimation: cusp1 (1000).
%   ex2cusp1    - Example 2 for density estimation: cusp1 (2000).
%   ex1cusp2    - Example 1 for density estimation: cusp2 (1000).
%   ex2cusp2    - Example 2 for density estimation: cusp2 (2000).
%   ex1gauss    - Example 1 for density estimation: gauss (1000).
%   ex2gauss    - Example 2 for density estimation: gauss (2000).
%   ex1nfix     - Example 1 for regression estimation fixed design.
%   ex2nfix     - Example 2 for regression estimation fixed design.
%   ex3nfix     - Example 3 for regression estimation fixed design.
%   ex1nsto     - Example 1 for regression estimation stochastic design.
%   ex2nsto     - Example 2 for regression estimation stochastic design.
%   ex3nsto     - Example 3 for regression estimation stochastic design.
%   freqbrk     - Frequency breakdown.
%   heavysin    - Noisy heavy sine.
%   leleccum    - Electrical consumption.
%   linchirp    - Linear chirp.
%   mfrqbrk     - Many frequency breakdowns
%   mishmash    - MishMash.
%   nblocr1     - Noisy blocks (3 Intervals).
%   nblocr2     - Noisy blocks (3 Intervals).
%   nbumpr1     - Noisy bumps  (3 Intervals).
%   nbumpr2     - Noisy bumps  (2 Intervals).
%   nbumpr3     - Noisy bumps  (4 Intervals).
%   ndoppr1     - Noisy Doppler (3 Intervals).
%   nearbrk     - Near breakdowns.
%   nelec       - Noisy electrical consumption (3 Intervals).
%   noisbloc    - Noisy blocks.
%   noisbump    - Noisy bumps.
%   noischir    - Noisy quadratic chirp.
%   noisdopp    - Noisy Doppler.
%   noismima    - Noisy mishmash.
%   noispol     - Noisy polynomial
%   noissin     - Noisy sine.
%   qdchirp     - Quadratic chirp.
%   quachirp    - Quadratic chirp (small length).
%   scddvbrk    - Second derivative breakdown.
%   sinfract    - Fractal signal.
%   sinper8     - Sine of period 8.
%   snblocr1    - Stochastic noisy blocks (3 Intervals).
%   snblocr2    - Stochastic noisy blocks (3 Intervals).
%   snbumpr1    - Stochastic noisy bumps (3 Intervals).
%   snbumpr2    - Stochastic noisy bumps (2 Intervals).
%   snbumpr3    - Stochastic noisy bumps (4 Intervals).
%   sndoppr1    - Stochastic noisy Doppler (3 Intervals).
%   snelec      - Stochastic noisy electrical consumption (3 Intervals).
%   sumlichr    - Sum of linear chirps.
%   sumsin      - Sum of sines.
%   trsin       - Triangle and sine superposition.
%   vonkoch     - Koch curve.
%   warma       - Arma noise.
%   wcantor     - Cantor curve.
%   wcantsym    - Symmetric Cantor curve.
%   whitnois    - White noise.
%   wnoislop    - White noisy slope.
%   wntrsin     - Noisy triangle and sine superposition.
%   wstep       - Step signal.
%
% Testing images (DWT or WP).
%   belmont1    - Belmont - City Hall 1	    	240 by 320
%   belmont2    - Belmont - City Hall 2	    	240 by 320 
%   chess       - Chess pieces                  256 by 256
%   detfingr    - Fingerprint                   296 by 296
%   facets      - Polyedron facets              256 by 256
%   geometry    - Geometry                      128 by 128
%   julia       - Julia set                     296 by 368
%   mandel      - Mandelbrot set                152 by 208
%   nbarb1      - noisy Barbara 128x128 [white noise 2D (0,10)].
%   noissi2d    - Noisy sinsin                  128 by 128
%   noiswom     - Barbara's face (noisy zoom)    96 by  96
%   sinsin      - sin(8*pi*x)* sin(8*pi*y)      128 by 128
%   tartan      - Tartan                        128 by 128
%   tire        - Tire                          200 by 232
%   wbarb       - Barbara                       256 by 256
%   wgatlin     - Piece of Gatlin image         120 by 176
%   wifs        - Ifs                           144 by 128
%   wmandril    - Coarse version of Mandrill    120 by 120
%   woman       - Barbara's face                256 by 256
%   woman2      - Barbara's face                128 by 128
%
% Examples of Images (used by WFUSTOOL): 
%   bust        - Roman Imperator Bust          256 by 256   
%   cathe_1     - Catherine (Image 1)      	    256 by 256   
%   cathe_2     - Catherine (Image 2)      	    256 by 256   
%   detail_1    - Detail (Image 1)      	    256 by 256   
%   detail_2    - Detail (Image 2)      	    256 by 256   
%   mask        - Mask of Japonese No Theatre   256 by 256
%   arms.jpg    - Arms of Belmont               256 by 256
%   blason.jpg  - Arms of Belmont               256 by 256
%   blason.pcx  - Arms of Belmont               256 by 256
%   face_mos    - Head side of coin             256 by 256
%   face_mos.pcx - Head side of coin            256 by 256
%   face_pai    - Head side of coin             256 by 256
%   fond_bou    - Texture (1)                   256 by 256
%   fond_cui    - Texture (2)                   256 by 256 
%   fond_cuif   - Texture (3)                   256 by 256 
%   fond_fou    - Texture (4)                   256 by 256 
%   fond_mos    - Texture (5)                   256 by 256 
%   fond_pai    - Texture (6)                   256 by 256 
%   fond_pav    - Texture (7)                   256 by 256 
%   fond_tex    - Texture (8)                   256 by 256 
%   pile_mos    - Tail side of coin             256 by 256
%
% Examples of Patterns (used by NWAVTOOL):
%   pertri      - Periodical triangle (periode 256) length = 2048
%   ptbumps     - Bumps pattern                length = 256
%   pthaar      - Haar pattern                 length = 256
%   ptodlin     - Odd linear pattern           length = 256
%   ptodpoly    - Odd polynomial pattern       length = 256
%   ptodtri     - Odd triangle pattern         length = 256
%   ptpssin1    - Sinusoidal pattern (1)       length = 256
%   ptpssin2    - Sinusoidal pattern (2)       length = 256
%   ptsine      - Sinusoidal pattern (3)       length = 256
%   ptsinpol    - Sine + polynomial pattern    length = 256
%   ptsumsin    - Sum of sine pattern          length = 256
%   regsinus    - Sine (periode 256)           length = 2048
%   testsig1    - Test signal for patterns (1) length = 2048
%   testsig3    - Test signal for patterns (2) length = 2048
%   testsig4    - Test signal for patterns (3) length = 2048
%   tstsig1s    - Test signal for patterns (4) length = 768
%   tstsig1t    - Test signal for patterns (5) length = 2048
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other files used in the toolbox.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   dwtmode.cfg  - default attributes for the DWT.
%   wavelets.ini - original ascii file containing wavelets info.
%   wavelets.bin - original binary file containing wavelets info.
%   wavelets.asc - ascii file containing wavelets info.
%   wavelets.inf - binary file containing wavelets info.
%   wavelet.map  - Used for help (in docroot/toolbox/wavelet)

% Last Revision: 10-Mar-2004.
% Copyright 1995-2004 The MathWorks, Inc.
% Generated from Contents.m_template revision 1.42.4.2 $Date: 2004/04/01 16:30:44 $

