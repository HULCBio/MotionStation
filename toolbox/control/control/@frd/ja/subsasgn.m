% SUBSASGN   LTI�I�u�W�F�N�g�ɑ΂���Y���t�����蓖��
%
% ���̊��蓖�đ���́A�C�ӂ�LTI���f�� SYS �ɑ΂��ēK�p����܂��B
%   SYS(Outputs,Inputs) = RHS  I/O �`�����l���̃T�u�Z�b�g�̊��蓖��
%   SYS.Fieldname = RHS        SET(SYS,'Fieldname',RHS) �Ɠ���
% ���ӂ̕\���́ASYS(1,[2 3]).inputname = 'u' ��A
% SYS.ResponseData(1) = [ ... ] �̂悤�ɓK���ȓY���t���Q�Ƃ𑱂��邱�Ƃ�
% �ł��܂��B
%
% LTI���f���̔z��ɑ΂��āA�C���f�b�N�X�t�����蓖�ẮA���̏������g��
% �܂��B
% 
%   SYS(Outputs,Inputs,j1,...,jk) = RHS
% 
% �����ŁAk �͔z��̎������ł�(���o�͂̎����ɉ����)�B
%
% �Q�l : SET, SUBSREF, LTIMODELS.


%   Author(s): S. Almy, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
