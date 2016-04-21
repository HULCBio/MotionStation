function [apiver,ccsver] = p_supportedApiVersions
% P_SUPPORTEDAPIVERSIONS (Private) Returns the CCS API versions
% currently supported by the "Link for CCS" product.
%   Example:
%     >> [apiver,ccsver] = p_supportedApiVersions
%     apiver =
%          1     2
%          1    31
%     ---> supported API versions are 1.2 and 1.31
%     ccsver = 
%          [2.0000    2.1000    2.1200]
%          [                    2.2100]
%     ---> API version 1.2 corresponds to CCS 2.0, 2.1, 2.12 
%     ---> API version 1.31 corresponds to CCS 2.21 

%   Copyright 2004 The MathWorks, Inc.

% API-CCS version info:
%   API version 1.2  - CCS 2.0, CCS 2.1, CCS 2.12
%   API version 1.3  - CCS 2.2 
%   API version 1.31 - CCS 2.21, CCS 2.3(*nr)
%   API version 1.40 - CCS 3.0, CCS 3.01(*nr)
% *nr = not released yet
% Note: 1.40 is NOT the same as 1.4 (1.4 = 1.04).  TI started using two
% digit minor version at CCS 2.21. 

apiver = [    1 2  ; ...
              1 3  ; ...
              1 31 ; ...
         ];

ccsver = {  [2.0, 2.1, 2.12]  ; ...
            [2.2]  ; ...
            [2.21] ; ...
         };

% [EOF] p_supportedApiVersions.m