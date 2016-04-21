%function [bnds,rowd,sens,rowp,rowg] = mu(matin,blk,opt)
%
% CONSTANT/VARYING�s��̍���(�����ƕ��f��)�\�������ْl(mu)���v�Z���܂��B
%
% ����: MATIN - CONSTANT/VARYING�s��
%       BLK   - �u���b�N�\��
%       OPT   - �I�v�V���������B���̂����ꂩ���܂ރL�����N�^������ł�
%               (�f�t�H���g = 'lu')�B
%          'l'  �p���[�C�^���[�V�������g���ĉ������v�Z���܂��B
%          't'  �����Ɋւ���J��Ԃ����s���܂��B
%          'R'  RANDOM�x�N�g���Ƌ��ɉ����Ɋւ���J��Ԃ����J�n���܂��B
%          'R7' RANDOM�x�N�g���Ƌ���7�񉺌��Ɋւ���J��Ԃ����s���܂�
%               (1-9���g���܂�)�B��������傫���l�́A��萸�x�悭��
%               �����v�Z���܂����A�v�Z���K�v�ł�(���̂��ߒx���Ȃ�܂�)�B
%          'u'  ���t��/LMI��@���g���ď�E���v�Z���܂��B
%          'c'  �����x�ŏ�E���v�Z���܂��B
%          'C'  ��荂���x�ɏ�E���v�Z���܂��B
%          'C1' 'C'�Ɠ����B
%          'C9' �ō��̐��x�ŏ�E���v�Z���܂�(1-9�̔C�ӂ̐������g���܂��B
%               �������傫���ƁA��荂���x�ɏ�E���v�Z���܂����A�v�Z�͒x
%               ���Ȃ�܂�)�B
%          'f'  �����ł�����G�c�ɏ�E���v�Z���܂��B
%          'r'  �e�X�̓Ɨ��ϐ��Ōv�Z���ăX�^�[�g���܂��B
%          's'  �i�s��Ԃ���������\�����܂���B
%          'w'  ���[�j���O��\�����܂���B
%          'L'  ���E�݂̂��v�Z���܂��B
%          'U'  ��E�݂̂��v�Z���܂��B
%
% �o��:  BNDS  - ��E�Ɖ��E
%        SENS  -  D�X�P�[�����O�ɑ΂���|| D M D^{-1} ||�̊��x
%        ROWP  - ���E����̐ۓ�
%        ROWD  - ��E�����D�X�P�[�����O
%        ROWG  - ��E�����G�X�P�[�����O
%        ROWD, SENS, ROWP, ROWG�́A���k���ꂽ�`���ł��B
%
% �Q�l:  UNWRAPD, UNWRAPP, MUUNWRAP, DYPERT, WCPERF, RANDEL

%   $Revision: 1.7.2.2 $  $Date: 2004/03/10 21:23:16 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
