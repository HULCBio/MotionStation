function txt = numdemo(topic,slide)
%NUMDEMO  Numerical Do's and Don'ts Demo
%
%   This demo reviews some pitfalls of numerical computations 
%   with LTI models and gives hints for getting reliable results.

%   Authors: P. Gahinet
%   Revised: A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/06/11 17:26:41 $

topiclist = {
    'Model Type Conversions';
    'Balancing' ;
    'Closing Feedback Loops' ;
    'Connecting Models' ;
    'High-Order Transfer Functions';
    'Sensitivity of Multiple Roots'
};

if nargin==0
    % Initialization
    topicshow(topiclist,1,mfilename);
else
    set(gcf,'Name',sprintf('Do''s and Don''ts: %s',topiclist{topic}))
    ax = gca;
    cla(ax)
    % delete(findobj(allchild(ax),'flat','Serializable','on'));  % fast cla on 'ax'
    p = localParameters;
    switch topic
    case 1
        % Conversions
        switch slide
        case 0
            % number of slide
            txt = 4;
        case 1
            txt = {
                ' You can convert any LTI model to transfer function, zero-pole-gain, or state-space'
                ' form using the commands TF, ZPK, and SS, respectively. For example, given a'
                ' two-input, two-output random state-space model HSS1 created by'
                ' '
                '   >> HSS1 = rss(3,2,2)'
                ' '
                ' you can obtain its transfer function by'
                ' '
                '   >> HTF = tf(HSS1)'
            };
            str = {
                '>> tf(sys)   % converts to transfer function  ';
                '                                              ';
                '                                              ';
                '>> zpk(sys)  % converts to zero-pole-gain form';
                '                                              ';
                '                                              ';
                '>> ss(sys)   % converts to state-space form   ';
            };
            axis(ax,'normal')
            set(ax,'visible','off')
            text('Parent',ax,'String','Model Type Conversions','Position',[.5 .9],...
                'FontSize',12+2*isunix,'FontWeight','bold','Hor','center','Ver','middle');
            text('Parent',ax,'String',str,'Position',[.5 .65],'Color',[0 0 .7],'fontname','FixedWidth',...
                'fontsize',12+2*isunix,'fontweight','bold','hor','center','vert','top')
        case 2
            txt = {
                ' Beware that conversions are neither cheap nor free of roundoff errors, and can'
                ' increase the model order.  You should therefore avoid converting back and forth'
                ' between model types, especially when dealing with MIMO models.  As a simple'
                ' illustration, convert the 2x2 state-space model HSS1 to transfer function and back'
                ' to state-space, and compare the pole/zero maps for the initial and final models:'
                ' '
                '   >> HTF = tf(HSS1)'
                '   >> HSS2 = ss(HTF)'
                '   >> pzmap(HSS1,''b'',HSS2,''r'')'
                ' '
                ' You can use the Systems menu off the right-click menu to toggle HSS2 on/off.'
            };
            HSS1 = p.HSS1;
            HSS2 = p.HSS2;
            pzmap(HSS1,'b',HSS2,'r')
            title('Pole/zero maps of HSS1 (blue) and HSS2 (red)');
        case 3
            txt = {
                ' The resulting model HSS2 has double the order of HSS1, as confirmed by '
                ' '
                '   >> [size(HSS1,''order'') , size(HSS2,''order'')]'
                ' '
                '   ans ='
                '           3     6'
                ' '
                ' This is because 6 is the generic order of 2x2 transfer matrices with denominator'
                ' of degree 3.  The reduced order 3 is an "anomaly" due to exact pole/zero'
                ' cancellations (look for x''s inside o''s in the pole/zero map).'
            };
            HSS1 = p.HSS1;
            HSS2 = p.HSS2;
            pzmap(HSS1,'b',HSS2,'r')
            title('Pole/zero maps of HSS1 (blue) and HSS2 (red)');
        case 4
            txt = {
                ' You can use the command MINREAL to eliminate cancelling pole/zero pairs and'
                ' recover a 3rd-order, minimal state-space model from HSS2:'
                ' '
                '   >> HSS2\_min = minreal(HSS2)'
                '   >> pzmap(HSS1,''b'',HSS2\_min,''r'')'
                ' '
                ' But extracting minimal realizations is numerically challenging, so it is best to'
                ' avoid creating nonminimal models in the first place.  (see also the "Model'
                ' Interconnections" topic).'
                ' '
                ' {\bfMoral:}  Don''t abuse conversions, and stick with the state-space form for all computations.'
            };
            HSS1 = p.HSS1;
            HSS2 = p.HSS2;
            HSS2_min = minreal(HSS2);
            pzmap(HSS1,'b',HSS2_min,'r')
            title('Pole/zero maps of HSS1 (blue) and HSS2\_min (red)')
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 2
        % Balancing
        switch slide
        case 0
            % number of slide
            txt = 5;
        case 1
            txt = {
                ' Mixing disparate time scales or unit scales may produce state-space models with'
                ' coefficients widely spread in values.  Working with such poorly scaled models '
                ' can lead to numerical instabilities and puzzling results.'
                ' '
                ' Above is an example of a poorly-scaled model (POORBAL).  Note the many orders'
                ' of magnitude separating the entries of B and C, as well as the lower vs. upper'
                ' diagonal entries in the state matrix A.'
                ' '
                ' This model is available for analysis in numdemo.mat:'
                ' '
                '   >> load numdemo            % load POORBAL model'
            };
            axis(ax,'normal')
            set(ax,'visible','off','xlim',[0 1],'ylim',[0 1])
            text('Parent',ax,'String','A poorly-scaled model (POORBAL):','Position',[.01 .9],...
                'FontSize',12+2*isunix,'FontWeight','bold','Hor','left','Ver','middle');
            blk = ' ';
            stra = [['a = ';repmat(blk,[3 4])] num2str(p.poorbal.a,6)];
            strb = [['b = ';repmat(blk,[3 4])] num2str(p.poorbal.b,6)];
            strc = ['c = ' num2str(p.poorbal.c,6)];
            strd = ['d = ' num2str(p.poorbal.d,6)];
            str = str2mat(stra,' ',strb,' ',strc,' ',strd);
            text('parent',ax,'position',[.47 .75],'string',str,'fontsize',8+2*isunix,...
                'fontname','FixedWidth','horiz','center','vertical','top','color',[0 0 .7])
        case 2
            txt = {
                ' This model is stable with poles at:  -1.9e6, -2.6e3+7.0e4i, -2.6e3-7.0e4i, -4.3e3'
                ' '
                ' To illustrate the pitfalls of poor scaling, discretize at 1 MHz (Ts = 1e-6) using'
                ' the matrix-based version of C2D and simulate the step response:'
                ' '
                '   >> [a,b,c,d] = ssdata(poorbal)'
                '   >> [ad,bd] = c2d(a,b,1e-6)'
                '   >> step(ss(ad,bd,c,d,1e-6),1e-3)'
                ' '
                ' The response diverges in spite of the continuous-time model being stable!'
                ' The C2D conversion failed to preserve stability on this badly-scaled model.'
            };
            axis(ax,'normal')
            [a,b,c,d] = ssdata(p.poorbal);
            [ad,bd] = c2d(a,b,1e-6);
            step(ss(ad,bd,c,d,1e-6),1e-3)
            title('Step Response of discretized POORBAL (unbalanced)');
        case 3
            txt = {
                ' A useful command to remedy poor scaling is SSBAL.  This command takes a'
                ' state-space model and rescales the states to compress the range of numerical'
                ' values in the A,B,C matrices.  This operation is called "balancing."'
                ' '
                '   >> wellbal = ssbal(poorbal)'
                ' '
                ' The balanced model is shown above.  Note the significanty reduced spread in'
                ' numerical values.'
            };
            set(ax,'visible','off')
            text('Parent',ax,'String','Model after balancing (WELLBAL):','Position',[.01 .9],...
                'FontSize',12+2*isunix,'FontWeight','bold','Hor','left','Ver','middle');
            blk = ' ';
            stra = [['a = ';repmat(blk,[3 4])] num2str(p.wellbal.a,6)];
            strb = [['b = ';repmat(blk,[3 4])] num2str(p.wellbal.b,6)];
            strc = ['c = ' num2str(p.wellbal.c,6)];
            strd = ['d = ' num2str(p.wellbal.d,6)];
            str = str2mat(stra,' ',strb,' ',strc,' ',strd);
            text('parent',ax,'position',[.47 .75],'string',str,'fontsize',8+2*isunix,...
                'fontname','FixedWidth','horiz','center','vertical','top','color',[0 0 .7])
        case 4
            txt = {
                ' Next, repeat the same discretization and simulation steps with the balanced'
                ' model (WELLBAL):'
                ' '
                '   >> [a,b,c,d] = ssdata(wellbal)'
                '   >> [ad,bd] = c2d(a,b,1e-6)'
                '   >> step(ss(ad,bd,c,d,1e-6),1e-3)'
                ' '
                ' The simulation now produces the expected results.'
            };
            [a,b,c,d] = ssdata(p.wellbal);
            [ad,bd] = c2d(a,b,1e-6);
            step(ss(ad,bd,c,d,1e-6),1e-3)
            title('Step Response of discretized WELLBAL (balanced)');
        case 5
            txt = {
                ' Many commands in the Control System Toolbox perform balancing automatically.  This'
                ' includes C2D when applied to a state-space model (as opposed to A,B matrices):'
                ' '
                '   >> poorbal\_d = c2d(poorbal,1e-6)'
                '   >> step(poorbal\_d,1e-3)'
                ' '
                ' Note that the discretized model is now stable thanks to the balancing performed by'
                ' C2D behind the scenes.'
                ' '
                ' {\bfMoral:}  Avoid working with poorly scaled models and use SSBAL to correct'
                ' scaling problems!'
            };
            poorbal_d = c2d(p.poorbal,1e-6);
            step(poorbal_d,1e-3)
            title('Step Response of POORBAL\_D (balanced)');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 3
        % Closing Feedback Loops
        switch slide
        case 0
            % number of slide
            txt = 4;
        case 1
            txt = {
                ' Suppose you want to compute the closed-loop transfer function H from r to y for the'
                ' feedback loop shown above with'
                ' '
                '   >> G = tf([1 2],[1 .5 3])'
                '   >> K = 2'
                ' '
                ' The best way is to use the FEEDBACK command:'
                ' '
                '   >> H1 = feedback(G,K)'
            };
            DrawLoop(ax)
        case 2
            txt = {
                ' From the formula H = G/(1+GK), you could also think of computing H directly as'
                ' '
                '   >> H2 = G/(1+G*K)'
                ' '
                ' Unfortunately this second approach gives bad results in general, as shown above.'
                ' This is because the expression H2, for G = N/D, gets evaluated generically as'
                ' '
                '      H2 = (N/D) / (1+K*N/D)  =  (N/D) * (D/(D+K*N))  =  (N*D) / (D*(D+K*N))'
                ' '
                ' so the poles of G get added to both the numerator and denominator of H.'
            };
            axis(ax,'normal')
            set(ax,'xlim',[0 1],'ylim',[0 1],'visible','off')
            g = tf([1 2],[1 .5 3]);
            k = 2;
            H1 = feedback(g,k);
            H2 = g/(1+g*k);
            s1 = strvcat('>> zpk(H1)',' ',evalc('zpk(H1)'));
            s2 = strvcat('>> zpk(H2)',' ',evalc('zpk(H2)'));
            text('Parent',ax,'Position',[-0.025 .7],'String',s1,...
                'fontsize',10+2*isunix,'fontname','FixedWidth','fontw','bold',...
                'horiz','left','vertical','top','color',[0 0 1],'interp','none')
            text('Parent',ax,'Position',[.375 .7],'String',s2,...
                'fontsize',10+2*isunix,'fontname','FixedWidth','fontw','bold',...
                'horiz','left','vertical','top','color',[1 0 0],'interp','none')
        case 3
            txt = {
                ' This can have dramatic consequences when computing with high-order transfer'
                ' functions.  The more sophisticated example below involves a 17th order transfer'
                ' function G. Compute the closed-loop transfer function for K=1:'
                ' '
                '   >> load numdemo                 % load G model'
                '   >> H1 = feedback(G,1)          % good'
                '   >> H2 = G/(1+G)                   % bad'
                ' '
                ' and compare the closed-loop Bode plots:'
                ' '
                '   >> bode(H1,''b'',H2,''r'')'
            };
            axis(ax,'auto')
            H1 = feedback(p.G,1);
            H2 = p.G/(1+p.G);
            bode(H1,'b',H2,'r')
            title('H1 (blue) vs. H2 (red)');
            h = gcr;
            set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'});
            ax = getaxes(h.AxesGrid);
            set(ax(1),'Ylim',[-50 0]);
            set(ax(2),'Ylim',[-360 360]);
        case 4
            txt = {
                ' The errors in the low frequency response of H2 can be traced to the additional'
                ' (cancelling) dynamics introduced near z=1. Specifically, H2 has about twice as '
                ' many poles and zeros near z=1 than H1.  As a result, the values of H2 near z=1 '
                ' have poor accuracy and the response at low frequencies gets distorted. See the '
                ' "High-Order Transfer Functions" topic for more details.'
                ' '
                ' {\bfMoral:}  Always use the command FEEDBACK to close feedback loops!'
            };
            H1 = feedback(p.G,1);
            H2 = p.G/(1+p.G);
            pzmap(H1,'b',H2,'r')
            title('Poles and zeros of H1 (blue) vs. H2 (red)');
            h = gcr;
            h.AxesGrid.setxlim([-0.5 1.5]);
            h.AxesGrid.setylim([-1 1]);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 4
        % Model Interconnections
        switch slide
        case 0
            % number of slide
            txt = 4;
        case 1
            txt = {
                ' You can connect LTI models using +, *, [ , ], [ ; ], and the commands SERIES,'
                ' PARALLEL, and FEEDBACK.  To ensure that the resulting model has minimal'
                ' order, it is important to follow some simple rules:'
                '    \bullet Convert all models to state-space form before connecting them'
                '    \bullet Respect the block diagram structure and do not use aggregate expressions'
                ' '
                ' As an example, try computing a model for the block diagram sketched above, with'
                ' '
                '   >> G = [1 , tf(1,[1 0]) , 5]'
                '   >> Fa = tf([1 1] , [1 2 5])'
                '   >> Fb = tf([1 2] , [1 3 7])'
            };
            axis(ax,'normal')
            DrawDiagram(ax)
        case 2
            txt = {
                ' Let''s start with the "optimal" way to connect these three blocks:'
                ' '
                '   >> H1 = [ss(Fa) ; ss(Fb)] * G'
                ' '
                ' Note that (a) Fa and Fb are converted to state space, and (b) this operation mirrors'
                ' the block diagram structure.  The resulting model H1 has order 5, which is minimal:'
                ' '
                '   >> size(H1,''order'')'
                ' '
                '   ans = '
                '           5'
            };
            DrawDiagram(ax)
            sysblock('Parent',ax,'Position',[7 -1.45 9 12],...
                'LineWidth',1,'LineStyle',':','FaceColor','none','EdgeColor',[0 0 .7]);
            text('Parent',ax,'Position',[16 -1],'String','  [ Fa ; Fb ]','FontSize',10+2*isunix,...
                'Hor','left','Color',[0 0 .7]);
            %fa = tf([1 1],[1 2 5]);
            %fb = tf([1 2],[1 3 7]);
            %g = [1 , tf(1,[1 0]) , 5];
            %sys = [ss(fa) ; ss(fb)] * g;
        case 3
            txt = {
                ' Let''s now look at the "worst" way to derive a state-space model for this block'
                ' diagram.  Observing that the overall transfer function is H = [Fa * G ; Fb * G],'
                ' you could compute H as'
                ' '
                '   >> H2 = ss( [Fa * G ; Fb * G] )'
                ' '
                ' The order of the resulting model H2 is 14, almost three times higher than H1!'
                ' '
                ' While H2 is a valid model, it contains a lot of duplicated dynamics because'
                ' (a) G appears twice in the expression, and (b) the state-space conversion is'
                ' performed on a 2x3 MIMO transfer matrix.'
            };
            DrawDiagram(ax)
            %fa = tf([1 1],[1 2 5]);
            %fb = tf([1 2],[1 3 7]);
            %g = [1 , tf(1,[1 0]) , 5];
            %sys = ss([fa * g ; fb * g]);
        case 4
            txt = {
                ' Here are a couple additional combinations with their respective fortunes:'
                ' '
                '   >> H3 = ss( [Fa ; Fb] * G )       % order = 14'
                '   >> H4 = ss( [Fa ; Fb] ) * G       % order = 5, lucky...'
                ' '
                ' '
                ' {\bfMoral:}  Use the state-space form for model interconnections, and stay true to'
                ' the block diagram structure.'
            };
            DrawDiagram(ax)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 5
        % High-order Transfer Functions
        switch slide
        case 0
            % number of slide
            txt = 3;
        case 1
            txt = {
                ' When working with medium- to high-order systems (10+ states), avoid the transfer'
                ' function form and use the state-space form whenever possible.  Computations'
                ' involving high-order transfer functions are often plagued by severe loss of'
                ' accuracy, if not plain overflow.  Even a simple product of two transfer functions'
                ' can give surprising results, as shown below.'
                ' '
                ' Start with two discrete-time transfer functions Pd and Cd of order 9 and 2,'
                ' respectively.  Their frequency responses are plotted above.'
                ' '
                '   >> load numdemo               % load Pd,Cd models'
                '   >> bode(Pd,''b'',Cd,''r'')'
            };
            axis(ax,'normal')
            Pd = p.Pd;
            Cd = p.Cd;
            bode(Pd,'b',Cd,'r',{1e-1,1e6});
            h = gcr;
            title('Bode diagram of Pd (blue) and Cd (red)');
            set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'});
            ax = getaxes(h.AxesGrid);
            set(ax,'Xlim',[0.1 1e6]);
            set(ax(1),'Ylim',[-100 100]);
            set(ax(2),'Ylim',[-540 180]);
        case 2
            txt = {
                ' Next compute the product L = Pd*Cd (series connection) three different ways and'
                ' compare the frequency responses: '
                ' '
                '   >> Ltf = Pd * Cd                        % transfer function product'
                '   >> Lzp = zpk(Pd) * Cd               % zero-pole-gain product'
                '   >> Lss = ss(Pd) * Cd                 % state space product'
                '   >> bode(Ltf,''g'',Lzp,''b'',Lss,''r-.'')'
                ' '
                ' The responses of the state-space and zero-pole-gain products match, but the'
                ' response of the transfer function product Ltf is choppy and erratic below'
                ' 100 rad/sec.'
            };
            Ltf = p.Pd * p.Cd;
            Lzp = zpk(p.Pd) * p.Cd;
            Lss = ss(p.Pd) * p.Cd;
            bode(Ltf,'g',Lzp,'b',Lss,'r-.',{1e-1,1e3})
            h = gcr;
            title('Bode diagram of Ltf (green), Lzp (blue), and Lss (red dash)');
            set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'});
            ax = getaxes(h.AxesGrid);
            set(ax(1),'Ylim',[-20 120]);
            set(ax(2),'Ylim',[-180 0]);
        case 3
            txt = {
                ' The loss of accuracy with the transfer function form can be explained by comparing'
                ' the pole/zero maps of Pd and Cd near z=1:'
                ' '
                '   >> pzmap(Pd,''b'',Cd,''r'')'
                ' '
                ' Note the multiple roots near z=1.  Because the relative accuracy of polynomial'
                ' values drops near roots, the relative error on the transfer function value near z=1'
                ' ends up exceeding 100%.  Observing that frequencies below 100 rad/s map to'
                ' |z-1|<1e-3, this explains the erratic results below 100 rad/s.'
                ' '
                ' {\bfMoral:}  Compute with the state-space form and avoid combining transfer functions.'
            };
            Pd = p.Pd;
            Cd = p.Cd;
            pzmap(Pd,'b',Cd,'r')
            h = gcr;
            title('Pole/zero maps of Pd (blue) and Cd (red)');
            h.AxesGrid.setxlim([0 1.05]);
            h.AxesGrid.setylim([-1 1]);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 6
        % Pole Cluster Sensitivity
        switch slide
        case 0
            % number of slides
            txt = 4;
        case 1
            txt = {
                ' Poles of high multiplicity and clusters of nearby poles can be very sensitive to'
                ' round off errors, sometimes with dramatic consequences.  This example compares'
                ' the response of a 15th-order discrete-time state-space model Hss with that of its'
                ' equivalent transfer function model Htf:'
                ' '
                '   >> load numdemo               % load Hss model'
                '   >> Htf = tf(Hss)'
                '   >> step(Hss,''b'',Htf,''r'',20)'
                ' '
                ' The step response of Htf diverges even though the state-space model Hss is'
                ' stable (all poles lie in the unit circle).'
            };
            axis(ax,'normal')
            Hss = p.Hss;
            Htf = tf(Hss);
            step(Hss,'b',Htf,'r',20)
            title('Step response of Hss (blue) and Htf (red)');
        case 2
            txt = {
                ' A comparison of the Bode plots is hardly more favorable:'
                ' '
                '   >> bode(Hss,''b'',Htf,''r'')'
                ' '
                ' Again, the transfer function''s response is quite erratic ...'
            };
            Hss = p.Hss;
            Htf = tf(Hss);
            bode(Hss,'b',Htf,'r')
            h = gcr;
            title('Bode diagram of Hss (blue) and Htf (red)');
            set(h.AxesGrid,'XUnits','rad/sec','YUnits',{'dB';'deg'});
        case 3
            txt = {
                ' These large discrepancies can be understood by comparing the pole/zero maps'
                ' of the state-space model and its transfer function:'
                ' '
                '   >> pzmap(Hss,''b'',Htf,''r'')'
                ' '
                ' Note the tighly packed cluster of poles near z=1 in Hss.  When these poles are'
                ' recombined into the transfer function denominator, roundoff errors perturb the'
                ' pole cluster into an evenly-distributed ring of poles around z=1 (a typical pattern'
                ' for perturbed multiple roots).  Unfortunately here, some perturbed poles cross the'
                ' unit circle, making the transfer function unstable!'
            };
            Hss = p.Hss;
            Htf = tf(Hss);
            pzmap(Hss,'b',Htf,'r');
            h = gcr;
            title('Pole-Zero map of Hss (blue) and Htf (red)');
            h.AxesGrid.setxlim([0.5 1.5]);
            h.AxesGrid.setylim([-1.0 1.0]);
            h.FrequencyUnits = 'rad/sec';
            
            pa = getaxes(h.AxesGrid);
            t = 0:.01:2*pi;
            line('Parent',double(pa),'XData',cos(t),'YData',sin(t),'color','k','linestyle',':')
        case 4
            txt = {
                ' A simple experiment backs these explanations:'
                ' '
                '   >> pss = pole(Hss)                    % poles of Hss'
                '   >> Den = poly(pss)                    % polynomial with roots Pss'
                '   >> ptf = roots(Den)                     % roots of this polynomial'
                '   >> plot(real(pss),imag(pss),''bx'',real(ptf),imag(ptf),''r*'')'
                ' ' 
                ' This confirms that  ROOTS(POLY(R))  can be quite different from R for clustered roots.'
                ' '
                ' {\bfMoral:}  Beware of poles or zeros of high multiplicity!'
            };
            pzmap(tf(1,[1 1],1),'g');
            h = gcr;
            title('Poles of Hss (blue) vs. roots of Den (red)');
            h.AxesGrid.setxlim([0.5 1.5]);
            h.AxesGrid.setylim([-0.2 0.2]);
            
            pa = getaxes(h.AxesGrid);
            set(pa,'HitTest','off');
            t = 0:.01:2*pi;
            line('Parent',double(pa),'XData',cos(t),'YData',sin(t),'Color','k','LineStyle',':')
            line('Parent',double(pa),'XData',[-1 2],'YData',[0 0],'Color','k','LineStyle',':')
            pss = pole(p.Hss);
            ptf = roots(poly(pss));
            line('Parent',double(pa),'XData',real(pss),'YData',imag(pss),'Color','b','LineStyle','none','Marker','x');
            line('Parent',double(pa),'XData',real(ptf),'YData',imag(ptf),'Color','r','LineStyle','none','Marker','*');
        end
    end
