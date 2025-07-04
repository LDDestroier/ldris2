local tArg = {...}
local selfDelete = false -- if true, deletes extractor after running
local file
local outputPath = tArg[1] and shell.resolve(tArg[1]) or "ldris2"
local safeColorList = {[colors.white] = true,[colors.lightGray] = true,[colors.gray] = true,[colors.black] = true}
local stc = function(color) if (term.isColor() or safeColorList[color]) then term.setTextColor(color) end end
local choice = function()
	local input = "yn"
	write("[")
	for a = 1, #input do
		write(input:sub(a,a):upper())
		if a < #input then
			write(",")
		end
	end
	print("]?")
	local evt,char
	repeat
		evt,char = os.pullEvent("char")
	until string.find(input:lower(),char:lower())
	if verbose then
		print(char:upper())
	end
	local pos = string.find(input:lower(), char:lower())
	return pos, char:lower()
end
local archive = textutils.unserialize("{\
  data = {\
    [ \"sound/mino_L.dfpwm\" ] = \"[���?��J@������A\\000\\000AD���ݭ�$��J���\\\"�@\\000D�{����kI\\000\\000 �R������D\\\"�T�ڭ�RJR�ݭ���JB\\000\\000\\000A������m+	@Bj��v�UUI�R��v7�H@\\000i�����m�\\000\\000\\000�Զ�~�nUI�$���V�B������ߕD\\000\\000\\000�$�������$BD$ն�jm�RJ�j�{��\\000@\\000�v����\\000�Hj��ww�*ER��jm��R\\000\\\"������U\\000\\000�$U����J����Զ[UU)I�{����\\\
A\\000\\000�T����w[K BHֶ��v�JITU�n�5�$\\000\\000$u����w[%\\000\\000\\000D����߻�J�H�D�V�Z�$�$�}o��w\\000\\000I�����n�D@@���m۶UJ)������\\000�@j����ߵ*\\000\\000\\000�$�����[�$Q*Iն�*% R�}����D\\000\\000\\000D������[�$�Q�v[�Z��R[k��]%\\000\\000�T����w[K\\000 �j����UUI��Rk�V\\\"I\\000\\000������U	\\000\\000H�j��*�H\\\"�T�vתI��m�����\\000\\000\\000!I����w[�@ �Hm�mm[U*%U���wKQ\\000�6����w\\000\\000\\000$�����ݭD\\000\\000�H��￷V���$U[�Z�$\\000I$�������*A�\\000@�$U�����n�\\000\\000�H������Z%��j�m�*��T����}[J\\000\\000\\000�T�����]KB BD��vwת*%IRժ���n�$B@ ��v���wm�\\\"�j�n�ݶU�$RU��۾�@)\\000\\000��}������J\\000\\000 $I����ݭ�$�$�jm�U)	!�T���o!\\000\\000 HR������V	!\\\"�m�kk���������m+!\\000��������nk	\\000� \\\"���ﻻ[U�RIR��mU�\\000\\\"J�����W%\\\"\\000\\000\\000D�T����[U�BD$��v[U�*I)���ۖ@\\000\\000 U�����n[K@\\000��Z�{��HR�Rmݶ)\\000@��������*	\\000\\000@)�����n[%!\\\"��j��۪*\\\"\\\"�ڶ���V%\\000�T����޵�� !IU��ww�*%�U[ۿ��&D!@DIz���ݭ\\\
����{{�*� �(��j��nI��HJU���H$���Tkk���Z��$IRRU�jk�ZU�RI�TU�Zm�Z�J��R��U���VU�RI�TUU�Z�VUUU�JUeUUU�����*UUUU���jU��RU��VU���Z��JUUUUUUUժ�J���T���JU��JUUUUU�������*UUUUUUU�������*UUUUU5�����*UUUUժ�����TUUUUUU5�2����*UKUUUUӬ����,KUUU���*���TUUSU�TUU���JUUUUU���TUUUUUU�����TM��TU����ʪ��RUUUUժ�����JUUժ��RUUժ��JUUUUUU�����*UUUUUUUUUUժ����TUUժ����TUUUUU����������TUU���RUU����*UUUUU�����*UUUUUUU��R����*UUU����JUUUUUU��������JU��jUm�UI����JI���n��$\\\"��j��ڵZ��$QUUU[�*�J\\\"���m�JD$Dh�m�w{�T!�ERն�*�R�T�Z�vk%B����~���\\\"!BP��ݽ�ZUKIJRU�Z�U%�$IJm��{�v%	��m۽�mWU\\\"IU����Z�RJ�j����V%\\\"B��mm߷�[)IUU��*�TU�jk�J�$I�R�v��׭$IDAQ����m�R�D���Z��J�J�Rk۶۵�A����}�^W�\\\"(\\\"�Z�n[U��J��Zm�Z%�D��Rkw�{�[I\\\"� �����n�U��$����jU�TIR�j���֪R$� �ȶm��׭J!��TU��VU��*��Zmm��H$\\\"RU۶���m�$$\\\"RUպݶ�j��RU�����$)I)�u��ޮ��AE�����Z�$\\\"IU�Zk���J���mk۶�$�!(����^_���HDR�jm�kUU)��jU��V�$�$�Tm�ݻ�*IIA\\\"�Vw��V�*IIRUU�V�R���Rk۶۶ZJAEԶ�޽w��H��T�Z[[�*�R�jm��֪�$��RU۶{w[��$\\\"\\\"��Z��V��J)�Rժ�j�RJUU%U��nmm�BD!u�����JDH�Z����nK�H�����VUUJI�V���u��\\\"����ն��mk�ZU*��H�\\\"\\\"�m�{}w�E� !���v۶�$�T�Zۭm�J$\\\"� ������v���Vkw۶����*Um�j����$�$�T����n[U))I\\\"IJU��m[�UUUJ%��UU�ZU�T���jmk�n�V�$�HJ���n�۪�JIIU���j�V�J���j�U��V*II�$UU���۶U�R\\\"I����ֶ�Uժ*��Rժ�UUU%�JI���mm��Z*�$\\\"IRU�ֶm[��������ʪU��TU)UU��Vk��*%%IR���jm��VU��$�������ZUVU�*U���V�T�R�T�������Z�R)%I)UU���V���J�R�UUU���*U�JU�Z�֪UU�RJJ�ҪU���ZU�J)�����V�ZU��RU�VUժVUU�*U����U��UUU�*UU�UUU������JUUUU�����JUUUUU�������RUUUUUU������JUUUUUU�����JUUUU������JUUUUUU������JUUUUU����*UU53Uͪ�����LUUUUUUU��������RUU\",\
    [ \"sound/mino_T.dfpwm\" ] = \"����9\\000@-�L���vE\\000�\\\
\\000T���f���r�����\\000Ԣ���jmk\\000\\000�J��V��[\\000jZUu[Uu�\\000\\000�j��U�\\000\\000�������+��\\000���4	�+����w�U\\000�������(\\000RJ��T���V�T���V\\000����5[W\\000�b�T�S��j\\000�JU���TU����\\r\\000@U�R����\\\
��\\000����*���*���@��\\000P%����iu]\\000�DT�_��oP�R�ߔʭ\\000�T��[�5\\000\\000�LJ)�����\\000T���WU�r�+�j-��\\000�\\000ʒ���[�U\\000PU)�WZ�\\000T�VM~�j��\\000�����յr\\000\\000T������\\000�+\\r�����\\\"���XZ��*\\000V�*QQ��KW�h���/y*��I�]�o@M�=PY����]\\r�\\000U��Y�b�\\000�EU%@����ik\\000\\000PM����6\\000U5\\000�_�UI�[����\\000K�J*��維\\000@Q��RU�P�V�?`�R�$���m[�\\000P�J���U@U��k�T*�����\\000(\\000�$���ϵe\\000U\\000���J��TU���\\000V�\\000�����5�V\\000(���f��P5U\\r�J[*\\000��*���\\000�*R*�����VP�W��,�*�n�P5\\000�R����j\\000\\000HU�_���\\000T�Z��VZ������*\\000\\000*U����UP�\\\
������k����\\\
@	�R�R���Y\\r\\000@���Z��j���P�\\000����_��R\\000�DJ�����\\000��Ҁ�Rk�\\000࿪��ks\\000\\000PE*���ժ�\\000T����j-���\\000�\\\
@�b�����\\000 �*��T�[\\000�ZKZ-��\\000����7Ѧ\\000[Y]駗ʧ�vY@�O�:�7zt�ߥ`�P	U���j�/@\\000�����[��\\000����h+]��Z�����^�\\000 IԿ��-��J��ZW\\000�J��m��\\000�$%���V����T�eeUe�7\\000�S��ߪu\\000PR�kU�����(SU\\000���U�\\000(����[��*���J+�W����\\000T\\000�X��[k\\000%�W������Z�@����n\\000H������T�����\\\
�%���\\\
(\\000�\\\"����6��\\000�+�ꡪ�R�@�\\000�R��WU�\\000bE�+�T��ɚTj@���_u\\000�D����V\\rPMпʪ*xU���@5\\000������j\\000@)�����R-@��\\000H���_mk\\000�����](U\\r�w5k�U��u@\\\
�D���o�*@\\r@�oժ��RU��\\000UU\\000TԿ��f�\\000@I)�V�m����Y��诪�gt�j��T*�6P�+WіRm��?�]P+[���;Px�L��m��i�?I�T�^����X@�vX�V���@�����}U'=(�@�u+�/E�P$7U��'����;a�oƶHPE���~j\\r�jY���T1��])w�����p�hY�/I\\rm-���k��R��W\\000mE��~$�V�\\000ڪM�OJ�2\\000�ڪ��W~E\\\
P�2�_-�JU���´�*\\\"������j�Si䂂J\\re�������R����P�kU,隼�N�j�*ġW���6�a��M������\\000hU�t��E�B�Vm���%e*�S�(�O@K@�WU��U%��׿\\\
U�J���R�VP��_�Բ�nժ��\\\"	`�i~-ei	�_)����\\000V���J�_��%�����O�R�AU�I��Vm���/U��\\000����_J��X�Z�%5�пI�IZZ�����H�\\\
�^��6�RUZ�R��/j`���U��4@�m��WA�[���u��Re[��U䯂�\\000�֭ҿ~tҶ௩��|U����\\\
��Z��+���U�SJ�?�*�����+@���S\\\
iG\\000����O�����E��jU-\\000�[%��\\\"����*��[�*�*��)Uj$UMU�	T�\\\
��j��\\000jW��ɟ`k!U]ZU� �_��]P��]����*�\\\"�)��W-��JS���vIB�\\000��R��o�$~*T�z{��W�V� ��K%�Z���TU�b��G��\\000u��_֯�e���,@���: P��Z�/I�\\000���J�M��*�+���-���$U@�j�O)�V-�@����W�J�@׺Կ~�P��T�Z�K5UI�@�v��K�R�U�j%�R�*���T��*%T\\000m-�W�%\\\
P�V�o*��_��TT��k���TQ\\000��v)5�C�NZ���\\000m+�}Ra�\\000P���-�5k�eU��\\000�%�+	5\\000h�U���T	P��WUj%�*S�_	P+����I�J����J�UV�~�ڬ\\000V�W~)��\\000P[��k��V\\r�2��UU�/I@�mk���-@T׿���PY���@��@z�_�!eT\\000j�;}�~��X�Zx�j���UJu�����Z*�:�T*U�T�USU�ZV�jU���V��ZU\",\
    [ \"sound/mino_Z.dfpwm\" ] = \"����ߏc\\000��te��R���\\000\\000J)�����:VՊ������\\000\\000����\\\\Ӫ��\\000\\000J����\\\
���XU U����@��JJ�WU�i\\000T*���@��~��@U��WU�\\000ԿJi����\\000(��W�@�V��\\\
@U����P��T�[��Zi\\000�T�/�?@Um�H�JU�U\\\
�4��T)�_����\\000���W��\\000U��@)��J���\\\
Ъ��J�����\\000T��J�UU��(\\000�T��k\\r�Z�je@���U]\\000��_Uգ*M�\\r \\000�����@UUY�U������@��V୲�m\\000\\000L)��+@USJj\\000K��W�P\\000��������\\000P%�_�W�jU���\\000�����P��R�5�m-\\000@)���������*��R��\\\
��������V�@K�,�U��HPU��?i4`����D�����oï��\\\"-��~�R����tɟnC�.-�.�\\000�Ah��]WUy\\000�D\\\"��j�o[PVR-�?i�V���R�e��k��\\000X%����[���f\\000\\000*E)Y�+����\\000�V3\\000��VUe�\\000�U�����n\\000��\\000SiR����j5�\\000\\000��\\\"�����\\\
�Z�����*e���J����_\\000l5\\000������V��m\\000\\000P)U��_*�_kPk��\\000�J���*j���_\\000�\\000�J4�����Z�\\000\\000*�J������5\\000�Ze+\\000��U�*v\\000��RU���W\\000Pk\\000PJ1���j�vU\\000��T��U��U@k�4���TUI\\r���J���W\\000�\\000T%U���_�ݪ\\000\\000`�TR�/��?k\\000XM�r\\000�_��*�\\000�_��b�������T����U˶j\\000\\000�*%�������֪���Ҥ�R\\000��eZ��Wi\\000TU\\000��j���_�j�T\\000\\000��K5�����R\\000�u���_�2���*���?R	���zQ/��_(�]J#$8���oEiOz� �K�9Q��C��f�r�A���)\\000��G��k�\\000�R����u�\\000lW��J�V\\r�J���R\\000lP)�(���j;\\000\\000��U-�H�Z����j`�������:\\000\\000��_���\\\
����k���\\000�?S��[����T���j�P+\\000R�+U����T����\\000UQ���U��\\000�*R����\\000VUUVN�J�\\000�����j�\\000@�JQ��_�+\\000Z�\\000�ZU��Z�R�\\000�\\000$%�����Z5\\000�J򿥪���������\\000@�����V�\\r\\000 I%������VS�O�Tm\\000������\\000\\000+U\\\
��o����J�KU��֔R����\\000����_���\\000\\000�TD����6\\000����WU+�\\000�_���Zt\\000\\000�$U����Z*\\000���RU�ʥJ���PY\\000�*���_+�:\\000\\000J�����J-�>�T�P\\000�����jJ\\000�Z*����K�T�4�~�IԪ���J���v\\r(Rv���R1��� [U?Pl��AU/�T/�dݵ����@��@������'U��U�OXװ����I�.���f�(땗+��:V� �j��J�|�~�\\000e[�_��\\000���`�H������\\\
��ߚ6�\\\"��I)\\000Z���KT;���\\000U��MJ�J�SeૢE�������Z����.;��D+�RA�R�\\\
��^+�\\\
`��_lkRu�O	݂�*��\\\"ՠU��Z���m-VIS��Z_�TE�V�Nհ����R)+�,5�x���VUBYik��W�4�J��ʵV뿢��R�mKj	���Z���oU�\\\
�I��\\000�zUֿ}J�T�V@�ZZ���(�\\\
U��YV�5m�J��Z�����$��\\\
P�Z�����ʪ*\\000d[ӦֿJ�?�@ֵT�����J�\\000_�R�T�'�\\000��\\000ն�Z���\\\"i�j\\000u�lY�O��W�`խj�WŒm��Wmdʪ%��-@�ֿ/)I�6@��V��I��*�\\000U�ZU���h-���JK���$�V��5���%%R5)��.�)�_���j���RU*e5��UVR���J\\000mՀj��U�>�DTS���-mK�S���hhm�j�Ք�*��W�j��WQ\\\
�-\\r�j����UCU� �uk��?U���R��6�F���T�U}UU%m���\\000ZW�d����{)���R	�][��]UԷb	R�J��Wz*Ui�W�IU[�J�P-5���*W�VS�JU�P�ZZ��6鴵D�D�F�TMwT�U�RQ��*�&[SBړK!��լߒJJ\\000jU��_�FT����JM*�\\\\U�_)�P�S��/���\\000+P���R��/P�V���ZIX��+�S��T��jտ�~K\\\
�U]௪J5�O�*�J%hPݪK����J�Z]��dR���UU�jS@���_*)�\\000m]�����M��R�*W�Y*�ֿ4�W*R)\\000��V���K���R]���d�*x�����$@��vY��%�JV�T�տ��'H����CJ�Z��}��QQ\\000v�U�_ꯘ@+k�W[I%��JUE���@]����Q*�+`��)��j�J�Vj�M��կHIQ\\\
�m���RU*Z*U\\r^5Ӫ,@�O-�/I�\\\"�VS��]�R��4k ���R���j�V�U����z�_V�D����]�ׂr	�TՒ���*U�h�_i�$JJP�kU�����J����T�IQ��URmR����%5U�'ժTM����Z���ZUU�\",\
    [ \"sound/drop.dfpwm\" ] = \"|xx<��p|�8�xtx�#c�!����ph�<zx|t���p�t<����jǇ����p���\\000���1��������a��!�6G����c塤�p��+���G�xy��j�;,�p�1�)a�q�pLhWiL�V�*G��pWk�RY����`\\\\��m���P1��b,�1�Ji��eqh�s)s8����g���P>[��8GYic9�VjGex���4��vieTQ�VO騂����QM��p��8�s,�u\\r���;�4��9�RZե*�g8�����5*Eg-�!���[S)��x�Z<�:���yėm������:�јz�EU�P���B0n��Q<�]Z�p�é�s}8���4�˪p�5���Y��x�cy��yK�g�ƥ(���J��*�2\\ra)�r\\\\�JiT�*�YC��ZG7��q�3���N�X\\\
��\\\\��3<�utx��bxN����W���y����x��8����x<��0�8F2<�8��U)��8��0V�q�:�q8��0��6<����qK'=��q��%>�g9:��\\\\���x�p��r(�p�Q�RU)���=��xq\\\\ky���:�<>��;Nˣ���0�R�Y\\\\����q������q��q<�rp�15����q����p���8��G]�����1��K��L�C�8Zj��x���cU98Ϫ�).�:x����4���8�q8��aU��8/<���������i<\\\\��I�4�q5�x��J��U���Z�ⱌ�8�Q��85�q4�G�*5���*U<�R��xT-�V��/.U��p4-�i.�q\\\\�8��I��R����U��hY�i4Ui�RY�Ń��xx���å*��I�F��,��㡋�����8<VUM�c<N�e�<��8�����h5�*�IY*��beZ<������q�c�q9���i�e9�e,��,���Y��x��U-�e�ǣV6.�j��T���8N咣i:\\\\r���q�UU�4�j���q���J�T��p��SK��\\\\J=�x�8��i<���i�V�xt�e-�c��t��N5�2���h5��X�RU��di\\\\,�F���N9<����r8��Jsx�V:���T�4�q���)��i�0��e��QI��4��Ѩ�G��RNV�NUm�8�����pG�.[jjt��gi�,N�)\\r�p<����8�f:�r8+U�㱅Y�r��Ʊh�p�c���+�긊��X���1�Ә�K-F��p�G���C��p�<\\\\,��R��<��p�f�\\\\jhU�Z��X�q<�\\\
G�L��x��8���ǩ���Вr<Ǳ4�F�p�ce�XY��q�qY���r��:�\\\\M��Nѕ��]t�R<N���8M���8�����Qi��Xı6��h��EUӒ�i���hK\\\\�e��2��X�鸜���,K5��8�R5ղ�J�8�\\\"-�4UUUU�4M�TU5UUM��4UK55�TͲ,���Ҳ,M�\",\
    [ \"sound/mino_S.dfpwm\" ] = \"@��?\\000����\\\"\\000@��_E\\000���_���_%����J���_����_U	����\\000U��\\000����\\000����\\000���V�\\000�Z�W�\\000P��WU�j���@���*@��_+���ߪ���+����U	\\000U���\\000����\\000����\\\"\\000����\\000����\\000�m�UI\\000T��UI\\000T��UE\\000X����\\000����Pm�W%	���W����_)	���_)@m���@����j���D\\000���J)\\000U��JE\\000�u�K%\\000R���4�����p[�W\\\
\\000�����\\000\\000������zHR	���o\\000@i��+ @�w�_D��T�P��ߔ\\000@���W*R���DYU$U����R\\000Z]�_IA	��Z�/RM5\\000�J���JB\\000���	IT��Nտ(��\\000T+���*$\\000`o��S$Qj������\\000����*!	\\000��_%B@ݪ�-E5\\000P����$\\000����UIT\\000����[U�\\000����oe�\\000PUk���$`����@S����\\\"\\000����R�������\\000iU����H\\000Tu��Oi\\000����+U�\\000�j��?%�\\000(�6��$Gh�R��kK\\000J���7\\000\\000U���\\\
\\000`�]��J5�[UU����\\000��_U\\000\\000���_5%\\000�j���@AU�j�\\\
�����Q��ˈ\\000���&�\\000���o-\\000R��o-	@���������)�j����j��B\\000H���Z\\000R���U	\\000J���j %��Z�j�j�\\000R��_�\\\"\\000�v�W�\\000U���%	�T���)���UHm��UB\\000���W\\000�z�kI@i���������\\000$���VJ\\000T���R\\\"\\000�������]��V U��U����JP���5!\\000dJ�_U)�Z��\\000����WI\\000\\000T����\\000�(�o�R�*��/ Q�R��W�\\000T���U�Ԡߪ��j��\\000H����_�\\000����WJ ��~�J�Wն? 	����J�\\000@�ݷ��T)p՚��iռ\\000)uu�_%Q\\000ն[�WE)#\\000*ۺ��J��\\000h�z�?���\\000P�����J�\\000@������H`k���L1@ͦ��K�\\\
\\\
�N���+e	\\000�6���d\\000]m��OI�(\\000ݺ���T�$\\000lժ��U!)\\000�����R��\\000�V���7�@W���SZ�~�����D`����/I\\000�����H\\000�m��TR@T��_ZS)�V�ڿTmS\\000*y����j\\000�ֹ��IT\\000��k�S�\\000����+�������H@ծ��)%�����K�\\000�Y��NU	\\000�T��-�\\000T����*%\\000����7JJ\\000ȵ��W�P۶�_I��m��%@[���IJ@����J�������(\\000ڶ��J�\\000�Z��+�H\\000궖�KE�\\000�Ֆ�/%I`kk��\\\"h�6�/Y���f���\\\
�Z���R\\\"	��[�RU\\000(���+E\\\"\\000�����FT\\000h�]��\\\\�\\000P����D\\\\�n�V��\\000R���*\\000�ͪ�j�@U�U\\000�WkkJ�4�R�߭�7�\\r֒~ը�J��\\\
P k+P%�������@B��ZAJ�oKH*��j��U���*@���Z$�����WV\\000*�sP���5��O�\\000��j`I��Z\\000+�?�P���V\\000K�OuT���@����\\000��?�P��3[\\000��P��T@U���\\000���P��en\\000U�_�����6\\000U��j����\\r�4�W]\\000T�?�@-�3\\000U���H��\\r@U�W�\\000���\\\
�Z�S-\\000j�����U+\\000��WY���\\\
�Z�U-\\000j�We���J\\000���Y��_�	P���L\\000U�We	�n�@���)��_M�l����ޟ����� ���(U���\\\"@��*A��'���_����USV�))��~�½�ݺ?�\\\
A�ߣkUJO��Z�Z@U����$ �z�k�D@kݾ-IҪ���*�H��j�I��7B%`�޵�B5�M���%J@��{i�(Tު7RK����V�UAV�vU%����{%E)Tkk��J)�Zk/)U\\\
���+)%Ekm�)J%am[�JIITkm�JJ)���^��j��WR�DUkի�*I���)�R���z%%����^%�$j��])�j�ի��B���U��ҪV�Jiԭ{=%�P�m��$	iV��T��UU�+���m��R\\\")��m��I$T�F{SJ���ZO	\\\"%��WJ�V���N����RU��Z]\\\
$Yj[�]���m�[�R$�������UR�R\\\"�Y����T��j�Z�UIU��jU��U�RU��V�ZW�J���V�VO�J�J�ժZ]�JU�V�j=��T)�Z�Z=�*U��Z��u�*U��Z��vU�T��j���J�T��Z���U�R������U�RU��ժVO�R���ժZO�J�J�V�V]UEi)��Vj])UU��*eںꖔT(�u��U��*d��Z�R�R�Ҫ�[UU� M�j]��UI������UC��j]U���Z�zJJU\\r����*��JT�Z�UJ�Tm���$U)�ڪ�W��T��U��T�T�j�Z7%����V��J�U�U��m�R��Z�Z픔��Z[�ڪRUUU��Z�*%Yժ�TUUԪ�ʵT�R)UKծ��T�V�Z])U�R��*�Ҫ���*m��R��UkպJ��mUiyUUU	Uժ��J�imUk+��R�jU�M�U�P��֮�TJ��V���*U�ZUU[U��D�jU�JU)EժV��T��v���R��\\\
�Tm��RH��ZU�UU�*�XUu�U����j�ZU�J�bU՛��R�RUX��M�B��o�	Y���JAU�[��JoUU���UU��*߬*�J�J-�����jU}�J���UU���]U�R�U�D�ʭj%UUm�����VEUU��*�U�T����WUYiu���Z�UU����jUTUթ��jUW�*�juU��ZUW�*�U]U�0��U���V]���VuU���UW�*�Zu���Z�U���V]U��Z����ZUW�*�ZuU�RZժ�JjU]���j�Z�JiU��*UU���RZժ�*UU���TU���LUU���TU��*SU���4UU���RUS�\",\
    [ \"lib/control.lua\" ] = \"local ControlAPI = {}\\\
\\\
local gameConfig = require \\\"config.gameconfig\\\"\\\
\\\
function ControlAPI:New(clientConfig, native_control)\\\
	local control = setmetatable({}, self)\\\
	self.__index = self\\\
\\\
	control.keysDown = {}\\\
	control.controlsDown = {}\\\
	control.antiControlRepeat = {}\\\
	control.clientConfig = clientConfig\\\
	control.native_control = native_control\\\
\\\
	return control\\\
end\\\
\\\
function ControlAPI:Clear()\\\
	self.keysDown = {}\\\
	self.controlsDown = {}\\\
end\\\
\\\
function ControlAPI:Resume(evt)\\\
	if evt[1] == \\\"key\\\" and not evt[3] then\\\
		self.keysDown[evt[2]] = 1\\\
\\\
	elseif evt[1] == \\\"key_up\\\" then\\\
		self.keysDown[evt[2]] = nil\\\
	end\\\
\\\
	return evt\\\
end\\\
\\\
function ControlAPI:CheckControl(controlName, repeatTime, repeatDelay)\\\
	repeatDelay = repeatDelay or 1\\\
\\\
	local clientConfig = self.clientConfig\\\
	\\\
	local processed_controls = {}\\\
\\\
	if self.native_control then\\\
		-- populate self.controlsDown based on self.keysDown\\\
		for name, _key in pairs(clientConfig.controls) do\\\
			self.controlsDown[name] = self.keysDown[_key]\\\
		end\\\
	end\\\
	\\\
	for k,v in pairs(self.controlsDown) do\\\
		processed_controls[k] = v\\\
	end\\\
	\\\
	-- disallow simultaneous move left + move right inputs\\\
	if self.controlsDown[\\\"move_left\\\"] and self.controlsDown[\\\"move_right\\\"] then\\\
		if self.controlsDown[\\\"move_left\\\"] > self.controlsDown[\\\"move_right\\\"] then\\\
			processed_controls[\\\"move_left\\\"] = nil\\\
		else\\\
			processed_controls[\\\"move_right\\\"] = nil\\\
		end\\\
	end\\\
\\\
	if processed_controls[controlName] then\\\
		if not self.antiControlRepeat[controlName] then\\\
			if repeatTime then\\\
				return processed_controls[controlName] == 1 or\\\
				(\\\
					processed_controls[controlName] >= (repeatTime * (1 / gameConfig.tickDelay)) and (\\\
						repeatDelay and ((processed_controls[controlName] * gameConfig.tickDelay) % repeatDelay == 0) or true\\\
					)\\\
				)\\\
			else\\\
				return processed_controls[controlName] == 1\\\
			end\\\
		end\\\
	else\\\
		return false\\\
	end\\\
\\\
end\\\
\\\
return ControlAPI\\\
\",\
    [ \"lib/gamedebug.lua\" ] = \"local _WRITE_TO_DEBUG_MONITOR = true\\r\\\
\\r\\\
local GameDebug = {}\\r\\\
\\r\\\
local to_colors = {}\\r\\\
local to_blit = {}\\r\\\
local i = 0\\r\\\
for col in (\\\"0123456789abcdef\\\"):gmatch(\\\".\\\") do\\r\\\
	to_colors[col] = 2 ^ i\\r\\\
	i = i + 1\\r\\\
end\\r\\\
for k,v in pairs(to_colors) do\\r\\\
	to_blit[v] = k\\r\\\
end\\r\\\
\\r\\\
local write_rich, process_rich, tsv\\r\\\
\\r\\\
function GameDebug:New(debug_term, is_active)\\r\\\
	local gamedebug = setmetatable({}, self)\\r\\\
	self.__index = self\\r\\\
	\\r\\\
	gamedebug.window = debug_term\\r\\\
	gamedebug.scroll_y = 0\\r\\\
	gamedebug.scroll_x = 0\\r\\\
	gamedebug.log = {}\\r\\\
	gamedebug.header = {}\\r\\\
	gamedebug.active = is_active and true or false\\r\\\
	gamedebug.tallest_header = 0\\r\\\
	\\r\\\
	gamedebug.header_bgcol = colors.gray\\r\\\
	gamedebug.log_bgcol = colors.black\\r\\\
	\\r\\\
	return gamedebug\\r\\\
end\\r\\\
\\r\\\
function GameDebug.FindMonitor()\\r\\\
	local mon = peripheral.find(\\\"monitor\\\")\\r\\\
	if not mon then\\r\\\
		if periphemu then\\r\\\
			-- CraftOS-PC with the default \\\"periphemu\\\" library\\r\\\
			if periphemu.create(\\\"right\\\", \\\"monitor\\\") then\\r\\\
				mon = peripheral.wrap(\\\"right\\\")\\r\\\
			end\\r\\\
		\\r\\\
		elseif ccemux then\\r\\\
			-- CCEmuX itself doesn't have virtual monitor support\\r\\\
			if not _HOST:match(\\\"CCEmuX\\\") then\\r\\\
				-- CraftOS-PC with ccemux module\\r\\\
				ccemux.attach(\\\"right\\\", \\\"monitor\\\")\\r\\\
				mon = peripheral.wrap(\\\"right\\\")\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
	\\r\\\
	return mon\\r\\\
end\\r\\\
\\r\\\
function GameDebug.Profile(func, ...)\\r\\\
	local time_start = os.epoch(\\\"utc\\\")\\r\\\
	local output = {func(...)}\\r\\\
	local time_total = os.epoch(\\\"utc\\\") - time_start\\r\\\
	return time_total, table.unpack(output)\\r\\\
end\\r\\\
\\r\\\
function GameDebug:ProfileHeader(name, func, ...)\\r\\\
	local output = {GameDebug.Profile(func, ...)}\\r\\\
	self:LogHeader(name, output[1] .. \\\"ms\\\", 0, true)\\r\\\
	return table.unpack(output, 2)\\r\\\
end\\r\\\
\\r\\\
function GameDebug:ProfileHeaderInline(name, func, ...)\\r\\\
	local output = {GameDebug.Profile(func, ...)}\\r\\\
	self:LogHeader(name, output[1] .. \\\"ms\\\", 0, false)\\r\\\
	return table.unpack(output, 2)\\r\\\
end\\r\\\
\\r\\\
function GameDebug:SetActive(active)\\r\\\
	self.active = active and true or false\\r\\\
end\\r\\\
\\r\\\
function GameDebug:Render(do_flush)\\r\\\
	if not self.active then return end\\r\\\
	if not self.window then return end\\r\\\
	local t = term.redirect(self.window)\\r\\\
	tsv(false)\\r\\\
	\\r\\\
	local scr_x, scr_y = term.getSize()\\r\\\
	term.setBackgroundColor(self.header_bgcol)\\r\\\
\\r\\\
	local x, y = 1, 1\\r\\\
	local line\\r\\\
	local do_clear = true\\r\\\
	\\r\\\
	local blank_line = string.rep(\\\" \\\", scr_x)\\r\\\
	\\r\\\
	-- sort fields by whether they force a line break\\r\\\
	local fields = {}\\r\\\
	for i = 1, #self.header do\\r\\\
		if not self.header[i][4] then\\r\\\
			table.insert(fields, self.header[i])\\r\\\
		end\\r\\\
	end\\r\\\
	for i = 1, #self.header do\\r\\\
		if self.header[i][4] then\\r\\\
			table.insert(fields, self.header[i])\\r\\\
		end\\r\\\
	end\\r\\\
	\\r\\\
	\\r\\\
	-- render header\\r\\\
	for i, field in ipairs(fields) do\\r\\\
		line = process_rich(field[1] .. \\\"&r&4\\\" .. tostring(field[2]), \\\"0\\\", to_blit[self.header_bgcol])\\r\\\
		if (x + #line[1] >= scr_x) or field[4] then\\r\\\
			x = 1\\r\\\
			y = y + 1\\r\\\
			do_clear = true\\r\\\
		end\\r\\\
		term.setCursorPos(x, y)\\r\\\
		self.tallest_header = math.max(self.tallest_header, y)\\r\\\
		if do_clear then\\r\\\
			term.clearLine()\\r\\\
			do_clear = false\\r\\\
		end\\r\\\
		term.blit(table.unpack(line))\\r\\\
		x = x + math.max(field[3] + #field[1], #line[1]) + 2\\r\\\
	end\\r\\\
	for iy = y + 1, self.tallest_header do\\r\\\
		term.setCursorPos(1, iy)\\r\\\
		term.clearLine()\\r\\\
	end\\r\\\
	\\r\\\
	-- render log\\r\\\
	term.setBackgroundColor(self.log_bgcol)\\r\\\
	local index = 1 - self.scroll_y\\r\\\
	for y = self.tallest_header + 1, scr_y do\\r\\\
		index = index + 1\\r\\\
		term.setCursorPos(1 - self.scroll_x, y)\\r\\\
		if self.log[index] then\\r\\\
			write_rich(\\\"~\\\" .. to_blit[self.log_bgcol] .. self.log[index] .. blank_line)\\r\\\
		else\\r\\\
			term.clearLine()\\r\\\
		end\\r\\\
	end\\r\\\
	tsv(true)\\r\\\
	term.redirect(t)\\r\\\
	\\r\\\
	if do_flush then\\r\\\
		self.header = {}\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
\\r\\\
function GameDebug:LogHeader(field, value, minimum_size, do_newline)\\r\\\
	table.insert(self.header, {field, value, minimum_size or 0, do_newline})\\r\\\
end\\r\\\
\\r\\\
function GameDebug:Log(text)\\r\\\
	self.log[#self.log + 1] = text\\r\\\
	self:Render()\\r\\\
end\\r\\\
\\r\\\
function process_rich(str, default_txcol, default_bgcol)\\r\\\
\\r\\\
	default_txcol = default_txcol or \\\"0\\\"\\r\\\
	default_bgcol = default_bgcol or \\\"f\\\"\\r\\\
\\r\\\
	local text_match = \\\"&\\\"\\r\\\
	local back_match = \\\"~\\\"\\r\\\
	local text_col = default_txcol\\r\\\
	local back_col = default_bgcol\\r\\\
	local line = {\\\"\\\", \\\"\\\", \\\"\\\"}\\r\\\
	local c\\r\\\
	local do_continue = false\\r\\\
	\\r\\\
	for i = 1, #str do\\r\\\
		if do_continue then\\r\\\
			do_continue = false\\r\\\
		else\\r\\\
			c = str:sub(i, i)\\r\\\
			if c == text_match then\\r\\\
				i = i + 1\\r\\\
				if str:sub(i, i) == \\\"r\\\" then\\r\\\
					text_col = default_txcol\\r\\\
				else\\r\\\
					text_col = str:sub(i, i)\\r\\\
					assert(to_colors[back_col], \\\"invalid TXT color'\\\" .. text_col .. \\\"'\\\")\\r\\\
				end\\r\\\
				do_continue = true\\r\\\
				\\r\\\
			elseif c == back_match then\\r\\\
				i = i + 1\\r\\\
				if str:sub(i, i) == \\\"r\\\" then\\r\\\
					back_col = default_bgcol\\r\\\
				else\\r\\\
					back_col = str:sub(i, i)\\r\\\
					assert(to_colors[back_col], \\\"invalid BG color'\\\" .. back_col .. \\\"'\\\")\\r\\\
				end\\r\\\
				do_continue = true\\r\\\
				\\r\\\
			else\\r\\\
				line[1] = line[1] .. c\\r\\\
				line[2] = line[2] .. text_col\\r\\\
				line[3] = line[3] .. back_col\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
	return line\\r\\\
end\\r\\\
\\r\\\
function write_rich(str)\\r\\\
	term.blit(table.unpack(process_rich(str)))\\r\\\
end\\r\\\
\\r\\\
function tsv(visible)\\r\\\
	if term.current().setVisible then\\r\\\
		term.current().setVisible(visible)\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
return GameDebug\\r\\\
\",\
    [ \"sound/lineclear.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000�}\\000\\000\\000\\000\\000\\000�[�yvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�}\\000\\000\\000\\000\\000�}/�D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�����˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ�,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000�6\\000\\000\\000\\000\\000\\000�}\\000\\000\\000\\000\\000Ƴbtx{txuxly�nzxwuqmjOYZQ`UWV\\\\YQF�S�M�еLX�ę��RJ����k�skV�+���C����6M.�4Ru]���cesnMj��)�ʟ�|������e�tP&S�)f�8����0|l|7\\\"BܠEgb�� @�dYթO��nǑ�\\\
\\000��.�ҙ��˵�z>�|�0l�豬/��9��a˸4E�갪e�=������j�pg�R�T�D���u�F\\\
&����#�3�\\\\<g\\r\\\\�]�x�\\000a�?����9t�t��8B7~��\\000&Ǉ12	�:%K)�����S������WU��tg���4�{�_f\\\\t��i�����:ȗS��3���P�W��N�Tl!����I���y��x���͚���1�IsIO���I��	^�V��@<PE^���J)K��Ҹ51�������<�N����ţy�[\\\"��G�b�On���	T�K�~,�#)�E�FszvO�I��������$5~Hh��F��Uj٘��e�bH!�R˖�:\\000��f��J�����W�L�_u��XSS�r�*Y�Ӗ|A�+�y��W����i��@W\\\"�I�J�b�_�T��S_:1\\\"��c�\\rG�,�ӳ�J$r�������ѧG�*����lj.�2���a���J�����7ǟ~�ׯ����U�;��u��r{Ez!��K��.��e!�YL����\\\"�T[���k��l��f[t&�c�������߻�Yć31�T��o�*�Q��л�����6�[�94�-�P�	��.eVxZRŷ�Y۴�u?nB�ߌ��5��/_#�qV��<�@3DiV�¶���y6Y�C;U�$�B��LT�h�Vc�46��{�Ei�R)Ųơ��v7�PT�����b�=��\\000�P}F_J�{��˪�x�RԞ�YI\\\\��&����L�8��'P��9���<�.Q�Zn飾d�]�z���ܼ�N��ۋ(�ݶ��4o{H�5�<}���9�$=�\\rB.��B�\\000���b\\\"g���RH��ݿ�o��w�̞�0�+��'����U�z;��PIW��7��:�51�X��ًh�x��4�7ce�����o��S�Yaα�?�����:3L၀I|��5\\\"�S�P�4��J�J)%���Z����O�N���\\\
S���_�Ӗ�[���8���Y���$�y�'���b���{�gLdu��P'�1��[ϚJMuiw��=�?�꥾q��w�{y�3�}��-�W�����w\\000R��$mK�Yf����Ӿ޻�y�<,��M2&o!��$�������Xy���C���\\rj��#���g�*#�$�Y|{�-Wi��{�3�����L%I��^3���:�&�	��ó�S=R��>K)%�������[S3OU�d��n7��G��SC�9Z0�O�ʽbʋ�+ʮ�o��L��}�I��e��\\000���K��A�X��I`�7e\\\"򿷋I�?+L,C�����!p�T���RJ��z:_u��X������������^z��sӼ)�����yݕ?�ܣrl�p���:��yK\\r#�����[��;���k�z:g�QS�S��N2t�ϡSB!��f����\\000����\\000 �Cbx�v�RJ)�,�p�~�����l[���Y(_��ױ�Vs�!�7C��rq�\\\"d)f�`fc��b�}���r��	�lU��UH��Z�	�H\\\
t^�����iU��\\\\�T�4j.̶tȎ\\r���\\\\\\\
@��.yԉY]J))u_��IG�oY�|7w�4�S��>��1���݂�GQ�z�.� �(����;�V1���ϱ�Z�����:K��L}��:�c[QC�&�:��o���N��Ko:��� �P�����%{+G�����^]���?�(�u��Q�v~l2K�������j��h��L�/5�{@�%���\\\\X��]�� ǷÙ�AO�@d�멘9�îs�Z\\\\YT�����\\000����ϒE�y��7��o���p�����Ȱ-�˕J���NC�+���b�5Ç�_���	6[+�	|a���4���j�J��TR�818�����\\\\�2r�P�4�&z^�z���3^J�4]�Qٕ������Ž�\\r�Z�������<�E����{��?��j\\\\d,��Z��.��0�9O`:F�~���g4��?ڃ�%��ڝ��Դsy���@��lj\\000�T�6�{�\\\\�k5b��U������S�G��:��L҅���$qx(�Nw����iK�nJ%=&z�����S��g)O�/���#僾-�Q�'ђW�Iլk͗f��<���KP�f\\r�-�P��΢7�ؘ�1�=��r̮P�.,0�b�������G�g<�F�RM�t���������'���:){Ւ�������=�;��s�����\\000\\r��h�Y5�67[��n*����(<���6��}�\\000��4��*�-��4��mMc�Z��0rSHO�+��l�A����HA�k��]!A�P�c�=\\\\az�����_d\\r�d!-���{�f�S�YTs\\\\G�.���QY���\\rT��jvb�uL\\r*󦡦�����s\\\"L����wB�Ѻ:\\000�|��Rj��G�[�n.��Y��}��>��˺�f���3��	g|��g��,�<]����hV\\r!�\\\\N�1X��]���Z}HOb����w�m�^D�\\\
Z�9���^��x`M��hpM�\\\"\\00088��1\\000}j�Ԥ�m�W�Q��t��ʿ���x/̉\\\"��G��DTz}�����y�7�Ui[�g�2h5�F�(}�4)�L�*�������`<���#Q=�*�q�<��&n�[lӢ��q�B�z�3�.1��ʨuM��V�D,�Ť)�-�M��ɲ�S�m�NI��#�5gM����L�i\\000y\\000��>�Tu���3]��k�����?�M�(�^o��N�p���x�P1�'F��a6�|�K�?�+\\\"��3,�AOl{�`t5Ϣ�:�b��{c\\000�Yry��ݳ�Uy���TY���Ɍl1Y�&xF�D������Q-�l��R\\0004{��+p�	��w�3b#r+l��q��B�4M��#\\000ogYEkh�h�Y�ə�)�g���_��1�5ٺ\\\\3X߈M�j�qE�Hb�~���T\\000��*0�I\\000�=��I�����5h\\000\",\
    [ \"sound/lock.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000a|\\000\\000\\000\\000\\000\\000\\\
z��vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000a|\\000\\000\\000\\000\\000���-D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�����˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ�,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000a|\\000\\000\\000\\000\\000iC-2	s�}{a]_V\\\
.�g[�(e����	X\\000�'��{_��/߿]�7�=�f?gMj��ev��N���`��7�ʰ�9[2��s�������Su}�ܹX�����F1�8����s+ϞS��Ə�R��6���`\\\
�K�'\\000��/�\\000�RUs���v��G���Xk����aN=fƑ:F��LM�Q�T;nr�4�e���$����*t�-���t�u��LA|�5�&�)w�oF1&n+=��^Ue�6���ӝC,n�\\000NɐA��� W�R����۪�o���~u�X(�h��?���P\\\"5��^���i/4 ���a\\\\J�GC[�K�䜢��Z��.Q^3��|\\\\ޞ�P�oOՖp,-%����L��vy�B���u���iKk�	J�I�ڤ�%��5����S�ϔ���^o��g�Ρs����z\\\
���FW1��m<;11�J��J���t)p�mc���6��݃d�axL6�X�UGzq]ɋ&{j�e߲��n�~��Z\\\"��T�A�Hf�����+:��W�Ⱥ/coS#3f�f��L�X�&�f�~4�؜[%��#\\r�>�p8Î|�@��O0OE7����1�sVRE�\\000��8`t�m۶@�ڒbY�㸭�43�����>n��x���f���ԑ�r@א�*lc�X�m��h��x�_�E�v�Iޝt�@��X�\\000\\000�mb�4�s9�〒���5u�S�_[�V����or.q\\\"�\\\
�I��4v�,�;O�:W�/e�2�ܘ�4��i�� ����Ж�[)�����o]v\\000��k�]�N�N)gV���Io}���ұ���\\\\U�?��~T����}�sM�L�n2=�]�1�\\000�{&l�ܸ\\000�_@����<^���U\\000I�$�\\000\\000\\000\",\
    [ \"sound/mino_O.dfpwm\" ] = \"��\\r�%���-\\000����=\\000P�ݻo\\000P���\\000�����mk�@mu�~�Zkw�\\r\\000Z�v�\\000����[\\000Xk���\\000�����\\000P����\\000Pmu��`Yu��@U{�{�Z��~\\000s��������\\r�*k���T[��7\\000��v�^\\000R۶�;\\000�v�oo\\000d�u�m\\000Tm���\\000L���z��k���Zo��\\000j�]�������wHeu��@[k�:`k��5@Uw�@�Rm�}o�\\000j�{����u�\\000Um��\\000�Z���\\r��z��m_�k�����\\000��Z����۶\\rh]������v\\000k�n�;P�ֵ[Pw�@��n��m\\000Tm[��a;\\000U��Q��5\\000T��m���\\000`mk-�nw@��~{�\\000���zk�\\000�֫�}\\000Pݭ������;�@�\\r���z�v{���Z\\000���n\\000�n\\000U����\\000��Vݺ��\\000Q��v���\\000��V��������vj\\000���uj�=\\000��V�8���\\000�u��V�}��U��o\\000Ү���og\\0006k��m��\\000�֭�Z_n\\000�n��^��\\000`[_ժ�^w\\000���[��o\\000�]��t���\\000@}�l��o}\\000\\000��\\\\��{�\\000�չ��{�\\000����{��\\000�jk�~��\\000�պk�6@���6��+Pk�\\000�m�k]@o�5\\000\\\\۪+����\\000W�[��y��\\000pUk��{��=\\000Z�B�o��z\\000��������\\000�J귺���\\000ZoU��=\\000�[���o{�\\000�^����s�\\000X������\\000Zko��]�/\\000@�����+�\\000�x���}��\\000�-���m�5\\000��\\000����m�msk���\\000Tu�����\\000\\000-�ku���nh\\000�]ZWm��\\000z{�\\000P�U�P�^��y���s������\\000�z���ھ��\\000��:^������\\000�_m��~վ�v\\000�x�����{u�\\000\\000�亭�j_n��\\000j���^U���k\\000pݪAn��o��\\r\\000��֭u��o�\\000����[o���+\\000\\000�S����o��=\\000�PwZk�z_�^��\\000�]]�ޯ��]�\\000�Z˶m��Z���@��zP=�^k۹v\\000��5�^ׇ�ϺW]\\\
\\000�`�6��Z�M�G�\\000\\000�UiO�nk�eo�\\000pS���ݵ�:��\\000쪫~[��E�Ş\\000\\000ou�uC���*_�\\000�6���m�u�?\\000�K�c���j���g\\000\\000��x�v�����\\000�]]��U�ͺ��\\000����u��Z]�yc\\000\\000��z�[5�.��;\\000@[��ަ��^�\\000��ne�Ry}���3\\000��l��J��u�\\000�N��^id{Q����Ek}�zZ�\\\"�\\000��H����*�W��`��`]��ht��X���l�/��.>\\\
༪�X�Y�-a�[��P��v���xUO����u7ԭU����N�� �����D���f@�V���\\000Ӫ�֭\\000����������ZV[mkYZm��U��ڮVT�V��T��uWPu�u[P�R֮*��U��2��U�nI�䥪[S@�-�nU�u�z���Z�U��ֻU5[A�k��ZY\\\
V��U[\\\
����*��Э��ڥZ\\000ںk��I�@{�����j]� �ۖjh]�6۪��.�V��U�ڶN�%���m�-i@׺���Z���Z��hm[k�T�R�[U�V�\\\
�[T��j+\\r`�[U�V�*�mWU�V]5��ҪU��j@�jU��R�@j[U��U��K[�U��\\000mkWUU+���VW��VTC��Z�V\\\
X�\\rr�Z�*`m�Hmm%P�[�*P�*m[[5U�V���U6�Z�zuemZ�l�EY��*E\\\
ԫVK�ʊ�H�K��\\\
��*��m�*U[�J[U+��n����U�U[ժ�j��mj��*����VՖ�ʶ���R�JP�U���R����Z�l+UU �jm����T��Vs5��m!`�UkU�V�)��6������\\000j�VmUmUUH}�e�j��\\\
��nkU�U�\\\
�,ȭ��-�*�UV۪jU-Ⱥ�@ڪU�*�V�жVU��Ve[�mZ��ZS�U@۪U�VK�j�Ԫ�jU��U��J�V��ZU@�U�jU�VU�Z��j��fU�Z�Y���jPm�V�T��VT���R��j��VmUU��ZP��j��Z)kT������U�\\000Y���ZU��P[� ���lUtU[i�i�V�Z�U�ZU�\\\
(�]�ZU�VU-9�[��UժV��Zˀ����Y[���V��B�U��VUӪ��UU�rUUU�j��VժʶH�jU\\r��U�*Un��V�*�ږ�V�j��Uժ���U��jS�U���ڪUմ�����4��-U-U�V�T����֦J�ZU�*\\\
h�ZժZ�����@�۪���V՚��@JQ�ZM�U�UU� �ZT�Z�YUYU�j��Z	��VU�*�jUUժ �UK�*U�����Y��ZUUZ�������Z\\\
�ViUժ���������VU+ժ������*�jUժ����������UU�����������VU5��J������*UUUU�������R�RUUUU���TS�4ժRUUU��JU\",\
    [ \"lib/minodata.lua\" ] = \"return {\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"    \\\",\\r\\\
			\\\"3333\\\",\\r\\\
			\\\"    \\\",\\r\\\
			\\\"    \\\",\\r\\\
		},\\r\\\
		spinID = 3,\\r\\\
		color = \\\"3\\\",\\r\\\
		name = \\\"I\\\",\\r\\\
		kickID = 2,\\r\\\
		sound = \\\"mino_I\\\"\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\" a \\\",\\r\\\
			\\\"aaa\\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 1,\\r\\\
		color = \\\"a\\\",\\r\\\
		name = \\\"I\\\",\\r\\\
		kickID = 1,\\r\\\
		sound = \\\"mino_T\\\"\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"  1\\\",\\r\\\
			\\\"111\\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 2,\\r\\\
		color = \\\"1\\\",\\r\\\
		name = \\\"L\\\",\\r\\\
		kickID = 1,\\r\\\
		sound = \\\"mino_L\\\"\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"b  \\\",\\r\\\
			\\\"bbb\\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 2,\\r\\\
		color = \\\"b\\\",\\r\\\
		name = \\\"J\\\",\\r\\\
		kickID = 1,\\r\\\
		sound = \\\"mino_J\\\"\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"44\\\",\\r\\\
			\\\"44\\\",\\r\\\
		},\\r\\\
		spinID = 3,\\r\\\
		color = \\\"4\\\",\\r\\\
		name = \\\"O\\\",\\r\\\
		kickID = 2,\\r\\\
		sound = \\\"mino_O\\\",\\r\\\
		spawnOffsetX = 1,\\r\\\
		noDelayLock = true\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\" 55\\\",\\r\\\
			\\\"55 \\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 2,\\r\\\
		color = \\\"5\\\",\\r\\\
		name = \\\"S\\\",\\r\\\
		kickID = 1,\\r\\\
		sound = \\\"mino_S\\\"\\r\\\
	},\\r\\\
	{\\r\\\
		shape = {\\r\\\
			\\\"ee \\\",\\r\\\
			\\\" ee\\\",\\r\\\
			\\\"   \\\",\\r\\\
		},\\r\\\
		spinID = 2,\\r\\\
		color = \\\"e\\\",\\r\\\
		name = \\\"Z\\\",\\r\\\
		kickID = 1,\\r\\\
		sound = \\\"mino_Z\\\"\\r\\\
	}\\r\\\
}\\r\\\
\",\
    [ \"lib/gameinstance.lua\" ] = \"-- game instance object\\r\\\
-- returns a function that resumes the game state for 1 tick and returns event info\\r\\\
\\r\\\
local Mino = require \\\"lib.mino\\\"\\r\\\
local Board = require \\\"lib.board\\\"\\r\\\
local gameConfig = require \\\"config.gameconfig\\\"\\r\\\
\\r\\\
local modem = peripheral.find(\\\"modem\\\")\\r\\\
if (not modem) and (ccemux) then\\r\\\
	ccemux.attach(\\\"top\\\", \\\"wireless_modem\\\")\\r\\\
	modem = peripheral.wrap(\\\"top\\\")\\r\\\
end\\r\\\
if modem then\\r\\\
	modem.open(100)\\r\\\
end\\r\\\
\\r\\\
local GameInstance = {}\\r\\\
\\r\\\
local scr_x, scr_y = term.getSize()\\r\\\
\\r\\\
function GameInstance:New(control, board_xmod, board_ymod, clientConfig)\\r\\\
	local game = setmetatable({}, self)\\r\\\
	self.__index = self\\r\\\
\\r\\\
	game.board_xmod = board_xmod or 0\\r\\\
	game.board_ymod = board_ymod or 0\\r\\\
	game.clientConfig = clientConfig\\r\\\
	game.control = control\\r\\\
	game.didControlTick = false\\r\\\
	game.message = {}\\r\\\
	game.uid = \\\"\\\"\\r\\\
\\r\\\
	for i = 1, 8 do\\r\\\
		game.uid = game.uid .. string.char(math.random(1, 255))\\r\\\
	end\\r\\\
\\r\\\
	return game\\r\\\
end\\r\\\
\\r\\\
local nm_actionlookup = {\\r\\\
	mino_setpos = 1,\\r\\\
	mino_lock = 2,\\r\\\
	board_update = 3,\\r\\\
	send_garbage = 4,\\r\\\
	mino_hold = 5,\\r\\\
}\\r\\\
\\r\\\
function GameInstance:AttachDebug(gamedebug)\\r\\\
	self.DEBUG = gamedebug\\r\\\
end\\r\\\
\\r\\\
function GameInstance:SerializeNetworkMoment(action, param1, param2, param3, param4)\\r\\\
	local output = self.uid .. (nm_actionlookup[action] or \\\" \\\")\\r\\\
	if action == \\\"mino_setpos\\\" or action == \\\"mino_lock\\\" then\\r\\\
		-- param1, param 2 = mino x, y\\r\\\
		-- param3 = mino type\\r\\\
		-- param4 = mino rotation\\r\\\
		output = table.concat({\\r\\\
			output,\\r\\\
			string.char((param1 + 127) % 256),\\r\\\
			string.char((param2 + 127) % 256),\\r\\\
			string.char(param3),\\r\\\
			string.char(param4)\\r\\\
		})\\r\\\
\\r\\\
	elseif action == \\\"board_update\\\" then\\r\\\
		output = table.concat({\\r\\\
			output,\\r\\\
			self.state.board:SerializeContents()\\r\\\
		})\\r\\\
	\\r\\\
	elseif action == \\\"send_garbage\\\" then\\r\\\
		output = output .. string.char(param1)\\r\\\
	\\r\\\
	elseif action == \\\"mino_hold\\\" then\\r\\\
		output = output .. string.char(param1)\\r\\\
\\r\\\
	elseif action == \\\"update\\\" then\\r\\\
		output = table.concat({\\r\\\
			output,\\r\\\
			string.char(param1), -- incomingGarbage\\r\\\
			string.char(param2), -- lines just cleared\\r\\\
			string.char(param3 or 0), -- ???\\r\\\
			string.char(param4 or 0)  -- ???\\r\\\
		})\\r\\\
	\\r\\\
	end\\r\\\
\\r\\\
	return \\\"ldris2\\\" .. output\\r\\\
end\\r\\\
\\r\\\
function GameInstance:ParseNetworkMoment(input)\\r\\\
	local moment = {}\\r\\\
	-- incredibly basic input validation\\r\\\
	-- this WILL be replaced later with something that won't explode if you feed a wrong value\\r\\\
	if input:sub(1, 6) == \\\"ldris2\\\" then\\r\\\
		input = input:sub(7)\\r\\\
	else\\r\\\
		return\\r\\\
	end\\r\\\
\\r\\\
	moment.uid = input:sub(1, 8)\\r\\\
	input = input:sub(9)\\r\\\
	local moment_type = input:sub(1, 1)\\r\\\
\\r\\\
	if moment_type == \\\"1\\\" then -- mino_setpos\\r\\\
		moment.action = \\\"mino_setpos\\\"\\r\\\
		moment.x = string.byte(input:sub(2, 2)) - 127\\r\\\
		moment.y = string.byte(input:sub(3, 3)) - 127\\r\\\
		moment.minoID = string.byte(input:sub(4, 4))\\r\\\
		moment.rotation = string.byte(input:sub(5, 5))\\r\\\
	\\r\\\
	elseif moment_type == \\\"2\\\" then -- mino_lock\\r\\\
		moment.action = \\\"mino_lock\\\"\\r\\\
		moment.x = string.byte(input:sub(2, 2)) - 127\\r\\\
		moment.y = string.byte(input:sub(3, 3)) - 127\\r\\\
		moment.minoID = string.byte(input:sub(4, 4))\\r\\\
		moment.rotation = string.byte(input:sub(5, 5))\\r\\\
\\r\\\
	elseif moment_type == \\\"3\\\" then -- board_update\\r\\\
		moment.action = \\\"board_update\\\"\\r\\\
		moment.contents = {}\\r\\\
		for i = 1, #input - 1, self.state.board.width do\\r\\\
			moment.contents[#moment.contents + 1] = input:sub(i + 1, i + 11)\\r\\\
		end\\r\\\
\\r\\\
	elseif moment_type == \\\"4\\\" then -- send_garbage\\r\\\
		moment.action = \\\"send_garbage\\\"\\r\\\
		moment.garbage = string.byte(input:sub(2, 2))\\r\\\
\\r\\\
	elseif moment_type == \\\"5\\\" then\\r\\\
		moment.action = \\\"mino_hold\\\"\\r\\\
		moment.minoID = string.byte(input:sub(2, 2))\\r\\\
		\\r\\\
	elseif moment_type == \\\"6\\\" then\\r\\\
		moment.action = \\\"update\\\"\\r\\\
		moment.incomingGarbage = string.byte(input:sub(2, 2))\\r\\\
		moment.linesJustCleared = string.byte(input:sub(3, 3))\\r\\\
		-- third field?\\r\\\
		-- fourth field?\\r\\\
	else\\r\\\
		return\\r\\\
	end\\r\\\
\\r\\\
	return moment\\r\\\
end\\r\\\
\\r\\\
\\r\\\
-- creates a lookup table of the rotated states of every mino\\r\\\
function GameInstance:MakeRotatedMinoLookup(mino_table)\\r\\\
	local output = {}\\r\\\
	local mino\\r\\\
	for i, mData in ipairs(mino_table) do\\r\\\
		output[i] = {\\r\\\
			table.copy( mino_table[i].shape ),\\r\\\
			table.copy( Mino:New(mino_table, i):Rotate(1).shape ),\\r\\\
			table.copy( Mino:New(mino_table, i):Rotate(2).shape ),\\r\\\
			table.copy( Mino:New(mino_table, i):Rotate(-1).shape )\\r\\\
		}\\r\\\
	end\\r\\\
	return output\\r\\\
end\\r\\\
\\r\\\
function GameInstance:GetSize()\\r\\\
	return \\r\\\
		gameConfig.board_width + (self.do_compact_view and 5 or 10),\\r\\\
		math.ceil(self.state.board.visibleHeight * 0.666)\\r\\\
end\\r\\\
\\r\\\
function GameInstance:Initiate(mino_table, randomseed)\\r\\\
	self.networked = false\\r\\\
	self.do_compact_view = false -- should set true, if you're doing multiplayer on a pocket computer\\r\\\
								-- do_compact_view moves the queue and hold boards to be above each other\\r\\\
	self.canPause = true\\r\\\
	self.do_render_tiny = false -- should set true, if you're a puppeted networked client\\r\\\
	self.visible = true\\r\\\
	self.state = {\\r\\\
		gravity = gameConfig.startingGravity,\\r\\\
		targetPlayer = 0,\\r\\\
		score = 0,\\r\\\
		topOut = false,\\r\\\
		canHold = true,\\r\\\
		didHold = false,\\r\\\
		didJustClearLine = false,\\r\\\
		heldPiece = false,\\r\\\
		paused = false,\\r\\\
		queue = {},\\r\\\
		queueMinos = {},\\r\\\
		linesCleared = 0,\\r\\\
		linesJustCleared = 0,\\r\\\
		minosMade = 0,\\r\\\
		random_bag = {},\\r\\\
		gameTickCount = 0,\\r\\\
		controlTickCount = 0,\\r\\\
		animFrame = 0,\\r\\\
		controlsDown = {},\\r\\\
		incomingGarbage = 0, -- amount of garbage that will be added to board after non-line-clearing mino placement\\r\\\
		combo = 0,           -- amount of successive line clears\\r\\\
		backToBack = 0,      -- amount of tetris/t-spins comboed\\r\\\
		spinLevel = 0        -- 0 = no special spin\\r\\\
	}                        -- 1 = T spin mini\\r\\\
							 -- 2 = Z/S/J/L spin\\r\\\
							 -- 3 = T spin\\r\\\
\\r\\\
	self.randomseed = randomseed or self.randomseed\\r\\\
\\r\\\
	if (mino_table or not self.mino_rotable) then\\r\\\
		self.mino_rotable = self:MakeRotatedMinoLookup(mino_table or gameConfig.minos)\\r\\\
	end\\r\\\
	self.mino_table = mino_table\\r\\\
\\r\\\
	-- create boards\\r\\\
	-- main gameplay board\\r\\\
	self.state.board = Board:New(\\r\\\
		7 + self.board_xmod,\\r\\\
		1 + self.board_ymod,\\r\\\
		gameConfig.board_width,\\r\\\
		gameConfig.board_height\\r\\\
	)\\r\\\
	self.state.board.overtopHeight = 3\\r\\\
	self.state.board.visibleHeight = 20\\r\\\
\\r\\\
	-- queue of upcoming minos\\r\\\
	self.state.queueBoard = Board:New(\\r\\\
		self.state.board.x + self.state.board.width + 1,\\r\\\
		self.state.board.y,\\r\\\
		4,\\r\\\
		28\\r\\\
	)\\r\\\
\\r\\\
	-- display of currently held mino\\r\\\
	self.state.holdBoard = Board:New(\\r\\\
		2 + self.board_xmod,\\r\\\
		1 + self.board_ymod,\\r\\\
		self.state.queueBoard.width,\\r\\\
		4\\r\\\
	)\\r\\\
	self.state.holdBoard.visibleHeight = 4\\r\\\
\\r\\\
\\r\\\
	-- indicator of incoming garbage\\r\\\
	self.state.garbageBoard = Board:New(\\r\\\
		self.state.board.x - 1,\\r\\\
		self.state.board.y,\\r\\\
		1,\\r\\\
		self.state.board.visibleHeight,\\r\\\
		\\\"f\\\"\\r\\\
	)\\r\\\
	self.state.garbageBoard.visibleHeight = self.state.garbageBoard.height\\r\\\
\\r\\\
	self.width, self.height = self:GetSize()\\r\\\
\\r\\\
	-- populate the queue\\r\\\
	for i = 1, self.clientConfig.queue_length + 1 do\\r\\\
		self.state.minosMade = self.state.minosMade + 1\\r\\\
		self.state.queue[i] = self:PseudoRandom(state)\\r\\\
	end\\r\\\
\\r\\\
	for i = 1, self.clientConfig.queue_length do\\r\\\
		self.state.queueMinos[i] = Mino:New(\\r\\\
			self.mino_table,\\r\\\
			self.state.queue[i + 1],\\r\\\
			self.state.queueBoard,\\r\\\
			1,\\r\\\
			i * 3 + 12\\r\\\
		)\\r\\\
	end\\r\\\
\\r\\\
	self.queue_anim = 0\\r\\\
\\r\\\
	self.state.mino = self:MakeDefaultMino()\\r\\\
	self.state.ghostMino = Mino:New(self.mino_table, self.state.mino.minoID, self.state.board, self.state.mino.x, self.state.mino.y,\\r\\\
	{})\\r\\\
	self.state.ghostMino.doWriteColor = true\\r\\\
\\r\\\
	local garbageMinoShape = {}\\r\\\
	for i = 1, self.state.board.height * 4 do\\r\\\
		if i > 32 then\\r\\\
			garbageMinoShape[i] = \\\"6\\\" -- you're super fucked\\r\\\
		elseif i > 24 then\\r\\\
			garbageMinoShape[i] = \\\"b\\\" -- you're fucked\\r\\\
		elseif i > 16 then\\r\\\
			garbageMinoShape[i] = \\\"1\\\"\\r\\\
		elseif i > 8 then\\r\\\
			garbageMinoShape[i] = \\\"4\\\"\\r\\\
		else\\r\\\
			garbageMinoShape[i] = \\\"e\\\"\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	self.state.garbageMino = Mino:New({\\r\\\
		[1] = {\\r\\\
			shape = garbageMinoShape,\\r\\\
			color = \\\"e\\\"\\r\\\
		}\\r\\\
	}, 1, self.state.garbageBoard, 1, self.state.garbageBoard.height + 1)\\r\\\
	\\r\\\
	if self.networked then\\r\\\
		self.canPause = false\\r\\\
	end\\r\\\
\\r\\\
	self.control.keysDown = {}\\r\\\
\\r\\\
	return self\\r\\\
end\\r\\\
\\r\\\
function GameInstance:Move(x, y)\\r\\\
	local board = self.state.board\\r\\\
	local queueBoard = self.state.queueBoard\\r\\\
	local holdBoard = self.state.holdBoard\\r\\\
	local garbageBoard = self.state.garbageBoard\\r\\\
\\r\\\
	self.board_xmod = math.floor(x or self.board_xmod)\\r\\\
	self.board_ymod = math.floor(y or self.board_ymod)\\r\\\
\\r\\\
	if self.do_compact_view then\\r\\\
		board.x = 5 + self.board_xmod\\r\\\
		board.y = 1 + self.board_ymod\\r\\\
		\\r\\\
		holdBoard.x = board.width + holdBoard.width + board.x - 3\\r\\\
		holdBoard.y = board.y + 5\\r\\\
		\\r\\\
		queueBoard.x = board.width + holdBoard.width + board.x - 3\\r\\\
		queueBoard.y = board.y\\r\\\
	else\\r\\\
		board.x = 7 + self.board_xmod\\r\\\
		board.y = 1 + self.board_ymod\\r\\\
		\\r\\\
		holdBoard.x = 2 + self.board_xmod\\r\\\
		holdBoard.y = 1 + self.board_ymod\\r\\\
		\\r\\\
		queueBoard.x = board.width + holdBoard.width + board.x - 3\\r\\\
		queueBoard.y = board.y\\r\\\
	end\\r\\\
\\r\\\
	garbageBoard.x = board.x - 1\\r\\\
	garbageBoard.y = board.y\\r\\\
	\\r\\\
	self.width, self.height = self:GetSize()\\r\\\
	if self.do_render_tiny then\\r\\\
		self:RenderTiny(true, {ignore_dirty = true})\\r\\\
	else\\r\\\
		self:Render(true, {ignore_dirty = true})\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
function GameInstance:MakeSound(name)\\r\\\
	self.message.sound = name\\r\\\
end\\r\\\
\\r\\\
function GameInstance:CyclePiece()\\r\\\
	local nextPiece = self.state.queue[1]\\r\\\
	table.remove(self.state.queue, 1)\\r\\\
	self.state.minosMade = self.state.minosMade + 1\\r\\\
	self.state.queue[#self.state.queue + 1] = self:PseudoRandom(state)\\r\\\
	return nextPiece\\r\\\
end\\r\\\
\\r\\\
function GameInstance:PseudoRandom()\\r\\\
\\r\\\
	math.randomseed(self.state.minosMade, self.randomseed)\\r\\\
\\r\\\
	if gameConfig.randomBag == \\\"random\\\" then\\r\\\
		return math.random(1, #gameConfig.minos)\\r\\\
\\r\\\
	elseif gameConfig.randomBag == \\\"singlebag\\\" then\\r\\\
		if #self.state.random_bag == 0 then\\r\\\
			-- repopulate random bag\\r\\\
			for i = 1, #gameConfig.minos do\\r\\\
				if math.random(0, 1) == 0 then\\r\\\
					self.state.random_bag[#self.state.random_bag + 1] = i\\r\\\
				else\\r\\\
					table.insert(self.state.random_bag, 1, i)\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
		local pick = math.random(1, #self.state.random_bag)\\r\\\
		local output = self.state.random_bag[pick]\\r\\\
		table.remove(self.state.random_bag, pick)\\r\\\
		return output\\r\\\
\\r\\\
	elseif gameConfig.randomBag == \\\"doublebag\\\" then\\r\\\
		if #self.state.random_bag == 0 then\\r\\\
			for r = 1, 2 do\\r\\\
				-- repopulate random bag\\r\\\
				for i = 1, #gameConfig.minos do\\r\\\
					if math.random(0, 1) == 0 then\\r\\\
						self.state.random_bag[#self.state.random_bag + 1] = i\\r\\\
					else\\r\\\
						table.insert(self.state.random_bag, 1, i)\\r\\\
					end\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
		local pick = math.random(1, #self.state.random_bag)\\r\\\
		local output = self.state.random_bag[pick]\\r\\\
		table.remove(self.state.random_bag, pick)\\r\\\
		return output\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
function GameInstance:MakeDefaultMino()\\r\\\
	local nextPiece\\r\\\
	if self.state.didHold then\\r\\\
		if self.state.heldPiece then\\r\\\
			nextPiece, self.state.heldPiece = self.state.heldPiece, self.state.mino.minoID\\r\\\
		else\\r\\\
			nextPiece, self.state.heldPiece = self:CyclePiece(), self.state.mino.minoID\\r\\\
		end\\r\\\
	else\\r\\\
		nextPiece = self:CyclePiece()\\r\\\
	end\\r\\\
\\r\\\
	return Mino:New(\\r\\\
		self.mino_table,\\r\\\
		nextPiece,\\r\\\
		self.state.board,\\r\\\
		math.floor(self.state.board.width / 2 - 1) + (gameConfig.minos[nextPiece].spawnOffsetX or 0),\\r\\\
		math.floor(gameConfig.board_height_visible - 1) + (gameConfig.minos[nextPiece].spawnOffsetY or 0),\\r\\\
		self.state.mino\\r\\\
	)\\r\\\
end\\r\\\
\\r\\\
function GameInstance:CalculateGarbage(linesCleared)\\r\\\
	local output = 0\\r\\\
	local lncleartbl = {\\r\\\
		[0] = 0,\\r\\\
		[1] = 0,\\r\\\
		[2] = 1,\\r\\\
		[3] = 2,\\r\\\
		[4] = 4,\\r\\\
		[5] = 5,\\r\\\
		[6] = 6,\\r\\\
		[7] = 7,\\r\\\
		[8] = 8\\r\\\
	}\\r\\\
\\r\\\
	if (self.state.spinLevel == 3) or (\\r\\\
		self.state.spinLevel == 2 and\\r\\\
		gameConfig.spin_mode >= 2 and\\r\\\
		(not gameConfig.are_non_T_spins_mini)\\r\\\
	) then\\r\\\
		output = output + linesCleared * 2\\r\\\
	else\\r\\\
		output = output + (lncleartbl[linesCleared] or 0)\\r\\\
	end\\r\\\
\\r\\\
	-- add combo bonus\\r\\\
	output = output + math.max(0, math.floor((self.state.combo - 1) / 2))\\r\\\
\\r\\\
	\\r\\\
	if self.didJustClearLine then\\r\\\
		-- add back-to-back bonus\\r\\\
		if self.state.backToBack >= 2 then\\r\\\
			output = output + 1\\r\\\
		end\\r\\\
\\r\\\
		-- add perfect clear bonus\\r\\\
		if self.state.board:CheckPerfectClear() then\\r\\\
			output = output + 10\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	return output\\r\\\
end\\r\\\
\\r\\\
function GameInstance:HandleLineClears()\\r\\\
	local mino, board = self.state.mino, self.state.board\\r\\\
\\r\\\
	-- get list of full lines\\r\\\
	local clearedLines = { lookup = {} }\\r\\\
	for y = 1, board.height do\\r\\\
		if not board.contents[y]:find(\\\" \\\") then\\r\\\
			clearedLines[#clearedLines + 1] = y\\r\\\
			clearedLines.lookup[y] = true\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	-- clear the lines, baby\\r\\\
	if #clearedLines > 0 then\\r\\\
		local newContents = {}\\r\\\
		local i = board.height\\r\\\
		for y = board.height, 1, -1 do\\r\\\
			if not clearedLines.lookup[y] then\\r\\\
				newContents[i] = board.contents[y]\\r\\\
				i = i - 1\\r\\\
			end\\r\\\
		end\\r\\\
		for y = 1, #clearedLines do\\r\\\
			newContents[y] = string.rep(\\\" \\\", board.width)\\r\\\
		end\\r\\\
		self.state.board.contents = newContents\\r\\\
	end\\r\\\
	\\r\\\
	self.state.linesCleared = self.state.linesCleared + #clearedLines\\r\\\
	self.state.linesJustCleared = #clearedLines\\r\\\
\\r\\\
	return clearedLines\\r\\\
end\\r\\\
\\r\\\
function GameInstance:SendGarbage(amount)\\r\\\
	if amount ~= 0 then\\r\\\
		self.message.attack = (self.message.attack or 0) + amount\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
function GameInstance:ReceiveGarbage(amount)\\r\\\
	if amount ~= 0 then\\r\\\
		self.state.incomingGarbage = math.floor(self.state.incomingGarbage + amount)\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
function GameInstance:Render(doDrawOtherBoards, tOpts)\\r\\\
	if self.visible then\\r\\\
		if self.clientConfig.do_ghost_piece then\\r\\\
			self.state.board:Render(tOpts, self.state.ghostMino, self.state.mino)\\r\\\
		else\\r\\\
			self.state.board:Render(tOpts, self.state.mino)\\r\\\
		end\\r\\\
		if doDrawOtherBoards then\\r\\\
			self.state.holdBoard:Render(tOpts)\\r\\\
			self.state.queueBoard:Render(tOpts, table.unpack(self.state.queueMinos))\\r\\\
			self.state.garbageBoard:Render(tOpts, self.state.garbageMino)\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
-- intended for previews of an enemy's board over a networked game\\r\\\
function GameInstance:RenderTiny(doDrawOtherBoards)\\r\\\
	if self.visible then\\r\\\
		if self.networked or (not self.clientConfig.do_ghost_piece) then\\r\\\
			self.state.board:RenderTiny(nil, self.state.mino)\\r\\\
		else\\r\\\
			self.state.board:RenderTiny(nil, self.state.ghostMino, self.state.mino)\\r\\\
		end\\r\\\
		if doDrawOtherBoards then\\r\\\
			self.state.holdBoard:RenderTiny({2, 0})\\r\\\
			self.state.garbageBoard:RenderTiny(nil, self.state.garbageMino)\\r\\\
			if not self.networked then\\r\\\
				self.state.queueBoard:RenderTiny({-5, 0}, table.unpack(self.state.queueMinos))\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
function GameInstance:AnimateQueue()\\r\\\
	table.remove(self.state.queueMinos, 1)\\r\\\
	self.state.queueMinos[#self.state.queueMinos + 1] = Mino:New(\\r\\\
		self.mino_table,\\r\\\
		self.state.queue[self.clientConfig.queue_length],\\r\\\
		self.state.queueBoard,\\r\\\
		1,\\r\\\
		(self.clientConfig.queue_length + 1) * 3 + 12\\r\\\
	)\\r\\\
	self.queue_anim = 3\\r\\\
end\\r\\\
\\r\\\
function GameInstance:Tick()\\r\\\
	local mino, ghostMino, garbageMino = self.state.mino, self.state.ghostMino, self.state.garbageMino\\r\\\
	local mino_name = mino.name\\r\\\
	\\r\\\
	self.didJustClearLine = false\\r\\\
\\r\\\
	local didCollide, didMoveX, didMoveY, yHighestDidChange = mino:Move(0, self.state.gravity, true)\\r\\\
	local doCheckStuff = false\\r\\\
	local doAnimateQueue = false\\r\\\
	local doMakeNewMino = false\\r\\\
	self.state.didHold = false\\r\\\
\\r\\\
	self.queue_anim = math.max(0, self.queue_anim - 0.8)\\r\\\
	self.state.gravity = gameConfig.startingGravity + (math.floor(self.state.linesCleared / 10) * 0.1)\\r\\\
\\r\\\
	-- position queue minos properly\\r\\\
	for i = 1, #self.state.queueMinos do\\r\\\
		self.state.queueMinos[i].y = (i * 3 + 12) + math.min(3, math.floor(self.queue_anim))\\r\\\
	end\\r\\\
\\r\\\
	if not mino.finished then\\r\\\
		mino.resting = (not didMoveY) and mino:CheckCollision(0, 1)\\r\\\
\\r\\\
		if yHighestDidChange then\\r\\\
			mino.movesLeft = gameConfig.lock_move_limit\\r\\\
		end\\r\\\
\\r\\\
		if mino.resting then\\r\\\
			mino.lockTimer = mino.lockTimer - gameConfig.tickDelay\\r\\\
			if mino.lockTimer <= 0 then\\r\\\
				mino.finished = 1\\r\\\
			end\\r\\\
		else\\r\\\
			mino.lockTimer = gameConfig.lock_delay\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	mino.spawnTimer = math.max(0, mino.spawnTimer - gameConfig.tickDelay)\\r\\\
	if mino.spawnTimer == 0 then\\r\\\
		if (not mino.active) then\\r\\\
			self:MakeSound(gameConfig.minos[mino.minoID].sound)\\r\\\
			self:AnimateQueue()\\r\\\
		end\\r\\\
		mino.active = true\\r\\\
		mino.visible = true\\r\\\
		ghostMino.active = true\\r\\\
		ghostMino.visible = true\\r\\\
	end\\r\\\
\\r\\\
	if mino.finished then\\r\\\
		if mino.finished == 1 then -- piece will lock\\r\\\
			self.state.didHold = false\\r\\\
			self.state.canHold = true\\r\\\
			-- check for top-out due to placing a piece outside the visible area of its board\\r\\\
			if false then -- I'm doing that later\\r\\\
				\\r\\\
			else\\r\\\
				doAnimateQueue = true\\r\\\
				mino:Write()\\r\\\
				doMakeNewMino = true\\r\\\
				doCheckStuff = true\\r\\\
			end\\r\\\
\\r\\\
		elseif mino.finished == 2 then -- piece will attempt hold\\r\\\
			if self.state.canHold then\\r\\\
				self.state.didHold = true\\r\\\
				self.state.canHold = false\\r\\\
\\r\\\
				if self.state.heldPiece then\\r\\\
					doAnimateQueue = false\\r\\\
				else\\r\\\
					doAnimateQueue = true\\r\\\
				end\\r\\\
\\r\\\
				-- draw held piece\\r\\\
				self.state.holdBoard:Clear()\\r\\\
				Mino:New(\\r\\\
					self.mino_table,\\r\\\
					mino.minoID,\\r\\\
					self.state.holdBoard,\\r\\\
					1 + (gameConfig.minos[mino.minoID].spawnOffsetX or 0),\\r\\\
					2,\\r\\\
					{}\\r\\\
				):Write()\\r\\\
\\r\\\
				doMakeNewMino = true\\r\\\
				doCheckStuff = true\\r\\\
			else\\r\\\
				mino.finished = false\\r\\\
			end\\r\\\
		else\\r\\\
			error(\\\"somehow mino.finished is \\\" .. tostring(mino.finished))\\r\\\
		end\\r\\\
\\r\\\
		local linesCleared = self:HandleLineClears()\\r\\\
		local _delay = (#linesCleared > 0 and self.clientConfig.line_clear_delay or self.clientConfig.appearance_delay)\\r\\\
\\r\\\
		if doMakeNewMino then\\r\\\
			self.state.mino = self:MakeDefaultMino(); mino = self.state.mino\\r\\\
			self.state.ghostMino = Mino:New(self.mino_table, mino.minoID, self.state.board, mino.x, mino.y, {}); ghostMino = self.state.ghostMino\\r\\\
			self.state.ghostMino.doWriteColor = true\\r\\\
\\r\\\
			if (not self.state.didHold) and (_delay > 0) then\\r\\\
				mino.spawnTimer = _delay\\r\\\
				mino.active = false\\r\\\
				mino.visible = false\\r\\\
				ghostMino.active = false\\r\\\
				ghostMino.visible = false\\r\\\
\\r\\\
			else\\r\\\
				self:MakeSound(gameConfig.minos[mino.minoID].sound)\\r\\\
				if doAnimateQueue then\\r\\\
					self:AnimateQueue()\\r\\\
				end\\r\\\
			end\\r\\\
\\r\\\
			if mino:CheckCollision(0, 0) then\\r\\\
				self.state.topOut = true\\r\\\
			end\\r\\\
\\r\\\
		end\\r\\\
\\r\\\
		-- check for top-out due to obstructed mino upon entry\\r\\\
		-- attempt to move mino at most 2 spaces upwards before considering it fully topped out\\r\\\
		-- NOTE: unsure why, but this fucks up for some reason\\r\\\
		--[[\\r\\\
		if doCheckStuff then\\r\\\
			self.state.topOut = true\\r\\\
			for i = 0, 2 do\\r\\\
				if not mino:CheckCollision(0, -i) then\\r\\\
					mino.y = mino.y - i\\r\\\
					self.state.topOut = false\\r\\\
					break\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
		--]]\\r\\\
\\r\\\
		-- calls the frame when a new mino is generated\\r\\\
		-- if the hold attempt fails (say, you already held a piece), it wouldn't do to check for a top-out or line clears\\r\\\
		if doCheckStuff then\\r\\\
\\r\\\
			if not self.state.didHold then\\r\\\
				if #linesCleared == 0 then\\r\\\
					self.state.combo = 0\\r\\\
				else\\r\\\
					self:MakeSound(\\\"lineclear\\\")\\r\\\
					self.didJustClearLine = true\\r\\\
					self.state.combo = self.state.combo + 1\\r\\\
					if #linesCleared >= 4 or self.state.spinLevel >= 1 then\\r\\\
						if (\\r\\\
							self.state.spinLevel >= 3 or\\r\\\
							(self.state.spinLevel == 2 and gameConfig.spin_mode >= 2) or\\r\\\
							(self.state.spinLevel == 1 and gameConfig.spin_mode >= 3)\\r\\\
						) then\\r\\\
							self.state.backToBack = self.state.backToBack + 1\\r\\\
						end\\r\\\
						\\r\\\
					else\\r\\\
						self.state.backToBack = 0\\r\\\
					end\\r\\\
				end\\r\\\
\\r\\\
				-- calculate garbage to be sent\\r\\\
				local garbage = self:CalculateGarbage(#linesCleared)\\r\\\
				garbage, self.state.incomingGarbage = math.max(0, garbage - self.state.incomingGarbage),\\r\\\
				math.max(0, self.state.incomingGarbage - garbage)\\r\\\
\\r\\\
				if garbage > 0 then\\r\\\
					self.DEBUG:Log(\\\"Doled out \\\" .. garbage .. \\\" lines\\\")\\r\\\
				end\\r\\\
				\\r\\\
				if self.state.spinLevel == 1 then\\r\\\
					self.DEBUG:Log(\\\"T-spin mini!\\\")\\r\\\
				elseif self.state.spinLevel == 2 then\\r\\\
					if gameConfig.are_non_T_spins_mini then\\r\\\
						self.DEBUG:Log(mino_name .. \\\"-spin mini!\\\")\\r\\\
					else\\r\\\
						self.DEBUG:Log(mino_name .. \\\"-spin!\\\")\\r\\\
					end\\r\\\
				elseif self.state.spinLevel == 3 then\\r\\\
					if #linesCleared == 3 then\\r\\\
						self.DEBUG:Log(\\\"T-spin triple!\\\")\\r\\\
					else\\r\\\
						self.DEBUG:Log(\\\"T-spin!\\\")\\r\\\
					end\\r\\\
				end\\r\\\
\\r\\\
				-- send garbage to enemy player\\r\\\
				self:SendGarbage(garbage)\\r\\\
\\r\\\
				-- generate garbage lines\\r\\\
				local taken_garbage = math.min(self.state.incomingGarbage, gameConfig.garbage_cap)\\r\\\
				self.state.board:AddGarbage(taken_garbage)\\r\\\
				self.state.incomingGarbage = self.state.incomingGarbage - taken_garbage\\r\\\
			end\\r\\\
\\r\\\
			if doMakeNewMino then\\r\\\
				self.state.spinLevel = 0\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
end\\r\\\
\\r\\\
function GameInstance:CheckSpecialSpin(mino, kick_count)\\r\\\
	-- intended for T-tetraminos\\r\\\
	-- if spinID == 1 and not all 3 corners are occupied on the board, no speical spin (return 0)\\r\\\
	-- if spinID == 1 and only one of the \\\"top\\\" corners are occupied on the board, it is a T-spin mini (return 1)\\r\\\
	-- (exception: if kick_count == 6, which is the TST kick, return 3)\\r\\\
	-- if spinID == 2 (for z/s spins) or 3 (for I spins), run separate logic (return 2)\\r\\\
	-- if spinID == 1 and both \\\"top\\\" corners are occupied, it's a full T-spin (return 3)\\r\\\
	\\r\\\
	if mino.spinID == 1 then\\r\\\
		-- sheesh\\r\\\
		local corners = {\\r\\\
			mino.board:IsSolid(mino.x, mino.y),\\r\\\
			mino.board:IsSolid(mino.x + mino.width - 1, mino.y),\\r\\\
			mino.board:IsSolid(mino.x + mino.width - 1, mino.y + mino.height - 1),\\r\\\
			mino.board:IsSolid(mino.x, mino.y + mino.height - 1),\\r\\\
			nil\\r\\\
		}\\r\\\
		local solid_count = 0\\r\\\
		for i = 1, #corners do\\r\\\
			if corners[i] then\\r\\\
				solid_count = solid_count + 1\\r\\\
			end\\r\\\
		end\\r\\\
\\r\\\
		if solid_count >= 3 then\\r\\\
			if (corners[mino.rotation + 1] and corners[((mino.rotation + 1) % 4) + 1]) or kick_count == 6 then\\r\\\
				return 3\\r\\\
			else\\r\\\
				return 1\\r\\\
			end\\r\\\
		end\\r\\\
\\r\\\
	elseif mino.spinID == 2 or mino.spinID == 3 then\\r\\\
		if (\\r\\\
			mino:CheckCollision(1, 0) and\\r\\\
			mino:CheckCollision(-1, 0) and\\r\\\
			mino:CheckCollision(0, -1)\\r\\\
		) then return 2 else return 0 end\\r\\\
	end\\r\\\
	\\r\\\
	return 0\\r\\\
	\\r\\\
end\\r\\\
\\r\\\
-- keep this in gameinstance.lua\\r\\\
-- fast actions are ones that should be possible to do multiple times per game tick, such as rotation or movement\\r\\\
-- i should make a separate function for instant controls and held controls...\\r\\\
function GameInstance:ControlTick(onlyFastActions)\\r\\\
	local dc, dmx, dmy -- did collide, did move X, did move Y\\r\\\
	local didSlowAction = false\\r\\\
	local _, kick_count\\r\\\
\\r\\\
	local control = self.control\\r\\\
	local mino = self.state.mino\\r\\\
	local board = self.state.board\\r\\\
	local state = self.state\\r\\\
\\r\\\
	if control:CheckControl(\\\"pause\\\", false) then\\r\\\
		if self.canPause then\\r\\\
			state.paused = not state.paused\\r\\\
			control.antiControlRepeat[\\\"pause\\\"] = true\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	if state.paused or not mino.active then\\r\\\
		return false\\r\\\
	end\\r\\\
\\r\\\
	if not onlyFastActions then\\r\\\
		if control:CheckControl(\\\"move_left\\\", self.clientConfig.move_repeat_delay, self.clientConfig.move_repeat_interval) then\\r\\\
			if not mino.finished then\\r\\\
				mino:Move(-1, 0, true, true)\\r\\\
				didSlowAction = true\\r\\\
				control.antiControlRepeat[\\\"move_left\\\"] = true\\r\\\
			end\\r\\\
		end\\r\\\
		if control:CheckControl(\\\"move_right\\\", self.clientConfig.move_repeat_delay, self.clientConfig.move_repeat_interval) then\\r\\\
			if not mino.finished then\\r\\\
				mino:Move(1, 0, true, true)\\r\\\
				didSlowAction = true\\r\\\
				control.antiControlRepeat[\\\"move_right\\\"] = true\\r\\\
			end\\r\\\
		end\\r\\\
		if control:CheckControl(\\\"soft_drop\\\", 0) then\\r\\\
			mino:Move(0, state.gravity * self.clientConfig.soft_drop_multiplier, true, false)\\r\\\
			didSlowAction = true\\r\\\
			control.antiControlRepeat[\\\"soft_drop\\\"] = true\\r\\\
		end\\r\\\
		if control:CheckControl(\\\"hard_drop\\\", false) then\\r\\\
			mino:Move(0, board.height, true, false)\\r\\\
			mino.finished = 1\\r\\\
			self:MakeSound(\\\"drop\\\")\\r\\\
			didSlowAction = true\\r\\\
			control.antiControlRepeat[\\\"hard_drop\\\"] = true\\r\\\
		end\\r\\\
		if control:CheckControl(\\\"sonic_drop\\\", false) then\\r\\\
			if mino:Move(0, board.height, true, true) then\\r\\\
				self:MakeSound(\\\"drop\\\")\\r\\\
			end\\r\\\
			didSlowAction = true\\r\\\
			control.antiControlRepeat[\\\"sonic_drop\\\"] = true\\r\\\
		end\\r\\\
		if control:CheckControl(\\\"hold\\\", false) then\\r\\\
			if not mino.finished then\\r\\\
				mino.finished = 2\\r\\\
				control.antiControlRepeat[\\\"hold\\\"] = true\\r\\\
				didSlowAction = true\\r\\\
			end\\r\\\
		end\\r\\\
		if control:CheckControl(\\\"quit\\\", false) then\\r\\\
			--state.topOut = true\\r\\\
			self.message.quit = true\\r\\\
			control.antiControlRepeat[\\\"quit\\\"] = true\\r\\\
			didSlowAction = true\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	if control:CheckControl(\\\"rotate_ccw\\\", false) and gameConfig.can_rotate then\\r\\\
		_, _, kick_count = mino:RotateLookup(-1, true, self.mino_rotable)\\r\\\
		if mino.spinID <= gameConfig.spin_mode then\\r\\\
			state.spinLevel = self:CheckSpecialSpin(mino, kick_count)\\r\\\
		end\\r\\\
		control.antiControlRepeat[\\\"rotate_ccw\\\"] = true\\r\\\
	end\\r\\\
	if control:CheckControl(\\\"rotate_cw\\\", false) and gameConfig.can_rotate then\\r\\\
		_, _, kick_count = mino:RotateLookup(1, true, self.mino_rotable)\\r\\\
		if mino.spinID <= gameConfig.spin_mode then\\r\\\
			state.spinLevel = self:CheckSpecialSpin(mino, kick_count)\\r\\\
		end\\r\\\
		control.antiControlRepeat[\\\"rotate_cw\\\"] = true\\r\\\
	end\\r\\\
	if control:CheckControl(\\\"rotate_180\\\", false) and gameConfig.can_rotate and gameConfig.can_180_spin then\\r\\\
		_, _, kick_count = mino:RotateLookup(2, true, self.mino_rotable)\\r\\\
		if mino.spinID <= gameConfig.spin_mode then\\r\\\
			state.spinLevel = self:CheckSpecialSpin(mino, kick_count)\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	return didSlowAction\\r\\\
end\\r\\\
\\r\\\
function GameInstance:GameOverAnimation()\\r\\\
	local old_overtop_height = self.state.board.overtopHeight\\r\\\
	for i = 1, math.ceil(self.state.board.visibleHeight) do\\r\\\
		if self.do_render_tiny then\\r\\\
			self.state.board:AddGarbage(1, true, (i % 2 == 0) and \\\" \\\" or \\\"0\\\")\\r\\\
			self.state.board:RenderTiny()\\r\\\
		else\\r\\\
			self.state.board:AddGarbage(1, true, (i % 2 == 0) and \\\"0\\\" or \\\"8\\\")\\r\\\
			self.state.board:Render({ignore_dirty = true})\\r\\\
		end\\r\\\
		self.state.board.overtopHeight = 0\\r\\\
		sleep(0.1)\\r\\\
	end\\r\\\
	self.state.board.overtopHeight = old_overtop_height\\r\\\
	sleep(0.5)\\r\\\
end\\r\\\
\\r\\\
function GameInstance:Resume(evt, doTick)\\r\\\
	local mino, ghostMino, garbageMino = self.state.mino, self.state.ghostMino, self.state.garbageMino\\r\\\
	local state, control = self.state, self.control\\r\\\
	self.message = {} -- sends back to main\\r\\\
	\\r\\\
	local doRender = false\\r\\\
	local moment -- used for multiplayer\\r\\\
	\\r\\\
	if evt[1] == \\\"network_moment\\\" then\\r\\\
		moment = self:ParseNetworkMoment(evt[2])\\r\\\
	end\\r\\\
\\r\\\
	if not self.networked then\\r\\\
\\r\\\
		self.control:Resume(evt)\\r\\\
\\r\\\
		if evt[1] == \\\"key\\\" and not evt[3] then\\r\\\
			self.control.keysDown[evt[2]] = 1\\r\\\
			self.didControlTick = self:ControlTick(false)\\r\\\
			state.controlTickCount = state.controlTickCount + 1\\r\\\
			doRender = true\\r\\\
			\\r\\\
			if evt[2] == keys.one then\\r\\\
				state.incomingGarbage = state.incomingGarbage + 1\\r\\\
			elseif evt[2] == keys.two then\\r\\\
				self:GameOverAnimation()\\r\\\
				self.message.quit = true\\r\\\
			end\\r\\\
\\r\\\
		elseif evt[1] == \\\"key_up\\\" then\\r\\\
			self.control.keysDown[evt[2]] = nil\\r\\\
		end\\r\\\
\\r\\\
		if evt[1] == \\\"timer\\\" then\\r\\\
			if doTick then\\r\\\
				for k, v in pairs(self.control.keysDown) do\\r\\\
					self.control.keysDown[k] = 1 + v\\r\\\
				end\\r\\\
				self:ControlTick(self.didControlTick)\\r\\\
				state.controlTickCount = state.controlTickCount + 1\\r\\\
				if not state.paused then\\r\\\
					self:Tick(message)\\r\\\
					state.gameTickCount = state.gameTickCount + 1\\r\\\
				end\\r\\\
				self.didControlTick = false\\r\\\
				self.control.antiControlRepeat = {}\\r\\\
\\r\\\
				doRender = true\\r\\\
			end\\r\\\
		end\\r\\\
\\r\\\
		if evt[1] == \\\"network_moment\\\" and moment then\\r\\\
			if moment.action == \\\"send_garbage\\\" then\\r\\\
				state.incomingGarbage = moment.garbage\\r\\\
				doRender = true\\r\\\
			end\\r\\\
		end\\r\\\
\\r\\\
		if state.topOut then\\r\\\
			-- this will have a more elaborate game over sequence later\\r\\\
			self.message.gameover = true\\r\\\
			DEBUG:Log(\\\"Game over!\\\")\\r\\\
			self:GameOverAnimation()\\r\\\
			self.message.quit = true\\r\\\
		end\\r\\\
\\r\\\
	else\\r\\\
\\r\\\
		-- \\\"network_moments\\\" always come from other clients\\r\\\
		if evt[1] == \\\"network_moment\\\" and moment then\\r\\\
			--moment = self:ParseNetworkMoment(evt[2])\\r\\\
			--_G.moment = moment\\r\\\
\\r\\\
			if moment.action == \\\"mino_setpos\\\" then\\r\\\
				mino.x = moment.x\\r\\\
				mino.y = moment.y\\r\\\
				mino.minoID = moment.minoID\\r\\\
				mino:ForceRotateLookup(moment.rotation, self.mino_rotable)\\r\\\
				doRender = true\\r\\\
\\r\\\
			elseif moment.action == \\\"mino_lock\\\" then\\r\\\
				mino.x = moment.x\\r\\\
				mino.y = moment.y\\r\\\
				mino.minoID = moment.minoID\\r\\\
				mino:ForceRotateLookup(moment.rotation, self.mino_rotable)\\r\\\
				mino.lock_timer = 0\\r\\\
				doRender = true\\r\\\
\\r\\\
			elseif moment.action == \\\"board_update\\\" then\\r\\\
				state.board.contents = moment.contents\\r\\\
				self.visible = true\\r\\\
				doRender = true\\r\\\
\\r\\\
			elseif moment.action == \\\"mino_hold\\\" then\\r\\\
				-- draw held piece\\r\\\
				state.holdBoard:Clear()\\r\\\
				Mino:New(\\r\\\
					self.mino_table,\\r\\\
					moment.minoID,\\r\\\
					state.holdBoard,\\r\\\
					1 + (gameConfig.minos[mino.minoID].spawnOffsetX or 0),\\r\\\
					2,\\r\\\
					{}\\r\\\
				):Write()\\r\\\
				doRender = true\\r\\\
			elseif moment.action == \\\"update\\\" then\\r\\\
				state.incomingGarbage = moment.incomingGarbage\\r\\\
				state.linesCleared = state.linesCleared + moment.linesJustCleared\\r\\\
				self.visible = true\\r\\\
			end\\r\\\
		end\\r\\\
	\\r\\\
	end\\r\\\
\\r\\\
	if doRender then\\r\\\
		-- handle ghost piece\\r\\\
		if self.clientConfig.do_ghost_piece then\\r\\\
			ghostMino.color = \\\"c\\\"\\r\\\
			ghostMino.shape = mino.shape\\r\\\
			ghostMino.x = mino.x\\r\\\
			ghostMino.y = mino.y\\r\\\
			ghostMino:Move(0, state.board.height, true)\\r\\\
\\r\\\
			garbageMino.y = 1 + state.garbageBoard.height - state.incomingGarbage\\r\\\
		end\\r\\\
		\\r\\\
		if self.do_render_tiny then\\r\\\
			self:RenderTiny(true)\\r\\\
		else\\r\\\
			self:Render(true)\\r\\\
		end\\r\\\
		\\r\\\
		if true then\\r\\\
			term.setCursorPos(state.board.x, (state.board.y) * 2 + self.height)\\r\\\
			term.setTextColor(colors.lightGray)\\r\\\
			term.write(\\\"Lines: \\\")\\r\\\
			term.setTextColor(colors.yellow)\\r\\\
			term.write(state.linesCleared)\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	if (not self.networked) then\\r\\\
		local packet = {}\\r\\\
		if state.gameTickCount % 3 == 0 then\\r\\\
			packet[#packet + 1] = self:SerializeNetworkMoment(\\\"mino_setpos\\\", mino.x, mino.y, mino.minoID, mino.rotation)\\r\\\
			packet[#packet + 1] = self:SerializeNetworkMoment(\\\"board_update\\\", state.board.contents)\\r\\\
		end\\r\\\
		\\r\\\
		if (state.gameTickCount % 3 == 0) or (state.linesJustCleared > 0) then\\r\\\
			packet[#packet + 1] = self:SerializeNetworkMoment(\\\"update\\\", state.incomingGarbage, state.linesJustCleared)\\r\\\
		end\\r\\\
\\r\\\
		if self.message.attack then\\r\\\
			--packet[#packet + 1] = self:SerializeNetworkMoment(\\\"send_garbage\\\", self.message.attack)\\r\\\
		end\\r\\\
\\r\\\
		if state.didHold then\\r\\\
			packet[#packet + 1] = self.message.packet, self:SerializeNetworkMoment(\\\"mino_hold\\\", state.heldPiece)\\r\\\
		end\\r\\\
		\\r\\\
		self.message.packet = packet\\r\\\
	end\\r\\\
\\r\\\
	return self.message\\r\\\
end\\r\\\
\\r\\\
return GameInstance\\r\\\
\",\
    [ \"sound/fall.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000'~\\000\\000\\000\\000\\000\\000p��vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000'~\\000\\000\\000\\000\\000��@[D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�����˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ�,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\0002\\000\\000\\000\\000\\000\\000'~\\000\\000\\000\\000\\000\\000Ｎ{ub\\\\^]XaUWRNOOQRPSJTQMKQONv�L\\000���*`����d��g�}�n='���Mp��6�G#���t�z�ƻ>n�]<%�����mi:M5&t���bJJ��^\\\"nN�7�T����s��[>e���	�O���L|̱3���M��k\\000���\\000�����їRJz��i���ZYa���>�[b#T=�N�����l%p���#K���*�O�13BՓ���2�)��ZĈ��T7������ʪ��V\\\"�$R���LK��X	�Ć�7\\000��\\\\�Q0�����\\\\-f�{���=�g��R|Ź�_ܘ��N�0^�EDk��j�9i�le�I�o�� `��+n	�Y�`��()e�C�%��\\\\�1�l�S}\\000��\\\
@<T[62�R�ܹ���Oۮ���m����f�*d����]����!~C�����n,�*�,��l����QU��y�r:٭�;�N���v\\000��\\\
@\\000�^�����#���gnO��u�[wa�/����=kT����Ss��N�n�1�%�Z\\\\�R�ܬg�����j�s�D,��\\000͟�o��c\\000��\\000\\000���c��k�e�ʣ�U�O���NY8���c��B���#6�Ș��z���|'\\\"`�~�Y\\\"vZ$�n(Hu���(��\\\
O�����-á=��,��5\\000��\\\
D\\000\\000�?\\000NAi�Xu٘!���ڿ~.�W��+�\\\"��A���c�!C���mL��	���ҙ]����a{����AQ:���b1�\\000\\000~�T��\\000x2s���v�M�d��M֜o��~�����Y*ֱŞO8�s^��9^؞]����L��=����H$�:\\000	��`�=ߞ&�\\rmbXKn�\\000���\\000S@�Y\\\
x�HJ\\r*I�/{����[��o��cs�|�������i��,�lF[��&נ��ek?�/Th����P�$�j\\000��D\\000�DXS��I�q{�0�G�v�q|�Y�谙.�M}��Z�e�|�fGdh�-��/����\\000=�h,��yZd��ި\\\"����b\\000��H\\000W\\000�Sjk���:�/�����b/���hq�����p�M�¤ד�+E����\\000|��\\\"F�Q2L1�sbD�ֿ5@�\\000��F\\000\\000�=��r�<ܙ����ع)����6㬊�`��J���so|KkfA9�/�\\000p�\\000�0�-���@�b�B\\000z�$	���\\r��Si|��^�|�Hq��5���Ple�=ħ�C�	v�p��ڊҠR�&�4.��,��ȶ�wL(�P�P\\000~���H�w����ϳ�x�~�u�>\\\"/��l'cnC�\\\
~��;�Y�AaQ��h�I=SB~< =�<#\\\
�֝�0�C�~�\\000r��	�;�� ��D�BTr���e}�l�mٳ`w޲�<��;i����Qo`8~Ns�68)\\\"�͆��KZa$g���:iB��\\000b���lΗsBց���[�=W�f)�ߺ�<{}� �h�q��>R9V\\\
N�&MW�*0Kn��HRa�t/�u��\\000��C\\000R�ҙI\\000�g4���;���W��2��b�\\\\(�ym$�=�j��ש�P�ɂ��@�O.�l\\\\�dc��O�E��\\000b�4��\\000x���*������ޣ֫nG���̘bVY�Nոw� �}ߡ�7\\\\JM�N矉Y'C62/.�%ߔB*\\r��z�H\\000f�(\\000�\\0008s �$���q?~Y6��4�g�a���x�u]��Y'��d���,���xv��A�\\000�or%|�uq�L�J��~R�؁\\000�R5Q�RU�y|�4ٳ���s.��te{�ӐG��\\\
Q��iö5Vf┡S�S���cI��B(4(TnC\\000N���\\000\\\"��dxV����J���~�t����h˷I�����5�V,>��jM�һu�t�x����J&\\\
���f�L��P�С�r.c\\000B��\\000�@���a�j �z�xW�~���ѡxZ�\\r'�(�Gb�.P��P�:M=�M��p��ŭ���4��c��y_\\0006���.\\000�)U��u�p�������Mm�7�gu��0�M���K��\\rR��e왩�6c��\\\
��m��8p:0��ƈ�t\\0006��\\000�Й1��@i��@�z�}ӭ�~�o}��&\\\\�箄�2�;˝�3\\r���0��-8�\\\
Xt��Oi��v�=��8`�w�\\000oԁ�P�3��S�4�QI4�u�7i�����X��L(&[�[�w�چl���;�LaO��ۅ�n^��\\\"=�L��1�&\\r�\\000MV\\000�H�:=7��0dg�~���w�v��V�k��wy���ϼ�Z��x�k;��n(�\\\
���&E�c�Ѐɽ�h�P\\000\\000\",\
    [ \"lib/kicktables.lua\" ] = \"local kicktables = {}\\r\\\
\\r\\\
--  0     1     2     3\\r\\\
--      \\r\\\
--  @  |  @  |     |  @\\r\\\
-- @@@ |  @@ | @@@ | @@\\r\\\
--     |  @  |  @  |  @\\r\\\
\\r\\\
-- keep in mind that in these tables, Y+ faces UP so that the tables correspond with the tetris wiki\\r\\\
\\r\\\
kicktables[\\\"SRS\\\"] = {\\r\\\
	[1] = { -- used on J, L, S, T, Z tetraminos\\r\\\
		[\\\"01\\\"] = {{ 0, 0}, {-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}},\\r\\\
		[\\\"10\\\"] = {{ 0, 0}, { 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}},\\r\\\
		[\\\"12\\\"] = {{ 0, 0}, { 1, 0}, { 1,-1}, { 0, 2}, { 1, 2}},\\r\\\
		[\\\"21\\\"] = {{ 0, 0}, {-1, 0}, {-1, 1}, { 0,-2}, {-1,-2}},\\r\\\
		[\\\"23\\\"] = {{ 0, 0}, { 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}},\\r\\\
		[\\\"32\\\"] = {{ 0, 0}, {-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}},\\r\\\
		[\\\"30\\\"] = {{ 0, 0}, {-1, 0}, {-1,-1}, { 0, 2}, {-1, 2}},\\r\\\
		[\\\"03\\\"] = {{ 0, 0}, { 1, 0}, { 1, 1}, { 0,-2}, { 1,-2}},\\r\\\
		[\\\"02\\\"] = {{ 0, 0}, { 0, 1}, { 1, 1}, {-1, 1}, { 1, 0}, {-1, 0}},\\r\\\
		[\\\"13\\\"] = {{ 0, 0}, { 1, 0}, { 1, 2}, { 1, 1}, { 0, 2}, { 0, 1}},\\r\\\
		[\\\"20\\\"] = {{ 0, 0}, { 0,-1}, {-1,-1}, { 1,-1}, {-1, 0}, { 1, 0}},\\r\\\
		[\\\"31\\\"] = {{ 0, 0}, {-1, 0}, {-1, 2}, {-1, 1}, { 0, 2}, { 0, 1}},\\r\\\
	},\\r\\\
	\\r\\\
	[2] = {	-- used on I tetraminos\\r\\\
		[\\\"01\\\"] = {{ 0, 0}, {-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}},\\r\\\
		[\\\"10\\\"] = {{ 0, 0}, { 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}},\\r\\\
		[\\\"12\\\"] = {{ 0, 0}, {-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}},\\r\\\
		[\\\"21\\\"] = {{ 0, 0}, { 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}},\\r\\\
		[\\\"23\\\"] = {{ 0, 0}, { 2, 0}, {-1, 0}, { 2, 1}, {-1,-2}},\\r\\\
		[\\\"32\\\"] = {{ 0, 0}, {-2, 0}, { 1, 0}, {-2,-1}, { 1, 2}},\\r\\\
		[\\\"30\\\"] = {{ 0, 0}, { 1, 0}, {-2, 0}, { 1,-2}, {-2, 1}},\\r\\\
		[\\\"03\\\"] = {{ 0, 0}, {-1, 0}, { 2, 0}, {-1, 2}, { 2,-1}},\\r\\\
		[\\\"02\\\"] = {{ 0, 0}, { 0, 1}},\\r\\\
		[\\\"13\\\"] = {{ 0, 0}, { 1, 0}},\\r\\\
		[\\\"20\\\"] = {{ 0, 0}, { 0,-1}},\\r\\\
		[\\\"31\\\"] = {{ 0, 0}, {-1, 0}}\\r\\\
	},\\r\\\
}\\r\\\
\\r\\\
return kicktables\\r\\\
\",\
    [ \"sound/mino_Z.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000]a\\000\\000\\000\\000\\000\\000\\\"��vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000]a\\000\\000\\000\\000\\00027�D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�����˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ�,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000]%\\000\\000\\000\\000\\000\\000]a\\000\\000\\000\\000\\000�`idBIPOVKZINO?O@AJA;AWV���O����A�b�-�-\\000�x�h�`3��<����O���F��IW\\r���F\\r������{	@��_���<�b�J����,���sU.j��\\000u<)��	\\000r��I���l�/\\000J\\000\\000.\\000\\000\\000���\\000���\\000�@���\\000��(`x��\\000t��W\\000�?�\\r\\000r��e�|*Փj�\\000XY@�-\\000\\000����\\000��\\000Hu�\\000h�\\000\\000\\\\9�z�\\000�\\000�@� ���$��B9\\000R����>��ڤN\\000�\\r�u�.����~���̚\\000f]�u�<�|��_e��;3���X\\000����ے ���M\\000��*\\000f���e��\\\\�G��K�\\000 HDU��6Y���x�H\\000�Ɠa�d�6��;\\000�9���pu�8q�j�D<h;\\\\C��	\\000v���oL�\\000���\\000]<=�\\000{�����;0jk��X\\000\\000N��S�K�Ї���\\000(k|�\\r���Qwt�&����\\000^��\\000���/��.�Ԁ%Lݭ	cjݯ#�`2���\\\
\\000`_�]	��\\\"\\000kO���H_�+>6���Ey�����\\000R�V���4�����c����_����_���vNn&nFJ������yZ����\\\
�/��ۀS\\r%p\\\"���:Kb��F}�Aɰ�	 n�\\\"�&$'��\\000\\000n?\\\"\\000�U\\000\\000\\r��\\\
�\\000\\\"�8�@��%\\000�_�Q\\000\\000��h�H��Vc����ABԡ�\\000j�T��)�,x��;�\\000*\\000\\000��\\\
P��y����'H 6`�\\000xy�o�\\000�����+�:��_�\\\" �C��\\000V�^�P5H>@�2O��t@ Y����\\\"n_���\\000T����ў�\\000l�b`k0.�7\\\
ck��嚯A�ڪ�3ՠ*�[�Q����n�\\000춄�B*����&�a\\000L��:�X�x	�N0�e,�� zb��rB��\\000���0���Y)�Uu�5R�歯ߛ�4��\\000L_��8\\000䋩K���*�b�'�6��-\\r�\\\
�$ԭ�배z����\\000&�5���N\\000%����jd�h`{�p-����?�aE���a��e���\\\\���\\000&�5��{<@��`!�f@~�K*H��\\000�5`�\\000��4:9@[X'9�ǉC ��Q�u�rar\\000{}P�΀w{��٪uk�[vF���,�\\000Z���E��M.�h9NKxے����:Q���1�9_ӻ��\\000\\\"���/������S��eY�m�[K�K�:�_|\\\"l	\\000�*�W�Θ�q�\\\
�j(P�2}�[G�&�=�\\000V�P\\000�ު��Ѥ�H\\000PP\\000|�\\000�\\r�:4xƀ	�Á�A�)\\000y����\\\"�=��,������li;��T	<a<�\\000|`,�\\\
��M؁�\\r.!!_5�\\000[����M�\\000�R2��R�����|Y�[��@���G'b����u�q��y�����2p�8�\\r���������$6�B�U/���Ab\\\\\\000\",\
    [ \"sound/mino_J.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000�g\\000\\000\\000\\000\\000\\000ѕ~�vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�g\\000\\000\\000\\000\\000e#CD�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�����˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ�,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000PF\\000\\000\\000\\000\\000\\000�g\\000\\000\\000\\000\\0008��%MBSGYMQXLbNRVPgfhaQTLfgRT`QAAOAD6D96BS[��F�ax��PU�jU\\000�?X`1�,E��S���[����=�\\000@|�Dӝo��\\000d_/i\\000@��ʕ\\000��\\0000�B\\000V[[�}o��O\\\
��?υ.%U@���H�4f��4Q�\\000I��\\000v4\\000h�\\000\\000�_���%p�J\\000Ne��l�{�~P?h���-\\000�v��	���պ�}�5_��]j.\\000�i�D�>�w��B����j��|�V��@E\\000p=�1\\000\\000�Vq+�����@yЧ�`R�\\000P���\\000���b�����ɚ(�e���\\000����TX\\000��\\\
\\000��CI`es�yNy�)\\000(,F	$X���};���F<�j}��k����z��_�/���ѶO,���4`i)ڱ�)\\000\\000��Rt\\000\\000�c,$\\000Ry�J.����ȯ��m�N\\000��z��\\000�\\rA#5ǖ���ѭX�?9~\\000P��4gv -z��^|�zX@�\\000\\000G\\000Fg�=�o� ��s=(��@�m�h�f���e���O��Ox36�w�����oBM��!\\rG#�y��ڿ)ls\\000\\000�G��\\000Vu���S��A�� n\\000�\\000�h�[�b��:��w�\\\"���.���ɩ0fO>\\000DZڳ�ԅ=��+�����d/<�\\000�X�r�\\000F��3@�\\\\\\r�^^/ o\\000X@���\\\"�a�ų~i��w�#K\\000�N�|��1�\\000�\\000*\\000޿�	�&*��\\000	�_z\\000F�U��(�ר_����?<� @$���2G�\\000��Dj5G�msmM>Un),�'E:��@��\\000`��%��;�&�>;qv�`c�����\\\
��8˙\\000N�}��vd��t����.\\000K\\000��s�Y\\000*GY��?O�.�H�O�@�0=�>��~��$$��0P\\000���j�7R�UdK�#y=��������`��%�m:\\000T��,]�Թ�q,�UM�Q)0�MT;�}\\000�2�HJ��!`?$Pw���9.#��jBs�*���3����J�#hA��XIi��jӴ�^k����USt����%y����d�m##��J@�I�ƞ���7�\\000�̯�5Nor������|�l��d<*�L�\\0008�q�i�>ۏ+	\\000\\000\\\"�VsSkNF�w.&�w�c`��3�?�\\000\\000�R �V�\\000�K\\000B��\\\"`SG���-�LkQBo\\000�'�r��uO��;�k��XI��b@Ӱ^���싃��b��v3�����	�����9\\000��\\000B2L��_���ހX'K\\000��\\000\\000B�+�(�\\\\�im���� зGr�x\\0008\\000\\000�m�\\000�b�질T��Y�_�D�-�\\000@s���^�_3�/l���.�f�T��(��(1�(�q\\000m���l\\000R��U�RC���Fy0�``�=�\\000�^��ʺ�R������¼ɲd���0�U\\000���Aj�w\\000\\0000��s��\\000Q\\000��&�j�7�`���̈́\\000��>�Y;{7.�E���s�Q\\r�\\0008\\000\\000���\\000��D4t٬�M�?�9'[:�\\000\\000�'r\\000��/�E_���92��r�>X�pV�$��n�yv�~��\\000\\000Oe\\000���\\000N�T�&�%�+����z\\000N$\\000x�\\000�\\000t*4d�ڔ��o�M��#�x$`*�\\000��?k��_�\\000pS!\\000�\\000���\\000\\000@�.�5w^\\\
*�$[����\\\
 w����+�>�ɥ��UӰOՆGOg�y3}[��17���\\000x ����� �!c�UA_�HS\\000�ա�HF�E�7���m#*�`�q��\\000\\000-���Ly������\\000\\000�;\\000,Y½pJ�w�9�+`Q���·r�\\000sp�\\000\\000`�\\000:���D�Ah���ڀ\\000�:\\000\\000�G�/\\000,½�M5�s_�u����Tz�X�X�vY��4�6�\\r 5r�^���w\\000��gw���ף\\000\\000p��\\000��=\\\\��z��F��{z���B���wD\\000<b�ik\\000\\000�@���F�	\\000ޭA����9�{o�J8�>�\\000H15�~>\\r��]�Y�68]��ܮp����4�\\000@o�р�}���(\\000�N�9W��l����@ph�\\000�\\000@Y\\000�6�K\\000e\\000P�j�j+��+��\\\
\\\"�h��\\000\\000G�\\000����ei�g%���[H�Y\\000J�uLs�^T�]@�O\\000O�\\000@�\\000\\000�k�a�R�g}�|�n#��H&�	\\000H)\\0000�#K@RU�$]A�7#\\000\\000;\\000�s[	\\000J�1�ݸ:�}s]X-��=��iK\\000�6 `��_c�����K�j��;$���Xŷ\\000f����0�l�g\\000���@\\000�\\000,��\\000�����YLC\\000J�1w]�}���C~�������\\000��ʰ�ˑR��Y�}@�\\000�_\\000�RZ\\000&��\\\"�_Ft�˯�\\\"�\\000~^2\\000\\000��	�4����iҶ\\r�@e�5^q�G�X���:���x���hI@R��-Eg�pv1P�\\000��Z���s���Kϲ�l�̑ff�eisǙni�\\0003�&�h��%3����8\\0000�_����\\000<�:G!A��Q�8��|[�嬞oo��$��q�Ԙ�o�`&Y���VX9W]\\000�?�'\\000�%$w���s`��ڶ^�6q,P��}��X�r^y=8�(TIP��\\000��!\\000\\000��?\\000 \\000~]\\000��D�H\\000��W_�ҥ���,����2 \\000X�����.ˢ`�R%\\000=\\000�.������\\000�5%��{\\000\\000\\000p���3\\000�:���2q����{o4�����g��(8+*ׇ��\\000\\000N|�\\000\\000`�\\000�,\\000��V�('��1R ۶G��\\\"��k*��;Ļ|.f��euF�/70���\\000��\\000�}%\\000`\\000��s���\\000�2��T���h�B?��l\\r\\r���J�֛��\\000�K��6��2\\000<�\\000�tP����y!v]���h����F\\0008�z��<ps7�Q��&�_\\000�\\r�\\000n\\\\耹\\rw�I�$��\\000\\000�\\000\",\
    [ \"config/gameconfig.lua\" ] = \"return {\\r\\\
	minos = {},					-- list of all the minos (pieces) that will spawn into the board (populated from /lib/minodata.lua)\\r\\\
	kickTables = {},			-- list of all kick tables for pieces (populated from /lib/kicktables.lua)\\r\\\
	lock_delay = 0.5,			-- (Lock Delay) amount of seconds it will take for a resting mino to lock into placed\\r\\\
	currentKickTable = \\\"SRS\\\",	-- current kick table\\r\\\
	randomBag = \\\"singlebag\\\",	-- current pseudorandom number generator\\r\\\
								-- \\\"singlebag\\\" = normal tetris guideline random\\r\\\
								-- \\\"doublebag\\\" = doubled bag size\\r\\\
								-- \\\"random\\\" = using math.random\\r\\\
	board_width = 10,			-- width of play area\\r\\\
	board_height = 40,			-- height of play area\\r\\\
	board_height_visible = 20,	-- height of play area that will render on screen (anchored to bottom)\\r\\\
	spin_mode = 2,				-- 1 = allows T-spins\\r\\\
								-- 2 = allows J/L-spins\\r\\\
								-- 3 = allows ALL SPINS! Similar to STUPID mode in tetr.io\\r\\\
	are_non_T_spins_mini = true,	-- if true, then all J/K/S/Z mino spins are considered \\\"mini\\\" (contributes to B2B, but does not grant bonus)\\r\\\
	can_180_spin = true,		-- if false, 180 spins are disallowed\\r\\\
	can_rotate = true,			-- if false, will disallow ALL piece rotation (meme mode)\\r\\\
	startingGravity = 0.15,		-- gravity per tick for minos\\r\\\
	lock_move_limit = 30,		-- amount of moves a mino can do after descending below its lowest point yet traversed\\r\\\
								-- used as a method of preventing stalling -- set it to math.huge for infinite\\r\\\
	tickDelay = 0.05,			-- time between game ticks\\r\\\
	garbage_cap = 4,			-- highest amount of garbage that will push to the board at once\\r\\\
	enable_sound = true,		-- enables use of speaker peripheral for game sounds\\r\\\
	enable_noteblocksound = false,	-- if true, opts for noteblock sounds intead of the included .ogg files\\r\\\
	minos = require \\\"lib.minodata\\\"\\r\\\
}\\r\\\
\",\
    [ \"sound/lineclear.dfpwm\" ] = \"�}�@�y8��� zz�[\\000����ԿU`�1����?�R�u��\\rG<�p�@���#��y-[5X:�!��*��:������s����<q�A!R�m�I/�~��3��Q����������h���QmA�S��S$%��:��q�g�qƩs�q�q���a�8N��q���q�q�,�8�9�4���8�3e���j��q��&�8�3U�9�KZ35�1�\\\\4�9�s�g\\\\�q�cN�--/��8|�p��x�4Z���t�>�\\r]�Y��'��p��,�J�[����ZD{��,��f��5H��c�}�Q�;P��e��)N�;�)�8��^܃�@�;�)#G=DU�)%`�_w�U��P\\\
�^(~G��_U�B��\\\\\\000�{�����&/\\000�c]�]��W���z,B(��-[W�̲��{����2���N[�kޥ�	8�/T徝��H_\\\\ק,�t �a�}X� NㅲغW�[W N�F�y�i�1�8c�)㔇s�NK5MM�p\\\\��8:�i希㘖�s�it�q�9�9��Xc�q�ǲr)��1v�1�1�3K�1ͪ*�8�c�r�c��9�X�\\rg�i��8.5\\\\;��c<<��Mf�q�i�)|R.�V:��q	�=�N�c��Q��k�-4�\\\
��-��\\r�7\\ri�(���z(�����w�u�>#(�j��(��]�\\\
hˏ*��>j�*��%$����R(�^e��j�mqT�R��^�\\\"\\\
�l�[׫�! �ei���^%�w\\000����iT��5��3��f��`�gh��W�ļ�BP�z�zˠ�p��� �[RJ|���6K\\000�j�3���{.�Uh8�q���$��W��p�q�1Ǳ��r8N�ӴJ+��t�q̬q��e��sG�GǋcZ�8��c�Xji�\\r�c嘓S��9.�8S�Y�X1�gt��ҲrL�tʌǱq�)��qZ�G/���Sqɣr|��K��ʅ�Ce^�E�?��u���R5ܑ��#�OS�c���[�,Ӫ-XܩƤ)���1��W�or�@��B(�V�*��:.�s$��{.I ��q�x��w�u��w�.��2�y{�hm)���Z����:�p�+�y�W��s�.��묢L�t�`��a��y�1�P��{}��T	����K �ֽ��WL!��_�_��V@~�^�CЫ\\\"U� ��Z�>� j��Xs�/�8�q��j8K\\r8�,�1m�jz����q��,�,�r8��1N��j�8NK��X�h�q���1�8s�3�q,U�S�4u̘3�8c�S�s�F㔖�cU�)Ǚ:�8�8ut8<��bYǱq�q�q:��h���V5:��<��\\\"�8����J��/����B_\\\
^zA;�5T7��=�U��A�gU,�Y�����>0�*z����`2:E��H����+�RU^�D�(����c�c����p�u��E���!ٷ�!O�,T��}�`�\\\
[/�q!�q{.#���L�x]'w%Di�xW��j�p�b���:%��U�!��U¹N�:8�/O�(����q���6�e\\r�9�+�y1ښKP�:�6u�yT��]J��F����8V�7�����9�.�#�Y�q,kƩq��p��s�)k���sǲqj�i4���c̚c�c�i\\\\Ui���T�c��T�s�2����T�9�9Nq\\\\��G�<�h�Ocz8.K���q��hO��G�\\r<�*U+�,�/u�+�n����*�O1ԏ���:��1����^KZ�^p.�z�ẑ����aQ��H�D��S�I����#���Z����.P��Z@~�Q�w�4��N�V�g��;�O,�*Z~;R�p���a%�W�W�������R�t(�{ő�W�.�:!��7�{���\\\"ʅϱ�c����}F(ӬB|��e8^9#���F1���R�0@��:�0�s�9��b�r�1���8��8�s�Y�XU�q<f�i�iƙ�1�qZ��q��9Ɯ��ǚi�8fV9f��6�q��cs�ũrL�±�q��<\\\\<N�\\\\�Ԋ�����.UC�ґՃ99u��l��p5�+�~1��J|��Eӧd���.�>	�*ԥX۠F?B�e�}`��\\000-�7@�VE���f���	��Cue�;��N�1�Ey��Zs	��r���h\\\"������j5�9��XQ��J�_9�TnY���W�f�i�,�Nx�օ@{��㘆���ނE4[���?�j��� �X�<�Py�wPO�F0ηF5��B�i��j1Կ��7����X�$�u�\\\\�d�i�)�r,�R�f�3��a�9�cY.���8Ǭ8բU9�8\\\\c�X3�8+�1f՘��8N�XS�;�Z�c�c�1G�9��)�Ǳ�x+�X96�559��Y�)mJ-��8�塥7<r%����y�S--y�8.��r��-�R�O7�/�1�=����b)��-�_�.�o���BZ��b���k�=��=�r�7����}I^F��^Ӈ�XC�+NP��Y��\\\
~�A��^�p���E\\000��;�P�ZAy�[Rz��j�f��]���YQ�5K��z���N�+`5�3+��9�K\\\
�^��b�߄��b���8,G��G��wS�z�0mw�y��Uºu,�5g9'�c�85���T���qy8��3�4�s85N5�4u�e�Ǌg�cZGc�c��L˱�85�qe�+c�S�gʊ+�0w,�+�3e��0y�SjSx�R�A�qi������)���#����ú�G;�/Ԏ5,��-��R/�t��OD��S���_��:H]gp�j�0�$������z���8�t5�Ρ�Q��i4\\\\�y���A��PK���?�h�n��W�O�P�s�uu�V+�mWŵ죗���/��r���5\\\\��\\\"�{�+�~�!�.ix��\\\\�xz�~\\r�lW�1��,�Xԧqo�@xE�����{�XOḨ���ڡÉ�n�5p�*�I�[��KS�3G�8�8+)�U�ҡ�\\\"����(s��Õ3Τ�x�bV.f�41�8c����1V�8�c���r��q�e��U�4�gL�C�8�iI�8���e��)�g�W8\\\\<N..�r83αʱ����H�Y�ᥲ�<t�y,�.�h\\\\_ᄮL�/\\r��ROR��l�,���'���R;��QE��;Q\\\\#F}�)�|/X,,�F�%�T6L�u0I�:H�)�n�R/�d�+�-}���t~ZޚD�z4mR�{(�\\\
}Y���(�R�]�r�i{�b�䵕F��.�8/7h�^B��5�{�bԩZj�P�H�7�r\\\
u^���5n�QN�W�݋���Za��qoM{�V,Եʬ6�)��2�fe���b�V���SF�R՘j�i�jq�q4�9-�x,F�,�cL9ƒ���Y%�(S�1�ʱR˸t,�Q��1��jY�cN�e̙K�Q6-�*�ө�Դ�h�h��Zq��U.�Hǩ�L.�8�Xqj�ר5Z�b��<r�Q/���TSe:j9rYeY��\\\\e<:r�x�^Ʋʤ/EۢVc��P^U���z�4t�HuT-�;,�9�J��*M+�T΋��5�6��Ҭ4�qRUs,K3�LS��QU+'V5-��bMKUՊֲ��F�lM5�q�dx�jѮ��渲�ZT�J��j4N�k��U��8Vi�iVe�U�9��4��J��,�8+�X�J�t�R�r*U�lT�J�4�LV����̔�,�U��Yq��e�f���V���UU�X�f5�J�UӱT-5͸�̲,��Yƪj<�ť��f9Vg�j���e�ƥVi���e�VY����Xd9�����\\\\6VZZ�qe�Sji��ii�i���YZƩ��e��O�f���V����e��e�Yf\",\
    [ \"sound/mino_T.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000`\\000\\000\\000\\000\\000\\000U�Evorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000`\\000\\000\\000\\000\\000�')iD�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�����˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ�,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000g!\\000\\000\\000\\000\\000\\000`\\000\\000\\000\\000\\000>63dOEbHH]HKBDG7BD6@SR�Ě���[�\\\
?@.�z:,�1�ݙ��O���ӓU��SS��1�z>�!�U���7H�Y?�E�(a�ZՀ�;sU���E��!X\\r\\\\�⃫��=`\\000j����\\\
l&��!�@\\000\\000�=�\\000@��\\000(GmbkA!�`�U�o\\000�\\000|@���z�@�o0<�	E��3p�A\\000n�&��7�$�m.@��E�\\0008�0Ta��.������\\\
�*\\\
08􅏃D4��Ĉ��C�\\\
��\\000V�ҫǅ_O�\\000uv«�W�L�vjݮ���&t�Z�a�9rj��8�ʀ���ù�ם\\000܌��L��p°\\\
��niW/!��a�=�8�6U�\\0003�y�\\000n�D�̹��� s@.��� �֫�����\\r\\000\\\\	 ���µp��Z�{�&P�$���(w�`�f��ۯW�$��y�\\000���|\\000��ܶ�Lj�7\\000iR�⠃���t#\\000;�\\000,�����Y���rn	V�+�:@)��)_ .��	����M�����W:�H`n[$�uo���9DC\\rf\\r�>�4@��}b�X�\\000��Q_Rt��Ġ���`�Vv��n�uL�Tz2Q��@��\\000\\000.\\000��m���r|�\\\
\\000��\\000��P\\000�\\000\\000�����|�.	Wc�\\\
`;:\\000j��}/*=�%qv+\\000��\\000-�M��a�v�5�ςc\\000��\\r���g�\\000�S\\000�5�2����N��\\\
H�BJ��y�K�A��(O�LCNd=P�~=7Ί\\000D�gU�N`_OXI.W���XGCb�;U&5((*\\000&��Ru�3=Q�[��tc���jb��n��/��|��*�1�k	\\000|���(�8�l1�@4 &|`\\000�4R/_,�G�B� ��+�me�4�oc�'�����lS�r\\000�p-\\000'���o-�p P��`�	+�p\\\".�$�߯h$*x����(�\\000CZҁ\\\
\\0000��M�@�L����44�	~\\000\\\"��q�&��q����ɷU�f����ɺ&���M��\\000�,ᛀf�+,F�chNJ.p�І+H�3�+��*T�PT�N\\000X�0���U�f������ea2�6|@�G����|p�e��/lO��\\\
�\\0006�5>��|L �\\000P�N5P�$�G\\000\\r\\000�p�\\000?\\000<|@�	�4���\\000&��6�Y\\\\]���\\000�C#�������o��E\\000�=��w~�5(=�̂(�\\\
\\\
�1:\\000a태�E��t�7�c�!_�_��~5�Ï�qD-���@OÓ@�_:`��\\000��l��*��Qx��,2saQ�x�`f��檠\",\
    [ \"ldris2.lua\" ] = \"local _AMOUNT_OF_GAMES = 1\\\
local _PRINT_DEBUG_INFO = true\\\
--[[\\\
   ,--,\\\
,---.'|\\\
|   | :       ,---,    ,-.----.     ,---,  .--.--.        ,----,\\\
:   : |     .'  .' `\\\\  \\\\    /  \\\\ ,`--.' | /  /    '.    .'   .' \\\\\\\
|   ' :   ,---.'     \\\\ ;   :    \\\\|   :  :|  :  /`. /  ,----,'    |\\\
;   ; '   |   |  .`\\\\  ||   | .\\\\ ::   |  ';  |  |--`   |    :  .  ;\\\
'   | |__ :   : |  '  |.   : |: ||   :  ||  :  ;_     ;    |.'  /\\\
|   | :.'||   ' '  ;  :|   |  \\\\ :'   '  ; \\\\  \\\\    `.  `----'/  ;\\\
'   :    ;'   | ;  .  ||   : .  /|   |  |  `----.   \\\\   /  ;  /\\\
|   |  ./ |   | :  |  ';   | |  \\\\'   :  ;  __ \\\\  \\\\  |  ;  /  /-,\\\
;   : ;   '   : | /  ; |   | ;\\\\  \\\\   |  ' /  /`--'  / /  /  /.`|\\\
|   ,/    |   | '` ,/  :   ' | \\\\.'   :  |'--'.     /./__;      :\\\
'---'     ;   :  .'    :   : :-' ;   |.'   `--'---' |   :    .'\\\
          |   ,.'      |   |.'   '---'              ;   | .'\\\
          '---'        `---'                        `---'\\\
\\\
LDRIS 2 (Work in Progress)\\\
Last update: April 22nd 2025\\\
\\\
Current features:\\\
+ Basic modem multiplayer! (barely functional)\\\
+ SRS wall kicks! 180-spins!\\\
+ 7bag randomization!\\\
+ Modern-feeling controls!\\\
+ Garbage attack!\\\
+ Ghost piece, piece holding, sonic drop!\\\
+ Configurable SDF, DAS, ARR, ARE, lock delay, etc.!\\\
+ Animated piece queue!\\\
+ Included sound effects!\\\
\\\
To-do:\\\
+ Fix multiplayer\\\
+ Try to further mitigate any garbage collector-related slowdown in CraftOS-PC\\\
+ Polish the menu\\\
+ Add proper game over screen\\\
+ Implement DFPWM audio so that real sound effects work in CC:Tweaked\\\
+ Refactor code to look prettier\\\
+ Add score, and let line clears and piece dropping add to it\\\
+ Implement initial hold and initial rotation\\\
+ Implement arcade features (proper kiosk mode, krist integration)\\\
+ Add touchscreen-friendly controls for CraftOS-PC Mobile\\\
+ Cheese race mode\\\
+ 40-line Sprint mode\\\
+ Add in-game menu for changing controls (some people can actually tolerate keyboard guideline)\\\
--]]\\\
\\\
-- if my indenting is fucked, I blame zed (neovim for life)\\\
\\\
local scr_x, scr_y = term.getSize()\\\
\\\
local Board = require \\\"lib.board\\\"\\\
local Mino = require \\\"lib.mino\\\"\\\
local GameInstance = require \\\"lib.gameinstance\\\"\\\
local Control = require \\\"lib.control\\\"\\\
local GameDebug = require \\\"lib.gamedebug\\\"\\\
local Menu = require \\\"lib.menu\\\"\\\
\\\
local DEBUG = GameDebug:New( _PRINT_DEBUG_INFO and GameDebug.FindMonitor(), _PRINT_DEBUG_INFO)\\\
\\\
local clientConfig = require \\\"config.clientconfig\\\" -- client config can be changed however you please\\\
local gameConfig = require \\\"config.gameconfig\\\"     -- ideally, only clients with IDENTICAL game configs should face one another\\\
gameConfig.kickTables = require \\\"lib.kicktables\\\"\\\
\\\
local modem = peripheral.find(\\\"modem\\\")\\\
if (not modem) then\\\
	if ccemux then -- CCEmuX\\\
		ccemux.attach(\\\"top\\\", \\\"wireless_modem\\\")\\\
		modem = peripheral.wrap(\\\"top\\\")\\\
	elseif periphemu then -- CraftOS-PC\\\
		periphemu.create(\\\"top\\\", \\\"modem\\\")\\\
		modem = peripheral.wrap(\\\"top\\\")\\\
	end\\\
end\\\
\\\
if modem then\\\
	modem.open(100)\\\
else\\\
	--error(\\\"no modem???\\\")\\\
end\\\
\\\
--local dfpwm = require \\\"cc.audio.dfpwm\\\"\\\
\\\
local resume_count = 0\\\
\\\
local speaker = peripheral.find(\\\"speaker\\\")\\\
if (not speaker) and periphemu then\\\
	periphemu.create(\\\"speaker\\\", \\\"speaker\\\")\\\
	speaker = peripheral.wrap(\\\"speaker\\\")\\\
end\\\
\\\
-- note block pitches for playing bad sound effects\\\
-- index 1 is delay duration, the rest represent pitch\\\
local sound_timers = {}\\\
local sound_data = {\\\
	mino_Z = { 0.1, 15, 6, 9 },\\\
	mino_T = { 0.1, 8, 10, 12 },\\\
	mino_S = { 0.05, 17, 12, 15, 10, 12, 19 },\\\
	mino_O = { 0.05, 17, 12, 10, 9, 5, 3 },\\\
	mino_L = { 0.1, 7, 5 },\\\
	mino_J = { 0.05, 5, 7, 11, 10, 13, 12, 13, 13, 15, 19 },\\\
	mino_I = { 0.05, 19, 14, 11, 7, 9, 11, 14, 19 },\\\
	lineclear = { 0.05, 24, 19, 16, 12, 12, 16, 19, 24 }\\\
}\\\
\\\
local function playNote(note)\\\
	if speaker then\\\
		speaker.playNote(\\\"guitar\\\", 1, note)\\\
	end\\\
end\\\
\\\
local function queueSound(name)\\\
	if not gameConfig.enable_sound then\\\
		return\\\
	end\\\
\\\
	if gameConfig.enable_noteblocksound then\\\
		if sound_data[name] then\\\
			for i = 2, #sound_data[name] do\\\
				sound_timers[os.startTimer((i - 2) * sound_data[name][1])] = sound_data[name][i]\\\
			end\\\
		end\\\
\\\
	elseif speaker then\\\
		speaker.playLocalMusic(fs.combine(shell.dir(), \\\"sound/\\\" .. name .. \\\".ogg\\\"), 0.15)\\\
	end\\\
end\\\
\\\
local function write_debug_stuff(game)\\\
	if game.control.native_control then\\\
		local mino = game.state.mino\\\
		DEBUG:LogHeader(\\\"Combo=\\\", game.state.combo, 2)\\\
		DEBUG:LogHeader(\\\"TimeToLock=\\\", tostring(mino.lockTimer):sub(1, 4), 5)\\\
		DEBUG:LogHeader(\\\"MovesLeft=\\\", mino.movesLeft, 3)\\\
		DEBUG:LogHeader(\\\"Pos=\\\", \\\"(\\\" .. mino.x .. \\\":\\\" .. tostring(mino.xFloat):sub(1, 5) .. \\\", \\\" .. mino.y .. \\\":\\\" .. tostring(mino.yFloat):sub(1, 5) .. \\\")\\\", 16)\\\
	end\\\
end\\\
\\\
local function move_games(GAMES)\\\
	local game_size = { GAMES[1].width + 2, GAMES[1].height }\\\
	for i = 1, #GAMES do\\\
		GAMES[i]:Move(\\\
			(scr_x / 2) - ((#GAMES * game_size[1]) / 2) + (game_size[1] * (i - 1)),\\\
			(scr_y / 4) - ((game_size[2] - 5) / 2) + 1\\\
		)\\\
	end\\\
end\\\
\\\
local function cwrite(text, y, color)\\\
	local cx, cy = term.getCursorPos()\\\
	local sx, sy = term.getSize()\\\
	local og_color = term.getTextColor()\\\
	if color then\\\
		term.setTextColor(color)\\\
	end\\\
	term.setCursorPos(math.ceil(sx / 2 - #text / 2), y or (sy / 2))\\\
	term.write(text)\\\
	term.setTextColor(color)\\\
end\\\
\\\
local function WIPscreen(...)\\\
	local evt = {}\\\
	local messages = {...}\\\
	term.clear()\\\
	for i = 1, #messages do\\\
		cwrite(messages[i], 2 + i, colors.white)\\\
		sleep(0.1)\\\
	end\\\
	sleep(0.15)\\\
	cwrite(\\\"Press any key to continue\\\", 5 + #messages, colors.lightGray)\\\
	repeat\\\
		evt = {os.pullEvent()}\\\
	until evt[1] == \\\"key\\\" or evt[1] == \\\"mouse_click\\\"\\\
	sleep(0.1)\\\
	term.clear()\\\
end\\\
\\\
local function startGame(mode_name, is_networked)\\\
\\\
	DEBUG:Log(\\\"Starting game \\\\\\\"\\\" .. mode_name .. \\\"\\\\\\\", is_networked = \\\" .. tostring(is_networked))\\\
	term.clear()\\\
\\\
	local tickTimer = os.startTimer(gameConfig.tickDelay)\\\
	local message, doTick, doResume\\\
\\\
	local frame_time\\\
	local last_epoch = os.epoch()\\\
\\\
	local GAMES = {}\\\
	for i = 1, _AMOUNT_OF_GAMES do\\\
		table.insert(GAMES, GameInstance:New(Control:New(clientConfig, false), 0, 0, clientConfig):Initiate(gameConfig.minos, last_epoch))\\\
		GAMES[i]:AttachDebug(DEBUG)\\\
		if i > 1 then\\\
			GAMES[i].networked = true\\\
			GAMES[i].do_render_tiny = true\\\
			GAMES[i].do_compact_view = true\\\
			GAMES[i].visible = false\\\
		end\\\
		if mode_name == \\\"marathon_tiny\\\" then\\\
			GAMES[i].do_render_tiny = true\\\
		end\\\
	end\\\
	local player_number = math.max(1, math.floor(#GAMES / 2))\\\
\\\
\\\
	-- center boards on screen\\\
	move_games(GAMES)\\\
\\\
	for i, _GAME in ipairs(GAMES) do\\\
		_GAME.control:Clear()\\\
		_GAME.control.native_control = (i == player_number)\\\
	end\\\
	\\\
	local is_game_running = true\\\
\\\
	while is_game_running do\\\
		doResume = true\\\
		evt = { os.pullEvent() }\\\
\\\
		if evt[1] == \\\"modem_message\\\" and is_networked then\\\
			if type(evt[5]) == \\\"string\\\" then\\\
				if evt[5]:sub(1, 6) == \\\"ldris2\\\" then\\\
					evt = {\\\"network_moment\\\", evt[5]}\\\
				end\\\
			end\\\
		end\\\
\\\
		DEBUG:LogHeader(\\\"t=\\\", resume_count, 6)\\\
		DEBUG:LogHeader(\\\"evt[1]=\\\", evt[1], 20, true)\\\
		DEBUG:LogHeader(\\\"evt[2]=\\\", evt[2], 20, true)\\\
		write_debug_stuff(GAMES[player_number])\\\
\\\
		last_epoch = os.epoch(\\\"utc\\\")\\\
\\\
		if evt[1] == \\\"term_resize\\\" then\\\
			scr_x, scr_y = term.getSize()\\\
			term.clear()\\\
			move_games(GAMES)\\\
		end\\\
\\\
		if evt[1] == \\\"timer\\\" then\\\
			if evt[2] == tickTimer then\\\
				doTick = true\\\
				tickTimer = os.startTimer(gameConfig.tickDelay)\\\
			else\\\
				doTick = false\\\
\\\
				if sound_timers[evt[2]] then\\\
					doResume = false\\\
					playNote(sound_timers[evt[2]])\\\
					sound_timers[evt[2]] = nil\\\
				end\\\
			end\\\
\\\
		end\\\
\\\
		if evt[1] == \\\"key\\\" and evt[2] == keys.tab then\\\
			--[[\\\
			player_number = (player_number % #GAMES) + 1\\\
			for i, _GAME in ipairs(GAMES) do\\\
				_GAME.control:Clear()\\\
				_GAME.control.native_control = (i == player_number)\\\
			end\\\
			--]]\\\
		end\\\
\\\
		-- it's wasteful to resume during key repeat events\\\
		if (evt[1] == \\\"key\\\" and evt[3]) then\\\
			doResume = false\\\
		end\\\
\\\
		-- run games\\\
		if doResume then -- do not resume on key repeat events!\\\
			resume_count = resume_count + 1\\\
			for i, GAME in ipairs(GAMES) do\\\
				message = GAME:Resume(evt, doTick) or {}\\\
\\\
				-- restart game after topout\\\
				if message.gameover then\\\
					GAME:Initiate(nil, last_epoch)\\\
				end\\\
\\\
				-- quit game\\\
				if message.quit then\\\
					is_game_running = false\\\
				end\\\
\\\
\\\
				-- queue timers for speaker notes\\\
				if message.sound then\\\
					queueSound(message.sound)\\\
				end\\\
\\\
				-- deal garbage attacks to other game instances\\\
				if message.attack then\\\
					for _i, _GAME in ipairs(GAMES) do\\\
						if _i ~= i then _GAME:ReceiveGarbage(message.attack) end\\\
					end\\\
				end\\\
\\\
				-- send network packets\\\
				if message.packet and modem and is_networked then\\\
					for ii, packet in ipairs(message.packet) do\\\
						modem.transmit(100, 100, packet)\\\
					end\\\
				end\\\
			end\\\
\\\
			frame_time = os.epoch(\\\"utc\\\") - last_epoch\\\
			DEBUG:LogHeader(\\\"ft=\\\", tostring(frame_time) .. \\\"ms\\\")\\\
			\\\
		end\\\
\\\
		if frame_time > 100 and collectgarbage then\\\
			collectgarbage(\\\"collect\\\")\\\
		end\\\
		\\\
		DEBUG:Render(true)\\\
	end\\\
	\\\
	DEBUG:Log(\\\"Game stopped.\\\")\\\
end\\\
\\\
local function titleScreen()\\\
	term.clear()\\\
	local control = Control:New(clientConfig, true)\\\
\\\
	local mainmenu = Menu:New(2, 2)\\\
	mainmenu:SetTitle(\\\"LDRIS 2\\\", 1)\\\
	mainmenu:AddOptions({\\\
		{\\\"Marathon\\\", \\\"marathon\\\", 1, 3},\\\
		{\\\"Marathon (Tiny)\\\", \\\"marathon_tiny\\\", 1, 4},\\\
		{\\\"Multiplayer (Modem)\\\", \\\"mp_modem\\\", 1, 5},\\\
		{\\\"Modes\\\", \\\"mode_menu\\\", 1, 6},\\\
		{\\\"Options\\\", \\\"options_menu\\\", 1, 7},\\\
		{\\\"Quit\\\", \\\"quit_game\\\", 1, 9}\\\
	})\\\
	mainmenu.selected = 1\\\
	mainmenu.cursor = {\\\"O \\\", \\\"@ \\\"}\\\
	mainmenu.cursor_blink = 0.05\\\
\\\
	local modemenu = Menu:New(24, 2)\\\
	modemenu:SetTitle(\\\"\\\", 1)\\\
	modemenu:AddOption(\\\"Cheese Race\\\", \\\"cheese_race\\\", 1, 3)	-- infinite garbage of a particular height\\\
	modemenu:AddOption(\\\"40-line Sprint\\\", \\\"sprint\\\", 1, 4)\\\
	modemenu:AddOption(\\\"Some other shit idk\\\", \\\"othershit\\\", 1, 5)\\\
	modemenu:AddOption(\\\"Return\\\", \\\"main_menu\\\", 1, 7)\\\
	modemenu.cursor = {\\\"O \\\", \\\"@ \\\"}\\\
	modemenu.cursor_blink = 0.05\\\
	\\\
	local optionmenu = Menu:New(2, 2)\\\
	optionmenu:SetTitle(\\\"Options\\\")\\\
	optionmenu:AddOptions({\\\
		{\\\"\\\", \\\"\\\", 1, 3}\\\
	})\\\
	\\\
	-- size consideration for pocket computers\\\
	if scr_x < 45 then\\\
		modemenu:Move(2, 11)\\\
		modemenu:SetTitle(\\\"MODES:\\\", 1)\\\
	end\\\
\\\
	local evt\\\
	local tickTimer = os.startTimer(mainmenu.cursor_blink)\\\
	local doRenderMenu = true\\\
	local sel\\\
\\\
	local MENU = mainmenu\\\
	local force_select = false\\\
	local force_return = false\\\
\\\
	while true do\\\
		if doRenderMenu then\\\
			MENU:Render()\\\
			doRenderMenu = false\\\
		end\\\
		for k, v in pairs(control.keysDown) do\\\
			control.keysDown[k] = 1 + v\\\
		end\\\
		evt = {os.pullEvent()}\\\
\\\
		control:Resume(evt)\\\
\\\
		if evt[1] == \\\"timer\\\" and evt[2] == tickTimer then\\\
			tickTimer = os.startTimer(MENU.cursor_blink)\\\
			MENU:CycleCursor()\\\
			doRenderMenu = true\\\
			\\\
		elseif evt[1] == \\\"term_resize\\\" then\\\
			term.setCursorPos(MENU.x, MENU.y)\\\
			term.clearLine()\\\
			doRenderMenu = true\\\
			\\\
		elseif evt[1] == \\\"mouse_click\\\" and evt[2] < 3 then\\\
			local sel_try = MENU:MouseSelect(evt[3], evt[4])\\\
			if sel_try then\\\
				if sel_try == MENU.selected or evt[2] == 2 then\\\
					force_select = true\\\
				end\\\
			elseif evt[2] == 2 then\\\
				force_return = true\\\
			end\\\
			MENU.selected = sel_try or MENU.selected\\\
			doRenderMenu = true\\\
		end\\\
\\\
		if control:CheckControl(\\\"menu_up\\\") then\\\
			MENU:MoveSelect(-1)\\\
			doRenderMenu = true\\\
\\\
		elseif control:CheckControl(\\\"menu_down\\\") then\\\
			MENU:MoveSelect(1)\\\
			doRenderMenu = true\\\
\\\
		elseif control:CheckControl(\\\"menu_select\\\") or force_select or force_return then\\\
			sel = force_return and \\\"\\\" or MENU:GetSelected()\\\
			do\\\
				if sel == \\\"marathon\\\" then\\\
					_AMOUNT_OF_GAMES = 1\\\
					startGame(sel, false)\\\
					term.clear()\\\
				\\\
				elseif sel == \\\"marathon_tiny\\\" then\\\
					_AMOUNT_OF_GAMES = 1\\\
					startGame(sel, false)\\\
					term.clear()\\\
\\\
				elseif sel == \\\"mp_modem\\\" then\\\
					_AMOUNT_OF_GAMES = 2\\\
					--WIPscreen(\\\"Multiplayer will be\\\", \\\"implemented later!\\\")\\\
					startGame(sel, true)\\\
					term.clear()\\\
\\\
				elseif sel == \\\"mode_menu\\\" then\\\
					MENU:Render(true)\\\
					MENU = modemenu\\\
					MENU.selected = 1\\\
\\\
				elseif sel == \\\"main_menu\\\" or force_return then\\\
					MENU = mainmenu\\\
					term.clear()\\\
\\\
				elseif sel == \\\"options_menu\\\" then\\\
					WIPscreen(\\\"Options will be\\\", \\\"added later!\\\",\\\"\\\",\\\"\\\",\\\"...Really!\\\")\\\
\\\
				elseif sel == \\\"quit_game\\\" then\\\
					return\\\
				end\\\
			end\\\
\\\
			do\\\
				if sel == \\\"cheese_race\\\" then\\\
					WIPscreen(\\\"Cheese race will be\\\", \\\"added later!\\\")\\\
					mainmenu:Render(true)\\\
\\\
				elseif sel == \\\"sprint\\\" then\\\
					WIPscreen(\\\"Sprint mode will be\\\", \\\"added later!\\\")\\\
					mainmenu:Render(true)\\\
\\\
				elseif sel == \\\"othershit\\\" then\\\
					WIPscreen(\\\"Other modes will be\\\", \\\"added later!\\\")\\\
					mainmenu:Render(true)\\\
				end\\\
			end\\\
\\\
			tickTimer = os.startTimer(MENU.cursor_blink)\\\
			doRenderMenu = true\\\
\\\
		elseif control:CheckControl(\\\"quit\\\") then\\\
			return\\\
		end\\\
		\\\
		force_select = false\\\
		force_return = false\\\
	end\\\
end\\\
\\\
term.clear()\\\
\\\
DEBUG:Log(\\\"Opened LDRIS2.\\\")\\\
\\\
\\\
local original_palette = {}\\\
local original_randomseed = {math.randomseed()}\\\
for i = 0, 15 do\\\
	original_palette[i + 1] = { term.getPaletteColor(2 ^ i) }\\\
end\\\
term.setPaletteColor(colors.gray, 0.15, 0.15, 0.15)\\\
term.setPaletteColor(colors.brown, 0.25, 0.25, 0.25)\\\
\\\
local runtime, success, err_message\\\
while true do\\\
	runtime, success, err_message = GameDebug.Profile(pcall, titleScreen)\\\
	if success then\\\
		break\\\
	else\\\
		printError(err_message)\\\
		term.setCursorPos(1, scr_y)\\\
		term.setBackgroundColor(colors.black)\\\
		term.setTextColor(colors.white)\\\
		print(\\\"Failed in \\\" .. tostring(runtime) .. \\\"ms\\\")\\\
		\\\
		-- justification: if it fails instantly, re-running again will lock the system and be bad\\\
		-- but if it fails due to some user action, restarting lets us look at the log in the GUI\\\
		if runtime < 1000 then\\\
			print(\\\"Failed within one second! Aborting.\\\")\\\
		else\\\
			write(\\\"Restarting in \\\")\\\
			for i = 5, 1, -1 do\\\
				write(i .. (i == 1 and \\\"...\\\" or \\\", \\\"))\\\
				sleep(1)\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
for i = 1, 16 do\\\
	term.setPaletteColor(2 ^ (i - 1), table.unpack(original_palette[i]))\\\
end\\\
math.randomseed(table.unpack(original_randomseed))\\\
\\\
\\\
DEBUG:Log(\\\"Closed LDRIS2.\\\")\\\
\\\
term.setCursorPos(1, scr_y - 1)\\\
term.clearLine()\\\
term.setTextColor(colors.yellow)\\\
print(\\\"Thank you for playing!\\\")\\\
term.setCursorPos(1, scr_y - 0)\\\
term.clearLine()\\\
term.setTextColor(colors.white)\\\
\\\
sleep(0.05)\\\
\",\
    [ \"sound/mino_I.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000/Y\\000\\000\\000\\000\\000\\0008�vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000/Y\\000\\000\\000\\000\\000��rD�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�����˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ�,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000r\\\"\\000\\000\\000\\000\\000\\000/Y\\000\\000\\000\\000\\000�v�}]R`^d]_Yb]O?BAC>88B�V��/O����U\\000@	������m�\\\\�̒Le�L������QPj��<�\\\"uٛ\\000�������_l�t�^���U�B\\000��a3��Z�5ɦ��Rd~��w@��\\000\\000P��5��ƚH`]�\\000<\\000Ϭ莽3��*o���o�_��}�V�\\000\\000��n3�-\\000\\000؏$\\000^�=޺�|��-��^��5�\\000�	\\000��1\\000��6e\\000����-Ͼݛ��.��\\000\\000���vx\\000>=���\\000�����U\\000\\000t�w�;@�.	\\000�ˋ	��\\000�Nކ\\\
\\000R��tN��j_X���U��\\000p|�e\\000ꀈ�k�Wz7���-5�@�Qm����Y�[H\\000.\\000t��ػUn�\\000�'? ��1P�:w\\rYG�\\000Z�� �7�Ԯ�i=�E/��\\000�M\\000�}\\000\\000�h������g)���*�W���z#�\\000\\000uOm���\\0002l���.�V'\\000�iZ_�K7[\\r@��\\000@c~f�\\\"^�nr%��n�-�o��~�-\\000�x���\\\"@���j�X�w?Rݛ�N\\\"HJ30yB5M�,@�4�~�\\000���\\\
�Ui����s\\000*+u�%}�`�O�b������^T��=�\\000���\\000\\000,@�-hآiNhS�6}�޼�[OV\\000\\000y���y�`P�ˡ^�ð��WS\\000���\\000�����\\000,�_�\\0000�엋\\000V��_��=v��t.�q���� \\0000�\\000sӦ3�<��3U�p[y�\\000�\\000���J�d6t��\\000g��V�������\\\\߲1\\000�szH^��{.�z���3�}�	�\\000ڍ6\\000K�\\\\ˤl=�v�h�u�Uߒ'����������m6Y8H\\000nˀ���a9���Me\\000���\\rh\\000��~\\000>RK�\\000Z�=�柯��sZc>�P�\\rڔ\\0004ê�G����s�ޯaY\\000�ޗ0�s� �2:��\\\
p�b���D\\000\\000�9��0?�at\\000t]��V�:��Lg��\\000Z�5o?�XG�?��w@\\000	.\\000�\\000\\000�\\000k���Uh߀,��͋\\000PiP�L����L_�:�w\\000���!\\000����\\000\\000��Z���\\\\�N<��*�o?\\000\\000�#\\000t�#H\\000J���0��\\0000�q�T��#��\\\"\\000���r\\000x%��:_��}��-�~\\000}�!b�\\000�YEF��u��K�\\000�ڐ�z�(A���r�\\000�\\000f`����\\000j��VX�[u���h2���V&�J�<�o�N�lH\\000�*$\\000@'Le\\\\���r�x\\000K\\r\\000��\\\
\\000��-��['Î�49as�\\\
�L�h�~��LЇ�t\\0008�\\\\\\000@\\000�A�\\000�2t���0\\000�'{�].����UrB�br�b����Ju-���\\000�t]���\\000�\\r�SBr��T��lu�ҹ\\000q��/���P����ko�*`�~5v�)#`�H/�#\\000.A\\000@�~��<7��=|`(�\\000e�m�<���9�޵\\r+�4`�/#<�:yZ�#�Ϳ�\\000$\\000��;�\\r\\000_�[�������\\000E��\\000\\000\\000X�\\000\",\
    [ \"sound/mino_J.dfpwm\" ] = \"���I��w_\\000��^@�U\\000�\\\"m!�)R��vR����J^��V\\000���\\\"�#��	mү\\000����[�*���`��+迒ԟh�@��R+�P���+mE�_U\\000�-�� J��Ru��_��E=��_%���-��Կ�V�/\\000��/�+����`[i���\\000ԟԊ� E�bMzh�oؕ�D��(�*jE�$�o�Z�W\\000���@�Z-����o�\\r�?���J�@���]����l�Ъ)d��E��\\000��P��L������/�RBW��UR���U���� Q?\\000��*�w+��\\\\���*}�_%����B�Ж-d!���@��E�t{�+ж}�� ����d�_I�\\\
����ڃ��җ���_��_Hiѯ=\\000�-��[��E���?ZD��z��\\\"�%�WKmR������Ч�H�U�'@�����@��Z��,���.vPW�_`���@	[�+�_$�W}�K���֊t닪P�'!��\\000G������QU����\\000w���(��Cj�J����jIH�_5r��Z*�����\\r��P��*n-j�?T\\r�>!���/\\000.�\\\
������R��m�E�W�d�V�p��@%h�/�>��޴�H�^�6��V�%���O\\000�����ڢ�R�I��'�;\\000�Zr�/`5� �ZjU_@=�_Z-���\\000.������T�����Z�V��(���jZ��J }+���\\000=U-\\\\�W\\r�/�B�\\000o_D�����H+����@��M�%$�{��J-�W*�^TK��U!����R'z�߭�W�U���]�-�+���H��h�M�^���$���J�	�_QK}P�/�S����nՄ�J�/�DR�+Ԋ�\\000���J�(�����@���l�&�V�p�����`� ��P�D/ ��	t�%]-}W��*Ȫ�+�CA�.�GUU`��ꂪ肪o�\\000���l����\\\
?�� �G����u��/�u���o\\000�qE�)�Q}\\\"P�Mhz�*T�TM}\\000�._H�|/�._���_�fO�|�+oQ����UUe������uI�#�\\\"t�*�_�-z���~@{	Z�%��C��.�/�K���%�҃f�Buw�&н�j5P��l�~U�+�4X])=�\\\
�|o^���\\\
菕�C'�W�oE��nA�B��%�r�r-�{H[�m�z�R[�������g?��~�Z�����h�@[��q��<��R�Oq�׵������ց}�e[��pK�2x��~W�_�sR�p���u:d�=�|Y�)�\\000�r,�]�~S�z�TE^��|�'�o�{�����[@o���\\\
��*�O�l�A�b� ����j���|�=dm�\\\\�nI?�E�\\\\E�T+�/pGO�����ڭ�U5�{)��;x�z�65��X��z��I�.��JUK��B���П���j�C_�k������p��q\\\
����j\\000��Z�PU��Z-܅/�tۮ�ע?\\000��zg����.���Є�R~�,���,T��T�?)%}�.-�/���+�A�w�I�A�u+@��*��|U}!-�-X�z�/	��v��j�����?�V��ߋ ���]%���U�@��@'�J�\\000�m%Rm���.���?`�����&�.-����?\\000ۭ�^����\\0007UԿ\\000�o�W+�J}-�Ҿ�@��\\\
-P�_@*��TWh��*�CBR�_\\000�'�/$�UpI�J�T�/x#]�\\000�W�}\\000�?x�l�B��/�����/�m�_�d_������ �?����Bw�o��:�J�D+%�?���nK�/\\000�u��$�f/�������O	�ED?��U!���]�/��-�\\000�K-�\\000�o�ZI�^-��^ж�VD����������^U�-�� �Kp�\\\"}M�����7�E���|��(�����R�i��4>�%z��:p�����_�PK�\\rN�!��A?���H�G�������\\\
��D��C-�Q����dy�r���x���]��*��X�R��>�W+8�x*�?`Od��J��J��:����o��k�O����B��	u��=�@?T�R_�|ER}<�?���:���2J��\\\
.��F~�UnCѫ�C��Ӣ�Q�������>T,�\\\"|�:�4-x�*��ZY>@O+ޣ�w������3������������t�Z<�=�+|Y�	������C��^#���Jtš��}A�|�r)�Z��7�|*��|��K>���]5��4ΩE�O5�C����ċJq�j��z�5��~��-6�+�*XU�P=���W���%]r�h�Sx��vwt��j���V�(���=�Х��X��*�jԃ^8��'�������P��8ű��O�W�:8u��O��|l�Ӄ+�\\\
>T����+�G��xj�)�G��>U�p�BU����~�r�G�+\\r^9�H��U\\rzVz���Ղ��T�5��âW.�|��`Ճ��^�^�|pu���GTV\\rx5���C�W�>_X��b���MxV�T����\\\
�~X�`��g�����R�Q�+O<U|�t�AW��>X-�հ����n�z��Aׂ�J�.�R�iţ�G����kσ�������e����a�k���t�tx�|Z�>J>�Z�����ׂ�҇����Q�ct�p1�T:�:�,<-T^O����Wŧ������S�zp*|j|�:l��V��OŇՅ������d���zhU��(=����K�����������up5��|X:�<->�N�������S������j���|�:x�<=Z��K������ԡ�AU�Jy�i�6<\\\\\\\\K~�G�Z�V���xx��?���A���p�>|(��n��y\\\\�������t��^���U)�~`+�N�k	}h��*����)��r�y���:z�.JU�Oi8��>UޢË�z�(+\\rn���Z��)��z������R�.�R���u�rYZ,�RǕ�z�Z�ʇ����*�:���/���e}L�+����2���<�ۃ���<�\\\\#_�i��xZx/I��WQz��V\\r�փ˰�0�6N�B��c|`�*���CV��=�>�TC��b�h~Wʣq��\\\\.ۅG�u��C|.\\\\��Ewp�-j��ǎ���jQ�>�\\\
�Wya�\\\":\\\\K��`�r�=T]Ŋ���=*=�G����Q=v�Oū���x|TKǂ_�Ҩjx�k�Gnau`O<�\\r��Tq��Z�T��\\\"�p�=�>Ѝ��e���N<��'��a���'�/�qhY<�NÆO�i�Q=\\r��K��up#�u��B{t�Z,<�E�C���T%����+}�z�+��鋥��x!/U�VU5Ԓ�O���b�=�5�#}����>���G���<pσ���|\\\\ܒ?���+x��OA��gz<����A��~8������j|`�&���#�p�5	����G�hhY?���S����^�{�'�y���^�\\\\ʁO�wp�V|��ǡnp��|�Cgzᬠ]����p�x��.e����Ќ>*/���jU�Q][���W��>��KC���hi^%�ã��j�n�����t��-��҃˒z�d-Ur�æU|hV^䣡�Z\\\\�\\\\Z���'�xd�?U��c��r��u��Jy��[�j�y9z�S�T/�u0w�ҡ�F��)�P�ᒋ��C=�\\\\���E���v|Tx)��)��n.\\\\U�Zࢇ+]�\\\
}�bуK��^D�����҂�\\\
�\\r.i�����¢J=5��tа�`+��^�(x�lH��]._/EMK'K���U��E���pS�h��4y��~�|.�_H�C���v�k�W�A�p��2|�<�*t���B����.�/Ņ�����yQUp���h9t�L�>EK��k���C��j���Q{�d�49Z<�,\\\\\\r6�����ą%C����C�pi�\\\"�R|�-�^j�V\\r��V���U�G��V���P��X�T:4/�����&+������ԡOQ_��%�5�Q��|���^f��X<�W/�Ó��T5����B�xp)�^:O��pte�\\r��ʧ[���X]�J��ߒ�kYN���4��vH>Z��'�dѬt�0G���S�mxH�����-���������:pj�J�^F��U58z�����CSR�x�������z��T��x�e�=ht��z���*�h�Ak:t��K���Q�4�0-7�S�+U�8>���B/��h����#]���.=X��j��A�8z:�V���=�<��E��T9X�Ȏ�.��q�xt�//T��y�Z��䥅�-�T|.�a���ttt��\\\
���-�|������3U�`\\r�+��%]p�����\\\
|4Z�ӂ�}��������xX|�.��ʁ��z8Z\\r.zţ��:�����ӣI��,�+���^pt:�����Tذ��+�FzJ�QFsЫ�5�pA����Q�<U�W����Txڧ}�qȵ\\\\h������0\\\\\\\\����QV~��GG�biU^$��Ǣ�ېr:6M�C�F<��,nX�ky̢����I{Y�0�K��K�Zp�S.�Z��EW��H\\\\|���W`㰵<l��Kn�t�z\\\\V�����b/�\\\\T�G����RY(��������*�tP��/�qa�<�\\\\�\\\
��⨣x�t����ҁ�:�8�.\\r���Nt\\\\tJ�Fꡣ5iz�G.��C�SZ��[JU�ŴE��T��WҪRY�����J���貪,M�JKKӲd�4���JUM�Ҳ�2-5MU�*�RժT�T-S�J���RU�4�R�R�,�J�*����R�4�J�J\",\
    [ \"lib/mino.lua\" ] = \"-- makes a Mino, a tetris piece that can be writted to and rendered on a Board\\r\\\
-- TODO: precalculate all rotated minos so that I don't have to recalculate their rotated state every time\\r\\\
local Mino = {}\\r\\\
\\r\\\
local gameConfig = require \\\"config.gameconfig\\\"\\r\\\
\\r\\\
-- recursively copies the contents of a table\\r\\\
table.copy = function(tbl)\\r\\\
	local output = {}\\r\\\
	for k, v in pairs(tbl) do\\r\\\
		output[k] = (type(v) == \\\"table\\\" and k ~= v) and table.copy(v) or v\\r\\\
	end\\r\\\
	return output\\r\\\
end\\r\\\
\\r\\\
local mathfloor = math.floor\\r\\\
\\r\\\
function Mino:New(mino_table, minoID, board, xPos, yPos, oldeMino)\\r\\\
	local mino = setmetatable(oldeMino or {}, self)\\r\\\
	self.__index = self\\r\\\
\\r\\\
	mino_table = mino_table or gameConfig.minos\\r\\\
	if not mino_table[minoID] then\\r\\\
		error(\\\"tried to spawn mino with invalid ID '\\\" .. tostring(minoID) .. \\\"'\\\")\\r\\\
	else\\r\\\
		mino.shape = mino_table[minoID].shape\\r\\\
		mino.spinID = mino_table[minoID].spinID\\r\\\
		mino.kickID = mino_table[minoID].kickID\\r\\\
		mino.color = mino_table[minoID].color\\r\\\
		mino.name = mino_table[minoID].name\\r\\\
	end\\r\\\
\\r\\\
	mino.mino_table = mino_table\\r\\\
	mino.finished = false\\r\\\
	mino.active = true\\r\\\
	mino.spawnTimer = 0\\r\\\
	mino.visible = true\\r\\\
	mino.height = #mino.shape\\r\\\
	mino.width = #mino.shape[1]\\r\\\
	mino.minoID = minoID\\r\\\
	mino.x = xPos\\r\\\
	mino.y = yPos\\r\\\
	mino.xFloat = 0\\r\\\
	mino.yFloat = 0\\r\\\
	mino.board = board\\r\\\
	mino.rotation = 0\\r\\\
	mino.resting = false\\r\\\
	mino.lockTimer = gameConfig.lock_delay\\r\\\
	mino.movesLeft = gameConfig.lock_move_limit\\r\\\
	mino.yHighest = mino.y\\r\\\
	mino.doWriteColor = false\\r\\\
\\r\\\
	return mino\\r\\\
end\\r\\\
\\r\\\
function Mino:Serialize(doIncludeInit)\\r\\\
	return textutils.serialize({\\r\\\
		minoID = doIncludeInit and self.minoID or nil,\\r\\\
		rotation = self.rotation,\\r\\\
		x = x,\\r\\\
		y = y,\\r\\\
	})\\r\\\
end\\r\\\
\\r\\\
-- takes absolute position (x, y) on board, and returns true if it exists within the bounds of the board\\r\\\
function Mino:DoesSpotExist(x, y)\\r\\\
	return self.board and (\\r\\\
		x >= 1 and\\r\\\
		x <= self.board.width and\\r\\\
		y >= 1 and\\r\\\
		y <= self.board.height\\r\\\
	)\\r\\\
end\\r\\\
\\r\\\
-- checks if the mino is colliding with solid objects on its board, shifted by xMod and/or yMod (default 0)\\r\\\
-- if doNotCountBorder == true, the border of the board won't be considered as solid\\r\\\
-- returns true if it IS colliding, and false if it is not\\r\\\
function Mino:CheckCollision(xMod, yMod, doNotCountBorder, round)\\r\\\
	local cx, cy -- represents position on board\\r\\\
	round = round or mathfloor\\r\\\
	for y = 1, self.height do\\r\\\
		for x = 1, self.width do\\r\\\
			cx = round(-1 + x + self.x + xMod)\\r\\\
			cy = round(-1 + y + self.y + yMod)\\r\\\
\\r\\\
			if self:DoesSpotExist(cx, cy) then\\r\\\
				if (\\r\\\
					self.board:IsSolid(cx, cy) and\\r\\\
					self:CheckSolid(x, y)\\r\\\
				) then\\r\\\
					return true\\r\\\
				end\\r\\\
\\r\\\
			elseif (not doNotCountBorder) and self:CheckSolid(x, y) then\\r\\\
				return true\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
	return false\\r\\\
end\\r\\\
\\r\\\
-- checks whether or not the (x, y) position of the mino's shape is solid\\r\\\
-- returns success, and optionally a hex color\\r\\\
function Mino:CheckSolid(x, y, relativeToBoard)\\r\\\
	--print(x, y, relativeToBoard)\\r\\\
	if relativeToBoard then\\r\\\
		x = x - self.x + 1\\r\\\
		y = y - self.y + 1\\r\\\
	end\\r\\\
	x = mathfloor(x)\\r\\\
	y = mathfloor(y)\\r\\\
	if y >= 1 and y <= #self.shape then\\r\\\
		if x >= 1 and x <= #self.shape[y] then\\r\\\
			return (self.shape[y] or \\\"\\\"):sub(x, x) ~= \\\" \\\",\\r\\\
			self.doWriteColor and self.color or self.shape[y]:sub(x, x)\\r\\\
		end\\r\\\
	end\\r\\\
	\\r\\\
	return false\\r\\\
end\\r\\\
\\r\\\
function Mino:Shade(sMatch, sRepl)\\r\\\
	assert(#sMatch == #sRepl, \\\"both arguments must be same length\\\")\\r\\\
	for i, line in ipairs(self.shape) do\\r\\\
		self.shape[i] = line:gsub(sMatch, sRepl)\\r\\\
	end\\r\\\
	return self\\r\\\
end\\r\\\
\\r\\\
-- direction = 1: clockwise\\r\\\
-- direction = -1: counter-clockwise\\r\\\
-- mino.rotation ranges from 0-3\\r\\\
function Mino:Rotate(direction, expendLockMove)\\r\\\
	local oldShape = table.copy(self.shape)\\r\\\
	local kickTable = gameConfig.kickTables[gameConfig.currentKickTable]\\r\\\
	local output = {}\\r\\\
	local success = false\\r\\\
	local kick_count = 0\\r\\\
	local newRotation = (self.rotation + direction) % 4\\r\\\
\\r\\\
	if self.active then\\r\\\
		-- get the specific offset table for the type of rotation based on the mino type\\r\\\
		local kickX, kickY\\r\\\
		local kickRot = self.rotation .. newRotation\\r\\\
\\r\\\
		-- translate the mino piece\\r\\\
		for y = 1, self.width do\\r\\\
			output[y] = \\\"\\\"\\r\\\
			for x = 1, self.height do\\r\\\
				if direction == -1 then\\r\\\
					output[y] = output[y] .. oldShape[x]:sub(-y, -y)\\r\\\
				elseif direction == 1 then\\r\\\
					output[y] = oldShape[x]:sub(y, y) .. output[y]\\r\\\
				elseif direction == 2 then\\r\\\
					output[y] = oldShape[self.height - y + 1]:sub(x, x) .. output[y]\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
		\\r\\\
		if direction % 2 == 1 then\\r\\\
			self.width, self.height = self.height, self.width\\r\\\
		end\\r\\\
		self.shape = output\\r\\\
		-- it's time to do some floor and wall kicking\\r\\\
		if self.board and self:CheckCollision(0, 0) then\\r\\\
			for i = 1, #kickTable[self.kickID][kickRot] do\\r\\\
				kickX = kickTable[self.kickID][kickRot][i][1]\\r\\\
				kickY = -kickTable[self.kickID][kickRot][i][2]\\r\\\
				if not self:Move(kickX, kickY, false) then\\r\\\
					success = true\\r\\\
					kick_count = i\\r\\\
					break\\r\\\
				end\\r\\\
			end\\r\\\
		else\\r\\\
			success = true\\r\\\
		end\\r\\\
		\\r\\\
		if success then\\r\\\
			self.rotation = newRotation\\r\\\
		else\\r\\\
			self.shape = oldShape\\r\\\
			if direction % 2 == 1 then\\r\\\
				self.width, self.height = self.height, self.width\\r\\\
			end\\r\\\
		end\\r\\\
\\r\\\
		if expendLockMove and not self.mino_table[self.minoID].noDelayLock then\\r\\\
			self.movesLeft = self.movesLeft - 1\\r\\\
			if self.movesLeft <= 0 then\\r\\\
				if self:CheckCollision(0, 1) then\\r\\\
					self.finished = 1\\r\\\
				end\\r\\\
			else\\r\\\
				self.lockTimer = gameConfig.lock_delay\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	-- round xFloat/yFloat values\\r\\\
	self.xFloat = math.floor(self.xFloat * 100) * 0.01\\r\\\
	self.yFloat = math.floor(self.yFloat * 100) * 0.01\\r\\\
\\r\\\
	return self, success, kick_count\\r\\\
end\\r\\\
\\r\\\
-- same as Mino:Rotate, but uses lookup tables to be faster\\r\\\
function Mino:RotateLookup(direction, expendLockMove, mino_rotable)\\r\\\
	local kickTable = gameConfig.kickTables[gameConfig.currentKickTable]\\r\\\
	local success = false\\r\\\
	local kick_count = 0\\r\\\
	local old_rotation = self.rotation\\r\\\
	local newRotation = (self.rotation + direction) % 4\\r\\\
	local kickRot = self.rotation .. newRotation\\r\\\
	\\r\\\
	self.shape = mino_rotable[self.minoID][newRotation + 1]\\r\\\
	if direction % 2 == 1 then\\r\\\
		self.width, self.height = self.height, self.width\\r\\\
	end\\r\\\
	\\r\\\
	-- it's time to do some floor and wall kicking\\r\\\
	if self.board and self:CheckCollision(0, 0) then\\r\\\
		for i = 1, #kickTable[self.kickID][kickRot] do\\r\\\
			kickX = kickTable[self.kickID][kickRot][i][1]\\r\\\
			kickY = -kickTable[self.kickID][kickRot][i][2]\\r\\\
			if not self:Move(kickX, kickY, false) then\\r\\\
				success = true\\r\\\
				kick_count = i\\r\\\
				break\\r\\\
			end\\r\\\
		end\\r\\\
	else\\r\\\
		success = true\\r\\\
	end\\r\\\
	\\r\\\
	if success then\\r\\\
		self.rotation = newRotation\\r\\\
	else\\r\\\
		self.shape = mino_rotable[self.minoID][old_rotation + 1]\\r\\\
		if direction % 2 == 1 then\\r\\\
			self.width, self.height = self.height, self.width\\r\\\
		end\\r\\\
	end\\r\\\
	\\r\\\
	if expendLockMove and not self.mino_table[self.minoID].noDelayLock then\\r\\\
		self.movesLeft = self.movesLeft - 1\\r\\\
		if self.movesLeft <= 0 then\\r\\\
			if self:CheckCollision(0, 1) then\\r\\\
				self.finished = 1\\r\\\
			end\\r\\\
		else\\r\\\
			self.lockTimer = gameConfig.lock_delay\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
-- rotates via lookup table without considering wall kicks or position\\r\\\
-- this is used in network mode where the position and rotation of a mino is already \\\"validated\\\"\\r\\\
-- direction is absolute, not relative\\r\\\
function Mino:ForceRotateLookup(abs_direction, mino_rotable)\\r\\\
	self.shape = mino_rotable[self.minoID][1 + (abs_direction % 4)]\\r\\\
	if (self.rotation - abs_direction) % 2 == 1 then\\r\\\
		self.width, self.height = self.height, self.width\\r\\\
	end\\r\\\
	self.rotation = abs_direction\\r\\\
end\\r\\\
\\r\\\
-- if doSlam == true, moves as far as it can before terminating\\r\\\
function Mino:Move(x, y, doSlam, expendLockMove)\\r\\\
	local didSlam\\r\\\
	local didCollide = false\\r\\\
	local didMoveX = true\\r\\\
	local didMoveY = true\\r\\\
	local step, round\\r\\\
\\r\\\
	if self.active then\\r\\\
		if doSlam then\\r\\\
			self.xFloat = self.xFloat + x\\r\\\
			self.yFloat = self.yFloat + y\\r\\\
\\r\\\
			-- handle Y position\\r\\\
			if y ~= 0 then\\r\\\
				step = y / math.abs(y)\\r\\\
				round = self.yFloat > 0 and mathfloor or math.ceil\\r\\\
				if self:CheckCollision(0, step) then\\r\\\
					self.yFloat = 0\\r\\\
					didMoveY = false\\r\\\
				else\\r\\\
					for iy = step, round(self.yFloat), step do\\r\\\
						if self:CheckCollision(0, step) then\\r\\\
							didCollide = true\\r\\\
							self.yFloat = 0\\r\\\
							break\\r\\\
						else\\r\\\
							didMoveY = true\\r\\\
							self.y = self.y + step\\r\\\
							self.yFloat = self.yFloat - step\\r\\\
						end\\r\\\
					end\\r\\\
				end\\r\\\
			else\\r\\\
				didMoveY = false\\r\\\
			end\\r\\\
\\r\\\
			-- handle x position\\r\\\
			if x ~= 0 then\\r\\\
				step = x / math.abs(x)\\r\\\
				round = self.xFloat > 0 and mathfloor or math.ceil\\r\\\
				if self:CheckCollision(step, 0) then\\r\\\
					self.xFloat = 0\\r\\\
					didMoveX = false\\r\\\
				else\\r\\\
					for ix = step, round(self.xFloat), step do\\r\\\
						if self:CheckCollision(step, 0) then\\r\\\
							didCollide = true\\r\\\
							self.xFloat = 0\\r\\\
							break\\r\\\
						else\\r\\\
							didMoveX = true\\r\\\
							self.x = self.x + step\\r\\\
							self.xFloat = self.xFloat - step\\r\\\
						end\\r\\\
					end\\r\\\
				end\\r\\\
			else\\r\\\
				didMoveX = false\\r\\\
			end\\r\\\
		else\\r\\\
			if self:CheckCollision(x, y) then\\r\\\
				didCollide = true\\r\\\
				didMoveX = false\\r\\\
				didMoveY = false\\r\\\
			else\\r\\\
				self.x = self.x + x\\r\\\
				self.y = self.y + y\\r\\\
				didCollide = false\\r\\\
				didMoveX = true\\r\\\
				didMoveY = true\\r\\\
			end\\r\\\
		end\\r\\\
\\r\\\
		local yHighestDidChange = (self.y > self.yHighest)\\r\\\
		self.yHighest = math.max(self.yHighest, self.y)\\r\\\
\\r\\\
		if yHighestDidChange then\\r\\\
			self.movesLeft = gameConfig.lock_move_limit\\r\\\
		end\\r\\\
\\r\\\
		if expendLockMove then\\r\\\
			if didMoveX or didMoveY then\\r\\\
				self.movesLeft = self.movesLeft - 1\\r\\\
				if self.movesLeft <= 0 then\\r\\\
					if self:CheckCollision(0, 1) then\\r\\\
						self.finished = 1\\r\\\
					end\\r\\\
				else\\r\\\
					self.lockTimer = gameConfig.lock_delay\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
	else\\r\\\
		didMoveX = false\\r\\\
		didMoveY = false\\r\\\
	end\\r\\\
\\r\\\
	return didCollide, didMoveX, didMoveY, yHighestDidChange\\r\\\
end\\r\\\
\\r\\\
-- writes the mino to the board\\r\\\
function Mino:Write()\\r\\\
	local is_solid, mino_color\\r\\\
	if self.active and self.board then\\r\\\
		for y = 1, self.height do\\r\\\
			for x = 1, self.width do\\r\\\
				is_solid, mino_color = self:CheckSolid(x, y, false)\\r\\\
				if is_solid then\\r\\\
					self.board:Write(x + self.x - 1, y + self.y - 1, self.doWriteColor and self.color or mino_color)\\r\\\
				end\\r\\\
			end\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
return Mino\\r\\\
\",\
    [ \"sound/lock.dfpwm\" ] = \"Ls,�85MSU�8''U����x�8���,�rX4�Ǳ��,58������q\\\\�����8VV�#�9j�q��r�8����Ó��c�8�����89�c��cj'���XiY9�s�ұJ3c��8�XU�1�83�pl��cZ�r���8c����qq8u<����cV�8s�8f<Ǳ��s�8ǣq�cf<�*�8α2�1N����q��8��pMK�8G�c��i���c�V9�pgU<z�t�r�g�q\\\\Z9��㌍�K������q�x�1�q�c<���q���8��8�s�q+�1��8�q�Ǳ�q'�c��8�X�q��c��x'�q�j<NY���q�89��,�q�j��ƩѴ4U5�Uͱr�qZ������XV�Ӵǩi�8�8�,���i�ij��q�rq�:�3M�q���8.�SU�2n8K�4��ʩ�jj9��4M���8β�e��U.:K�q�q�c�q����8��8�˱��rʱr��3��̪�1u8�8�4��1��2�4�J3�3�4�S�4N59�8���XcǩrǪ���r�*��<��:ƙr�q��*�c̱����1��q�r��,:5-�1�8�9f�8f�Se9��c:���qŅ�c���2:�S����c�qe�h�YN��8����q�����2�5S�3�S�XS�8㘋���3V�8ZV<t�*N���ǲ��2NS�8�G5�ᔕ�9�X.�8ZZ��g��T�qg�8K�4δb���8�8���e�i�U�1K���X�e�h�T�1�1g�cU���c�YU,-b�,M�8N�h<�X�X%�1Ә��8��X�f�c��q�8�9N9N9�%+�8��%�ǒ�<c�1���q�3�p�S�8�qj�꘦Ǳ�)KǱ���α�\\\\s�r�2s8���4��Ry�*i\\\\Sl<��ex4�cQ��1���q��r*k��j�'�8MU�2�����ƥ�fgY�i�if���i�����i�f\",\
    [ \"sound/fall.dfpwm\" ] = \"�@���\\\
��\\000 �?����W�\\000���\\000%� ܿo�\\000���\\\
��n[[=\\000��\\000D��~/ ���{�o{�V�@�H�;U��]����֪!@@I\\\"����mݻժ*D !H(�$!� ��\\r������m�z~�6��d���` _�U�'\\000I�\\\"\\\"����{k+�ߪVD\\000��\\000I\\\"!�Q������۷���n:�}�������j�ZB� ��K�@(T�Hm+ ��JQ���.���B�����PR��B����'����AZ�U�B(����[�^�W���k������Uc\\000�R�lU�1������۴J�\\000m]O�H���z�����U�$T \\\"@P�P+�V�UWm��UaQ\\\
�������G�WKKR\\000U��g������$@��R=\\\\l7��^���mw��kM%	�\\000$\\\\���[xOB���\\000���|��[��r+�������DT�$<��I\\\"�*%����ơ��������aU�!`\\000s0e�C%���H\\000&�T޺��]-��eQ+	�mX/�*\\000�-��~J�T�{����~��u-�,}�$\\000�P�]�~\\\\4S�Q¨,��tU��!�0X�ը$\\\
X��뢻���<�t+�3T���K��c�z�}��J\\\
O�4�h��0�����q���tW\\\
�]�Z�����\\\"���\\\
�z�I��8]�����2t�T�QPg�>װ֪c�(x��s�����~�i@J	z����]�˻������V\\000`���S�N�^��5�O�׭S@R,Dۊg,��<,��+����%����z�\\\"�+�axp\\000:�,\\r��0Xep߫��r8�b��>w��r颍���Px���� $�@�`�3�v]�D҃�jI-\\\"��q���VZ� �ǽ~�>\\\\�\\\
��#�8J�Ɠ�i�Xz|֡%ȥ,~�h�`a�a,����um��:���p�M7T����TUt������+ܯ�2����-�1����W=��!��Ӊ�R4ʩPE�XG8�<��箯�.+��\\\\Ê+�U�%�5<FG!\\\\2���Q^�#\\r���7�G8��qXkZ��\\\\��C�1���׾��	H�H�ѷ��#�d���i�WE5�~��1�Li4P���כK<r�|����>��(BE�mm���\\r�\\\
Uh��ׇ�� ����^-P��!H}��t��OZ.4�±���W.J�B��P�޿�����I0~�(.�a�Q���YJ#�&*(PDi�G�8K }�E)������n빂��� ���������)���;� Ŵ��%��߯���(��#�qȴ��ﱠ1--[�5Jaj(��7mY����7�=M��(��>y0~'Jy���0\\\
Cкw�@�u�Y��c�Q\\000�S��`=V�ϯ�$&$�(��ǷH���뎣\\000E�e����BDR�ͣ<\\rV_�y�w�G�}��@0��>�q��ҭg<-��bm��\\000��Z�+�5x����PP�կGY^\\\\�p�ac@=/�8��՚O[PwA�M\\\
-�z��㽯3���[%\\r��zݯ����@ �j:�\\\"��,y�lݣ��)�x���*ӊ�a0,�ΪQ��p����k��\\\"\\000�c�K!@(E�i�����I����V޵Ng�N�@)�}�Q�*3U|���?�(Q��ϯ6�P�y�'[{YB)RB-/�U}�b��`���B�������QӐ������E/��k���R����� �k�D�t������h �B��5J}?��å�(8�@@�����Y���Ү8jp���D�U�Ҋ��}����g޻�XEB� )���edB�u�u�DRՁ�B���mԉ��ޭF@�=J�/�\\000����^��@�J���ODB����w߿�(EI�\\\
�u��U�:��(��݋������:��;��Y�/�6((�f����ǹĔ��b�~Q��޿@��*)��,������(��JR�����}W���\\000X�3E��:�p�	!N)������V]S\\000B���k/��:��_�4��U���Y>���\\000Q�.	l6*����$�8E���B�&U��P`QӜ��\\\"B�ܽIR�����WiIJ���׿DH���P.����#!R�[JU�+� Q���%�6�H$�B���s�;���WE\\000�5�q�ץl�\\000%`��[�\\\\B@����\\\"�_��������ou@��_N�ݲl#�=�\\000��&���jA$`uG��t~�\\\"�o�������H���4������\\\
����h� @�޿erӣ\\000�nwm(R\\\"A�^��8�{�@�|��[ǒN�l嵋�_�R��������5��z�PG	�}�������� ����z�~�\\\"�@��ߗ�����Z_) *����4�\\000J.��k)򻓠����o�;�. A�{{�\\000��*-\\000��]Q��V�P4���=�AH�o�@������}ma����S����iD���������O	e	��[�!�V�/�R��o��'	R��F��w�r��P���m�+�(	 j����T\\000�������0���A�B����vLb!ҷ�?(=\\r��%ϻ�X�K�4T� i\\\
vO�n}_\\\
���~O������@}���T�(Fo��\\\"u�e����p�9��a�����}��(�QDR�U����6tH�o�H�ﯭ��b�ʗ����X��>]a��k�G�B/�M�߯���U�PN!V._._ZQ�U�(���S	�]k'�k�H��PHV�����kC���%D�_m��j��-iJ� Dhq��/i˪���\\r%Z}	���.�W��J��xi��B�\\\"u�y�Q*u��~)��TZ�u:!YqMZZy.Y׻�\\\"��T1���U�UD�����{�5(���j�(jtT(q��j�V�$�W`�+��k�\\\"�RB���VkIT�:��r�\\\"MQY�J}k�*\\\
S����i�U�D5)�\\\\)�����T�R��k���kJ�RUE�Z�ݪ\\\"hUR�֯��Tnw�0R���T�ɢ*E�VU��o)US��V����@�j���RiZIUR�fUU5k)��V	+[i���fUEJUQj-UUմW4uӶ�$�n�L�J��UKU͒�J�TR���nE�Vje����E��l��CU�J������j�,M��V���ԥ��VDe���U���6B�HM-U�j�m�QU��*�޲*����*E�U]�U�J*UK���VU���L)�TZ��-���UI�*�����UZ�T�RU���Ui�2U��*��U�*�J�mU��TUU�T���U�*�JU�VU��ժ*U�j�VUUUUU���j�����RU�jU�JU�j���VUUUUUUeUUUUUUU5U���ZUUU���������VUU��,�UUUVUUZU�UU�����VU�ZUUUUUUUUUUUU�*U��ZUUUUUUUUUU�����UUU����ZUU���Z�VUU������j���Vj����Z��UUUUUUUY���Zjj��VUUU�jeUVUUUUUUj\",\
    [ \"sound/mino_S.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000�_\\000\\000\\000\\000\\000\\000�Lf�vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�_\\000\\000\\000\\000\\000�u�D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�����˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ�,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000�)\\000\\000\\000\\000\\000\\000�_\\000\\000\\000\\000\\000��$bI1F5F5G=D5A5-689<2:5+1^���i����'j�j7cO7g7ϯ_ޜ�cU����\\\\��?�J�\\000�Ee\\000_giG`?�ҟ��	�����\\000z�����v#�7`ڀ\\000�T�*H\\000`kp\\000\\000x*b\\000���\\000��'\\000\\000\\000�n��I�u�n����� \\000���֚H|	\\0009�������x�j����g�\\000�\\000oxv\\000�C�\\000T\\000W��u\\000n��:���j��Y_\\rm4\\0000�H	���a�\\000�P�G\\000@|+\\000�x�8��\\000f���xݛi�rDw��\\\
j������s=^�xPuy�쵂�7{����&���%\\000<K��B9@vu�\\000z�+I���rc�i*\\000DdU�,��\\000D���@����x��	\\000�\\000	��4\\000r�ۭ����&���N\\000@R� ��r}�l���c[\\000����\\000\\000N��UM`�	�\\\\�@�cƖL�\\000���q�\\000j��9���Z$GR3�\\000u�q\\000�Z�1�Y\\0003��2�L\\0000��iµ@��a��j��b\\000^�=vߎ��Z�>��j{���ݟ���i������`}�	���T*F�����\\000�2�@\\\\��`�t�\\000n��;�0>j�_U��D5\\000��`\\000���f\\000�5��K\\000:�[��(�\\000��.\\000^��p|�4~�C!s�\\\
��\\000�hPe�ҮK&\\000\\0001L���z\\\
�#\\000`\\000[�O�\\000�R��\\000>�	b�}ן�x�W��o�\\\"�9�\\000 �r�\\000\\000֛��\\000�,\\000N?\\000\\000���\\0004\\\\\\r\\000��\\000f���?u���J}�;�44���r�\\000�\\\
\\000�\\000���.\\000��W\\000�\\000*�����CS��X��ӈ����q�C�2��c��\\000�\\r���{\\000\\000\\r��M.\\000$v}����8gU���%�b�Y`��ϝ���Ν;_��!\\000��6�(`1�\\000��\\000�\\000�r\\000{SѺ~�n�c�h��N�z��h��~�>1���(DH�%���8�F	��U����\\000y��lg�u��΀�@a��e8���mOX*?_��#YeL@v\\000�@��\\000��>\\000y�9���C�Rm��S�	����Pz��\\000�\\000N.`00��*\\000{�9��<�M��j+}��{\\000�?R��|u\\000J	\\000��\\000'�9&@�ػ�\\000	؎\\r\\000����T-� }P�Ml4�&�a����Q:����\\000\\000`:@�\\000>�U4��>\\000��u�ti~S.���=44�-*c��w\\000�h\\000\\000��M\\000\\0004�\\000zqx�һ�V��y�,,*c����,~����C��b\\000\\0007.~�<\\000|`�\",\
    [ \"sound/mino_O.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000�^\\000\\000\\000\\000\\000\\000svorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�^\\000\\000\\000\\000\\000d�,D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�����˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ�,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000�\\\"\\000\\000\\000\\000\\000\\000�^\\000\\000\\000\\000\\000�%[�VHLW_LbfDD><BBOME?3V���3d���M�#\\000Ц=�B���e���T��s������D��ta`O\\000\\000����O�G\\000�3�_\\000̟C	`]Z\\r�U���o(C\\000n��{]�6�C��\\0008\\000iP{�n����i�\\000s�����y\\\\�w�V�\\000��%z���V���~R��� �\\000f�+�x�\\000���\\000��>z���\\000����}�\\000��g\\000�u%\\000���9��Z�7����QV�n���A�0\\\\\\000Z�r�Z@���`\\000@�\\000�lc�����?�����\\000��Z�\\000K��p��G������9�i@�[f@0�|0cf��\\000b�8-<����E��D\\000��\\000\\000�cd}�{�{�4m��4S�W��D��S�v��*��G�,��8�ޢ���qu_��\\000���V^��Z/��i���meIz\\000Lc����5��mϖ\\000�y#2n���Yi\\\
\\000���e\\000�xH\\000���6�pu@�Z�d�kpS�\\0004�\\0008<�Z��3�y��]�_���*�D�\\000W�Y��#\\000.�n��aB�10fP��5�J�D����úY�X�E�=����'\\000R�+�vg(um<���KޟO�����1��&��vo+q��\\\"+��)ƪ �W��!��\\\\���0�[-���|iE��I�p�1�1�~~2P�8���\\\
cvu?\\000^�}&7���<����K\\\\��\\000�Z`�h3\\000\\0000\\000��\\000��`XI<H@	���0��%�@@�C?t\\000:�+��|/TC�1T�VP�P{�\\\
v8����+�;��������<�#v�K�5�`��։]��0{��'��8١Ԓ}Nj�X�zH���8r���u-<u\\r��\\000��(@1`�:\\000�g��-���S8�ih���@�:�9�\\r���p:\\000g���<HP���\\\"�e�H�ˌ�j��(�\\000}��E-)��o�*B�<�2�StzH�s�!���%�_�z����\\\\Bc����\\000\\000u8�]8~���	\\000PnS�b�tv�.��5��c�V9��Q����ѱK��<0�X\\000�~5`\\000w�W\\000�V	\\000(=\\000�1��f&�Yպ}	��\\000�]�`[���+�Y���7��aFu�� ~U�U���+�r�=\\000y�\\000�}������A��Y�Z�˛����y%�ω�y��L���؇�\\000l��?\\\\�������>�҂����[e�au���-�y\\000o�U�ڬ�^�^m1��v�2�C��d�``�P�� }�y*�|��V�ΎΖ�\\000g�5�~P�ЭJ�2\\000k{�	�i^`;�i�-_b�pYCF�\\\
v�X�:�+��\\000�?W�����1\\000��4M;�<���!';Ɇg1@�CU����@���\\000\",\
    [ \"sound/mino_I.dfpwm\" ] = \"��\\000��s�9�����Ly��~`�z���|�S�h�8s`�*������l���,�a����U����QE?��\\000�Z��/p�A?��\\\
W]�Q��X��j�G]ЕC?T�k]�Q�~��<s��)^�����:�S\\r�����U�«z��/V�����J�ꠏR��+�X��t�G;�B�X�C�V������[�t��8��/�F���KC���7�*�:��Z�ꃮ�{�S���b;�&���/�������C��~�~�JtM�����	��i�[�^�<��[×�K�@��4�Mx*B/���\\\
W��Sy�}�*|	z*/hU÷�W��Q��]�*>=����J�W�tA��(�:)? 7��/����s�@Z��.�R��u��}�2=P�RIG�tE�ҫ+&�=����V���Յyti��\\rU���!�/U-���R�$}TyP�\\\
'�����@z�,���#H�*�����O �XyP��V�\\\"����/�,�+�+�$?�:���K�/��rP{�\\\
}�Y���Z�W����}���W�^%��6���^}�!�A�?P�n鈇�\\000�XUi�,����Ẓ����A�Z=U��Ni���@�*�K\\\
飩|��7�K.�j�*? �~d����(˞��oX���\\\"���/��/T�BZ�^k�@�+uA�{�U\\r�w�U�~H�P���x��o��{��#j�\\\
:բ�*���R��jп��>�(��<����R�H��G�j�U5�j|����#���$��\\000G�^�h/���}+x��W��R�j��S�~%H�j������wx�ѓ�|ъ�m�K\\r��+y��X��zi����~7��_B�U5��\\\
���E �����ZC_%�ǔB����=U���{Q���+p��/��*�~V�'�~p�@�Vx��.�Q�\\000��9����^���Bx��m�o�� �\\\
Q��G^�\\000�*�\\000��<�]!��EU-�t�K�_I��Q��LZ_\\\"�e�n/�*�V��%�T�p��[/-/��~4-]��K-�^�V�M@���P��w=U>��C�A�\\r������\\r�;hU�_���B��o��\\000������v�\\\"��X�r�X>+Я���#| �!i�+��_ _t���*�b��!�P�&�o�[���%���4~��n��ї���D��P�Jx�>B>*E������d�~�R|tZ�/��w	W��Q��opU|\\000����������T�Mx*?@���K��K�PQ�\\\"���VC�r�J}�0:^��\\r��OxA�:�C�>��/F��Xj�_`�@�h�U���ۼ�]��]1�D��F�ХĿp�	���G]-�T��J�	o9�e�p�u�O%^�zT��j���b�x���x�U���7�逗�Q�x��/��Bk�����N5���x����BW�T�_X倮:��J���A�����F?4��Z�C��^����e�o��!�5�E�^�T�>��V-�eoh�\\\"�j؋*�Ъ�^��\\\
�Z�SJwh�^Uh'[�આ>���:�S�na����G5^�ю:m�oq�����K�v�N[\\\\�����-��S?��+yO!^�����i�.���^(�E�W$�U�`'6��/е��>Ԛb�OT��%A��͇T�M�@�:\\\
����'��}��+��B�%=��7hG\\\\����/P�_��������H��4�A_)�1���M�\\r�DbZ�-,t�����H��5�VO	��]�zP��pʱk ۥ�پ���U@�}!�-�o�R�\\\"�Q\\\"��]�\\r_I�O5� ��j�[\\\
���&��ʓ�U��]\\\"�/�ZT�%�Zt�����ȵ��C{��������{A]j�T{�����E���'���AW��W:��B�_�S��$���J}K�[�̓kxUhKt�NW5p���]��݂%Gw�Z9dUçD�zEy��%ݪ�ҵ	U[�Y�[���o���ґU+V[)�R�m;T�t[B��KRu�hԵ����$viՄ���*�iSE�ZUY��D��+�^UY��\\\
���uYe�m+j��Jѥ��d�T�t[���L[�VIg���v���h�u5Z�4Y�&�+JWMի��F��m�t�T+-{֪�\\\"k����U�%i-U՜��]��ʖ��R�Ҫl��*U�ZJV��-�)�%UժԴZ��R-ՖT�*UK�R�Q�ԪT�*U+UK�)�JKUK�TkRK�J�*+�*US�R��J���Ԫ�*�T��J�*MU�T��R�R5����*U--K�*M�J�ҪR��T�R�J+U�*ӪT��JU�R���TS5��J�Jղ*�T�R��T�*��*U+�ҪT3�J�J��*�R�R��J�J�R��J�\",\
    [ \"config/clientconfig.lua\" ] = \"return {\\r\\\
	controls = {\\r\\\
		rotate_ccw = keys.z,\\r\\\
		rotate_cw = keys.x,\\r\\\
		rotate_180 = keys.c,\\r\\\
		move_left = keys.left,\\r\\\
		move_right = keys.right,\\r\\\
		soft_drop = keys.down,\\r\\\
		hard_drop = keys.up,\\r\\\
		sonic_drop = keys.space,	-- drop mino to bottom, but don't lock\\r\\\
		hold = keys.leftShift,\\r\\\
		pause = keys.p,\\r\\\
		restart = keys.r,\\r\\\
		open_chat = keys.t,\\r\\\
\\r\\\
		menu_up = keys.up,\\r\\\
		menu_down = keys.down,\\r\\\
		menu_left = keys.left,\\r\\\
		menu_right = keys.right,\\r\\\
		menu_select = keys.enter,\\r\\\
		menu_cancel = keys.backspace,\\r\\\
		quit = keys.q,\\r\\\
	},\\r\\\
	-- (SDF) the factor in which soft dropping effects the gravity\\r\\\
	soft_drop_multiplier = 4.0,\\r\\\
	\\r\\\
	-- (DAS) amount of time you must be holding the movement keys for it to start repeatedly moving (seconds)\\r\\\
	move_repeat_delay = 0.25,\\r\\\
	\\r\\\
	-- (ARR) speed at which the pieces move when holding the movement keys (seconds per tick)\\r\\\
	move_repeat_interval = 0.05,\\r\\\
	\\r\\\
	-- (ARE) amount of seconds it will take for the next piece to arrive after the current one locks into place\\r\\\
	-- settings this to something above 0 will let you preload a rotation (IRS) or hold (IHS) (unimplemented)\\r\\\
	appearance_delay = 0,\\r\\\
	\\r\\\
	-- alternate appearance delay for when a line is cleared\\r\\\
	line_clear_delay = 0,\\r\\\
	\\r\\\
	-- amount of pieces visible in the queue (limited by size of UI)\\r\\\
	queue_length = 5,\\r\\\
	\\r\\\
	-- whether or not to render the ghost mino\\r\\\
	do_ghost_piece = true,\\r\\\
}\\r\\\
\",\
    [ \"lib/menuslider.lua\" ] = \"local MenuSlider = {}\\\
\\\
function MenuSlider:New(x, y, min, max, interval, width)\\\
	local slider = setmetatable({}, self)\\\
	self.__index = self\\\
\\\
	slider.x = x or 1\\\
	slider.y = y or 1\\\
	\\\
	slider.is_slider = true -- just making sure\\\
\\\
	slider.color_cap = colors.yellow\\\
	slider.color_handle = colors.yellow\\\
	slider.color_bar = colors.lightGray\\\
	slider.color_text = colors.white\\\
	\\\
	slider.max = max or 10\\\
	slider.min = min or 0\\\
	slider.interval = interval or 1\\\
	slider.width = width or 8 -- length of bar, not including cap characters\\\
	slider.char_cap = { \\\"[\\\", \\\"]\\\" }\\\
	slider.char_bar = { \\\"\\\\128\\\", \\\"\\\\132\\\", \\\"\\\\140\\\" }\\\
	\\\
	return slider\\\
end\\\
\\\
function MenuSlider:Render()\\\
\\\
	\\\
	\\\
end\\\
\\\
return MenuSlider\",\
    [ \"lib/menu.lua\" ] = \"local Menu = {}\\\
\\\
\\\
function Menu:New(x, y)\\\
	local menu = setmetatable({}, self)\\\
	self.__index = self\\\
\\\
	menu.x = x or 1\\\
	menu.y = y or 1\\\
	menu.selected = 1\\\
	menu.title = {\\\"\\\", 1}\\\
	menu.options = {}\\\
	menu.cursor = {\\\">\\\"}\\\
	menu.cursor_blink = 0.5\\\
	menu.cursor_index = 1\\\
	menu.color_title = colors.yellow\\\
	menu.color_selected = colors.yellow\\\
	menu.color_unselected = colors.lightGray\\\
\\\
	return menu\\\
end\\\
\\\
local function cwrite(text, y, color)\\\
	local cx, cy = term.getCursorPos()\\\
	local sx, sy = term.getSize()\\\
	local og_color = term.getTextColor()\\\
	if color then\\\
		term.setTextColor(color)\\\
	end\\\
	term.setCursorPos(sx / 2 - #text / 2, y or (sy / 2))\\\
	term.write(text)\\\
	term.setTextColor(color)\\\
end\\\
\\\
function Menu:CycleCursor()\\\
	self.cursor_index = (self.cursor_index % #self.cursor) + 1\\\
end\\\
\\\
function Menu:Move(x, y)\\\
	self.x = tonumber(x) or self.x\\\
	self.y = tonumber(y) or self.y\\\
end\\\
\\\
-- takes absolute mouse X and Y, optionally returns menu index\\\
function Menu:MouseSelect(x, y)\\\
	local sel\\\
	local mx = (x - self.x) + 1\\\
	local my = (y - self.y) + 1\\\
	for i, option in ipairs(self.options) do\\\
		if my == option[3] then\\\
			if mx >= option[2] and mx < (option[2] + #option[1]) then\\\
				return i\\\
			end\\\
		end\\\
	end\\\
end\\\
\\\
function Menu:AddOption(name, sID, rx, ry)\\\
	assert(type(sID) == \\\"string\\\", \\\"menu options must have string ID\\\")\\\
	name = name or \\\"\\\"\\\
	rx = rx or 1\\\
	ry = ry or 1\\\
\\\
	table.insert(self.options, {name, rx, ry, sID})\\\
end\\\
\\\
function Menu:AddOptions(tOptions)\\\
	for i, option in ipairs(tOptions) do\\\
		self:AddOption(table.unpack(option))\\\
	end\\\
end\\\
\\\
function Menu:GetSelected()\\\
	return self.options[self.selected][4]\\\
end\\\
\\\
function Menu:SetTitle(title, ry)\\\
	assert(type(title) == \\\"string\\\", \\\"asshole\\\")\\\
	self.title[1] = title\\\
	self.title[2] = ry or self.title[2]\\\
end\\\
\\\
function Menu:MoveSelect(delta)\\\
	local new_selection = ((self.selected + delta - 1) % #self.options) + 1\\\
	if self.options[new_selection] then\\\
		self.selected = new_selection\\\
	end\\\
end\\\
\\\
function Menu:Render(show_no_selected)\\\
	local cursor_index = (math.floor(os.clock() / self.cursor_blink) % #self.cursor) + 1\\\
--	term.setCursorPos(self.x + self.title[2] - 1, self.y + self.title[3] - 1)\\\
--	term.setTextColor(self.color_title)\\\
--	term.write(self.title[1])\\\
	cwrite(self.title[1], self.y + self.title[2] - 1, self.color_title)\\\
\\\
	term.setTextColor(self.color_unselected)\\\
	for i, option in ipairs(self.options) do\\\
		if show_no_selected or (i ~= self.selected) then\\\
			term.setCursorPos(self.x + option[2] - 1, self.y + option[3] - 1)\\\
			term.write(option[1] .. \\\"  \\\")\\\
		end\\\
	end\\\
\\\
	if not show_no_selected then\\\
		term.setTextColor(self.color_selected)\\\
		term.setCursorPos(self.x + self.options[self.selected][2] - 1, self.y + self.options[self.selected][3] - 1)\\\
		term.write(self.cursor[cursor_index])\\\
		term.write(self.options[self.selected][1] .. \\\"  \\\")\\\
	end\\\
end\\\
\\\
return Menu\\\
\",\
    [ \"sound/mino_L.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000Q/��vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000*5�!D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�����˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ�,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000�%\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000�U�`//.F;.07JbQ/14M6+-Rc�苤j��+��㭯\\\"~��i�����ʯ�G�F�.�������[]��]r.iX��[���}�ɸ�ĢU�v�L�I��as�*�#�����H\\rL��vo�d�������	��2�^0�d\\000\\000����π�G�Np�C\\000�@�K\\000�ro�Ĭ��ŧ%wt����o�V\\000\\000��Y\\000?��\\000�� \\\
�)�vo�$����=������[��\\000�C��Y`p���� \\000��\\000�jo�8`�I�1,J�RE(]�R��Rϳ����<rS�o��1И\\\"�OH֚5	�h�:��=�<��$0@\\000^q<���l����f5��\\000T�FD��I��i�\\000���YJ�|�/`\\000�@���*\\000rq(�������l(s�;\\000�3��`����H\\000\\000{�	���\\000�\\000^m�:��D7��K�`g\\000�fݗ�'$p{\\000���^\\000�\\000�\\000l	\\000xL\\000&MĹ�I���c@][WˠHm:�/�眀\\r�t7�g	�`�.��{.p؀\\0000�\\000E�ƨ���[Ҝ\\0005o���,�˝����6��+URL-b�G�2X���,YSh �F�1��p���{m.덛T]�\\000El �������u���_]�橐ϛt�K[��/��i2A��'?~����䧁��T�N�v\\r�?	��/6���'�`Z�\\\\jm��{D���6�\\000Gy�R�M����Ë�oYm+��-��Y��m���b1e��0�f(9�r�%*R�oS��f�@Wx��tz�9[J���`b6\\000*KЄ�0e��47~��k:Xd\\000�y��\\000��\\000��\\000�\\000���\\000�L\\000*IЄ*�T�����b�\\\\�\\\
!�̫�\\000@�!\\000O@�\\\\�y\\000Q�7��t\\000&I�Ď0e<}�9�J@�^2B�����y��@�y\\000J\\000���E=��\\000G��ր\\\"�~�3����Z�4K��mݺ�5S;�ILO�v���4�ɐS�]ii��Q:�xE)��@ׁ�8P: ��K45K�����@���\\000@=M��y�	:G\\000�ǐ�@�P�(�\\\
�)\\000E��U���OC|�J�;\\000��\\\\��\\000{9�\\000�\\000��\\000ˠ�o�Ei��(���!y�40�&\\0000�35K�\\000v�j�K\\000x������I��\\000\\\"��!\\000\\000�,�nݚ�����q\",\
    [ \"lib/board.lua\" ] = \"-- generates a new board, on which polyominos can be placed and interact\\r\\\
-- TODO: optimize Render function! ideally, render minos onto framebuffer on second pass\\r\\\
local Board = {}\\r\\\
\\r\\\
local gameConfig = require \\\"config.gameconfig\\\"\\r\\\
\\r\\\
local stringrep = string.rep\\r\\\
local mathfloor = math.floor\\r\\\
local tableconcat = table.concat\\r\\\
\\r\\\
-- {match pattern, character, color invert?}\\r\\\
-- used for RenderTiny method\\r\\\
local tele_lookup_rev = {}\\r\\\
local tele_lookup_nor = {\\r\\\
	[\\\"      \\\"] = \\\"\\\\128\\\",\\r\\\
	[\\\"O     \\\"] = \\\"\\\\129\\\",\\r\\\
	[\\\" O    \\\"] = \\\"\\\\130\\\",\\r\\\
	[\\\"OO    \\\"] = \\\"\\\\131\\\",\\r\\\
	[\\\"  O   \\\"] = \\\"\\\\132\\\",\\r\\\
	[\\\"O O   \\\"] = \\\"\\\\133\\\",\\r\\\
	[\\\" OO   \\\"] = \\\"\\\\134\\\",\\r\\\
	[\\\"OOO   \\\"] = \\\"\\\\135\\\",\\r\\\
	[\\\"   O  \\\"] = \\\"\\\\136\\\",\\r\\\
	[\\\"O  O  \\\"] = \\\"\\\\137\\\",\\r\\\
	[\\\" O O  \\\"] = \\\"\\\\138\\\",\\r\\\
	[\\\"OO O  \\\"] = \\\"\\\\139\\\",\\r\\\
	[\\\"  OO  \\\"] = \\\"\\\\140\\\",\\r\\\
	[\\\"O OO  \\\"] = \\\"\\\\141\\\",\\r\\\
	[\\\" OOO  \\\"] = \\\"\\\\142\\\",\\r\\\
	[\\\"OOOO  \\\"] = \\\"\\\\143\\\",\\r\\\
	[\\\"    O \\\"] = \\\"\\\\144\\\",\\r\\\
	[\\\"O   O \\\"] = \\\"\\\\145\\\",\\r\\\
	[\\\" O  O \\\"] = \\\"\\\\146\\\",\\r\\\
	[\\\"OO  O \\\"] = \\\"\\\\147\\\",\\r\\\
	[\\\"  O O \\\"] = \\\"\\\\148\\\",\\r\\\
	[\\\"O O O \\\"] = \\\"\\\\149\\\",\\r\\\
	[\\\" OO O \\\"] = \\\"\\\\150\\\",\\r\\\
	[\\\"OOO O \\\"] = \\\"\\\\151\\\",\\r\\\
	[\\\"   OO \\\"] = \\\"\\\\152\\\",\\r\\\
	[\\\"O  OO \\\"] = \\\"\\\\153\\\",\\r\\\
	[\\\" O OO \\\"] = \\\"\\\\154\\\",\\r\\\
	[\\\"OO OO \\\"] = \\\"\\\\155\\\",\\r\\\
	[\\\"  OOO \\\"] = \\\"\\\\156\\\",\\r\\\
	[\\\"O OOO \\\"] = \\\"\\\\157\\\",\\r\\\
	[\\\" OOOO \\\"] = \\\"\\\\158\\\",\\r\\\
	[\\\"OOOOO \\\"] = \\\"\\\\159\\\"\\r\\\
}\\r\\\
\\r\\\
for k,v in pairs(tele_lookup_nor) do\\r\\\
	if type(k) == \\\"string\\\" then\\r\\\
		tele_lookup_rev[ k:gsub( \\\".\\\", function(c) return c == \\\" \\\" and \\\"O\\\" or \\\" \\\" end ) ] = v\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
function Board:New(x, y, width, height, blankColor)\\r\\\
    local board = setmetatable({}, self)\\r\\\
    self.__index = self\\r\\\
\\r\\\
    board.contents = {}\\r\\\
    board.height = height or gameConfig.board_height\\r\\\
    board.width = width or gameConfig.board_width\\r\\\
    board.x, board.y = x, y\\r\\\
    board.blankColor = blankColor or \\\"7\\\" -- color if no minos are in that spot\\r\\\
    board.transparentColor = \\\"f\\\"         -- color if the board tries to render where there is no board\\r\\\
    board.garbageColor = \\\"8\\\"\\r\\\
    board.visibleHeight = height and mathfloor(board.height / 2) or gameConfig.board_height_visible\\r\\\
    board.charHeight = math.ceil(board.visibleHeight * (2 / 3))\\r\\\
    board.overtopHeight = 0\\r\\\
	board.last_frame = {}\\r\\\
\\r\\\
    for y = 1, board.height do\\r\\\
        board.contents[y] = stringrep(\\\" \\\", board.width)\\r\\\
    end\\r\\\
\\r\\\
    return board\\r\\\
end\\r\\\
\\r\\\
function Board:Write(x, y, color)\\r\\\
    x = mathfloor(x)\\r\\\
    y = mathfloor(y)\\r\\\
    if not self.contents[y] then\\r\\\
        error(\\\"tried to write outsite size of board!\\\")\\r\\\
    end\\r\\\
    self.contents[y] = self.contents[y]:sub(1, x - 1) .. color .. self.contents[y]:sub(x + 1)\\r\\\
end\\r\\\
\\r\\\
function Board:IsSolid(x, y)\\r\\\
	x = mathfloor(x)\\r\\\
	y = mathfloor(y)\\r\\\
	if self.contents[y] then\\r\\\
		if x >= 1 and x <= self.width then\\r\\\
			return (self.contents[y]:sub(x, x) ~= \\\" \\\"), self.contents[y]:sub(x, x)\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	return true, \\\" \\\"\\r\\\
end\\r\\\
\\r\\\
function Board:AddGarbage(amount, no_hole, color)\\r\\\
    --if amount < 1 then return end\\r\\\
\\r\\\
    local changePercent = 00 -- higher the percent, the more likely it is that subsequent rows of garbage will have a different hole\\r\\\
    local holeX = math.random(1, self.width)\\r\\\
\\r\\\
    -- move board contents up\\r\\\
    for y = amount, self.height do\\r\\\
        self.contents[y - amount] = self.contents[y]\\r\\\
    end\\r\\\
\\r\\\
    -- populate 'amount' bottom rows with fucking bullshit\\r\\\
    for y = self.height, self.height - amount + 1, -1 do\\r\\\
		if no_hole then\\r\\\
			self.contents[y] = stringrep(color or self.garbageColor, self.width)\\r\\\
		else\\r\\\
			self.contents[y] = stringrep(color or self.garbageColor, holeX - 1) .. \\\" \\\" .. stringrep(color or self.garbageColor, self.width - holeX)\\r\\\
			if math.random(1, 100) <= changePercent then\\r\\\
				holeX = math.random(1, self.width)\\r\\\
			end\\r\\\
		end\\r\\\
    end\\r\\\
end\\r\\\
\\r\\\
function Board:CheckPerfectClear()\\r\\\
    -- checks only the bottom 2 rows, since is is impossible to have blocks floating above two empty rows\\r\\\
    -- ... i think\\r\\\
    for y = self.height - 1, self.height do\\r\\\
        if self.contents[y] ~= (\\\" \\\"):rep(self.width) then\\r\\\
            return false\\r\\\
        end\\r\\\
    end\\r\\\
\\r\\\
    return true\\r\\\
end\\r\\\
\\r\\\
function Board:Clear(color)\\r\\\
    color = color or \\\" \\\"\\r\\\
    for y = 1, self.height do\\r\\\
        self.contents[y] = stringrep(color, self.width)\\r\\\
    end\\r\\\
    return self\\r\\\
end\\r\\\
\\r\\\
-- used for sending board data over the network\\r\\\
function Board:Serialize(doIncludeInit)\\r\\\
    return textutils.serialize({\\r\\\
        x             = doIncludeInit and self.x or nil,\\r\\\
        y             = doIncludeInit and self.y or nil,\\r\\\
        height        = doIncludeInit and self.height or nil,\\r\\\
        width         = doIncludeInit and self.width or nil,\\r\\\
        blankColor    = doIncludeInit and self.blankColor or nil,\\r\\\
        visibleHeight = self.visibleHeight or nil,\\r\\\
        contents      = self.contents\\r\\\
    })\\r\\\
end\\r\\\
\\r\\\
function Board:SerializeContents()\\r\\\
	return tableconcat(self.contents)\\r\\\
end\\r\\\
\\r\\\
-- takes list of minos that it will render atop the board\\r\\\
-- TODO: optimize please!\\r\\\
function Board:Render(tOpts, ...)\\r\\\
	tOpts = tOpts or {}\\r\\\
	local xmod = tOpts[1] or 0\\r\\\
	local ymod = tOpts[2] or 0\\r\\\
	local char_sub = tOpts.char_sub or {}\\r\\\
	local text_sub = tOpts.text_sub or {}\\r\\\
	local back_sub = tOpts.back_sub or {}\\r\\\
	local ignore_dirty = tOpts.ignore_dirty\\r\\\
	\\r\\\
    local charLine1 = stringrep(\\\"\\\\131\\\", self.width)\\r\\\
    local charLine2 = stringrep(\\\"\\\\143\\\", self.width)\\r\\\
    local transparentLine, blankLine = {}, {}\\r\\\
    for x = 1, self.width do\\r\\\
        transparentLine[x] = self.transparentColor\\r\\\
        blankLine[x] = \\\" \\\"\\r\\\
    end\\r\\\
    local colorLine1, colorLine2, colorLine3 = {}, {}, {}\\r\\\
    local minoColor1, minoColor2, minoColor3\\r\\\
    local minos = { ... }\\r\\\
    local is_solid, mino_color, mino\\r\\\
\\r\\\
	local tY = self.y - math.ceil(self.overtopHeight * 0.666)\\r\\\
	local topbound = self.height - (self.visibleHeight + self.overtopHeight)\\r\\\
	local visibound = topbound + self.overtopHeight\\r\\\
	local mino\\r\\\
	local dirty = {}\\r\\\
\\r\\\
	for y = 1 + topbound, self.height, 3 do\\r\\\
--		colorLine1, colorLine2, colorLine3 = {}, {}, {}\\r\\\
        for x = 1, self.width do\\r\\\
            minoColor1, minoColor2, minoColor3 = nil, nil, nil\\r\\\
            --for i, mino in ipairs(minos) do\\r\\\
			for i = 1, #minos, 1 do\\r\\\
				mino = minos[i]\\r\\\
                if mino.visible then\\r\\\
\\r\\\
                    is_solid, mino_color = mino:CheckSolid(x, y + 0, true)\\r\\\
                    if is_solid then\\r\\\
                        minoColor1 = mino_color\\r\\\
						dirty[tY] = true\\r\\\
                    end\\r\\\
\\r\\\
                    is_solid, mino_color = mino:CheckSolid(x, y + 1, true)\\r\\\
                    if is_solid then\\r\\\
                        minoColor2 = mino_color\\r\\\
						dirty[tY] = true\\r\\\
						dirty[tY + 1] = true\\r\\\
                    end\\r\\\
\\r\\\
                    is_solid, mino_color = mino:CheckSolid(x, y + 2, true)\\r\\\
                    if is_solid then\\r\\\
                        minoColor3 = mino_color\\r\\\
						dirty[tY + 1] = true\\r\\\
                    end\\r\\\
\\r\\\
                end\\r\\\
            end\\r\\\
\\r\\\
            colorLine1[x] = (minoColor1 or ((self.contents[y    ] and self.contents[y    ]:sub(x, x)) or \\\" \\\"))\\r\\\
            colorLine2[x] = (minoColor2 or ((self.contents[y + 1] and self.contents[y + 1]:sub(x, x)) or \\\" \\\"))\\r\\\
            colorLine3[x] = (minoColor3 or ((self.contents[y + 2] and self.contents[y + 2]:sub(x, x)) or \\\" \\\"))\\r\\\
\\r\\\
            if colorLine1[x] == \\\" \\\" then colorLine1[x] = (y     > (visibound) and self.blankColor or self.transparentColor) end\\r\\\
            if colorLine2[x] == \\\" \\\" then colorLine2[x] = (y + 1 > (visibound) and self.blankColor or self.transparentColor) end\\r\\\
            if colorLine3[x] == \\\" \\\" then colorLine3[x] = (y + 2 > (visibound) and self.blankColor or self.transparentColor) end\\r\\\
\\r\\\
        end\\r\\\
\\r\\\
        if (y + 0) > self.height or (y + 0) <= topbound then\\r\\\
            colorLine1 = transparentLine\\r\\\
        end\\r\\\
        if (y + 1) > self.height or (y + 1) <= topbound then\\r\\\
            colorLine2 = transparentLine\\r\\\
        end\\r\\\
        if (y + 2) > self.height or (y + 2) <= topbound then\\r\\\
            colorLine3 = transparentLine\\r\\\
        end\\r\\\
		\\r\\\
		local _cl1, _cl2, _cl3 = tableconcat(colorLine1), tableconcat(colorLine2), tableconcat(colorLine3)\\r\\\
		\\r\\\
		if ignore_dirty or (self.last_frame[tY] ~= (_cl1 .. _cl2)) then\\r\\\
			term.setCursorPos(self.x + xmod, self.y + tY + ymod)\\r\\\
			term.blit(charLine2, tableconcat(colorLine1), tableconcat(colorLine2))\\r\\\
		end\\r\\\
		if ignore_dirty or (self.last_frame[tY + 1] ~= (_cl2 .. _cl3)) then\\r\\\
			term.setCursorPos(self.x + xmod, self.y + tY + ymod + 1)\\r\\\
			term.blit(charLine1, tableconcat(colorLine2), tableconcat(colorLine3))\\r\\\
		end\\r\\\
		\\r\\\
		self.last_frame[tY]     = _cl1 .. _cl2\\r\\\
		self.last_frame[tY + 1] = _cl2 .. _cl3\\r\\\
		\\r\\\
		tY = tY + 2\\r\\\
    end\\r\\\
end\\r\\\
\\r\\\
-- draws the board using smaller, black and white characters\\r\\\
function Board:RenderTiny(tOpts, ...)\\r\\\
	tOpts = tOpts or {}\\r\\\
	local xmod = tOpts[1] or 0\\r\\\
	local ymod = tOpts[2] or 0\\r\\\
	local char_sub = tOpts.char_sub or {}\\r\\\
	local text_sub = tOpts.text_sub or {}\\r\\\
	local back_sub = tOpts.back_sub or {}\\r\\\
	\\r\\\
	local charLine = {}\\r\\\
	local textLine = {}\\r\\\
	local backLine = {}\\r\\\
	local pixel = \\\"\\\"\\r\\\
	local minos = { ... }\\r\\\
	\\r\\\
	local is_solid\\r\\\
	\\r\\\
	local topbound = self.height - (self.visibleHeight + self.overtopHeight)\\r\\\
	local visibound = topbound + self.overtopHeight\\r\\\
	local tY = self.y - math.ceil(self.overtopHeight * 0.333)\\r\\\
	local ix = 0\\r\\\
	\\r\\\
	for y = 1 + topbound, self.height, 3 do\\r\\\
		charLine = {}\\r\\\
		textLine = {}\\r\\\
		backLine = {}\\r\\\
		ix = 0 -- char/text/backLine iterator\\r\\\
		for x = 1, self.width, 2 do\\r\\\
			ix = ix + 1\\r\\\
			pixel = \\\"\\\"\\r\\\
			for my = 0, 2 do\\r\\\
				for mx = 0, 1 do\\r\\\
					is_solid = false\\r\\\
					if (not self.contents[y + my]) then\\r\\\
						pixel = pixel .. \\\" \\\"\\r\\\
					elseif self.contents[y + my]:sub(x + mx, x + mx) == \\\"\\\" then\\r\\\
						pixel = pixel .. \\\" \\\"\\r\\\
					elseif self.contents[y + my]:sub(x + mx, x + mx) ~= \\\" \\\" then\\r\\\
						pixel = pixel .. \\\"O\\\"\\r\\\
					else\\r\\\
						for i, mino in ipairs(minos) do\\r\\\
							if mino.visible then\\r\\\
								is_solid = is_solid or mino:CheckSolid(x + mx, y + my, true)\\r\\\
								if is_solid then break end\\r\\\
							end\\r\\\
						end\\r\\\
						pixel = pixel .. (is_solid and \\\"O\\\" or \\\" \\\")\\r\\\
					end\\r\\\
				end\\r\\\
			end\\r\\\
			-- match \\\"pixel\\\"\\r\\\
			if tele_lookup_nor[pixel] then\\r\\\
				charLine[ix] = tele_lookup_nor[pixel]\\r\\\
				textLine[ix] = \\\"0\\\"\\r\\\
				backLine[ix] = \\\"f\\\"\\r\\\
			elseif tele_lookup_rev[pixel] then\\r\\\
				charLine[ix] = tele_lookup_rev[pixel]\\r\\\
				textLine[ix] = \\\"f\\\"\\r\\\
				backLine[ix] = \\\"0\\\"\\r\\\
			else\\r\\\
				charLine[ix] = \\\"?\\\"\\r\\\
				textLine[ix] = \\\"8\\\"\\r\\\
				backLine[ix] = \\\"c\\\"\\r\\\
			end\\r\\\
		end\\r\\\
		term.setCursorPos(self.x + xmod, tY + ymod)\\r\\\
		term.blit(tableconcat(charLine), tableconcat(textLine), tableconcat(backLine))\\r\\\
		tY = tY + 1\\r\\\
	end\\r\\\
	\\r\\\
end\\r\\\
\\r\\\
return Board\\r\\\
\",\
    [ \"sound/drop.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\0002\\\\\\000\\000\\000\\000\\000\\000��{Ovorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\0002\\\\\\000\\000\\000\\000\\000RO�!D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�����˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ�,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000m\\000\\000\\000\\000\\000\\0002\\\\\\000\\000\\000\\000\\000Wy5�yfddhde\\\\XMTJ���)]a���\\\
��-���R���_~˾^���q�z����yN�&o?hr��a&�$�1m&�?5��3\\\
��SS¿2��\\\"����ɟϟߖOO�|NG��G�_��+O��j��p�p�4��:\\000V�+ԃ@�>w�Ac�Nu)�|kw�R?˽O'|�P}ާ��g	KM_f|�A,�S��S�[��غÈ��i�δO�YX�s,�xy��V?c'i�u��h��%B��\\\"ZI>�k�,�����Z.�\\\\��L���6[\\\
\\000~���Q���g�Tna������ӫ��������5D=�2�G2nc�u�ak������˘�颋��(�R8��r3�%Ϸ��K�]�k1�m�L��x�j\\000����%9t|?U�<�Z�z��{tǓ���Z{tUֹQ5G$�/����͛��$���׎�p��)�\\000\\\
���T���\\000~ﺻ=���!�(�C�A�\\000���2h�����NE�f�*[��jn�D�>G���N:*��9�e&SW���sϿ7g�<-�&�F����?�)�v���B��[%o}�,���F�H�\\\
$���%��\\000�����x����dT	b>9/�qm��<�-���}{v6�蛱���!7�`�����l�NԚm�a-Y���/=�!`ܬ��\\\"�biݯ���I���mX�~n�\\0000��XJ,��I߻y��.�m���f>�Z�>�-��M�>�7<�ű�Xwmb��:��C�n�H���MQ�ɘi�c5����=��`�U֋�ׁ�K��Q�@Zm87�v�I�ݪ��.��d\\000���E�o��^�M{�+���Us1v͡-��+�=Uq��_@�#�]��mh<������@ބ[L?��A8nAzSt	\\000e��e\\000r�w�T�+L�������sk���z�=q�]ۺe�als��ڭk;�O�FX�aZ�.�K���������>���,x{�-5�\\\
�>�6f(\\000Ny�c\\\\`�j�N~�d5\\000@y3����eY����B�C�*������� �\\\\5Ќ��e\\rE7�O����s�����[�'f�fj`\\\
\\000Zcsv�h�l}{:�=S�@���Ȝ����{�H��Q�W�?�K䵵��|t��L����bkkŁ���cl�=0Ud\\\\v�I\\000\\0007k��\\\\G��W��&#��}���W���)n����u��k]'�*�����Gq\\\\5Za�g�$�8&�������=`�\\000\",\
    [ \"README.md\" ] = \"# LDRIS version 2\\\
Modern (to-be) multiplayer tetris for ComputerCraft. (Work in progress)\\\
\\\
### Current features:\\\
- Basic modem multiplayer (currently scuffed)\\\
- SRS rotation and wall-kicking, plus 180-spins\\\
- 7-bag randomization\\\
- Modern-feeling controls\\\
- Garbage attack support\\\
- Ghost piece\\\
- Piece holding\\\
- Sonic drop\\\
- Configurable SDF, DAS, ARR, ARE, lock delay\\\
- Animated piece queue\\\
- Included sound effects (from Tetris TGM 3)\\\
\\\
### To-do:\\\
- Further mitigate garbage collector-related slowdown when played in CraftOS-PC\\\
- Refactor code to look prettier\\\
- Add score, and let line clears and piece dropping add to it\\\
- Implement initial hold and initial rotation\\\
- Polish multiplayer up and make it perform good\\\
- Polish the menu and add some graphics or something\\\
- Implement arcade features (proper kiosk mode, krist integration)\\\
- Add touchscreen-friendly controls for CraftOS-PC Mobile\\\
- Cheese race mode\\\
- 40-line sprint mode\\\
- Add in-game menu for changing controls (some people can actually tolerate guideline)\\\
\",\
  },\
  mainFile = \"ldris2.lua\",\
  compressed = false,\
}")
if fs.isReadOnly(outputPath) then
	error("Output path is read-only. Abort.")
elseif fs.getFreeSpace(outputPath) <= #archive then
	error("Insufficient space. Abort.")
end

if fs.exists(outputPath) and fs.combine("", outputPath) ~= "" then
	print("File/folder already exists! Overwrite?")
	stc(colors.lightGray)
	print("(Use -o when making the extractor to always overwrite.)")
	stc(colors.white)
	if choice() ~= 1 then
		error("Chose not to overwrite. Abort.")
	else
		fs.delete(outputPath)
	end
end
if selfDelete or (fs.combine("", outputPath) == shell.getRunningProgram()) then
	fs.delete(shell.getRunningProgram())
end
for name, contents in pairs(archive.data) do
	stc(colors.lightGray)
	write("'" .. name .. "'...")
	if contents == true then -- indicates empty directory
		fs.makeDir(fs.combine(outputPath, name))
	else
		file = fs.open(fs.combine(outputPath, name), "w")
		if file then
			file.write(contents)
			file.close()
		end
	end
	if file then
		stc(colors.green)
		print("good")
	else
		stc(colors.red)
		print("fail")
	end
end
stc(colors.white)
write("Unpacked to '")
stc(colors.yellow)
write(outputPath .. "/")
stc(colors.white)
print("'.")
