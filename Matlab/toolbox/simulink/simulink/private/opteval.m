function [f,g,msg] = opteval(x,FUNfcns,varargin)
%OPTEVAL Evaluate user functions from NLCONST and related functions.
%   [F,G,MSG] = OPTEVAL(X,FUNfcns,VARARGIN) takes the cell array
%   (created with PREFCNCHK) and evaluates its functions at X, VARARGIN.
%   The results are returned in F and G with error messages put in MSG.
%   Several different syntaxes have to be supported depending on what the
%   caller type is (FUNfcns{4}).  The caller type is the name of the 
%   function that calls SIMCNSTR.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $
%   Mary Ann Branch 9-1-96


f=[];
g=[];
msg='';

switch FUNfcns{4}
  case {'trim','ncdtoolbox'}  
    if FUNfcns{3} == 1
      [f,g]=feval(FUNfcns{1},x,varargin{:});
    elseif FUNfcns{3} == 2
      f = feval(FUNfcns{1},x,varargin{:});
      if ~isempty(FUNfcns{2})
        g = feval(FUNfcns{2},x,varargin{:});
      end  % else leave g=[].
    end
  otherwise
    msg = ('Calling function not known.');
end
