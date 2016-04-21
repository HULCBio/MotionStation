function result=xpcbench(flag,quiet,bench,f14complexity)
% XPCBENCH Execute xPC Target benchmarks and show result
%
%   XPCBENCH is very similar to the famous BENCH utility which comes with
%   MATLAB. BENCH benchmarks this machine using MATLAB features and compares
%   the result with pre-stored benchmark results of other machines. By
%   executing BENCH on this machine you get an impression of how this utility
%   works. XPCBENCH, as the name implies, is a utility to benchmark xPC Target
%   performance. In other words, it measures the execution performance of
%   real-time applications on your target PC.
%
%   The pre-stored benchmarks results are labeled with CPU type and
%   CPU clock rate of the PC which was used for this particular
%   benchmark. All pre-stored benchmarks have been built with
%   Visual C/C++ 6.0 Professional. Some of the pre-stored benchmarks
%   results are based on builds with other compilers or versions.
%   The benchmark labels reflect this:
%       .NET    : Visual C/C++ .NET Professional
%       .NET03  : Visual C/C++ .NET 2003 Professional
%
%   XPCBENCH without an argument displays the pre-stored benchmark results
%   without running the benchmark on this xPC Target environment. The first
%   figure displays the results of the 5 benchmarks executed on several target
%   PCs with different types of CPUs. The benchmark results are displayed in
%   microseconds and stand for the minimal achievable base sample time for
%   that real-time application (benchmark) executed on that specific target
%   PC. The second figure displays a summary of the benchmark results
%   (relative performance) using a bar graph.
%
%   The 5 benchmarks are:
%     1. Minimal: This is based on a "minimal" model just consisting of three
%                 blocks (Constant, Gain, Termination). The model has neither
%                 continuous nor discrete states. The result of this benchmark
%                 gives an impression about the target PC specific latencies.
%
%     2. F14 :    This is based on the standard Simulink example model
%                 'f14'. Type f14 at the MATLAB command line prompt to open
%                 the model and get an impression of the model complexity.
%                 The model contains 62 blocks and defines 10 continuous
%                 states.
%
%      3. F14*5 : This is based on the standard Simulink example model 'f14'
%                 as well, but this benchmark model consists of 5 f14
%                 systems modeled in subsystems. This benchmark is
%                 therefore 5 times more demanding than benchmark 2.
%                 (310 blocks, 50 continuous states)
%
%     4. F14*10 : This benchmark contains 10 f14 systems
%                 (620 blocks, 100 continuous states)
%
%     5. F14*25 : This benchmark contains 25 f14 systems
%                 (1550 blocks, 500 continuous states)
%
%   XPCBENCH('this') runs the benchmarks on your xPC Target environment. At
%   the time you invoke the benchmark execution xPC Target has to be fully
%   set up and functional; therefore, a target system has to be connected and
%   the xPC Target test XPCTEST has to have successfully run. The benchmark
%   execution takes about 10 minutes. This includes the generation of the
%   Simulink benchmark models, the xPC Target application build and the
%   automatic search for the smallest achievable sample time for all 5
%   benchmarks. After the execution of the benchmarks the result will be
%   displayed along with the pre-stored benchmark results found for other
%   machines.
%
%   See also XPCTEST.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.13.6.5 $ $Date: 2004/04/08 21:05:30 $

index= findobj(0,'Name','xPC Target Benchmark - Overview');
if ~isempty(index)
    close(index);
end
index= findobj(0,'Name','xPC Target Benchmark - Details');
if ~isempty(index)
    close(index);
end


doThis=0;
nMachine=19;
nBench=5;

if nargin >= 1

    if strcmp(flag,'this')
        doThis=1;
        nMachine=nMachine+1;
    end

end

if doThis

    if nargin<3
        res=benchThis;
    end
    if nargin==3
        res=benchThis(bench);
    end

    if nargin==4
        res=benchThis(bench,f14complexity);
    end

    if nargout==1
        result=res;
    end

    if nargin<2
        benchdata(nMachine).Machine='This Machine        ';
        benchdata(nMachine).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
        benchdata(nMachine).BenchResults=[res(1).Tsmin,res(2).Tsmin,res(3).Tsmin,res(4).Tsmin,res(5).Tsmin];
    end


end

benchdata(1).Machine='Intel PIII 600MHz   ';
benchdata(1).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(1).BenchResults=[0.000008,0.000013,0.000039,0.000097,0.000363];

