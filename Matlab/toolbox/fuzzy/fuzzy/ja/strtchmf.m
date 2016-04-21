% STRTCHMF は、メンバシップ関数の引き延ばします。
% 
% outParams = STRTCHMF(inParams,inRange,outRange,inType) は、オリジナル
% のメンバシップ関数パラメータと範囲を使って、新しいメンバシップ関数の範
% に適応するパラメータを出力します。
%
% 例題 :
%
%           ri = [0 10]; ro = [-5 30];
%           xi = linspace(ri(1),ri(2));
%           xo = linspace(ro(1),ro(2));
%           pi = [0 5 8];
%           po = strtchmf(pi,ri,ro,'trimf');
%           yi = trimf(xi,pi);
%           yo = trimf(xo,po);
%           subplot(2,1,1), plot(xi,yi,'y');
%           subplot(2,1,2), plot(xo,yo,'c');
%           title('MF Stretching')
%
% 参考： DSIGMF, GAUSSMF, GAUSS2MF, GBELLMF, EVALMF, PIMF, PSIGMF, 
%        SIGMF, SMF, TRAPMF, TRIMF, ZMF.