end


%------------------- Local Functions

function DrawLoop(ax)
% Draws feedback loop
set(ax,'visible','off','xlim',[-1 21],'ylim',[0 10])
y0 = 7.2;  x0 = 1.5;
wire('parent',ax,'x',x0+[0 2],'y',y0+[0 0],'arrow',0.5);
sumblock('parent',ax,'position',[x0+2.5,y0],'label','-240',...
    'radius',.5,'fontsize',15);
wire('parent',ax,'x',x0+[3 6],'y',y0+[0 0],'arrow',0.5);
sysblock('parent',ax,'position',[x0+6 y0-1.5 3 3],'name','G',...
    'fontsize',12+2*isunix,'fontweight','bold','facecolor',[1 1 .9]);
wire('parent',ax,'x',x0+[9 14],'y',y0+[0 0],'arrow',0.5);
sysblock('parent',ax,'position',[x0+6 y0-7.5 3 3],'name','K',...
    'fontsize',12+2*isunix,'fontweight','bold','facecolor',[1 1 .9]);
wire('parent',ax,'x',x0+[12 12 9],'y',y0+[0 -6 -6],'arrow',0.5);
wire('parent',ax,'x',x0+[6 2.5 2.5],'y',y0+[-6 -6 -0.5],'arrow',0.5);
text('parent',ax,'position',[x0 y0],'string','r ',...
    'horiz','right','fontsize',12+2*isunix,'fontweight','bold');
