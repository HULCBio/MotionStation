% Fuzzy Logic Toolbox
% Version 2.1.3 (R14) 05-May-2004
%
% GUI editors
%   anfisedit  - ANFIS training and testing UI tool.
%   findcluster- Clustering UI tool.
%   fuzzy      - Basic FIS editor.
%   mfedit     - Membership function editor.
%   ruleedit   - Rule editor and parser.
%   ruleview   - Rule viewer and fuzzy inference diagram.
%   surfview   - Output surface viewer.
%
% Membership functions.
%   dsigmf     - Difference of two sigmoid membership functions.
%   gauss2mf   - Two-sided Gaussian curve membership function.
%   gaussmf    - Gaussian curve membership function.
%   gbellmf    - Generalized bell curve membership function.
%   pimf       - Pi-shaped curve membership function.
%   psigmf     - Product of two sigmoid membership functions.
%   smf        - S-shaped curve membership function.
%   sigmf      - Sigmoid curve membership function.
%   trapmf     - Trapezoidal membership function.
%   trimf      - Triangular membership function.
%   zmf        - Z-shaped curve membership function.
%
% Command line FIS functions
%   addmf      - Add membership function to FIS
%   addrule    - Add rule to FIS.
%   addvar     - Add variable to FIS.
%   defuzz     - Defuzzify membership function.
%   evalfis    - Perform fuzzy inference calculation.
%   evalmf     - Generic membership function evaluation.
%   gensurf    - Generate FIS output surface.
%   getfis     - Get fuzzy system properties.
%   mf2mf      - Translate parameters between functions.
%   newfis     - Create new FIS.
%   parsrule   - Parse fuzzy rules.
%   plotfis    - Display FIS input-output diagram.
%   plotmf     - Display all membership functions for one variable.
%   readfis    - Load FIS from disk.
%   rmmf       - Remove membership function from FIS.
%   rmvar      - Remove variable from FIS.
%   setfis     - Set fuzzy system properties.
%   showfis    - Display annotated FIS.
%   showrule   - Display FIS rules.
%   writefis   - Save FIS to disk.
%
% Advanced techniques
%   anfis      - Training routine for Sugeno-type FIS (MEX only).
%   fcm        - Find clusters with fuzzy c-means clustering.
%   genfis1    - Generate FIS matrix using generic method.
%   genfis2    - Generate FIS matrix using subtractive clustering.
%   subclust   - Estimate cluster centers with subtractive clustering.
%
% Miscellaneous functions
%   convertfis - Convert v1.0 fuzzy matrix to v2.0 fuzzy structure.
%   discfis    - Discretize a fuzzy inference system.
%   evalmmf    - For multiple membership functions evaluation.
%   fstrvcat   - Concatenate matrices of varying size.
%   fuzarith   - Fuzzy arithmatic function.
%   findrow    - Find the rows of a matrix that match the input string.
%   genparam   - Generates initial premise parameters for ANFIS learning.
%   probor     - Probabilistic OR.
%   sugmax     - Maximum output range for a Sugeno system.
%
% GUI helper files
%   cmfdlg     - Add customized membership function dialog.
%   cmthdlg    - Add customized inference method dialog.
%   fisgui     - Generic GUI handling for the Fuzzy Logic Toolbox
%   gfmfdlg    - Generate fis using grid partition method dialog.
%   mfdlg      - Add membership function dialog.
%   mfdrag     - Drag membership functions using mouse.
%   popundo    - Pull the last change off the undo stack.
%   pushundo   - Push the current FIS data onto the undo stack.
%   savedlg    - Save before closing dialog.
%   statmsg    - Display messages in a status field.
%   updtfis    - Update Fuzzy Logic Toolbox GUI tools.
%   wsdlg      - Open from/save to workspace dialog.

%   other functions 
%   anfismex.m  
%   anfiscb.m	
%   anfisintf.m 
%   combine.m      
%   distfcm.m		 
%   evalfis1.m	
%   fisgui.m	
%   fuzblock.mdl   
%   initfcm.m      
%   mam2sug.m      
%   nwfisdlg.m     
%   para2fis.m		      
%   setfis2.m      
%   sffis.m 	    
%   slblocks.m  
%   stepfcm.m      
%   strtchmf.m     
%   tri2mf.m       
%   trndtdlg.m     

%   Copyright 1994-2004 The MathWorks, Inc.


