% function vplot([plot_type],vmat1,vmat2,vmat3, ...)
% function vplot([plot_type],vmat1,'linetype1',vmat2,'linetype2',...)
% function vplot('bode_l',toplimits,bottomlimits,vmat1,vmat2,vmat3, ...)
%
% 1�܂��͕�����VARYING�s����v���b�g���܂��B�V���^�b�N�X�́A���ׂẴf
% �[�^��VMATi�Ɋ܂܂�A����PLOT_TYPE�ɂ���Ďw�肳��邱�Ƃ������΁AMA-
% TLAB��plot�R�}���h�Ɠ����ł��B
%
% (�I�v�V������)plot_type�����́A���̂����̂����ꂩ�ł��B
%
%    'iv,d'       �s��ƓƗ��ϐ�(�f�t�H���g)
%    'iv,m'       �Q�C���ƓƗ��ϐ�
%    'iv,lm'      �Q�C��(�ΐ�)�ƓƗ��ϐ�
%    'iv,p'       �ʑ��ƓƗ��ϐ�
%    'liv,d'      �s��ƓƗ��ϐ�(�ΐ�)
%    'liv,m'      �Q�C���ƓƗ��ϐ�(�ΐ�)
%    'liv,lm'     �Q�C��(�ΐ�)�ƓƗ��ϐ�(�ΐ�)
%    'liv,p'      �ʑ��ƓƗ��ϐ�(�ΐ�)
%    'ri'         �����Ƌ���(�Ɨ��ϐ��ɂ��p�����[�^��)
%    'nyq'        �����Ƌ���(�Ɨ��ϐ��ɂ��p�����[�^��)
%    'nic'        �j�R���X���}
%    'bode'       �{�[�h���}
%    'bode_g'     �O���b�h�t���{�[�h���}
%    'bode_l'     ���̐����t���{�[�h���}
%    'bode_gl'    ���̐����ƃO���b�h�t���{�[�h���}
%
% �v���b�g�^�C�v'bode_l'�����'bode_gl'�ł́A2�Ԗڂ�3�Ԗڂ̈������A����
% ����A��i�Ɖ��i�̎��͈̔͂������x�N�g���ł��B���Ƃ��΁A���̂悤�ɂ�
% ��܂��B
%
%     vplot('bode_gl',[-1,1,-3,1],[-1,1,-180,0],...
%
%  �Q�l: PLOT



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
