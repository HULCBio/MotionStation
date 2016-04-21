function C = conv(A,B) %#ok
% Embedded MATLAB Library function.
%
% Limitations:
% No known limitations.

% $INCLUDE(DOC) toolbox/eml/lib/dsp/conv.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2004/03/21 22:07:27 $

eml_assert(nargin > 1, 'error', 'Not enough input arguments.');
eml_assert(((size(A,1) == 1) | (size(A,2) == 1)),'error','Input A has to be a vector.');
eml_assert(((size(B,1) == 1) | (size(B,2) == 1)),'error','Input B has to be a vector.');

RTN = 0;
eml_ignore('d = pwd;');
eml_ignore('cd(fullfile(matlabroot,''toolbox'',''matlab'',''datafun''));');
eml_ignore('C = conv(A,B);');
eml_ignore('RTN = 1;');
eml_ignore('cd(d);');
if RTN, return; end

lengthA = length(A(:));
lengthB = length(B(:));
lengthC = lengthA + lengthB - 1;
switch class(A)
    case 'single',
        %if (strcmp(eml_cclass(A), 'single'))
        if (isreal(A) && isreal(B))
            %% Both A and B are real. 
            if (size(B,1) == 1) % input vector is a row
                eml_cdecl(C, 'single', 0, [1 lengthC]);
            else
                eml_cdecl(C, 'single', 0, [lengthC 1]);
            end
            cc.MWDSP_Conv_TD_RR(A, lengthA, false,B, lengthB, false, eml_wref(C), lengthC ,1 );  
        elseif ~(isreal(A) || isreal(B))
            %% Both A and B are complex.
            if (size(A,1) == 1) % input vector is a row
                eml_cdecl(C, 'single', 1, [1 lengthC]);
            else
                eml_cdecl(C, 'single', 1, [lengthC 1]);
            end
            cc.MWDSP_Conv_TD_CC(A, lengthA, false,B, lengthB, false, eml_wref(C), lengthC ,1 );  
        else
            %% Any one of A or B is complex
            if (size(A,1) == 1) % input vector is a row
                eml_cdecl(C, 'single', 1, [1 lengthC]);
            else
                eml_cdecl(C, 'single', 1, [lengthC 1]);
            end
            if (isreal(A))
                cc.MWDSP_Conv_TD_RC(A, lengthA, false,B, lengthB, false, eml_wref(C), lengthC ,1 );  
            else
                cc.MWDSP_Conv_TD_RC(B, lengthB, false,A, lengthA, false, eml_wref(C), lengthC ,1 );  
            end                
        end
    case 'double'
        %elseif (strcmp(eml_cclass(A), 'double'))
        if (isreal(A) && isreal(B))
            if (size(B,1) == 1) % input vector is a row
                eml_cdecl(C, 'double', 0, [1 lengthC]);
            else
                eml_cdecl(C, 'double', 0, [lengthC 1]);
            end
            cc.MWDSP_Conv_TD_DD(A, lengthA, false,B, lengthB, false, eml_wref(C), lengthC ,1 );
        elseif  ~(isreal(A) || isreal(B))
            %% Both A and B are complex.
            if (size(A,1) == 1) % input vector is a row
                eml_cdecl(C, 'double', 1, [1 lengthC]);
            else
                eml_cdecl(C, 'double', 1, [lengthC 1]);
            end
            cc.MWDSP_Conv_TD_ZZ(A, lengthA, false,B, lengthB, false, eml_wref(C), lengthC ,1 );  
        else
            %% Any one of A or B is complex
            if (size(A,1) == 1) % input vector is a row
                eml_cdecl(C, 'double', 1, [1 lengthC]);
            else
                eml_cdecl(C, 'double', 1, [lengthC 1]);
            end
            if (isreal(A))
                cc.MWDSP_Conv_TD_DZ(A, lengthA, false,B, lengthB, false, eml_wref(C), lengthC ,1 );  
            else
                cc.MWDSP_Conv_TD_DZ(B, lengthB, false,A, lengthA, false, eml_wref(C), lengthC ,1 );  
            end                
        end
    otherwise
        eml_assert(false, 'error', ['Function ''conv'' is not defined for values of class ''' class(A) '''.']);

end


