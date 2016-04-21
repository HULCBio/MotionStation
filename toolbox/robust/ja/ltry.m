% LTRY �A������LQG/LTR����V���Z�V�X (�v�����g�o�͂�).
%
% [ss_f,svl] = ltry(ss_,Kf,Q,R,q,w,svk)�A�܂��́A
% [af,bf,cf,df,svl] = ltry(A,B,C,D,Kf,Q,R,q,w,svk) �́A�v�����g�o�͂ɂ�
% ���āA��� wt�̖�����Ɍ��ɂ����āALQG���[�v�`�B�֐���KBF���[�v�`�B��
% ���Ɏ�������悤��LQG/LTR�𐶐����܂��B
% 
%                        -1                  -1
%     GKc(Is-A+B*Kc+Kf*C) Kf -------> C(Is-A) Kf   (as q ---> INF)
%
% ����: �V�X�e��(A,B,C,D)�A�܂���("mksys"�Ő��������)�V�X�e���s��ss_    
% 
%               Kf        -- �J���}���t�B���^�Q�C��
%  (�I�v�V����) svk(MIMO) -- (C inv(Is-A)Kf)�̓��ْl
%  (�I�v�V����) svk(SISO) -- �����i�C�L�X�g�v���b�g��
%                            [re im;re(�t��) -im(�t��)]
%               w --- ���g���_
%               Q --- ��ԏd��, R -- ����d��
%               q --- ���J�o���Q�C���̏W�����܂ލs�x�N�g��
%                    (nq: q�̒���). 
%                     �e�C�^���[�V�����ŁA Q <-- Q + q*C'*C;
%  �o��: svl       -- �S�Ẵ��J�o���_�ł̓��ْl�v���b�g
%        svl(SISO) -- �i�C�L�X�g�O�� svl = [re(1:nq) im(1:nq)]
%        �ŏI�I�ȏ�ԋ�ԃR���g���[�� (af,bf,cf,df).
%



% Copyright 1988-2002 The MathWorks, Inc. 
