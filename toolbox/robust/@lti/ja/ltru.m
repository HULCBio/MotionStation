% LTRU �A������LQG/LTR����V���Z�V�X (�v�����g���͂�)
%
% [ss_f,svl] = ltru(ss_,Kc,Xi,Th,r,w,svk)�A�܂��́A
% [af,bf,cf,df,svl] = ltru(A,B,C,D,Kc,Xi,Th,r,w,svk) �́A�v�����g���͂�
% �����āA�v�����g�m�C�Y�̖�����Ɍ��ɂ����āALQG���[�v�`�B�֐���LQSF��
% �[�v�`�B�֐��Ɏ�������悤��LQG/LTR�𐶐����܂��B
% 
%                        -1                  -1
%     GKc(Is-A+B*Kc+Kf*C) Kf -------> Kc(Is-A) B   (as r --> INF)
%
% ����: �V�X�e��(A,B,C,D)�A�܂���("mksys"�Ő��������)�V�X�e��
%       �s��ss_LQSF
%               Kc        -- �Q�C��  
%  (�I�v�V����) svk(MIMO) -- (Kc inv(Is-A)B)�̓��ْl
%  (�I�v�V����) svk(SISO) -- �����i�C�L�X�g�v���b�g��
%                            [re im;re(�t��) -im(�t��)]
%               w         -- ���g���_
%               Xi        -- �v�����g�m�C�Y�̕��U
%               Th        -- �Z���T�m�C�Y�̕��U
%               r         -- ���J�o���Q�C���̏W�����܂ލs�x�N�g��
%                            (nr: r�̒���)�B 
%                            �e�C�^���[�V�����ŁA Xi <-- Xi + r*B*B';
%  �o��: svl       -- �S�Ẵ��J�o���_�ł̓��ْl�v���b�g
%        svl(SISO) -- �i�C�L�X�g�O�� svl = [re(1:nr) im(1:nr)]
%        �ŏI�I�ȏ�ԋ�ԃR���g���[�� (af,bf,cf,df).



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
