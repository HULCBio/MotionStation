function h = tunedmodel(Identifier)
%TUNEDMODEL  Constructor for tunable model object.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $ $Date: 2002/04/10 04:54:43 $

% Create class instance
h = sisodata.tunedmodel;
h.Identifier = Identifier;

L = handle.listener(h,findprop(h,'Format'),'PropertyPreSet',@LocalConvertGain);
L.CallbackTarget = h;
h.Listeners = L;

%-------------------------Listeners-------------------------


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalConvertGain %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalConvertGain(CompData,event)
% Updates gain magnitude when switching format
% RE: * Using PreSet because both old and new value needed
%     * Using  ZPK gain = FormatFactor * (formatted gain)
GainData = CompData.Gain;
if isempty(GainData)
   return
end
GF1 = formatfactor(CompData);                 % for old format
GF2 = formatfactor(CompData,event.NewValue);  % for new format
GF_Ratio = GF1/GF2;
GainData.Magnitude = GainData.Magnitude * abs(GF_Ratio);
GainData.Sign = GainData.Sign * sign(GF_Ratio);
CompData.Gain = GainData;