% PLOT  CFIT �I�u�W�F�N�g���v���b�g
% PLOT(F) �́A�J�����g axes �� x �̃����W�S�̂� F ���v���b�g���܂��B
% ���̑��̏ꍇ�A�ߎ��Ŏg��ꂽ�f�[�^�̃����W�S�̂��v���b�g���܂��B
%
% PLOT(F,XDATA,YDATA) �́AXDATA �ɑ΂��āAYDATA ���AXDATA �̃����W�S�̂� 
% F ���v���b�g���܂��B
%
% PLOT(F,XDATA,YDATA,EXCLUDEDATA) �́A��X�̃J���[�ō폜����f�[�^���v��
% �b�g���܂��BEXCLUDEDATA �́A�_���z��ŁA1�ُ͈�l��\�킵�܂��B
%
% PLOT(F,'S1',XDATA,YDATA,'S2',EXCLUDEDATA,'S3') �́A������ 'S1', 'S2', 
% 'S3' ���g���āA�w�肵�����C���̃��C���^�C�v�A�v���b�g�V���{���A�J���[
% ���R���g���[�����܂��B�����̕�����́A�ȗ����Ă��\���܂���B
%
%   PLOT(F,...,'PTYPE')
%   PLOT(F,...,'PTYPE',CONFLEV)
%   PLOT(F,...,'PTYPE1',...,'PTYPEN',CONFLEV) 
% �́A�v���b�g�^�C�v�ƐM�����x�����R���g���[�����܂��BCONFLEV �́A1���
% ���������̒l�ŁA�f�t�H���g�� 0.95 (95% �M�����)�ł��B'PTYPE' �́A��
% �̕�����̂����ꂩ�A�܂��́A���̕�����̃Z���z���ݒ肷�邱�Ƃ��ł�
% �܂��B
% 
%  'fit'         �f�[�^�Ƌߎ��J�[�u���v���b�g (�f�t�H���g)
%  'predfunc'    'fit' �Ɠ����ł����A�֐��ɑ΂���\���͈͂������Ă��܂��B
%  'predobs'     'fit' �Ɠ����ł����A�V�����ϑ��ɑ΂���\���͈͂�������
%                ���܂��B
%  'residuals'   �ߎ����[�����C���ŕ\�킵�A�c�����v���b�g���܂��B
%  'stresiduals' �ߎ����[�����C���ŕ\�킵�A�W�������ꂽ�c�����v���b�g��
%                �܂��B
%  'deriv1'      1�K���W�����v���b�g
%  'deriv2'      2�K���W�����v���b�g
%  'integral'    �ϕ����v���b�g
%
% H = PLOT(F,...) �́A�v���b�g���ꂽ�I�u�W�F�N�g�̃n���h����v�f�Ƃ���
% �x�N�g�����o�͂��܂��B
%
% �Q�l PLOT, EXCLUDEDATA

% $Revision: 1.2.4.1 $


%   Copyright 2001-2004 The MathWorks, Inc.
