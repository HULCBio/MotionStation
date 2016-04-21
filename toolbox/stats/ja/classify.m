% CLASSIFY   ���ʕ���
%
% CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP) �́ASAMPLE �̃f�[�^�̊e�s��
% TRAINING �̃O���[�v�̒l�Ɋ��蓖�Ă܂��BSAMPLE ��TRAINING �́A�����̗��
% ���s��ł���K�v������܂��BGROUP�́ATRAINING �ɑ΂���O���[�v���ϐ�
% �ł��B���̒l�́A�O���[�v���`���A�e�v�f�́A�ǂ̃O���[�v��TRAINING ��
% �s�ɑ����Ă��邩�����肵�܂��BGROUP �́A���l�x�N�g���A������z��A
% ������̃Z���z��̂����ꂩ�Őݒ�ł��܂��BTRAINING ��GROUP �́A������
% �s�ł��BCLASSIFY �́AGROUP��NaNs�A���邢�́A��̕�����������l�Ƃ���
% ��舵���ATRAINING�̑Ή�����s�𖳎����܂��BCLASS�́ASAMPLE �̊e�s���A
% �ǂ̃O���[�v�Ɋ��蓖�Ă��邩�������AGROUP �Ɠ����^�C�v�������܂��B
%
% [CLASS,ERR] = CLASSIFY(SAMPLE,TRAINING,GROUP) �́A�딻�ʂ���G���[��
% �����̐�����o�͂��܂��BCLASSIFY �́A�������̃G���[�̊����A �����A
% �딻�ʂ��ꂽ TRAINING �̊ϑ��l�̕S�������o�͂��܂��B
%
% CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP,TYPE) �ł́A���ʊ֐��̃^�C�v���A
% 'linear', 'quadratic' ���邢�́A'mahalanobis'�̂����ꂩ�Ɏw�肷�邱�Ƃ�
% �ł��܂��B���`���ʂ́A�����U�̑�\�I�Ȑ����p���āA�e�O���[�v�ɑ��ϗ�
% ���K���z���x���t�B�b�e�B���O���܂��B2�����ʂ́A�O���[�v���ɊK�w�����ꂽ
% �����U�����p���āAMVN ���x���t�B�b�e�B���O���܂��BMahalanobis���ʂ́A
% �K�w�����ꂽ�����U�̐����p���āAMahalanobis�������g�p���܂��BTYPE �́A
% �f�t�H���g�ł́A'linear'�ł��B
%
% CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP,TYPE,PRIOR) �ɂ��A3�̕��@��
% �����ꂩ1�ŁA�O���[�v�ɑ΂��鎖�O�m�����w�肷�邱�Ƃ��ł��܂��B
% PRIOR �́AGROUP �̈�ӓI�Ȓl�̐��Ɠ��������̐��l�I�ȃx�N�g���ƂȂ邱�Ƃ�
% �ł��܂��BGROUP���A���l�ł���ꍇ�APRIOR �̏��Ԃ́AGROUP�Ƀ\�[�g�����
% ����l�ɑΉ����A���邢�́AGROUP ����������܂ޏꍇ�AGROUP�̒l�̍ŏ���
% ���ۂ̏��ԂɑΉ����܂��BPRIOR �́A�t�B�[���h'prob'������ 1�~1 �\���́A
% ���l�x�N�g���A����ɁAGROUP�Ɠ����^�C�v��'prob'�̗v�f���ǂ̃O���[�v��
% �������邩��������ӓI�Ȓl���܂�'group'�Ɛݒ肷�邱�Ƃ��ł��܂��B
% �\���̂Ƃ��āAPRIOR �́AGROUP�Ɍ���Ȃ��O���[�v���܂ނ��Ƃ��ł��܂��B
% ����́ATRAINING ���A���傫���P���f�[�^�̃T�u�Z�b�g�ł���ꍇ�A�L����
% �Ȃ�܂��B�ŏI�I�ɁAPRIOR �́ATRAINING ��group�̑��ΓI�p�x���琄�肳���
% group�̎��O�m���������A ������̒l'empirical'�ɂȂ邱�Ƃ��ł��܂��B
% PRIOR�́A�f�t�H���g�ŁA�������m�����������l�x�N�g���A���Ȃ킿�A��l���z��
% ���������̂ɂȂ�܂��B PRIOR �́A�G���[�̊����̌v�Z�������āAMahalanobis
% �����ɂ�锻�ʂɂ͎g�p����܂���B
%
% ���:
%
%      % �P���f�[�^: 2�̐��K���z�̐���
%      training = [mvnrnd([ 1  1],   eye(2), 100); ...
%                  mvnrnd([-1 -1], 2*eye(2), 100)];
%      group = [repmat(1,100,1); repmat(2,100,1)];
%      % ���郉���_���ȕW�{�f�[�^
%      sample = unifrnd(-5, 5, 100, 2);
%
%      % ���m�̎��O�l�A group 1 ��30% �̊m���A group 2 ��70% �̊m����
%      % �g��������
%      c = classify(sample, training, group, 'quad', [.3 .7]);
%


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:11:04 $
