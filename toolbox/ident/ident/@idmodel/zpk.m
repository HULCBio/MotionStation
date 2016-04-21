function model = zpk(idmodel,noi)
% IDMODEL/ZPK Transformation to the LTI/ZPK format
%
%   SYS = ZPK(MODEL)
%
%   MODEL is any IDMODEL object (IDPOLY, IDSS, IDARX, or IDGREY)
%   SYS is in the Control System Toolbox's LTI/ZPK object format.
%
%   The noise source-inputs (e) in MODEL will be labeled as an
%   InputGroup 'Noise', while the measured inputs are grouped as
%   'Measured'. The noise channels are first normalized so that
%   the noise inputs in SYS correspond to uncorrelated sources
%   with unit variances.
%
%   SYS = ZPK(MODEL('Measured')) or SYS = ZPK(MODEL,'M') ignores the noise inputs.
%
%   SYS = ZPK(MODEL('Noise')) gives a system of the transfer functions
%   from the noise sources (normalized as described above) to the outputs.
%
%   See also IDMODEL/ZPKDATA, IDMODEL/SS and LTI/ZPK.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2001/08/03 14:25:28 $
if nargin>1
model=zpk(ss(idmodel('m')));
else
    model = zpk(ss(idmodel));
end
