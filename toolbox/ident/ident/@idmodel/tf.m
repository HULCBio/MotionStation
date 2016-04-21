function model = tf(idmodel,noi)
% IDMODEL/TF Transformation to the LTI/TF format
%
%   SYS = TF(MODEL)
%
%   MODEL is any IDMODEL object (IDPOLY, IDSS, IDARX, or IDGREY)
%   SYS is in the Control System Toolbox's LTI/TF object format.
%
%   The noise source-inputs (e) in MODEL will be labeled as an
%   InputGroup 'Noise', while the measured inputs are grouped as
%   'Measured'. The noise channels are first normalized so that
%   the noise inputs in SYS correspond to uncorrelated sources
%   with unit variances.
%
%   SYS = TF(MODEL('Measured')) or SYS = TF(MODEL,'m') ignores the noise inputs.
%
%   SYS = TF(MODEL('Noise')) gives a system of the transfer functions
%   from the noise sources (normalized as described above) to the outputs.
%
%   See also TF and IDMODEL/SS

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2001/08/03 14:25:25 $

if nargin<2
    model = tf(ss(idmodel));
else
    model=tf(ss(idmodel('m')));
end
