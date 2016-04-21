function [C , lags] = xcorr(A,B, maxlag,scaleopt)
% Embedded MATLAB Library function.
%   
% Limitations:
% 1) Does not support the case where A is a matrix. 
% 2) Partial (abbreviated) strings of biased,unbiased,coeff,none
%    is unsupported.

% $INCLUDE(DOC) toolbox/eml/lib/dsp/xcorr.m $
% Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/03/21 22:07:34 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(A), 'error', ['Function ''xcorr'' is not defined for values of class ''' class(A) '''.']);

eml_assert(((size(A,1) == 1) || (size(A,2) == 1)),'error',...
           'Input A has to be a vector.');
if (nargin == 2)
    % 2nd argument can either be another vector to do cross-correlation or
    % it can be a scalar value representing the maxlag. 
    eml_assert((length(B) == 1) || ((size(B,1) == 1) || (size(B,2) == 1)),...
    'error','B must be a vector (min(size(B))==1)');
end

lengthA = length(A(:));

if nargin >= 2
    lengthB = length(B(:));
end
   
RTN = 0;
eml_ignore('d = pwd;');
eml_ignore('cd(fullfile(matlabroot,''toolbox'',''signal'',''signal''));');
eml_ignore([...
    'switch(nargin)',10 ...
    '   case 1, [C lags] = xcorr(A);',10 ...
    '   case 2, [C lags] = xcorr(A,B);',10 ...
    '   case 3, [C lags] = xcorr(A,B,maxlag);',10 ...
    '   case 4, [C lags] = xcorr(A,B,maxlag,scaleopt);',10 ...
    'end',10 ...
]);
eml_ignore('RTN = 1;');
eml_ignore('cd(d);');
if RTN, return; end

switch nargin
    case 1,
        C = doAutocorrelation(A);
        lags = -(lengthA-1):(lengthA-1);
    case 2,     
        if (isa(B,'char'))
            switch B
                case {'biased','unbiased','coeff','none'}
                    C  = doAutocorrelation(A);
                    lags = -(lengthA-1):(lengthA-1);
                    C    = scaleoutput(C,B,lengthA,lags);  
                otherwise
                    eml_assert(0,'error','Input argument is not recognized.');
            end
        elseif (lengthB == 1)
            % In this case the second argument is 'maxlag' and we do
            % autocorrelation. 
            eml_assert(B == double(int32(B)),'error',...
	               'Maximum lag must be an integer.');
            %%% WISH: Get rid of type-casting 'double' in the above case. 
            Ctemp = doAutocorrelation(A);
            switch class(A)
                case 'single'
                    if (size(Ctemp,1) == 1) %% C is a row vector
                        eml_cdecl(C, 'single', ~isreal(A), [1   2*B+1]);
                    else
                        eml_cdecl(C, 'single', ~isreal(A), [2*B+1  1]);
                    end
                case 'double'
                    if (size(Ctemp,1) == 1) %% C is a row vector
                        eml_cdecl(C, 'double', ~isreal(A), [1  2*B+1]);
                    else
                        eml_cdecl(C, 'double', ~isreal(A), [2*B+1  1]);
                    end
            end    
            lengthCtemp = 2*lengthA - 1;
            clipby = lengthA - B - 1;
            C = Ctemp(clipby+1:lengthCtemp-clipby);
            lags = -B:B;
        else
            C = doCrosscorrelation(A,B);
            if (lengthA > lengthB)
                lags = -(lengthA-1):(lengthA-1);
            else
                lags = -(lengthB-1):(lengthB-1);
            end
        end
    case 3,
        if (isa(maxlag,'char'))
            if (strcmp(maxlag,'biased') || strcmp(maxlag,'unbiased') || ...
		strcmp(maxlag,'coeff') || strcmp(maxlag,'none'))
                doScale = 1;
            else
                eml_assert(0,'error','Input argument is not recognized.');
            end
        else
            doScale = 0;
        end
        if ((lengthA ~= lengthB) && (lengthB > 1) && doScale)
            eml_assert(strcmp(maxlag,'none'),'error',...
		       'Scale option must be none for different length vectors A and B.');
        end
        if (lengthA > lengthB)
            if (lengthB == 1)
                eml_assert(B == double(int32(B)),'error',...
			   'Maximum lag must be an integer.');
                Ctemp = doAutocorrelation(A);
                switch class(A)
                    case 'single'
                        if (size(Ctemp,1) == 1) %% C is a row vector
                            eml_cdecl(C, 'single', ~isreal(A), [1 2*B+1]);
                        else
                            eml_cdecl(C, 'single', ~isreal(A), [2*B+1 1]);
                        end
                    case 'double'
                        if (size(Ctemp,1) == 1) %% C is a row vector
                            eml_cdecl(C, 'double', ~isreal(A), [1 2*B+1]);
                        else
                            eml_cdecl(C, 'double', ~isreal(A), [2*B+1 1]);                            
                        end
                end
                lengthCtemp = 2*lengthA - 1;
                clipby = lengthA - B - 1;
                C = Ctemp(clipby+1:lengthCtemp-clipby);
                lags = -B:B;
                C = scaleoutput(C,maxlag,lengthA,lags); %%% xxx possibility to get rid of 3rd argument. used to be B b4
            else
                [C  lags] = doScaleOrChop(A,B,maxlag,lengthA,doScale);
            end
        else
            [C  lags] = doScaleOrChop(A,B,maxlag,lengthB,doScale);
        end
    case 4,
        if strcmp(class(scaleopt),'char')
            if ~(strcmp(scaleopt,'biased') || strcmp(scaleopt,'unbiased') || strcmp(scaleopt,'coeff') || strcmp(scaleopt,'none'))
                eml_assert(0,'error','Input argument is not recognized.');
            end
            if (lengthA ~= lengthB)
                eml_assert(strcmp(scaleopt,'none'),'error','Scale option must be none for different length vectors A and B.');
            end
        end
        if lengthA > lengthB
            [C  lags] = doScaleOrChop(A,B,maxlag,lengthA,0);
            C = scaleoutput(C,scaleopt,lengthA,lags);                
        else
            [C  lags] = doScaleOrChop(A,B,maxlag,lengthB,0);
            C = scaleoutput(C,scaleopt,lengthB,lags);                
        end
end

function Cout = doAutocorrelation(In) 
lengthC = 2*length(In(:)) - 1;
outRow = (size(In,1) == 1);
Cout = callRelevantRuntFcn(In, In, lengthC, outRow);

function Cout = doCrosscorrelation(Ain,Bin)
lengthAin = length(Ain(:));
lengthBin = length(Bin(:));

outRow = (size(Ain,1) == 1);
if (lengthAin > lengthBin)
    % Length A is greater than length B. To perform
    % cross-correlation, both the lengths have to be of the same
    % size. Pad zeros at the end of the vector B to make sizes
    % equal and then perform cross-correlation. 
    diff_length = lengthAin - lengthBin;
    if (isreal(Bin))
        Bused = zeros(1,lengthAin); %#ok (due to type inference)
        zerovec = zeros(1,diff_length);
    else
        Bused = complex(zeros(1,lengthAin),zeros(1,lengthAin)); %#ok (due to type inference)
        zerovec = complex(zeros(1,diff_length),zeros(1,diff_length));
    end
    if (size(Bin,1) == 1)
        Bused = [Bin, zerovec];
    else
        Bused = [Bin.', zerovec];
    end
    lengthC = 2*lengthAin - 1;
    Cout = callRelevantRuntFcn(Ain, Bused, lengthC, outRow);
elseif (lengthAin < lengthBin)
    diff_length = lengthBin - lengthAin;
    if (isreal(Ain))
        Aused = zeros(1,lengthBin); %#ok (due to type inference)
        zerovec = zeros(1,diff_length);
    else
        Aused = complex(zeros(1,lengthBin),zeros(1,lengthBin)); %#ok (due to type inference)
        zerovec = complex(zeros(1,diff_length),zeros(1,diff_length));
    end
    if (outRow)
        Aused = [Ain, zerovec];
    else
        Aused = [Ain.', zerovec];        
    end
%%%    Aused = zeros(lengthBin,1);
%%% WISH:- use this->    Aused = [Ain; zeros(diff_length,1)];
    lengthC = 2*lengthBin - 1;
    Cout = callRelevantRuntFcn(Aused, Bin, lengthC, outRow);
else            
    lengthC = 2*lengthAin - 1;            
    Cout = callRelevantRuntFcn(Ain, Bin, lengthC, outRow);
end

function  Cout = callRelevantRuntFcn(Ain, Bin, lengthC, outRow) %#ok

lengthAin = length(Ain(:));
lengthBin = length(Bin(:));

outCplx = ~(isreal(Ain) && isreal(Bin));
switch class(Ain)
    case 'single'
        if (outRow)  %% is a row
            eml_cdecl(Cout, 'single', outCplx, [1 lengthC]);
        else
            eml_cdecl(Cout, 'single', outCplx, [lengthC  1]);
        end
        if (isreal(Ain) && isreal(Bin))
            cc.MWDSP_Corr_TD_RR(Ain, lengthAin, false,Bin, lengthBin, false, eml_wref(Cout), lengthC,1 );
        elseif (isreal(Ain) && ~isreal(Bin))
            cc.MWDSP_Corr_TD_RC(Ain, lengthAin, false,Bin, lengthBin, false, eml_wref(Cout), lengthC,1 );
        elseif (~isreal(Ain) && isreal(Bin))
            cc.MWDSP_Corr_TD_CR(Ain, lengthAin, false,Bin, lengthBin, false, eml_wref(Cout), lengthC,1 );
        else
            cc.MWDSP_Corr_TD_CC(Ain, lengthAin, false,Bin, lengthBin, false, eml_wref(Cout), lengthC,1 );
        end
    case 'double'
        if (outRow)  %% is a row
            eml_cdecl(Cout, 'double', outCplx, [1 lengthC]);
        else
            eml_cdecl(Cout, 'double', outCplx, [lengthC  1]);
        end
        if (isreal(Ain) && isreal(Bin))
            cc.MWDSP_Corr_TD_DD(Ain, lengthAin, false,Bin, lengthBin, false, eml_wref(Cout), lengthC,1 );    
        elseif (isreal(Ain) && ~isreal(Bin))
            cc.MWDSP_Corr_TD_DZ(Ain, lengthAin, false,Bin, lengthBin, false, eml_wref(Cout), lengthC,1 );    
        elseif (~isreal(Ain) && isreal(Bin))
            cc.MWDSP_Corr_TD_ZD(Ain, lengthAin, false,Bin, lengthBin, false, eml_wref(Cout), lengthC,1 );    
        else
            cc.MWDSP_Corr_TD_ZZ(Ain, lengthAin, false,Bin, lengthBin, false, eml_wref(Cout), lengthC,1 );    
        end
    otherwise
        eml_assert(0,'error','Non-floating point datatypes are not supported.');        
end

function [C , lags] = doScaleOrChop(A,B,maxlag,laglength,doScale)
if (doScale)
    Ctemp    = doCrosscorrelation(A,B);
    lags = -(laglength-1):(laglength-1);
    C    = scaleoutput(Ctemp,maxlag,laglength,lags);                
else
    Ctemp = doCrosscorrelation(A,B);
    eml_assert(maxlag == double(int32(maxlag)),'error','Maximum lag must be an integer.');
    switch class(A)
        case 'single'
            if (size(Ctemp,1) == 1) %% Ctemp is a row
                eml_cdecl(C, 'single', ~isreal(A), [1  2*maxlag+1]);
            else
                eml_cdecl(C, 'single', ~isreal(A), [2*maxlag+1 1]);
            end
        case 'double'
            if (size(Ctemp,1) == 1) %% Ctemp is a row
                eml_cdecl(C, 'double', ~isreal(A), [1  2*maxlag+1]);
            else
                eml_cdecl(C, 'double', ~isreal(A), [2*maxlag+1 1]);                
            end
    end
    lengthCtemp = 2*laglength - 1;
    clipby = laglength - maxlag - 1;
    C   = Ctemp(clipby+1:lengthCtemp-clipby);
    lags = -maxlag:maxlag;
end

function Cout = scaleoutput(Cin,scale_rule,M,lags4unbiased)

lengthCin = length(Cin(:));

if isreal(Cin)
    if (size(Cin,1) == 1) %% Cin is a row
        Cout = zeros(1,lengthCin);
    else
        Cout = zeros(lengthCin,1);
    end
else
    if (size(Cin,1) == 1) %% Cin is a row
        Cout = complex(zeros(1, lengthCin),zeros(1, lengthCin));
    else
        Cout = complex(zeros(lengthCin,1),zeros(lengthCin,1));
    end
end
%%% WISH: Switch on string values. 
%%% WISH: After I have support for complex division, the following code
%%% should work for all complex values too. 
if strcmp(scale_rule,'biased')
    Cout = Cin/M;
elseif strcmp(scale_rule,'unbiased')
  
    for p = 1:length(lags4unbiased) %%(2*M-1)
        if (lags4unbiased(p) < 0)
            lags4unbiased(p) = -lags4unbiased(p);
        end
        Cout(p) = Cin(p)/(M - lags4unbiased(p));
    end
elseif strcmp(scale_rule,'coeff')
    middleindx = (lengthCin+1)/2;
    Cout = Cin/Cin(middleindx);
else
    Cout = Cin;
end
