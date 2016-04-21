% Main documented lifting functions
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
%   laurpoly     - Constructor for the class LAURPOLY (Laurent Polynomial).
%
% Laurent Matrix [OBJECT in @laurmat directory]
%   laurmat      - Constructor for the class LAURMAT (Laurent Matrix).
%
% Demonstrations.
%   demolift    - Demonstrates Lifting functions in the Wavelet Toolbox.  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Full description of Lifting Directories                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Lifting directory (Main).
%==========================
%   readmeLIFT  - SOME COMMENTS about LIFTING FUNCTIONALITIES
%   Contents    - Contents for Wavelet Toolbox Lifting Tools.
%   demolift    - Demonstrates Lifting functions in the Wavelet Toolbox.  
%---+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--%
%   addlift     - Adding primal or dual lifting steps.
%   apmf2ls     - Analyzis polyphase matrix factorization to lifting scheme.
%   biorlift    - Biorthogonal spline lifting schemes.
%   bswfun      - Biorthogonal scaling and wavelet functions.
%   cdflift     - Cohen-Daubechies-Feauveau lifting schemes.
%   coiflift    - Coiflets lifting schemes.
%   dblift      - Daubechies lifting schemes.
%   displmf     - Display a Laurent matrices factorization.
%   displs      - Display lifting scheme.
%   errlsdec    - Errors for lifting scheme decompositions.
%   fact_and_ls - Factorizations and lifting schemes for wavelets.
%   filt2ls     - Filters to lifting scheme.
%   filters2lp  - Filters to Laurent polynomials.
%   hlwt        - Haar (Integer) Wavelet decomposition 1-D using lifting.  # UD #
%   hlwt2       - Haar (Integer) Wavelet decomposition 2-D using lifting.  # UD #
%   ihlwt       - Haar (Integer) Wavelet reconstruction 1-D using lifting. # UD #
%   ihlwt2      - Haar (Integer) Wavelet reconstruction 2-D using lifting. # UD #
%   ilwt        - Inverse 1-D lifted wavelet transform.
%   ilwt2       - Inverse 2-D lifted wavelet transform.
%   inp2sq      - In Place to "square" storage of coefficients.
%   isbiorw     - True for a biorthogonal wavelet.
%   isorthw     - True for an orthogonal wavelet.
%   liftfilt    - Apply elementary lifting steps on filters.
%   liftwave    - Lifting scheme for usual wavelets.
%   ls2apmf     - Lifting scheme to analyzis polyphase matrix factorization.
%   ls2filt     - Lifting scheme to filters.
%   ls2filters  - Lifting scheme to filters.
%   ls2lp       - Lifting scheme to Laurent polynomials.
%   ls2pmf      - Lifting scheme(s) to polyphase matrix factorization(s).
%   lsdual      - Dual lifting scheme.
%   lsinfo      - Information about lifting schemes.
%   lsupdate    - Compute lifting scheme update.
%   lwt         - Wavelet decomposition 1-D using lifting.
%   lwt2        - Wavelet decomposition 2-D using lifting.
%   lwtcoef     - Extract or reconstruct 1-D LWT wavelet coefficients.
%   lwtcoef2    - Extract or reconstruct 2-D LWT wavelet coefficients.
%   orfilen4    - Orthogonal filters of length 4.
%   pmf2apmf    - Polyphase matrix factorization to analyzis polyphase matrix 
%                 factorization.
%   pmf2ls      - Polyphase matrix factorization(s) to lifting scheme(s).
%   symlift     - Symlets lifting schemes.
%   show_et     - Show table obtained by the Euclidean division algorithm.
%   tablseq     - Equality test for lifting schemes.
%   wave2lp     - Laurent polynomial associated to a wavelet.
%   wave2ls     - Lifting scheme associated to a wavelet.
%   wavenames   - Wavelet names information.
%   wavetype    - Wavelet type information.
%
% Laurent Matrix [OBJECT in @laurmat directory]
%=========================================
%   ctranspose  - Laurent matrix transpose (non-conjugate).
%   det         - Laurent matrix determinant.
%   disp        - Display a Laurent matrix object as text.
%   display     - Display function for LAURMAT objects.
%   eq          - Laurent matrix equality test.
%   isequal     - True if Laurent matrices are numerically equal.
%   laurmat     - Constructor for the class LAURMAT (Laurent Matrix).
%   mftable     - Matrix factorization table.
%   minus       - Laurent matrix substraction.
%   mtimes      - Laurent matrix multiplication.
%   ne          - Laurent matrix inequality test.
%   newvar      - Change variable in a Laurent matrix.
%   plus        - Laurent matrix addition.
%   pm2ls       - Polyphase matrix to lifting scheme(s).
%   prod        - Product of Laurent matrices.
%   reflect     - Reflection for a Laurent matrix.
%   subsasgn    - Subscripted assignment for Laurent matrix.
%   subsref     - Subscripted reference for Laurent matrix.
%   uminus      - Unary minus for Laurent matrix.
%
% Laurent Polynomial [OBJECT in @laurpoly directory]
%=============================================
%   degree      - Degree for Laurent polynomial.
%   disp        - Display a Laurent polynomial object as text.
%   display     - Display function for LAURPOLY objects.
%   dyaddown    - Dyadic downsampling for a Laurent polynomial.
%   dyadup      - Dyadic upsampling for a Laurent polynomial.
%   eo2lp       - Recover a Laurent polynomial from its even and odd parts.
%   eq          - Laurent polynomial equality test.
%   eucfacttab  - Euclidean factor table for Euclidean division algorithm.
%   euclidediv  - Euclidean Algorithm for Laurent polynomials.
%   euclidedivtab - Table obtained by the Euclidean division algorithm.
%   even        - Even part of a Laurent polynomial.
%   get         - Get LAURPOLY object field contents.
%   horzcat     - Horizontal concatenation of Laurent polynomials.
%   inline      - Construct an INLINE object associated to a Laurent polynomial.
%   isconst     - True for a constant Laurent polynomial.
%   isequal     - Laurent polynomials equality test.
%   ismonomial  - True for a monomial Laurent polynomial.
%   laurpoly    - Constructor for the class LAURPOLY (Laurent Polynomial).
%   lp2filters  - Laurent polynomials to filters.
%   lp2ls       - Laurent polynomial to lifting schemes.
%   lp2num      - Coefficients of a Laurent polynomial object.
%   lpstr       - String to display a Laurent polynomial object.
%   makelift    - Make an elementary lifting step.
%   minus       - Laurent polynomial substraction.
%   mldivide    - Laurent polynomial matrix left division.
%   modmat      - Modulation matrix associated to two Laurent polynomials.
%   modulate    - Modulation for a Laurent polynomial.
%   mpower      - Laurent polynomial exponentiation.
%   mrdivide    - Laurent polynomial matrix right division.
%   mtimes      - Laurent polynomial multiplication.
%   ne          - Laurent polynomial inequality test.
%   newvar      - Change variable in a Laurent polynomial.
%   odd         - Odd part of a Laurent polynomial.
%   plus        - Laurent polynomial addition.
%   pnorm       - Pseudo-norm for a Laurent polynomial.
%   powers      - Powers of a Laurent polynomial.
%   ppm         - Polyphase matrix associated to two Laurent polynomials.
%   ppmfact     - Polyphase matrix factorizations.
%   praacond    - Perfect reconstruction and anti-aliasing conditions.
%   prod        - Product of Laurent polynomials.
%   reflect     - Reflection for a Laurent polynomial.
%   rescale     - Rescale Laurent polynomials.
%   sameswfplot - Same BSWFUN and WAVEFUN plots.
%   uminus      - Unary minus for Laurent polynomial.
%   vertcat     - Vertical concatenation of Laurent polynomials.
%   wlift       - Make elementary lifting steps.
%
% @laurpoly/private directory
%----------------------
%   reduce      - Simplification for Laurent polynomial.
%
% test directory
%===============
% Main directory tests
%   tlwtilwt    - Unit test for the function LWT.
%   tlwtilwt2   - Unit test for the function LWT2.
%   tls2filters - Unit test for the function LS2FILTERS.
%   tls2lp      - Unit test for the function LS2LP.
%   tpmf2apmf   - Unit test for the function PMF2APMF.
%   twave2lp    - Unit test for the function WAVE2LP.
%---+--+--+--+--+--+--+--+--+--+--+--+--+--%
% Laurent Matrix object (LAURMAT)
%   tlm         - Unit test for LAURMAT (constructor in @LAURMAT).
%   tlm_ovr_m   - Unit test for LAURMAT object overloaded methods.
%   tlm_own_m   - Unit test for LAURMAT object own methods.
%---+--+--+--+--+--+--+--+--+--+--+--+--+--%
% Laurent Polynomial object (LAURPOLT)
%   tlp         - Unit test for LAURPOLY (constructor in @LAURPOLY).
%   tlp_ovr_m   - Unit test for LAURPOLY object overloaded methods.
%   tlp_own_m   - Unit test for LAURPOLY object own methods.
%   tlp_wlift   - Unit test for WLIFT.
%
%========================================================================%
%                UNDER DEVELOPMENT and TEMPORARY FILES                   %
%========================================================================%
%
% demo_and_misc/demo directory
%=============================
%   dem_1       - Demo 1 for  Lifting functions.
%   dem_2       - Demo 2 for  Lifting functions.         
%   dem_3       - Demo 3 for  Lifting functions.
%   dem_4       - Demo 4 for  Lifting functions.
%   dem_liftfilt - Demonstrates liffilt function capabilities.
%   dem_wlift_1 - Demo 1 for WLIFT.
%   dem_wlift_2 - Demo 2 for WLIFT.
%   dem_wlift_3 - Demo 3 for WLIFT.
%   demoliftwav - Demonstrates Lifting functions in the Wavelet Toolbox.
%   wlift_str_util - String utilities for lifting demos. 
%   make_wave    - Built Scaling function and Wavelet. 
%   view_dec     - Show Polyphase Matrix decompositions.
%
% demo_and_misc/misc directory
%=============================
%
% VARIOUS TESTS (some are which are also DEMOS)
%----------------------------------------------
%   t_lwt_1     - Test lifting decomposition and reconstruction (1-D).
%                 (TEST for functions LWT and ILWT).
%
%   t_lwt_2     - Test lifting decomposition and reconstruction (1-D).
%                 (TEST for the function LWTCOEF).
%
%   t_lwt_2bis  - Test lifting decomposition and reconstruction (1-D).
%                 (TEST for the function LWTCOEF).
%
%   t_lwt_3     - Test lifting decomposition and reconstruction (1-D).
%                 (GUI for thresholding).
%                 
%   t_lwt_4     - Test lifting decomposition and reconstruction (1-D).
%                 (GUI for thresholding).
%
%   t_lwt2_1    - Test lifting decomposition and reconstruction (2-D).
%                 (TEST for functions LWT2 and ILWT2).
%
%   t_lwt2_2    - Test lifting decomposition and reconstruction (2-D).
%                 (TEST for the function LWTCOEF2).
%
%   t_lwt2_3    - Test lifting decomposition and reconstruction (2-D).
%                 (GUI for thresholding).
%
%---------------
%   t_lwt_dwt_01 - Comparison between DWT and LWT (level 1).
%   t_lwt_dwt_db - Comparison between DWT and LWT (DB wavelets - level 1).
%   t_lwt_dwt_02 - Comparison between DWT and LWT coefficients (1-D).
%   t_lwt_dwt_03 - Comparison between DWT and LWT coefficients (2-D).
%---------------

% Last Revision: 12-Nov-2003
% Copyright 1995-2004 The MathWorks, Inc.
% Generated from Contents.m_template revision $Date: 2004/03/15 22:40:59 $
