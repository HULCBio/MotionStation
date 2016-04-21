function obj = subsasgn(obj, subs, value)
%SUBSASGN    subsasgn of cfit objects

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.5.2.2 $  $Date: 2004/02/01 21:40:59 $

if (isempty(obj.fittype))
   error('curvefit:cfit:subsasgn:emptyFit', ...
         'Can''t assign to an empty FIT.');
end

% In case nested subsref like f.p.coefs
currsubs = subs(1);

if length(subs) > 1
    subs(1) = [];
    value = subsasgn(subsref(obj,currsubs), subs, value); 
end

switch currsubs.type
case '.'
   argname = currsubs.subs;
   % is it coeff or prob parameter?
   coeff = strmatch(argname,coeffnames(obj.fittype),'exact');
   prob = strmatch(argname,probnames(obj.fittype),'exact');
   % which index is it?
   if ~isempty(coeff) && isempty(prob)
      k = coeff;
      obj.coeffValues{k} = value;
   elseif isempty(coeff) && ~isempty(prob)
      k = prob;
      obj.probValues{k} = value;
   elseif ~isempty(coeff) && ~isempty(prob)
      error('curvefit:cfit:subsasgn:ambiguousName', ...
            'Name is both coeff and prob parameter.')
   else
      % maybe this should return out = [] ??
      error('curvefit:cfit:subsasgn:invalidName', ...
            'Name is neither coeff or prob parameter.')
   end

   % Uncertainty information is no longer valid
   if ~isempty(obj.sse) && ~isempty(obj.dfe) && ~isempty(obj.rinv)
      obj.sse = [];
      obj.dfe = [];
      obj.rinv = [];
      if ~isempty(coeff)
         warning('curvefit:cfit:subsasgn:coeffsClearingConfBounds',...
          'Setting coefficient values clears confidence bounds information.');
      else
         warning('curvefit:cfit:subsasgn:paramsClearingConfBounds',...
           'Setting parameter values clears confidence bounds information.');
      end
   end
   
otherwise % case '{}', case '()'
   error('curvefit:cfit:subsasgn:dotNotationRequired', ...
         'Cannot use cellarray brackets or parens to assign to FIT.')
end




