% EIG   �V���{���b�N�s��̌ŗL�l�ƌŗL�x�N�g��
% �o�͈�����1�ݒ肵��LAMBDA = EIG(A)�́A�V���{���b�N�����s��A�̌ŗL�l
% ���܂ރV���{���b�N�ȃx�N�g�����o�͂��܂��B
%
% �o�͈�����2�ݒ肵��[V,D] = EIG(A)�́A�e�񂪌ŗL�x�N�g������Ȃ�s��V
% �ƁA�ŗL�l���܂ޑΊp�s��D���o�͂��܂��B���ʂ�V��A�Ɠ����T�C�Y�Ȃ�΁AA
% �́AA*V = V*D�𖞂������`�Ɨ��ȌŗL�x�N�g���̊��S�W���������܂��B
%
% �o�͈�����3�ݒ肵��[V,D,P]�́A���������`�Ɨ��ȌŗL�x�N�g���̑����̃C
% ���f�b�N�X�x�N�g��P���o�͂��܂��BA*V = V*D(P,P)�𖞂����܂��BA��n�sn��
% �̏ꍇ�AV��n�sm��ɂȂ�܂��B���̂Ƃ��An�͑㐔�I�d���x�̘a�ŁAm�͊�
% �I�d���x�̘a�ł��B
%
% LAMBDA = EIG(VPA(A))��[V,D] = EIG(VPA(A))�́A�ϐ��x�̉��Z���g���āA
% ���l�I�ɌŗL�l�ƌŗL�x�N�g�����v�Z���܂��BA���ŗL�x�N�g���̊��S�W����
% �����Ȃ��Ȃ�΁AV �̊e��͐��`�Ɨ��ł͂���܂���B
%
% ��� :
% 
%      [v,lambda] = eig([a,b,c; b,c,a; c,a,b])
%
%      R = sym(gallery('rosser'));
%      eig(R)
%      [v,lambda] = eig(R)
%      eig(vpa(R))
%      [v,lambda] = eig(vpa(R))
%
% A = sym(gallery(5))�́A�ŗL�x�N�g���̊��S�W���������܂���B
% [v,lambda,p] = eig(A)�́A�ŗL�x�N�g����1�����o�͂��܂��B
%
% �Q�l   POLY, JORDAN, SVD, VPA.



%   Copyright 1993-2002 The MathWorks, Inc.