benchdata(2).Machine='AMD Athlon 1GHz     ';
benchdata(2).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(2).BenchResults=[0.000010,0.000013,0.000024,0.000041,0.000109];

benchdata(3).Machine='Intel 486DX 40MHz   ';
benchdata(3).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(3).BenchResults=[0.000043,0.000375,0.001900,0.003800,0.012500];

benchdata(4).Machine='Intel PII 400MHz    ';
benchdata(4).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(4).BenchResults=[0.000008,0.000016,0.000058,0.000135,0.000502];

benchdata(5).Machine='AMD K6-2 400MHz     ';
benchdata(5).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(5).BenchResults=[0.000010,0.000024,0.000075,0.000159,0.000755];

benchdata(6).Machine='Intel PI 166MHz     ';
benchdata(6).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(6).BenchResults=[0.000011,0.000044,0.000253,0.000567,0.001681];

benchdata(7).Machine='Intel PI 90MHz      ';
benchdata(7).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(7).BenchResults=[0.000027,0.000100,0.000590,0.001400,0.004600];

benchdata(8).Machine='Intel P4 1.5GHz     ';
benchdata(8).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(8).BenchResults=[0.000010,0.000015,0.000031,0.000056,0.000133];

benchdata(9).Machine='xPC TargetBox 106   ';
benchdata(9).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(9).BenchResults=[0.000012,0.000034,0.000120,0.000287,0.001303];

benchdata(10).Machine='xPC TargetBox 107   ';
benchdata(10).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(10).BenchResults=[0.00001,0.000019,0.0000620,0.000126,0.000340];

benchdata(11).Machine='xPC TargetBox 108   ';
benchdata(11).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(11).BenchResults=[0.000011,0.000017,0.000042,0.000087,0.000236];

benchdata(12).Machine='MachZ 128Mhz        ';
benchdata(12).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(12).BenchResults=[0.000056,0.000254,0.001439,0.0031847,0.007939];

benchdata(13).Machine='Intel P4 2.0GHz     ';
benchdata(13).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(13).BenchResults=[0.000013,0.000016,0.000030,0.000052,0.000119];

benchdata(14).Machine='AMD Athlon XP 1.6GHz';
benchdata(14).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(14).BenchResults=[0.000014,0.000016,0.000025,0.000036,0.000080];

benchdata(15).Machine='Intel PIII 1.0GHz   ';
benchdata(15).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(15).BenchResults=[0.000010,0.000013,0.000025,0.000045,0.000124];


benchdata(16).Machine='Intel P4 3GHz .NET  ';
benchdata(16).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(16).BenchResults=[0.000010,0.000012,0.000019,0.000029,0.000055];

benchdata(17).Machine='Intel P4 3GHz .NET03';
benchdata(17).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(17).BenchResults=[0.000009,0.000011,0.000014,0.000019,0.000035];

benchdata(18).Machine='AMD 2800+ .NET      ';
benchdata(18).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(18).BenchResults=[0.000014,0.000016,0.000021,0.000029,0.000060];

benchdata(19).Machine='AMD 2800+ .NET03    ';
benchdata(19).Benchmarks={'Minimal','F14','F14*5','F14*10','F14*25'};
benchdata(19).BenchResults=[0.000014,0.000016,0.000020,0.000025,0.000041];



doDisplay=1;
if nargin>=2
    if strcmp(quiet,'quiet')
        doDisplay=0;
    end
end

