function varargout = lp2ls(Hs,Gs,factMode,tolerance)
%LP2LS Laurent polynomial to lifting schemes.
%   LS = LP2LS(HS,GS,FACTMODE) returns the lifting scheme or 
%   the cell array of lifting schemes LS associated to the 
%   Laurent polynomials HS and GS. FACTMODE indicates the 
%   type of factorization from which LS is issued. The valid
%   values for FACTMODE are: 
%     'd' (dual factorization) or 'p' (primal factorization).
%
%   LS = LP2LS(HS,GS) is equivalent to LS = LP2LS(HS,GS,'d').
%
%   [LS_d,LS_p] = LP2LS(HS,GS,'t') or LS_All = LP2LS(HS,GS,'t')
%   returns the lifting schemes obtained from both factorization.
%
%   In addition, ... = LP2LS(...,TOLERANCE) performs a control
%   about lifting scheme(s) reconstruction property using the
%   tolerance value TOLERANCE. The default value for TOLERANCE
%   is 1.E-8.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 24-Jun-2003.
%   Last Revision: 27-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2004/03/15 22:36:36 $ 

% Check input arguments.
switch nargin
    case 2 , tolerance = 1.E-8; factMode = 'd';
    case 3 , tolerance = 1.E-8;
end
factMode = lower(factMode(1));

% Synthesis Polyphase Matrix factorizations
[MatFACT,PolyMAT] = ppmfact(Hs,Gs);
nbFACT = length(MatFACT);

% Compute lifting schemes. 
if nbFACT>0
    switch factMode
        case 't' ,
            % Compute Analyzis Polyphase Matrix Factorizations.
            [dual_APMF,prim_APMF] = pmf2apmf(MatFACT,factMode);

            % Compute Lifting Steps.
            dual_LS = apmf2ls(dual_APMF);
            prim_LS = apmf2ls(prim_APMF);
            
            % Control of the factorizations.
            [dual_errTAB,dual_errFlags] = errlsdec(dual_LS,tolerance);
            [prim_errTAB,prim_errFlags] = errlsdec(prim_LS,tolerance);
            dual_LS = dual_LS(dual_errFlags);
            prim_LS = prim_LS(prim_errFlags);
            switch nargout
                case 1 , varargout{1} = {dual_LS{:} , prim_LS{:}};
                case 2 , varargout = {dual_LS , prim_LS};
            end
           
        case {'d','p'} ,  % dual_LS or prim_LS
            % Compute Lifting Steps.
            APMF = pmf2apmf(MatFACT,factMode);
            LS = apmf2ls(APMF);
            
            % Control of the factorizations.
            [errTAB,errFlags] = errlsdec(LS,tolerance);
            LS = LS(errFlags);
            varargout = LS;
            
        otherwise
            error('Invalid value for factorization mode.')
    end
else
    varargout = cell(1,nargout);
end
