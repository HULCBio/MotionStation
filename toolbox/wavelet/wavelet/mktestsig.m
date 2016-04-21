function mktestsig(numEX)
%MKTESTSIG Make signal for test.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Mar-2003.
%   Last Revision: 11-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/03/15 22:41:18 $ 

switch numEX
    case 1
        load ptpssin1
        nbFormeBASE = 8; scaleBASE = 8; rapport = 2; PONDERATIONS =  [1,1];
        signalBASE = getSignal('translate',Y,rapport,PONDERATIONS,nbFormeBASE);
        testsig1 = signalBASE;
        save testsig5 testsig5 scaleBASE
        
    case 6
        load ptpssin2
        nbFormeBASE = 8; scaleBASE = 8; rapport = 2; PONDERATIONS =  [1,1];
        signalBASE = getSignal('translate',Y,rapport,PONDERATIONS,nbFormeBASE);
        testsig6 = signalBASE;
        save testsig6 testsig6 scaleBASE
        
    case 1
        pat1 = 'ptpssin1';
        eval(['load ' pat1]);
        pat1 = Y;
        load pthaar
        pat2 = Y;
        load ptodpoly
        pat3 = Y;
        pattern=struct('pat1',pat1,'pat2',pat2,'pat3',pat3);
        
        % Translated
        nbFormeBASE = 8; scaleBASE = 8; 
        rapports = [2,2]; PONDERATIONS =  [1,1/2,2];
        signalBASE = getSignal('translate',pattern,rapports,PONDERATIONS,nbFormeBASE);
        testsig1 = signalBASE;
        save testsig1 testsig1 scaleBASE 
        
%     case 2
%         pat1 = 'ptpssin1';
%         eval(['load ' pat1]);
%         pat1 = Y;
%         load pthaar
%         pat2 = Y;
%         pattern=struct('pat1',pat1,'pat2',pat2);
%         
%         % Superimposed
%         nbFormeBASE = 3; scaleBASE = 32; 
%         rapports = [4,4]; PONDERATIONS =  [1,1/2];
%         signalBASE = getSignal('superpose',pattern,rapports,PONDERATIONS,nbFormeBASE);
%         tstsig1s = signalBASE;
%         save tstsig1s tstsig1s scaleBASE
        
    case 3
        pat1 = 'ptodtri';
        eval(['load ' pat1]);
        pat1 = Y;
        load pthaar
        pat2 = Y;
        load ptsinpol
        pat3 = Y;
        pattern=struct('pat1',pat1,'pat2',pat2,'pat3',pat3);
        
        % Translated
        nbFormeBASE = 8; scaleBASE = 8; 
        rapports = [2,2]; PONDERATIONS =  [1,3/8,1/4];
        signalBASE = getSignal('translate',pattern,rapports,PONDERATIONS,nbFormeBASE);
        testsig3 = signalBASE;
        save testsig3 testsig3 scaleBASE
        
    case 4
        load ptodlin
        pat1 = Y;
        load pthaar
        pat2 = Y;
        load ptsumsin
        pat3 = Y;
        pattern=struct('pat1',pat1,'pat2',pat2,'pat3',pat3);
        
        % Translated
        nbFormeBASE = 8; scaleBASE = 8; 
        rapports = [2,2]; PONDERATIONS =  [1,1/2,5/8];
        signalBASE = getSignal('translate',pattern,rapports,PONDERATIONS,nbFormeBASE);
        testsig4 = signalBASE;
        save testsig4 testsig4 scaleBASE
end

function signalBASE = getSignal(typeSIG,FormeBASE,rapport,PONDERATIONS,nbFormeBASE)
Forme_1 = FormeBASE;
len_F1  = length(Forme_1);
x_new   = linspace(0,1,len_F1/rapport);
x_old   = linspace(0,1,len_F1);        
Forme_2 = (rapport^0.5)*interp1(x_old,Forme_1,x_new);
len_F2  = length(Forme_2);
Forme_1 = PONDERATIONS(1)*Forme_1;
Forme_2 = PONDERATIONS(2)*Forme_2;
signalBASE = zeros(1,nbFormeBASE*len_F1);
switch typeSIG
	case 'superpose'
        deb = floor((nbFormeBASE-1)*len_F1/2)+1-64; fin = deb + len_F1-1;
        signalBASE(deb:fin) = Forme_1;
        deb = deb + floor((len_F1-len_F2)/2); fin = deb + len_F2-1;
        signalBASE(deb:fin) = signalBASE(deb:fin) + Forme_2;

	case 'translate'
        deb = floor(2*len_F1); fin = deb + len_F1-1;
        signalBASE(deb:fin) = Forme_1;
        deb = floor(6*len_F1-len_F2/2-256); fin = deb + len_F2-1;
        signalBASE(deb:fin) = signalBASE(deb:fin) + Forme_2;
end
%-------------------------------------------------------------------------
        
% %==========================================================================
% function signalBASE = getSignal(typeSIG,pattern,rapports,PONDERATIONS,nbFormeBASE)
% Forme_1 = pattern.pat1;
% len_F1  = length(Forme_1);
% x_new   = linspace(0,1,len_F1/rapports(1));
% x_old   = linspace(0,1,len_F1);
% Forme_2 = (rapports(1)^0.5)*interp1(x_old,pattern.pat2,x_new);
% len_F2  = length(Forme_2);
% x_new   = linspace(0,1,len_F1/rapports(2));
% x_old   = linspace(0,1,len_F1);
% Forme_3 = (rapports(2)^0.5)*interp1(x_old,pattern.pat3,x_new);
% len_F3  = length(Forme_3);
% Forme_1 = PONDERATIONS(1)*Forme_1;
% Forme_2 = PONDERATIONS(2)*Forme_2;
% Forme_3 = PONDERATIONS(3)*Forme_3;
% signalBASE = zeros(1,nbFormeBASE*len_F1);
% switch typeSIG
% 	case 'superpose'
%         deb = floor((nbFormeBASE-1)*len_F1/2)+1-64; fin = deb + len_F1-1;
% %         deb = floor((nbFormeBASE-1)*len_F1/2)+1+64+12; fin = deb + len_F1-1;
%         signalBASE(deb:fin) = Forme_1;
%         deb = deb + floor((len_F1-len_F2)/2); fin = deb + len_F2-1;
%         signalBASE(deb:fin) = signalBASE(deb:fin) + Forme_2;
%         deb = deb + floor((len_F1-len_F3)/2); fin = deb + len_F3-1;
%         signalBASE(deb:fin) = signalBASE(deb:fin) + Forme_3;
% 
% 	case 'translate'
%         deb = floor(len_F1-64); fin = deb + len_F1-1;
%         signalBASE(deb:fin) = Forme_1;        
%         deb = floor(4*len_F1-len_F2/2-64); fin = deb + len_F2-1;
%         signalBASE(deb:fin) = signalBASE(deb:fin) + Forme_2;
%         deb = floor(6*len_F1-len_F3/2+64); fin = deb + len_F3-1;
%         signalBASE(deb:fin) = signalBASE(deb:fin) + Forme_3;
% end
% %-------------------------------------------------------------------------
