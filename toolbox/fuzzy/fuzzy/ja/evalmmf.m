% EVALMMF �����̃����o�V�b�v�֐��v�Z
% EVALMMF(X,MF_PARA,MF_TYPE) �́Ai�Ԗڂ̍s���A�^�C�v MF_TYPE(i,:) �ƃp
% �����[�^MF_PARA(i,:) ������ MF �̃����o�V�b�v�K���ł���s����o�͂���
% ���B
% 
% MF_TYPE ���P
% ��̕�����ł���ꍇ�A��������ׂĂ̌v�Z�Ɏg�p���܂��B
%
% ���:
%    x = 0:0.2:10;
%    para = [-1 2 3 4; 3 4 5 7; 5 7 8 0; 2 9 0 0];
%    type = str2mat('pimf','trapmf','trimf','sigmf');
%    mf = evalmmf(x,para,type);
%    plot(x',mf');
%    set(gcf,'name','evalmmf','numbertitle','off');
%
% �Q�l    DSIGMF, GAUSS2MF, GAUSSMF, GBELLMF, EVALMF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
