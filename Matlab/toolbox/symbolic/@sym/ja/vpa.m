% VPA   �ϐ��x�̉��Z
% R = VPA(S) �́AD ���̐��x�����ϐ��x���������_���Z���g���āAS �̊e
% �v�f�𐔒l�I�ɕ]�����܂��B�����ŁAD �́ADIGITS �̃J�����g�̐ݒ�l�ł��B
% R �́A�V���{���b�N���ł��B
%
% VPA(S, D) �́ADIGITS �̃J�����g�̐ݒ�̑���ɁAD �����g���ĕ]������
% ���BD �́A�����A�܂��́A���l�̃V���{���b�N�\���ł��B
%
% ��� :
%      phi = sym('(1+sqrt(5))/2');      % phi�́A"������"�ł��B
%      vpa(phi,75) �́A75����phi���܂ޕ�����ł��B
%
%      vpa(sym(pi),1919)�́A�X�N���[���S�̂�pi��\�����܂��B
%      vpa(sym('exp(pi*sqrt(163))'),36) �́A�قƂ�ǐ�����\�����܂��B
%
%      vpa(sym(hilb(2)),5) �́A���̌��ʂ��o�͂��܂��B
% 
%      [    1., .50000]
%      [.50000, .33333]
%
% �Q�l�F DOUBLE, DIGITS.



%   Copyright 1993-2002 The MathWorks, Inc.
