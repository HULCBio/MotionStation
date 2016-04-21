function icclab = cielab2icclab(cielab)
%CIELAB2ICCLAB Convert CIELab values to ICCLab values.
%   ICCLAB = CIELAB2ICCLAB(CIELAB) converts 8-bit or 16-bit CIELab
%   encoded L*a*b* colors to 8-bit or 16-bit ICCLab encoded L*a*b*
%   colors.  Note that the CIELab input values are as read by RTIFC,
%   which reads the signed 8-bit or 16-bit a* and b* values into a uint8
%   or uint16 array.  CIELAB is an M-by-N-by-3 or M-by-N-by-1 array of
%   class uint8 or uint16, and ICCLAB has the same size and class.  If
%   CIELAB is M-by-N-by-1, it is assumed to contain only L* values.
%
%   8-bit CIELab encoding
%   ---------------------
%   The L* component is encoded as an unsigned integer in the range
%   [0,255].  The a* and b* components are encoded as signed integers in
%   the range [-128,127].  RTIFC, however, reads these signed integers
%   in as unsigned integers, so values in the range [-128,-1] appear to
%   be in the range [128,255].
%
%   16-bit CIELab encoding
%   ----------------------
%   The L* component is encoded as an unsigned integer in the range
%   [0,65535].  The a* and b* components are encoded as signed integers
%   in the range [-32768,32767].  The 16-bit encoded values for a* and b*
%   are 256 times the 1976 CIE a* and b* values.  RTIFC, however, reads
%   these signed integers in as unsigned integers, so values in the range
%   [-32768,-1] appear to be in the range [32768,65535].
%
%   8-bit ICCLab encoding
%   ---------------------
%   The L* component is encoded as an unsigned integer in the range
%   [0,255].  The a* and b* components are encoded as unsigned integers
%   in the range [0,255], and they equal the 1976 CIE a* and b* values
%   plus 128.
%
%   16-bit ICCLab encoding
%   ----------------------
%   The L* component is encoded as an unsigned integer in the range
%   [0,65280].  The a* and b* components are encoded as unsigned integers
%   in the range [0,65535], and they equal 256 times the 1976 CIE a* and
%   b* values plus 32768.
%
%   Reference
%   ---------
%   "Adobe Photoshop TIFF Technical Notes," March 22, 2002, page 12,
%   www.adobe.com.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:51 $

icclab = cielab;

if isa(icclab, 'uint16')
    % Fix L* values.
    icclab(:,:,1) = icclab(:,:,1) * (65280/65535);

    % How much to shift the a* and b* values.
    shift_value = 32768;
else
    shift_value = 128;
end

if size(icclab,3) > 1
    % Fix a* and b* values.
    ab = icclab(:,:,[2 3]);
    
    % Shift low values up.
    mask = ab <= (shift_value - 1);
    ab(mask) = ab(mask) + shift_value;

    % Shift high values down.
    mask = ~mask;
    ab(mask) = ab(mask) - shift_value;
    
    icclab(:,:,[2 3]) = ab;
end