text('parent',ax,'position',[x0+14 y0],'string',' y',...
    'horiz','left','fontsize',12+2*isunix,'fontweight','bold');
sysblock('parent',ax,'position',[x0+1 y0-8.5 12 11],'num',' ','name',' ',...
    'fontsize',12+2*isunix,'fontweight','bold','facecolor','none',...
    'linestyle',':','linewidth',1,'edgecolor','k');
equation('parent',ax,'position',[x0+13.5,y0-7],'name','H','num','G','den','1+GK',...
    'anchor','left','fontsize',12+2*isunix,'fontweight','bold')


function DrawDiagram(ax)
% Draws blocks for connecting models example
set(ax,'visible','off','xlim',[-2 22],'ylim',[0.3 10.7])
y0 = 5;  x0 = 0;
wire('parent',ax,'x',x0+[0 3],'y',y0+[0 0],'arrow',0.5);
wire('parent',ax,'x',x0+[0 3],'y',y0+[2 2],'arrow',0.5);
wire('parent',ax,'x',x0+[0 3],'y',y0+[-2 -2],'arrow',0.5);
sysblock('parent',ax,'position',[x0+3 y0-3 3 6],'name','G',...
    'fontsize',12+0*isunix,'fontweight','bold','facecolor',[1 1 .9]);
