% PIMF �Ό^�Ȑ������o�V�b�v�֐�
% 
% PIMF(X,PARAMS) �́AX �Ōv�Z�����Ό^�����o�V�b�v�֐��ł���s����o�͂�
% �܂��B
% PARAMS = [A B C D] �́A���̃����o�V�b�v�֐��̃u���[�N�|�C���g�����肷
% ��4�v�f�x�N�g���ł��B�p�����[�^ A �� D �́A�Ȑ���"��(�Ό^�̒l�̒Ⴍ��
% ��������)"��\���A�p�����[�^ B �� C �́A"��(�Ό^�̒l�̍����Ȃ�������)"
% ��\���܂��B���ɁA���� MF �́ASMF �� ZMF �̐ςł��B
%
%      PIMF(X,PARAMS) = SMF(X,PARAMS(1:2)).*ZMF(X,PARAMS(3:4))
%
% ���̃� MF �́A4�̃p�����[�^�������߁A�Ώ̂ɂȂ�Ȃ����Ƃɒ��ӂ���
% ���������B���̂��Ƃ́A2�̃p�����[�^�݂̂��g���A����܂ł̃� MF �ƈ�
% �Ȃ�܂��B
%
% ���:
%    x = (0:0.1:10)';
%    y1 = pimf(x,[1 4 9 10]);
%    y2 = pimf(x,[2 5 8 9]);
%    y3 = pimf(x,[3 6 7 8]);
%    y4 = pimf(x,[4 7 6 7]);
%    y5 = pimf(x,[5 8 5 6]);
%    plot(x,[y1 y2 y3 y4 y5]);
%    set(gcf,'name','pimf','numbertitle','off');
%
% �Q�l    DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
