% STEP �́AIDMODELs�̃X�e�b�v�������v�Z���܂��BIDDATA �Z�b�g���璼�ڌv�Z
% �ł��܂��B
%
% STEP(MOD) �́AIDMODEL ���f�� MOD(IDPOLY, IDARX, IDSS, IDGREY �̂�����
% ����) �̃X�e�b�v�������v���b�g���܂��B
%
% STEP(DAT) �́AIDDATA �I�u�W�F�N�g�Ƃ��ė^�����f�[�^�Z�b�g DAT ����X�e
% �b�v�������v�Z���A�v���b�g���܂��B
%
% �����̓��f���ɑ΂��āAstep �R�}���h���X�̓��̓`�����l���ɓK�p���܂��B
%
% STEP(MOD,'sd',K) �́A�W���΍� K �ɑΉ�����M����Ԃ��v���b�g���܂��B
%
% STEP(MOD,[T1 T2]) �́A���� t = T1 ���� T2 �܂ł̃X�e�b�v�������v�Z����
% ���BT1 ���ȗ�����Ă���ꍇ�At = -T2/4 ���� T2 �܂ł̊ԂŌv�Z����܂��B
% �f�[�^���璼�ڃX�e�b�v�������v�Z����ꍇ�A�f�[�^���Ƀt�B�[�h�o�b�N�̉e
% ����������ꍇ������܂�(t = 0 �O�̉���)�B������ԃx�N�g���́AMOD ��
% ���炩�̒l���ݒ肳��Ă���ꍇ�ł��A��Ƀ[���ƂȂ�܂��B
%
% �X�e�b�v�́A(T1 �Ɋւ�炸)���t = 0 �Ő����Ă���Ɖ��肵�Ă��܂��B
%
% STEP(MOD1,MOD2,..,DAT1,..,T) �́A�}���` IDMODEL ���f���̃X�e�b�v�����ƁA
% IDDATA �Z�b�g MOD1,MOD2,...,DAT1,...��P��v���b�g��ɕ\�����܂��B����
% �x�N�g��T ���I�v�V�����Ƃ��Đݒ肷�邱�Ƃ��ł��܂��B���[�U�́A�e�V�X�e
% ���̃J���[�A���C���X�^�C���A�}�[�J�����̂悤�ɐݒ肷�邱�Ƃ��ł��܂��B
%      STEP(MOD1,'r',MOD2,'y--',MOD3,'gx').
%
% ���̂悤�ɁA���ӂɈ�����ݒ肷��ƁA
% 
%      [Y,T,YSD] = STEP(MOD) 
% 
% �o�͉��� Y �ƃV�~�����[�V�����Ɏg�p�������ԃx�N�g�� T ���o�͂��܂��B�X
% �N���[����Ƀv���b�g�\���͍s���܂���BMOD ��NY �o�́ANU ���͂̏ꍇ�A
% LT = length(T)�ƂȂ�܂��BY �́A�T�C�Y [LT NY NU] �̔z��ŁAY(:,:,j) 
% �́Aj �Ԗڂ̓��̓`�����l���̃X�e�b�v������^���܂��BYSD �́AY �̕W����
% �����܂�ł��܂��B
%   
% DATA ���� MOD = STEP(DAT) �ɑ΂��āA�X�e�b�v�����̃��f���� IDARX �I�u
% �W�F�N�g�Ƃ��ďo�͂��܂��B����́ASTEP(MOD) �ɂ��v���b�g�ł��܂��B
%
% �f�[�^���g�����X�e�b�v�����̌v�Z�́A'long' FIR ���f�����x�[�X�ɁA�K��
% �ȃv���z���C�g�j���O���ꂽ���͐M�����g���Čv�Z����܂��B�v���z���C�g�j
% ���O�t�B���^�̎���(�f�t�H���g��10)�́A���͈������X�g���ɕ\��� STEP
% ( ....,'PW',NA,... ) �̂悤�Ƀv���p�e�B���ƒl�̑g�Ƃ��� NA �ɐݒ肵�܂��B
%
% ���ӁF
% IDMODEL/STEP �� IDDATA/STEP �́A�����ƂƋ��ɒ������邽�߂Ɏg���܂��B
% CONTROL SYSTEM TOOLBOX �������Ă��āALTI/STEP �ɃA�N�Z�X�������ꍇ�A
% VIEW(MOD1,....,'step') ���g���܂��B 

%   L. Ljung 10-2-90,1-9-93


%   Copyright 1986-2001 The MathWorks, Inc.
