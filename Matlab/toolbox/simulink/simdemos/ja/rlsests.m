% RLSESTS   �V�X�e��������s��S-function
%
% ����M-�t�@�C���́ASimulink S-function�u���b�N�ŗ��p���邽�߂ɐ݌v����
% �Ă��܂��B
% �w���f�[�^�d�ݕt�������ŏ����p�����[�^����A���S���Y���𗘗p���āA
% �p�����[�^������s���܂��B
%   
% ���͈����́A�ȉ��̂Ƃ���ł��B
%
%     nstates:        ��ԃx�N�g�����̏�Ԑ��B
%     lambda:         �w���f�[�^�d�݃t�@�N�^�B
%     dt:             �T���v���_�̊Ԋu(�b)�B
%
% RLS����q�́A���̕������ɂ���`����܂��B
% 
%    theta[k]  =  theta[k-1] + ....
% 
%
%      1      P(k-2) * phi(k-1) * [y(k) - phi(k-1)'theta(k-1)]
%   -------  * -------------------------------------------------
%   lambda         lambda + phi(k-1)' * P(k-2) *phi(k-1)
%
%   	         1       P(k-2) * phi(k-1) * phi(k-1)' * P(k-2)
%     P(k-1)  =  ------ * ----------------------------------------
%   	       lambda    lambda + phi(k-1)' * P(k-2) * phi(k-1)
%
%   ������:
%
%     theta:	����p�����[�^
%     phi:		��ԃx�N�g��
%     P:		�����U�s��
%     lambda:	�w���f�[�^�d�݃t�@�N�^
%
%
% �Q�l : SFUNTMPL., "Adaptive Filtering, Prediction, and Control",
%        G. C. Goodwin & K. S. Sin.


%   Copyright 1990-2002 The MathWorks, Inc.
