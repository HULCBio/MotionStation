% MF2MF �����o�V�b�v�֐��Ԃł̃p�����[�^�̌���
%
% �\��
% outParams = mf2mf(inParams,inType,outType)
%
% �ڍ�
% ���̊֐��́A�p�����[�^�̏W�����g���āA1�̑g�ݍ��݂̃����o�V�b�v�֐�
% �^�C�v�𑼂̃����o�V�b�v�֐��^�C�v�֕ϊ����܂��Bmf2mf �́A�V���������o
% �V�b�v�֐��ƌÂ������o�V�b�v�֐����ɁA�Ώ̂ȓ_���u�́A���̊֌W��ۂ�
% ���ɂ��܂��B�������A���Ƃ��āA���̕ϊ��ł͏����������ƂɂȂ�܂��B��
% �Ȃ킿�A�o�̓p�����[�^���I���W�i���̃����o�V�b�v�֐��^�C�v�ɖ߂��Ă��A
% �ϊ����ꂽ�����o�V�b�v�֐��̓I���W�i���̂��̂Ɠ����悤�ɂ͌����܂���B% 
% mf2mf �̓��͈����́A���̂Ƃ���ł��B
% 
% inParams    :�ϊ����郁���o�V�b�v�֐��̃p�����[�^
% inType      :�ϊ����郁���o�V�b�v�֐��^�C�v�ɑ΂��镶����
% outType     :�ϊ���̐V���������o�V�b�v�֐��ɑ΂��镶����
%
% ���
%     x = 0:0.1:5;
%     mfp1 = [1 2 3];
%     mfp2 = mf2mf(mfp1,'gbellmf','trimf');
%     plot(x,gbellmf(x,mfp1),x,trimf(x,mfp2))
%
% �Q�l    DSIGMF, GAUSSMF, GAUSS2MF, GBELLMF, EVALMF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
