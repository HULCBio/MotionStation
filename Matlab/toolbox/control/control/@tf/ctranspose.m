function tsys = ctranspose(sys)
%CTRANSPOSE  Pertransposition of transfer functions.
%
%   TSYS = CTRANSPOSE(SYS) is invoked by TSYS = SYS'
%
%   If SYS represents the continuous-time transfer function
%   H(s), TSYS represents its pertranspose H(-s).' .   In 
%   discrete time, TSYS represents H(1/z).' if SYS represents 
%   H(z).
%
%   See also TRANSPOSE, TF, LTIMODELS.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 06:08:17 $

% Extract data
num = sys.num;
den = sys.den;
if isempty(num),
   tsys = sys.';  return
end

sizes = size(num);
sizes([1 2]) = sizes([2 1]);
Ts = getst(sys.lti);

% Variable change s->-s or z->1/z
if Ts==0,
   % Continuous-time case: replace s by -s
   for k=1:prod(sizes),
      num{k}(2:2:end) = -num{k}(2:2:end);
      den{k}(2:2:end) = -den{k}(2:2:end);
      num{k} = conj(num{k});
      den{k} = conj(den{k});
   end
else
   % Discrete-time case: replace z by z^-1
   for k=1:prod(sizes),
      num{k} = conj(fliplr(num{k}));
      den{k} = conj(fliplr(den{k}));
   end
end

% Transposition
tsys = sys;
tsys.num = permute(num,[2 1 3:length(sizes)]);
tsys.den = permute(den,[2 1 3:length(sizes)]);
tsys.lti = (sys.lti)';
