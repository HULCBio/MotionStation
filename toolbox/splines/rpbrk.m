function varargout = rpbrk(rp,varargin)
%RPBRK Part(s) of a rpform.
%
%   OUT1 = RPBRK(RP,PART)  returns the particular part specified by the string 
%   PART, which may be (the beginning character(s) of) one of the following 
%   strings: 
%      'breaks', 'coefficients', 'pieces' or 'l', 'order' or 'k', 
%      'dimension', 'interval'.
%
%   RPBRK(PP)  returns nothing, but prints all parts.
%
%   PJ = RPBRK(RP,J)  returns the rpform of the J-th polynomial piece of the 
%   function in RP.
%
%   PC = RPBRK(RP,[A B])  returns the restriction to the interval  [A .. B]  of 
%   the function in RP.
%
%   If RP contains an m-variate spline and PART is not a string, then it
%   must be a cell-array, of length m .
%
%   [OUT1,...,OUTo] = RPBRK(SP, PART1,...,PARTi)  returns in OUTj the part 
%   specified by the string PARTj, j=1:o, provided o<=i.
%
%   For example, if RP contains a bivariate spline with at least 4 pieces
%   in the first variable, then
%
%      rpp = rpbrk(rp,{4,[-1 1]});
%
%   gives the bivariate spline that agrees with the given one on the
%   rectangle  [rp.breaks{1}(4) .. [rp.breaks{1}(5)] x [-1 1] .
%
%   See also RPMAK, RSBRK, PPBRK, SPBRK, FNBRK.

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2003/04/25 21:12:05 $

if ~isstruct(rp)||~isequal(rp.form,'rp')
   error('SPLINES:RPBRK:unknownfn',...
   'The input does not seem to describe a function in rpform.')
end 

if nargin>1
   lp = max(1,nargout);
   if lp>length(varargin)
      error('SPLINES:RPBRK:moreoutthanin', ...
            'Too many output arguments for the given input.')
   end
   varargout = cell(1,lp);
   for jp=1:lp
      part = varargin{jp};
      if ischar(part)
         if isempty(part)
	    error('SPLINES:RPBRK:emptypart',...
	    'Part specification should not be an empty string.')
	 end
         switch part(1)
         case 'f',       out1 = [rp.form,'form'];
         case 'd',       out1 = rp.dim;
         case {'l','p'}, out1 = rp.pieces;
         case 'b',       out1 = rp.breaks;
         case {'o','k'}, out1 = rp.order;
         case 'c',       out1 = rp.coefs;
         case 'v',       out1 = length(rp.order);
         case 'i'
            if iscell(rp.breaks)
               for i=length(rp.order):-1:1
                  out1{i} = rp.breaks{i}([1 end]); end
            else
               out1 = rp.breaks([1 end]);
            end
         otherwise
            error('SPLINES:RPBRK:unknownpart',...
	    '''%s'' is not part of a rpform.',part)
         end
      else % we are to restrict RP to some interval or piece
         out1 = fn2fm(fnbrk(fn2fm(rp,'pp'),part),'rp');
      end
      varargout{jp} = out1;
   end    
else
   if nargout==0
      if iscell(rp.breaks) % we have a multivariate spline and, at present,
                           % I can't think of anything clever to do; so...
         disp(rp)
      else
        disp('breaks(1:l+1)'),        disp(rp.breaks)
        disp('coefficients((d+1)*l,k)'),  disp(rp.coefs)
        disp('pieces number l'),      disp(rp.pieces)
        disp('order k'),              disp(rp.order)
        disp('dimension d of target'),disp(rp.dim)
      end
   else
      error('SPLINES:RPBRK:toomanyouts','More output arguments than expected.')
   end
end
