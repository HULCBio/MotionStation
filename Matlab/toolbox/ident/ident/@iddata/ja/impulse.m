% IMPULSE �́AIDMODELs �̃C���p���X�������v�Z���AIDDATA �Z�b�g���璼�ڐ�
% �肳��܂��B
%
% IMPULSE(MOD) �́AIDMODEL ���f�� MOD(IDPOLY, IDARX, IDSS, IDGREY)�̃C��
% �p���X�������v���b�g���܂��B 
%
% IMPULSE(DAT) �́AIDDATA �I�u�W�F�N�g�Ƃ��ė^������f�[�^�Z�b�g DAT ��
% ��C���p���X�������v�Z���A�v���b�g���܂��B���n��f�[�^�ɓK�p���邱�Ƃ�
% �ł��܂���B�T�u�`�����l���̉����݂̂��v���b�g���邽�߂ɂ́A���̂悤
% �Ɏ��s���܂��B
%
%     IR = IMPULSE(DAT);
%     IMPULSE(IR(INPUTS,OUTPUTS))
%
% �����̓��f���ɑ΂��āA�Ɨ������C���p���X�w�߂��X�̓��̓`�����l���ɓK
% �p����܂��B
%
% IMPULSE(MOD,'sd',K) �́A�[���̎���̗̈�Ƃ��ĕW���΍� K ����ɐM��
% ��Ԃ��v���b�g���܂��B���̗̈�̊O���̔C�ӂ̉����́A���̂悤��"�L��"
% �ł��B�ш�Ƃ��ĐM����Ԃ��������߂ɁAIMPULSE(M,'sd',3,'fill') ��
% ����Ƀ��f���̌�Ɉ��� 'FILL' �������Ă��������B
%
% IMPULSE �̓f�t�H���g��stem�v���b�g���g���܂��B�W���̃v���b�g�ɕύX
% ����ɂ́A���f���̌�� IMPULSE(M,'plot') �Ƃ��Ĉ��� 'PLOT' ��ǉ�����
% ���������B���̏ꍇ�A�M�����̂Ȃ���Ԃ��тƂ��ĉ����̎���Ɏ�����܂��B
%
% IMPULSE(MOD,[T1 T2]) �́At = T1 ���� T2 �̃C���p���X�������V�~�����[�V
% �������܂��BT1 ���ȗ�����Ă���ꍇ�́A-T2/4����T2�ɂȂ�܂��B�f�[�^��
% �璼�ڐ��肷��C���p���X�����Ɋւ��āA�f�[�^���Ƀt�B�[�h�o�b�N�̉e����
% �����ꍇ������܂�(t = 0 �ȑO�̉���)�B������ԃx�N�g���́AMOD�ŉ��炩��
% �l�ɐݒ肳��Ă���ꍇ�ł���Ƀ[���ƂȂ�܂��B
%
% �C���p���X�́At = 0�ŏ�ɐ����Ă���Ɖ��肵�Ă��܂�(Ti �̒l�Ɋւ�炸)�B
% ����:
%     �p���X�̓T���v�����O�Ԋu T �Ő��K������Ă���A0<t<T �ɑ΂��� u(t)=
%     1/T �ƂȂ�A���̑��̏ꍇ�[���ɂȂ�܂��B
%
% IMPULSE(MOD1,MOD2,..,DAT1,..,T) �́A������ IDMODEL ���f���̃C���p���X��
% ���� IDDATA �Z�b�g MOD1,MOD2,...,DAT1,...��P��v���b�g��ɕ\�����܂��B
% ���ԃx�N�g�� T �̓I�v�V�����ł��B���[�U�́A�J���[�A���C���X�^�C���A�}�[
% �J���e�V�X�e�����ƂɁA���̂悤�ɐݒ�ł��܂��B
% 
%      IMPULSE(MOD1,'r',MOD2,'y--',MOD3,'gx').
%
% ���ӂ̈����ƃ��f���̓��͈�����ݒ肵�āA
% 
%      [Y,T,YSD] = IMPULSE(MOD) 
% 
% �́A�o�͉��� Y �ƃV�~�����[�V�������ɓK�p���ꂽ���ԃx�N�g�� T ���o�͂�
% �܂��B�v���b�g�́A�X�N���[����ɕ\������܂���BMOD ���ANY �o�́ANU ��
% �͂������ALT = length(T) �̏ꍇ�AY �́A�T�C�Y[LT NY NU] �̔z��ɂȂ��
% ���B�����ŁAY(:,:,j) �́Aj �Ԗڂ̓��̓`�����l���̃C���p���X������^����
% ���BYSD �́AY �̕W���΍����܂�ł��܂��B
%   
% DATA ���� MOD = IMPULSE(DAT) �ɑ΂��āA�C���p���X�����̃��f���� IDARX 
% �I�u�W�F�N�g�Ƃ��āA�o�͂��܂��B����́AIMPULSE(MOD) ���g���āA�v���b�g
% �ł��܂��B
%
% �f�[�^����̃C���p���X�����̌v�Z�́A�K�؂ȃv���z���C�g�j���O���ꂽ����
% �M�����g�����A'long' FIR ���f�����x�[�X�ɂ��Ă��܂��B�v���z���C�g�j���O
% �t�B���^�̎���(�f�t�H���g��10)�́A�v���p�e�B���ƒl��g�ɂ��� NA �Őݒ�
% �ł��AIMPULSE( ....,'PW',NA,... ) �̂悤�ɓ��͈������X�g�̔C�ӂ̈ʒu��
% �ݒ�ł��܂��B
%
% ���ӁF
% IDMODEL/IMPULSE �� IDDATA/IMPULSE �́A�����ƂŎg�p����悤�ɒ�������
% ���BCONTROL SYSTEM TOOLBOX �������Ă��āALTI/IMPULSE �ɃA�N�Z�X��������
% ���́APLOT(MOD1,...,'impulse') ���g���Ă��������B


%   Copyright 1986-2001 The MathWorks, Inc.
