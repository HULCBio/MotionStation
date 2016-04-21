%LICENSE License number.
%   LICENSE returns the license number for this MATLAB.
%  
%   The license number is always returned as a string.
%
%   This function is not guaranteed to return a number.  It may return
%   the string 'demo' for demo licenses,'student' for student licenses,
%   or 'unknown' if the license number cannot be determined.
%
%   LICENSE('inuse') displays the list of licenses checked out in
%   the current MATLAB session. 
%     
%   STRUCT = LICENSE('inuse') returns a structure that contains the
%   list of licenses checked out in the current MATLAB session and 
%   the username of the person who checked out the license.  
%
%   When used with the MATLAB Runtime Server, the 'inuse' option 
%   displays nothing or returns an empty structure.
%
%   LICENSE('test', FEATURE) tests if a license for the
%   product, FEATURE, exists. LICENSE returns 1 if the license
%   exists and 0 if the license does not exist.
%
%   The FEATURE string must be the exact feature name used to
%   identify the product in a License File.  For example,
%   'Identification_Toolbox' is the feature name for
%   the System Identification Toolbox. The FEATURE string
%   must not exceed 27 characters and is case-insensitive. 
%
%   Note: Testing for a license only confirms that the license
%   exists. It does not confirm that the license can be checked
%   out. If the license has expired or if a system administrator
%   has excluded you from using the product in an options file,
%   LICENSE will still return 1, if the license exists. 
% 
%   LICENSE('test', FEATURE, TOGGLE) enables or disables 
%   testing of the product, FEATURE, depending on the value of TOGGLE.
%   If TOGGLE is set to 'enable', LICENSE returns 1 if the product 
%   license exists and 0 if the product license does not exist. 
%   If TOGGLE is set to 'disable', LICENSE always returns 0 (license 
%   does not exist) for a test of this feature. 
%   
%   Note: Disabling a test for a particular product can impact
%   all other tests for the existence of the license, not just
%   tests performed using the LICENSE command.  

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.2 $  $Date: 2004/04/25 21:35:29 $
%   Built-in function.