sysblock('parent',ax,'position',[x0+10 y0+3-2 5 4],'name','Fa','num','s+1','den','s^2+2s+5',...
    'fontsize',12+0*isunix,'fontweight','bold','facecolor',[1 1 .9]);
sysblock('parent',ax,'position',[x0+10 y0-3-2 5 4],'name','Fb','num','s+2','den','s^2+3s+7',...
    'fontsize',12+0*isunix,'fontweight','bold','facecolor',[1 1 .9]);
wire('parent',ax,'x',x0+[6 8 8 10],'y',y0+[0 0 3 3],'arrow',0.5);
wire('parent',ax,'x',x0+[6 8 8 10],'y',y0+[0 0 -3 -3],'arrow',0.5);
wire('parent',ax,'x',x0+[15 18],'y',y0+[3 3],'arrow',0.5);
wire('parent',ax,'x',x0+[15 18],'y',y0+[-3 -3],'arrow',0.5);


function p_out = localParameters
%---Parameters/systems used in demo
persistent p;
if isempty(p)
    load numdemo;
    %---Model Type Conversions
    randn('seed',5); rand('seed',0);
    p.HSS1 = rss(3,2,2);
    p.HTF = tf(p.HSS1);
    p.HSS2 = ss(p.HTF);
    %---Balancing
    p.poorbal = poorbal;  % from numdemo
    p.wellbal = ssbal(poorbal);;
    %---Closing Feedback Loops
    p.G = G;   % from numdemo
    %---High-Order Transfer Functions
    p.Pd = Pd;  % from numdemo
    p.Cd = Cd;  % from numdemo
    %---Sensitivity of Multiple Roots
    p.Hss = Hss;  % from numdemo
end
p_out = p;
