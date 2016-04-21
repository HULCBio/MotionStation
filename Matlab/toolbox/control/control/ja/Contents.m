% Control System Toolbox
% 
% Version 6.0 (R14) 05-May-2004
% 
% ���
% ctrlpref    - Control System Toolbox �̃v���t�@�����X�̐ݒ�LTI���f���̗l�X�ȃ^�C�v�̏ڍׂȃw���v
% ltimodels   - LTI���f���̗l�X�ȃ^�C�v�̏ڍׂȃw���v
% ltiprops    - ���p�\��LTI���f���v���p�e�B�̏ڍׂȃw���v
% 
% ���`���f���̍쐬
% tf          - �`�B�֐��̍쐬
% zpk         - ��_/��/�Q�C���^���f���̍쐬
% ss, dss     - ��ԋ�ԃ��f���̍쐬
% frd         - ���g�������f�[�^���f���̍쐬
% filt        - �f�W�^���t�B���^�̍쐬
% set         - LTI ���f���̃v���p�e�B�̐ݒ�/�ύX
% 
% �f�[�^�̒��o
% tfdata      - ���q�������A���ꑽ�����̒��o
% zpkdata     - ��_/��/�Q�C���f�[�^�̒��o
% ssdata      - ��ԋ�ԍs��̒��o
% dssdata     - SSDATA �̃f�B�X�N���v�^��
% frdata      - ���g�������f�[�^�̒��o
% get         - LTI ���f���̃v���p�e�B�l�̑��o
% 
% �ϊ�
% tf          - �`�B�֐��ւ̕ϊ�
% zpk         - ��_/��/�Q�C���^���f���ւ̕ϊ�
% ss          - ��ԋ�ԃ��f���ւ̕ϊ�
% frd         - ���g�������f�[�^�ւ̕ϊ�
% c2d         - FRD ���f���̎��g���_�̒P�ʂ̕ύX
% d2c         - �A�����痣�U�ւ̕ϊ�
% d2d         - ���U���ԃ��f���̃��T���v��
% 
% �V�X�e���̐ڑ�
% append      - ���͂Əo�͂�ǉ����邱�Ƃɂ�� LTI �V�X�e���̃O���[�v��
% parallel    - ���񌋍�(�Q�l �I�[�o���[�h +)
% series      - ���񌋍�(�Q�l �I�[�o���[�h *)
% feedback    - 2�̃V�X�e���̃t�B�[�h�o�b�N����
% lft         - ��ʓI�ȃt�B�[�h�o�b�N���ݐڑ�(Redheffer �X�^�[��)
% connect     - �u���b�N�_�C�A�O�����\�������ԋ�ԃ��f�����쐬
% 
% ���f���_�C�i�~�N�X
% dcgain      - D.C. (����g��)�Q�C��
% bandwidth   - �V�X�e���̃o���h��
% pole, eig   - �V�X�e���̋�
% zero        - �V�X�e��(�`�B)�̗�_
% pzmap       - ��-��̃}�b�v
% iopzmap     - ��/�o�͂̋�-��}�b�v
% damp        - �V�X�e���̋ɂɑΉ�����ŗL�U�����ƌ�����
% esort       - �������Q�l�ɘA�����Ԃ̋ɂ��\�[�g
% dsort       - �傫�����Q�l�ɗ��U���Ԃ̋ɂ��\�[�g
% norm        - LTI �V�X�e���̃m����
% covar       - ���F�m�C�Y�ɑ΂���o�͋����U
% 
% ���ԉ���
% ltiview     - ���`������͂� GUI(LTI Viewer)
% step        - �X�e�b�v����
% impulse     - �C���p���X����
% initial     - ������Ԃ�����ԋ�ԃV�X�e���̎��R����
% lsim        - �C�ӂ̓��͂ɑ΂��鉞��
% gensig      - LSIM �p�̂��߂̓��͐M���̐���
% 
% ���g������
% ltiview     - �����v�Z�p�� GUI(LTI Viewer)
% bode        - ���g�������� Bode ���}
% bodemag     - BODE ���}�̑傫���݂̂̕\��
% sigma       - ���ْl���g���v���b�g
% nyquist     - Nyquist ���}
% nichols     - Nichols ���}
% margin      - �Q�C���]�T�ƈʑ��]�T
% allmargin   - ���ׂẴN���X�I�[�o���g���Ɗ֘A����Q�C��/�ʑ��]�T
% freqresp    - ���g���O���b�h�ɂ�������g������
% evalfr      - �^����ꂽ���g���ł̎��g�������̌v�Z
% 
% �ÓT�I�Ȑ݌v
% sisotool    - SISO design GUI (���O�Ղƃ��[�v���`��@)
% rlocus      - Evans ���O��
% 
% �ɔz�u
% place       - MIMO �̋ɔz�u
% acker       - SISO �̋ɔz�u
% estim       - �^����ꂽ�����Q�C�����琄�����쐬
% reg         - �^����ꂽ�����Q�C���Ə�ԃt�B�[�h�o�b�N�Q�C������
%                ���M�����[�^���쐬
% 
% LQR/LQG �݌v
% lqr, dlqr   - ���`2���`��(LQ)��ԃt�B�[�h�o�b�N���M�����[�^
% lqry        - �o�͏d�ݕt�� LQ ���M�����[�^
% lqrd        - �A���v�����g�ɑ΂��闣�U LQ ���M�����[�^
% kalman      - Kalman ��Ԑ����
% kalmd       - �A���v�����g�ɑ΂��闣�U Kalman ��Ԑ����
% lqgreg      - �^����ꂽ LQ �Q�C���� Kalman ��Ԑ����ɂ�� LQG 
%               ���M�����[�^�̍쐬
% augstate    - ��Ԃ̒ǉ��ɂ��o�͂̊g��
% 
% ��ԋ�ԃ��f��
% rss, drss   - ����ȏ�ԋ�ԃ��f���������_���ɐ���
% ss2ss       - ��ԍ��W�ϊ�
% canon       - ��ԋ�Ԑ����^
% ctrb        - ����s��
% obsv        - �ϑ��s��
% gram        - ���䐫�O���~�A���Ɖϑ����O���~�A��
% ssbal       - ��ԋ�Ԏ����̑Ίp���t��  
% balreal     - �O���~�A���Ɋ�Â�����/�o�͕��t��
% modred      - ���f���̏�Ԃ̏���
% minreal     - ��/��_�����ɂ��ŏ�����
% sminreal    - �\���I�ŏ�����
% 
% ���g�������f�[�^(FRD)���f��
% chgunits    - ���g���x�N�g���P�ʂ̕ϊ�
% fcat        - ���g�������̃}�[�W
% fselect     - ���g���͈͂܂��̓T�u�O���b�h�̑I��
% fnorm       - ���g���֐��_�ł̃s�[�N�Q�C��
% abs         - ���g�������̃Q�C��
% real, imag  - ���g�������̎����Ƌ���
% interp      - ���g�������f�[�^�̕��
% 
% ���Ԓx��
% hasdelay    - �ނ����Ԃ������f�����ǂ����𔻒�
% totaldelay  - �e����/�o�͂̑g���̒x��̑���
% delay2z     - z = 0�ւ̋ɂ̍Ĕz�u�܂��͎��g�������f�[�^(FRD)�̈ʑ��V�t�g
% pade        - �ނ����Ԃ� Pade �ߎ�
% 
% ���f���̎����Ɠ���
% class       - ���f���^�C�v('tf'�A'zpk'�A'ss'�A�܂��́A'frd').
% isa         - LTI ���f���̌^�̌��o
% size        - ���f���T�C�Y�Ǝ���
% ndims       - ������
% isempty     - LTI ���f������̏ꍇ�A�^
% isct        - �A�����ԃ��f���̏ꍇ�A�^
% isdt        - ���U���ԃ��f���̏ꍇ�A�^
% isproper    - �v���p�� LTI ���f���̏ꍇ�A�^
% issiso      - �P���͒P�o�̓��f���̏ꍇ�A�^
% reshape     - LTI ���f���̔z��̃T�C�Y�ύX
% 
% �I�[�o���[�h���ꂽ���Z�q
% + �� -     - LTI �V�X�e���̉��Z�ƌ��Z(���񌋍�)
% *           - LTI �V�X�e���̏�Z(���񌋍�)
% \           - �E���Z -- sys1/sys2 �́Asys1*inv(sys2) �ł��B
% /           - �E���Z -- sys1/sys2 �́Asys1*inv(sys2) �ł��B
% ^           - LTI ���f���̃x�L��
% '           - ����]�u.
% .'          - ���o�̓}�b�v�̓]�u
% [..]        - ���͂܂��͏o�͂ɉ����� LTI ���f���̌���
% stack       - �z��̎����ɉ����� LTI ���f��/�z��̑g�ݍ���
% inv         - LTI �V�X�e���̋t�V�X�e��
% conj        - ���f���W���̕��f����
% 
% �s��������̉�@
% (d)lyap     - (���U)�A�� Lyaponov �������̉�@
% (d)lyapchol - ����Lyaponov�������ɑ΂���\���o�ɏ�a
% care        - �A���㐔 Riccati ���������̉�@
% dare        - ���U�㐔�� Riccati �������̉�@
% gcare       - ��ʉ�Riccati������̊J��(�A������)
% gdare       - ��ʉ�Riccati������̊J��(���U����))
% 
% �f�����X�g���[�V����
% ���p�\�ȃf���̃��X�g�ɂ��ẮA"demo" �܂��� "help ctrldemos" ��
% �^�C�v���Ă��������B
% 
% Copyright 1986-2004 The MathWorks, Inc.
