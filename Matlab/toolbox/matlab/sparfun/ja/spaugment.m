% SPAUGMENT   �ŏ����g��V�X�e���̌`��
% 
% S = SPAUGMENT(A,c) �́A�X�p�[�X�Ȑ����Ώ̕s��s�� S = [c*I A; A' 0] 
% ���쐬���܂��B���̍s��́A
% 
%         r = b - A*x
%         S * [r/c; x] = [b; 0].
% 
% �ɂ���čŏ������
% 
%         min norm(b - A*x)
% 
% �Ɋ֘A�t�����܂��B�c���X�P�[�����O�t�@�N�^ c �̍œK�l�́A�v�Z������
% ���� min(svd(A)) �� norm(r) �Ɋ֘A���܂��BS = SPAUGMENT(A) �́Ac ���w��
% ���Ȃ���΁Amax(max(abs(A)))/1000 ���g���܂��B
%
% MATLAB�̈ȑO�̃o�[�W�����ł́A�g��s��͐����łȂ����ɑ΂��āA�X�p�[�X
% �Ȑ��`�������̃\���o \ �� / �Ŏg���Ă��܂����A���݂�MATLAB�ł́A
% ����� A ��qr�������g���āA�ŏ����������߂܂��B
%
% �Q�l�FSPPARMS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:02:56 $
