% AOCTOOL   ����q�����U���̓��f���̂��Ă͂߂ƑΘb�`���̃O���t��\��
%
% AOCTOOL(X,Y,G,ALPHA) �́A�\���q X�A���� Y�A�����ăO���[�v���ϐ�G��p����
% ����q�����U����(anocova)���s���܂��B�o�͂Ƃ��Ă�3��ނ̕\���������܂��B
% ��̓f�[�^�Ɨ\���Ȑ��̑Θb�`���̃O���t�A���ɂ�ANOVA�\�A������3�߂ɂ́A
% �p�����[�^����l�̕\���܂܂�܂��B�O���t�́A���ׂẴO���[�v�̗\���A
% �܂��͂ЂƂ̃O���[�v�̗\���ƐM����Ԃ�\�����邱�Ƃ��ł��܂��B
% �M�������́A100(1-ALPHA)%�ł��B�f�t�H���g�́AALPHA=0.05�ł��B
%
% AOCTOOL(X,Y,G,ALPHA,XNAME,YNAME,GNAME) �́AX��Y��G�ϐ��̖��O���w�肷��
% ���Ƃ��ł��܂��B
%
% AOCTOOL(X,Y,G,ALPHA,XNAME,YNAME,GNAME,DISPLAYOPT,MODEL) �́A2�̕t���I
% �Ȉ������܂܂�܂��BDISPLAYOPT �́A�O���t��\��('on' �f�t�H���g)���\��
% ���Ȃ�('off')�̂ǂ��炩���R���g���[�����܂��BMODEL �́A���Ă͂߂鏉��
% ���f�����R���g���[�����A�ȉ��̐��l�������̂ǂꂩ1���w�肷�邱�Ƃ�
% �ł��܂��B
%       1    'same mean'
%       2    'separate means'
%       3    'same line'
%       4    'parallel lines'
%       5    'separate lines'
%
% [H,ATAB,CTAB,STATS] = AOCTOOL(...) �́A�l�X�ȍ��ڂ��o�͂��܂��BH�́A
% �v���b�g��line�I�u�W�F�N�g�ɑ΂���n���h���̃x�N�g����Ԃ��܂��B
% ATAB��CTAB�́AANOVA�\�ƌW������l�\�ł��BSTATS�́AMULTCOMPARE�֐���
% ���ϒl�̑��d��r��������s����ۂɎg�p���邱�Ƃ��ł��铝�v�ʂ��܂�
% �\���̂ł��B
%
% �O���t���̎Q�ƃ��C���ł���_�����h���b�O����ƁA�\�����ꂽ�l�����݂�
% X�l�Ƃ��čX�V�����̂����邱�Ƃ��ł��܂��B����ɁA�G�f�B�b�g�{�b�N�X
% �̃e�L�X�g�t�B�[���h����"X"�l���^�C�v���邱�ƂŎw�肵���\���l���擾
% ���邱�Ƃ��ł��܂��B�|�b�v�A�b�v���j���[�́A�O���[�v���ϐ��̌��݂̒l��
% �ύX������A���f����ύX���܂��B�v�b�V���{�^���́A�x�[�X���[�N�X�y�[�X��
% �ɕϐ����o�͂��邱�Ƃ��ł��܂��B���j���[�͐M����Ԃ��R���g���[�����܂��B


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:08:54 $
