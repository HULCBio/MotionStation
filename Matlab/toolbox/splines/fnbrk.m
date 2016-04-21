function varargout = fnbrk(fn,varargin)
%FNBRK Name or part(s) of a form.
%
%   FNBRK(FN,PART) returns the specified PART of the function in FN. 
%   For most choices of PART, this is some piece of information about the
%   function in FN. For some choices of PART, it is the form of some function
%   related to the function in FN.
%   If PART is a string, then only the beginning character(s) of the 
%   relevant string need be specified.
%
%   Regardless of the form of FN, PART may be 
%
%      'dimension'     for the dimension of the function's target
%      'variables'     for the dimension of the function's domain
%      'coefficients'  for the coefficients in the particular form
%      'interval'      for the basic interval of the function
%      'form'          for the form used to describe the function in FN 
%      [A B], with A and B scalars, for getting a description of the 
%                      univariate function in FN in the same form, but
%                      on the interval [A .. B], and with the basic interval
%                      changed to [A .. B]. For an m-variate function, this
%                      specification must be in the form of a cell-array
%                      with m entries of the form [A B].
%      []  returns FN unchanged (of use when FN is an m-variate function). 
%
%   Depending on the form of FN, additional parts may be asked for.
%
%   If FN is in B-form (or BBform, or rBform), then PART may also be
%
%      'knots'         for the knot sequence
%      'coefficients'  for the B-spline coefficients
%      'number'        for the number of coefficients
%      'order'         for the polynomial order of the spline
%
%   If FN is in ppform (or rpform), then PART may also be
%
%      'breaks'        for the break sequence   
%      'coefficients'  for the local polynomial coefficients
%      'pieces'        for the number of polynomial pieces
%      'order'         for the polynomial order of the spline
%      an integer, j,  for the ppform of the j-th polynomial piece
%
%   If FN is in stform, then PART may also be
%
%      'centers'       for the centers 
%      'coefficients'  for the coefficients
%      'number'        for the number of coefficients
%      'type'          for the type of stform
%
%   If FN contains an m-variate tensor-product spline with m>1 and 
%   PART is not a string, then it must be a cell-array, of length m .
%
%   [OUT1, ..., OUTo] = FNBRK(FN, PART1, ..., PARTi) returns, in OUTj, the part
%   requested by PARTj, j=1:o, provided o<=i. 
%
%   FNBRK(FN) returns nothing, but prints the 'form' along with all the parts
%   if available.
% 
%   Examples:
%
%      coefs = fnbrk( fn, 'coef' );
%
%   returns the coefficients (from its B-form or its ppform) of the spline
%   in fn.
%
%      p1 = fn2fm(spline(0:4,[0 1 0 -1 1]),'B-');
%      p2 = fnrfn(spmak(augknt([0 4],4),[-1 0 1 2]),2);
%      p1plusp2 = spmak( fnbrk(p1,'k'), fnbrk(p1,'c')+fnbrk(p2,'c') );
%
%   provides the (pointwise) sum of the two functions  p1  and  p2 , and this
%   works since they are both splines of the same order, with the same 
%   knot sequence, and the same target dimension.
%
%      x = 1:10; y = -2:2; [xx, yy] = ndgrid(x,y);
%      pp = csapi({x,y},sqrt((xx -4.5).^2+yy.^2));
%      ppp = fnbrk(pp,{4,[-1 1]});
%
%   gives the spline that agrees with the spline in pp on the rectangle 
%   [b4,b5] x [-1,1] , where b4, b5 are the 4th and 5th point in the 
%   break sequence for the first variable.
%
%   See also SPMAK, PPMAK, RSMAK, RPMAK, STMAK, SPBRK, PPBRK, RSBRK, RPBRK, STBRK.

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
%   $Revision: 1.21 $ 

if nargin>1
   np = max(1,nargout); % FNBRK(FN,PART) may be part of an expression
   if np <= length(varargin)
      varargout = cell(1,np);
   else
      error('SPLINES:FNBRK:moreoutthanin', ...
            'Too many output arguments for the given input.')
   end
end 

if ~isstruct(fn)    % this branch should eventually be abandoned
   switch fn(1)
   %
   % curves:
   %
      case 10, fnform = 'ppform, univariate, array format';
      case 11, fnform = 'B-form, univariate, array format';
      case 12, fnform = 'BBform, univariate, array format';
      case 15, fnform = 'polynomial in Newton form';
   %
   % surfaces:
   %
      case 20, fnform = 'ppform, bivariate tensor product, array format';
      case 21, fnform = 'B-form, bivariate tensor product, array format';
      case 22, fnform = 'BBform, bivariate, array format';
      case 24, fnform = 'polynomial in shifted power form, bivariate';
      case 25, fnform = 'thin-plate spline, bivariate';
   %
   % matrices:
   %
      case 40, fnform = 'almost block diagonal form';
      case 41, fnform = 'spline version of almost block diagonal form';
   % 42 = 'factorization of spline version of almost block diagonal form'
   %      (not yet implemented)
   
   %
   % multivariate:
   %
      case 94, fnform = ...
                  'polynomial in shifted normalized power form, multivariate';
      otherwise
         error('SPLINES:FNBRK:unknownform','Input is of unknown (function) form.')
   end
   
   if nargin>1 %  return some parts if possible
      switch fn(1)
      case 10, [varargout{:}] = ppbrk(fn,varargin{:});
      case {11,12}, [varargout{:}] = spbrk(fn,varargin{:});
      otherwise
         error('SPLINES:FNBRK:unknownpart',...
              ['Parts for ',fnform,' are not (yet) available.'])
      end
   else        % print available information
      if nargout
         error('SPLINES:FNBRK:partneeded','You need to specify a part to be returned.')
      else
         fprintf(['The input describes a ',fnform,'\n\n'])
         switch fn(1)
         case 10, ppbrk(fn);
         case {11,12}, spbrk(fn);
         otherwise
            fprintf(['Its parts are not (yet) available.\n'])
         end
      end
   end
   return
end   
 
     % we reach this point only if FN is a structure.
pre = fn.form(1:2);
switch pre
case {'pp','rp','st'}
case {'B-','BB'},     pre = 'sp';
case 'rB',            pre = 'rs';
otherwise
   error('SPLINES:FNBRK:unknownform','Input is of unknown (function) form.')
end

if nargin>1
   eval(['[varargout{:}] = ',pre,'brk(fn,varargin{:});'])
else
   if nargout
      error('SPLINES:FNBRK:partneeded','You need to specify a part to be returned.')
   else
      fprintf(['The input describes a ',fn.form(1:2),'form\n\n'])
      eval([pre,'brk(fn)'])
   end
end
