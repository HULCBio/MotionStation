function [supported, encapsulated, name] = dicom_supported_txfr_syntax(txfr_uid)
%DICOM_SUPPORTED_TXFR_SYNTAX  Determine if a transfer syntax is supported.
%   [TF, ENCAP, NAME] = DICOM_SUPPORTED_TXFR_SYNTAX(UID) uses the unique
%   identifier UID of transfer syntax NAME to see if it is supported.  If
%   UID is supported TF has a value of 1; TF will be 0 otherwise.  ENCAP
%   is 1 if the syntax is used for uncapsulated data, which is usually
%   compressed.
%
%   If UID belongs to an unknown transfer syntax, TF is 0 and ENCAP is 1,
%   as all native transfer syntaxes are specified.
%
%   See also DICOM_UID_DECODE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2003/08/23 05:54:00 $


% Get details about the syntax.
uid = dicom_uid_decode(txfr_uid);
    
switch (txfr_uid)
case {'1.2.840.10008.1.2'}
    
    % Default syntax.  All applications must support it.
    supported = 1;
    encapsulated = 0;
    name = uid.Name;
    
    
case {'1.2.840.10008.1.2.1'
      '1.2.840.10008.1.2.2'
      '1.2.840.113619.5.2'}
    
    % Other uncompressed formats.
    supported = 1;
    encapsulated = 0;
    name = uid.Name;
    
case {'1.2.840.10008.1.2.5'}

    % RLE.
    supported = 1;
    encapsulated = 1;
    name = uid.Name;

case {'1.2.840.10008.1.2.4.57'
      '1.2.840.10008.1.2.4.65'
      '1.2.840.10008.1.2.4.70'}

    % JPEG lossless syntaxes.
    supported = 1;
    encapsulated = 1;
    name = uid.Name;
    
case {'1.2.840.10008.1.2.4.50'
      '1.2.840.10008.1.2.4.51'
      '1.2.840.10008.1.2.4.53'
      '1.2.840.10008.1.2.4.55'
      '1.2.840.10008.1.2.4.59'
      '1.2.840.10008.1.2.4.61'
      '1.2.840.10008.1.2.4.63'}
    
    % JPEG lossy syntaxes.
    supported = 1;
    encapsulated = 1;
    name = uid.Name;
    
case {'1.2.840.10008.1.2.4.52'
      '1.2.840.10008.1.2.4.54'
      '1.2.840.10008.1.2.4.56'
      '1.2.840.10008.1.2.4.58'
      '1.2.840.10008.1.2.4.60'
      '1.2.840.10008.1.2.4.62'
      '1.2.840.10008.1.2.4.64'
      '1.2.840.10008.1.2.4.66'}
 
    % JPEG lossy syntaxes with arithmetic coding.
    supported = 0;
    encapsulated = 1;
    name = uid.Name;
    
otherwise
    
    % Some other transfer syntax.  Unsupported.
    supported = 0;
    encapsulated = 1;

    if (~isempty(uid))
        
        name = uid.Name;
        
    else
        
        name = txfr_uid;
        
    end
    
end
