function h=sos(h,varargin)
%SOS  Quantized filter to second-order section form.
%   SOS(Hq) returns a quantized filter object with second-order-sections
%   that is converted from quantized filter object Hq.  The filter structure
%   does not change.
%
%   SOS(Hq, ...) takes the same optional arguments as TF2SOS, except that
%   the scaling option is only valid for Direct Form II (DF2) structures.
%
%   Example:
%     [A,B,C,D]=butter(8,.5);
%     Hq = qfilt('StateSpace',{A,B,C,D},'mode','single');
%     Hq1 = sos(Hq)
%
%   See also QFILT, QFILT/QFILT2TF, TF2SOS.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision $  $Date $

error(nargchk(1,3,nargin));
msgID = 'FILTERDESIGN:qfilt:sos';

filtstruct = filterstructure(h);
[bq,aq,br,ar] = qfilt2tf(h); %qfilt2tf multiplies through the scale values.

% Call tf2sos with two output args, so that proper scaling can be done
% Scaling is only supported for DF2.
if ~strcmp(filtstruct,'df2') && length(varargin) > 1, % Scaling specified
    warnmsg=sprintf(['Scaling option is ignored for ',filtstruct, ' filter structures.\n',...
            'Scaling is available only for the Direct Form II (DF2) structure.']);
    warning(msgID,warnmsg)
    varargin{2} = [];
end
[sos,g] = tf2sos(br,ar,varargin{:});

h.scalevalues = real(g);
s = sos2cell(sos);
coef = tf2filtstruct(filtstruct,s);
h = set(h,'referencecoefficients',coef);

function coef = tf2filtstruct(filtstruct,s)
coef = cell(1,length(s));
for k=1:length(s)
  switch filtstruct
    case {'df1','df1t','df2','df2t'}
      coef{k} = s{k};
    case {'fir','firt','symmetricfir','antisymmetricfir'}
      coef{k} = {s{k}{1}};
    case {'statespace'}
      [A,B,C,D] = tf2ss(s{k}{1},s{k}{2});
      coef{k} = {A,B,C,D};
    case {'latticema','latcmax','latticemaxphase'}
      lat = tf2latc(s{k}{1});
      coef{k} = {lat};
    case {'latticear','latcallpass','latticeallpass'}
      lat = tf2latc(1,s{k}{1});
      coef{k} = {lat};
    case {'latticearma'}
      [lat,lad] = tf2latc(s{k}{1},s{k}{2});
      coef{k} = {lat,lad};
    case {'latticeca', 'latticecapc'}
      [lat1,lat2,beta] = tf2cl(s{k}{1},s{k}{2});
      coef{k} = {lat1,lat2,beta};
  end
end
