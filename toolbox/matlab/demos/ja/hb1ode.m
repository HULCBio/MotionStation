% HB1ODE   HindmarshとByrneのスティッフな問題1
% 
% これは、非常に長い区間でのオリジナルのRobertson化学反応問題です。成分
% は、ある一定の極限方向になるので、このことは、Jacobianの再使用に関する
% テストをすることになります。方程式は、負の解の成分に対して、不安定にな
% りますが、誤差の制御により容認できます。そのため、解の成分がゼロになり、
% 負の近似が可能であるため、長い時間区間で多くのコードが不安定になります。
% デフォルトの区間は、HindmarshとByrneのコードEPISODEが安定である、最も
% 長い区間です。システムは、モニタされる保存則を満足します。
% 
%       y(1) + y(2) + y(3) = 1
%   
% 参考文献：A. C. Hindmarsh and G. D. Byrne, Applications of EPISODE: An
% Experimental Package for the Integration of Ordinary Differential
% Equations, in Numerical Methods for Differential Systems, L. Lapidus and
% W. E. Schiesser eds., Academic Press, Orlando, FL, 1976, pp 147-166.
%   
% 参考：ODE15S, ODE23S, ODE23T, ODE23TB, ODESET, @.


%   Mark W. Reichelt and Lawrence F. Shampine, 2-11-94, 4-18-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:48:45 $
