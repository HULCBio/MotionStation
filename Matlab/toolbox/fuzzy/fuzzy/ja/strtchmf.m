% STRTCHMF �́A�����o�V�b�v�֐��̈������΂��܂��B
% 
% outParams = STRTCHMF(inParams,inRange,outRange,inType) �́A�I���W�i��
% �̃����o�V�b�v�֐��p�����[�^�Ɣ͈͂��g���āA�V���������o�V�b�v�֐��̔�
% �ɓK������p�����[�^���o�͂��܂��B
%
% ��� :
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
% �Q�l�F DSIGMF, GAUSSMF, GAUSS2MF, GBELLMF, EVALMF, PIMF, PSIGMF, 
%        SIGMF, SMF, TRAPMF, TRIMF, ZMF.

