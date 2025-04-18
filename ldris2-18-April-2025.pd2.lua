local tArg = {...}
local selfDelete = false -- if true, deletes extractor after running
local file
local outputPath = tArg[1] and shell.resolve(tArg[1]) or shell.getRunningProgram()
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
  compressed = false,\
  data = {\
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
    [ \"sound/mino_L.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000Û]\\000\\000\\000\\000\\000\\000Q/‚¨vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000Û]\\000\\000\\000\\000\\000*5—!Dÿÿÿÿÿÿÿÿÿÿÿÿšvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000€ \\\
Æ€ĞU\\000\\000\\000\\000BˆFÆP§”—‚…GÄP‡óPjé xJaÉ˜ôkBß{Ï½÷Ş{ 4d\\000\\000\\000@bà1	B¡Å	Qœ)Ba9	–r:	B÷ „.çŞrî½÷\\rY\\000\\000\\0000!„B!„B\\\
)¥RŠ)¦˜bÊ1ÇsÌ1È ƒ:è¤“N2©¤“2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊcŒ1ÆcŒ1ÆcŒ1ÆBCV\\000 \\000\\000„AdB!…RŠ)¦sÌ1Ç€ĞU\\000\\000 \\000€\\000\\000\\000\\000G‘É‘É‘$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û—}ÛwuÙ·}ÙvuY—eYwm[—uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9’#)’„†¬\\000d\\000\\000\\000à(â8’#9–cI–¤IšåYåi&j¢„†¬\\000\\000\\000\\000\\000\\000\\000\\000 (Šâ(#I–¥išç©(Š¦ªª¢iªªªš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš@hÈ*\\000@\\000@ÇqÇQÇqÉ‘$	\\rY\\000È\\000\\000\\000ÀPG‘Ë±$ÍÒ,Ïò4Ñ3=W”MİÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ€ĞU\\000\\000\\000\\000 ˆB†1 4d\\000\\000\\000€¢‘1Ô)%Á¥`!Ä1Ô!ä<”Z:RX2&=Å„Â÷Şsï½÷\\rY\\000\\000\\000FƒxL‚B(FqBg\\\
‚BXN‚¥œ‡N‚Ğ=!„Ë¹·œ{ï½BCV\\000€\\000\\000B!„B!„BJ)…”bŠ)¦˜rÌ1Çs2È ƒ:é¤“L*é¤£L2ê(µ–RK1Å[n1ÖZkÍ9÷”2ÆcŒ1ÆcŒ1ÆcŒ1‚ĞU\\000\\000\\000\\000aA„BH!…”bŠ)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I’,É’4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeİÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäHŠ¤\\000¡!«\\000\\000\\000\\000\\0008Š£8äHåX’%i’fy–gyš§‰šè¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(Š¢8ŠãH’eišæyª'Š¢©ªªhšªªª¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš&²\\\
\\000\\000\\000ĞqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000€\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç“<É³<Çs<É“4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000€ Ç´ƒ$	„ ‚äÄÄ¤… ‚ä:%Åä!§ bä9É˜Aä‚ÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥“9ç¤tR¡¥Rg©´ZbÌ(•ÚR­\\r„RH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,„BCV\\000Q\\000\\000„1H)¤bŒ9ÈDŒ1èd†1!sNAÇ…T*uPRÃsA¨ ƒT:G•ƒPRG\\000\\000€\\000\\000€\\000¡Ğ@œ\\000€A’4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUİvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×•eÓumÙue[WeYø5U•eÓumÙt]ÙveW·UYÖmÑu}]•eá7eÙ÷e[×}Y·•at]ÛWeY÷MY~Ù–…İÕu_˜DQU=U•]QU]×t][W]×¶5Õ”]ÓumÙT]YVeY÷]WÖuMUeÙ”eÛ6]W–UYöuW–u[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}U–u_Öua˜uÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_•máXeÙøuá–[×…ßs]_WmÙVÙ6†İ÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^İ6êÆO¸ß¨©ª¯›®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VY†Õ–…aÖuaÙ…a©Úº2¼ºo¯­+ÃíßW†ªmË«ÛÂ0û¶ğÛÂo»±3\\000\\0008\\000\\000˜P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEU•eÕ•eYu]]MÓ•EÕteÓT]Yu]WV]W–%M3MÍóLSó<Ó4UÓ•MSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓ–MS•eÓUmÙUeW–]Ù¶MU•eS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨š²kšªl«ªª»²kë¾,Ë¶,ªªëš®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï™¦,›ª)Û¦ªÊ²,»¶mË²/Œ¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À€\\000@€	e Ğ•\\000@\\000\\000`cŒAh”rÎ9RÎ9!sB©dÎA¡¤Ì9¥¤”9¡””B¥¤ÔZ¡””Z+\\000\\000 À\\000 ÀM‰Å\\\
\\rY	\\000¤\\000GÓLÓueÙËEU•eÛ6†Å²DQUeÙ¶…cEU•eÛÖu4QTUY¶mİWSUeÙ¶}]82UU–m[×}#U–m[×…¡’*Ë¶më¾QI¶m]7†ã¨$Û¶îû¾q,ñ…¡°,•ğ•_8*\\000\\000ğ\\000 VG8),4d%\\000\\000\\000¤”QJ)£”RJ)Æ”RŒ	\\000\\000p\\000\\0000¡²\\\"\\000ˆ\\000\\000œsÎ9çœsÎ9çœsÎ9çœsÎ9çcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1Æ\\000ìD8\\000ìDX…†¬\\000Â\\000\\000„‚’R)¥”9ç¤”RJ)¥”ÈA¥”RJ)¥DÒI)¥”RJ)¥qPJ)¥”RJ)¡”RJ)¥”RJ	¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ\\000&\\000P	6Î°’tV8\\\\hÈJ\\000 7\\000\\000PŠ9Æ$”JH%„Jå„ÎI	)µVB\\\
­„\\\
:h£RK­•”JI™„B(¡„RZ)%µR2¡„PJ!¥RJ	¡ePB\\\
%””RI-´TJÉ „PZ	©•ÔZ\\\
%•”A)©„’R*­µ”JJ­ƒÒR)­µÖJJ!•–R¥¤–R)¥µJk­µNR)-¤ÖRk­•VJ)¥”JI­µ–Zk)¥VB)­´ÒZ)%µÖRk-•ÔZK­¥ÖRk­¥ÖJ)%¥–Zk­µ–Z*)µ”B)¥•’Bj©¥ÖJ*-„ĞRI¥•VZk)¥”J(%•”Z*©µ–Rh¥…ÒJI%¥–J*)¥ÔR*¡”R*¡•ÔRk©¥–J*-µÔR+©”–JJ©\\000\\000tà\\000\\000`D¥…ØiÆ•GàˆB†	(\\000\\000\\000ˆ™@ \\000\\\
d\\000ÀB‚\\000PX`(]è‚\\\"HA\\\\8qã‰NèĞ\\000ˆ™\\000¡\\\"$dÀE…t\\000°¸À(]è‚\\\"HA\\\\8qã‰NèĞ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\†ÆG‡ÇHˆ\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000€OggS\\000¢%\\000\\000\\000\\000\\000\\000Û]\\000\\000\\000\\000\\000ìUØ`//.F;.07JbQ/14M6+-RcÅè‹¤j‘’+Ÿ±ã­¯\\\"~ª”iÖßıüÊ¯úG–F–.ÑÀ™‘¬ı[]›Ñ]r.iXÂ[¥®}¯É¸ÚÄ¢U‡vüL’I³ùasØ*½#——öçÖH\\rLŠvo¤d‡¦¦ŸÜĞ	 ï2ˆ^0·d\\000\\000ß÷åóÏ€ëG¼NpC\\000À@°K\\000ìro¨Ä¬©©Å§%wt¼ÿ–¦oĞV\\000\\000‘Y\\000?àõ\\000¾à \\\
¸)Švo¤$³¦¦¿=¹£¼ÿ–¢[‘¹\\000€CÄäY`p€ÿœ§ \\000§€\\000¼joÒ8`ÉI1,J°RE(]¡R¬ËRÏ³¤õÍ÷<rSÍoë˜1Ğ˜\\\"áOHÖš5	ÀhÀ:˜à=€<œÏ$0@\\000^q<øÍëlˆ°²f5»»\\000T›FDıIìği§\\000£èóYJú|è/`\\000 @ï ¸*\\000rq(˜´–ıÑñúl(s°;\\000à¨3¾«`¾Ğ÷ÀH\\000\\000{€	˜À²\\000Ì\\000^mà:ğşD7ÄèKÒ`g\\000­fİ—¹'$p{\\000°Ä^\\000ì\\000Æ\\000l	\\000xL\\000&MÄ¹ªI›î¸âc@][WË Hm:/¥çœ€\\rÀt7Ğg	À`Ø.Â{.pØ€\\0000é\\000E·Æ¨Õ‰Ş[Òœ\\0005o›ª¢,õËõøûœ6ËÙ+URL-b›Gü2XæÂé,YSh ÊF½1™ûpŠö©{m.ë›T]™\\000El µ¡ú¬ğ¢ŒúıuñşÂ—ª_]şæ©Ï›tİK[íç¿/şËi2Aãş'?~œÏÔÿä§¸òT®Nœv\\r†?	ŒÌ/6ªâÈ'»`Z·\\\\jm¡‹{D£6ş\\000Gyğ¢RèM™ÜøŒÃ‹”oYm+ÓÎ-»úYšùm·¨¹b1eôñ±0òf(9…rà%*RâoSÃüf€@Wx»­tzˆ9[Jãğ`b6\\000*KĞ„Š0eòÀ47~€¾k:Xd\\000àyşª\\000œú\\000€ \\000àª\\000€¾\\000°L\\000*IĞ„*âT’¦¹‘è»bÁ\\\\‡\\\
!ğÌ«ú\\000@ö!\\000O@‘\\\\Ğy\\000QÀ7‚Ğt\\000&IĞÄ0e<}Ú9ôJ@^2B½šÇşy€ï‡@óy\\000J\\000€‡ÀE=°œ\\000GÖøÖ€\\\"’~À3½€’Z™4Kµé»mİºœ5S;†ILOœvĞÏĞ4šÉSÜ]iiâQ:ÎxE)ø@×Ù8P: àÑK45Kàñ‰…Äè»@Ù››\\000@=M»Åyş	:G\\000œÇà@ÌP°(â›\\\
†)\\000E˜UıOC|ôJ ;\\000Šç\\\\£í\\000{9à\\000¼\\000î \\000Ë €o EiªÆ(ûŠ§!yŞ40‘&\\0000‹35K÷\\000v×jñK\\000xÀƒ‡€¯ÑI¿Ä\\000\\\" ®!\\000\\000À,µnİšÀºŠõ€q\",\
    [ \"sound/mino_O.dfpwm\" ] = \"ü¸\\r€%ëûı-\\000¨öö÷=\\000PÛİ»o\\000PÛíµï\\000 í¶­ß ®mk¿@muÛ~€Zkw÷\\r\\000ZÛvï\\000ªÖíŞ[\\000Xk···\\000°¶íŞŞ\\000P«ííï\\000Pmuïİ`Yu¿»@U{»{€Z»İ~\\000s­½÷€ªµö½\\r€*k÷î€T[»½7\\000©¶v÷^\\000RÛ¶Û;\\000ªv­oo\\000dµu÷m\\000TmºëÛ\\000Lõ¸íz”¶kûÑ°ZoÛï\\000jë]´ÖêÛ°êŞwHeu÷ş@[kû:`k ½5@Uwï¿@€Rmë}o \\000jµ{·€ÖöuÛ\\000Umïı\\000¨ZÛŞï\\r Úz»¬m_k¨ÕîŞ÷\\000ÀªZïîÔªÛ¶\\rh]»Ú­îîv\\000kµn»;P Öµ[PwÛ@« n»ím\\000Tm[Û×a;\\000U­¶Qßî5\\000T¥ºm¿ºÖ\\000`mk-ınw@«ê­~{İ\\000¶ëÙzkı\\000·Ö«é·}\\000Pİ­ï®÷€¨»«;»@·\\r îİz€v{€İîZ\\000µöîn\\000Ûn\\000U«»»û\\000®ªVİº·»\\000Q­®vİŞİ\\000¥ºV»õî€ªµ­õvj\\000µ¶¶uj·=\\000´¶V·8Ëí÷\\000 u­ğ­V÷}€ê´U½î§o\\000Ò®«õÖog\\0006kËëm»Ş\\000¸Ö­úZ_n\\000°n¯ª^ßÕ\\000`[_Õªş^w\\000Àº–[õ½o\\000À]«êt÷öÅ\\000@}«lõío}\\000\\000ÚŞ\\\\××{½\\000´Õ¹Ö÷{½\\000ÀÖêµí{·à\\000ÔjkÛ~ûÀ\\000µÕºk÷6@½ÀÖ6·å+Pkß\\000¨m«k]@oí5\\000\\\\Ûª+¡îëú\\000W«[Áõyµ×\\000pUkú{­=\\000Z®BÚo¯æz\\000«…¶ëõ©õö\\000 Jê·ºúõÖ\\000ZoU×Õ=\\000Ô[“ÕŞo{¶\\000€^«±½ís«\\000X«ª¿­§é½\\000Zko§ê]û/\\000@½­ªİş+Ë\\000ôx«ÜË}ıú\\000°-·Óõmï5\\000ôÎ\\000¸¶îÍm mskßàê¶\\000Tuõ­·­ß\\000\\000-­ku«çính\\000ª]ZWm¯Ş\\000z{ı\\000PÕU×P»^÷ºy€Óªs«­¶×ëõ\\000Èzš®ºÚ¾›Ô\\000¬Ó:^õ´¡ºüæ\\000´_m «~Õ¾¶v\\000 xµ£›õ—{uî\\000\\000ºäº­æj_nèÚ\\000j­õÔ^UøöÓk\\000pİªAníêoÓû\\r\\000°ĞÖ­u©×oö\\000¨òšÖí[oÛÕÛ+\\000\\000èS­­­÷oÛö=\\000ÀPwZkİz_ï^ ­\\000è®]]­Ş¯ĞÊ]û\\000õZË¶m°îZåÕû@­¶zP=­^kÛ¹v\\000À®5 ^×‡³ÏºW]\\\
\\000ô`º6ÙõZ×M¯G\\000\\000êUiOûnk½eoĞ\\000pSµúµİµ:ªò\\000ìª«~[½ÚEùÅ\\000\\000ouéuC×öä*_Ü\\000à­6­®âmŸuã•?\\000¸K§c«Üöj·¼ôg\\000\\000İêºx­v¾´›§ş\\000 ]]®UÇÍºóê\\000ĞÖëÑuÕèZ]¿yc\\000\\000´õzº[5®.Ûõ;\\000@[·›Ş¦Êë¢^ï\\000èÖne¯Ry}Òëı3\\000€İl«úJ¥Şuº\\000ÖN®Õ^id{Qõ¯ÀÖEk}§zZ¶\\\"ı\\000½ªHÚ÷öÃ*¨W•¯`¯Š`]¾¾htñòX€ö©l—/µ€.>\\\
à¼ªÃXèYµ-a[ãÏPº•vÃİ´xUOÄª¯u7Ô­U¯ô°ºNµ» «öÖê D·»©f@ÙV­®«\\000ÓªºÖ­\\000µ¶¶š¶€ª­¶šZV[mkYZmµ­U˜ÕÚ®VT®V·ªT­ªuWPu©u[PíRÖ®*´Uµ­2 µU­nIä¥ª[S@ë-ÊnUµu­z¨õ®ZÕU¡¶Ö»U5[AºkÒÖZY\\\
V¿ªU[\\\
¶¶»•*¨ÙĞ­¨ŞÚ¥Z\\000Úºk­­I @{µ­² µj]µ »Û–jh]Û6Ûª€Ö.íª‚V«ĞUƒÚ¶N­%€º¶mµ-i@×º­ª¶Z«µµZµÕhm[kÕT¨R·[U¨V«\\\
¤[T«Õj+\\r`­[U«V©* mWU©V]5 ÚÒªU­šj@íjUµªR«@j[U¥­U¬êK[¥U­ª\\000mkWUU+«¢ÛVWµ–VTC·µZµV\\\
X­\\rr­Z­*`m­Hmm%P­[­*P»*m[[5U V¡¶¶U6«ZÑzuemZÍlíEY«Ú*E\\\
Ô«VK»ÊŠ¬H¶K«é\\\
ÕÚ* ®mª*U[µJ[U+¥n¢­€ÚU©U[ÕªÔj«ªmj¶ª*¢®–µVÕ–ªÊ¶–ÕêRµJP»U­²µRµ°ÔÖZªl+UU Ùjm©ª®¥TÀÊVs5µªm!`ÕUkU«VÙ)€¶6µ«ªµªª\\000j¯VmUmUUH}Õeµj«ª\\\
¨ĞnkU­U«\\\
¤,È­­¬-­*ÈUVÛªjU-Èºª@ÚªUµ*²V­Ğ¶VU«ĞVe[´mZµ¨ZSµU@ÛªUÉVKËj°ÔªÅjUµªU´ÖJ­VµšZU@«U­jU«VUÔZ¶–jµªfUµZ­YµªªjPmÖVµT­ªVT­¶ÕR«ªj©ÕVmUU­¥ZP¶ÖjµªZ)kT›­ªµª–U­\\000Y·¬¶ZU«ªP[­ ·ª¶lUtU[i«i«VÀZ«U«ZUÓ\\\
(¤]ÕZU­VU-9¨[­ªUÕªV¶ZË€¶µªªY[µ´ªV«¶B­U­šVUÓª´ÚUUÓrUUU•j°´VÕªÊ¶H­jU\\r¨¶UÕ*Unª•V­* Ú–©V«j¥ªUÕª€²«UµªjS•Uª­€ÚªUÕ´ª¦ªÕÔ4’­-U-U«VµTµ´­©Ö¦J«ZU­*\\\
h×ZÕªZ©¶ªªª@µÛª­–ªVÕšªª@JQÛZM«U¥UU« ­ZT­Z­YUYU¡j«ªZ	²ÖVU­*ÕjUUÕª ­UK«*U­ªªªªY•ĞZUUZ­ªªªªªªZ\\\
­ViUÕª¬ªªªªªª¢´VU+Õªªªªªªª*´jUÕªªªªªªªªª’ªUU«ªªªªªªªªª¤VU5«ªJ«ªªªªª*UUUU«´ªªªÔÊRµRUUUU«ªªTSµ4ÕªRUUU­ªJU\",\
    [ \"lib/board.lua\" ] = \"-- generates a new board, on which polyominos can be placed and interact\\r\\\
local Board = {}\\r\\\
\\r\\\
local gameConfig = require \\\"config.gameconfig\\\"\\r\\\
\\r\\\
local stringrep = string.rep\\r\\\
local mathfloor = math.floor\\r\\\
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
function Board:AddGarbage(amount)\\r\\\
    if amount < 1 then return end\\r\\\
\\r\\\
    local changePercent = 00 -- higher the percent, the more likely it is that subsequent rows of garbage will have a different hole\\r\\\
    local holeX = math.random(1, self.width)\\r\\\
\\r\\\
    -- move board contents up\\r\\\
    for y = amount, self.height do\\r\\\
        self.contents[y - amount + 1] = self.contents[y]\\r\\\
    end\\r\\\
\\r\\\
    -- populate 'amount' bottom rows with fucking bullshit\\r\\\
    for y = self.height, self.height - amount + 1, -1 do\\r\\\
        self.contents[y] = stringrep(self.garbageColor, holeX - 1) .. \\\" \\\" .. stringrep(self.garbageColor, self.width - holeX)\\r\\\
        if math.random(1, 100) <= changePercent then\\r\\\
            holeX = math.random(1, self.width)\\r\\\
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
-- takes list of minos that it will render atop the board\\r\\\
function Board:Render(...)\\r\\\
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
	local topbound = (self.height - (self.visibleHeight + self.overtopHeight))\\r\\\
	local visibound = topbound + self.overtopHeight\\r\\\
\\r\\\
	for y = 1 + topbound, self.height, 3 do\\r\\\
--		colorLine1, colorLine2, colorLine3 = {}, {}, {}\\r\\\
        for x = 1, self.width do\\r\\\
            minoColor1, minoColor2, minoColor3 = nil, nil, nil\\r\\\
            for i = 1, #minos do\\r\\\
				mino = minos[i]\\r\\\
                if mino.visible then\\r\\\
\\r\\\
                    is_solid, mino_color = mino:CheckSolid(x, y + 0, true)\\r\\\
                    if is_solid then\\r\\\
                        minoColor1 = mino_color\\r\\\
                    end\\r\\\
\\r\\\
                    is_solid, mino_color = mino:CheckSolid(x, y + 1, true)\\r\\\
                    if is_solid then\\r\\\
                        minoColor2 = mino_color\\r\\\
                    end\\r\\\
\\r\\\
                    is_solid, mino_color = mino:CheckSolid(x, y + 2, true)\\r\\\
                    if is_solid then\\r\\\
                        minoColor3 = mino_color\\r\\\
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
        term.setCursorPos(self.x, self.y + tY)\\r\\\
        term.blit(charLine2, table.concat(colorLine1), table.concat(colorLine2))\\r\\\
        term.setCursorPos(self.x, self.y + tY + 1)\\r\\\
        term.blit(charLine1, table.concat(colorLine2), table.concat(colorLine3))\\r\\\
\\r\\\
		tY = tY + 2\\r\\\
    end\\r\\\
end\\r\\\
\\r\\\
return Board\\r\\\
\",\
    [ \"sound/lineclear.dfpwm\" ] = \"ÿ}æ@Îy8ğÿÏ zzà[\\000ú†õŸÔ¿U`°1ğŞ’êœ?†Rÿuş \\rG<âpÀ@ƒªå#ß÷y-[5X:!ÊÑ*¿‚:¯×„®ês”§á<qåA!Rém¿I/í¸~­â3´äQ ¼‚ÑÚú«©‚òhôŒÃÎQmA„Sõà¸S$%–¿:¦ÇqÔgœqÆ©sÇqÇq§£ãa³8NÇÇqœÃã”qqÇ,­89Ë4ÕÅØ8æ˜3e§¬•jœ™qœ£&Ë83U¬9ÆKZ35Î1Ö\\\\4Ç9Æs¸g\\\\Öqâ™cN‡--/¥ñ8|ğp¹¬xØ4Z–‡tƒ>Ñ\\r]êYøÜ'ª®p‹ê,ìJÔ[ ½…ÜZD{„º,­ªfÁã5H§Îc„}ÊQÕ;P²òe‹ò)NÓ;êº)«8†ğ^Üƒ¶@ò;Î)#G=DUÏ)%`«_w«Uš¦P\\\
²^(~G”¶_U•B½¢\\\\\\000—{É¿õÏï&/\\000Ñc]×]ÏúWº¦Àz,B(•¦-[W¡Ì²ï{ŸŠê˜â…2ÂëµşN[ıkŞ¥´	8‚/Tå¾æëH_\\\\×§,Çt a®}Xëœ Nã…²ØºW[W N™FÇyìiÇ1Î8c)ã”‡s¬NK5MMãp\\\\éá8:iå¸Œã˜–sÇitqÆ99œãXc¦qÆÇ²r)Çãœ1vÌ1Î13KÍ1Íª*Ç8cËrœc¦9åX\\rg§i§â8.5\\\\;Éc<<—Mf™q©iÃ)|R.¥V:µ¤q	Ã=¨N‡c©øQ±¥kà-4×\\\
û°-ª»\\rÊ7\\riİ(ª¶•z( ÿ£Àèw€u‡>#(ıj÷¼(¤ª]á\\\
hË*¨Ÿ>j„*ş·%$¦ã÷¦R(û^e¨ÀjómqT˜R»—^ÿ\\\"\\\
Òlû[×«‹!  ei¿•ö^%Íw\\000¨–ÂÔiTÿü5µŠ3¹Æf°Á`Ägh­ÿW¥Ä¼²BPªzŞzË êp­ï´ Õ[RJ|Ÿö°6K\\000ïj3¤‘‡{.èUh8×q´ç³$ÇÃW–æpqÆ1Ç±Åár8N‡Ó´J+‡ãtÇqÌ¬q–™e•sGÇGÇ‹cZÎ8ã”cãXji¬\\rç˜cå˜“S•Ã9.å8S¥YçX1ÇgtËËÒ²rLãtÊŒÇ±q)ÇÅqZé G/²ÃSqÉ£r|ğÁKËâÊ…ãCe^ÔEõ?à•uàşĞR5Ü‘¥#”OSô‰c¬‡¢[•,Óª-XÜ©Æ¤)şÔå1® W—orŞ@ø¿B(õV¶*ÁÖ:.®s$Ê{.I şÚq„x½ŠwŠu©¼w¸.áÒ2§y{„hm)×¹ôZ„¥¦´:©p¼+üy„W—€s¨.öœë¬¢LÃtÿ`Õéa’îyÏ1¸P‚ı{}¢òT	œ½®ä³K ÅÖ½¶ƒWL!Äò__Œ…V@~¨^ïCĞ«\\\"UÛ ùíZÕ>å j¤‡Xs¾/ü8œq†Ój8K\\r8Ï,‡1mñjz¯Â©qŒã,Ó,Ër8ÇÌ1N±jå8NKãXÕhœqÌáÌ1Î8s3Îq,USÇ4uÌ˜3Î8cå˜Ss´Fã”–ã”cU§)Ç™:œ8®8ut8<œébYÇ±qÅq™q:êáhºğâ¨V5:µ¨<åğ\\\"Ş8ñ˜äğ‡Jó’Ğ/„÷ºB_\\\
^zA;–5T7šê=àªU…üAªgU,êY¸¥á£å>0Ü*zÃğÔï`2:E½³H¥ç®+¬RU^ÿDº(ÇØçˆÒcc§ú‡îp•u¨¬Eªâ©ç!Ù·Œ!Oé,TøÛ}¨`°\\\
[/İq!öq{.#„çöL x]'w%DiäxW×jàp‘bÒóø:%èğU®!ÊÃUÂ¹NÊ:8¼/O‘(ÂßÇàq•¡«6e\\rí9+öy1ÚšKP¯:â6uÁyT¤ğ]J“ÎF¤ú‡ç8Vé7©¥åÇ9æ˜.œ#YÆq,kÆ©qñp¦†sœ)k±ÒsÇ²qjÆi4ÇÉcÌšcc–i\\\\UišãTcœ¹TÅs¸2ãâè¸Tã˜99Nq\\\\™¦G<¼hƒOcz8.K™®àqšãhOñŠÃGê\\r<Ü*U+ñ,é/u¡+ê‰nØ®ß*ñO1ÔÑğŒ:£Ë1Œûª÷^KZ©^p.…zÊáº‘Òñ»øÍaQ¼«HŸDªëSÿIÂÒêÊ#¤­£Z±÷°ê.P¶ŞZ@~ñŠ®Q‚wÑ4²»N VÇg¡Â;ÉO,*Z~;Rºp¸±î«a%ÀWñWÖö¨¨Ã€÷R¾t(Š{Å‘âŒWŞ.Æ:!©Æ7È{­\\\"Ê…Ï±cÄ÷˜­}F(Ó¬B|ÙÆe8^9#·µF1úÂíRë0@«¼:Î0ãŒsÊ9ŒãbËrÔ1ÎãÒ8ã8sŒYñXUÃq<f™iœiÆ™Ç1ç˜qZšã¨qœ9ÆœªñÇšié8fV9f•6œq•cs¦Å©rLÕÂ±Æq²<\\\\<N¯\\\\¸ÔŠ‹ƒ©‹.UCåÒ‘Õƒ99u˜½lÅÇp5…+ö~1ì½J|—«EÓ§d”ïÀ.Ñ>	ü*Ô¥XÛ F?BÕe¨}`ú½\\000-×7@ùVE¬¾Àf±¯È	ãËCueõ;ÅŸN‡1®Ey¤áZs	©rØõ†h\\\"åù§‰äïj5†9ÖëXQ¼½JË_9–TnY¸ÀWèfiş,¦NxµÖ…@{°§ã˜†«‚åŞ‚E4[éù„?€j×Ãä¿ çXÕ<îPywPO±F0Î·F5¹œBŞiòj1Ô¿„š7˜òŠŠX§$‡uø\\\\ğdãŒiÇ)Çr,ÎR®f•3ÇaÇ9cY.Î·Ì8Ç¬8Õ¢U9æ8\\\\cÏX3Í8+Î1fÕ˜ã˜ã8NåXSå;ZcÕcÌ1GÇ9ÊË)Ç±Êx+ãX96559ÎÁYÆ)mJ-–ã8å¡¥7<r%ºğğ†y†S--yØ8.®ğr £-¹R‰O7¨/Ô1=ŞùÄìb)æª-¡_”.¬o€µäºBZ‡Óbş‚Êk¤=‚õ=†rÔ7›¾€åº}I^F«Ô^Ó‡¯XCü+NP¼ÕYçé«\\\
~ßA¬ª^p¨×öE\\000êü;„PïZAyÙ[Rz¨ûj fıÀ]ÖÊàYQ®5KŞz‚½üNâ¸+`5Ç3+ƒÒ9ºK\\\
ñ^´£b²ß„£ÕbĞŞÓ8,GîÍG¥ëwS¼z¦0mwŒy¼œUÂºu,Œ5g9'cæ´85©ãT‡£Åqy8‡å˜3Ë4Ãs85N5Î4uŒeœÇŠgcZGcœcÆ§LË±Æ85òŒqeŒ+cSÆgÊŠ+§0w,æ+3eÇô0yŒSjSx¸RêAÇqi”ÇáñÇÉ)ÊÊ#Õ¢¥Ãº G;Š/Ô5,†å‰-è­R/àt…ÁODıºS‰½„_‚Ş:H]gpj¯0×$¹ƒúşäz£ ¯8Æt5©Î¡ÓQÎái4\\\\ËyÀ¶ÖA”ë‹PKù¯´?¥h¸n·éWO£PÎs uuÜV+ÜmWÅµì£—œ¶/®€rœ­â5\\\\ê÷\\\"à{ª+¤~«!š.ixŸĞ\\\\¤xz¡~\\ràlWÌ1­Û,¦XÔ§qoÒ@xEú‚ñ®ñ†â¨{°XOá¸¨¬çˆõÚ¡Ã‰ôn5p·*„IÇ[âÈKSÌ3G‹8Ç8+)ã˜UÒ¡¹\\\"ÇÑãğ(sÌ—Ã•3Î¤ãxÌbV.fÇ41Î8cš¥Æ1VÚ8Œc¥ÌârÇÌqÌeœÆUÉ4gL•CÇ8§iIÃ8±ñŒe¬±)g¬W8\\\\<N..Ór83Î±Ê±Ê‡³ôHÇYœá¥²†<t…y,‡.µh\\\\_á„®L£/\\rú‰ROR÷ l±,¼…Ø'¼¢R;…ÎQE·Ğ;Q\\\\#F}õ)’|/X,,¥Fù%ãT6L—u0Iµ:H¿)„nÅR/é“dã+Ğ-}ÒÚå t~ZŞšDÊz4mRí{(ô\\\
}Y‹î ô(ùR”]år£i{§b‘äµ•FÚÔ.Ô8/7hØ^BÁò5é{ËbÔ©ZjåPçHÕ7¤r\\\
u^ˆŒ5n‹QN™W‰İ‹ÂËàZa¹ÊqoM{™V,ÔµÊ¬6È)ÇÒ2feªá±ÔbšVœÆSFÇRÕ˜j¥i–jq¥q49-ºx,Fñ,ŠcL9Æ’£Ô£Y%ç(SÍ1§Ê±RË¸t,ËQ®Ô1ª•jYšcN²eÌ™KËQ6-Ó*Ó©²Ô´âhçh²Zq•¥U.¼HÇ©§L.Ë8êXqj•×¨5Zìb¥–<rñQ/´ÒäTSe:j9rYeY©\\\\e<:rÉxÁ^Æ²Ê¤/EÛ¢Vc¬§P^U¦±åzÖ4tòHuT-™;,Æ9–J«Ô*M+­TÎ‹šÊ5š6¥ãÒ¬4¶qRUs,K3ÖLSËÒQU+'V5-¶¬bMKUÕŠÖ²”¶F£lM5ÒqÕdxÒjÑ®¢ªæ¸²¸ZTÕJ«Òj4Nªk™ÈUÓÉ8Vi–iVe­U¬9´¬4¶¬JåÒ,³8+«X­JµtÑRÕr*UËlTÖJµ4LV­¬²¸Ì”§,U•£Yq¥•eœfš‡”Vœ¥©UU¹X¦f5œJ­UÓ±T-5Í¸ÔÌ²,¥YÆªj<é˜Å¥©–f9Vg™j–¥–ešÆ¥Vi–¥•ešVY™š¥ãXd9¦š–¥š\\\\6VZZ–qe™Sji–¥ii©i–¦¦YZÆ©–•e™¦Ošf™–¥V¦–™¥eš¦e©Yf\",\
    [ \"README.md\" ] = \"# LDRIS version 2\\\
Modern (to-be) multiplayer tetris for ComputerCraft. (Work in progress)\\\
\\\
### Current features:\\\
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
- Fix garbage collector-related slowdown when played in CraftOS-PC\\\
- Refactor code to look prettier\\\
- Add score, and let line clears and piece dropping add to it\\\
- Implement initial hold and initial rotation\\\
- Add an actual menu, and not the crap that LDRIS 1 had\\\
- Implement proper Multiplayer (aiming for modem-only for now)\\\
- Implement arcade features (proper kiosk mode, krist integration)\\\
- Add touchscreen-friendly controls for CraftOS-PC Mobile\\\
- Cheese race mode\\\
- Add in-game menu for changing controls (some people can actually tolerate guideline)\\\
\",\
    [ \"sound/drop.dfpwm\" ] = \"|xx<ÂÏp|Ä8®xtxæ#cŸ!ñÏáñphÇ<zx|tÊşÂpçt<ÇÀãjÇ‡¬ğçÄpşÇç\\000Çñı1¾£‹Ëø€ø¼aŞÃ!˜6G¼†áÈcå¡¤ïp©Â+Œ‡ñG­xyœåj‡;,æpÃ1Ç)a‹qåpLhWiLã¨VÕ*GÑápWkÑRYœêñç`\\\\”ÃmğŠ×P1œËb,Ï1JiÅÇeqh•s)s8•£”g¹ÔáP>[ºá8GYic9ËVjGexçÕ4”vieTQVOé¨‚÷œ¥¨QM¯™pÎã8†s,òu\\rµèÈ;“4Úã9–RZÕ¥*g8åğšÒ5*Eg-¯!Œ¶¨[S)ËúxƒZ<†:çyÄ—mùÃóğŒÏ:×Ñ˜zÃEUÇP­€…B0nËÓQ<‹]ZÖp¾Ã©Şs}8¯‡»4ßËªp5¤…ÃY£°xcyéåyKÇg¼Æ¥(¨éÔJ‰Á*“2\\ra)Ír\\\\†JiTè*İYCáôZG7âq×3Æñ´êNçX\\\
ûº\\\\ËÒ3<ÇutxªÆbxNùá¨ÆáWóğáyˆÏ¾ñxæğ8Ç§òx<ƒã08F2<á8äÁU)Çã8ã0Vãqã:Çq8‡ã0Ã6<–ãÅÇqK'=çáqÃ%>g9:Öá\\\\–¥ÓxåpÇr(§pÃQªRU)‡Ëã=Óxq\\\\ky«Ç×:½<>ÕÃ;NË£¦¢à0–RÇY\\\\üğ”¥ÅÃq¶–ÑÑÑq¥Æq<rp‡15¦±¤Ãqª‡§¾pñ¨Æã8ñG]œÇÅâ1º¢KÇñLËC«8Zj©âx¨•ÇcU98ÏªÆ).Å:xÇá—4šÅñ8q8ãaUËñ8/<ÕÃãªÓÃãi<\\\\¦åI«4«q5×xôáJ‡§UÍÓZªâ±ŒÇ8Qá85Åq4‹G£*5‡£±*U<ËRËáxT-šVåá±/.U¹èp4-Ëi.ãq\\\\ã8ãIãRÇãÎñ¸ªUÖhY¥i4UiÔRYÕÅƒ—­xxš––Ã¥*—ÒIËFµ´,‡Ãã¡‹–­´ÔÔ8<VUMÇc<Nãe«<×â8—«Ãáh5*©IY*‡ã°beZ<šã²§¹¬áqÆc«q9²Ëi¥e9–e,ÇÑ,­²—Yšæxœ¥U-­eÇ£V6.ËjéâT¥Ãã8Nå’£i:\\\\r´â¢Ãq§UUã4jé¸äÒq²†ÇJÕT¥ñp§¥SKÓè²\\\\J=ºxé8Ãi<§§išVÕxtÅe-—cÓátªN5Õ2Çãñh5ãXÙRUÇádi\\\\,•F‡£ŠN9<ÇÊÅr8ã¸JsxœV:ªÃãT«4Õqš¦ã)—Çiø0£e¹¨QIÃã4ÇÈÑ¨ŒG‹ãRNVŸNUmğ8ÆÃÁãpG.[jjt²šgi¹,NÇ)\\rµp<ÖğĞá8–f:Îr8+UÅã±…YÎr¸ÔÆ±hép–c©ƒ+ê¸ŠÃãX•¦â1Ó˜‡K-FÃâpœGËéC«òp¬<\\\\,§ÑR‡«<Óñpf©\\\\jhU¥Z‡ãXÕq<Õ\\\
GÁLëáxÓ8œ–¥Ç©ªúàĞ’r<Ç±4Fñp‡ce¹XY©ÇqÇqY—¦År†Ó:®\\\\MÇå¸NÑ•·›]tÒR<Në¦á8M¥Åã8¥šêĞQiÅXÄ±6ãhª†EUÓ’ãiŒ†±hK\\\\e©Å2‹±X¦é¸œª§ª,K5â8–R5Õ²ªJÕ8Ç\\\"-«4UUUU¹4MÓTU5UUMãÒ4UK55ÕTÍ²,ÍÒÊÒ²,MÓ\",\
    [ \"sound/mino_Z.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000]a\\000\\000\\000\\000\\000\\000\\\"Êvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000]a\\000\\000\\000\\000\\00027òDÿÿÿÿÿÿÿÿÿÿÿÿšvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000€ \\\
Æ€ĞU\\000\\000\\000\\000BˆFÆP§”—‚…GÄP‡óPjé xJaÉ˜ôkBß{Ï½÷Ş{ 4d\\000\\000\\000@bà1	B¡Å	Qœ)Ba9	–r:	B÷ „.çŞrî½÷\\rY\\000\\000\\0000!„B!„B\\\
)¥RŠ)¦˜bÊ1ÇsÌ1È ƒ:è¤“N2©¤“2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊcŒ1ÆcŒ1ÆcŒ1ÆBCV\\000 \\000\\000„AdB!…RŠ)¦sÌ1Ç€ĞU\\000\\000 \\000€\\000\\000\\000\\000G‘É‘É‘$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û—}ÛwuÙ·}ÙvuY—eYwm[—uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9’#)’„†¬\\000d\\000\\000\\000à(â8’#9–cI–¤IšåYåi&j¢„†¬\\000\\000\\000\\000\\000\\000\\000\\000 (Šâ(#I–¥išç©(Š¦ªª¢iªªªš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš@hÈ*\\000@\\000@ÇqÇQÇqÉ‘$	\\rY\\000È\\000\\000\\000ÀPG‘Ë±$ÍÒ,Ïò4Ñ3=W”MİÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ€ĞU\\000\\000\\000\\000 ˆB†1 4d\\000\\000\\000€¢‘1Ô)%Á¥`!Ä1Ô!ä<”Z:RX2&=Å„Â÷Şsï½÷\\rY\\000\\000\\000FƒxL‚B(FqBg\\\
‚BXN‚¥œ‡N‚Ğ=!„Ë¹·œ{ï½BCV\\000€\\000\\000B!„B!„BJ)…”bŠ)¦˜rÌ1Çs2È ƒ:é¤“L*é¤£L2ê(µ–RK1Å[n1ÖZkÍ9÷”2ÆcŒ1ÆcŒ1ÆcŒ1‚ĞU\\000\\000\\000\\000aA„BH!…”bŠ)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I’,É’4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeİÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäHŠ¤\\000¡!«\\000\\000\\000\\000\\0008Š£8äHåX’%i’fy–gyš§‰šè¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(Š¢8ŠãH’eišæyª'Š¢©ªªhšªªª¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš&²\\\
\\000\\000\\000ĞqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000€\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç“<É³<Çs<É“4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000€ Ç´ƒ$	„ ‚äÄÄ¤… ‚ä:%Åä!§ bä9É˜Aä‚ÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥“9ç¤tR¡¥Rg©´ZbÌ(•ÚR­\\r„RH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,„BCV\\000Q\\000\\000„1H)¤bŒ9ÈDŒ1èd†1!sNAÇ…T*uPRÃsA¨ ƒT:G•ƒPRG\\000\\000€\\000\\000€\\000¡Ğ@œ\\000€A’4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUİvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×•eÓumÙue[WeYø5U•eÓumÙt]ÙveW·UYÖmÑu}]•eá7eÙ÷e[×}Y·•at]ÛWeY÷MY~Ù–…İÕu_˜DQU=U•]QU]×t][W]×¶5Õ”]ÓumÙT]YVeY÷]WÖuMUeÙ”eÛ6]W–UYöuW–u[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}U–u_Öua˜uÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_•máXeÙøuá–[×…ßs]_WmÙVÙ6†İ÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^İ6êÆO¸ß¨©ª¯›®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VY†Õ–…aÖuaÙ…a©Úº2¼ºo¯­+ÃíßW†ªmË«ÛÂ0û¶ğÛÂo»±3\\000\\0008\\000\\000˜P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEU•eÕ•eYu]]MÓ•EÕteÓT]Yu]WV]W–%M3MÍóLSó<Ó4UÓ•MSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓ–MS•eÓUmÙUeW–]Ù¶MU•eS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨š²kšªl«ªª»²kë¾,Ë¶,ªªëš®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï™¦,›ª)Û¦ªÊ²,»¶mË²/Œ¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À€\\000@€	e Ğ•\\000@\\000\\000`cŒAh”rÎ9RÎ9!sB©dÎA¡¤Ì9¥¤”9¡””B¥¤ÔZ¡””Z+\\000\\000 À\\000 ÀM‰Å\\\
\\rY	\\000¤\\000GÓLÓueÙËEU•eÛ6†Å²DQUeÙ¶…cEU•eÛÖu4QTUY¶mİWSUeÙ¶}]82UU–m[×}#U–m[×…¡’*Ë¶më¾QI¶m]7†ã¨$Û¶îû¾q,ñ…¡°,•ğ•_8*\\000\\000ğ\\000 VG8),4d%\\000\\000\\000¤”QJ)£”RJ)Æ”RŒ	\\000\\000p\\000\\0000¡²\\\"\\000ˆ\\000\\000œsÎ9çœsÎ9çœsÎ9çœsÎ9çcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1Æ\\000ìD8\\000ìDX…†¬\\000Â\\000\\000„‚’R)¥”9ç¤”RJ)¥”ÈA¥”RJ)¥DÒI)¥”RJ)¥qPJ)¥”RJ)¡”RJ)¥”RJ	¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ\\000&\\000P	6Î°’tV8\\\\hÈJ\\000 7\\000\\000PŠ9Æ$”JH%„Jå„ÎI	)µVB\\\
­„\\\
:h£RK­•”JI™„B(¡„RZ)%µR2¡„PJ!¥RJ	¡ePB\\\
%””RI-´TJÉ „PZ	©•ÔZ\\\
%•”A)©„’R*­µ”JJ­ƒÒR)­µÖJJ!•–R¥¤–R)¥µJk­µNR)-¤ÖRk­•VJ)¥”JI­µ–Zk)¥VB)­´ÒZ)%µÖRk-•ÔZK­¥ÖRk­¥ÖJ)%¥–Zk­µ–Z*)µ”B)¥•’Bj©¥ÖJ*-„ĞRI¥•VZk)¥”J(%•”Z*©µ–Rh¥…ÒJI%¥–J*)¥ÔR*¡”R*¡•ÔRk©¥–J*-µÔR+©”–JJ©\\000\\000tà\\000\\000`D¥…ØiÆ•GàˆB†	(\\000\\000\\000ˆ™@ \\000\\\
d\\000ÀB‚\\000PX`(]è‚\\\"HA\\\\8qã‰NèĞ\\000ˆ™\\000¡\\\"$dÀE…t\\000°¸À(]è‚\\\"HA\\\\8qã‰NèĞ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\†ÆG‡ÇHˆ\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000€OggS\\000]%\\000\\000\\000\\000\\000\\000]a\\000\\000\\000\\000\\000æ`idBIPOVKZINO?O@AJA;AWV¡«‰O£ŠÍAàb¼-à-\\000Îx€h`3ïõ<íÒŞÚOŞıÑFˆµIW\\r€­¡F\\r¼äÚÓ€Ş{	@½½_ŠõŠ<ŞbÀJÀúæÏ,¼µƒsU.j‘†\\000u<)©å	\\000r­«I§ŸÚl·/\\000J\\000\\000.\\000\\000\\000šµÆ\\000°ä¢\\000¢@àüÊ\\000€ë(`x€³\\000tù€W\\000³?Ú\\r\\000r¯«eû|*Õ“j¸\\000XY@€-\\000\\000Àˆ\\000‚¬\\000HuÚ\\000hï\\000\\000\\\\9z \\000¶\\000À@Å Àçû$¨€B9\\000R£¶Ó>ğ²”ĞÚ¤N\\000à\\rÎuĞ.¬ëúİ~ÿÿ÷Ìš\\000f]ÓuÜ<ì|ûå_e™İ;3»ÀøX\\000ÏìêÔÛ’ €ÄùM\\000¸¸*\\000f§‹©e Ç\\\\ĞGú„K\\000 HDUµ÷6YîÇó»·xĞH\\000ˆÆ“aÂdù6°¡;\\000 9†í±’…puè8qÄjøD<h;\\\\Cû€	\\000v£ˆèoL¸\\000ı³Ğ\\000]<=À\\000{èßşÇ;0jk£X\\000\\000NÿùS…KÂ‚åĞ‡€³\\000(k|\\r²ÃâQwtª&¤ù€•\\000^¡à\\000ºÚá/éù.ğÔ€%Lİ­	cjİ¯#Á`2ƒ€å¿\\\
\\000`_í]	àç\\\"\\000kO°¾ÑH_ˆ+>6Š›ñ›EyĞÊÓù‡\\000RV›ëÁ4Áá–«ìcŒ¬µò_¥øÿÒ_·ÔÃvNn&nFJ¹õÿªıyZ˜àÿ¶\\\
à/‹ËÛ€S\\r%p\\\"úƒá:Kb”œF}®AÉ°‘	 n¥\\\"ï„&$'ÆÕ\\000\\000n?\\\"\\000£U\\000\\000\\r€ß\\\
È\\000\\\"×8@öÒ%\\000×_ïQ\\000\\000¾ğh„Hùê‡VcĞÁèéABÔ¡À\\000j£T—™)’,xô»;Ê\\000*\\000\\000ØÖ\\\
P©¦yºÂäĞ'H 6`À\\000xy€oÊ\\000Ô¾¡ºˆ+Ã:ğ‚_Ñ\\\" ÇC˜\\000V—^óP5H>@—2Oè€t@ Y¶š˜\\\"n_Êëö\\000T·ğ¨¨ÑË\\000láb`k0.à7\\\
ckøÀåš¯AƒÚª£3Õ *‰[àQ§¥ì‹nŸ\\000ì¶„±B*í•ÚãĞ&ôa\\000Lş: X x	°N0˜e,©á zbøÀrB€¦\\000¬§’0µÀËY)ØUuš5R¤æ­¯ß›´4‚ğ¢\\000L_Àí8\\000ä‹©KÀŞÆ*Übì'¸6ìÔ-\\rä\\\
ê–$Ô­àë°°zÍÊÁø\\000&5 «N\\000%‘ÊÁ†jdÿh`{ûp-üÇÌ–?¦aE’‡ÏaÛãe‚¶Œ\\\\À¾À\\000&5 {<@™¥`!´f@~öK*HÀ¿\\000ú5`‹\\000 ì4:9@[X'9ŒÇ‰C ÛáQë u€rar\\000{}PÀÎ€w{¶°Ùªuk”[vFÌßÃ,ß\\000ZÃÅ›E€–M.Â˜ôh9NKxÛ’ƒ²±Æ:Q®ë1ñ°9_Ó»İÆ\\000\\\"¨¦/¢‰‰±Àè•S·—eY´mš[KóK:_|\\\"l	\\000ğ*ÀW€Î˜ƒqá\\\
„j(P 2}Ò[G…&ş=º\\000V†P\\000ÜŞª¸µÑ¤ÕH\\000PP\\000|“\\000ƒ\\rğ:4xÆ€	âÃ€A£)\\000y•”³‚\\\"=Àú,Ç††ÄÀ»li;òÆT	<a<¨\\000|`, \\\
ø†MØğ\\r.!!_5º\\000[€´‹èMò\\000ëR2şÈR³¨öû²|Y®[êÁ@Ÿ¿ÈG'bıô¸®uŸqüëy€ŸæÁò2pÛ8ï\\ràÍÖŞÍú°ğî™$6¨BÇU/­«°Ab\\\\\\000\",\
    [ \"sound/lineclear.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000µ}\\000\\000\\000\\000\\000\\000[…yvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000µ}\\000\\000\\000\\000\\000˜}/èDÿÿÿÿÿÿÿÿÿÿÿÿšvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000€ \\\
Æ€ĞU\\000\\000\\000\\000BˆFÆP§”—‚…GÄP‡óPjé xJaÉ˜ôkBß{Ï½÷Ş{ 4d\\000\\000\\000@bà1	B¡Å	Qœ)Ba9	–r:	B÷ „.çŞrî½÷\\rY\\000\\000\\0000!„B!„B\\\
)¥RŠ)¦˜bÊ1ÇsÌ1È ƒ:è¤“N2©¤“2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊcŒ1ÆcŒ1ÆcŒ1ÆBCV\\000 \\000\\000„AdB!…RŠ)¦sÌ1Ç€ĞU\\000\\000 \\000€\\000\\000\\000\\000G‘É‘É‘$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û—}ÛwuÙ·}ÙvuY—eYwm[—uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9’#)’„†¬\\000d\\000\\000\\000à(â8’#9–cI–¤IšåYåi&j¢„†¬\\000\\000\\000\\000\\000\\000\\000\\000 (Šâ(#I–¥išç©(Š¦ªª¢iªªªš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš@hÈ*\\000@\\000@ÇqÇQÇqÉ‘$	\\rY\\000È\\000\\000\\000ÀPG‘Ë±$ÍÒ,Ïò4Ñ3=W”MİÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ€ĞU\\000\\000\\000\\000 ˆB†1 4d\\000\\000\\000€¢‘1Ô)%Á¥`!Ä1Ô!ä<”Z:RX2&=Å„Â÷Şsï½÷\\rY\\000\\000\\000FƒxL‚B(FqBg\\\
‚BXN‚¥œ‡N‚Ğ=!„Ë¹·œ{ï½BCV\\000€\\000\\000B!„B!„BJ)…”bŠ)¦˜rÌ1Çs2È ƒ:é¤“L*é¤£L2ê(µ–RK1Å[n1ÖZkÍ9÷”2ÆcŒ1ÆcŒ1ÆcŒ1‚ĞU\\000\\000\\000\\000aA„BH!…”bŠ)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I’,É’4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeİÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäHŠ¤\\000¡!«\\000\\000\\000\\000\\0008Š£8äHåX’%i’fy–gyš§‰šè¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(Š¢8ŠãH’eišæyª'Š¢©ªªhšªªª¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš&²\\\
\\000\\000\\000ĞqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000€\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç“<É³<Çs<É“4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000€ Ç´ƒ$	„ ‚äÄÄ¤… ‚ä:%Åä!§ bä9É˜Aä‚ÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥“9ç¤tR¡¥Rg©´ZbÌ(•ÚR­\\r„RH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,„BCV\\000Q\\000\\000„1H)¤bŒ9ÈDŒ1èd†1!sNAÇ…T*uPRÃsA¨ ƒT:G•ƒPRG\\000\\000€\\000\\000€\\000¡Ğ@œ\\000€A’4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUİvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×•eÓumÙue[WeYø5U•eÓumÙt]ÙveW·UYÖmÑu}]•eá7eÙ÷e[×}Y·•at]ÛWeY÷MY~Ù–…İÕu_˜DQU=U•]QU]×t][W]×¶5Õ”]ÓumÙT]YVeY÷]WÖuMUeÙ”eÛ6]W–UYöuW–u[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}U–u_Öua˜uÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_•máXeÙøuá–[×…ßs]_WmÙVÙ6†İ÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^İ6êÆO¸ß¨©ª¯›®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VY†Õ–…aÖuaÙ…a©Úº2¼ºo¯­+ÃíßW†ªmË«ÛÂ0û¶ğÛÂo»±3\\000\\0008\\000\\000˜P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEU•eÕ•eYu]]MÓ•EÕteÓT]Yu]WV]W–%M3MÍóLSó<Ó4UÓ•MSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓ–MS•eÓUmÙUeW–]Ù¶MU•eS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨š²kšªl«ªª»²kë¾,Ë¶,ªªëš®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï™¦,›ª)Û¦ªÊ²,»¶mË²/Œ¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À€\\000@€	e Ğ•\\000@\\000\\000`cŒAh”rÎ9RÎ9!sB©dÎA¡¤Ì9¥¤”9¡””B¥¤ÔZ¡””Z+\\000\\000 À\\000 ÀM‰Å\\\
\\rY	\\000¤\\000GÓLÓueÙËEU•eÛ6†Å²DQUeÙ¶…cEU•eÛÖu4QTUY¶mİWSUeÙ¶}]82UU–m[×}#U–m[×…¡’*Ë¶më¾QI¶m]7†ã¨$Û¶îû¾q,ñ…¡°,•ğ•_8*\\000\\000ğ\\000 VG8),4d%\\000\\000\\000¤”QJ)£”RJ)Æ”RŒ	\\000\\000p\\000\\0000¡²\\\"\\000ˆ\\000\\000œsÎ9çœsÎ9çœsÎ9çœsÎ9çcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1Æ\\000ìD8\\000ìDX…†¬\\000Â\\000\\000„‚’R)¥”9ç¤”RJ)¥”ÈA¥”RJ)¥DÒI)¥”RJ)¥qPJ)¥”RJ)¡”RJ)¥”RJ	¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ\\000&\\000P	6Î°’tV8\\\\hÈJ\\000 7\\000\\000PŠ9Æ$”JH%„Jå„ÎI	)µVB\\\
­„\\\
:h£RK­•”JI™„B(¡„RZ)%µR2¡„PJ!¥RJ	¡ePB\\\
%””RI-´TJÉ „PZ	©•ÔZ\\\
%•”A)©„’R*­µ”JJ­ƒÒR)­µÖJJ!•–R¥¤–R)¥µJk­µNR)-¤ÖRk­•VJ)¥”JI­µ–Zk)¥VB)­´ÒZ)%µÖRk-•ÔZK­¥ÖRk­¥ÖJ)%¥–Zk­µ–Z*)µ”B)¥•’Bj©¥ÖJ*-„ĞRI¥•VZk)¥”J(%•”Z*©µ–Rh¥…ÒJI%¥–J*)¥ÔR*¡”R*¡•ÔRk©¥–J*-µÔR+©”–JJ©\\000\\000tà\\000\\000`D¥…ØiÆ•GàˆB†	(\\000\\000\\000ˆ™@ \\000\\\
d\\000ÀB‚\\000PX`(]è‚\\\"HA\\\\8qã‰NèĞ\\000ˆ™\\000¡\\\"$dÀE…t\\000°¸À(]è‚\\\"HA\\\\8qã‰NèĞ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\†ÆG‡ÇHˆ\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000€OggS\\000â6\\000\\000\\000\\000\\000\\000µ}\\000\\000\\000\\000\\000Æ³btx{txuxly€nzxwuqmjOYZQ`UWV\\\\YQF·SâM‘ĞµLXõÄ™ÍêRJÙ×õËk›skV÷+ûºè¶C˜îÑç6M.4Ru]¯ş‘cesnMjş¿)âÊŸ¬|à¦Ååà¿eëtP&Sß)fì8ÈæÍÖ0|l|7\\\"BÜ Egb±ı @¬dYÕ©O…ïªnÇ‘™\\\
\\000À¿.…Ò™ıñËµız>½|õ0låè±¬/ºé9†ªaË¸4Eûê°ªe¡=œŞÆŞîj­pg®RÔTŞD¶ƒ³uÿF\\\
&ğ‘ÁÍÿ#ı3æ†\\\\<g\\r\\\\]Æx¾\\000a‹?»ó¯©´9t¯t˜·8B7~£³\\000&Ç‡12	 :%K)¥”ƒ»Sö¿ûÿâñ‹WUşûtg¼²ä4ÿ{ñ_fîŠ\\\\tåíiÊÚÜ†Ç:È—SÉå3¿©P©W¿N›Tl!Á‚‹®I…Š¾yŠ’x¥’ŞÍšö¹Å1’IsIO’©ØI—	^®V½â@<PE^¥¥ÄJ)K­ó¿Ò¸51ı¼…×õæñ<åN…§±Å£yÇ[\\\"‡»G”bãOn±ÒÁ	TK˜~,ñ#)EÌFszvO²I‹µã¾êìÍä­Ğ$5~Hh©ÍF¯ä¯UjÙ˜œÆe¨bH!¢RË–™:\\000ªÏf¥ÌJ±ÓÍë¯êWªL—_uù²XSSƒrı*YõÓ–|A¦+äy—ØW½£ÿ‘i«È@W\\\"‚IJ”bì“_¹Tö¢S_:1\\\"¿ûcª\\rGª,ùÓ³¶J$rûû£®¦ùÑ§G·*˜‡ª“lj.Ô2¯‰Èa§´ÄJ–’¤ùË7ÇŸ~ã×¯¿ïãŸU•;Äöu˜Är{Ez!‡¢KöŠ.‡Ÿe!áYL“¨Åï\\\"£T[—œ³k¯Ål­Ãf[t&¥c®¥ïéå®‹ß»ºYÄ‡31çT‚®oµ*ñQ¡ıĞ»ÊÓş¢Ö6Á[‰94‘-æP×	§´.eVxZRÅ··YÛ´íu?nBœßŒóÃ5†Œ/_#ªqV”›<®@3DiVèÂ¶¢Áy6YÃC;UÅ$’BÑŞLTšhé³Vc¾46³š{°Ei¹R)Å²Æ¡é½v7®PTä¸±·b»=ë½\\000äP}F_Já{ñÈËªê¢xûRÔÏYI\\\\ö²&×ÆüüL‹8•'Pú‰9˜ĞÑ<¢.QÛZné£¾dİ]èzıÃÓÜ¼´NÀØÛ‹(•İ¶€§4o{Hø5ü<}İ‚Ë9ñ$=³\\rB.­ÛB˜\\000©’Öb\\\"gô¼”RHñ¼şİ¿›oË«wˆÌç©0æ+©î'îİÃõUûz;’¢PIWêÓ7½æ:ß51XúÙ‹hŞx²›4—7ce•ÄÌíîŒoìÒSŠYaÎ±ö?õœ‹ï—:3Lá€I|äÂ5\\\"»Så•Pá4–«JÎJ)%×í›íZïÙÿ¶OÇN¯¿\\\
SØØÉ_¾Ó–Ô[ñÙç›8†ìÎY÷œê$¿y›'¬öÌbˆÔŞ{şgLduøşP'Ù1¯¿[ÏšJMuiwÑı= ?üê¥¾qÑèw­{y3û}†¿-¤Wô³ì¯àw\\000RÂğ$mKÉYf‘·ãéÓ¾Ş»ùy¢<,¸M2&o!¨•$¶Ô±µİóXy‰âÊCŸ”â\\rj—Ò#ŠÂ·g¾*#æ$ìY|{¯-Wi¢×{£3ûîòÊÑL%I±˜^3™éÒ:Û&¯	ÕÀÃ³ŠS=R ”>K)%Õï¿üï©şÇı[S3OU¿dßÈn7æã£GŠëSCö9Z0øOÂÊ½bÊ‹ÚÂ+Ê®×oÜÔLÊÿ}´IÿúeêÇ\\000•ú³KİÛA®Xòš‰éI`­7e\\\"ò¿·‹Ié?+L,C£³…¤À!pùTŸŸ•RJ™âz:_uóÕX¿òÊü¥óüÖåÍû°^zêçsÓ¼)Ìóííñyİ•?¾Ü£rl”pÍÔÖ:¸òyK\\r#õ”• ş[Œ®;¢‰œkÕz:g×QSÈSŸíN2tÛÏ¡SB!‰€fš¶“à\\000›‡ˆç\\000 ÂCbx›vúRJ)³,ÿpŞ~ÑÄİÒøl[¬õ¼Y(_îó×±¸Vs!¯7Cêírqª\\\"d)f¾`fc­³b¾}¸™”rø	èlUİUH­íZà	»H\\\
t^»°¯ÓiUÒæ\\\\Tç4j.Ì¶tÈ\\r±«†\\\\\\\
@„Ç.yÔ‰Y]J))u_·IGÙoYú|7wë4SŒ®>ñÓ1‹¦ÿİ‚GQëz½.® ¡(ñğº÷‹;ç®V1§‰Ï±ÑZÈÆñÑÍ:KŞúL}©Û:“c[QC—&Ó:öëoÑñËNèğKo:Ÿ« ”P½ú¬”’%{+Gİùã¿Úõ^]àÎÿ?ù(›uä‹ë½Qßv~l2KÂş¼™şÒÀj«”hòÎL/5Í{@Õ%²¾³\\\\X¤Î]­‹ Ç·Ã™šAO @d¯ë©˜9¶Ã®sµZ\\\\YT££ÛÆî\\000”ğ¨„³Ï’Eåy¿¤7ÏóoÉ×İpüÚÙÈ°-ëË•J¬õNCÎ+ù¬bã5Ã‡ê¯_‹‰Å	6[+·	|aÑÒ×4¯ØÆjæJ»§TRÂ818÷÷çğ™õ\\\\×2rÚP‰4«&z^ªz „ê3^JÉ4]öQÙ•¿åİÂÙÅ½ì\\rá³Z«°ı«‡Ç<¯Eøçşÿ{?¸j\\\\d,ÅíZ¦ò.Ğß0Ğ9O`:Fë~¢î•²Á«g4¿½?Úƒê%üÇÚ³ïÔ´sy™«@„‡lj\\000³T•6{÷\\\\şk5bîÊU«ï¾œÜíS Gœ÷:ÒàLÒ…µ‰Î$qx(NwËÎÑõiKñnJ%=&zÎÃ­“àS…Õg)Oİ/Ô…Ã#åƒ¾-´Qñ©'Ñ’WäIÕ¬kÍ—f‹Ë<²ğ¶ÏKPÀf\\rÿ-ûP¯™Î¢7úØ˜ê1×=°ÍrÌ®Pù.,0øb¾€Ÿ¨ğ‡ŠG¦g<çF‚RM•t¾åºÏŞõ“”‘'–Êä:){Õ’ç¯“ª•ºº=•;”¥sŞÿ˜¢•\\000\\r¹±h¼Y5Á67[ü°n*ïÌÂ(<¬«è6À•}ğŸ\\000øí“4˜©*Û-»²4ÍòmMcçZ÷¬0rSHOó‰+òìl¯Aü¨»·HA•kı´]!AèPˆcŞ=\\\\az¡§ÿ‡¡_d\\r¨d!-¤¥Â{ğfªSšYTs\\\\G¾.ı¼üQYÙ‡ª\\rT÷ÙjvbõuL\\r*ó¦¡¦ªÿ´­‡s\\\"L‰ƒ´wB…Ñº:\\000ù|©±RjˆæGÑ[›n.ûÒY»“}Š”>†ÙËº±f‘šú3ğ‹	g|„âgªÎ,·<]ı±ÅçhV\\r!Ç\\\\Nû1X²ù]®®úZ}HObÕùİîw‚m‘^DÀ\\\
Z¹9™¶èœ^œ—xÂ”`M¿¢hpM•\\\"\\00088£­1\\000}jÑÔ¤îmÿWÍQıÂtÉÓÊ¿ÖÉx/Ì‰\\\"æÀG›DTz}»‚€İ yÜ7Ui[½gã2h5÷Fñ­(}Š4)ßLó*òöÁ•ªğ`<œ™›#Q=¹*ßq¦<¿–&nñ[lÓ¢“ëqİB‹z³3Ÿ.1ëÊ¨uM¦¶VâD,‹Å¤)èš-˜M”É²¡Sœm€NI¼ä›#Ï5gM§Âô‘Lúi\\000y\\000ÕÏ>€Tu¹åÿ3]¾ækÓêù…±?÷M…(Ü^o®­N¡p‹£ºxÛP1µ'Fóâa6û|ñ¨˜K’?À+\\\"µ3,‰AOl{¯`t5Ï¢ã:©b‘†{c\\000öYryÊÇİ³ç»Uy·ÏéTY®ºÉŒl1Yæ&xFîD½•İÕöQ-¤l°©R\\0004{„”+pÆ	½wº3b#r+l½„qĞäBã4MÀ¼#\\000ogYEkhhõYáÉ™Ø)Îgçç×_1­5Ùº\\\\3XßˆMæŒjŞqE°HbÑ~ƒùÅT\\000ïÌ*0ÛI\\000¤= ³I³‚ÕÆ—5h\\000\",\
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
    [ \"sound/mino_T.dfpwm\" ] = \"€ÿõà9\\000@-LÿÿÛvE\\000¬\\\
\\000Tÿ¯¨fÙª¦rÙúÿ°ª\\000Ô¢ùÿÿjmk\\000\\000•JªÿVÒÿ[\\000jZUu[Uu…\\000\\000ıjıßUí\\000\\000©¦”ößÿ­+ ª\\000è­Ò4	ø+µ¤êÿw U\\000¨”åÿ«¶Ö(\\000RJı¯T©ÿ VÕTù ÕV\\000–ò¿Òÿ5[W\\000 b’TÿSÿ¯j\\000êJUø¯²TUğ¿¢Êú«\\r\\000@U”Rìÿµæ\\\
€¶\\000 Êÿª*Óúå*•¥ÿ@¶Ê\\000P%Êÿü¿iu]\\000¨DTù_ªşoPÕR•ß”Ê­\\000ğT«ÿ[5\\000\\000¤LJ)şÿ¯º®\\000T«ÀüWU©rÁ+Õj-õÿ\\000´\\000Ê’•ÿÿ[«U\\000PU)ÿWZü\\000TVM~j©ª\\000€ÕÿÍôÕµr\\000\\000T•ªò¿ú¿©\\000­+\\r€ÿ²ªª\\\"€ÿ•XZÿÛ*\\000Vª*QQıÿKWhÀªú/y*ê¢I–]òo@M¢=PY´ı”¤]\\rÖ\\000U¯ŞYşb÷\\000ÀEU%@åÿÅşik\\000\\000PM¢õÿ©6\\000U5\\000ú_©UIà[©ªöÿ\\000K J*ÿÿç¶­\\000@QÅÿRUÿP«V£?`²R $ÿ›ÿm[Õ\\000PšJşµÿU@Uµøk«T*€•ªşÕ\\000(\\000¥$©úÿÏµe\\000U\\000¤ú¯J­úTU©ëÿ\\000VÕ\\000€ªüïÿ5ÛV\\000(ª¤ÿfş¯P5U\\rŞJ[*\\000ÿ«*ÿ¯¶\\000€*R*ÿÿ·ª€VPşW©Ê,Ö*•nşP5\\000”Råÿ«­j\\000\\000HUù_ªêÿ\\000T­Zõ–VZ€úåÿµÖ*\\000\\000*UÒÿù¿UP«\\\
€ÿªª²øk•©ÿ¯\\\
@	€R©Rÿÿ«Y\\r\\000@ªş—Z©€j¥ÚşP«\\000¬Èÿş_­ÛR\\000€DJõ¿Ôÿ«\\000ªªÒ€¿Rk¥\\000à¿ªêÿks\\000\\000PE*ÕÿÿÕª°\\000Tÿ¥ªÊj-©©ÿ\\000µ\\\
@™bÿÿ—ª²\\000 «*ı•Tÿ[\\000ÕZKZ-ªä\\000êÿ’ı7Ñ¦\\000[Y]é§—Ê§€vY@êO¥:7zt—ß¥`ÍP	Uîÿ«jÿ/@\\000”–¤üÿ[µ¨\\000ú·¥h+]ó Z ”üû¿^¯\\000 IÔ¿Öÿ- ˜JîÚZW\\000üJÙÿm·€\\000¤$%ÿÿÚV©şµT¥eeUeÿ7\\000©Sêÿßªu\\000PRùkUÿ¨ª©ê(SU\\000ôêÿU­\\000(¥Ôÿ«[€´*€¿ªJ+àW­ªÿ×\\000T\\000¨X‘ÿ[k\\000%ıW­ú¤©¤şZ­@Åù¿µn\\000H’òßüß T¥À·ª¶\\\
€%åÿÖ\\\
(\\000©\\\"¥ÿ¿Õ6€ª\\000’+Õê¡ªªRÿ@Õ\\000¨RşÿWUÛ\\000bEı+åT«–ÉšTj@ş¯ú_u\\000€D•ÒÿÿV\\rPMĞ¿Êª*xUêÌÿ@5\\000¨¤òÿ¿µj\\000@)ÿ­ÖÿªR-@­¥\\000Hù·ş_mk\\000Š¤üÛÿ](U\\ràw5kğU©êu@\\\
ˆD¥ÔÿoÛ*@\\r@ÊoÕªı RU«ÿ\\000UU\\000TÔ¿ÿÛfÕ\\000@I)ıVım•ªµ°Y–ªè¯ªügt«jûÿT*€6Pû+WÑ–RmĞò?‚]P+[ş‡µ;Px­L°†mÖiã?I–Tô^‘¾–ŸX@ñvX¼V¤Ï@¢¯¥¦±}U'=(€@êu+ı/EÿP$7Uä'êÖĞÑ;aÔoÆ¶HPE½ğªÿ~j\\rjY¢şËT1©Á])w’ô¯ ­p«hYÿ/I\\rm-€‚Õk±ÿR’üW\\000mE«¥~$¥VÍ\\000ÚªMõOJ©2\\000èÚªšúW~E\\\
PÛ2´_-•JUÀ¯ÒÂ´¿*\\\" ®À¢–•jÿSiä‚‚J\\reÙöõ¨Òô¤R­¤õ¥PÊkU,éš¼ÉNªj²*Ä¡Wº›6 a¥êMĞä¯êô§¢\\000hU¿tû÷EÒB€Vm€ı«%e*àSÕ(ûO@K@­WUÿ¯U%ª­×¿\\\
UÿJ«–«RİVPİ©_…Ô²€nÕª¥¿\\\"	`­i~-ei	Ğ_)©ı«¨\\000V µµJÿ_’Ò%€µ€ÖúO•RıAU¶Iõ VmêªÿÒ/U„Õ\\000 ­®ô_Jÿ’XÕZ®%5µĞ¿I¥IZZ»µŠÿ¯H¥\\\
 ^¸ş6ªRUZéR•ü/j`í¢ìÿU¢’4@ m©ıWAû[€ª‹uõ‘Re[ÔıUä¯‚–\\000´Ö­Ò¿~tÒ¶à¯©š”|Uµ’•Ğ\\\
°­ZÕÿ+¡ ´UÿSJª?¨*µäşª’+@¥î¿úS\\\
iG\\000¨µ«öOõ¯€ªúEÀ¯jU-\\000ı[%õÕ\\\"€ÚÖ*éÿ[’*´*Àê)Uj$UMUÿ	T©\\\
¨¶j¿¥\\000jWµşÉŸ`k!U]ZU¥ Õ_·ô]P•¡]®Ôòê·*•\\\"´)‘ëW-²JS•õ¦vIB­\\000­ºRïÒo»$~*Tz{âıW¢VÔ ¡şK%ŞZÕäúTUØbıëGªª\\000u«ô_Ö¯ e«¯Ü,@¥Ô”: P×ÒZÿ/IÍ\\000ÕµªJ©M¦ª*ı+€¶º-õÿŠ$U@ÛjùO)ÔV-õ@©ª¨÷WñJÑ@×ºÔ¿~’P­à¯TÉZàK5UI´@µvµÿK©RÔUÿj%ıR­*ı«šTİú*%T\\000m-ùWı%\\\
PÕVÀo*©À_¥ÖTT ºk«ÿ—TQ\\000¶ v)5åCÑNZÿ²•\\000m+ÿ}Ra…\\000P·Êı-é5kÔeU‹¶\\000Õ%û+	5\\000h­Uÿõ“T	P²úWUj%¼*Sê_	P+ ¶®úI©J€¶µ¿J©UV«~¨Ú¬\\000V÷W~)©Ê\\000P[«úk¿°V\\rğ«2¥øUUñ/I@mkõÿ’-@T×¿’ªşPY©–ß@¥Ú@zí_¯!eT\\000j—;}—~¥€X­Zx­j“ÈUJu­ª†’ÚZ*ë:¥T*U­TµUSU•ZV¥jU¥ª©V¥¥ZU\",\
    [ \"ldris2.lua\" ] = \"local _AMOUNT_OF_GAMES = 1\\\
local _PRINT_DEBUG_INFO = false\\\
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
Last update: April 18th 2025\\\
\\\
Current features:\\\
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
+ Implement DFPWM audio so that real sound effects work in CC:Tweaked\\\
+ Try to further mitigate any garbage collector-related slowdown in CraftOS-PC\\\
+ Refactor code to look prettier\\\
+ Add score, and let line clears and piece dropping add to it\\\
+ Implement initial hold and initial rotation\\\
+ Improve menu drastically\\\
+ Implement proper Multiplayer (aiming for modem-only for now)\\\
+ Implement arcade features (proper kiosk mode, krist integration)\\\
+ Add touchscreen-friendly controls for CraftOS-PC Mobile\\\
+ Cheese race mode\\\
+ 40-line Sprint mode\\\
+ Add in-game menu for changing controls (some people can actually tolerate guideline)\\\
]]\\\
\\\
-- if my indenting is fucked, I blame zed's default settings'\\\
\\\
local scr_x, scr_y = term.getSize()\\\
\\\
local Board = require \\\"lib.board\\\"\\\
local Mino = require \\\"lib.mino\\\"\\\
local GameInstance = require \\\"lib.gameinstance\\\"\\\
local Control = require \\\"lib.control\\\"\\\
local GameDebug = require \\\"lib.gamedebug\\\"\\\
local Menu = require \\\"lib.menu\\\"\\\
local cospc_debuglog = GameDebug.cospc_debuglog\\\
local clientConfig = require \\\"config.clientconfig\\\" -- client config can be changed however you please\\\
local gameConfig = require \\\"config.gameconfig\\\"     -- ideally, only clients with IDENTICAL game configs should face one another\\\
gameConfig.kickTables = require \\\"lib.kicktables\\\"\\\
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
	if game.control.native_control and _PRINT_DEBUG_INFO then\\\
		local mino = game.state.mino\\\
		\\\
		term.setCursorPos(18, scr_y - 1)\\\
		term.write(\\\"Combo: \\\" .. game.state.combo .. \\\"      \\\")\\\
\\\
		term.setCursorPos(2, scr_y - 1)\\\
		term.write(\\\"M=\\\" .. mino.movesLeft .. \\\", TtL=\\\" .. tostring(mino.lockTimer):sub(1, 4) .. \\\"  \\\")\\\
\\\
		term.setCursorPos(2, scr_y - 0)\\\
		term.write(\\\"POS=(\\\" .. mino.x .. \\\":\\\" .. tostring(mino.xFloat):sub(1, 5) .. \\\", \\\" .. mino.y .. \\\":\\\" .. tostring(mino.yFloat):sub(1, 5) .. \\\")      \\\")\\\
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
	term.setCursorPos(sx / 2 - #text / 2, y or (sy / 2))\\\
	term.write(text)\\\
	term.setTextColor(color)\\\
end\\\
\\\
local function WIPscreen(message)\\\
	term.clear()\\\
	cwrite(message, 3, colors.white)\\\
	sleep(0.25)\\\
	cwrite(\\\"Press any key to continue\\\", 6, colors.lightGray)\\\
	os.pullEvent(\\\"key\\\")\\\
	sleep(0.1)\\\
	term.clear()\\\
end\\\
\\\
local function startGame()\\\
\\\
		cospc_debuglog(2, \\\"Starting game.\\\")\\\
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
		while true do\\\
				doResume = true\\\
				evt = { os.pullEvent() }\\\
				\\\
				if _PRINT_DEBUG_INFO then\\\
					term.setCursorPos(1, 1)\\\
					term.write(\\\"t=\\\" .. tostring(resume_count) .. \\\"  \\\")\\\
\\\
					term.setCursorPos(20, 1)\\\
					term.write(\\\"evt=\\\" .. tostring(evt[1]) .. \\\"   \\\")\\\
					term.setCursorPos(32, 1)\\\
					term.write(tostring(evt[2]) .. \\\"                    \\\")\\\
					\\\
					write_debug_stuff(GAMES[player_number])\\\
				end\\\
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
						player_number = (player_number % #GAMES) + 1\\\
						for i, _GAME in ipairs(GAMES) do\\\
							_GAME.control:Clear()\\\
							_GAME.control.native_control = (i == player_number)\\\
						end\\\
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
--								message = GameDebug.profile(\\\"Game \\\" .. i, i + 1, function() return (GAME:Resume(evt, doTick) or {}) end)\\\
								message = GAME:Resume(evt, doTick) or {}\\\
\\\
								-- restart game after topout\\\
								if message.gameover then\\\
										cospc_debuglog(i, \\\"Game over!\\\")\\\
										GAME:Initiate(nil, last_epoch)\\\
								end\\\
								\\\
								-- quit game\\\
								if message.quit then\\\
									return\\\
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
												if _i ~= i then\\\
														_GAME:ReceiveGarbage(message.attack)\\\
												end\\\
										end\\\
								end\\\
						end\\\
						\\\
						frame_time = os.epoch(\\\"utc\\\") - last_epoch\\\
						if _PRINT_DEBUG_INFO or (frame_time > 200) then\\\
							term.setCursorPos(10, 1)\\\
							term.write(\\\"ft=\\\" .. tostring(frame_time) .. \\\"ms  \\\")\\\
						end\\\
				end\\\
				\\\
				GameDebug.broadcast(GAMES)\\\
		end\\\
end\\\
\\\
local function titleScreen()\\\
	term.clear()\\\
	local control = Control:New(clientConfig, true)\\\
\\\
	local mainmenu = Menu:New(2, 2)\\\
	mainmenu:SetTitle(\\\"LDRIS 2\\\", 1)\\\
	mainmenu:AddOption(\\\"Marathon\\\", 1, 3)\\\
	mainmenu:AddOption(\\\"Multiplayer (Modem)\\\", 1, 4)\\\
	mainmenu:AddOption(\\\"Modes\\\", 1, 5)\\\
	mainmenu:AddOption(\\\"Options\\\", 1, 6)\\\
	mainmenu:AddOption(\\\"Quit\\\", 1, 8)\\\
	mainmenu.selected = 1\\\
	mainmenu.cursor = {\\\"O \\\", \\\"@ \\\"}\\\
	mainmenu.cursor_blink = 0.05\\\
\\\
	local modemenu = Menu:New(10, 5)\\\
	modemenu:SetTitle(\\\"\\\")\\\
	modemenu:AddOption(\\\"Cheese Race\\\", 1, 1)	-- infinite garbage of a particular height\\\
	modemenu:AddOption(\\\"40-line Sprint\\\", 1, 2)\\\
	modemenu:AddOption(\\\"Some other shit idk\\\", 1, 3)\\\
	\\\
	local evt\\\
	local tickTimer = os.startTimer(0.05)\\\
	while true do\\\
		mainmenu:Render()\\\
		for k, v in pairs(control.keysDown) do\\\
			control.keysDown[k] = 1 + v\\\
		end\\\
		evt = {os.pullEvent()}\\\
		control:Resume(evt)\\\
\\\
		if evt[1] == \\\"timer\\\" and evt[2] == tickTimer then\\\
			tickTimer = os.startTimer(0.05)\\\
		end\\\
\\\
		if control:CheckControl(\\\"menu_up\\\") then\\\
			mainmenu:MoveSelect(-1)\\\
\\\
		elseif control:CheckControl(\\\"menu_down\\\") then\\\
			mainmenu:MoveSelect(1)\\\
\\\
		elseif control:CheckControl(\\\"menu_select\\\") then\\\
			if mainmenu.selected == 1 then\\\
				startGame()\\\
\\\
			elseif mainmenu.selected == 2 then\\\
				WIPscreen(\\\"Multiplayer will be implemented later!\\\")\\\
\\\
			elseif mainmenu.selected == 3 then\\\
				WIPscreen(\\\"Other modes will be added later!\\\")\\\
\\\
			elseif mainmenu.selected == 4 then\\\
				WIPscreen(\\\"Options will be added later! Really\\\")\\\
\\\
			elseif mainmenu.selected == 5 then\\\
				return\\\
			end\\\
\\\
			term.clear()\\\
			tickTimer = os.startTimer(0.05)\\\
\\\
		elseif control:CheckControl(\\\"quit\\\") then\\\
			return\\\
		end\\\
	end\\\
end\\\
\\\
term.clear()\\\
\\\
cospc_debuglog(nil, 0)\\\
cospc_debuglog(nil, \\\"Opened LDRIS2.\\\")\\\
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
local success, err_message = pcall(titleScreen)\\\
\\\
for i = 1, 16 do\\\
		term.setPaletteColor(2 ^ (i - 1), table.unpack(original_palette[i]))\\\
end\\\
math.randomseed(table.unpack(original_randomseed))\\\
\\\
if not success then\\\
		error(err_message)\\\
end\\\
\\\
cospc_debuglog(nil, \\\"Closed LDRIS2.\\\")\\\
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
    [ \"sound/mino_L.dfpwm\" ] = \"[Òıÿ?’J@İÿÿÿÿ¶A\\000\\000ADªíî½İ­¦$’ªJµ»­\\\"’@\\000Dª{ÿÿÿßkI\\000\\000 ’R÷ûÿ¾·¥D\\\"‰TÕÚ­ªRJR©İ­ıÿïJB\\000\\000\\000A”Úşÿÿßm+	@Bjİîv»UUI¤Rµív7‰H@\\000iíşÿÿßm•\\000\\000\\000’Ô¶ÿ~ïnUI’$©ÕÖV•B’Ôîİÿşß•D\\000\\000\\000„$Õşûÿ÷¶•$BD$Õ¶Ûjm•RJÕjû{·\\000@\\000Õvÿÿÿï¶\\000‚HjíŞww×*ERª”jm­’R\\000\\\"µïûÿïßU\\000\\000$UïÿßÛJ’‘ˆ¤Ô¶[UU)I©{­şÿİ\\\
A\\000\\000Tíşÿÿw[K BHÖ¶»ív«JITUÕn·5‚$\\000\\000$uïşÿÿw[%\\000\\000\\000D’Ôîïß»ÛJ’H’DªVÛZ©$’$Õ}oÿÿw\\000\\000Iµÿÿÿïn•D@@‘ªİmÛ¶UJ)¥ªöîí–„\\000€@jÛûÿÿßµ*\\000\\000\\000‚$Õöş¾»[•$Q*IÕ¶¶*% RÚ}ïÿ¿•D\\000\\000\\000D’ª÷ÿÿ¾[•$‚QÕv[­Z¥¤R[k÷ÿ]%\\000\\000ˆTÛÿÿÿw[K\\000 ’j»½»ÛUUI”ªRkÛV\\\"I\\000\\000’ÚûşÿßU	\\000\\000H’j÷ï®*‰H\\\"‘TÕv×ªIéŞmÿÿ½’ˆ\\000\\000\\000!Iõşÿÿw[•@ „HmÛmm[U*%UÕêŞwKQ\\000©6ûÿÿÿw\\000\\000\\000$¥îÿÿÿİ­D\\000\\000„HÕİï¿·V•”’$U[ÛZµ$\\000I$©ûÿÿûïÖ*A€\\000@$Uµíî½ï»Ûn«\\000\\000‚Hµ½ÿÿÿİZ%‘¤j­m«*¥¤Tµ½÷ş}[J\\000\\000\\000’Tõşÿÿï]KB BDªÚvw×ª*%IRÕª¶ûîn•$B@ ‘ªvÿÿşwm«\\\"‘jÛn·İ¶U¥$RU•ºÛ¾@)\\000\\000‚Ô}ïÿÿş½­J\\000\\000 $Iªİ÷ïİ­’$’$©jm»U)	!’Tßİÿo!\\000\\000 HRµÿÿÿïİV	!\\\"©m»kk»ª¤”¤ªÚş»m+!\\000€¶İıÿÿïnk	\\000€ \\\"¥µİï»»[U‰RIRµ­mU©\\000\\\"Jİß÷ÿßW%\\\"\\000\\000\\000D’Tûşÿï»[U’BD$©Úv[U­*I)é¶îşÛ–@\\000\\000 UÛşÿÿÿn[K@\\000„©Z·{÷î¶ª’HR•Rmİ¶)\\000@¤ºï÷ÿÿı¶*	\\000\\000@)¥íşû÷n[%!\\\"‘¤j»»Ûª*\\\"\\\"©Ú¶ıï÷V%\\000‘TµûûÿŞµª„ !IU¹¿wwÕ*%‘U[Û¿»Û&D!@DIzıîïİ­\\\
„¥î¶ß{{İ*• ˆ(¨ªjûí½nI’ˆHJU»­íî¶ªH$‰¤Tkk»»ÛZ•”$IRRUµjkÛZUªRI©TU­ZmµZ•J¥”R©ªU«­µVU©RI©TUU«Z«VUUU¥JUeUUUµªªªª*UUUU­ªªjU©ªRU¥ªVU«ªªZ©ªJUUUUUUUÕªªJ­ªªTµªªJUµªJUUUUUµªªªªªª*UUUUUUU«ªªªªªª*UUUUU5«ªªªª*UUUUÕªªªªªÊTUUUUUU5«2«ªª²*UKUUUUÓ¬ªªÒÒ,KUUU«ªª*«¬²TUUSUµTUUµªªJUUUUU­ªªTUUUUUU«ªªªªTM­ªTU«ªªªÊªªªRUUUUÕªªªªª¬JUUÕªªªRUUÕªªªJUUUUUU«ªªªª*UUUUUUUUUUÕªªªªªTUUÕªªªªªTUUUUUµªªªªªªªªÊTUU­ªªRUU­ªªª*UUUUU­ªªªª*UUUUUUU­ªRµªªª*UUUµªªªJUUUUUUµªªªªªªªJU¥ªjUmÛUI’”ªÖJIíî÷n·’$\\\"¡Èjİ÷ÚµZ•’$QUUU[«*¥J\\\"¥µí¶»m­JD$DhÙmïw{­T!„ERÕ¶í¶*•RªTÛZÕvk%Bˆ¤Öî~ïö¶\\\"!BPªªİ½ÛZUKIJRUÕZ­U%©$IJm·Û{ïv%	‘¤mÛ½÷mWU\\\"IUªª¶¶ZªRJ¥jÛÖÚÖV%\\\"Bˆ¤mmß··[)IUUÛî¶ªª*©TU«jk­J‘$I’Rív÷Ş×­$IDAQµîİİmÕR’D’ªªZ­µJ•J’RkÛ¶ÛµÕA…¨­Û}ß^W¥\\\"(\\\"©ZÛn[Uª”J•µZmÛZ%‰Dˆ”Rkwï{×[I\\\"‚ Š¤Õöîn«U•”$©ªªÕjU•TIRªj·íîÖªR$‚ ŠÈ¶m÷Ş×­J!‘ªTUÛÚVU©”*ÕÚZmm­’H$\\\"RUÛ¶û¾İm’$$\\\"RUÕºİ¶ªj¥”RUµª­ªª$)I)¥u»íŞ®•’AE¤¶îîî¶Z©$\\\"IU•Zk­–ªJ’ªªmkÛ¶Ö$‘!(ÕÚÚû^_«’„HDR•jm·kUU)•ªjUµµV¥$‰$¥Tm·İ»Û*IIA\\\"’Vw»ÛV«*IIRUUµV«R©’”RkÛ¶Û¶ZJAEÔ¶íŞ½w«”H’¤T¥Z[[«*•R¥jm­ÚÖª’$‘ˆRUÛ¶{w[•’$\\\"\\\"©ªZ»İV­ªJ)•RÕªµj•RJUU%UµÖnmm­BD!u·û»½»JDH©ZÛİ÷õnK’H’ª”ÚÖVUUJI­Vµİ÷u«¦\\\"‘‘””Õ¶¶µmkÛZU*µ”H„\\\"\\\"©m÷{}w·E‰ !‘ÚÚvÛ¶ª$¥T•ZÛ­m«J$\\\"„ ‘´İîıöv›¥ªVkwÛ¶ª¤””*Um­j­µª”$¥$¥Tµ¶µİn[U))I\\\"IJU­¶m[«UUUJ%¥ªUUµZU¥T•¤¤jmkÛn­V¥$‘HJµÖÚn·ÛªªJIIUªªÖjµV©J¥ªªj­U­­V*II’$UU­µ»Û¶U•R\\\"I’¤ªªÖ¶­UÕª*•ªRÕªªUUU%•JI•ªµmm·µZ*¥$\\\"IRUµÖ¶m[«ªª”¤”ªªÊªU­ªTU)UU«µVkµª*%%IRªªÖjm»¶VU©¤$¥”ªªªµÖZUVU©*U­ªªV«T¥R©Tªªª­µ¶ÖZ©R)%I)UU­µµV«ªªJ¥R©UUU­ªª*U¥JUµZµÖªUU¥RJJ©ÒªU«­µZU©J)•ªªªªV­ZU©ªRU©VUÕªVUU©*U©ªªªU­ªUUUª*UUªUUU­ªªªªªJUUUUµªªªªJUUUUUµªªªªªªRUUUUUU«ªªªªªJUUUUUU­ªªªªJUUUUµªªªªªJUUUUUU­ªªªªªJUUUUU­ªªª*UU53UÍªªªªªªLUUUUUUU³ªªªªªªªRUU\",\
    [ \"lib/gamedebug.lua\" ] = \"local GameDebug = {}\\\
\\\
local _WRITE_TO_DEBUG_MONITOR = false\\\
\\\
function GameDebug.cospc_debuglog(header, text)\\\
	-- ccemux itself doesn't have virtual monitor support\\\
	if _HOST:find(\\\"CCEmuX\\\") then\\\
		return\\\
	end\\\
\\\
	if _WRITE_TO_DEBUG_MONITOR then\\\
		if ccemux then\\\
			if not peripheral.find(\\\"monitor\\\") then\\\
				ccemux.attach(\\\"right\\\", \\\"monitor\\\")\\\
			end\\\
			local t = term.redirect(peripheral.wrap(\\\"right\\\"))\\\
			if text == 0 then\\\
				term.clear()\\\
				term.setCursorPos(1, 1)\\\
			else\\\
				term.setTextColor(colors.yellow)\\\
				term.write(header or \\\"SYS\\\")\\\
				term.setTextColor(colors.white)\\\
				print(\\\": \\\" .. text)\\\
			end\\\
			term.redirect(t)\\\
		end\\\
	end\\\
end\\\
\\\
\\\
local modem = peripheral.find(\\\"modem\\\")\\\
if (not modem) and (ccemux) then\\\
	ccemux.attach(\\\"top\\\", \\\"wireless_modem\\\")\\\
	modem = peripheral.wrap(\\\"modem\\\")\\\
end\\\
\\\
function GameDebug.broadcast(message)\\\
	if modem then\\\
		modem.transmit(100, 100, message)\\\
	end\\\
end\\\
\\\
function GameDebug.profile(fName, y, func, ...)\\\
	local time_start = os.epoch(\\\"utc\\\")\\\
	term.setCursorPos(1, y)\\\
	term.write(fName .. \\\": \\\" .. \\\"load          \\\")\\\
	local output = func(...)\\\
	local time_total = os.epoch(\\\"utc\\\") - time_start\\\
	term.setCursorPos(1, y)\\\
	term.write(fName .. \\\": \\\" .. tostring(time_total) .. \\\"    \\\")\\\
	return output\\\
end\\\
\\\
return GameDebug\\\
\",\
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
    [ \"sound/mino_I.dfpwm\" ] = \"Àÿ\\000ãüsÀ9şÀü¬ñLyÀÏ~`šz–áÖ|ÀSıhå8s`Ÿ*úÀªú¨Âlõ€Ç,üa¸ª¡Uø«èQE?¬õ\\000—Zø£/pÕA?ªø\\\
W]àQ…¿XÓjøG]Ğ•C?Tñk]àQ~±Ê<s´‡)^áš½Èâ®:ÀS\\r±Ê¼êàU¼Â«z”Ñ/V¹€§ş¢J¼ê Rú +øXÑ¬t€G;şBÖX«C‹Vı€Ûòø¢[¬t€ß8¼ë/´F ËôKC‹ğå7ô*ª:ü‚Z…êƒ®Ò{€SµÀúb;ø&¨–¨/•†ö…¦ÕğCÕĞ~Ñ~¼JtMƒ¿€§é	õ¡iğ[ğª^‚<ªú[Ã—ÀKõ@ıĞ4øMx*B/ª…ş\\\
WÑĞSyĞ}±*|	z*/hUÃ·‚WéèQ¹ğ]¸*>=•‡º‡JÉWà«tAú¤(ı:)? 7ÉË/‡–úàsÕ@ZıĞ.ÂR¨íuââ}¼2=P¿RIGµtEùÒ«+&õ=À¶ğÒV’ö…Õ…ytiú\\rU¾ò¤é!¢/U-ô¯àRå$}TyPï\\\
'¿ôØò@z«,¾áªæ#H­*ØïÀ¥¦O úXyP½…V¿\\\"ôÒâê/ª,ú+à+Ã$?´:è÷€K‹/ú²rP{­\\\
}èYãêšZôW «Ê}´ªĞW‚^%ô™6 ÿà^} !ıAŒ?P½néˆ‡î\\000ıXUiË,Ïı«ˆZÌ£ˆú¬ãA×Z=Uñ—€ê‹Ni¡º»@¯*ôK\\\
é£©|€ö7ÂK.újô…*? Õ~d•ú¯ü(ËˆÄoX«üİ\\\"œªÅ/è/TéBZ÷^kğ¯@ä+uA¬{ÁU\\réwàU~HÿP•êßx™Æo„{´¢#jï\\\
:Õ¢·*«ôRû«jĞ¿¤µ>…(ôë<Ğû êRİHÿ Güj…U5Éj|êàôã# ıÃ$ı¶\\000Gµ^h/®µÀ}+x•áWüRÊjû„S~%Hjº€êœåàwxšÑ“ˆ|ÑŠ½mÁK\\r¿Ñ+y İXÕè«ziÓÒöÂ•‚~7ÀÇ_BÔU5èŞ\\\
¼´øE û¤Òí·ÀZC_%èÇ”B½­ô¯=Uù‚ {Q«ı+p•Ê/ÕÇ*è~V½'È~pô@ÕVxæˆı.àQÇ\\000üÅ9üŸ‚»^Á×BxîømÀo…¶ û\\\
QéëG^¿\\000õ*í\\000ê¬<ø]!«ÊEU-øtğK_IşQâ¡ÛLZ_\\\"´e«n/¸*ôVˆ§%—Tõpª±[/-/í£â¢~4-]‰ĞK-õ^°VøM@Ÿ¤şPÕâw=U>€úCÕAş\\r¸ªøà—ª\\rô;hUñ_• ßB«¡o¼ı\\000ô“•‚ï«Ğvğ\\\"èéXºr´X>+Ğ¯Åé«Ê#| ü!iÕ+‘º_ _tê§Ë*òbéÀ!½Pº&èo½[£¡ê£%ø¯à4~¬–nÑ—À«ÒDûÒPüJx©>B>*E·†—ÊÄÇdá~±R|tZ´/ª†w	WëéQÕğopU|\\000½”í«ÂÁ§åö¡TøMx*?@¥÷†KåàKéPQü\\\"¼ª©VC×rõJ}à¯0:^­ê\\rå›ÄOxAñ¦:üCœ>£/FûÇXjá•_`Û@÷h…Uğ‹†Û¼â]øÓ]1ªD¹‹F¾Ğ¥Ä¿på	”ºèG]-ĞT‡¼Jñ	o9¡eşp–uÑO%^Â“zTá®j‹şb•xêĞ«xÁUô¨â7¬é€—ıQ•xÕÂ/ªøBkô¨Êœé€N5ş¢ŠxÕÁªôBWøTÅ_Xå€®:üÁJğÔAªø…«è±F?4å¯ZôC•ñ¬…^Ôø§äe•o¨Ò!5ôE•^ğTƒ>ªò…V-èeohê\\\"jØ‹*¯Ğª…^ªò\\\
«ZèSJwhê^Uh'[®àª†>ªÒÖ:ÄSna¥½¤ØG5^ÁÑ:m¡oq„«ş‘èK˜v¡N[\\\\à¥ûˆâ-õS?ªã+yO!^ƒü‚¨²i‰.ô£‚^(¾E W$úU÷`'6ªì/Ğµö©>ÔšbÉOTöö%AŸ¨Í‡TëMå@÷:\\\
¬ôŠô'‹¸}­€+‹øBì¢%=„Ú7hG\\\\·­ÔÊ/Pº_œ„“í®ÂHú‹4ÒA_)á1«¢ÖMÈ\\rıDÂbZú-,tÁ«àÔÕH¯Å5ìVO	½ê]ŠzP¯pÊ±k Û¥ÒÙ¾‚•¼U@—}!¤-ñ¨oôRÑ\\\"îQ\\\"º]«\\r_IO5º Û”jÑ[\\\
ºªâ&²î Ê“¼U «]\\\"µ/¥ZT¯%¬Zt›ˆö”ñ…Èµ šC{’°×—’ÚªÔ{A]jøT{ªá¢Ö¨ìE»ô'Šª®AW²W:¹øB”_ŠSÈ÷$ôÔÅJ}K¤[ÅÍƒkxUhKtNW5pÒõ´]ª°İ‚%Gw²Z9dUÃ§D¿zEy‰ô%İªÂÒµ	U[¼YĞ[ƒ–”o…¼¬Ò‘U+V[)åR«m;Tšt[B«¥KRu­hÔµŠ¦š®$viÕ„¶¦»*ÑiSEéZUYôªD§ª+‘^UYÑÖ\\\
«œ®uYe‰m+jšºJÑ¥ª“d»T©t[›–L[™VIg•–ªv‰èÕh¡u5Z¶4YÊ&Í+JWMÕ«ÖF«¨mÔtªT+-{Öª¦\\\"k«¤­ªUÔ%i-UÕœª¤]…¶Ê–¤­RåªÒªl‰º*UÕZJV›”-Õ)Õ%UÕªÔ´Z¢­R-Õ–T«*UKµR­QµÔªT«*U+UKµ)­JKUK­TkRKµJµ*+Õ*US­R«ÒJÕÒÔÔª´*­Tµ¬JÕ*MU«T«ªRµR5µª´ª*U--K­*MÓJÕÒªR­ÒT­RµJ+Uµ*ÓªT«ÒJUµRµª´TS5­¬JµJÕ²*­T«R­´T­*­Ô*U+­ÒªT3µJµJ«Ô*µRµR«ÔJµJ­R«ÔJµ\",\
    [ \"sound/mino_J.dfpwm\" ] = \"Ğÿ¸I¿øw_\\000ü…^@ÿU\\000ÿ\\\"m!ÿ)Rÿ‚vR»Øê¿ÙJ^ı»V\\000¾©ª\\\"ÿ#¨ß	mÒ¯\\000Ôö¯€[Õ*€ÿ¶`·¤+è¿’ÔŸhõ@ŠşR+ùP÷Ş°+mEø_U\\000õ-éı JûµRu°Û_‚´E=ï_%€¾¤-ªÿÔ¿¤VÒ/\\000©ş/ +êĞşí`[iô¿”\\000ÔŸÔŠú EıbMzh»oØ•ºDöŸ(÷*jEÿ$éo…Z©W\\000Ù÷@«Z- ÿ­Ğo¢\\rê?‘úÑJ»@Ûş¨]êöŞêl«Ğª)dşàE¿¸\\000ĞÿPèŞLğ—ÀÿèÛ/úRBW©şURÒı¸U «»ö Q?\\000òÿ*°w+¨ş\\\\­ª–*}Ò_%ú¶­îBşĞ–-d!íÔä@ÿèE’t{+Ğ¶}²Õ ıƒªªd‹_Iè¯\\\
èö¦¬Úƒª Ò—–ªĞ_ôí€_HiÑ¯=\\000ı-ô“[ú¤Eı •?ZDô´zÕØ\\\"«%ÀWKmR¡ÚŞ­¿€Ğ§¿HĞUı'@­ºğş@ñıZ¨‚,úÀ.vPWª_`«Úÿ@	[ö+‚_$äW}©K‚ìÿÖŠtë‹ªPô'!õë\\000Gè÷‚« óQUé„ıí\\000w«äŸ(€ÿCjéJ »ø…jIHê_5r€ÿZ*ùµ»èø\\rªàPºÚ*n-j?T\\rí•>!¨¶š/\\000.ß\\\
¥¿€’ÿîRäm‰EÒWêdñVò¶põğ¶º@%hÚ/°>´€Ş´®H¬^Ğ6ÿÛV‚%ö—ÕO\\000»£«Ğê‘Ú¢ÕR÷I…ğ'è©;\\000ùZrá/`5ı ºZjU_@=ğ_Z-µŠ¿\\000.ß´§…ÍÿTéò—ÉòªòZğVô©(±ûğjZàÿJ }+¨½¶\\000=U-\\\\©W\\rĞ/­Bÿ\\000o_DßÂü§«H+Ğíâ²@şÉMè%$í{ìJ-èW*Ñ^TK¾¬U!­ªúàR'zèß­€W¨Uı‹]é-´+¢ÿH©ÚhûM^©ı»$¨›´Jş	Ô_QK}Pÿ/ Sµş×ĞnÕ„şJô/´DRú+ÔŠ¾\\000İŞøJ—(ÿªìµŠ@‚şƒlÕ& VÿpÅô¡öÔ`ÿ ¡¾PıD/ äÿ	t©%]-}W¶ù*Èª×+ğCA÷.àGUU`ó°ê‚ªè‚ªoÕ\\000ÿµÂl§êøß\\\
?å‹Å åGşÕÅìu¡é/ÀuåôÑo\\000şqEº)øQ}\\\"PıMhz©*T½TM}\\000ø._H­|/¥._€–‹_€fOƒ|Ó+oQƒîĞËUUeÁ«äû€¤uIè#ı\\\"t¥*ø_ -z©”¨~@{	Zú%¶üCˆ.è/ÔK¥ı«%ÛÒƒfêBuwÁ&Ğ½àj5Pıl´~Uø+è4X])=à¿\\\
–|o^‰­\\\
è•µC'ËWÀoEòÅnAıBÉê%ğ—ròr-¨{H[òm©zúR[°¶¼ÔôŠg?¤Ã~§Z­ğŠúhÿ@[¾ qàÓ<ÔÃRúOq×µ ÕğÖÒÖ}Âe[´äpKã2xû~Wá _àsRÕp•ü€u:dé=à¥|Yª)ù\\000¿r,Æ]Ğ~S–z¾TE^ª|ƒ'ºoÔ{•Šú‡Ò[@o±½áª\\\
õÁ*êOĞláAúb³ ù¢µøjô¨†|=dmõ\\\\ÕnI?ĞE·\\\\ET+Ã/pGO µúÑò Ú­àU5À{)ìá;xÁzè65 ŸX¼Êz‚ŞIŸ. ÖJUKÿB¡—ĞŸ”„«jÕC_€këéø’ªúp€ÿq\\\
ú¡´ºj\\000¾¬ZğPU¿ˆZ-Ü…/ètÛ®µ×¢?\\000Ëîzg Òÿ€.é‡øµĞ„¼R~¡,èú•,Tú¾TØ?)%}Î.-À/©İÕ+õAáw©IÕAêu+@ıà*ı°|U}!-ú-X¥z•/	ºŠvª¨jŸ¬ÒŠí?ÀV«Àß‹ «ÕÈ]%şĞU²@—ş@'üJêŸ\\000üm%RmşÀ§.À¿à?`íğâÜÒ&´.-Àûğ¶ı?\\000Û­ª^¤¿Ú\\0007UÔ¿\\000éoÀW+è¥J}-ĞÒ¾ª@¿ú\\\
-Pı_@*éŸì–TWh¥—*õCBR©_\\000ş'¡/$äUpIİJªTå/x#]¿\\000êWŠ}\\000©?xÑlëB«Š/ÈêØêö/€mí_€d_ô¡‚ªú® ¤?øµôµBw¸o :ĞJßD+%½? •ünKê/\\000ºu¡‹$õf/¨²· ·„ğO	úED? ºU!½ªÚ]ğ¶/´-õ\\000üK-½\\000öo¢ZIË^-Á•^Ğ¶êVDı¨ü¿© ¶«ªñª^Uõ-ö’ üKpµ\\\"}M‘®¨•¦7øEùØç|—ÿ(‡· ğRõiÚñ4>Á%zàÇ:p‡µø«è_ãPKõ\\rNÕ!¼A?•ÿHÅGºò„îâ\\\
ÿÁD•öC-êQï¡ıÀÓdyÁrø‡äx¡ù¡]Ğò*ÚèXåRôÂ>¨W+8ìx*º?`OdºèJª¥JÀ¯:„ÕìÃo°Õk Oé€×ÑøB¯ğ	u“ =í@?TñR_´|ER}<‚?¨––:­ş·2JŸĞ\\\
.««F~UnCÑ«ÄC¶¤Ó¢¡Qéõé°½°«è>T,ù\\\"|ª:¾4-x¼*¼†ZY>@O+Ş£ôwÕÇÅê­ç3ôÀü«àãØşà§¬tøZ<é=+|YË	üú´†·˜C±ƒ^#üËÓJtÅ¡¼á}AÕ|ò…r)·Zø„7¨|*èê|±ºK>à×”]5İŸ4Î©EÀO5ğ•C·¡¾àÄ‹JqİjÂ¬zÁ5Š~¸Â-6¬+ğ*XU×P=éĞÒWœöÀ%]rµh…Sx£¡vwtà‡j”êªàV¾(«‘’=ôĞ¥æXª½*êjÔƒ^8êŠÒ'ù¢Œ—´–êP§ì8Å±£–O¨Wœ:8uğ£ÂO•¬|lğ¡Óƒ+ß\\\
>Tú°ÒÁ+‡G•­xjñ)áGµ¦>UøpõBUƒ¯‚ª~Ğrğ¥¡G¦+\\r^9ôHé±æ‚U\\rzVz¡òĞÕ‚§–TÜ5à©ñÃ¢W.•|¬ô`Õƒ“ƒ^^¤|puÀÕáGTV\\rx5ø‘òC­W…>_X½àbá«Â•MxVøTñÃÒÏ\\\
½~Xù`ÕÁg…ªÔøRñQãƒ+O<U|±tá´AW¥•>X-¸Õ°£¥—­n¥z‘åA×‚§JÒ.ÙRÒiÅ£ÊGƒ«­‡kÏƒ¢¥ÃÅâeáÁóÁaáká¡úĞtğtx¢|Z¸>J>šZ¯–•ƒ×‚ÇÒ‡ÑÁëàQñctáºp1üT:´:¸,<-T^O•¥‡®WÅ§âÁêÁ©ğSé°zp*|j|¨:l¼ŠV®†OÅ‡Õ…¥áËâ¡õàdè©ø°zhU¸¾(=œ¼‹«K‹§ÊÃÖÁÒâ“âÉò¡up5ø¤|X:Ø<->”N—†¦‡¦ÃSÁ§ÒÃêàjğªø°|°:xš<=Z†Kª’§Á«Ô¡ëAUñ²±JyÔi¨6<\\\\\\\\K~å‡GğZƒVøÃÕxx¨«?Èû…A‡ğëp…>|(Şnã¨ày\\\\ÍÃöàåÔtø‡^‡úÀU)~`+Nñ…k	}h±*´ÃÃâ)ı°rŠy‡ÁÇ:zõ.JUÃOi8ñØ>UŞ¢Ã‹äzğ(+\\rn…§£Zéà)zƒ“ƒ­òğR©.ÜR…«“uĞrYZ,—RÇ•ê¨z¨ZÊ‡¥²ºğ’*:ü/œñÀe}Lé†+°ãÁÇ2ü°ø<¨Ûƒõøà°<µ\\\\#_ÆiÁ³xZx/IåÁWQz¹èV\\rÖÖƒË°ş0Ò6NôBÇÕc|`µ*—ì£ÒCVñĞ=‚>ÜTC¥ùbèh~WÊ£qÕğ£\\\\.Û…G©uµàC|.\\\\–ÏEwpá-jøŠÇ£ÜàjQ–>ø\\\
ÎWyaµ\\\":\\\\K–Ö`ér…=T]ÅŠí£øÁ=*=ÂG‡êÒğQ=v‚OÅ«Ôğ‰x|TKÇ‚_ğÒ¨jxŠk‡Gnau`O<¼\\rÓÏTqù ZTÅ×\\\"õpÅ=ª>ĞƒËeü¡ªN<èÃ'µğaºµ¤'Ã/êqhY<«NÃ†OĞiøQ=\\ríÂK‹²up#uƒÓB{tğZ,<ÓEÓC½°êT%½ŠâÅ+}¨z+¶Šé‹¥´¸x!/Uã…VU5Ô’OÑãèb•=Ø5Â#}ªà‡“>°âÁGø±ø<pÏƒõøà°|\\\\Ü’?¦³à©+xøƒOAóÁgz<ò­ÚêA«¨~8Ô—êÁâÕj|`­&õÃÆ#µpÒ5	­ªƒåG¼hhY?Š«ÂS‡ğ²ø¢^ˆ{'¥yºà…^\\\\ÊO©wpñV|ÊÃÇ¡np­«|ËCgzá¬ ]¬“ê®pèx‰ª.eÅö±øĞŒ>*/¡‡‹jUøQ][Á§ŠWêğ¢¸>¦ÅKC¯èèhi^%«Ã£®°jè¦n–²ƒ«ªtÚĞ-—´ÒƒË’zØd-UrÅÃ¦U|hV^ä£¡§Z\\\\Ñ\\\\ZÕÑÁ'µxdš?UÚĞc“´rôuáÒJy±à[j©y9zĞS¥T/Êu0wà©Ò¡—F™Ş)¼Pòá’‹¥®C=œ\\\\ğÔäE¡©v|Tx)åÁ)¡n.\\\\UàZà¢‡+]œ\\\
}ÑbÑƒK¯‚^DŸ°òáÅÒ‚Ó\\\
«\\r.iø¨ñÁÚÂ¢J=5ô°tĞ°ô`+ª´^¸(x¬lH–]._/EMK'K‡¦Uá‡òEëÁÚpSğhõà4y½Ğ~Ğ|.•_H¶CÔõv¡kÀWõAëp•à2|Ğ<¸*t¼¶BŸŠ«‡./Å…ò…ÅàÕâ¡yQUp±øòh9tL¬>EK¥ƒkƒ£êCåÁjñâèQ{Ğdğ49Z<´,\\\\\\r6‹…‰—Ä…%C—Á¥áCõpi¸\\\"ôR|‘-¸^jšV\\r‡V‡£ÃUÅGõ¡Vá²ò¢ùP»àX¸T:4/´®’‹¶&+•®ƒ®”µÔ¡OQ_°‹%Õ5ğQ¬®| ›ƒ^fô£X<êW/ÒÃ“ÑøT5‡¾‘ËB×xp)Ú^:O‡—pteÔ\\r¼’Ê§[ÁóàX]¸J¬‡ß’ñ kYNé–4åÑvH>ZÃË'ôdÑ¬tü0G‹ÇäSõmxHÏ«òÑĞ-¼´”’›†ÕÁÑ:pjğJ^FòàU58z´•‡–åCSR¾x¡’¡£ÅzÑĞT‹x¡e‹=ht£‰zÊĞÇ*¾hòAk:t”ÅK¯àÈQı4ø0-7ÉS£+Uğ¥8>ÖÀÓB/ôè”h¼ŠÅÇ#]èÒĞ.=Xç§jñäA—8z:ÅV§ä°Å=¤<©¯EèãT9XıÈ†.¥á‡qªxt//Tã…éy¨Zä¥…£-ğT|.®aÉÁ—tttè¯\\\
êÉÃ-´|¸Šõ¡£3Uù`\\r+ñƒÒ%]pØ­ğÂé\\\
|4ZªÓ‚£}ªø†©ÓÁ§´xX|….ºÊ§¸z8Z\\r.zÅ£±:¸ªŸ¶¡Ó£I¼à,Ê+ŞÑò¡^pt:¦ªšñ¢¾TØ°Ê+à©FzJøQFsĞ«©5¸pAâèQ‘<U”W®àòÂTxÚ§}¢qÈµ\\\\hê‡§¢ô¡«0\\\\\\\\è«òèQV~¨¢GGğbiU^$¯…Ç¢äÛr:6M•C«F<Ñè§,nXó€kyÌ¢•¾àÂI{Yğ0—K»ÀKÇZpğS.Z…—EWèñH\\\\|ŠÒËW`ã°µ<lŠîKnátÁz\\\\V†×Òàğb/´\\\\T†G—£ğğRY(ı°—¥ğÃØ*œtP¯†/Ìqaé<ª\\\\Ç\\\
èâ¨£xšt‡¢Ò§:¸8ª.\\råÑÃNt\\\\tJ–Fê¡£5izĞG.§´CªSZ¼¨[JUÕÅ´Eº²T­”WÒªRYºª¬ÊJ«”³è²ª,M¶JKKÓ²dµ4­¬ªJUMµÒ²ª2-5MUË*ÕRÕªT­T-SËJµªÔRU«4­RÓR­,µJÓ*µ¬ÔÊR­4­JËJ\",\
    [ \"lib/debug.lua\" ] = \"local _WRITE_TO_DEBUG_MONITOR = false\\r\\\
\\r\\\
local cospc_debuglog = function(header, text)\\r\\\
	-- ccemux itself doesn't have virtual monitor support\\r\\\
	if _HOST:find(\\\"CCEmuX\\\") then\\r\\\
		return\\r\\\
	end\\r\\\
\\r\\\
	if _WRITE_TO_DEBUG_MONITOR then\\r\\\
		if ccemux then\\r\\\
			if not peripheral.find(\\\"monitor\\\") then\\r\\\
				ccemux.attach(\\\"right\\\", \\\"monitor\\\")\\r\\\
			end\\r\\\
			local t = term.redirect(peripheral.wrap(\\\"right\\\"))\\r\\\
			if text == 0 then\\r\\\
				term.clear()\\r\\\
				term.setCursorPos(1, 1)\\r\\\
			else\\r\\\
				term.setTextColor(colors.yellow)\\r\\\
				term.write(header or \\\"SYS\\\")\\r\\\
				term.setTextColor(colors.white)\\r\\\
				print(\\\": \\\" .. text)\\r\\\
			end\\r\\\
			term.redirect(t)\\r\\\
		end\\r\\\
	end\\r\\\
end\\r\\\
\\r\\\
return cospc_debuglog\\r\\\
\",\
    [ \"sound/mino_T.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000`\\000\\000\\000\\000\\000\\000UµEvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000`\\000\\000\\000\\000\\000í')iDÿÿÿÿÿÿÿÿÿÿÿÿšvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000€ \\\
Æ€ĞU\\000\\000\\000\\000BˆFÆP§”—‚…GÄP‡óPjé xJaÉ˜ôkBß{Ï½÷Ş{ 4d\\000\\000\\000@bà1	B¡Å	Qœ)Ba9	–r:	B÷ „.çŞrî½÷\\rY\\000\\000\\0000!„B!„B\\\
)¥RŠ)¦˜bÊ1ÇsÌ1È ƒ:è¤“N2©¤“2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊcŒ1ÆcŒ1ÆcŒ1ÆBCV\\000 \\000\\000„AdB!…RŠ)¦sÌ1Ç€ĞU\\000\\000 \\000€\\000\\000\\000\\000G‘É‘É‘$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û—}ÛwuÙ·}ÙvuY—eYwm[—uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9’#)’„†¬\\000d\\000\\000\\000à(â8’#9–cI–¤IšåYåi&j¢„†¬\\000\\000\\000\\000\\000\\000\\000\\000 (Šâ(#I–¥išç©(Š¦ªª¢iªªªš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš@hÈ*\\000@\\000@ÇqÇQÇqÉ‘$	\\rY\\000È\\000\\000\\000ÀPG‘Ë±$ÍÒ,Ïò4Ñ3=W”MİÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ€ĞU\\000\\000\\000\\000 ˆB†1 4d\\000\\000\\000€¢‘1Ô)%Á¥`!Ä1Ô!ä<”Z:RX2&=Å„Â÷Şsï½÷\\rY\\000\\000\\000FƒxL‚B(FqBg\\\
‚BXN‚¥œ‡N‚Ğ=!„Ë¹·œ{ï½BCV\\000€\\000\\000B!„B!„BJ)…”bŠ)¦˜rÌ1Çs2È ƒ:é¤“L*é¤£L2ê(µ–RK1Å[n1ÖZkÍ9÷”2ÆcŒ1ÆcŒ1ÆcŒ1‚ĞU\\000\\000\\000\\000aA„BH!…”bŠ)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I’,É’4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeİÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäHŠ¤\\000¡!«\\000\\000\\000\\000\\0008Š£8äHåX’%i’fy–gyš§‰šè¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(Š¢8ŠãH’eišæyª'Š¢©ªªhšªªª¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš&²\\\
\\000\\000\\000ĞqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000€\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç“<É³<Çs<É“4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000€ Ç´ƒ$	„ ‚äÄÄ¤… ‚ä:%Åä!§ bä9É˜Aä‚ÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥“9ç¤tR¡¥Rg©´ZbÌ(•ÚR­\\r„RH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,„BCV\\000Q\\000\\000„1H)¤bŒ9ÈDŒ1èd†1!sNAÇ…T*uPRÃsA¨ ƒT:G•ƒPRG\\000\\000€\\000\\000€\\000¡Ğ@œ\\000€A’4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUİvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×•eÓumÙue[WeYø5U•eÓumÙt]ÙveW·UYÖmÑu}]•eá7eÙ÷e[×}Y·•at]ÛWeY÷MY~Ù–…İÕu_˜DQU=U•]QU]×t][W]×¶5Õ”]ÓumÙT]YVeY÷]WÖuMUeÙ”eÛ6]W–UYöuW–u[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}U–u_Öua˜uÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_•máXeÙøuá–[×…ßs]_WmÙVÙ6†İ÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^İ6êÆO¸ß¨©ª¯›®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VY†Õ–…aÖuaÙ…a©Úº2¼ºo¯­+ÃíßW†ªmË«ÛÂ0û¶ğÛÂo»±3\\000\\0008\\000\\000˜P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEU•eÕ•eYu]]MÓ•EÕteÓT]Yu]WV]W–%M3MÍóLSó<Ó4UÓ•MSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓ–MS•eÓUmÙUeW–]Ù¶MU•eS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨š²kšªl«ªª»²kë¾,Ë¶,ªªëš®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï™¦,›ª)Û¦ªÊ²,»¶mË²/Œ¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À€\\000@€	e Ğ•\\000@\\000\\000`cŒAh”rÎ9RÎ9!sB©dÎA¡¤Ì9¥¤”9¡””B¥¤ÔZ¡””Z+\\000\\000 À\\000 ÀM‰Å\\\
\\rY	\\000¤\\000GÓLÓueÙËEU•eÛ6†Å²DQUeÙ¶…cEU•eÛÖu4QTUY¶mİWSUeÙ¶}]82UU–m[×}#U–m[×…¡’*Ë¶më¾QI¶m]7†ã¨$Û¶îû¾q,ñ…¡°,•ğ•_8*\\000\\000ğ\\000 VG8),4d%\\000\\000\\000¤”QJ)£”RJ)Æ”RŒ	\\000\\000p\\000\\0000¡²\\\"\\000ˆ\\000\\000œsÎ9çœsÎ9çœsÎ9çœsÎ9çcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1Æ\\000ìD8\\000ìDX…†¬\\000Â\\000\\000„‚’R)¥”9ç¤”RJ)¥”ÈA¥”RJ)¥DÒI)¥”RJ)¥qPJ)¥”RJ)¡”RJ)¥”RJ	¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ\\000&\\000P	6Î°’tV8\\\\hÈJ\\000 7\\000\\000PŠ9Æ$”JH%„Jå„ÎI	)µVB\\\
­„\\\
:h£RK­•”JI™„B(¡„RZ)%µR2¡„PJ!¥RJ	¡ePB\\\
%””RI-´TJÉ „PZ	©•ÔZ\\\
%•”A)©„’R*­µ”JJ­ƒÒR)­µÖJJ!•–R¥¤–R)¥µJk­µNR)-¤ÖRk­•VJ)¥”JI­µ–Zk)¥VB)­´ÒZ)%µÖRk-•ÔZK­¥ÖRk­¥ÖJ)%¥–Zk­µ–Z*)µ”B)¥•’Bj©¥ÖJ*-„ĞRI¥•VZk)¥”J(%•”Z*©µ–Rh¥…ÒJI%¥–J*)¥ÔR*¡”R*¡•ÔRk©¥–J*-µÔR+©”–JJ©\\000\\000tà\\000\\000`D¥…ØiÆ•GàˆB†	(\\000\\000\\000ˆ™@ \\000\\\
d\\000ÀB‚\\000PX`(]è‚\\\"HA\\\\8qã‰NèĞ\\000ˆ™\\000¡\\\"$dÀE…t\\000°¸À(]è‚\\\"HA\\\\8qã‰NèĞ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\†ÆG‡ÇHˆ\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000€OggS\\000g!\\000\\000\\000\\000\\000\\000`\\000\\000\\000\\000\\000>63dOEbHH]HKBDG7BD6@SR›Äšë´ø[Õ\\\
?@.èz:,€1‚İ™øŸO›ıºÓ“UÀºSS“Š1Ëz>Ş!¶ïŸ²Uôß–7HÀY?EÛ(aşZÕ€½;sUüßÆE¬¦!X\\r\\\\Êâƒ«¬=`\\000j£Êßò\\\
l&¹°î‡«!À@\\000\\000¦=°\\000@ˆ€\\000(GmbkA!Ñ`ÿUÀo\\000ï\\000|@‰€ïz´@•o0<¦	Eƒ—3pA\\000n«&óë7$Ôm.@”™Eº\\0008¶0Ta¥ú.“ú°¦€Ï\\\
*\\\
08ô…ƒD4Œ‚Äˆğ–C¥\\\
äÃ\\000VŸÒ«Ç…_Oó\\000uvÂ«ØWèLºvjİ®§ùİ&tëZaê9rjÓë±8Ê€¦°Ã¹õ×\\000ÜŒŸ÷Lì±ØpÂ°\\\
ŞÚniW/!¾»a=˜8ş6U \\0003Ùy´\\000n©D¯Ì¹³æÚ s@. ß€ ôÖ«À¼·Œû\\r\\000\\\\	 ¤‡™Âµp Z{¢&Pƒ$ø€Â(wĞ`®f©˜Û¯W’$—ÕyÇ\\000Şÿï|\\000ÀÃÜ¶ºLj‚7Â“\\000iR®â ƒë€àt#\\000;¸\\000,àÍ ƒ¼Y¦€èŒrn	V¥+Œ:@)› )_ .Ş´	¨´ÖÊM¾Õç¿÷ïW:®H`n[$µuo€ÿğ9DC\\rf\\rÜ>İ4@ƒ¶}bí‹XÙ\\000ÜĞQ_RtÈğÄ ˜Üø`ÁVvƒ n­uLØTz2Q–Ô@§…\\000\\000.\\000€Àm“Ær|\\\
\\000€¸\\000¿äP\\000×\\000\\000”Á¬¾À|¤.	Wc\\\
`;:\\000j­•}/*=”%qv+\\000¸Ğ\\000-ÀM“av¶5õÏ‚c\\000˜ª\\rØgĞ\\000ìS\\000°5€2€·à‰Nğ’\\\
HBJ—äy”K²A¶è(OLCNd=På~=7ÎŠ\\000D§gU¶N`_OXI.WŠìÀXGCb¶;U&5((*\\000&‡ÚRuæ3=Q†[ú”tc¨jbÖÔn·ˆ/‹á| Ÿ*ğ1€k	\\000|èïğ(ïŒ8àl1Ñ@4 &|`\\0004R/_,ñG³Bµ ¬Ù+İme­4ïocë'®»åõûlS¸r\\000à¬p-\\000'éìo-íp PÁ„`™	+±p\\\".‡$Ûß¯h$*x”¸±®(Ë\\000CZÒ\\\
\\0000—ğM¡@ØL€÷’44	~\\000\\\"ƒqı&…Øq‚Š« É·Uëf›ºİÖÉº&›şMŸº\\000ø,á›€f®+,FöchNJ.p Ğ†+H˜3‡+Øø*TóPTäN\\000X‹0 ºU›fùı¶¨µ–ea2Ë6|@ĞGÀ¶€Ğ|pãe€€/lO€Å\\\
è\\0006‰5>’–|L õ\\000PÄN5P¤$ÑG\\000\\r\\000üp¾\\000?\\000<|@ù	”4À£\\000&…ğ¼6¡Y\\\\]¾Üş\\000 C#€¹ëû¸òïoÖìE\\000€=—€w~€5(=íÌ‚( \\\
\\\
Û1:\\000aíƒœ¸EŠtñ7Îc‚!_ÿ_áü~5ÖÃæqD-Ÿ°ú@OÃ“@Õ_:`›·\\000°´lóë*¼ÉQxÛç,2saQÏx’`fı´æª \",\
    [ \"sound/mino_S.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000Ë_\\000\\000\\000\\000\\000\\000£Lfúvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000Ë_\\000\\000\\000\\000\\000‘ušDÿÿÿÿÿÿÿÿÿÿÿÿšvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000€ \\\
Æ€ĞU\\000\\000\\000\\000BˆFÆP§”—‚…GÄP‡óPjé xJaÉ˜ôkBß{Ï½÷Ş{ 4d\\000\\000\\000@bà1	B¡Å	Qœ)Ba9	–r:	B÷ „.çŞrî½÷\\rY\\000\\000\\0000!„B!„B\\\
)¥RŠ)¦˜bÊ1ÇsÌ1È ƒ:è¤“N2©¤“2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊcŒ1ÆcŒ1ÆcŒ1ÆBCV\\000 \\000\\000„AdB!…RŠ)¦sÌ1Ç€ĞU\\000\\000 \\000€\\000\\000\\000\\000G‘É‘É‘$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û—}ÛwuÙ·}ÙvuY—eYwm[—uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9’#)’„†¬\\000d\\000\\000\\000à(â8’#9–cI–¤IšåYåi&j¢„†¬\\000\\000\\000\\000\\000\\000\\000\\000 (Šâ(#I–¥išç©(Š¦ªª¢iªªªš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš@hÈ*\\000@\\000@ÇqÇQÇqÉ‘$	\\rY\\000È\\000\\000\\000ÀPG‘Ë±$ÍÒ,Ïò4Ñ3=W”MİÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ€ĞU\\000\\000\\000\\000 ˆB†1 4d\\000\\000\\000€¢‘1Ô)%Á¥`!Ä1Ô!ä<”Z:RX2&=Å„Â÷Şsï½÷\\rY\\000\\000\\000FƒxL‚B(FqBg\\\
‚BXN‚¥œ‡N‚Ğ=!„Ë¹·œ{ï½BCV\\000€\\000\\000B!„B!„BJ)…”bŠ)¦˜rÌ1Çs2È ƒ:é¤“L*é¤£L2ê(µ–RK1Å[n1ÖZkÍ9÷”2ÆcŒ1ÆcŒ1ÆcŒ1‚ĞU\\000\\000\\000\\000aA„BH!…”bŠ)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I’,É’4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeİÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäHŠ¤\\000¡!«\\000\\000\\000\\000\\0008Š£8äHåX’%i’fy–gyš§‰šè¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(Š¢8ŠãH’eišæyª'Š¢©ªªhšªªª¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš&²\\\
\\000\\000\\000ĞqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000€\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç“<É³<Çs<É“4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000€ Ç´ƒ$	„ ‚äÄÄ¤… ‚ä:%Åä!§ bä9É˜Aä‚ÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥“9ç¤tR¡¥Rg©´ZbÌ(•ÚR­\\r„RH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,„BCV\\000Q\\000\\000„1H)¤bŒ9ÈDŒ1èd†1!sNAÇ…T*uPRÃsA¨ ƒT:G•ƒPRG\\000\\000€\\000\\000€\\000¡Ğ@œ\\000€A’4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUİvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×•eÓumÙue[WeYø5U•eÓumÙt]ÙveW·UYÖmÑu}]•eá7eÙ÷e[×}Y·•at]ÛWeY÷MY~Ù–…İÕu_˜DQU=U•]QU]×t][W]×¶5Õ”]ÓumÙT]YVeY÷]WÖuMUeÙ”eÛ6]W–UYöuW–u[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}U–u_Öua˜uÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_•máXeÙøuá–[×…ßs]_WmÙVÙ6†İ÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^İ6êÆO¸ß¨©ª¯›®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VY†Õ–…aÖuaÙ…a©Úº2¼ºo¯­+ÃíßW†ªmË«ÛÂ0û¶ğÛÂo»±3\\000\\0008\\000\\000˜P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEU•eÕ•eYu]]MÓ•EÕteÓT]Yu]WV]W–%M3MÍóLSó<Ó4UÓ•MSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓ–MS•eÓUmÙUeW–]Ù¶MU•eS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨š²kšªl«ªª»²kë¾,Ë¶,ªªëš®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï™¦,›ª)Û¦ªÊ²,»¶mË²/Œ¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À€\\000@€	e Ğ•\\000@\\000\\000`cŒAh”rÎ9RÎ9!sB©dÎA¡¤Ì9¥¤”9¡””B¥¤ÔZ¡””Z+\\000\\000 À\\000 ÀM‰Å\\\
\\rY	\\000¤\\000GÓLÓueÙËEU•eÛ6†Å²DQUeÙ¶…cEU•eÛÖu4QTUY¶mİWSUeÙ¶}]82UU–m[×}#U–m[×…¡’*Ë¶më¾QI¶m]7†ã¨$Û¶îû¾q,ñ…¡°,•ğ•_8*\\000\\000ğ\\000 VG8),4d%\\000\\000\\000¤”QJ)£”RJ)Æ”RŒ	\\000\\000p\\000\\0000¡²\\\"\\000ˆ\\000\\000œsÎ9çœsÎ9çœsÎ9çœsÎ9çcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1Æ\\000ìD8\\000ìDX…†¬\\000Â\\000\\000„‚’R)¥”9ç¤”RJ)¥”ÈA¥”RJ)¥DÒI)¥”RJ)¥qPJ)¥”RJ)¡”RJ)¥”RJ	¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ\\000&\\000P	6Î°’tV8\\\\hÈJ\\000 7\\000\\000PŠ9Æ$”JH%„Jå„ÎI	)µVB\\\
­„\\\
:h£RK­•”JI™„B(¡„RZ)%µR2¡„PJ!¥RJ	¡ePB\\\
%””RI-´TJÉ „PZ	©•ÔZ\\\
%•”A)©„’R*­µ”JJ­ƒÒR)­µÖJJ!•–R¥¤–R)¥µJk­µNR)-¤ÖRk­•VJ)¥”JI­µ–Zk)¥VB)­´ÒZ)%µÖRk-•ÔZK­¥ÖRk­¥ÖJ)%¥–Zk­µ–Z*)µ”B)¥•’Bj©¥ÖJ*-„ĞRI¥•VZk)¥”J(%•”Z*©µ–Rh¥…ÒJI%¥–J*)¥ÔR*¡”R*¡•ÔRk©¥–J*-µÔR+©”–JJ©\\000\\000tà\\000\\000`D¥…ØiÆ•GàˆB†	(\\000\\000\\000ˆ™@ \\000\\\
d\\000ÀB‚\\000PX`(]è‚\\\"HA\\\\8qã‰NèĞ\\000ˆ™\\000¡\\\"$dÀE…t\\000°¸À(]è‚\\\"HA\\\\8qã‰NèĞ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\†ÆG‡ÇHˆ\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000€OggS\\000ƒ)\\000\\000\\000\\000\\000\\000Ë_\\000\\000\\000\\000\\000°$bI1F5F5G=D5A5-689<2:5+1^›Ûëi»©ƒÌ'jç‹j7cO7g7Ï¯_ŞœİcU…Œ¹\\\\Ø€?•J¥\\000àEe\\000_giG`?úÒŸ”€	ÀŞà€•\\000z§“¥ïÙv#µ7`Ú€\\000˜T¶*H\\000`kp\\000\\000x*b\\000¼Ğê\\000¬à'\\000\\000\\000ØnŸ«Iëu±nÊë÷ô \\000¢ÆÖšH|	\\0009ÆïşæßÇx¡jÔÁ¤¯g¥\\000Ş\\000oxv\\000ğCÒ\\000T\\000WìÍu\\000n¥µ:şjÍïªY_\\rm4\\0000…H	öÀ»aÇ\\000ŒP€G\\000@|+\\000¼x€8€•\\000f­«áxİ›iùrDwÚ€\\\
j¨ÊÚ´ÿÛs=^¨xPuy˜ìµ‚ë7{¨úñÁ&ôñ°%\\000<K‚•B9@vu€\\000z«+I÷Órc‹i*\\000DdU«,»å\\000D±ƒñ@¼Àãÿx€Š	\\000­\\000	À€4\\000r­Û­ìÇÕÍ&‘öN\\000@Ré¹ £Òr}·l¿ı¾c[\\000 ÅÈş\\000\\000NˆÿUM`ö	ß\\\\‹@ cÆ–L†\\000Ş€€q¬\\000j¥•9¾èãZ$GR3Õ\\000u™q\\000ÎZ‹1˜Y\\0003‰ö2€L\\0000ğ€iÂµ@Ğßaš jÀ„b\\000^§=vßÒZŞ>¡j{˜êâİŸŸ•Åiøıç×ÃÔ`}›	ÿ™åT*Fà”¢Ëğ\\000œ2À@\\\\ÀÒ`ûtĞ\\000n§µ;ş0>j¦_U³ßD5\\000„”`\\000€‡ûf\\000ğ5€øK\\000:à[°Ğ(à\\000†°.\\000^³ıp|×4~òC!s€\\\
 Œ\\000¦hPeéÒ®K&\\000\\0001L§ÿÀz\\\
à#\\000`\\000[ÛO¢\\000€RÌ´\\000>û	b¯}×Ÿ®xÄWœŸo¹\\\"š9\\000 ¬r¶\\000\\000Ö›†é\\000¼,\\000N?\\000\\000°£À\\0004\\\\\\r\\000ŸŠ\\000fµ½²?uŒ´÷J}Û;ª44¶¨¬rš\\000ÿ\\\
\\000£\\000ÀÀŒ.\\000 ŠW\\000ï\\000*›“òø“CS¶êX¿íÓˆ†¹¨Œq«C‘2ö·c€½\\000€\\rğãà{\\000\\000\\r¾†M.\\000$v}«¡ıò8gUªåü%Øb¬Y`œÏ«÷öÎ;_¾ï!\\000¼û6ğ(`1¾\\000 ˜\\000¾\\000„r\\000{SÑº~Ìn×cŒhÍ Nğz°®h‹º~·>1¥Ù(DH½%ª8¥F	¼ÑUàĞà\\000y€lg°uâ¶ê›Î€·@a±¶e8š˜ûmOX*?_Ëî€·À#YeL@v\\000°@ÀÆ\\000‰Â>\\000y…9®í·—¢CÍRm¿S©	æ²óŠ°—Pz€÷\\000¼\\000N.`00“Ø*\\000{…9şŞ<®MÌûj+}¨¤{\\000º?Ròü|u\\000J	\\000 á\\000'‡9&@ğØ»Ã\\000	Ø\\r\\000‰ıõñT-§ }PùMl4Ì&ŒaÂó«Ğ–Q:š€ÓÈ\\000\\000`:@à\\000>ğU4€À>\\000‹“uÿti~S.ñÖâ=44Œ-*c½€w\\000úh\\000\\000†¿M\\000\\0004œ\\000zqx×Ò»ÊVÛïy¨,,*c€Ûæ‘Ó,~›€¡ğCàıb\\000\\0007.~Ú<\\000|`ƒ\",\
    [ \"sound/lock.dfpwm\" ] = \"Ls,Ó85MSUÕ8''U£ÒÒx¸8¥±,ÓrX4‡Ç±Ôâ,58‡Çáäâ˜q\\\\–™Æ‹ã8VV–#Ç9jšqœšrÌ8™Ã“£ã¤cå8¥™ãÔ89c©ç˜cj'ÇÊâXiY9sÇÒ±J3cŒã¬8µXUÅ1æ83®plãŒcZœrÇÅÇ8c•‹“ã¨qq8u<§Œãâ˜cVÇ8sÌ8f<Ç±ªá˜sÌ8Ç£qÆcf<Æ*Ç8Î±2Î1N‡ÃãÄqã8ñpMKÇ8Gcœ£i¦ÇÆcV9æpgU<z§tœrÇgÇq\\\\Z9‹ãŒ‡KãÔø˜ÇÅqÆxÆ1çœqœc<‡‡Ãqâãğ8–ç8sÌq+Ç1ã8ÎqÇÇ±Çq'‡cÆÊ8æXÇq©£cÇx'«qªj<NYšãŒÃq¬89Ç,Çqªj§©Æ©Ñ´4U5UÍ±rªqZš¦šããäXV•Ó´Ç©iæ8Î8ã,—¥¦iªijª§qªrq–:3MËqªªå8.SUÕ2n8KË4³Ê©jj9ã4MË—ã8Î²Ìeœ¦U.:KËqšqœcqãÔ8å8Ë±ª¬rÊ±rÓá3Ç³Ìªâ1u8Õ8Î4ã1ÇÒ2Ç4ËJ33å4SÎ4N59å8ã§ñXcÇ©rÇªª¦œr¬*§ª<œÆ:Æ™rÌqœ¬*ç˜cÌ±ªÇãÌ1ãÑq¬rŒ³,:5-Õ1Í8Ã9fé8fSe9c:™¦¥qÅ…‹cãä2:S–£cqeéhYNÙâ8ÎÇÇÑq§²²§Ê25S3SãXSÖ8ã˜‹ÕâÄ3Vã8ZV<t¸*Nòğ§Ç²ÇÊ2NSÇ8G5Îá”•Ã9ãX.Ù8ZZ­ŒgŒãTã¤qgË8Kã4Î´bÅñ˜ã8ã8æ§œešišUå1K‡ãXeéhåTÇ1Ç1gŒcU¦…‡cYU,-b³,Mã8NÏh<æXåX%Ç1Ó˜ãè8æ˜ãXfcœªq¬89N9N9ç˜%+Ç8¦%éŒÇ’Å<cÔ1ÅÑqŒ3ãpœSæ8Çqj—ê˜¦Ç±Ê)KÇ±±§ÆÎ±¬\\\\sœrË2s8ËÊÒ4ãRyÇ*i\\\\Sl<œÊex4cQ“Æ1£ªqªr*k¬ªjª'Õ8MUÕ2¦ª©šÆ¥ªfgYªi¦if©¦ši¦–©¥–i•f\",\
    [ \"sound/drop.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\0002\\\\\\000\\000\\000\\000\\000\\000°‰{Ovorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\0002\\\\\\000\\000\\000\\000\\000ROá!Dÿÿÿÿÿÿÿÿÿÿÿÿšvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000€ \\\
Æ€ĞU\\000\\000\\000\\000BˆFÆP§”—‚…GÄP‡óPjé xJaÉ˜ôkBß{Ï½÷Ş{ 4d\\000\\000\\000@bà1	B¡Å	Qœ)Ba9	–r:	B÷ „.çŞrî½÷\\rY\\000\\000\\0000!„B!„B\\\
)¥RŠ)¦˜bÊ1ÇsÌ1È ƒ:è¤“N2©¤“2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊcŒ1ÆcŒ1ÆcŒ1ÆBCV\\000 \\000\\000„AdB!…RŠ)¦sÌ1Ç€ĞU\\000\\000 \\000€\\000\\000\\000\\000G‘É‘É‘$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û—}ÛwuÙ·}ÙvuY—eYwm[—uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9’#)’„†¬\\000d\\000\\000\\000à(â8’#9–cI–¤IšåYåi&j¢„†¬\\000\\000\\000\\000\\000\\000\\000\\000 (Šâ(#I–¥išç©(Š¦ªª¢iªªªš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš@hÈ*\\000@\\000@ÇqÇQÇqÉ‘$	\\rY\\000È\\000\\000\\000ÀPG‘Ë±$ÍÒ,Ïò4Ñ3=W”MİÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ€ĞU\\000\\000\\000\\000 ˆB†1 4d\\000\\000\\000€¢‘1Ô)%Á¥`!Ä1Ô!ä<”Z:RX2&=Å„Â÷Şsï½÷\\rY\\000\\000\\000FƒxL‚B(FqBg\\\
‚BXN‚¥œ‡N‚Ğ=!„Ë¹·œ{ï½BCV\\000€\\000\\000B!„B!„BJ)…”bŠ)¦˜rÌ1Çs2È ƒ:é¤“L*é¤£L2ê(µ–RK1Å[n1ÖZkÍ9÷”2ÆcŒ1ÆcŒ1ÆcŒ1‚ĞU\\000\\000\\000\\000aA„BH!…”bŠ)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I’,É’4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeİÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäHŠ¤\\000¡!«\\000\\000\\000\\000\\0008Š£8äHåX’%i’fy–gyš§‰šè¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(Š¢8ŠãH’eišæyª'Š¢©ªªhšªªª¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš&²\\\
\\000\\000\\000ĞqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000€\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç“<É³<Çs<É“4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000€ Ç´ƒ$	„ ‚äÄÄ¤… ‚ä:%Åä!§ bä9É˜Aä‚ÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥“9ç¤tR¡¥Rg©´ZbÌ(•ÚR­\\r„RH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,„BCV\\000Q\\000\\000„1H)¤bŒ9ÈDŒ1èd†1!sNAÇ…T*uPRÃsA¨ ƒT:G•ƒPRG\\000\\000€\\000\\000€\\000¡Ğ@œ\\000€A’4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUİvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×•eÓumÙue[WeYø5U•eÓumÙt]ÙveW·UYÖmÑu}]•eá7eÙ÷e[×}Y·•at]ÛWeY÷MY~Ù–…İÕu_˜DQU=U•]QU]×t][W]×¶5Õ”]ÓumÙT]YVeY÷]WÖuMUeÙ”eÛ6]W–UYöuW–u[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}U–u_Öua˜uÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_•máXeÙøuá–[×…ßs]_WmÙVÙ6†İ÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^İ6êÆO¸ß¨©ª¯›®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VY†Õ–…aÖuaÙ…a©Úº2¼ºo¯­+ÃíßW†ªmË«ÛÂ0û¶ğÛÂo»±3\\000\\0008\\000\\000˜P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEU•eÕ•eYu]]MÓ•EÕteÓT]Yu]WV]W–%M3MÍóLSó<Ó4UÓ•MSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓ–MS•eÓUmÙUeW–]Ù¶MU•eS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨š²kšªl«ªª»²kë¾,Ë¶,ªªëš®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï™¦,›ª)Û¦ªÊ²,»¶mË²/Œ¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À€\\000@€	e Ğ•\\000@\\000\\000`cŒAh”rÎ9RÎ9!sB©dÎA¡¤Ì9¥¤”9¡””B¥¤ÔZ¡””Z+\\000\\000 À\\000 ÀM‰Å\\\
\\rY	\\000¤\\000GÓLÓueÙËEU•eÛ6†Å²DQUeÙ¶…cEU•eÛÖu4QTUY¶mİWSUeÙ¶}]82UU–m[×}#U–m[×…¡’*Ë¶më¾QI¶m]7†ã¨$Û¶îû¾q,ñ…¡°,•ğ•_8*\\000\\000ğ\\000 VG8),4d%\\000\\000\\000¤”QJ)£”RJ)Æ”RŒ	\\000\\000p\\000\\0000¡²\\\"\\000ˆ\\000\\000œsÎ9çœsÎ9çœsÎ9çœsÎ9çcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1Æ\\000ìD8\\000ìDX…†¬\\000Â\\000\\000„‚’R)¥”9ç¤”RJ)¥”ÈA¥”RJ)¥DÒI)¥”RJ)¥qPJ)¥”RJ)¡”RJ)¥”RJ	¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ\\000&\\000P	6Î°’tV8\\\\hÈJ\\000 7\\000\\000PŠ9Æ$”JH%„Jå„ÎI	)µVB\\\
­„\\\
:h£RK­•”JI™„B(¡„RZ)%µR2¡„PJ!¥RJ	¡ePB\\\
%””RI-´TJÉ „PZ	©•ÔZ\\\
%•”A)©„’R*­µ”JJ­ƒÒR)­µÖJJ!•–R¥¤–R)¥µJk­µNR)-¤ÖRk­•VJ)¥”JI­µ–Zk)¥VB)­´ÒZ)%µÖRk-•ÔZK­¥ÖRk­¥ÖJ)%¥–Zk­µ–Z*)µ”B)¥•’Bj©¥ÖJ*-„ĞRI¥•VZk)¥”J(%•”Z*©µ–Rh¥…ÒJI%¥–J*)¥ÔR*¡”R*¡•ÔRk©¥–J*-µÔR+©”–JJ©\\000\\000tà\\000\\000`D¥…ØiÆ•GàˆB†	(\\000\\000\\000ˆ™@ \\000\\\
d\\000ÀB‚\\000PX`(]è‚\\\"HA\\\\8qã‰NèĞ\\000ˆ™\\000¡\\\"$dÀE…t\\000°¸À(]è‚\\\"HA\\\\8qã‰NèĞ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\†ÆG‡ÇHˆ\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000€OggS\\000m\\000\\000\\000\\000\\000\\0002\\\\\\000\\000\\000\\000\\000Wy5éyfddhde\\\\XMTJµ÷ )]a¯š¾\\\
‚·-¥¥”RªÖü_~Ë¾^ıüïq¦zïÜë˜çyNê&o?hr»ûa&±$¡1m&Ÿ?5õã3\\\
üÑSSÂ¿2ßú\\\"±¯ŸÉŸÏŸß–OO­|NGùÿGî_‘Œ+O¬ÿjÜ¬p”p´4ÿË:\\000V±+Ôƒ@§>wäAc”Nu)³|kwëR?Ë½O'|ÁP}Ş§¦Ëg	KM_f|ÕA,SÅ÷SÆ[³ò¥ØºÃˆÕæi£Î´OŞYX£s,¦xyÛÜV?c'iŒu¡¨h¬ß%BÊì\\\"ZI>ëk§,²Ù…’¶Z.‰\\\\ÿLûµè6[\\\
\\000~£–²Q Óİg±TnaìóëùøØÓ«Æüø¶°óÍå5D=Ø2ÆG2nc›u³akûùŒ¸èË˜ç¤é¢‹è¶´(ÎR8§´r3ß%Ï··­KÍ]’k1¡mÏL²xãj\\000–›ØÚ%9t|?U„<”Z©zşß{tÇ“¦Z{tUÖ¹Q5G$å/”ª¼×Í›¶Û$Úöİ×Œp¾¶)õ\\000\\\
ùíÓTşü€\\000~ïº»=ç†øñ!Ú(×C·A“\\000§¤2hÊèô¼ÌNEÛfä*[ŠjnõDó>GŒíóN:*·9İe&SWü€õsÏ¿7gç<-Ü&äF©­©×?‰)–võô”BŸ¼[%o}’,£àFÇHƒ\\\
$°®¶%¥Õ\\000‚£¤ò‰ÍxéŞıdT	b>9/éqmù²<É-¢¶ô}{v6µè›±œ†è!7ö`§²Éël¿NÔšmÒa-YÛÆ‡/=!`Ü¬‘½\\\"ôbiİ¯Š ÆIÈßÚmXµ~n§\\0000ûæXJ,†›Iß»y¹‚.öm«ÒÁf>çZù>ï-®¦M±>ß7<ÏÅ±ÂXwmb¾ê:¾±Cê¬n¨HÔ«¹MQ¸É˜i™c5‹œ…¿=¶å`ÃUÖ‹ì×¼KšQ…@Zm87¨v‘IÏİª›â.ÎÇd\\000”ÆäEó§o¶ô^ë¬M{+ö—ŠUs1vÍ¡-„í+å=Uq¬¾_@¡#ï]éñmh<Œëû¨•ñ@Ş„[L?ïÁA8nAzSt	\\000e»ê‹e\\000r‰w†Tâ+Lº˜§òÄÀãsk™óÎz»=qû]Ûºeals¤‰Ú­k;ŠOßFXæ–aZº.‡K†˜Œ‘Ãú—æ›>¡ĞË,x{¬-5ó·\\\
…>š6f(\\000NyÂc\\\\`îj¿N~Àd5\\000@y3Ÿí–õ·eYëŞûBêC‘*™ùãøüùÙ Ã\\\\5ĞŒ©áe\\rE7¡O»²„sÉè™À¼˜[È'fÁfj`\\\
\\000ZcsvÖhØl}{:ü=S×@ÒäÉÈœÏÖ÷‘{óŠHıœQÀWŸ?ÕKäµµîÇ|tÀúLèôËãbkkÅ„À½clŞ=0Ud\\\\v“I\\000\\0007kî™ƒ·Ì\\\\GíŞW½˜&#ºª}éùëW…óÅ)n¾ÚÈçªuÙêk]'Ş*ÊòÛÀ‹Gq\\\\5Zaæg¾$»8&»šœ´¨‹È=`ƒ\\000\",\
    [ \"lib/gameinstance.lua\" ] = \"-- game instance object\\r\\\
-- returns a function that resumes the game state for 1 tick and returns event info\\r\\\
\\r\\\
local Mino = require \\\"lib.mino\\\"\\r\\\
local Board = require \\\"lib.board\\\"\\r\\\
local gameConfig = require \\\"config.gameconfig\\\"\\r\\\
\\r\\\
local GameDebug = require \\\"lib.gamedebug\\\"\\r\\\
local cospc_debuglog = GameDebug.cospc_debuglog\\r\\\
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
\\r\\\
	return game\\r\\\
end\\r\\\
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
function GameInstance:Initiate(mino_table, randomseed)\\r\\\
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
	}                        -- 1 = mini spin\\r\\\
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
	self.width = gameConfig.board_width + 10\\r\\\
	self.height = math.ceil(self.state.board.visibleHeight * 0.666)\\r\\\
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
	board.x = 7 + self.board_xmod\\r\\\
	board.y = 1 + self.board_ymod\\r\\\
\\r\\\
	queueBoard.x = board.x + board.width + 1\\r\\\
	queueBoard.y = board.y\\r\\\
\\r\\\
	holdBoard.x = 2 + self.board_xmod\\r\\\
	holdBoard.y = 1 + self.board_ymod\\r\\\
\\r\\\
	garbageBoard.x = board.x - 1\\r\\\
	garbageBoard.y = board.y\\r\\\
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
	if (self.state.spinLevel == 3) or (self.state.spinLevel == 2 and gameConfig.spin_mode >= 2) then\\r\\\
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
function GameInstance:Render(doDrawOtherBoards)\\r\\\
	self.state.board:Render(self.state.ghostMino, self.state.mino)\\r\\\
	if doDrawOtherBoards then\\r\\\
		self.state.holdBoard:Render()\\r\\\
		self.state.queueBoard:Render(table.unpack(self.state.queueMinos))\\r\\\
		self.state.garbageBoard:Render(self.state.garbageMino)\\r\\\
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
	--	local holdBoard, queueBoard, garbageBoard = self.state.holdBoard, self.state.queueBoard, self.state.garbageBoard\\r\\\
\\r\\\
	self.didJustClearLine = false\\r\\\
\\r\\\
	local didCollide, didMoveX, didMoveY, yHighestDidChange = mino:Move(0, self.state.gravity, true)\\r\\\
	local doCheckStuff = false\\r\\\
	local doAnimateQueue = false\\r\\\
	local doMakeNewMino = false\\r\\\
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
						self.state.backToBack = self.state.backToBack + 1\\r\\\
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
					cospc_debuglog(nil, \\\"Doled out \\\" .. garbage .. \\\" lines\\\")\\r\\\
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
			mino.board:IsSolid(mino.x, mino.y + mino.height),\\r\\\
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
\\r\\\
	if control:CheckControl(\\\"pause\\\", false) then\\r\\\
		self.state.paused = not self.state.paused\\r\\\
		control.antiControlRepeat[\\\"pause\\\"] = true\\r\\\
	end\\r\\\
\\r\\\
	if self.state.paused or not mino.active then\\r\\\
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
			mino:Move(0, self.state.gravity * self.clientConfig.soft_drop_multiplier, true, false)\\r\\\
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
			--self.state.topOut = true\\r\\\
			self.message.quit = true\\r\\\
			control.antiControlRepeat[\\\"quit\\\"] = true\\r\\\
			didSlowAction = true\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	if control:CheckControl(\\\"rotate_ccw\\\", false) and gameConfig.can_rotate then\\r\\\
		_, _, kick_count = mino:RotateLookup(-1, true, self.mino_rotable)\\r\\\
		if mino.spinID <= gameConfig.spin_mode then\\r\\\
			self.state.spinLevel = self:CheckSpecialSpin(mino, kick_count)\\r\\\
		end\\r\\\
		control.antiControlRepeat[\\\"rotate_ccw\\\"] = true\\r\\\
	end\\r\\\
	if control:CheckControl(\\\"rotate_cw\\\", false) and gameConfig.can_rotate then\\r\\\
		_, _, kick_count = mino:RotateLookup(1, true, self.mino_rotable)\\r\\\
		if mino.spinID <= gameConfig.spin_mode then\\r\\\
			self.state.spinLevel = self:CheckSpecialSpin(mino, kick_count)\\r\\\
		end\\r\\\
		control.antiControlRepeat[\\\"rotate_cw\\\"] = true\\r\\\
	end\\r\\\
	if control:CheckControl(\\\"rotate_180\\\", false) and gameConfig.can_rotate and gameConfig.can_180_spin then\\r\\\
		_, _, kick_count = mino:RotateLookup(2, true, self.mino_rotable)\\r\\\
		if mino.spinID <= gameConfig.spin_mode then\\r\\\
			self.state.spinLevel = self:CheckSpecialSpin(mino, kick_count)\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	return didSlowAction\\r\\\
end\\r\\\
\\r\\\
function GameInstance:Resume(evt, doTick)\\r\\\
	local mino, ghostMino, garbageMino = self.state.mino, self.state.ghostMino, self.state.garbageMino\\r\\\
	self.message = {} -- sends back to main\\r\\\
	local doRender = false\\r\\\
\\r\\\
	self.control:Resume(evt)\\r\\\
\\r\\\
	if evt[1] == \\\"key\\\" and not evt[3] then\\r\\\
		self.control.keysDown[evt[2]] = 1\\r\\\
		self.didControlTick = self:ControlTick(false)\\r\\\
		self.state.controlTickCount = self.state.controlTickCount + 1\\r\\\
		doRender = true\\r\\\
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
			self.state.controlTickCount = self.state.controlTickCount + 1\\r\\\
			if not self.state.paused then\\r\\\
				self:Tick(message)\\r\\\
				self.state.gameTickCount = self.state.gameTickCount + 1\\r\\\
			end\\r\\\
			self.didControlTick = false\\r\\\
			self.control.antiControlRepeat = {}\\r\\\
\\r\\\
			doRender = true\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	if self.state.topOut then\\r\\\
		-- this will have a more elaborate game over sequence later\\r\\\
		self.message.gameover = true\\r\\\
	end\\r\\\
\\r\\\
	if doRender then\\r\\\
		-- handle ghost piece\\r\\\
		ghostMino.color = \\\"c\\\"\\r\\\
		ghostMino.shape = mino.shape\\r\\\
		ghostMino.x = mino.x\\r\\\
		ghostMino.y = mino.y\\r\\\
		ghostMino:Move(0, self.state.board.height, true)\\r\\\
\\r\\\
		garbageMino.y = 1 + self.state.garbageBoard.height - self.state.incomingGarbage\\r\\\
\\r\\\
		self:Render(true)\\r\\\
		--GameDebug.profile(\\\"Render\\\", scr_y-3, function() self:Render(true) end)\\r\\\
		if true then\\r\\\
			term.setCursorPos(self.state.board.x, (self.state.board.y) * 2 + self.height)\\r\\\
			term.setTextColor(colors.lightGray)\\r\\\
			term.write(\\\"Lines: \\\")\\r\\\
			term.setTextColor(colors.yellow)\\r\\\
			term.write(self.state.linesCleared)\\r\\\
		end\\r\\\
	end\\r\\\
\\r\\\
	return self.message\\r\\\
end\\r\\\
\\r\\\
return GameInstance\\r\\\
\",\
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
}\\r\\\
\",\
    [ \"sound/mino_O.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000ı^\\000\\000\\000\\000\\000\\000svorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000ı^\\000\\000\\000\\000\\000d“,Dÿÿÿÿÿÿÿÿÿÿÿÿšvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000€ \\\
Æ€ĞU\\000\\000\\000\\000BˆFÆP§”—‚…GÄP‡óPjé xJaÉ˜ôkBß{Ï½÷Ş{ 4d\\000\\000\\000@bà1	B¡Å	Qœ)Ba9	–r:	B÷ „.çŞrî½÷\\rY\\000\\000\\0000!„B!„B\\\
)¥RŠ)¦˜bÊ1ÇsÌ1È ƒ:è¤“N2©¤“2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊcŒ1ÆcŒ1ÆcŒ1ÆBCV\\000 \\000\\000„AdB!…RŠ)¦sÌ1Ç€ĞU\\000\\000 \\000€\\000\\000\\000\\000G‘É‘É‘$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û—}ÛwuÙ·}ÙvuY—eYwm[—uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9’#)’„†¬\\000d\\000\\000\\000à(â8’#9–cI–¤IšåYåi&j¢„†¬\\000\\000\\000\\000\\000\\000\\000\\000 (Šâ(#I–¥išç©(Š¦ªª¢iªªªš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš@hÈ*\\000@\\000@ÇqÇQÇqÉ‘$	\\rY\\000È\\000\\000\\000ÀPG‘Ë±$ÍÒ,Ïò4Ñ3=W”MİÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ€ĞU\\000\\000\\000\\000 ˆB†1 4d\\000\\000\\000€¢‘1Ô)%Á¥`!Ä1Ô!ä<”Z:RX2&=Å„Â÷Şsï½÷\\rY\\000\\000\\000FƒxL‚B(FqBg\\\
‚BXN‚¥œ‡N‚Ğ=!„Ë¹·œ{ï½BCV\\000€\\000\\000B!„B!„BJ)…”bŠ)¦˜rÌ1Çs2È ƒ:é¤“L*é¤£L2ê(µ–RK1Å[n1ÖZkÍ9÷”2ÆcŒ1ÆcŒ1ÆcŒ1‚ĞU\\000\\000\\000\\000aA„BH!…”bŠ)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I’,É’4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeİÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäHŠ¤\\000¡!«\\000\\000\\000\\000\\0008Š£8äHåX’%i’fy–gyš§‰šè¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(Š¢8ŠãH’eišæyª'Š¢©ªªhšªªª¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš&²\\\
\\000\\000\\000ĞqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000€\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç“<É³<Çs<É“4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000€ Ç´ƒ$	„ ‚äÄÄ¤… ‚ä:%Åä!§ bä9É˜Aä‚ÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥“9ç¤tR¡¥Rg©´ZbÌ(•ÚR­\\r„RH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,„BCV\\000Q\\000\\000„1H)¤bŒ9ÈDŒ1èd†1!sNAÇ…T*uPRÃsA¨ ƒT:G•ƒPRG\\000\\000€\\000\\000€\\000¡Ğ@œ\\000€A’4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUİvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×•eÓumÙue[WeYø5U•eÓumÙt]ÙveW·UYÖmÑu}]•eá7eÙ÷e[×}Y·•at]ÛWeY÷MY~Ù–…İÕu_˜DQU=U•]QU]×t][W]×¶5Õ”]ÓumÙT]YVeY÷]WÖuMUeÙ”eÛ6]W–UYöuW–u[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}U–u_Öua˜uÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_•máXeÙøuá–[×…ßs]_WmÙVÙ6†İ÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^İ6êÆO¸ß¨©ª¯›®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VY†Õ–…aÖuaÙ…a©Úº2¼ºo¯­+ÃíßW†ªmË«ÛÂ0û¶ğÛÂo»±3\\000\\0008\\000\\000˜P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEU•eÕ•eYu]]MÓ•EÕteÓT]Yu]WV]W–%M3MÍóLSó<Ó4UÓ•MSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓ–MS•eÓUmÙUeW–]Ù¶MU•eS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨š²kšªl«ªª»²kë¾,Ë¶,ªªëš®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï™¦,›ª)Û¦ªÊ²,»¶mË²/Œ¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À€\\000@€	e Ğ•\\000@\\000\\000`cŒAh”rÎ9RÎ9!sB©dÎA¡¤Ì9¥¤”9¡””B¥¤ÔZ¡””Z+\\000\\000 À\\000 ÀM‰Å\\\
\\rY	\\000¤\\000GÓLÓueÙËEU•eÛ6†Å²DQUeÙ¶…cEU•eÛÖu4QTUY¶mİWSUeÙ¶}]82UU–m[×}#U–m[×…¡’*Ë¶më¾QI¶m]7†ã¨$Û¶îû¾q,ñ…¡°,•ğ•_8*\\000\\000ğ\\000 VG8),4d%\\000\\000\\000¤”QJ)£”RJ)Æ”RŒ	\\000\\000p\\000\\0000¡²\\\"\\000ˆ\\000\\000œsÎ9çœsÎ9çœsÎ9çœsÎ9çcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1Æ\\000ìD8\\000ìDX…†¬\\000Â\\000\\000„‚’R)¥”9ç¤”RJ)¥”ÈA¥”RJ)¥DÒI)¥”RJ)¥qPJ)¥”RJ)¡”RJ)¥”RJ	¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ\\000&\\000P	6Î°’tV8\\\\hÈJ\\000 7\\000\\000PŠ9Æ$”JH%„Jå„ÎI	)µVB\\\
­„\\\
:h£RK­•”JI™„B(¡„RZ)%µR2¡„PJ!¥RJ	¡ePB\\\
%””RI-´TJÉ „PZ	©•ÔZ\\\
%•”A)©„’R*­µ”JJ­ƒÒR)­µÖJJ!•–R¥¤–R)¥µJk­µNR)-¤ÖRk­•VJ)¥”JI­µ–Zk)¥VB)­´ÒZ)%µÖRk-•ÔZK­¥ÖRk­¥ÖJ)%¥–Zk­µ–Z*)µ”B)¥•’Bj©¥ÖJ*-„ĞRI¥•VZk)¥”J(%•”Z*©µ–Rh¥…ÒJI%¥–J*)¥ÔR*¡”R*¡•ÔRk©¥–J*-µÔR+©”–JJ©\\000\\000tà\\000\\000`D¥…ØiÆ•GàˆB†	(\\000\\000\\000ˆ™@ \\000\\\
d\\000ÀB‚\\000PX`(]è‚\\\"HA\\\\8qã‰NèĞ\\000ˆ™\\000¡\\\"$dÀE…t\\000°¸À(]è‚\\\"HA\\\\8qã‰NèĞ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\†ÆG‡ÇHˆ\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000€OggS\\000Ú\\\"\\000\\000\\000\\000\\000\\000ı^\\000\\000\\000\\000\\000•%[ñVHLW_LbfDD><BBOME?3VŸ«¦3d÷¶µMö#\\000Ğ¦=¡B ¦¶e¡¾T¬¾sîöøöÅõDÆüta`O\\000\\000ñåĞàO÷G\\000ğ3Ë_\\000ÌŸC	`]Z\\r€U”¾o(C\\000n¯Õ{]‚6ñµšC›ğ\\0008\\000iP{Èn¿„€¦iÜ\\000s¾¸Äç×y\\\\¹wæVÈ\\000†¸%z¤™VøÀ~R€¯à Ù\\000f«+âxÜ\\000„ö§\\000ÀÒ>z¨è€\\000³‚ì}ğ®\\000ÀÙg\\000ıu%\\000°Çà9ÛZ§7øÀØÕQVğnÓ«»AÖ0\\\\\\000Z«rÒZ@ıÙæ`\\000@¸\\000 lc©Ğöíù?ïù»ç‘\\000¨«ZÇ\\000KÁ¤påÀG€¹ï¬¬£ø9€i@¯[f@0†|0cf€±\\000b8ï¾-<¦“¹ØEªªD\\000¨¤\\000\\000ìcd}{ÿ{—4m»ç4S¨W€ÑDÀ·Sàvœø*æÄGÂ,‹Æ8å¬Ş¢’Àèqu_³¨\\000ËüØV^«ÔZ/ßÄiº’ meIz\\000Lcë÷ÿÖ5­İmÏ–\\000 y#2nïÌÉYi\\\
\\000¿§¾e\\000ÜxH\\000¥èè6µpu@ĞZ¡d‰kpS¸\\0004å½\\0008<ZöÁ3“y–í]–_Úêü*ÁDÏ\\000WµY€ş#\\000.ÖnÀÆaBÓ10fPĞô5öJìDÀó¦½ÃºY³XìE»=›ğÄè'\\000RŸ+Œvg(um<¢†¾KŞŸO‚€³Åé1“ÿ&´×vo+qüíµ\\\"+ôí)Æª öWÁÍ!ô¥\\\\‹À»0°[-°üŠ|iEºÌI¸pÔ1¨1ˆ~~2P¯8–ãÓ\\\
cvu?\\000^¥}&7òä’<€şöáK\\\\€\\000‚Z`šh3\\000\\0000\\000æê»\\000îà`XI<H@	”ÃØ0ëÀ%¾@@”C?t\\000:™+„•|/TC€1T€VPÓP{ƒ\\\
v8»˜€é+˜;’°Öğï€÷ˆß<Ş#vK€5ì`ØÖ‰]à0{Ûà'½–8Ù¡Ô’}NjËXŠzHÃõ¸8r»óÜu-<u\\rıª\\000¬Ñ(@1`ƒ:\\000·g‚À-¥¹íS8şih œ¡@´:Ø9Í\\r’Óp:\\000gÁÀÖ<HPÙà†\\\"°eüHÂËŒ€j˜Á(´\\000}³E-)ˆ°oÚ*BŞ<î2ÚStzHèsô!€íà%æ_€zÀ–ö\\\\Bcƒ¸¤Ó\\000\\000u8Õ]8~«×À	\\000PnSƒbÖtvÏ.¸Î5• cßV9ËÂQĞÃ«Ñ±K‡ø<0¤X\\000³~5`\\000wêW\\000·V	\\000(=\\000¶1‰f&·YÕº}	€ª\\000œ]Ò`[‰‡Á+¯Y¨‘â7’å›aFuœÁ ~UU’¼½+àr€=\\000yÒ\\000ø}Íà€¤¬ÑA“áY¢Zó®Ë›Ãğãòy%ğ¡Ï‰ğyœÌL²’ŒØ‡İ\\000l±?\\\\ãò‡–Á¶ƒ>àÒ‚ÀÉÆá†[eau’æ€Ş-ˆy\\000o°UÍÚ¬ç^í^mÂœ1—Àvè2¨C¨‹dá``’Pƒª }Úy*¨|‡VĞÎÎ–‚\\000g¹5€~P‡Ğ­Jª2\\000k{ô	ì˜i^`;Öi°-_bĞpYCF¬\\\
v¨XÃ:±+øÃ\\000Œ?W¨€ƒğ•1\\000êŞ4M;ö<²!';É†g1@¯CU±îø€@ Ó\\000\",\
    [ \"sound/mino_S.dfpwm\" ] = \"@Šÿ?\\000 ıÿ¯\\\"\\000@Ûÿ_E\\000 Úı_ Úı_% Úş¯J Úö_•Àªı_U	€ªö­\\000Uû«\\000ªöÿª\\000ÔÚÿ­\\000ÔêÿV•\\000¨ZÿW•\\000P«ÿWU jÿ¯•@Õşß*@Õş_+€ªıßª€ªõ+€´ú¿U	\\000Uëÿª\\000ªëÿª\\000ªíÿª\\\"\\000ªíÿš\\000ªíÿª\\000ªmÿUI\\000T»ÿUI\\000T»ÿUE\\000Xëş«’\\000¨¶ı¯PmÿW%	 ÖıW• Öõ_)	 ¶í_)@m÷¿”@µÛ¥€jÛÿªD\\000ªõÿJ)\\000UİÿJE\\000ÔuÿK%\\000R«ÿ«4¨®ÿ•’p[ÿW\\\
\\000 ¶ÿÿª\\000\\000ˆú·õ¢ªzHR	Ôÿöo\\000@iûÿ+ @òw­_Dªê¢T•Pÿªß”\\000@ÕÖÿW*RßÖüDYU$U’ı¯ŞR\\000Z]ÿ_IA	úZí/RM5\\000ÕJîÿªJB\\000èëú	IT€úNÕ¿(µ¬\\000T+ºÿ¯*$\\000`oİÿS$Qj·ªş£ªÒ\\000­Òıÿ*!	\\000í¶û_%B@İªê-E5\\000P³îÿ¯$\\000´¶ÎÿUIT\\000´¦™ÿ[UÔ\\000À¬²ÿoe”\\000PUkÿ¿”$`«ªş©@S­ıÿ•\\\"\\000«ºûÿR’€¶ªó«¢\\000iUÍÿ¯’H\\000Tu¯ÿOi\\000´­¬ÿ+U¢\\000¨j­ÿ?%¡\\000(×6ş¯$Gh‡Rş×kK\\000J©ıÿ7\\000\\000Uûÿ¿\\\
\\000`ÿ]ë€J5¾[UUÕú ’\\000¨û_U\\000\\000©Úÿ_5%\\000¨jı¿­@AUÿj½\\\
 ª†­’Q­÷Ëˆ\\000èºû¿&„\\000¤úıo-\\000Rµıo-	@˜Úş¶«ª´«)jû·Õ¨j÷©B\\000H»ıßZ\\000Rµÿ·U	\\000Jµÿİj %í­Zjë¿jŠ\\000Rµû_š\\\"\\000ÔvÿW‹\\000Uíÿ«%	€T·ÿ­)ÔöUHmû¯UB\\000ªµÿW\\000ÕzÿkI@i·ÿ­´îÿªŠ\\000$­õ¿VJ\\000TÕıßR\\\"\\000©êş¯ª€˜]ÿ«V U×ÿU¨Òö•JPÕû¿5!\\000dJı_U)¨Z»ş\\000ÀÚÿÿWI\\000\\000TÛÿÿ™\\000’(èo­R´*Õú/ Q€RıÿW•\\000TëşıU¢Ô ßª’â´j×ß\\000H€ªõÿ_‰\\000¶ı÷WJ •‚~­JŠWÕ¶? 	ªºÿßJ’\\000@µİ·© T)pÕš²şiÕ¼\\000)uuÿ_%Q\\000Õ¶[ÿWE)#\\000*Ûºû¿J¢„\\000hİzû?¥”¢\\000PÕÚ÷ÿ«J‚\\000@Õõıÿ’”H`kÕëÿL1@Í¦×ÿK•\\\
\\\
€N«İÿ+e	\\000­6·ÿ¯d\\000]m½şOI¡(\\000İºÒşŸTÉ$\\000lÕªûÿU!)\\000 «¦ûÿR…¤\\000 V«÷ÿ7…@W½åÿSZ ~£êÿŠ¼D`©µÿû/I\\000 ª½ÿªH\\000­m÷ÿTR@T½ö_ZS)€VØÚ¿TmS\\000*y±ÿ“šj\\000¤Ö¹ÿ•IT\\000ÔÖkÿS•\\000°»«ÿ+¡ ¶Ûş¯¢H@Õ®ÿ¿)%€´Úş¿K¥\\000©YëÿNU	\\000ªTíÿ-­\\000TÕÚÿ—*%\\000¨ÕÚÿ7JJ\\000Èµ¶ÿW”PÛ¶ş_I ¶mı¿%@[Ûú¿IJ@­­ı¿J’€º¶õ“¤(\\000Ú¶æÿJ‰\\000ÖZ×ÿ+‘H\\000ê¶–ÿKEÊ\\000¨Õ–ÿ/%I`kkÿ¯\\\"h½6ş/Y²ÀÊfû¿š\\\
€ZëúÿR\\\"	€­[õRU\\000(­ıÿ+E\\\"\\000š®Úÿ«FT\\000hº]ÿ“\\\\Å\\000P¬òÿ¯D\\\\µnüVú‹\\000R­ÿ¿*\\000üÍªàjÕ@UÿU\\000ôWkkJÿ4 Rúß­Ğ7­\\rÖ’~Õ¨€Jê·\\\
P k+P%ù¯¥ˆÊÿÛ@BüëZAJéoKH*ÿ»j€ñ¯Uª’ÿ*@©ü¿Z$ÑÕ°’şWV\\000*ésP‘ÿ©5€ıOµ\\000¬èj`Iş«Z\\000+é?³P¥ÿªV\\000KúOuT©ÿÌ@•ş§º\\000ªä?ÕP¥ş3[\\000¥òŸµP¥ÿT@UúÏÚ\\000”ÉÖP•şen\\000Ué_Óªÿª6\\000UùÏj¨ªÿª\\r€4ıW]\\000Tõ?Õ@-ÿ3\\000UõŸµHÍ•\\r@UıWµ\\000¨ÖÕ\\\
€ZÿS-\\000jı¯² ÚU+\\000ÙúWY¨í¿Ê\\\
€ZÿU-\\000jûWe¨¶ÿJ\\000Õş§Y¨í_¦	PµÿªL\\000UûWe	 n•@õş§)¤í_M l¥”€êŞŸ¢¨¾ÿ’ µı­(U÷¯Š\\\"@º¿*A·Û'‚Öı_… êşUSVé))¸ë~Â½í†İº?”\\\
A­ß£kUJO¶ÕZ£Z@UÕú¾¥$ ‰z¿k‰D@kİ¾-IÒª´ê*‹HËè¯j…IûÖ7B%`«Şµ–B5 MõŞÚ%J@Õò{i…(TŞª7RK¢­¬åVŠUAVívU%Š ®µ{%E)Tkk»”J)ªZk/)U\\\
µµÕ+)%Ekmí)J%am[ëJIITkm»JJ)¨­¶^¥¤jµ¶WR•DUkÕ«”*I­ÚÚ)¥R¢­µz%%•¨­µ^%¥$j­­])¥jµÕ«ª¤BµªìUªªÒªVµJiÔ­{=%‘P»mßê$	iVÑŞT¥ÊUU«+¨¢mÛ÷R\\\")‚ÜmıÖI$TµF{SJ•ÖÔZO	\\\"%µí»WJ’V·õšN’¨ªíšRUº–Z]\\\
$Yj[ß]’”²m«[µR$µ²¨«©ª¹URÕR\\\"«Y­õª¤T©ÄjµZÕUIU¥¢jU­ÖU¥RU‰ªV­ZW•J•ŠªVµVO¥J•JªÕªZ]•JUªV«j=•ªT)²Z­Z=•*Uª°Z«ªu•*U©°Z­ªvU©T•Èj­ªõJ©T©ÄZµªÕU¥R•¢ªµªÚU¥RU’ªÕªVO•R©ŠªÕªZO•J¥JªV«V]UEi)ªÚVj])UU¥´*eÚºê–”T(ªu«íU’¤*dµ­Z·R©R¤Òªµ[UU© MËj]•ªUI•–ª¶ª¦UCªªj]U•©µZ­zJJU\\rµ¶¬ô*©ªJTµZëUJ¥Tmµµ§$U)ÔÚªªW¥²T¤ªU­×TªTÈj­Z7%¥©¢µV¥®J•U…U«ªm¥R¥’Z­Zí””ªŠZ[™ÚªRUUUµêZª*%YÕªêªTUUÔªªÊµTÕR)UKÕ®ªªT¡VÍZ])U•R­ª*·Òªª‚¬*m½ªR¥„UkÕºJ©ÊmUiyUUU	UÕªõ–J¥imUk+•ªRÔjUÕM•UªP«ªÖ®ªTJ¢ÍV«”*UÅZUU[U•ªD­jU½JU)EÕªV½ªT”Šv­¥ÒR­«\\\
’Tmı®RH•ìZU•UU®*©XUu«U‰¥¨«j•ZUºJ¥bUÕ›ªÍR¯RUX­òM•B­ªo™	Y•¾­JAUê[­ªJoUU¨ªêUU…ª*ß¬*ÔJíJ-¡µ´§ªjU}ÓJ¨ªêUU‰ªª]UªRíU«D•Ê­j%UUmª•¨ªê¥VEUU­ª*©UõT•¢ªªWUYiuªª¢ZÕUU‰ªªjUTUÕ©ªŠjUW•*ªjuU©¡ZUWª*ªU]Uª0«ÕU¥†ªV]©ª¨VuU©¢¬UW•*ªZu¥ª¢ZÕU¥ŠªV]Uª¨Zµ™ªŠZUW•*ªZuU©RZÕªªJjU]¥ª¨jµZ©JiU«ª*UU­ªªRZÕªª*UU­ªÊTU³ªªLUU«ªªTUµª*SU­ªª4UU­ªÊRUS³\",\
    [ \"sound/mino_J.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000§g\\000\\000\\000\\000\\000\\000Ñ•~ïvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000§g\\000\\000\\000\\000\\000e#CDÿÿÿÿÿÿÿÿÿÿÿÿšvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000€ \\\
Æ€ĞU\\000\\000\\000\\000BˆFÆP§”—‚…GÄP‡óPjé xJaÉ˜ôkBß{Ï½÷Ş{ 4d\\000\\000\\000@bà1	B¡Å	Qœ)Ba9	–r:	B÷ „.çŞrî½÷\\rY\\000\\000\\0000!„B!„B\\\
)¥RŠ)¦˜bÊ1ÇsÌ1È ƒ:è¤“N2©¤“2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊcŒ1ÆcŒ1ÆcŒ1ÆBCV\\000 \\000\\000„AdB!…RŠ)¦sÌ1Ç€ĞU\\000\\000 \\000€\\000\\000\\000\\000G‘É‘É‘$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û—}ÛwuÙ·}ÙvuY—eYwm[—uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9’#)’„†¬\\000d\\000\\000\\000à(â8’#9–cI–¤IšåYåi&j¢„†¬\\000\\000\\000\\000\\000\\000\\000\\000 (Šâ(#I–¥išç©(Š¦ªª¢iªªªš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš@hÈ*\\000@\\000@ÇqÇQÇqÉ‘$	\\rY\\000È\\000\\000\\000ÀPG‘Ë±$ÍÒ,Ïò4Ñ3=W”MİÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ€ĞU\\000\\000\\000\\000 ˆB†1 4d\\000\\000\\000€¢‘1Ô)%Á¥`!Ä1Ô!ä<”Z:RX2&=Å„Â÷Şsï½÷\\rY\\000\\000\\000FƒxL‚B(FqBg\\\
‚BXN‚¥œ‡N‚Ğ=!„Ë¹·œ{ï½BCV\\000€\\000\\000B!„B!„BJ)…”bŠ)¦˜rÌ1Çs2È ƒ:é¤“L*é¤£L2ê(µ–RK1Å[n1ÖZkÍ9÷”2ÆcŒ1ÆcŒ1ÆcŒ1‚ĞU\\000\\000\\000\\000aA„BH!…”bŠ)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I’,É’4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeİÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäHŠ¤\\000¡!«\\000\\000\\000\\000\\0008Š£8äHåX’%i’fy–gyš§‰šè¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(Š¢8ŠãH’eišæyª'Š¢©ªªhšªªª¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš&²\\\
\\000\\000\\000ĞqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000€\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç“<É³<Çs<É“4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000€ Ç´ƒ$	„ ‚äÄÄ¤… ‚ä:%Åä!§ bä9É˜Aä‚ÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥“9ç¤tR¡¥Rg©´ZbÌ(•ÚR­\\r„RH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,„BCV\\000Q\\000\\000„1H)¤bŒ9ÈDŒ1èd†1!sNAÇ…T*uPRÃsA¨ ƒT:G•ƒPRG\\000\\000€\\000\\000€\\000¡Ğ@œ\\000€A’4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUİvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×•eÓumÙue[WeYø5U•eÓumÙt]ÙveW·UYÖmÑu}]•eá7eÙ÷e[×}Y·•at]ÛWeY÷MY~Ù–…İÕu_˜DQU=U•]QU]×t][W]×¶5Õ”]ÓumÙT]YVeY÷]WÖuMUeÙ”eÛ6]W–UYöuW–u[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}U–u_Öua˜uÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_•máXeÙøuá–[×…ßs]_WmÙVÙ6†İ÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^İ6êÆO¸ß¨©ª¯›®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VY†Õ–…aÖuaÙ…a©Úº2¼ºo¯­+ÃíßW†ªmË«ÛÂ0û¶ğÛÂo»±3\\000\\0008\\000\\000˜P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEU•eÕ•eYu]]MÓ•EÕteÓT]Yu]WV]W–%M3MÍóLSó<Ó4UÓ•MSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓ–MS•eÓUmÙUeW–]Ù¶MU•eS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨š²kšªl«ªª»²kë¾,Ë¶,ªªëš®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï™¦,›ª)Û¦ªÊ²,»¶mË²/Œ¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À€\\000@€	e Ğ•\\000@\\000\\000`cŒAh”rÎ9RÎ9!sB©dÎA¡¤Ì9¥¤”9¡””B¥¤ÔZ¡””Z+\\000\\000 À\\000 ÀM‰Å\\\
\\rY	\\000¤\\000GÓLÓueÙËEU•eÛ6†Å²DQUeÙ¶…cEU•eÛÖu4QTUY¶mİWSUeÙ¶}]82UU–m[×}#U–m[×…¡’*Ë¶më¾QI¶m]7†ã¨$Û¶îû¾q,ñ…¡°,•ğ•_8*\\000\\000ğ\\000 VG8),4d%\\000\\000\\000¤”QJ)£”RJ)Æ”RŒ	\\000\\000p\\000\\0000¡²\\\"\\000ˆ\\000\\000œsÎ9çœsÎ9çœsÎ9çœsÎ9çcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1Æ\\000ìD8\\000ìDX…†¬\\000Â\\000\\000„‚’R)¥”9ç¤”RJ)¥”ÈA¥”RJ)¥DÒI)¥”RJ)¥qPJ)¥”RJ)¡”RJ)¥”RJ	¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ\\000&\\000P	6Î°’tV8\\\\hÈJ\\000 7\\000\\000PŠ9Æ$”JH%„Jå„ÎI	)µVB\\\
­„\\\
:h£RK­•”JI™„B(¡„RZ)%µR2¡„PJ!¥RJ	¡ePB\\\
%””RI-´TJÉ „PZ	©•ÔZ\\\
%•”A)©„’R*­µ”JJ­ƒÒR)­µÖJJ!•–R¥¤–R)¥µJk­µNR)-¤ÖRk­•VJ)¥”JI­µ–Zk)¥VB)­´ÒZ)%µÖRk-•ÔZK­¥ÖRk­¥ÖJ)%¥–Zk­µ–Z*)µ”B)¥•’Bj©¥ÖJ*-„ĞRI¥•VZk)¥”J(%•”Z*©µ–Rh¥…ÒJI%¥–J*)¥ÔR*¡”R*¡•ÔRk©¥–J*-µÔR+©”–JJ©\\000\\000tà\\000\\000`D¥…ØiÆ•GàˆB†	(\\000\\000\\000ˆ™@ \\000\\\
d\\000ÀB‚\\000PX`(]è‚\\\"HA\\\\8qã‰NèĞ\\000ˆ™\\000¡\\\"$dÀE…t\\000°¸À(]è‚\\\"HA\\\\8qã‰NèĞ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\†ÆG‡ÇHˆ\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000€OggS\\000PF\\000\\000\\000\\000\\000\\000§g\\000\\000\\000\\000\\0008€„%MBSGYMQXLbNRVPgfhaQTLfgRT`QAAOAD6D96BS[ØğF÷axëå¹PUĞjU\\000°?X`1À,Eº¿Sóİö[»´‘–=¿\\000@|óDÓoÆÍ\\000d_/i\\000@ˆÿÊ•\\000 ¬\\0000™B\\000V[[Ø}o±–O\\\
¾’?Ï….%U@ğ ÀHê°4f–¿4Q¨\\000I´©\\000v4\\000h÷\\000\\000º_Œğ%p€J\\000Ne«–l {¥~P?h‡êà-\\000Àv°î	–À«Õºç©}›5_ò¶]j.\\000¢iDĞ>ËwÛöBéú´jˆ¾|€VÏı@E\\000p=Œ1\\000\\000°Vq+ÚŠèÊñ@yĞ§¾`RÜ\\000P€°\\000¼ÂĞbòõ­³–Éš(€e€º÷\\000Ô‡ÉäTX\\000ÀÈ\\\
\\000ÜÊCI`esíyNy«)\\000(,ï‚F	$XÀ€ª};€ú‰F<‹j}³µk³µùÒz†ö_‚/€º–Ñ¶O,•›Ì4`i)Ú±ö)\\000\\000£¯Rt\\000\\000ìc,$\\000Ry“J.Ô³÷‡È¯çámN\\000ª€z›\\000À\\rA#5Ç–·¾ÌÑ­Xë?9~\\000Pµ¶4gv -z€ø^|€zX@ß\\000\\000G\\000Fg‡=ÿoÇ «ıs=(ªá@¶mhšf©¦‹eÛû£OŒ«Ox36µw‰±¨ëšĞoBM˜€!\\rG#¶y¨ëÚ¿)ls\\000\\000çG¡\\000VuÓÈ S™ãA«• n\\000¨\\000°hÀ[¨b¥Ú:Ûåwî\\\"îÀÒ.€˜¥É©0fO>\\000DZÚ³ÚÔ…=¾æ¾+˜¹ıù½d/< \\000àXÿr¶\\000F…Í3@×\\\\\\rš^^/ o\\000X@°ææ\\\"âa¤Å³~i‰¨w¨#K\\000øN³|…±1°\\000ğ\\000*\\000Ş¿Ç	€&*ˆ€\\000	Ø_z\\000F©U–¸(É×¨_‰îëµÊ?<Á @$€À¡2GÛ\\000ĞçDj5G—msmM>Un),¨'E:Ÿµ@¥ù\\000`­©%üô;ª&€>;qvÜ`c¨§üö©\\\
ˆê8Ë™\\000N©}Ë×vdÉÕt±ã¥°¢.\\000K\\000ÀÔs”Y\\000*GYÿÏ?O¿.ìHÔO˜@Õ0=Á>¥º~µ¬$$ğë0P\\000ĞÃèjÀ7R¡UdK‹#y=ëïã½Š¥”à`à€%šm:\\000T°‘,]¶Ô¹öq,£UM¦Q)0 MT;Ã}\\000Õ2ÕHJÇ!`?$Pwãø€9.#úìjBsõ*ü Ó3‰ÅôJÁ#hAˆ³XIiªêjÓ´×^kœ´–°UStêèïÓ%y—œü„døm##¢çJ@şI°Æ¡Ôñ7§\\000°Ì¯ğ5Norûš©Èúü| l×Ád<*Lû\\0008Âqœió>Û+	\\000\\000\\\"¹VsSkNF¥w.&”wc`Áï3€?¯\\000\\000àR ÌVÆ\\000ƒK\\000B§\\\"`SG³Å²-ÀLkQBo\\000ú'ÅrÛÚuO¿û;µkıXI÷ì¾b@Ó°^¼êêì‹ƒ›èbô—v3 Øùÿ¾	°‘âìö9\\000»¥\\000B2L§©_œ‹ÁŞ€X'K\\000ö¯\\000\\000B¡+Ò(Ë\\\\²imŒ—ş Ğ·Gr¨x\\0008\\000\\000ºmÇ\\000°bˆì§ˆTİïYÚ_ÖDÇ-à\\000@sí¦ş·^Ò_3Å/l¨À¾.ÀfTÖñ„š(ĞÀ(1ê(€q\\000måà•l\\000R§•U€RCäïèFy0Ì``ğ=Ş\\000€^ˆ¢ÊºÅR­÷ùï¿ıŠÂ¼É²dÌü³0€U\\000ª˜Ajë–w\\000\\0000ïÎsİâ\\000Q\\000Îî&Ájç†7£` ò¦ğÍ„\\000€‹>­Y;{7.¶E™è¡øsîQ\\rÀ\\0008\\000\\000ºÄó\\000€¬D4tÙ¬ÕMú?·9'[:\\000\\000Ô'r\\000ÿ/¬E_œÈß92á¸Ørà>XêpV…$ „nã·yv€~¹ê\\000\\000Oe\\000àÈã–\\000N¿T†&í%¶+®¿½Öz\\000N$\\000x€\\000Ğ\\000t*4d®Ú”Úİo¹M½‚#‘x$`*˜\\000 œ?kÀ_ë\\000pS!\\000Í\\000‡é³\\000\\000@‡.·5w^\\\
*ü$[µòı\\\
 wê•®Â+Ú>ãÉ¥ÙŞUÓ°OÕ†GOgÛy3}[Ğ17Àµ¤\\000x ¾Œ€Ûü  !cøUA_éHS\\000àÕ¡ÎHFEå7µ©m#*ü`¿qÌ\\000\\000-À±Ly–ûşåÒ\\000\\000®;\\000,YÂ½pJÌw²9½+`QªÆİÎ‡r„\\000sp¡\\000\\000`Ë\\000:¡½ì¹D‰AhÈ÷ÀÚ€\\000Ğ:\\000\\000¶Gñ€/\\000,Â½ëM5ßs_Ëu´íüÚTzçX´X†vY‰4Ñ6©\\r 5rú^¡êáw\\000ÀÆgw€´™×£\\000\\000p»ö\\000›é=\\\\ïÿz¶õF£Ù{zµ¡ŠB¯„ wD\\000<bßik\\000\\000Ú@Õ€ÑF›	\\000Ş­A÷ÿŸß9Ù{oÖJ8>¿\\000H15ù~>\\r©»]™YÛ68]¸¼Ü®pœĞÉæ4ò\\000@oÅÑ€Š}à—ü(\\000ìN©9Wç Ôl…¸@phŠ\\000·\\000@Y\\000€6 K\\000e\\000P‰j÷j+÷¦+’ú\\\
\\\"Ûh º\\000\\000G–\\000ğÌà×eiĞg%€€ı[HàY\\000J©uLsÊ^TÕ]@šO\\000Oà\\000@›\\000\\000´kŒaıRÚg}â|Ïn#ÜêH&›	\\000H)\\0000š#K@RU¾$]A÷7#\\000\\000;\\000ùs[	\\000J£1ûİ¸:Ÿ}s]X-õÀ=ÀØiK\\000€6 `„ı_cŞçø¾K÷jÓô;$´‘ìŠXÅ·\\000f‰«Ïú0 lÙg\\000Àö½@\\000ö\\000,õÇ\\000Œ±—Ÿ¾YLC\\000J§1w]•}´öÒC~€¦Şà€²\\000 èÊ°€Ë‘Rü“Yæ}@ä\\000æ_\\000¨RZ\\000&ËÏ\\\"€_FtƒË¯á\\\"–\\000~^2\\000\\000Û€	§4¿ªèiÒ¶\\rš@e“5^qàGÙXÙş:¬¥ÓxĞıËhI@R”ø-EgÀpv1Pì\\000¨‰Zú¿«sò÷KÏ²ÀlÌ‘ff™eisÇ™ni\\0003Ü&èhÀÖ%3¸Äğî8\\0000Õ_€ÍúÒ\\000<°:G!A¯ê›Q“8›õ|[şå¬ooÇé$ÌøqÓÔ˜Çoçª`&Yå¹Ô¶VX9W]\\000À?Â'\\000è%$wüâşs`˜—Ú¶^£6q,P¸ö}§‰X„r^y=8Ê(TIPô\\000èÇ!\\000\\000¼€?\\000 \\000~]\\000¨ÀD‰H\\000•ÔW_ºÒ¥½è,Á¬†2 \\000X„´•ßÙ.Ë¢`¢R%\\000=\\000ı.ÒĞÿª ÷\\000€5%àæ{\\000\\000\\000pìô˜3\\000•:÷¼š2q¹ààœ{o4£ôæÎàg‰ı(8+*×‡àŞ\\000\\000N|–\\000\\000`ã\\000€,\\000ÒV('Õê1R Û¶G”À\\\"À¬k*€;Ä»|.fÇóeuFØ/70ºò\\000€Ø\\000€}%\\000`\\000ìs™\\000‹2¶¿T¥ëóhÉB?ÀÁl\\r\\r£¢ÚJ¥Ö›‚×\\000ğK Á6À«2\\000<¿\\000ÀtP¨æàèy!v]›ñ·h™«äF\\0008ız„½<ps7¢QÏ&¼_\\000€\\rª\\000n\\\\è€¹\\rwÍI¿$€€\\000\\000Ö\\000\",\
    [ \"sound/mino_Z.dfpwm\" ] = \"øùªèßc\\000€¦te÷¿R¨üÿ\\000\\000J)ÿÿ¿ ª:VÕŠ€êÿÿ«ª\\000\\000°úŸª\\\\Óªş¿\\000\\000J©şû¿\\\
 ªê‡XU Uÿÿ«ª@õ¿JJàWUıi\\000T*ı×ÿ@µ–~ ª@UıÿWU°\\000Ô¿Jiµô¿•\\000(•úWù@«Vıª\\\
@U¥ÿ¿ªPÀªTü[õ¿Zi\\000 Tù/Õ?@UmıH€JUÿU\\\
Ğ4€ÿT)ğ_õ¿¶–\\000€ªúW©ş\\000Uµı@)€”Jÿÿª\\\
ĞªşªJ şë­­\\000Tõ¯JëUUı¿(\\000¥Tşÿk\\r Z¼je@ù¯ÿU]\\000ˆê_UÕ£*Mù\\r \\000©¤ü÷¿@UUY¥U€¤ÿÿ«Õ@Ô©Và­²ôm\\000\\000L)ı×+@USJj\\000KıÿWÕP\\000É¥´¿ªêÿª\\000P%ù_ıW€jUı€ª\\000•êÿ¿²P ÕRü5Õm-\\000@)õŸú¿€ªªú¨*€ªRÿ­\\\
 €µ´ø«äßVµ@Kå¯,¿U­êHPUÛú?i4`¥ ıÓD¤Š¯¤ oÃ¯¨Ò\\\"-ıè~ R¶ô¯¢tÉŸnCş.-½.ø\\000ÀAhÿş]WUy\\000D\\\"Òöjşo[PVR-ğ?iÕV­àŸR­eÙÿk Õ\\000X%‰åÿÿ[«Õéf\\000\\000*E)Yÿ+§ÿµÖ\\000ÈV3\\000ş«VUe©\\000üU­¥¬şÿn\\000 ©\\000SiRıÿ¿­j5½\\000\\000¥ª\\\"úªü¿Ú\\\
€ZÕÕ€ÿª*e­€ÿJ«‰êÿ_\\000l5\\000 •Éÿÿ¯V­Õm\\000\\000P)U¢ş_*ÿ_kPk¥•\\000ğ¿ªJ­´ğ¿*j•úÿ_\\000Ë\\000©J4ñÿÿ«µZË\\000\\000*¥JÊÿ«äÿ«5\\000¥Ze+\\000ş—U¦*v\\000ş«RUªşÿW\\000Pk\\000PJ1şÿ¿jµvU\\000€ªT¥ôUøÿU@kÕ4ÀÿÊTUI\\rÀÿ•J¦íÿW\\000Ô\\000T%Uÿÿ_•İª\\000\\000`•TRÿ/•ş?k\\000XM­r\\000ø_ªÔ*­\\000ğ_•¥bıÿÓ ¶€ªT’ôÿÿUË¶j\\000\\000ª*%éÿ©äÿÕ€Öªš€ÿÒ¤–R\\000ÿ«eZÌÿWi\\000TU\\000¬¤j•şÿ_Ñj›T\\000\\000¨ªK5şŸ¤úŸR\\000ªu•ªà_´2‰ôÿ*šªğ?R	°äÁzQ/¬ï_(©]J#$8¡áÆoEiOz¡ òµKğ9Q¶êCıŸfrÿA€­¥)\\000ÑÿGåÿkÛ\\000€R’”şïu¶\\000lW€ÿJªV\\rğ¯J•úÿR\\000lP)Õ(ÿÿªj;\\000\\000‹âU-ûH¥Z¥ü´²j`©ş©ÿ›«¶:\\000\\000¥õ_êÿ®\\\
 ª•øk©ª¢\\000ğ?Síÿ[Í€¤”Túÿßj«P+\\000Rÿ+U•ÖµêTêÿ€Ö\\000UQıÿ¿U«¶\\000 *Rÿªÿ·\\000VUUVNªJ½\\000èÿ•ú¿jÓ\\000@ªJQÿÿ_«+\\000ZÚ\\000à¿ZU¥üZ©Rı\\000¶\\000$%©òÿ¿ÚZ5\\000 Jò¿¥ªşÀšªšşµªœ\\000@Íÿ¤ÿ¯V«\\r\\000 I%õ¿ú¿º VSøO©Tm\\000ş«¶Ôÿª\\000\\000+U\\\
ıÿo•©¨ JÿKU¦şÖ”Ríÿªª\\000Ôÿû_µ¶­\\000\\000”TDÿ•öÿ6\\000¥ªª…WU+ª\\000ÿ_©ú¿Zt\\000\\000¨$U©ÿÿ·Z*\\000–€òRU•Ê¥J«¤ÿPY\\000 *‘şÿ_+µ:\\000\\000J•ò·ªäÿÔJ-«> TÑP\\000¥ıÿ¥ÊjJ\\000€Z*Êö¯ÿK•T­4€~«IÔªÀÿ‘J£¿Šv\\r(Rv¥øÿR1¢£’ [U?PlÿAU/ÒT/ŒdİµæÿïÂ@µ†@ºÕÑÿµø'UˆÔU¯OX×°¨ÿ¥€IÕ.¤÷‹fú(ë•—+€è¿:Vò‰ ¤jÿËJ»|”~™\\000e[ù_¿Š\\000¥•è`½H€Öúÿ¥’\\\
 ¶ßš6Ø\\\"ÒÿI)\\000Zµë¿ôKT;ù©ª\\000UÏÿMJ€JÿSeà«¢E¡°µ²•ş´Zõ¨¶€.;ú¯D+ÀRAüRÕ\\\
èë^+Ò\\\
`­Ú_lkRuÊO	İ‚œ*ıµ\\\"Õ UŠôZ£¨Õm-VIS”ªZ_«TE•V­NÕ°¤ÔêªËR)+µ,5µx«ªªVUBYikıöW‰4¥J€ÖÊµVë¿¢úÓR€mKj	°¿’Z¥´ÀoU›\\\
ÕIÀê¦\\000ÖzUÖ¿}J”T•V@ÛZZÕşµ(ÿ\\\
U²¶YVú5mªJªüZ•ª‰ö¯$Ğê\\\
PÛZ­õ¯Ÿ•Êª*\\000d[Ó¦Ö¿JÊ?¥@ÖµT ş•–šJÛ\\000_µR¥Tı'•\\000ÖÚ\\000Õ¶ªZıû’\\\"iªj\\000u«lYûOÊúW¤`Õ­jôWÅ’mÉàWmdÊª% ¥-@í«¨Ö¿/)I¥6@ĞÖV›ÚI™ş*Ê\\000UµZUı¦ªh-•úÕJKµú«$˜V”Ó5­ú÷%%R5)¬í¤.ë¯)é_’ÀÖj•À¿RU*e5€¿UVRªÿ”J\\000mÕ€j¶šUÿ>©DTSË‚¶-mKıS¥ú—hhm­jøÕ”«*¥èW©jÉúWQ\\\
 -\\r°jµªÕÿUCUª ¨uk­Õ?Uªş¢R€Ò6­F¿©¦T¥U}UU%mş©”\\000ZWdµ­ú{)¥¢ªR	¢][©õ]UÔ·b	R«JË¤Wz*UiÔWÉIU[—JÕP-5¨ªÚ*WÕVS©JUµPÑZZ»Ä6é´µDéD«F­TMwT¥UêRQµ›*µ&[SBÚ“K!µıÕ¬ß’JJ\\000jUõê¯_¡FT­ ¿²JM*à«\\\\UÕ_)ÔPÛSÓş/Šš¥\\000+Pú²¿RÂô/PÕV¥õÈZIXµı+úSŠÒT°µjÕ¿´~K\\\
 U]à¯ªJ5ÚO¥*ÿJ%hPİªKÍÿ•”J Z]ı«dRµ¥ªUU jS@­µí¯_*)¥\\000m]Öú§¦úMªÖR«*W“Y* Ö¿4õW*R)\\000µÚV›ıõK¦”€R]´¿ªd©*xª©ªô×$@õªvYÖÿ%©JV€T¯Õ¿©ü'H«¥¥úCJ«ZÒå}­şQQ\\000v­Uê_ê¯˜@+kôW[I%ô«JUE©€ê@]¦©é¥Q*¨+`½ü)¬ô‡¬j«J”Vj€M—şÕ¯HIQ\\\
€m«­şRU*Z*U\\r^5Óª,@ëO-é/I¥\\\"íVS£ş]‘Rª€4k õ¯•R®j•VıU¨Ş’šz÷_V”D¥€ˆê]õ×‚r	ŠTÕ’ôÜ*U‰h½_i¯$JJP¯kU–ÕöµÊJ­ ö­TªIQ¿²URmR•¨µª%5Uµ'ÕªTMª¦ªªZ©•ªZUUª\",\
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
	menu.title = {\\\"Menu\\\", 1}\\\
	menu.options = {}\\\
	menu.cursor = {\\\">\\\"}\\\
	menu.cursor_blink = 0.5\\\
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
function Menu:AddOption(name, rx, ry)\\\
	name = name or \\\"\\\"\\\
	rx = rx or 1\\\
	ry = ry or 1\\\
\\\
	table.insert(self.options, {name, rx, ry})\\\
end\\\
\\\
function Menu:SetTitle(title, rx)\\\
	assert(type(title) == \\\"string\\\", \\\"asshole\\\")\\\
	self.title = {title, rx}\\\
end\\\
\\\
function Menu:MoveSelect(delta)\\\
	local new_selection = ((self.selected + delta - 1) % #self.options) + 1\\\
	if self.options[new_selection] then\\\
		self.selected = new_selection\\\
	end\\\
end\\\
\\\
function Menu:Render()\\\
	local cursor_index = (math.floor(os.clock() / self.cursor_blink) % #self.cursor) + 1\\\
--	term.setCursorPos(self.x + self.title[2] - 1, self.y + self.title[3] - 1)\\\
--	term.setTextColor(self.color_title)\\\
--	term.write(self.title[1])\\\
	cwrite(self.title[1], self.y + self.title[2] - 1, self.color_title)\\\
\\\
	term.setTextColor(self.color_unselected)\\\
	for i, option in ipairs(self.options) do\\\
		if i ~= self.selected then\\\
			term.setCursorPos(self.x + option[2] - 1, self.y + option[3] - 1)\\\
			term.write(option[1] .. \\\"  \\\")\\\
		end\\\
	end\\\
\\\
	term.setTextColor(self.color_selected)\\\
	term.setCursorPos(self.x + self.options[self.selected][2] - 1, self.y + self.options[self.selected][3] - 1)\\\
	term.write(self.cursor[cursor_index])\\\
	term.write(self.options[self.selected][1] .. \\\"  \\\")\\\
end\\\
\\\
return Menu\\\
\",\
    [ \"sound/mino_I.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000/Y\\000\\000\\000\\000\\000\\0008ğvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000/Y\\000\\000\\000\\000\\000©úrDÿÿÿÿÿÿÿÿÿÿÿÿšvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000€ \\\
Æ€ĞU\\000\\000\\000\\000BˆFÆP§”—‚…GÄP‡óPjé xJaÉ˜ôkBß{Ï½÷Ş{ 4d\\000\\000\\000@bà1	B¡Å	Qœ)Ba9	–r:	B÷ „.çŞrî½÷\\rY\\000\\000\\0000!„B!„B\\\
)¥RŠ)¦˜bÊ1ÇsÌ1È ƒ:è¤“N2©¤“2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊcŒ1ÆcŒ1ÆcŒ1ÆBCV\\000 \\000\\000„AdB!…RŠ)¦sÌ1Ç€ĞU\\000\\000 \\000€\\000\\000\\000\\000G‘É‘É‘$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û—}ÛwuÙ·}ÙvuY—eYwm[—uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9’#)’„†¬\\000d\\000\\000\\000à(â8’#9–cI–¤IšåYåi&j¢„†¬\\000\\000\\000\\000\\000\\000\\000\\000 (Šâ(#I–¥išç©(Š¦ªª¢iªªªš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš@hÈ*\\000@\\000@ÇqÇQÇqÉ‘$	\\rY\\000È\\000\\000\\000ÀPG‘Ë±$ÍÒ,Ïò4Ñ3=W”MİÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ€ĞU\\000\\000\\000\\000 ˆB†1 4d\\000\\000\\000€¢‘1Ô)%Á¥`!Ä1Ô!ä<”Z:RX2&=Å„Â÷Şsï½÷\\rY\\000\\000\\000FƒxL‚B(FqBg\\\
‚BXN‚¥œ‡N‚Ğ=!„Ë¹·œ{ï½BCV\\000€\\000\\000B!„B!„BJ)…”bŠ)¦˜rÌ1Çs2È ƒ:é¤“L*é¤£L2ê(µ–RK1Å[n1ÖZkÍ9÷”2ÆcŒ1ÆcŒ1ÆcŒ1‚ĞU\\000\\000\\000\\000aA„BH!…”bŠ)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I’,É’4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeİÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäHŠ¤\\000¡!«\\000\\000\\000\\000\\0008Š£8äHåX’%i’fy–gyš§‰šè¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(Š¢8ŠãH’eišæyª'Š¢©ªªhšªªª¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš&²\\\
\\000\\000\\000ĞqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000€\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç“<É³<Çs<É“4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000€ Ç´ƒ$	„ ‚äÄÄ¤… ‚ä:%Åä!§ bä9É˜Aä‚ÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥“9ç¤tR¡¥Rg©´ZbÌ(•ÚR­\\r„RH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,„BCV\\000Q\\000\\000„1H)¤bŒ9ÈDŒ1èd†1!sNAÇ…T*uPRÃsA¨ ƒT:G•ƒPRG\\000\\000€\\000\\000€\\000¡Ğ@œ\\000€A’4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUİvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×•eÓumÙue[WeYø5U•eÓumÙt]ÙveW·UYÖmÑu}]•eá7eÙ÷e[×}Y·•at]ÛWeY÷MY~Ù–…İÕu_˜DQU=U•]QU]×t][W]×¶5Õ”]ÓumÙT]YVeY÷]WÖuMUeÙ”eÛ6]W–UYöuW–u[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}U–u_Öua˜uÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_•máXeÙøuá–[×…ßs]_WmÙVÙ6†İ÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^İ6êÆO¸ß¨©ª¯›®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VY†Õ–…aÖuaÙ…a©Úº2¼ºo¯­+ÃíßW†ªmË«ÛÂ0û¶ğÛÂo»±3\\000\\0008\\000\\000˜P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEU•eÕ•eYu]]MÓ•EÕteÓT]Yu]WV]W–%M3MÍóLSó<Ó4UÓ•MSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓ–MS•eÓUmÙUeW–]Ù¶MU•eS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨š²kšªl«ªª»²kë¾,Ë¶,ªªëš®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï™¦,›ª)Û¦ªÊ²,»¶mË²/Œ¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À€\\000@€	e Ğ•\\000@\\000\\000`cŒAh”rÎ9RÎ9!sB©dÎA¡¤Ì9¥¤”9¡””B¥¤ÔZ¡””Z+\\000\\000 À\\000 ÀM‰Å\\\
\\rY	\\000¤\\000GÓLÓueÙËEU•eÛ6†Å²DQUeÙ¶…cEU•eÛÖu4QTUY¶mİWSUeÙ¶}]82UU–m[×}#U–m[×…¡’*Ë¶më¾QI¶m]7†ã¨$Û¶îû¾q,ñ…¡°,•ğ•_8*\\000\\000ğ\\000 VG8),4d%\\000\\000\\000¤”QJ)£”RJ)Æ”RŒ	\\000\\000p\\000\\0000¡²\\\"\\000ˆ\\000\\000œsÎ9çœsÎ9çœsÎ9çœsÎ9çcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1Æ\\000ìD8\\000ìDX…†¬\\000Â\\000\\000„‚’R)¥”9ç¤”RJ)¥”ÈA¥”RJ)¥DÒI)¥”RJ)¥qPJ)¥”RJ)¡”RJ)¥”RJ	¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ\\000&\\000P	6Î°’tV8\\\\hÈJ\\000 7\\000\\000PŠ9Æ$”JH%„Jå„ÎI	)µVB\\\
­„\\\
:h£RK­•”JI™„B(¡„RZ)%µR2¡„PJ!¥RJ	¡ePB\\\
%””RI-´TJÉ „PZ	©•ÔZ\\\
%•”A)©„’R*­µ”JJ­ƒÒR)­µÖJJ!•–R¥¤–R)¥µJk­µNR)-¤ÖRk­•VJ)¥”JI­µ–Zk)¥VB)­´ÒZ)%µÖRk-•ÔZK­¥ÖRk­¥ÖJ)%¥–Zk­µ–Z*)µ”B)¥•’Bj©¥ÖJ*-„ĞRI¥•VZk)¥”J(%•”Z*©µ–Rh¥…ÒJI%¥–J*)¥ÔR*¡”R*¡•ÔRk©¥–J*-µÔR+©”–JJ©\\000\\000tà\\000\\000`D¥…ØiÆ•GàˆB†	(\\000\\000\\000ˆ™@ \\000\\\
d\\000ÀB‚\\000PX`(]è‚\\\"HA\\\\8qã‰NèĞ\\000ˆ™\\000¡\\\"$dÀE…t\\000°¸À(]è‚\\\"HA\\\\8qã‰NèĞ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\†ÆG‡ÇHˆ\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000€OggS\\000r\\\"\\000\\000\\000\\000\\000\\000/Y\\000\\000\\000\\000\\000¸v³}]R`^d]_Yb]O?BAC>88B«Vö²/O·İçóU\\000@	€·ì€•âmÀ\\\\ÍÌ’LeÿLµ¦ÆÔÔQPjšï<—\\\"uÙ›\\000°ãõã•ã•÷îŸ_l½t½^¯×ëUÀB\\000Š a3¾ŒZ±5É¦¦×Rd~¤ïw@€Õ\\000\\000Pô€5ÃÜÆšH`]µ\\000<\\000Ï¬è½3×ç*oïäñoÜ_èç¬}“V©\\000\\000ø§n3ê€-\\000\\000Ø$\\000^©=Şºü|­Ù-½¦^€„5Ğ\\000À	\\000Ñ1\\000«6e\\000ÑâÔÑ-Ï¾İ›ÌÙ.–í\\000\\000’¦évx\\000>=Òı–\\000ø˜¶ûÀU\\000\\000tìwÀ;@Î.	\\000ôË‹	€¯\\000ÀNŞ†\\\
\\000R©µtN·—j_X€îU\\000p| e\\000ê€ˆÚk´Wz7ÚöÔ-5@Qm‰ÉÎ”Y–[H\\000.\\000t£€Ø»Un•\\000ó'? ¬ı1P«:w\\rYGâ\\000Z­¬ ó7æÔ®€i=€E/øÔ\\000 M\\000Û}\\000\\000°h «ÔÔÒg)öìØ*µW•‹šz#\\000\\000uOmË°º\\0002lÆÖÿ.ÉV'\\000ÀiZ_ğK7[\\r@Á„\\000@c~f³\\\"^nr%Œînê-êo¾°~ü-\\000ˆx  ò\\\"@¥¥«jÎX¥w?Rİ›ì³N\\\"HJ30yB5M°,@Ó4Ä~ß\\000Çğº\\\
ÌUiŒŸ²Ís\\000*+u€%}ó•`ñOƒb¡ãôºÚÖ^TôÆ=ó\\000ê¾Ùâ¢\\000\\000,@-hØ¢iNhS»6}’Ş¼Ë[OV\\000\\000y Ò´y—`P³Ë¡^İÃ°ˆ³WS\\000ìêç\\000€Á¨ù‘\\000,ú_Ï\\0000¤ì—‹\\000V­Á_ëß=vÿŠt.q ÓÎÑ \\0000è\\000sÓ¦3«<–§3UÇp[y»\\000À\\000ÀÎäJÕd6t„±\\000gÜV´©€ú‹¯â\\\\ß²1\\000¶szH^«’{.îzÄè¡ï§3Â}Ã	Ğ\\000Ú6\\000Kˆ\\\\Ë¤l=¾vâhšußUß’'¨§àûöô¥Ëšm6Y8H\\000nË€ô«¢a9¾ÜÃMe\\000€°ô\\rh\\000ıÌ~\\000>RK¯\\000Z«=æŸ¯˜¥sZc>ĞP¢\\rÚ”\\0004Ãªæ–GËòåËsöŞ¯aY\\000†Ş—0Ïsîœ ÿ2:áı\\\
p«bƒ„¿D\\000\\000à9é0?‡at\\000t]¯ÊV³:¤”LgŸ±\\000Z±5o?ŠXG«?ÂÓw@\\000	.\\000ğ\\000\\000Ñ\\000k†ÌUhß€,€¾Í‹\\000PiP©LÛÃÅóL_ı:¸w\\000Ğã÷!\\000ìÎşÎ\\000\\000ÎÇZ¯™õ\\\\ÚN<Š‡*ğ¥o?\\000\\000ƒ#\\000t‚#H\\000JÛ ı0ÿœ\\0000íq¿T‚Ï#à—\\\"\\000ü¶†r\\000x%‘Ñ:_¥Ÿ}­«-î~\\000}Ù!bÇ\\000¼YEFóuïíKø\\000ÎÚûz¶(A¼«r\\000ï\\000f`°É€«\\000jõVX½[uˆ›Õh2äíèV&ŒJí<ßoËNúlH\\000Ã*$\\000@'Le\\\\Áüær x\\000K\\r\\000·™\\\
\\000ë¡‡-ßí['Ãå49asÄ\\\
ñL¤hı~ï’õ»LĞ‡ôt\\0008¹\\\\\\000@\\000€A‚\\000×2t‡Àæ0\\000İ'{û].Â÷ÓúUrBÛbrÒbÙíç‘ÿJu-§·‡\\000ßt]¯ñ\\000è€\\rSBr€™TáÀlu€Ò¹\\000q€›/éÚçPüÆíÕko¡*`Ã~5vÚ)#`H/ş#\\000.A\\000@Ü~°®<7€„=|`(º\\000e©m¿<¾Óò9©Şµ\\r+„4`Å/#<:yZ°#€Í¿¼\\000$\\000æç;\\r\\000_ƒ[«‘ˆ€€İê\\000EŸ…\\000\\000\\000Xõ\\000\",\
    [ \"sound/lock.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000a|\\000\\000\\000\\000\\000\\000\\\
z™vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000a|\\000\\000\\000\\000\\000´ùª-Dÿÿÿÿÿÿÿÿÿÿÿÿšvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000€ \\\
Æ€ĞU\\000\\000\\000\\000BˆFÆP§”—‚…GÄP‡óPjé xJaÉ˜ôkBß{Ï½÷Ş{ 4d\\000\\000\\000@bà1	B¡Å	Qœ)Ba9	–r:	B÷ „.çŞrî½÷\\rY\\000\\000\\0000!„B!„B\\\
)¥RŠ)¦˜bÊ1ÇsÌ1È ƒ:è¤“N2©¤“2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊcŒ1ÆcŒ1ÆcŒ1ÆBCV\\000 \\000\\000„AdB!…RŠ)¦sÌ1Ç€ĞU\\000\\000 \\000€\\000\\000\\000\\000G‘É‘É‘$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û—}ÛwuÙ·}ÙvuY—eYwm[—uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9’#)’„†¬\\000d\\000\\000\\000à(â8’#9–cI–¤IšåYåi&j¢„†¬\\000\\000\\000\\000\\000\\000\\000\\000 (Šâ(#I–¥išç©(Š¦ªª¢iªªªš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš@hÈ*\\000@\\000@ÇqÇQÇqÉ‘$	\\rY\\000È\\000\\000\\000ÀPG‘Ë±$ÍÒ,Ïò4Ñ3=W”MİÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ€ĞU\\000\\000\\000\\000 ˆB†1 4d\\000\\000\\000€¢‘1Ô)%Á¥`!Ä1Ô!ä<”Z:RX2&=Å„Â÷Şsï½÷\\rY\\000\\000\\000FƒxL‚B(FqBg\\\
‚BXN‚¥œ‡N‚Ğ=!„Ë¹·œ{ï½BCV\\000€\\000\\000B!„B!„BJ)…”bŠ)¦˜rÌ1Çs2È ƒ:é¤“L*é¤£L2ê(µ–RK1Å[n1ÖZkÍ9÷”2ÆcŒ1ÆcŒ1ÆcŒ1‚ĞU\\000\\000\\000\\000aA„BH!…”bŠ)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I’,É’4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeİÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäHŠ¤\\000¡!«\\000\\000\\000\\000\\0008Š£8äHåX’%i’fy–gyš§‰šè¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(Š¢8ŠãH’eišæyª'Š¢©ªªhšªªª¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš&²\\\
\\000\\000\\000ĞqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000€\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç“<É³<Çs<É“4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000€ Ç´ƒ$	„ ‚äÄÄ¤… ‚ä:%Åä!§ bä9É˜Aä‚ÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥“9ç¤tR¡¥Rg©´ZbÌ(•ÚR­\\r„RH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,„BCV\\000Q\\000\\000„1H)¤bŒ9ÈDŒ1èd†1!sNAÇ…T*uPRÃsA¨ ƒT:G•ƒPRG\\000\\000€\\000\\000€\\000¡Ğ@œ\\000€A’4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUİvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×•eÓumÙue[WeYø5U•eÓumÙt]ÙveW·UYÖmÑu}]•eá7eÙ÷e[×}Y·•at]ÛWeY÷MY~Ù–…İÕu_˜DQU=U•]QU]×t][W]×¶5Õ”]ÓumÙT]YVeY÷]WÖuMUeÙ”eÛ6]W–UYöuW–u[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}U–u_Öua˜uÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_•máXeÙøuá–[×…ßs]_WmÙVÙ6†İ÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^İ6êÆO¸ß¨©ª¯›®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VY†Õ–…aÖuaÙ…a©Úº2¼ºo¯­+ÃíßW†ªmË«ÛÂ0û¶ğÛÂo»±3\\000\\0008\\000\\000˜P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEU•eÕ•eYu]]MÓ•EÕteÓT]Yu]WV]W–%M3MÍóLSó<Ó4UÓ•MSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓ–MS•eÓUmÙUeW–]Ù¶MU•eS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨š²kšªl«ªª»²kë¾,Ë¶,ªªëš®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï™¦,›ª)Û¦ªÊ²,»¶mË²/Œ¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À€\\000@€	e Ğ•\\000@\\000\\000`cŒAh”rÎ9RÎ9!sB©dÎA¡¤Ì9¥¤”9¡””B¥¤ÔZ¡””Z+\\000\\000 À\\000 ÀM‰Å\\\
\\rY	\\000¤\\000GÓLÓueÙËEU•eÛ6†Å²DQUeÙ¶…cEU•eÛÖu4QTUY¶mİWSUeÙ¶}]82UU–m[×}#U–m[×…¡’*Ë¶më¾QI¶m]7†ã¨$Û¶îû¾q,ñ…¡°,•ğ•_8*\\000\\000ğ\\000 VG8),4d%\\000\\000\\000¤”QJ)£”RJ)Æ”RŒ	\\000\\000p\\000\\0000¡²\\\"\\000ˆ\\000\\000œsÎ9çœsÎ9çœsÎ9çœsÎ9çcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1Æ\\000ìD8\\000ìDX…†¬\\000Â\\000\\000„‚’R)¥”9ç¤”RJ)¥”ÈA¥”RJ)¥DÒI)¥”RJ)¥qPJ)¥”RJ)¡”RJ)¥”RJ	¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ\\000&\\000P	6Î°’tV8\\\\hÈJ\\000 7\\000\\000PŠ9Æ$”JH%„Jå„ÎI	)µVB\\\
­„\\\
:h£RK­•”JI™„B(¡„RZ)%µR2¡„PJ!¥RJ	¡ePB\\\
%””RI-´TJÉ „PZ	©•ÔZ\\\
%•”A)©„’R*­µ”JJ­ƒÒR)­µÖJJ!•–R¥¤–R)¥µJk­µNR)-¤ÖRk­•VJ)¥”JI­µ–Zk)¥VB)­´ÒZ)%µÖRk-•ÔZK­¥ÖRk­¥ÖJ)%¥–Zk­µ–Z*)µ”B)¥•’Bj©¥ÖJ*-„ĞRI¥•VZk)¥”J(%•”Z*©µ–Rh¥…ÒJI%¥–J*)¥ÔR*¡”R*¡•ÔRk©¥–J*-µÔR+©”–JJ©\\000\\000tà\\000\\000`D¥…ØiÆ•GàˆB†	(\\000\\000\\000ˆ™@ \\000\\\
d\\000ÀB‚\\000PX`(]è‚\\\"HA\\\\8qã‰NèĞ\\000ˆ™\\000¡\\\"$dÀE…t\\000°¸À(]è‚\\\"HA\\\\8qã‰NèĞ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\†ÆG‡ÇHˆ\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000€OggS\\000\\000\\000\\000\\000\\000\\000a|\\000\\000\\000\\000\\000iC-2	s}{a]_V\\\
.g[½(eº‚ŸË	X\\000â—'›Ÿ{_±Ö/ß¿]7ù=f?gMjŸîevé¸ÊNøçò`ü‹7®Ê°ò¹9[2÷¹s•ŸÿÈÀSu}îÜ¹Xı¢ğ¿ÃÄF1å8ö–Šs+ÏSÂøÆ›RÊí6³÷`\\\
œK»'\\000”Æ/”\\000”RUså×ÛvñíG·üó†Xk™ÿºçaN=fÆ‘:F¤ÿLM•QÍT;nr4úeæÑÌ$ù›µ*tİ-ãª‹¼tåu—™LA|é‚5â&‘)wóoF1&n+=¹ÿ^Ue´6‡®ïƒÓC,n¿\\000NÉAƒÒà WRú§ÔùÛª­oï¾~u«X(æ—hÙË?ÑëˆP\\\"5áş^ûÌÈi/4 –ıa\\\\J¢GC[ŞKÑäœ¢šZ•º.Q^3®ü|\\\\Ş†P«oOÕ–p,-%»àøÀLş×vyBºëÚuºáiKkƒ	J»IÍÚ¤ì¢%ï¨5ˆªÓâS¡Ï”úü·^o³ï¿g£Î¡sš¦İğz\\\
ÄŞÄFW1ğím<;11¢J¯J±ÏÃt)p­mcÈûæ6Ÿ¬İƒd¦axL6î­XÅUGzq]É‹&{jìeß²™ÔnÀ~»¡Z\\\"¯éTÁA€Hf§´¶Ëò«+:¦±Wí½³Èº/coS#3fæf®¨Lã·X¯&İfì~4¤Øœ[%¢‚#\\rÃ>ä­p8Ã|ï@™úO0OE7‘°¼’1ÕsVREé\\000Ÿé8`tçmÛ¶@Éî”›Ú’bY›ã¸­Õ43ŒİÇùÕ>néîx›ŠİfÏÙÓÔ‘²r@×Ò*lcÆXŸmüÓh†ê—x _ğEŠv´IŞtÑ@•ÖX­\\000\\000™mbÕ4¼s9Àã€’Üìâ±5u¤S“_[¨V±Êôåor.q\\\"ì\\\
ûIâø4v­,ì;Oæ:W‘/e¯2éÜ˜€4¾²i‚À ÷æ€ÊĞ–½[)«‡·µo]v\\000‹×kÀ]‹N¨N)gVŠÏåIo}±êùÒ±óÃÆ\\\\UÃ?õ¤~T¤¼öŸ}sMÊL¿n2=‹]¤1Ø\\000¼{&lÖÜ¸\\000ğ_@¢Àâ²ò<^‘¯ÁU\\000I¿$€\\000\\000\\000\",\
    [ \"sound/fall.dfpwm\" ] = \"à@ÿÿë€\\\
€à\\000 ÿ?üà‡Wø\\000ÿ·ò¯\\000%¾ Ü¿oá\\000Éş·\\\
Ôÿn[[=\\000„ô\\000Dé~/ ¤öß{Ïo{·V«@„HÕ;UÿÛ]şŞîîÖª!@@I\\\"½ï÷ûmİ»Õª*D !H(‚$!¢ Õı\\r¤ıÿ÷Şïm’z~ß6‚Úd½×î¶ªŠ` _í¿­UÅ'\\000IÔ\\\"\\\"©½·í¿»{k+ ßªVD\\000‚Ò\\000I\\\"!•QÕÿ¿İııÛ·ö®¨n:¥}¿µ¯­¢Ôşj«ZBè“ ôK«@(T”Hm+ ‘„JQªıí.ú·ÛBıÚÛ ½PR¢„B¥ıí«Í' ¢èÿAZİUB(ò¯Ú÷€[^õW×Öïkµêı¿·¿Uc\\000­R€lU‚1®ºÿ¯–İÛ´Jø\\000m]OHÕôûzØşÿ÷â¿Uï$T \\\"@P°P+ÛV«UWm½î›UaQ\\\
†€„ÖÑáêºG¿WKKR\\000UÓíg÷ïß÷­$@µ•R=\\\\l7ıÿ^×ÿ×mw®İkM%	 \\000$\\\\åëñ[xOB’€¤\\000¥ú¿|ˆö[¤¯r+İÿõ­ı¯«DTš$<©ğI\\\"‚*%¥¦ŠÒÆ¡óüµİù¾·ÿaUå!`\\000s0e–C%¢®°H\\000&„TŞºîÿ]-—¿eQ+	¥mX/º*\\000÷-~JTÂ{Äõ¼š~üîu-­,}Š$\\000òPŠ]”~\\\\4SèQÂ¨,·ştUà÷!õ0XĞÕ¨$\\\
XˆÏë¢»¢›ç<õtïŸ¯+”3TÍóÖKÿ¾c›zï}š¿J\\\
Où4Õhƒ0êã¢…¢qŞõûtW\\\
ÿ]“Zã«¤‹Æ\\\"ÑÔê¾\\\
Šz‚I‘²8]½½áö¾2tŒTä°QPg©>×°Öªcª(xğÂs¿Ëø½¿~õi@J	z…•ãë]ï¿Ë»öøÆó™V\\000`„ƒ–SÕNº^ÛÕ5ç¯O¿×­S@R,DÛŠg,åè<,”‡+æ²ıÚì%¦ª¨ŞzÅ\\\"˜+¬axp\\000:ª,\\r¬ò0Xepß«Ÿ©r8Èb×ã>w÷éré¢³ºªPx÷¥Ó¯ $Ğ@„`›3Şv]«DÒƒ‚jI-\\\"ø·qïãÕVZ» ¯Ç½~¾>\\\\£\\\
£Â#«8J‘Æ“—i¨Xz|Ö¡%È¥,~åhù`aÄa,ÌñôóumŒÎ:ºøĞpá”M7T±½ã·îTUt¬‚¡êâÍ+Ü¯®2Ä™‡-†1‘ÑßÎW=Ûâ!ààÓ‰ÃR4Ê©PEãXG8”<ïéç®¯.+Äò\\\\ÃŠ+U¨%«5<FG!\\\\2Œø´Q^Ó#\\rÁñê7«G8¡ÀqXkZëºâ\\\\û¼C¼1…èı×¾¯‡	HÃHÒÑ·ƒ#†dŒÁ´iWE5´~½ê1«Li4P¼×›K<r¨|İ†éµß>®ˆ(BEõmmŒâè\\r¡\\\
Uhò•Ã×‡¥ ©ã§ñ¼^-Pè’ë!H}¬ætí÷OZ.4ÒÂ±»‡‹W.J«BÊÃP•Ş¿¿¼òÄÃI0~¶(.¸a…Qëş÷YJ#¥&*(PDiÕGç8K }°E)ı¿şúºªnë¹‚ªã± ¤ÃúÿçÙä âè)ÄÕÓ;µ Å´ÄÅ%¾ß¯«ÁÓ(£Õ#ÉqÈ´–§ï± 1--[ş5Jaj(´Ş7mYÏÿ»7ì=Mµª(§Ğ>y0~'JyÜö¬0\\\
CĞºw¼@ÇuÅY¯ªcÔQ\\000ÃSë`=VñÏ¯ç‰$&$Â(ËÇÇ·H©®ÿë£\\000EšeÜëûªBDRÑÍ£<\\rV_íyÏw©GÎ}õêˆ@0ıı>¦q¶ÒÒ­g<-Àëbm§÷\\000¨ÊZã+ª5xµñ§£PPªÕ¯GY^\\\\–pëac@=/ß8‚ûÕšO[PwAóM\\\
-îzı©ã½¯3¡°ë[%\\rèï©zİ¯®—´ó¨@ Æj:ú\\\"ª,y¹lİ£­ƒ)ïxùıÿ*ÓŠãºa0,òÎªQêépû¥×‹k¼ü\\\"\\000â«cïK!@(E…iïş¾éI©ª†VŞµNg÷N£@)¬}ÖQå*3U| ¬Ë?£(Q­õÏ¯6âPÚyß'[{YB)RB-/ˆU}¡bú—`èååB…£®§âøÿQÓ×î±”÷Š¾¾²E/à—kƒ‘ÎR¾¾¾ßë Ùk¨Dätÿ®Óôö¶h ÜBêæ5J}?õ‚Ã¥²(8–@@éÅ×õ½YÃæã‚Ò®8jp«ú„D»U÷ÒŠ¯ä}¦‚¡ÇgŞ»ëXEB… )ÔİÓedB¾uúu•DRÕê¿B´ËômÔ‰éŞ­F@ş=J¶/½\\000ª‚µÃ^¿¶@âJ©ŸÛODB¹…˜®wß¿Æ(EI÷\\\
·uß×U×:º¢(ıÇİ‹÷¯¤‚ ¥:®;øêYı/6((fŒ…®·Ç¹Ä”ì¢b²~Q¤ Ş¿@Ûü*)½¾,æØşõÕÅ(ü¿JR–¾‹ô¤}WŠ…­\\000X®3Eïß:«pÄ	!N)€ıêÿ¿ÈV]S\\000B¡ş®k/”¬:¡Æ_•4¾ßU¶ÄöY>¥şÓ\\000Qí.	l6*áåÿ»$…8E±ÿÂBİ&UÜáP`QÓœÿ—\\\"B‘Ü½IRÿêúÿíWiIJóí××¿DH¦’ÂP.›¶¦Û#!R½[JU+× Qô÷ÿ%Û6»H$B©âísù;ª÷ÕWE\\000ª5që×¥l¸\\000%`êö[£\\\\B@ÿ“¢Õ\\\"–_¢ûö€ÂĞëµúou@‚…_Nçİ²l#Š=–\\000Ù×î½®&äõájA$`uGû­t~¨\\\"œo¥°¤ûŸÕ‘Hıõø4”·¾¾€è\\\
ª¯³îhÔ @µŞ¿erÓ£\\000‹nwm(R\\\"Aÿ^·­8×{Ö@Š|»¼[Ç’Nìlåµ‹£_°Rş¿ê§˜®®×Â©5¼ëz‚PG	½}×°„°§¹¥û ÕãÚëz¹~\\\"@–›ß—ˆ¢î÷åZ_) *Øí×ú4¸\\000J.Ÿ­k)ò»“ ‚ˆúèoï;Õ. AÅ{{Û\\000Àê*-\\000’ş]Q¨øV P4áéõ=»AH¾o©@õŞ÷¥ê}maĞ†§ÕS”·ûéiD«¯¯€é¨ÂâîO	e	ô¿[µ!€VŠ/ŒR–õoõ¯'	RŠ—F¾şw›r’PõÛÕm‡+ª(	 jùßõ¶T\\000‘«×ù·¥×0ªšÅAÁBƒ­ßövLb!Ò·µ?(=\\r¨Ò%Ï»×XúK»4T¼ i\\\
vO×n}_\\\
”ÎĞ~O•ª£¾¨å@}Ş•TÙ(Foµİ\\\"ue›¦–pª9ŞÛaªş¨ãÚ}—‰(ñQDR¯UÕõ¾ë6tHoŸHÖï¯­‚êbƒÊ—úîëéXƒ‹>]aİõk©GÅB/éM¢ß¯…òíU PN!V._._ZQµU‚(å´÷®S	¢]k'’k„HÕ÷PHVä÷ÕÓkC‘¦ %Dº_m½¡jã×-iJ½ Dhq™ /iËªõÅö\\r%Z}	ŠÔğ.ëW©ÔJêxiú¥Bè¶\\\"uÒy­Q*uŠô~)ßõTZ¤u:!YqMZZy.Y×»Æ\\\"„êT1…úİUıUDˆ²•²Ê{ù5(¯¢şjŞ(jtT(qÕöj·VŒ$ÄW`Ñ+Óïk—\\\"—RBÔúëVkIT”:í¢ò”r»\\\"MQYôJ}kµ*\\\
S¬”¶©iÊU·D5)«\\\\)®—ªŠÔT’RÛİkÔäÊkJ“RUEªZíİª\\\"hURÉÖ¯—”Tnw•0R¢íìTÙÉ¢*E­VU¥ºo)US­¸V•ûš@êj¯•¶RiZIUR´fUU5k)«•V	+[i«¨êšfUEJUQj-UUÕ´W4uÓ¶—$•n³LËJ¥ªUKUÍ’µJ¶TRºš°nEÚVje©’¶®E©Öl¡¶CU¥Jµª”¶ªµj•,Mª”V«¬­Ô¥”ÕVDe©êŞUµ–ª6BHM-Uºjµm•QU©Ö*¤Ş²*£´«ª*EªU]•U­J*UK©›šVUµªêL)ÕTZ•ª-©ÙÔUI•*•ªªªÚUZ«T©RU¦šµUiÕ2U©Ò*¥­Uµ*«J¥mU«¤TUU•Tµ¶šU¥*•JUªVUµªÕª*U¥jªVUUUUU•ªªj¥ªªªªRU«jU«JU©j–ªªVUUUUUUeUUUUUUU5U•ªªZUUU©ªªªªªªªªVUU©ª,«UUUVUUZU–UUªªªªªVU©ZUUUUUUUUUUUUª*U«ªZUUUUUUUUUU¥ªª–ªUUU¥ªªªZUUªªªZ•VUU•ªªªªªj¥ª¥Vj¥ªªªZ©•UUUUUUUY–ªªZjjª¦VUUU•jeUVUUUUUUj\",\
    [ \"sound/fall.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000'~\\000\\000\\000\\000\\000\\000pÂóvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000À]\\000\\000\\000\\000\\000\\000ªOggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000'~\\000\\000\\000\\000\\000ÇÑ@[Dÿÿÿÿÿÿÿÿÿÿÿÿšvorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000€ \\\
Æ€ĞU\\000\\000\\000\\000BˆFÆP§”—‚…GÄP‡óPjé xJaÉ˜ôkBß{Ï½÷Ş{ 4d\\000\\000\\000@bà1	B¡Å	Qœ)Ba9	–r:	B÷ „.çŞrî½÷\\rY\\000\\000\\0000!„B!„B\\\
)¥RŠ)¦˜bÊ1ÇsÌ1È ƒ:è¤“N2©¤“2É¨£ÔZJ-ÅSl¹ÅXk­5çÜkPÊcŒ1ÆcŒ1ÆcŒ1ÆBCV\\000 \\000\\000„AdB!…RŠ)¦sÌ1Ç€ĞU\\000\\000 \\000€\\000\\000\\000\\000G‘É‘É‘$I²$KÒ$Ïò,Ïò,O5QSEUuUÛµ}Û—}ÛwuÙ·}ÙvuY—eYwm[—uW×u]×u]×u]×u]×u]×u 4d\\000 \\000 #9#9#9’#)’„†¬\\000d\\000\\000\\000à(â8’#9–cI–¤IšåYåi&j¢„†¬\\000\\000\\000\\000\\000\\000\\000\\000 (Šâ(#I–¥išç©(Š¦ªª¢iªªªš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš@hÈ*\\000@\\000@ÇqÇQÇqÉ‘$	\\rY\\000È\\000\\000\\000ÀPG‘Ë±$ÍÒ,Ïò4Ñ3=W”MİÔU\\rY\\000\\000\\000\\000\\000\\000\\000\\000ÀñÏñOò$ÏòÏñ$OÒ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ€ĞU\\000\\000\\000\\000 ˆB†1 4d\\000\\000\\000€¢‘1Ô)%Á¥`!Ä1Ô!ä<”Z:RX2&=Å„Â÷Şsï½÷\\rY\\000\\000\\000FƒxL‚B(FqBg\\\
‚BXN‚¥œ‡N‚Ğ=!„Ë¹·œ{ï½BCV\\000€\\000\\000B!„B!„BJ)…”bŠ)¦˜rÌ1Çs2È ƒ:é¤“L*é¤£L2ê(µ–RK1Å[n1ÖZkÍ9÷”2ÆcŒ1ÆcŒ1ÆcŒ1‚ĞU\\000\\000\\000\\000aA„BH!…”bŠ)ÇsÌ1 4d\\000\\000\\000 \\000\\000\\000ÀQ$Er$Gr$I’,É’4É³<Ë³<ËÓDMÔTQU]Õvmßöeßö]]öm_¶]]ÖeYÖ]ÛÖeİÕu]×u]×u]×u]×u]×u\\rY\\000H\\000\\000èHãHãHäHŠ¤\\000¡!«\\000\\000\\000\\000\\0008Š£8äHåX’%i’fy–gyš§‰šè¡!«\\000\\000@\\000\\000\\000\\000\\000\\000\\000(Š¢8ŠãH’eišæyª'Š¢©ªªhšªªª¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš¦iš&²\\\
\\000\\000\\000ĞqÇqÇqGr$IBCV\\0002\\000\\000\\0000ÅQ$Çr,I³4Ë³<MôLÏeS7uÕBCV\\000€\\000\\000\\000\\000\\000\\000\\000p<Çs<Ç“<É³<Çs<É“4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4MÓ4 4d%\\000\\000\\000€ Ç´ƒ$	„ ‚äÄÄ¤… ‚ä:%Åä!§ bä9É˜Aä‚ÒE¦\\\"\\rY\\000D\\000\\000Æ ÆsÈ9'¥“9ç¤tR¡¥Rg©´ZbÌ(•ÚR­\\r„RH-£Tb-­vÔJ­%¶\\000\\000\\000\\000,„BCV\\000Q\\000\\000„1H)¤bŒ9ÈDŒ1èd†1!sNAÇ…T*uPRÃsA¨ ƒT:G•ƒPRG\\000\\000€\\000\\000€\\000¡Ğ@œ\\000€A’4ÍÒ4Ï³4Ïó<QTUOUÕ=ÓôLSU=ÓTUS5eWTMY¶<Ñ4=ÓTUÏ4UU4UÙ5MÕu=UµeÓUuYtUİvmÙ·]YnOUe[T][7UWÖUY¶}W¶m_EUUÕu=Uu]ÕuuÛt]]÷TUvM×•eÓumÙue[WeYø5U•eÓumÙt]ÙveW·UYÖmÑu}]•eá7eÙ÷e[×}Y·•at]ÛWeY÷MY~Ù–…İÕu_˜DQU=U•]QU]×t][W]×¶5Õ”]ÓumÙT]YVeY÷]WÖuMUeÙ”eÛ6]W–UYöuW–u[t]]7eYøUWÖuW·c¶m_]W÷MYÖ}U–u_Öua˜uÛ×5UÕ}Sv}áte]Ø}ßf]Ïu}_•máXeÙøuá–[×…ßs]_WmÙVÙ6†İ÷aö}ãXuÛf[7ººN~a8nß8ª¶-tu[X^İ6êÆO¸ß¨©ª¯›®kü¦,ûº¬ÛÂpû¾r|®ëûª,¿*ÛÂoëºrì¾Où\\\\×VY†Õ–…aÖuaÙ…a©Úº2¼ºo¯­+ÃíßW†ªmË«ÛÂ0û¶ğÛÂo»±3\\000\\0008\\000\\000˜P\\\
\\rY\\000Ä	\\000X$Éó,ËEË²DQ4EUEQU-M3MMóLSÓ<Ó4MSuEÓT]KÓLSó4ÓÔ<Í4MÕtUÓ4eS4M×5UÓvEU•eÕ•eYu]]MÓ•EÕteÓT]Yu]WV]W–%M3MÍóLSó<Ó4UÓ•MSu]ËóTSóDÓõDQUUSU]SUeWó<SõDO5=QTUÓ5eÕTUY6UÓ–MS•eÓUmÙUeW–]Ù¶MU•eS5]Ùt]×v]×v]ÙvIÓLSó<ÓÔ<O5MSu]SU]Ùò<ÕôDQU5O4UUU]×4UW¶<ÏT=QTUMÔTÓt]YVUSVEÕ´eUUuÙ4UYveÙ¶]ÕueSU]ÙT]Y6USv]W¶¹²*«iÊ²©ª¶lªªìÊ¶më®ëê¶¨š²kšªl«ªª»²kë¾,Ë¶,ªªëš®*Ë¦ªÊ¶,Ëº.Ë¶°«®kÛ¦êÊº+ËtYµ]ßömºêº¶¯Ê®¯»²lë®íê²nÛ¾ï™¦,›ª)Û¦ªÊ²,»¶mË²/Œ¦éÚ¦«Ú²©º²íº®®Ë²lÛ¢iÊ²©º®mª¦,Ë²lû²,Û¶êÊºìÚ²í»®,Û²m»ì\\\
³¯º²­»²m««Ú¶ìÛ>[WuU\\000\\000À€\\000@€	e Ğ•\\000@\\000\\000`cŒAh”rÎ9RÎ9!sB©dÎA¡¤Ì9¥¤”9¡””B¥¤ÔZ¡””Z+\\000\\000 À\\000 ÀM‰Å\\\
\\rY	\\000¤\\000GÓLÓueÙËEU•eÛ6†Å²DQUeÙ¶…cEU•eÛÖu4QTUY¶mİWSUeÙ¶}]82UU–m[×}#U–m[×…¡’*Ë¶më¾QI¶m]7†ã¨$Û¶îû¾q,ñ…¡°,•ğ•_8*\\000\\000ğ\\000 VG8),4d%\\000\\000\\000¤”QJ)£”RJ)Æ”RŒ	\\000\\000p\\000\\0000¡²\\\"\\000ˆ\\000\\000œsÎ9çœsÎ9çœsÎ9çœsÎ9çcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1ÆcŒ1Æ\\000ìD8\\000ìDX…†¬\\000Â\\000\\000„‚’R)¥”9ç¤”RJ)¥”ÈA¥”RJ)¥DÒI)¥”RJ)¥qPJ)¥”RJ)¡”RJ)¥”RJ	¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ)¥”RJ\\000&\\000P	6Î°’tV8\\\\hÈJ\\000 7\\000\\000PŠ9Æ$”JH%„Jå„ÎI	)µVB\\\
­„\\\
:h£RK­•”JI™„B(¡„RZ)%µR2¡„PJ!¥RJ	¡ePB\\\
%””RI-´TJÉ „PZ	©•ÔZ\\\
%•”A)©„’R*­µ”JJ­ƒÒR)­µÖJJ!•–R¥¤–R)¥µJk­µNR)-¤ÖRk­•VJ)¥”JI­µ–Zk)¥VB)­´ÒZ)%µÖRk-•ÔZK­¥ÖRk­¥ÖJ)%¥–Zk­µ–Z*)µ”B)¥•’Bj©¥ÖJ*-„ĞRI¥•VZk)¥”J(%•”Z*©µ–Rh¥…ÒJI%¥–J*)¥ÔR*¡”R*¡•ÔRk©¥–J*-µÔR+©”–JJ©\\000\\000tà\\000\\000`D¥…ØiÆ•GàˆB†	(\\000\\000\\000ˆ™@ \\000\\\
d\\000ÀB‚\\000PX`(]è‚\\\"HA\\\\8qã‰NèĞ\\000ˆ™\\000¡\\\"$dÀE…t\\000°¸À(]è‚\\\"HA\\\\8qã‰NèĞ\\000\\000\\000\\000\\000\\000\\000\\000Ñ\\\\†ÆG‡ÇHˆ\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000€OggS\\0002\\000\\000\\000\\000\\000\\000'~\\000\\000\\000\\000\\000\\000ï¼®{ub\\\\^]XaUWRNOOQRPSJTQMKQONvŸL\\000àœ°*`¥ôô¥d—íg³}÷n='¶ÑğMp¾6ûG#™¯Štız˜Æ»>nÆ]<% ½ô¸şmi:M5&t¤¹ä†bJJ›‘^\\\"nNó7¡T†Éóïs·Ü[>eëø†	ôOšŞÚL|Ì±3øóÏMş¨k\\000–¡„\\000ğ‹“„œÑ—RJz’ıiŞåøZYaòå>—[b#T=ñNäÜÿ•§l%pûãí#Küˆ–*©O¾13BÕ“®—¼2²)¸ÃZÄˆæßT7¯À˜ïÂÛÊª€¬V\\\"Ä$RÏÉòLK­«X	¢Ä†¥7\\000’£\\\\ÅQ0âå®Ã¾ê\\\\-fİ{«¦ù=ÑgÙÔR|Å¹Ğ_Ü˜«ÒNÓ0^šEDkª­j9iÅle³IÙoŠ› `²Ä+n	¤Yœ`æœó()eï‹Cô%—Û\\\\È1‰lÓS}\\000¦­\\\
@<T[62¸R«Ü¹æú¯OÛ®·”Òmê¡Ôã§áfÜ*dïÓÈÿ]…Ñ¯Œ!~C·„¢ŞÏn,*Ê,ƒÊl‚”›¼QU¡yèr:Ù­›;êNóÒÖv\\000ª»\\\
@\\000û^×ĞÏõå#·ï×gnO§ëu‹[wa/¯¹°û=kTÈëö”SsªíNÇnî1ì%ÙZ\\\\èR·Ü¬g‚³šßj‡sÉD,‰°\\000ÍŸßo éc\\000¢½\\000\\000Àãäc»ƒk¨eÊ£×UûOİ÷òNY8ºØcÅñB½¹ï#6†È˜§z¨—¨|'\\\"`~¥Y\\\"vZ$©n(Hu¹²°(ÊÏ\\\
O½Á’¢Ù-Ã¡=½¸,À³5\\000½\\\
D\\000\\000ª?\\000NAiòXuÙ˜!ôşêÚ¿~.¯W¼¢+›\\\"‰¢AŸéÊcê!CŸı‘mL©–	ŞêÖÒ™]°¨ÖÏa{±‰ŞğAQ:ìˆşb1”\\000\\000~¹T€”\\000x2sîÁ›vM©dÚì—MÖœoíı~ª¯…›ÂY*Ö±ÅO8˜s^¦µ9^Ø]÷åÀÒLïÔ=—Ÿª¯H$ä:\\000	´û`¨=ß&Œ\\rmbXKnƒ\\000†³ˆ\\000S@úY\\\
xÈHJ\\r*IÇ/{ûõ¨©[óÛoßÙcsô|¶·³ŞŸ¬ÆiŠŒ,¸lF[Œ³&× Àœek?¡/Th„±†ÖP»$æj\\000Š¡D\\000áDXSŞIƒq{á0î¼¯Gıvìq|»Y¶è°™.¾M}û†Zşe¿|÷fGdh‰-àã/†“€•\\000=’h,¿íyZdãèŞ¨\\\"ö‘€b\\000‚©H\\000W\\000°SjkĞôú:—/½äı÷ªb/Öÿïhq“«ã“àpëM¬Â¤×“˜+E±¼•ä\\000|•à\\\"F‡Q2L1ƒsbDÖ¿5@˜\\000Š©F\\000\\000€=¾‘rü<Ü™ŸöÇÇØ¹)Óİùæ6î†ã¬Ší©`´İJï©•so|KkfA9é/\\000p­\\000¸0¡-Ó³¡@bóB\\000z±$	Øìñ\\rÉ÷Si|ş¸^®|õHqì·õ5ãùÖPleÌ=Ä§ôCË	vÌp‘ÕÚŠÒ R…&¬4.œ„,‘õÈ¶ÙwL(àPìP\\000~³ÆáHwƒÒ¶¤Ï³ìx¾~½u÷>\\\"/Íêl'cnC¥\\\
~ü€;–Y•AaQ½hğI=SB~< =¯<#\\\
ìÖ©0¡Cƒ~‡\\000r­¤	Ø;¿’ ­ÎDÉBTrÿßÖe}úlımÙ³`wŞ²¬<Ç×;i¦’°ÒQo`8~Ns¶68)\\\"ÈÍ†˜‚KZa$g‘æş:iBĞæ£\\000b§¼lÎ—sBÖø¸’[=Wşf)¯ßº¥<{}Ÿ ¯h¿q«Å>R9V\\\
Nèš&MW‡*0KnîŸØHRa†t/¬u´ş\\000 ôC\\000R™Ò™I\\000àg4Ìˆ½;Úñ¿÷Wäß2ßŞbœ\\\\(µym$³=ájãş×©ä›P¶É‚©Ñ@ÜO.íl\\\\ädcğğ¥OE÷Æ\\000b•4€ä\\000xóÒ*éŞÿı™ûŞ£Ö«nGçù±Ì˜bVYŠNÕ¸w® Ş}ß¡©7\\\\JM™NçŸ‰Y'C62/.¬%ß”B*\\rÀ£zûH\\000f•(\\000ç\\0008s É$®ÊÄq?~Y6ıÛ4gõaÛ’éx´u]³ÂY'ÖÙdÒ÷Á,ô¾xvÛÚAÀ\\000úor%|õuqçL–JéÑ~R“Ø\\000œR5QƒRUÉy|ó4Ù³¼ëõs.õüte{è¡ÓGøÆ\\\
Qú“iÃ¶5Vfâ”¡S¤Sú¢³cI–ÖB(4(TnC\\000N“Ø“\\000\\\"çÇdxVõø©JüÍ~»tûŞıŞhË·I÷”³ìø5…V,>¦¶jM–Ò»u‘t´xúÁöJ&\\\
 ğõfîL…PàĞ¡€r.c\\000B“ \\000À@à¹“a–j ùz›xWÙ~öËí®Ñ¡xZ\\r'ƒ(´GbÈ.PŠòP¯:M=‚M¥ùpÀ‰Å­ı›ç4–™cĞ‡y_\\0006‹ÔĞ.\\000Õ)U•üuùp¬ú£§ÒíÁMmé7â¨gu¾Å0ÙM©ÕÀKğ×\\rR•¥eì™©×6c±\\\
»÷mêëœ8p:0†€Æˆt\\0006È\\000€Ğ™1—¤@i¡Ğ@êzâ}Ó­É~Õo}§&\\\\ƒç®„‘2õ;Ë‡3\\r¹¢Ò0Åó¢-8ö\\\
Xtö“Oi«vÑ=Ôƒ8` wì\\000oÔÂP€3–«S¢4•QI4óu•7iı¨®XäL(&[Õ[Ñw˜Ú†lÆúü;²LaO¢à¸Û…Ñn^óÓ\\\"=ÇL„„1Æ&\\rç\\000MV\\000˜H´:=7åÄ0dg¿~õù—wŠv’ËVík€·wy›‹ŞÏ¼–ZŠ´xƒk;öˆn(®\\\
‰€÷&E¦c˜Ğ€É½³hÃP\\000\\000\",\
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
	spin_mode = 1,				-- 1 = allows T-spins\\r\\\
								-- 2 = allows J/L-spins\\r\\\
								-- 3 = allows ALL SPINS! Similar to STUPID mode in tetr.io\\r\\\
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
    LICENSE = \"MIT License\\\
\\\
Copyright (c) 2025 LDDestroier\\\
\\\
Permission is hereby granted, free of charge, to any person obtaining a copy\\\
of this software and associated documentation files (the \\\"Software\\\"), to deal\\\
in the Software without restriction, including without limitation the rights\\\
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\\\
copies of the Software, and to permit persons to whom the Software is\\\
furnished to do so, subject to the following conditions:\\\
\\\
The above copyright notice and this permission notice shall be included in all\\\
copies or substantial portions of the Software.\\\
\\\
THE SOFTWARE IS PROVIDED \\\"AS IS\\\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\\\
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\\\
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\\\
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\\\
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\\\
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\\\
SOFTWARE.\\\
\",\
  },\
  mainFile = \"ldris2.lua\",\
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
