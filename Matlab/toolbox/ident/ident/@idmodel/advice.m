function advice(m)
%ADVICE gives advice and suggestions on properties of IDMODEL objects. 
%
%   ADVICE(MODEL)

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/04/10 23:17:15 $

[ny,nu]=size(m);

ut = m.Utility;
try
    advice = ut.advice;
catch
    advice = [];
end
es = m.EstimationInfo;
method = es.Method;
adv = {' '};
try 
    mname = inputname(1);
catch
    mname = 'MODEL';
end
dname = es.DataName;
if isempty(dname)
    dname = 'DATA';
end


% 1. Iterations
stop = lower(es.WhyStop);
if length(stop)>2&strcmp(stop(1:3),'max')
    maxi = m.Algorithm.MaxIter;
    if maxi < 10
        add = ',''MaxIter'',20';
    else
        add = '';
    end
    adv = [adv,{...
                'The model may be improved if more iterations in the search are used. Try'...
                ' '...
                ['  ',mname,' = PEM(',dname,',',mname,add,')'],...
                ' '}];
elseif m.Algorithm.MaxIter==0
    
    add = ',''MaxIter'',20';
    
    adv = [adv,{...
                'You have not demanded any iterations. Try'...
                ' '...
                ['  ',mname,' = PEM(',dname,',',mname,add,')'],...
                ' '}];
end
try
    idid = advice.estimation.DataId;
catch
    idid = 0;
end
%2. COMPARE
if ~isfield(advice,'compare')
    adv = [adv,{...
                'You should run a comparison test'...
                ' '...
                ['  COMPARE(VDATA,',mname,')'],...
                ' '...
                ['where VDATA preferably is a different data set from the estimation data ',dname,'.'],...
                ['You can then run ADVICE(',mname,') again.'],...
                ' '}];
else
    comp = advice.compare;
    if abs(idid-comp.DataId)<eps
        adv = [adv,{...
                    'You have done the comparison test on the same data set for which the model was'...
                    'estimated. It is a more revealing test to do COMPARE for a different, Validation, data set.'...
                    ' '...
                }];
    end
end
% THE numbers ...
%2. RESID

if ~isfield(advice,'resid')
    adv = [adv,{...
                'You should run a residual test'...
                ' '...
                ['  RESID(VDATA,',mname,')'],...
                ' '...
                ['where VDATA preferably is a different data set from the estimation data ',dname,'.'],...
                ['You can then run ADVICE(',mname,') again.'],...
                ' '}];