if doDisplay

    bench=cat(1,benchdata.BenchResults);
    bench=1./bench;
    bench(:,1)=sum(bench(:,1:2)')'./2;
    bench(:,2)=[];
    for i=1:size(bench,2)
        bench(:,i)=bench(:,i)./(sum(bench(:,i))/nMachine);
    end
    bench=sum(bench')'./nBench;
    [bench,k] = sort(bench);
    this= zeros(nMachine,1);
    if doThis
        this(find(k==nMachine))=1;
    end
    specs={};
    for i=1:length(benchdata)
        specs=[specs,{benchdata(i).Machine}];
    end
    specs = specs(k);

    figure
    barh(bench.*(1-this),'y');
    fig=gcf;
    set(gca,'XLim',[0, max(bench)*1.05]);
    ymax= nMachine+1;
    if nargin==1
        hold on
        barh(bench.*this,'m');
        set(gca,'XLim',[0 max(bench)*1.05]);
        ymax= ymax+1;
    end
    set(gca,'YLim',[0, ymax]);
    set(gca,'YTick',[1:1:nMachine]);
    set(gca,'yticklabel',specs);
    set(gca,'FontName','Courier','FontWeight','normal');
    set(gca,'Units','Normalized','Position',[0.3,0.15,0.65,0.75]);
    title('Relative Performance','FontName','Arial','FontSize',12)
    grid
    hold off
    set(gcf,'Name','xPC Target Benchmark - Overview','NumberTitle','off');
    h=text(-0.1,-1.85,'See ''help xpcbench'' for more information');
    set(h,'FontSize',11,'Color','r');

    fig2 = figure('pos',get(gcf,'pos')+[50 -150 0 0]);
    axes('Position',[0 0 1 1])
    axis off
    x0 = .02;
    y0 = .80;
    dy = (y0-.1)/(nMachine+1);
    s = [blanks(25) 'Minimal    F14     F14*5   F14*10   F14*25'];
    text(x0,y0,s,'horizontal','left','fontname','courier');
    for k1 = nMachine:-1:1
        y = y0-(nMachine+1-k1)*dy;
        x = x0;
        s = [specs{k1} sprintf('%9.0f',benchdata(k(k1)).BenchResults*1e6)];
        h = text(x,y,s,'horizontal','left','fontname','courier');
        if this(k1), set(h,'color','b'), end
    end
    h=text(0.22,0.9,['Minimal achievable sample times in ',181,'s']);
    set(h,'FontSize',14);
    set(gcf,'Name','xPC Target Benchmark - Details','NumberTitle','off');
    figure(fig);

end

function res=benchThis(bench,f14complexity)

if ~strcmp(xpctargetping,'success')
    error('Connection to target cannot be established');
end

minbench=0;
f14bench=0;
if nargin==0
    minbench=1;
    f14bench=1;
    f14n=[1,5,10,25];
end
if nargin>=1
    if strcmp(bench,'minimal')
        minbench=1;
        f14bench=0;
    else
        minbench=0;
        f14bench=1;
        if nargin==2
            f14n=f14complexity;
        else
            f14n=1;
        end
    end
end


k=1;


if minbench

    % minimal

    try, bdclose('minimal'); end
    new_system('minimal');
    add_block('built-in/Constant','minimal/Constant');
    add_block('built-in/Gain','minimal/Gain');
    add_block('built-in/Terminator','minimal/Terminator');
    add_line('minimal','Constant/1','Gain/1');
    add_line('minimal','Gain/1','Terminator/1');

    h=Simulink.ConfigSet;
    h.name='xpcconfig1';
    attachConfigSet('minimal',h);
    switchTarget(h, 'xpctarget.tlc',[]);
    setActiveConfigSet('minimal',h.name);
    set_param(h,'TemplateMakefile','xpc_default_tmf');
    
    set_param(h,'ExtMode','on');
    set_param(h,'ForceParamTrailComments','off');
    set_param(h,'InlineInvariantSignals','on');
    set_param(h,'InlineParams','off');
    set_param(h,'RL32IRQSourceModifier','Timer');
    set_param(h,'RL32LogBufSizeModifier','100000');
    set_param(h,'RL32LogTETModifier','off');
    set_param(h,'RL32ModeModifier','Real-Time');
    set_param(h,'RL32ObjectName','tg');
    set_param(h,'RTWVerbose','on');
    set_param(h,'RollThreshold','5');
    set_param(h,'ShowEliminatedStatement','on');
    
   


    set_param(h,'OptimizeBlockIOStorage','off');
    set_param(h,'BufferReuse','off');
    set_param(h,'ParameterPooling','off');
    set_param(h,'BooleanDataType','off');
    set_param(h,'BlockReduction','off');
    set_param(h,'SaveState','off');

    set_param(h,'Solver','FixedStepDiscrete');
    set_param(h,'FixedStep','0.001');

        
    res(k).Name='Minimal';
    res(k).nBlocks=length(find_system(bdroot,'Type','block'));

    tic;
    rtwbuild('minimal');
    res(k).BuildTime=toc;

    close_system('minimal',0);
    tic;
    res(k).Tsmin=dobench(0.001);
    res(k).BenchTime=toc;

    k=k+1;

end

if f14bench

    for i=1:length(f14n)

        nf14(f14n(i));

        h=Simulink.ConfigSet;
        h.name='xpcconfig2';
         attachConfigSet('f14tmp',h);
        switchTarget(h, 'xpc',[]);
        setActiveConfigSet('f14tmp',h.name);
        switchTarget(h, 'xpctarget.tlc',[]);
        set_param(h,'TemplateMakefile','xpc_default_tmf');
        
        set_param(h,'ExtMode','on');
        set_param(h,'ForceParamTrailComments','off');
        set_param(h,'InlineInvariantSignals','on');
        set_param(h,'InlineParams','off');
        set_param(h,'RL32IRQSourceModifier','Timer');
        set_param(h,'RL32LogBufSizeModifier','100000');
        set_param(h,'RL32LogTETModifier','off');
        set_param(h,'RL32ModeModifier','Real-Time');
        set_param(h,'RL32ObjectName','tg');
        set_param(h,'RTWVerbose','on');
        set_param(h,'RollThreshold','5');
        set_param(h,'ShowEliminatedStatement','on');
      
        set_param(h,'OptimizeBlockIOStorage','off');
        set_param(h,'BufferReuse','off');
        set_param(h,'ParameterPooling','off');
        set_param(h,'BooleanDataType','off');
        set_param(h,'BlockReduction','off');
        set_param(h,'SaveState','off');

        set_param(h,'Solver','ode4');
        set_param(h,'FixedStep','0.010');
        set_param(h,'SolverMode','SingleTasking');
        
        res(k+i-1).Name=['F14_',num2str(f14n(i))];
        res(k+i-1).nBlocks=length(find_system('f14tmp','Type','block'));

        tic;
        rtwbuild('f14tmp');
        res(k+i-1).BuildTime=toc;

        close_system('f14tmp',0);
        tic;
        res(k+i-1).Tsmin=dobench(0.001*f14n(i));
        res(k+i-1).BenchTime=toc;

    end

end


function nf14(n)

open_system('f14');

replace_block('f14/u','Inport','built-in/Ground','noprompt');
replace_block('f14/Nz Pilot (g)','Outport','built-in/Terminator','noprompt');
replace_block('f14/alpha (rad)','Outport','built-in/Terminator','noprompt');

try,bdclose('f14tmp'), end
new_system('f14tmp');
open_system('f14tmp');

add_block('built-in/Subsystem','f14tmp/Subsystem');
open_system('f14tmp/Subsystem');

cpymdl('f14','f14tmp/Subsystem');

close_system('f14tmp/Subsystem');

close_system('f14',0);

%set_param('f14tmp/Subsystem','TreatAsAtomicUnit','on');
%set_param('f14tmp/Subsystem','RTWSystemCode','Function');


for i=1:n-1
    add_block('f14tmp/Subsystem',['f14tmp/Subsystem',num2str(i)]);
    %set_param(['f14tmp/Subsystem',num2str(i)],'TreatAsAtomicUnit','on');
    %set_param(['f14tmp/Subsystem',num2str(i)],'RTWSystemCode','Function');
end



function cpymdl(src,dst)

blocks = find_system(src,'SearchDepth',1,'Type','block');

nblks = size(blocks,1);
marker = length(src)+1;

for i=1:nblks

    blk = blocks{i};

    pos = get_param(blk,'Position');
    ort = get_param(blk,'Orientation');

    add_block(blk,[dst,blk(marker:end)],'Position',pos,'Orientation',ort);

end

lines=get_param(src,'Lines');
for i=1:length(lines),
    loc_copy_line(lines(i),dst);
end

function loc_copy_line(ln,sys)

lnlen = norm(ln.Points(end,:)-ln.Points(1,:));
if (lnlen ~= 0)
    add_line(sys,ln.Points);
    drawnow;
end

if (~isempty(ln.Branch))

    for i=1:length(ln.Branch),
        loc_copy_line(ln.Branch(i),sys);
    end

end



function Tsmin=dobench(startTs)

tg=xpc;

tg.stoptime=1;

low=8e-6;
high=startTs;

found=0;

while ~found
    mid=(high-low)/2+low;
    tg.sampletime=mid;
    start(tg);
    pause(2);
    if strcmp(tg.CPUOverload,'detected')
        low=mid;
    else
        high=mid;
    end
    if (high-low)<0.5e-6
        found=1;
    end
end

Tsmin=high;
