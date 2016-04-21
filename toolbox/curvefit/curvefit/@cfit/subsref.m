function out = subsref(obj, subs)
%SUBSREF Evaluate CFIT object.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.5.2.2 $  $Date: 2004/02/01 21:41:00 $

if (isempty(obj.fittype))
   error('curvefit:cfit:subsref:emptyFit', 'Can''t call an empty FIT.');
end

% In case nested subsref like f.p.coefs
currsubs = subs(1);

switch currsubs.type
case '()'
   inputs = currsubs.subs;
   if (length(inputs) < 1)
      error('curvefit:cfit:subsref:notEnoughInputs',... 
            'Not enough inputs to CFIT/SUBSREF.');
   elseif (length(inputs) > 1)
      error('curvefit:cfit:subsref:tooManyInputs', ...
            'Too many inputs to CFIT/SUBSREF.');
   end
   
   if (isempty(fevalexpr(obj.fittype)))
      out = [];
   else
      try
         out= feval(obj,inputs{:});
      catch
         error('curvefit:cfit:subsref:cannotEvaluateModel', ...
               'Cannot evaluate CFIT model for some reason.')   
      end
   end
case '.'
   argname = currsubs.subs;
   % is it coeff or prob parameter?
   coeff = strmatch(argname,coeffnames(obj.fittype),'exact');
   prob = strmatch(argname,probnames(obj.fittype),'exact');
   % which index is it?
   if ~isempty(coeff) && isempty(prob)
      k = coeff;
      out = obj.coeffValues{k};
   elseif isempty(coeff) && ~isempty(prob)
      k = prob;
      out = obj.probValues{k};
   elseif ~isempty(coeff) && ~isempty(prob)
      error('curvefit:cfit:subsref:ambiguousName', ...
            'Name is both coeff and prob parameter.')
   else
      % maybe this should return out = [] ??
      error('curvefit:cfit:subsref:noCoeffOrProb', ...
            'Name is neither coeff or prob parameter.')
   end
   
otherwise % case '{}'
   error('curvefit:cfit:subsref:cellarrayBracketsNotAllowed', ...
         'Cannot use cellarray brackets with FIT.')
end

if length(subs) > 1
    subs(1) = [];
    out = subsref(out, subs); 
end
    

