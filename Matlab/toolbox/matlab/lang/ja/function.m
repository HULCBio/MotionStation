% FUNCTION   �V�����֐��̒ǉ�
% 
% �����̊֐����g���āA�V���Ȋ֐���MATLAB�ɒǉ��ł��܂��B�V���Ȋ֐���
% �\������R�}���h�Ɗ֐��́A�t�@�C�����̊g���q�� 'm' �������A�V���Ȋ֐�
% �����`����t�@�C���������t�@�C���ɐݒ肳��܂��B�t�@�C���̍ŏ��̍s
% �́A�V���Ȋ֐��̃V���^�b�N�X�̒�`���܂݂܂��B���Ƃ��΁ASTAT.M �Ƃ���
% ���O�̃f�B�X�N��̃t�@�C��
% 
%         function [mean,stdev] = stat(x)
%           %STAT Interesting statistics.
%         n = length(x);
%         mean = sum(x) / n;
%         stdev = sqrt(sum((x - mean).^2)/n);
% 
% �́A�x�N�g���̕��ςƕW���΍����v�Z���� STAT �Ƃ����V���Ȋ֐����`��
% �܂��B�֐��{�̓��̕ϐ��́A���ׂă��[�J���ϐ��ł��B���[�N�X�y�[�X�ŃO
% ���[�o���ɋ@�\������̂Ɋւ��ẮASCRIPT ���Q�Ƃ��Ă��������B
%
% �����t�@�C�����̑��̊֐��ɑ΂��ėL���ȃT�u�֐��́A��s����֐���T
% �u�֐��̖{�̂̌�ɁA�L�[���[�hFUNCTION���g���ĐV���Ȋ֐����`��
% �邱�Ƃō쐬����܂��B���Ƃ��΁Aavg�̓t�@�C��STAT.M���̃T�u�֐��ł��B
%
%          function [mean,stdev] = stat(x)
%          %STAT Interesting statistics.
%          n = length(x);
%          mean = avg(x,n);
%          stdev = sqrt(sum((x-avg(x,n)).^2)/n);
%
%          %-------------------------
%          function mean = avg(x,n)
%          %AVG subfunction
%          mean = sum(x)/n;
%
% �T�u�֐��́A����炪��`����Ă���t�@�C���̊O���ł͗L���ł͂����
% ����B�ʏ�A�t�@�C���̏I�[�ɓ��B�����Ƃ��Ƀ��^�[�����s���܂��B
% RETURN �X�e�[�g�����g���g���āA�r���ŋ����I�Ƀ��^�[�����邱�Ƃ��ł���
% ���B
% 
% �Q�l�FSCRIPT, RETURN, VARARGIN, VARARGOUT, NARGIN, NARGOUT, 
%       INPUTNAME, MFILENAME.

%   Copyright 1984-2002 The MathWorks, Inc. 

