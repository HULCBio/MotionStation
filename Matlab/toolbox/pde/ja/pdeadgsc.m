% PDEADGSC   ���΋��e�K�͂��g���āA�O�p�`��I�����܂��B
%
% BT = PDEADGSC(P,T,C,A,F,U,ERRF,TOL) �́ABT �ōו��������ׂ��O�p�`��
% �C���f�b�N�X���o�͂��܂��B
%
% PDE ���̌`��́A�O�p�`�f�[�^ P, T �ɂ���ė^�����܂��A�ڍׂ́AIN-
% ITMESH ���Q�Ƃ��Ă��������B
%
% C, A, F �́APDE �W���ł��B�ڍׂ́AASSEMPDE ���Q�Ƃ��Ă��������B
%
% U �́A��x�N�g���ŗ^����ꂽ�J�����g�̉��ł��B�ڍׂ́AASSEMPDE ���Q��
% ���Ă��������B
%
% ERRF �́APDEJMPS �Ōv�Z�����덷�C���W�P�[�^�ł��B
%
% TOL �́A�덷�̋��e�͈̓p�����[�^�ł��B
%
% �O�p�`�́ASCALE ���ȉ��̂悤�Ɍv�Z�����Ƃ���ŁA���� ERRF>TOL*
% SCALE ���g���đI������܂��B
% CMAX �� C �̍ő�l�Ƃ��܂��B
% AMAX �� A �̍ő�l�Ƃ��܂��B
% FMAX �� F �̍ő�l�Ƃ��܂��B
% UMAX �� U �̍ő�l�Ƃ��܂��B
% �`����܂ލł������������`�̕ӂ�L�Ƃ��܂��B
%
% SCALE = MAX(FMAX*L^2,AMAX*UMAX*L^2,CMAX*UMAX) �Ƃ��܂��B���̃X�P�[����
% �O�́A�������̃X�P�[�����O�ƌ`��Ƃ͓Ɨ��Ƀp�����[�^ TOL �����܂��B
% 
% �Q�l   ADAPTMESH, PDEJMPS



%       Copyright 1994-2001 The MathWorks, Inc.
