% CONTOURF   �h��Ԃ����R���^�[�v���b�g
% 
% CONTOURF(...) �́A�R���^�[���h��Ԃ���邱�ƈȊO�́ACONTOUR(...) ��
% �����ł��B�w�肵�����x���ȏ�̃f�[�^�̗̈悪�h��Ԃ���܂��B�w�肵��
% ���x���ȉ��̃f�[�^�̈�́A�u�����N�̂܂܂��A�Ⴂ���x���̗̈�ɂ����
% �h��Ԃ���܂��B�f�[�^����NaN�́A�h��Ԃ����R���^�[�v���b�g���ŁA
% ���Ƃ��ĕ\������܂��B
%
% C = CONTOURF(...) �́ACONTOURC �ŋL�q����ACLABEL �Ŏg�p���ꂽ�悤�ɁA
% �R���^�[�s�� C ���o�͂��܂��B
%
% [C,H] = CONTOURF(...) �́ACONTOUR�I�u�W�F�N�g�̃n���h��H���o�͂��܂��B
%
% ���ʌ݊���
% CONTOURF('v6',...) �́AMATLAB 6.5����т���ȑO�̃o�[�W�����Ƃ̌݊���
% �̂��߁Acoutour�O���[�v�I�u�W�F�N�g�̑����patch�I�u�W�F�N�g���쐬��
% �܂��B 
%
% ���:
%      z=peaks; 
%      [c,h] = contourf(z); clabel(c,h), colorbar
%
% �Q�l�FCONTOUR, CONTOUR3, CLABEL, COLORBAR.


%   Author: R. Pawlowicz (IOS)  rich@ios.bc.ca   12/14/94
%   Copyright 1984-2002 The MathWorks, Inc. 
