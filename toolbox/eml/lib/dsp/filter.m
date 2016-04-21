function [y,zf] = filter(Num, Den, x, ic, dim)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Only possible values for 'dim' are 1 and 2.
% 2) Dealing with NaN(s).

% $INCLUDE(DOC) toolbox/eml/lib/dsp/filter.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2004/03/21 22:07:29 $

eml_assert(nargin > 2, 'error', 'Not enough input arguments.');
eml_assert(isfloat(Num), 'error', ['Function ''filter'' is not defined for values of class ''' class(Num) '''.']);
eml_assert(isfloat(Den), 'error', ['Function ''filter'' is not defined for values of class ''' class(Den) '''.']);
eml_assert(isfloat(x), 'error', ['Function ''filter'' is not defined for values of class ''' class(x) '''.']);
if nargin >= 4,
    eml_assert(isfloat(ic), 'error', ['Function ''filter'' is not defined for values of class ''' class(ic) '''.']);
end

eml_assert(~isempty(Num) && ((size(Num,1) == 1) || (size(Num,2) == 1)),...
    'error','Argument must be a non-empty vector.');
eml_assert(~isempty(Den) && ((size(Den,1) == 1) || (size(Den,2) == 1)),...
    'error','Argument must be a non-empty vector.');
if nargin >= 5,
    eml_assert((length(dim) == 1) && ((dim ==1) || (dim == 2)),...
        'error','Fifth argument can only be a scalar value with value 1 or 2.');
end

RTN = 0;
eml_ignore([...
        'switch(nargin)',10 ...
        '   case 3, [y zf] = builtin(''filter'',Num,Den,x);',10 ...
        '   case 4, [y zf] = builtin(''filter'',Num,Den,x,ic);',10 ...
        '   case 5, [y zf] = builtin(''filter'',Num,Den,x,ic,dim);',10 ...
        'end',10 ...
        'RTN=1;',10 ...
    ]);
if RTN, return; end
% The above MATLAB code, distinguishes between a row and a column vector,
% but the following eML code, treats both a row and a column vector as a
% column vector. 'filter' function, when taking in 5 arguments, give
% different results for a row and column vector, hence we can't get it to
% work. 
% WISH : eML is able to recognize the difference between row and column
% vectors. 
if isempty(x)  
    % when input is empty, output is the same as input. 
    y = x;
    zf = x;
else
    %% Handle the case when x is some valid input like scalar, vector or
    %% matrix. 
    outReal = isreal(Num) && isreal(Den) && isreal(x);
    ordnum = length(Num(:)) - 1;
    ordden = length(Den(:)) - 1;
    if nargin == 5
        if (dim == 2)
            % The rule is:- If input is row, then don't tranpose, but if
            % column, then tranpose. 
            xtemp = x.'; %% xxx
        else
            xtemp = x;
        end
    else
        if (size(x,1) == 1) % input is a row vector
            xtemp = x.';
        else
            xtemp = x;
        end
    end
    
    samps = size(xtemp,1);
    chans = size(xtemp,2);
    
    %%% checking for the intial conditions
    if nargin >= 4
        % this means that there is an extra Initial condition argument and z
        % takes the value given by the fourth argument ic. 
        if (ordnum > ordden)
            expectedICsize = ordnum;
            if (isempty(ic))
                if (outReal)
                    icUsed = zeros(expectedICsize, 1);
                else
                    icUsed = complex(zeros(expectedICsize, 1),zeros(expectedICsize, 1));
                end
            else
                icUsed = ic;
            end
            eml_assert(length(icUsed(:)) == expectedICsize,'error','Initial conditions must be a vector of length max(length(a),length(b))-1');
        else
            expectedICsize = ordden;
            if (isempty(ic))
                if (outReal)
                    icUsed = zeros(expectedICsize, 1);
                else
                    icUsed = complex(zeros(expectedICsize, 1),zeros(expectedICsize, 1));
                end
            else
                icUsed = ic;
            end
            eml_assert(length(icUsed(:)) == expectedICsize,'error','Initial conditions must be a vector of length max(length(a),length(b))-1');
        end
        % Append a zero at the end of the input icUsed vector and that becomes the
        % 'state' for filter. 
        if (size(icUsed,1) == 1)  
            zPerCh = [icUsed  0];
        else 
            zPerCh = [icUsed; 0]; 
        end
    else
        if (ordnum > ordden)
            if (outReal)
                zPerCh = zeros(1,length(Num(:)));
            else
                zPerCh = complex(zeros(1,length(Num(:))),zeros(1,length(Num(:))));
            end
        else
            if (outReal)
                zPerCh = zeros(1,length(Den(:)));
            else
                zPerCh = complex(zeros(1,length(Den(:))),zeros(1,length(Den(:))));                
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  All-Pole Filter case %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           
    if (ordnum == 0)
        [ytemp z] = implementAllpoleFilter(Num,Den,xtemp,zPerCh,samps,chans,outReal);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  FIR Filter case %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%               
    elseif (ordden == 0)
        [ytemp z] = implementFIRFilter(Num,Den,xtemp,zPerCh,samps,chans,outReal);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  IIR Filter case %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    else
        [ytemp z] = implementIIRFilter(Num,Den,xtemp,zPerCh,samps,chans,outReal);
    end
    
    if (nargout == 2)
        if (ordnum > ordden)
            ord = ordnum;
            if (outReal)
                zf = zeros(ord,chans);
            else
                zf = complex(zeros(ord,chans),zeros(ord,chans));
            end
            for p = 1:chans
                index = 4*(p-1) + (1:ord);
                zf(:,p) = z(index);
            end
        else
            ord = ordden;
            if (outReal)
                zf = zeros(ord,chans);
            else
                zf = complex(zeros(ord,chans),zeros(ord,chans));                
            end
            for p = 1:chans
                index = 4*(p-1) + (1:ord);
                zf(:,p) = z(index);
            end
        end
    end
    
    if (nargin == 5)
        if (dim == 2)
            y = ytemp.';
        else
            y = ytemp;
        end
    else
        if (size(x,1) == 1) % input is a row vector
            y = ytemp.';
        else        
            y = ytemp;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%% end of filter.m function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%% Implement Allpole filter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ytemp, z] = implementAllpoleFilter(Num,Den,xtemp,zPerCh,samps,chans,outReal) %#ok
switch class(xtemp)
    case 'single',  eml_cdecl(ytemp, 'single', ~outReal, size(xtemp));
    case 'double',  eml_cdecl(ytemp, 'double', ~outReal, size(xtemp));
    otherwise
        eml_assert(0,'error','Non-floating point datatypes are not supported.');
end
delays = length(Den(:));
ordden = length(Den(:)) - 1;
ordnum = length(Num(:)) - 1;
if (outReal)
    z = zeros(length(Den(:))*chans,1);
else
    z = complex(zeros(length(Den(:))*chans,1),zeros(length(Den(:))*chans,1));
end
for p = 1:chans
    indx = p + (0:ordden)+ordden*(p-1);
    z(indx) = zPerCh;
end
if (Num(1) == 1)
    if (Den(1) == 1)
        switch class(xtemp)
            case 'single', 
                if (isreal(xtemp) && isreal(Den))
                    cc.MWDSP_AllPole_TDF_RR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                elseif (isreal(xtemp) && ~isreal(Den))
                    cc.MWDSP_AllPole_TDF_RC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                elseif (~isreal(xtemp) && isreal(Den))
                    cc.MWDSP_AllPole_TDF_CR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                else 
                    cc.MWDSP_AllPole_TDF_CC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                end
            case 'double',  
                if (isreal(xtemp) && isreal(Den))
                    cc.MWDSP_AllPole_TDF_DD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                elseif (isreal(xtemp) && ~isreal(Den))
                    cc.MWDSP_AllPole_TDF_DZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                elseif (~isreal(xtemp) && isreal(Den))
                    cc.MWDSP_AllPole_TDF_ZD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                else
                    cc.MWDSP_AllPole_TDF_ZZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                end
        end                
    else
        z = z*Den(1);
        switch class(xtemp)
            case 'single', 
                if (isreal(xtemp) && isreal(Den))
                    cc.MWDSP_AllPole_TDF_A0Scale_RR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                elseif (isreal(xtemp) && ~isreal(Den))
                    cc.MWDSP_AllPole_TDF_A0Scale_RC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                elseif (~isreal(xtemp) && isreal(Den))
                    cc.MWDSP_AllPole_TDF_A0Scale_CR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                else
                    cc.MWDSP_AllPole_TDF_A0Scale_CC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                end
            case 'double',  
                if (isreal(xtemp) && isreal(Den))
                    cc.MWDSP_AllPole_TDF_A0Scale_DD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                elseif  (isreal(xtemp) && ~isreal(Den))
                    cc.MWDSP_AllPole_TDF_A0Scale_DZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true);                     
                elseif  (~isreal(xtemp) && isreal(Den))
                    cc.MWDSP_AllPole_TDF_A0Scale_ZD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true); 
                else  
                    cc.MWDSP_AllPole_TDF_A0Scale_ZZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Den,ordden,true);                     
                end
        end                
    end
else
    switch class(xtemp)
        case 'single'
            if (Den(1) == 1)
                if (isreal(xtemp) && isreal(Den))
                    cc.MWDSP_IIR_DF2T_RR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);
                elseif (isreal(xtemp) && ~isreal(Den))
                    cc.MWDSP_IIR_DF2T_RC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);
                elseif (~isreal(xtemp) && isreal(Den))
                    cc.MWDSP_IIR_DF2T_CR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);
                else
                    cc.MWDSP_IIR_DF2T_CC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);
                end
            else
                z = z*Den(1);
                if (isreal(xtemp) && isreal(Den))
                    cc.MWDSP_IIR_DF2T_A0Scale_RR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);
                elseif (isreal(xtemp) && ~isreal(Den))
                    cc.MWDSP_IIR_DF2T_A0Scale_RC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);                
                elseif  (~isreal(xtemp) && isreal(Den))
                    cc.MWDSP_IIR_DF2T_A0Scale_CR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);                
                else  
                    cc.MWDSP_IIR_DF2T_A0Scale_CC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);                
                end
            end
        case 'double'
            if (Den(1) == 1)
                if (isreal(xtemp) && isreal(Den))
                    cc.MWDSP_IIR_DF2T_DD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);
                elseif (isreal(xtemp) && ~isreal(Den))
                    cc.MWDSP_IIR_DF2T_DZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);
                elseif (~isreal(xtemp) && isreal(Den))
                    cc.MWDSP_IIR_DF2T_ZD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);
                else
                    cc.MWDSP_IIR_DF2T_ZZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);
                end
            else
                z = z*Den(1);
                if (isreal(xtemp) && isreal(Den))
                    cc.MWDSP_IIR_DF2T_A0Scale_DD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);
                elseif (isreal(xtemp) && ~isreal(Den))
                    cc.MWDSP_IIR_DF2T_A0Scale_DZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);                
                elseif  (~isreal(xtemp) && isreal(Den))
                    cc.MWDSP_IIR_DF2T_A0Scale_ZD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);                
                else  
                    cc.MWDSP_IIR_DF2T_A0Scale_ZZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);                
                end
            end
    end            
end

%%%%%%%%%%%%%%%%%%% Implement FIR filter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ytemp, z] = implementFIRFilter(Num,Den,xtemp,zPerCh,samps,chans,outReal) %#ok
switch class(xtemp)
    case 'single',  eml_cdecl(ytemp, 'single', ~outReal, size(xtemp));
    case 'double',  eml_cdecl(ytemp, 'double', ~outReal, size(xtemp));
    otherwise
        eml_assert(0,'error','Non-floating point datatypes are not supported.');
end
delays = length(Num(:));
ordden = length(Den(:)) - 1;
ordnum = length(Num(:)) - 1;
if (outReal)
    z = zeros(length(Num(:))*chans,1);
else
    z = complex(zeros(length(Num(:))*chans,1),zeros(length(Num(:))*chans,1));
end
for p = 1:chans
    indx = p + (0:ordnum)+ordnum*(p-1);
    z(indx) = zPerCh;
end
switch class(xtemp)
    case 'single'
        if (Den(1) == 1)
            if (isreal(xtemp) && isreal(Num))
                cc.MWDSP_FIR_TDF_RR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,true); 
            elseif (isreal(xtemp) && ~isreal(Num))
                cc.MWDSP_FIR_TDF_RC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,true); 
            elseif (~isreal(xtemp) && isreal(Num))
                cc.MWDSP_FIR_TDF_CR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,true); 
            else
                cc.MWDSP_FIR_TDF_CC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,true); 
            end
        else
            z = z*Den(1);
            if (isreal(xtemp) && isreal(Num))
                cc.MWDSP_IIR_DF2T_A0Scale_RR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);
            elseif (isreal(xtemp) && ~isreal(Num))
                cc.MWDSP_IIR_DF2T_A0Scale_RC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);                
            elseif (~isreal(xtemp) && isreal(Num))
                cc.MWDSP_IIR_DF2T_A0Scale_CR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);                
            else 
                cc.MWDSP_IIR_DF2T_A0Scale_CC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);                
            end
        end
    case 'double'
        if (Den(1) == 1)
            if (isreal(xtemp) && isreal(Num))
                cc.MWDSP_FIR_TDF_DD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,true); 
            elseif (isreal(xtemp) && ~isreal(Num))
                cc.MWDSP_FIR_TDF_DZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,true); 
            elseif (~isreal(xtemp) && isreal(Num))
                cc.MWDSP_FIR_TDF_ZD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,true); 
            else
                cc.MWDSP_FIR_TDF_ZZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,true); 
            end
        else
            %% xxx Currently don't support the case where ic's are
            %% non-zeros, might enhance, may be divide ics by something. 
            z = z*Den(1);
            if (isreal(xtemp) && isreal(Num))
                cc.MWDSP_IIR_DF2T_A0Scale_DD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);
            elseif (isreal(xtemp) && ~isreal(Num))
                cc.MWDSP_IIR_DF2T_A0Scale_DZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);                
            elseif (~isreal(xtemp) && isreal(Num))
                cc.MWDSP_IIR_DF2T_A0Scale_ZD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);                
            else 
                cc.MWDSP_IIR_DF2T_A0Scale_ZZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,Num,ordnum,Den,ordden,true);                
            end
        end
end

%%%%%%%%%%%%%%%%%%% Implement IIR filter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ytemp, z] = implementIIRFilter(Num,Den,xtemp,zPerCh,samps,chans,outReal) %#ok
switch class(xtemp)
    case 'single',  eml_cdecl(ytemp, 'single', ~outReal, size(xtemp));
    case 'double',  eml_cdecl(ytemp, 'double', ~outReal, size(xtemp));
    otherwise
        eml_assert(0,'error','Non-floating point datatypes are not supported.');
end
ordden = length(Den(:)) - 1;
ordnum = length(Num(:)) - 1;

if (ordnum > ordden)
    delays = length(Num(:));
    if (outReal)
        z = zeros(length(Num(:))*chans,1);
    else
        z = complex(zeros(length(Num(:))*chans,1),zeros(length(Num(:))*chans,1));
    end
    for p = 1:chans 
        indx = p + (0:ordnum)+ordnum*(p-1);
        z(indx) = zPerCh;
    end
else
    delays = length(Den(:));
    if (outReal)
        z = zeros(length(Den(:))*chans,1);
    else
        z = complex(zeros(length(Den(:))*chans,1),zeros(length(Den(:))*chans,1));
    end
    for p = 1:chans
        indx = p + (0:ordden)+ordden*(p-1);
        z(indx) = zPerCh;
    end
end

%% If only one of Num. or Den. is complex, then we have to make the other
%% one complex too. 
if (isreal(Num) && ~isreal(Den))
    NumUsed = complex(Num, 0);
    DenUsed = Den;
elseif (~isreal(Num) && isreal(Den))
    NumUsed = Num;
    DenUsed = complex(Den, 0);
else
    NumUsed = Num;
    DenUsed = Den;
end
isRealCoeff = (isreal(Num) && isreal(Den));
switch class(xtemp)
case 'single'
    if (Den(1) == 1)
        % First Deno. coeff. is unity, hence need to call the run-time
        % function which assumes so. 
        if (isreal(xtemp) && isRealCoeff)
            cc.MWDSP_IIR_DF2T_RR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);
        elseif (isreal(xtemp) && ~isRealCoeff)
            cc.MWDSP_IIR_DF2T_RC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);
        elseif (~isreal(xtemp) && isRealCoeff)
            cc.MWDSP_IIR_DF2T_CR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);
        else
            cc.MWDSP_IIR_DF2T_CC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);
        end
    else
        % First Deno. coeff. is NOT unity, hence need to call the run-time
        % function which handles this case.  
        %% Also need to modify the states in this case. 
        z = z*Den(1);
        if (isreal(xtemp) && isRealCoeff)
            cc.MWDSP_IIR_DF2T_A0Scale_RR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);            
        elseif (isreal(xtemp) && ~isRealCoeff)
            cc.MWDSP_IIR_DF2T_A0Scale_RC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);                            
        elseif (~isreal(xtemp) && isRealCoeff)
            cc.MWDSP_IIR_DF2T_A0Scale_CR(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);                            
        else
            cc.MWDSP_IIR_DF2T_A0Scale_CC(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);                            
        end
    end
case 'double'
    if (Den(1) == 1)
        % First Deno. coeff. is unity, hence need to call the run-time
        % function which assumes so. 
        if (isreal(xtemp) && isRealCoeff)
            cc.MWDSP_IIR_DF2T_DD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);
        elseif (isreal(xtemp) && ~isRealCoeff)
            cc.MWDSP_IIR_DF2T_DZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);                
        elseif (~isreal(xtemp) && isRealCoeff)
            cc.MWDSP_IIR_DF2T_ZD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);                
        else
            cc.MWDSP_IIR_DF2T_ZZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);                
        end
    else
        % First Deno. coeff. is NOT unity, hence need to call the run-time
        % function which handles this case.  
        z = z*Den(1);
        if (isreal(xtemp) && isRealCoeff)
            cc.MWDSP_IIR_DF2T_A0Scale_DD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);            
        elseif (isreal(xtemp) && ~isRealCoeff)
            cc.MWDSP_IIR_DF2T_A0Scale_DZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);                            
        elseif (~isreal(xtemp) && isRealCoeff)
            cc.MWDSP_IIR_DF2T_A0Scale_ZD(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);                            
        else
            cc.MWDSP_IIR_DF2T_A0Scale_ZZ(xtemp,eml_wref(ytemp),eml_wref(z),delays,samps,chans,NumUsed,ordnum,DenUsed,ordden,true);                            
        end
    end
end

%%% EOF filter.m
