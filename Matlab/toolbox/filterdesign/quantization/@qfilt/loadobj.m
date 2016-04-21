function Hq = loadobj(h)
%LOADOBJ Load filter for objects.
%   B = LOADOBJ(A) is called by LOAD when an object is loaded from a .MAT
%   file. The return value B is subsequently used by LOAD to populate the
%   workspace.  LOADOBJ can be used to convert one object type into
%   another, to update an object to match a new object definition, or to
%   restore an object that maintains information outside of the object
%   array.
%
%   If the input object does not match the current definition (as defined
%   by the constructor function), the input will be a struct-ized version
%   of the object in the .MAT file.  All the information in the original
%   object will be available for use in the conversion process.
%
%   LOADOBJ will be separately invoked for each object in the .MAT file.
%
%   See also LOAD, SAVEOBJ.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/14 15:31:33 $

if isa(h,'qfilt')
  Hq = h;
  return
end

% Create default qfilt object with up-to-date properties
Hq = qfilt;

switch h.version
  case 1
    % R11.1 version
    % Copy all data from version 1 object h to Hq
    warn = warning;
    warning('off');
    Hq = set(Hq,'filterstructure',h.base.FilterStructure.Value, ...
        'referencecoefficients',h.base.ReferenceCoefficients.Value, ...
        'mode',h.base.Mode.Value, ...
        'optimizeunitygains',h.base.OptimizeUnityGains.Value, ...
        'scalevalues',h.base.ScaleValues.Value);
    switch h.base.Mode.Value
      case 'fixed'
        Hq = set(Hq,'overflowmode',h.fixed.OverflowMode.Value, ...
            'roundmode',h.fixed.RoundMode.Value, ...
            'coefficientformat',h.fixed.CoefficientFormat.Value, ...
            'inputformat',h.fixed.InputFormat.Value, ...
            'outputformat',h.fixed.OutputFormat.Value, ...
            'multiplicandformat',h.fixed.OutputFormat.Value, ...  % Not in R11.1
            'productformat',h.fixed.ProductFormat.Value, ...
            'sumformat',h.fixed.SumFormat.Value);
      case 'float'
        Hq = set(Hq,'overflowmode',h.float.OverflowMode.Value, ...
            'roundmode',h.float.RoundMode.Value, ...
            'coefficientformat',h.float.CoefficientFormat.Value, ...
            'inputformat',h.float.InputFormat.Value, ...
            'outputformat',h.float.OutputFormat.Value, ...
            'multiplicandformat',h.float.OutputFormat.Value, ... % Not in R11.1
            'productformat',h.float.ProductFormat.Value, ...
            'sumformat',h.float.SumFormat.Value);
      case 'double'
        Hq = set(Hq,'overflowmode',h.double.OverflowMode.Value, ...
            'roundmode',h.double.RoundMode.Value, ...
            'coefficientformat',h.double.CoefficientFormat.Value, ...
            'inputformat',h.double.InputFormat.Value, ...
            'outputformat',h.double.OutputFormat.Value, ...
            'multiplicandformat',h.double.OutputFormat.Value, ... % Not in R11.1
            'productformat',h.double.ProductFormat.Value, ...
            'sumformat',h.double.SumFormat.Value);
      case 'single'
        Hq = set(Hq,'overflowmode',h.single.OverflowMode.Value, ...
            'roundmode',h.single.RoundMode.Value, ...
            'coefficientformat',h.single.CoefficientFormat.Value, ...
            'inputformat',h.single.InputFormat.Value, ...
            'outputformat',h.single.OutputFormat.Value, ...
            'multiplicandformat',h.single.OutputFormat.Value, ... % Not in R11.1
            'productformat',h.single.ProductFormat.Value, ...
            'sumformat',h.single.SumFormat.Value);
    end
    warning(warn)
  case 2
    % R12 version
    % Replace the states of Java quantizers with Java quantizers.
    Hq.coefficientformat = qfiltloadobj(h.coefficientformat);
    Hq.inputformat = qfiltloadobj(h.inputformat);
    Hq.outputformat = qfiltloadobj(h.outputformat);
    Hq.multiplicandformat = qfiltloadobj(h.multiplicandformat);
    Hq.productformat = qfiltloadobj(h.productformat);
    Hq.sumformat = qfiltloadobj(h.sumformat);
  otherwise 
    % If nothing else can be done, return the structure that was saved.
    warning('Unrecognized QUANTIZER version.  Returning saved structure.')
    Hq = h;
end
