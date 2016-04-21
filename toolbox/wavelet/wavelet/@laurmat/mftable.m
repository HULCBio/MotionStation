function MatFACT = mftable(M,flagNoControl)
%MFTABLE Matrix factorization table.
%   MatFACT = MFTABLE(M) returns the factorizations 
%   of the Laurent matrix M obtained via an euclidean
%   division algorithm. MATFACT is a cell array such 
%   that each cell contains a factorization of PM:
%      PM = prod(MatFACT{j}{:}) for every j.
%
%   Each "elementary factor" F = MatFACT{j}{k} is of one
%   of the two following form:
%
%            | 1     0 |            | 1     P |
%            |         |            |         |
%        F = |         |   or   F = |         |
%            |         |            |         |
%            | P     1 |            | 0     1 |
%
%   where P is a Laurent polynomial.
%
%   Example:
%      [Hs,Gs,Ha,Ga] = wave2lp('db2');
%      PM = ppm(Hs,Gs);
%      disp(PM);
%      MatFACT = mftable(PM);
%      displmf(MatFACT{1});

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 25-Apr-2001.
%   Last Revision 30-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/13 00:39:16 $ 

switch nargin
    case 1 , testTypeControl = 'mat';
    case 2 , testTypeControl = 'none';
end

E_H = M.Matrix{1,1};
O_H = M.Matrix{2,1};
len_E_H = length(lp2num(E_H));
R_E_H = mod(len_E_H,2);
differ_deg = degree(E_H)-degree(O_H);

MatFACT = {};
switch R_E_H
    case 0  % Even number of factors = length(FactorTAB) - 1
        if differ_deg >= 0
            [FactorTAB,minmaxTAB] = eucfacttab(E_H,O_H);
            MatFACT = makeMatFact(FactorTAB,M,testTypeControl);
        end
    case 1  % Odd number of factors = length(FactorTAB) - 1
        if differ_deg <= 0
            [FactorTAB,minmaxTAB] = eucfacttab(O_H,E_H);
            MatFACT = makeMatFact(FactorTAB,M,testTypeControl);
        end
end

%------------------------------------------------------%
% Number of Polynomial factors = length(FactorTAB) - 1 
% R_E_H = 0  <==>  Even number of factors.
% R_E_H = 1  <==>  Odd number of factors.
%------------------------------------------------------%

%========================================================================%
function MatFACT = makeMatFact(FactorTAB,M,testTypeControl)
%MAKEMATFACT Make matrix factorization.
%   MatFACT = MAKEMATFACT(FactorTAB,M,testTypeControl)
%   Computes all the factorizations for matrix M, using 
%   the array of factors FactorTAB.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 30-May-2003.
%   Last Revision: 21-Jun-2003.

MatFACT = {};
if isempty(FactorTAB) , return; end

% Initialization.
%----------------
lenFACT = size(FactorTAB,2);
remVAL  = mod(lenFACT-1,2);
idxFACT = 0;

% Suppress zeros factor.
%-----------------------
TMP_1 = laurmat(FactorTAB(:,1));
TMP_2 = laurmat(zeros(size(FactorTAB,1),1));
if TMP_1==TMP_2 
    FactorTAB(:,1) = [];
    remVAL = mod(lenFACT-1,2);
    disp(sprintf('NewREM = %3.0f ',remVAL));
    error('*** STOP ***')
end
clear TMP_1 TMP_2

% Compute factorizations.
%------------------------
for idx = 1:size(FactorTAB,1)
    FACT = FactorTAB(idx,:);
    C    = laurmat({FACT{end},0;0,1/FACT{end}});
    MF   = cell(1,lenFACT-1);
    for k = 1:lenFACT-1
        MF{k} = laurmat({1,FACT{k};0,1});
        if mod(k,2)==remVAL , MF{k} = MF{k}'; end        
    end
    [OK,R] = ControlFACT(MF,C,M,testTypeControl);
    if OK
        if ~isempty(R) , MF{end+1} = R; end
        MF{end+1} = C;
        idxFACT = idxFACT+1;
        MatFACT{idxFACT} = MF;	
    end
end

%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function [OK,R] = ControlFACT(MF,C,M,testTypeControl)

OK = 1;
R  = [];
switch testTypeControl
case 'none',
otherwise
    P0 = prod(MF{:}) * C;
    D  = M - P0;
    OK = (D.Matrix{1,1}==0 && D.Matrix{2,1}==0);
    switch testTypeControl
        case 'col' , R = [];
        case 'mat'
            
            D1 = euclideDIV(D.Matrix{1,2},M.Matrix{1,1});
            D2 = euclideDIV(D.Matrix{2,2},M.Matrix{2,1});
            for i=1:size(D1,1)
                M_D1 = laurmat(D1(i,:));
                for j=1:size(D2,1)
                    M_D2 = laurmat(D2(j,:));
                    OK = (M_D1==M_D2) && D1{i,2}==0;
                    if OK , break; end
                end
                if OK ,
                    S = D1{i,1}*(C.Matrix{1,1}*C.Matrix{1,1});
                    if S==0
                        R = [];
                    else
                        R = laurmat({1,S;0,1});
                    end
                    break; 
                end
            end
    end
end
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
%========================================================================%