else
    resid = advice.resid;
    if abs(idid-resid.DataId)<eps
        adv = [adv,{...
                    'You have performed the residual test on the same data set for which the model was'...
                    'estimated. It is a tougher test to do the test for a different, Validation, data set.'...
                    ' '...
                }];
    end
    if nu>0
        ue = resid.chitestue;
        nogood = find(ue>90); % CHECK LEVELS
        if nu>1&ny>1
        [lev1,maxlev1] = max(ue);
        [lev,maxlev2] = max(lev1);
        ku=maxlev2;
        ky=maxlev1(maxlev2);
    elseif nu>1
        ky = 1;
        [lev,ku] = max(ue);
    elseif ny>1
        ku = 1;
        [lev,ky]=max(ue);
    else
        lev = ue;
        ky = 1; ku = 1;
    end
        if isempty(nogood)
            allgood =1;
            adv = [adv,{...
                        'There is no indication of significant errors in the model dynamics.'...
                        ' '}];
        else
            allgood = 0;
            if lev > 99
                text = ' a very strong';
            elseif lev > 95
                text = ' a strong';
            else
                text = ' an';
            end
            if (isa(m,'idpoly')|isa(m,'idarx'))&(ny>1|nu>1)
                ioadv = 1;
            else
                ioadv = 0;
            end
            adv = [adv,{...
                        ['There is',text,' indication that the dynamics of the model is not adequately described.']...
                        ['A first general advice is to run RESID(VDATA,',mname,',''FR'') to check in which frequency'],...
                        'ranges the model error is present. If the model error is unacceptable, you will have to'...
                        'increase the model order.'...
                        ' '}];
            % ku = floor(maxlev/ny)+1;
            %ky = rem(maxlev-1,ny)+1;
            if ioadv
                
                adv = [adv,{...
                            ['The worst model channels are from input ',int2str(ku),' to output ',int2str(ky)],...
                            ' '}];
            end
            try
            out = resid.outtestue;
        catch
            out=[];
        end
        if ~isempty(out)
            outworst = squeeze(out(ky,ku,:));
            worstku = find(outworst>1.7)-1;
            if ~isempty(worstku)
                if isa(m,'idpoly')|isa(m,'idarx')
                    txt = ['and the orders NB '];
                else
                    txt =['and the model order '];
                end
                if length(worstku)==1
                    txt2 = 'lag ';
                    txt3 = 'this lag is';
                else
                    txt2 = 'lags ';
                    txt3 = 'these lags are';
                end
                adv = [adv,{...
                            ['In particular you should pay attention to ',txt2,int2str(worstku'),' from input ',int2str(ku),'.'],...
                            ['Modify KU ',txt,'so that ',txt3,' included in the model.'],...
                            ' '}];
            end
        end
        end
        
        %% NOW CHECK WHITENESS OF RESIDUALS
        try
            rese = resid.chiteste;
        catch
            rese = 0;
        end
        if rese == 0
            adv = [adv,{...
                        ['To check correctness of noise model first run RESID(VDATA,',mname,').']...
                        ' '}];
        elseif rese<90
            adv = [adv,{...
                        'There is no indication that the noise model should be incorrect.'...
                        ' '}];
        else
            if rese>99
                text = 'a very strong';
            elseif rese>95
                text = 'a strong';
            else
                text = 'an';
            end
            ms=idss(m);
            if norm(pvget(ms,'K'))==0
                oe = 1;
            else
                oe = 0;
            end
            if oe
                adv =[adv,{...
                            ['There is ',text,' indication that the model errors are not white. Since you have not'],...
                            'built a noise model, this is OK. However the model estimate might be improved if you'...
                            'also include a model of the noise. (Set ''DisturbanceModel'' to ''Estimate'' for state-space'...
                            'models, or use BJ or ARMAX for polynomial models.)'...
                            ' '}];
            else
                adv =[adv,{...
                            ['There is ',text,' indication that the residuls are not white. To get a good noise model'],...
                            'you need to increase the orders associated with the noise parameters, or just increase'...
                            'the order of a state-space model.'...
                            ' '}];
            end
        end
        
    end
    if nu>0
        fbck = ut.advice.resid.chitestuefb;
        fblev = max(max(fbck)');
        nudir = 0;
        if ~isnan(fblev)
            if fblev < 60
                adv = [adv,{...
                            'There is no significant indication of feedback in the data.'...
                        }];
                if any(nudir)
                    adv = [adv,{...
                                '(Unless you decide that the direct term is due to feedback.)'...
                            }];
                end
                adv = [adv,{' '}];
            else
                if fblev>99
                    
                    txt = 'a very strong indication';
                elseif fblev>90
                    txt = 'a strong indication';
                    
                else
                    txt = 'a possible indication';
                end
                adv = [adv,{...
                            ['There is ',txt,' of feedback in the data.'],...
                            ' You should be careful when interpreting the results of SPA and also interpret'...
                            ' the results of output error models with care.'...
                            '(Output error models result from the OE command or setting ''DisturbanceModel''= ''None'''...
                            'in state-space models.)'...
                            ' '}];
            end
        end
    end
end
%3. ParameterVariance

%4. Model simplification
%%%LL IF CSTB EXISTS %% COV??
try
    ms = pvset(m,'CovarianceMatrix','None');
    ms = ss(ms('m'));
    %msr = idmodred(ms,size(ms.A,1)-1);
    [msr,g] = balreal(ms);
    
    %msr = modred(msr,length(g));
    %SISOf1 = s
    if g(end)/g(1)< 0.01
        adv = [adv,{...
                    'The model order seems unnecessarily high. Try models of lower order and see'...
                    'if they are able to reproduce validation data equally well.'...
                    ' '}];
        try
        if advice.estimation.ResidNorm/advice.estimation.DataNorm < 0.0001&...
                g(end)/g(1)>0.000001
            
            adv =[adv,{...
                        'On the other hand, the accuracy of the estimate seems to be such that the'...
                        'high order dynamics is accurately estimated.'...
                        ' '}];
        end
        end
    end
end


%
disp(char(adv));