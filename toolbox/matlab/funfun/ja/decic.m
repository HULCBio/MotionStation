%DECIC  ODE15I �ɑ΂��閵���̂Ȃ������������v�Z
% [Y0MOD,YP0MOD] = DECIC(ODEFUN,T0,Y0,FIXED_Y0,YP0,FIXED_YP0) �́A
% F(T0,Y0MOD,YP0MOD) = 0 �𖞂����o�͒l�������邽�߂̌J��Ԃ���
% �����̐���l�Ƃ��āA���� Y0,YP0 ���g�p���܂��BDECIC �́A����̗v�f��
% �ł������ύX���Ȃ��悤�ɂ��܂��BY0(i) �̐���ɕύX��������Ă��Ȃ�
% �ꍇ�AFIXED_Y0(i) = 1 �Ɛݒ肷�邱�Ƃɂ��A����v�f���Œ肳���悤
% �Ɏw��ł��A�����łȂ��ꍇ�A0 �Ǝw�肵�܂��BFIXED_Y0 ����̔z��Ƃ���
% �ƁA���ׂĂ̗v�f�ŕύX���\�ł���Ɖ��߂���܂��BFIXED_YP0 �́A���l
% �Ɉ����܂��B
%
% length(Y0) ���������̗v�f���Œ肷�邱�Ƃ͂ł��܂���B���Ɉˑ����āA
% ���ꂾ���������Œ�ł��Ȃ��\��������܂��BY0 �܂��� YP0 �̓����
% �v�f���Œ�ł��Ȃ��\��������܂��B�K�v�ȏ�̗v�f���Œ肵�Ȃ����Ƃ�
% �����߂��܂��B
% 
% [Y0MOD,YP0MOD] = DECIC(ODEFUN,T0,Y0,FIXED_Y0,YP0,FIXED_YP0,OPTIONS)
% �́AODESET �֐��ō쐬���ꂽ�\���́AOPTIONS �̒l�ɂ��u��������ꂽ
% �ϕ������̃f�t�H���g�l���g�p���ď�L�̂悤�Ɍv�Z���܂��B
%
% [Y0MOD,YP0MOD] = DECIC(ODEFUN,T0,Y0,FIXED_Y0,YP0,FIXED_YP0,OPTIONS,P1,P2...)
% �́A�t���p�����[�^ P1,P2,... ���AODEFUN(T,Y,YP,P1,P2...) �Ƃ��āA
% ODE �֐��A����сAOPTIONS �Ɏw�肳�ꂽ���ׂĂ̊֐��ɓn���܂��B
% �I�v�V�������ݒ肳��Ă��Ȃ��ꍇ�A�v���[�X�z���_�Ƃ��� OPTIONS = [] ��
% �g�p���Ă��������B
%
% [Y0MOD,YP0MOD,RESNRM] = DECIC(ODEFUN,T0,Y0,FIXED_Y0,YP0,FIXED_YP0...)
% �́AODEFUN(T0,Y0MOD,YP0MOD) �̃m������ RESNRM �Ƃ��ďo�͂��܂��B
% �m�������傫������悤�ɂ݂���ꍇ�A��菬���� RelTol (�f�t�H���g�́A
% 1e-3) ���w�肷�邽�߂� OPTIONS ���g�p���Ă��������B
%
%
% �Q�l ODE15I, ODESET, IHB1DAE, IBURGERSODE.

% Jacek Kierzenka and Lawrence F. Shampine
% Copyright 1984-2003 The MathWorks, Inc.
