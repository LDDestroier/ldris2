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
  mainFile = \"ldris2.lua\",\
  compressed = false,\
  data = {\
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
    local tY\\r\\\
    local is_solid, mino_color\\r\\\
\\r\\\
	tY = self.y - math.ceil(self.overtopHeight * 0.666)\\r\\\
	local topbound = (self.height - (self.visibleHeight + self.overtopHeight))\\r\\\
    local visibound = topbound + self.overtopHeight\\r\\\
\\r\\\
	for y = 1 + topbound, self.height, 3 do\\r\\\
		colorLine1, colorLine2, colorLine3 = {}, {}, {}\\r\\\
\\r\\\
        for x = 1, self.width do\\r\\\
            minoColor1, minoColor2, minoColor3 = nil, nil, nil\\r\\\
            for i, mino in ipairs(minos) do\\r\\\
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
            colorLine1[x] = (minoColor1 or ((self.contents[y]     and self.contents[y]    :sub(x, x)) or \\\" \\\"))\\r\\\
            colorLine2[x] = (minoColor2 or ((self.contents[y + 1] and self.contents[y + 1]:sub(x, x)) or \\\" \\\"))\\r\\\
            colorLine3[x] = (minoColor3 or ((self.contents[y + 2] and self.contents[y + 2]:sub(x, x)) or \\\" \\\"))\\r\\\
\\r\\\
            if colorLine1[x] == \\\" \\\" then colorLine1[x] = (y     > (visibound) and self.blankColor or self.transparentColor) end\\r\\\
            if colorLine2[x] == \\\" \\\" then colorLine2[x] = (y + 1 > (visibound) and self.blankColor or self.transparentColor) end\\r\\\
            if colorLine3[x] == \\\" \\\" then colorLine3[x] = (y + 2 > (visibound) and self.blankColor or self.transparentColor) end\\r\\\
\\r\\\
--            if colorLine1[x] == \\\" \\\" then colorLine1[x] = (y     >= (self.visibleHeight) and self.blankColor or self.blankColor) end\\r\\\
--            if colorLine2[x] == \\\" \\\" then colorLine2[x] = (y + 1 >= (self.visibleHeight) and self.blankColor or self.blankColor) end\\r\\\
--            if colorLine3[x] == \\\" \\\" then colorLine3[x] = (y + 2 >= (self.visibleHeight) and self.blankColor or self.blankColor) end\\r\\\
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
    [ \"sound/drop.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\0002\\\\\\000\\000\\000\\000\\000\\000��{Ovorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\0002\\\\\\000\\000\\000\\000\\000RO�!D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�������˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ���,۲m��\\\
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
    [ \"sound/lock.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000a|\\000\\000\\000\\000\\000\\000\\\
z��vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000a|\\000\\000\\000\\000\\000���-D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�������˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ���,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000a|\\000\\000\\000\\000\\000iC-2	s�}{a]_V\\\
.�g[�(e����	X\\000�'��{_��/߿]�7�=�f?gMj��ev��N���`��7�ʰ�9[2��s�������Su}�ܹX�����F1�8����s+ϞS��Ə�R��6���`\\\
�K�'\\000��/�\\000�RUs���v��G���Xk����aN=fƑ:F��LM�Q�T;nr�4�e���$����*t�-���t�u��LA|�5�&�)w�oF1&n+=��^Ue�6���ӝC,n�\\000NɐA��� W�R����۪�o���~u�X(�h��?���P\\\"5��^���i/4 ���a\\\\J�GC[�K�䜢��Z��.Q^3��|\\\\ޞ�P�oOՖp,-%����L��vy�B���u���iKk�	J�I�ڤ�%��5����S�ϔ���^o��g�Ρs����z\\\
���FW1��m<;11�J��J���t)p�mc���6��݃d�axL6�X�UGzq]ɋ&{j�e߲��n�~��Z\\\"��T�A�Hf�����+:��W���Ⱥ/coS#3f�f��L�X�&�f�~4�؜[%��#\\r�>�p8Î|�@��O0OE7����1�sVRE�\\000��8`t�m۶@�ڒbY�㸭�43�����>n��x���f���ԑ�r@א�*lc�X�m��h��x�_�E�v�Iޝt�@��X�\\000\\000�mb�4�s9�〒���5u�S�_[�V����or.q\\\"�\\\
�I��4v�,�;O�:W�/e�2�ܘ�4��i�� ����Ж�[)�����o]v\\000��k�]�N�N)gV���Io}���ұ���\\\\U�?��~T����}�sM�L�n2=�]�1�\\000�{&l�ܸ\\000�_@����<^���U\\000I�$�\\000\\000\\000\",\
    [ \"sound/mino_T.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000`\\000\\000\\000\\000\\000\\000U�Evorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000`\\000\\000\\000\\000\\000�')iD�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�������˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ���,۲m��\\\
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
    [ \"sound/mino_I.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000/Y\\000\\000\\000\\000\\000\\0008�vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000/Y\\000\\000\\000\\000\\000��rD�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�������˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ���,۲m��\\\
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
    [ \"sound/mino_S.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000�_\\000\\000\\000\\000\\000\\000�Lf�vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�_\\000\\000\\000\\000\\000�u�D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�������˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ���,۲m��\\\
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
\\000�\\000���.\\000��W\\000�\\000*�����CS��X��ӈ����q�C�2��c��\\000�\\r���{\\000\\000\\r��M.\\000$v}����8gU���%�b�Y`��ϝ���Ν;_��!\\000��6�(`1�\\000��\\000�\\000�r\\000{SѺ~�n�c�h��N�z��h��~�>1���(DH�%���8�F	��U����\\000y��lg�u��΀�@a��e8���mOX*?_��#YeL@v\\000�@��\\000��>\\000y�9�����C�Rm��S�	����Pz��\\000�\\000N.`00��*\\000{�9��<�M��j+}��{\\000�?R��|u\\000J	\\000��\\000'�9&@�ػ�\\000	؎\\r\\000����T-� }P�Ml4�&�a����Q:����\\000\\000`:@�\\000>�U4��>\\000��u�ti~S.���=44�-*c��w\\000�h\\000\\000��M\\000\\0004�\\000zqx�һ�V��y�,,*c����,~����C��b\\000\\0007.~�<\\000|`�\",\
    [ \"sound/mino_O.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000�^\\000\\000\\000\\000\\000\\000svorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�^\\000\\000\\000\\000\\000d�,D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�������˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ���,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000�\\\"\\000\\000\\000\\000\\000\\000�^\\000\\000\\000\\000\\000�%[�VHLW_LbfDD><BBOME?3V���3d���M�#\\000Ц=�B���e���T��s������D��ta`O\\000\\000����O�G\\000�3�_\\000̟C	`]Z\\r�U���o(C\\000n��{]�6�C��\\0008\\000iP{�n����i�\\000s�����y\\\\�w�V�\\000��%z���V���~R��� �\\000f�+�x�\\000���\\000��>z���\\000����}�\\000��g\\000�u%\\000���9��Z�7����QV�n���A�0\\\\\\000Z�r�Z@���`\\000@�\\000�lc�����?�����\\000��Z�\\000K��p��G������9�i@�[f@0�|0cf��\\000b�8-<����E��D\\000��\\000\\000�cd}�{�{�4m��4S�W��D��S�v��*��G�,��8�ޢ���qu_��\\000���V^��Z/��i���meIz\\000Lc����5��mϖ\\000�y#2n���Yi\\\
\\000���e\\000�xH\\000���6�pu@�Z�d�kpS�\\0004�\\0008<�Z��3�y��]�_���*�D�\\000W�Y��#\\000.�n��aB�10fP��5�J�D����úY�X�E�=����'\\000R�+�vg(um<���KޟO�����1��&��vo+q���\\\"+��)ƪ �W��!��\\\\���0�[-���|iE��I�p�1�1�~~2P�8���\\\
cvu?\\000^�}&7���<����K\\\\��\\000�Z`�h3\\000\\0000\\000��\\000��`XI<H@	���0��%�@@�C?t\\000:�+��|/TC�1T�VP�P{�\\\
v8����+�;��������<�#v�K�5�`��։]��0{��'��8١Ԓ}Nj�X�zH���8r���u-<u\\r��\\000��(@1`�:\\000�g��-���S8�ih���@�:�9�\\r���p:\\000g���<HP���\\\"�e�H�ˌ�j��(�\\000}��E-)��o�*B�<�2�StzH�s�!���%�_�z����\\\\Bc����\\000\\000u8�]8~���	\\000PnS�b�tv�.��5��c�V9��Q����ѱK��<0�X\\000�~5`\\000w�W\\000�V	\\000(=\\000�1��f&�Yպ}	��\\000�]�`[���+�Y���7��aFu�� ~U�U���+�r�=\\000y�\\000�}������A��Y�Z�˛����y%�ω�y��L���؇�\\000l��?\\\\�������>�҂����[e�au���-�y\\000o�U�ڬ�^�^m1��v�2�C��d�``�P�� }�y*�|��V�ΎΖ�\\000g�5�~P�ЭJ�2\\000k{�	�i^`;�i�-_b�pYCF�\\\
v�X�:�+��\\000�?W�����1\\000��4M;�<���!';Ɇg1@�CU����@���\\000\",\
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
    [ \"sound/mino_L.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000Q/��vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000*5�!D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�������˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ���,۲m��\\\
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
    [ \"sound/fall.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000'~\\000\\000\\000\\000\\000\\000p��vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000'~\\000\\000\\000\\000\\000��@[D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�������˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ���,۲m��\\\
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
x�HJ\\r*I�/{����[��o��cs�|�������i��,�lF[��&נ��ek?�/Th����P�$�j\\000��D\\000�DXS��I�q{�0�G�v�q|�Y�谙.�M}��Z�e�|�fGdh�-��/����\\000=�h,��yZd��ި\\\"����b\\000��H\\000W\\000�Sjk���:�/�����b/���hq�����p�M�¤ד�+E����\\000|��\\\"F�Q2L1�sbD�ֿ5@�\\000��F\\000\\000�=��r�<ܙ����ع)����6㬊��`��J���so|KkfA9�/�\\000p�\\000�0�-���@�b�B\\000z�$	���\\r��Si|��^�|�Hq��5���Ple�=ħ�C�	v�p��ڊҠR�&�4.��,��ȶ�wL(�P�P\\000~���H�w����ϳ�x�~�u�>\\\"/��l'cnC�\\\
~��;�Y�AaQ��h�I=SB~< =�<#\\\
�֝�0�C�~�\\000r��	�;�� ��D�BTr���e}�l�mٳ`w޲�<��;i����Qo`8~Ns�68)\\\"�͆��KZa$g���:iB��\\000b���lΗsBց���[�=W�f)�ߺ�<{}� �h�q��>R9V\\\
N�&MW�*0Kn��HRa�t/�u��\\000��C\\000R�ҙI\\000�g4���;���W��2��b�\\\\(�ym$�=�j��ש�P�ɂ��@�O.�l\\\\�dc��O�E��\\000b�4��\\000x���*������ޣ֫nG���̘bVY�Nոw� �}ߡ�7\\\\JM�N矉Y'C62/.�%ߔB*\\r��z�H\\000f�(\\000�\\0008s �$���q?~Y6��4�g�a���x�u]��Y'��d���,���xv��A�\\000�or%|�uq�L�J��~R�؁\\000�R5Q�RU�y|�4ٳ���s.��te{�ӐG��\\\
Q��iö5Vf┡S�S���cI��B(4(TnC\\000N���\\000\\\"��dxV����J���~�t����h˷I�����5�V,>��jM�һu�t�x����J&\\\
���f�L��P�С�r.c\\000B��\\000�@���a�j �z�xW�~����ѡxZ�\\r'�(�Gb�.P��P�:M=�M��p��ŭ���4��c��y_\\0006���.\\000�)U��u�p�������Mm�7�gu��0�M���K��\\rR��e왩�6c��\\\
��m��8p:0��ƈ�t\\0006��\\000�Й1��@i��@�z�}ӭ�~�o}��&\\\\�箄�2�;˝�3\\r���0��-8�\\\
Xt��Oi��v�=��8`�w�\\000oԁ�P�3��S�4�QI4�u�7i�����X��L(&[�[�w�چl���;�LaO��ۅ�n^��\\\"=�L��1�&\\r�\\000MV\\000�H�:=7��0dg�~���w�v��V�k��wy���ϼ�Z��x�k;��n(�\\\
���&E�c�Ѐɽ�h�P\\000\\000\",\
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
    [ \"sound/mino_J.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000�g\\000\\000\\000\\000\\000\\000ѕ~�vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�g\\000\\000\\000\\000\\000e#CD�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�������˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ���,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000PF\\000\\000\\000\\000\\000\\000�g\\000\\000\\000\\000\\0008��%MBSGYMQXLbNRVPgfhaQTLfgRT`QAAOAD6D96BS[��F�ax��PU�jU\\000�?X`1�,E��S���[����=�\\000@|�Dӝo��\\000d_/i\\000@��ʕ\\000��\\0000�B\\000V[[�}o��O\\\
��?υ.%U@���H�4f��4Q�\\000I��\\000v4\\000h�\\000\\000�_���%p�J\\000Ne��l�{�~P?h���-\\000�v��	���պ�}�5_��]j.\\000�i�D�>�w��B����j��|�V��@E\\000p=�1\\000\\000�Vq+�����@yЧ�`R�\\000P���\\000���b�����ɚ(�e���\\000����TX\\000��\\\
\\000��CI`es�yNy�)\\000(,F	$X���};���F<�j}��k����z��_�/���ѶO,���4`i)ڱ�)\\000\\000��Rt\\000\\000�c,$\\000Ry�J.����ȯ��m�N\\000��z��\\000�\\rA#5ǖ���ѭX�?9~\\000P��4gv -z��^|�zX@�\\000\\000G\\000Fg�=�o� ��s=(��@�m�h�f���e���O��Ox36�w�����oBM��!\\rG#�y��ڿ)ls\\000\\000�G��\\000Vu���S��A�� n\\000�\\000�h�[�b��:��w�\\\"���.���ɩ0fO>\\000DZڳ�ԅ=��+�����d/<�\\000�X�r�\\000F��3@�\\\\\\r�^^/ o\\000X@���\\\"�a�ų~i��w�#K\\000�N�|��1�\\000�\\000*\\000޿�	�&*��\\000	�_z\\000F�U��(�ר_����?<� @$���2G�\\000��Dj5G�msmM>Un),�'E:��@��\\000`��%��;�&�>;qv�`c�����\\\
��8˙\\000N�}��vd��t����.\\000K\\000��s�Y\\000*GY��?O�.�H�O�@�0=�>��~��$$��0P\\000���j�7R�UdK�#y=��������`��%�m:\\000T��,]�Թ�q,�UM�Q)0�MT;�}\\000�2�HJ��!`?$Pw���9.#��jBs�*���3����J�#hA��XIi��jӴ�^k����USt����%y����d�m##��J@�I�ƞ���7�\\000�̯�5Nor������|�l��d<*�L�\\0008�q�i�>ۏ+	\\000\\000\\\"�VsSkNF�w.&�w�c`��3�?�\\000\\000�R �V�\\000�K\\000B��\\\"`SG���-�LkQBo\\000�'�r��uO��;�k��XI��b@Ӱ^���싃��b��v3�����	�����9\\000��\\000B2L��_���ހX'K\\000��\\000\\000B�+�(�\\\\�im���� зGr�x\\0008\\000\\000�m�\\000�b�질T��Y�_�D�-�\\000@s����^�_3�/l���.�f�T��(��(1�(�q\\000m���l\\000R��U�RC���Fy0�``�=�\\000�^��ʺ�R������¼ɲd���0�U\\000���Aj�w\\000\\0000��s��\\000Q\\000��&�j�7�`���̈́\\000��>�Y;{7.�E���s�Q\\r�\\0008\\000\\000���\\000��D4t٬�M�?�9'[:�\\000\\000�'r\\000��/�E_���92��r�>X�pV�$��n�yv�~��\\000\\000Oe\\000���\\000N�T�&�%�+����z\\000N$\\000x�\\000�\\000t*4d�ڔ��o�M��#�x$`*�\\000��?k��_�\\000pS!\\000�\\000���\\000\\000@�.�5w^\\\
*�$[����\\\
 w����+�>�ɥ��UӰOՆGOg�y3}[��17���\\000x ����� �!c�UA_�HS\\000�ա�HF�E�7���m#*�`�q��\\000\\000-���Ly������\\000\\000�;\\000,Y½pJ�w�9�+`Q���·r�\\000sp�\\000\\000`�\\000:���D�Ah���ڀ\\000�:\\000\\000�G�/\\000,½�M5�s_�u����Tz�X�X�vY��4�6�\\r 5r�^���w\\000��gw���ף\\000\\000p��\\000��=\\\\��z��F��{z���B���wD\\000<b�ik\\000\\000�@���F�	\\000ޭA����9�{o�J8�>�\\000H15�~>\\r��]�Y�68]��ܮp����4�\\000@o�р�}���(\\000�N�9W��l����@ph�\\000�\\000@Y\\000�6�K\\000e\\000P�j�j+��+��\\\
\\\"�h��\\000\\000G�\\000����ei�g%���[H�Y\\000J�uLs�^T�]@�O\\000O�\\000@�\\000\\000�k�a�R�g}�|�n#��H&�	\\000H)\\0000�#K@RU�$]A�7#\\000\\000;\\000�s[	\\000J�1�ݸ:�}s]X-��=��iK\\000�6 `��_c�����K�j��;$���Xŷ\\000f����0�l�g\\000���@\\000�\\000,��\\000�����YLC\\000J�1w]�}���C~�������\\000��ʰ�ˑR��Y�}@�\\000�_\\000�RZ\\000&��\\\"�_Ft�˯�\\\"�\\000~^2\\000\\000��	�4����iҶ\\r�@e�5^q�G�X���:���x���hI@R��-Eg�pv1P�\\000��Z���s���Kϲ�l�̑ff�eisǙni�\\0003�&�h��%3����8\\0000�_����\\000<�:G!A��Q�8��|[�嬞oo��$��q�Ԙ�o�`&Y���VX9W]\\000�?�'\\000�%$w���s`��ڶ^�6q,P��}��X�r^y=8�(TIP��\\000��!\\000\\000��?\\000 \\000~]\\000��D�H\\000��W_�ҥ���,����2 \\000X�����.ˢ`�R%\\000=\\000�.������\\000�5%��{\\000\\000\\000p���3\\000�:���2q����{o4�����g��(8+*ׇ��\\000\\000N|�\\000\\000`�\\000�,\\000��V�('��1R ۶G��\\\"��k*��;Ļ|.f��euF�/70���\\000��\\000�}%\\000`\\000��s���\\000�2��T���h�B?��l\\r\\r���J�֛��\\000�K��6��2\\000<�\\000�tP����y!v]���h����F\\0008�z��<ps7�Q��&�_\\000�\\r�\\000n\\\\耹\\rw�I�$��\\000\\000�\\000\",\
    [ \"sound/mino_Z.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000]a\\000\\000\\000\\000\\000\\000\\\"��vorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000]a\\000\\000\\000\\000\\00027�D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�������˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ���,۲m��\\\
�������m��ڶ��>[WuU\\000\\000��\\000@�	e�А�\\000@\\000\\000`c�Ah�r�9�R�9!sB�d�A���9���9���B���Z���Z+\\000\\000��\\000 �M��\\\
\\rY	\\000�\\000G�L�ue��EU�e�6�ŲDQUeٶ�cEU�e��u4QTUY�m�W�SUeٶ}]82UU�m[�}#U�m[ׅ��*˶m�QI�m]7��$۶���q,񅡰,��_8*�\\000\\000�\\000�VG8),4d%\\000�\\000\\000��QJ)��RJ)ƔR�	\\000\\000p\\000\\0000��\\\"\\000�\\000\\000�s�9�s�9�s�9�s�9�c�1�c�1�c�1�c�1�c�1�c�1�\\000�D8\\000�DX���\\000�\\000\\000���R)��9礔RJ)���A��RJ)�D�I)��RJ)�qPJ)��RJ)��RJ)��RJ	��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ\\000&\\000P	6ΰ�tV8\\\\h�J\\000 7\\000\\000P�9�$��JH%�J���I	)�VB\\\
��\\\
:h���RK���JI��B(��RZ)%�R2��PJ!�RJ	�ePB\\\
%��RI-�TJ� �PZ	���Z\\\
%��A)���R*���JJ���R)���JJ!��R���R)��Jk��NR)-��Rk��VJ)���JI���Zk)�VB)���Z)%��Rk-��ZK���Rk���J)%��Zk���Z*)��B)���Bj���J*-��RI��VZk)��J(%��Z*���Rh���JI%��J*)��R*��R*���Rk���J*-��R+���JJ�\\000\\000t�\\000\\000`D���iƕG��B�	(\\000\\000\\000���@�\\000\\\
d\\000�B�\\000PX`(]�\\\"HA\\\\8q�N��\\000���\\000�\\\"$d�E�t\\000���(]�\\\"HA\\\\8q�N��\\000\\000\\000\\000\\000\\000\\000\\000�\\\\��G��H�\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�OggS\\000]%\\000\\000\\000\\000\\000\\000]a\\000\\000\\000\\000\\000�`idBIPOVKZINO?O@AJA;AWV���O����A�b�-�-\\000�x�h�`3��<����O���F��IW\\r���F\\r������{	@��_���<�b�J����,���sU.j��\\000u<)��	\\000r��I���l�/\\000J\\000\\000.\\000\\000\\000���\\000���\\000�@���\\000��(`x��\\000t��W\\000�?�\\r\\000r��e�|*Փj�\\000XY@�-\\000\\000����\\000��\\000Hu�\\000h�\\000\\000\\\\9�z�\\000�\\000�@� ���$��B9\\000R����>��ڤN\\000�\\r�u�.����~���̚\\000f]�u�<�|��_e��;3���X\\000����ے ���M\\000��*\\000f���e��\\\\�G��K�\\000 HDU��6Y���x�H\\000�Ɠa�d�6��;\\000�9�����pu�8q�j�D<h;\\\\C��	\\000v���oL�\\000���\\000]<=�\\000{�����;0jk��X\\000\\000N��S�K�Ї���\\000(k|�\\r���Qwt�&����\\000^��\\000���/��.�Ԁ%Lݭ	cjݯ#�`2���\\\
\\000`_�]	��\\\"\\000kO���H_�+>6���Ey�����\\000R�V���4�����c����_����_���vNn&nFJ������yZ����\\\
�/��ۀS\\r%p\\\"���:Kb��F}�Aɰ�	 n�\\\"�&$'��\\000\\000n?\\\"\\000�U\\000\\000\\r��\\\
�\\000\\\"�8�@��%\\000�_�Q\\000\\000��h�H��Vc����ABԡ�\\000j�T��)�,x��;�\\000*\\000\\000��\\\
P��y����'H 6`�\\000xy�o�\\000�����+�:��_�\\\" �C��\\000V�^�P5H>@�2O��t@ Y����\\\"n_���\\000T����ў�\\000l�b`k0.�7\\\
ck��嚯A�ڪ�3ՠ*�[�Q����n�\\000춄�B*����&�a\\000L��:�X�x	�N0�e,�� zb��rB��\\000���0���Y)�Uu�5R�歯ߛ�4��\\000L_��8\\000䋩K���*�b�'�6��-\\r�\\\
�$ԭ�배z����\\000&�5���N\\000%����jd�h`{�p-����?�aE���a��e���\\\\���\\000&�5��{<@��`!�f@~�K*H��\\000�5`�\\000��4:9@[X'9�ǉC ��Q�u�rar\\000{}P�΀w{��٪uk�[vF���,�\\000Z���E��M.�h9NKxے����:Q���1�9_ӻ��\\000\\\"���/������S��eY�m�[K�K�:�_|\\\"l	\\000�*�W�Θ�q�\\\
�j(P�2}�[G�&�=�\\000V�P\\000�ު��Ѥ�H\\000PP\\000|�\\000�\\r�:4xƀ	�Á�A�)\\000y����\\\"�=��,������li;��T	<a<�\\000|`,�\\\
��M؁�\\r.!!_5�\\000[����M�\\000�R2��R�����|Y�[��@���G'b����u�q��y�����2p�8�\\r���������$6�B�U/���Ab\\\\\\000\",\
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
    [ \"ldris2.lua\" ] = \"local _AMOUNT_OF_GAMES = 2\\\
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
Last update: April 15th 2025\\\
\\\
Current features:\\\
+ SRS wall kicks! 180-spins!\\\
+ 7bag randomization!\\\
+ Modern-feeling controls!\\\
+ Garbage attack!\\\
+ Ghost piece!\\\
+ Piece holding!\\\
+ Sonic drop!\\\
+ Configurable SDF, DAS, ARR, ARE, lock delay, etc.!\\\
+ Animated piece queue!\\\
+ Included sound effects!\\\
\\\
To-do:\\\
+ Fix garbage collector-related slowdown when played in CraftOS-PC\\\
    (if related to string concatenation, then damn...)\\\
+ Refactor code to look prettier\\\
+ Find out why the minos don't instantly move up when board is almost full, and instead take one game frame to do so\\\
+ Add score, and let line clears and piece dropping add to it\\\
+ Implement initial hold and initial rotation\\\
+ Add an actual menu, and not the crap that LDRIS 1 had\\\
+ Implement proper Multiplayer (aiming for modem-only for now)\\\
+ Implement arcade features (proper kiosk mode, krist integration)\\\
+ Add touchscreen-friendly controls for CraftOS-PC Mobile\\\
+ Cheese race mode\\\
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
local cospc_debuglog = GameDebug.cospc_debuglog\\\
local clientConfig = require \\\"config.clientconfig\\\" -- client config can be changed however you please\\\
local gameConfig = require \\\"config.gameconfig\\\"     -- ideally, only clients with IDENTICAL game configs should face one another\\\
gameConfig.kickTables = require \\\"lib.kicktables\\\"\\\
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
				speaker.playLocalMusic(fs.combine(shell.dir(), \\\"sound/\\\" .. name .. \\\".ogg\\\"))\\\
		end\\\
end\\\
\\\
local function write_debug_stuff(game)\\\
	if game.control.native_control and _PRINT_DEBUG_INFO then\\\
		local mino = game.state.mino\\\
		\\\
		term.setCursorPos(14, scr_y - 2)\\\
		term.write(\\\"Combo: \\\" .. game.state.combo .. \\\"      \\\")\\\
\\\
		term.setCursorPos(2, scr_y - 1)\\\
		term.write(\\\"M=\\\" .. mino.movesLeft .. \\\", TtL=\\\" .. tostring(mino.lockTimer):sub(1, 4) .. \\\"      \\\")\\\
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
			(scr_y / 4) - ((game_size[2] - 5) / 2)\\\
		)\\\
	end\\\
end\\\
\\\
local function main()\\\
\\\
		cospc_debuglog(2, \\\"Starting game.\\\")\\\
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
					term.setCursorPos(17, 1)\\\
					term.write(\\\"evt=\\\" .. tostring(evt[1]) .. \\\"   \\\")\\\
					term.setCursorPos(28, 1)\\\
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
							term.write(\\\"ft=\\\" .. tostring(frame_time) .. \\\"ms   \\\")\\\
						end\\\
				end\\\
				\\\
				GameDebug.broadcast(GAMES)\\\
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
local success, err_message = pcall(main)\\\
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
    [ \"sound/lineclear.ogg\" ] = \"OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000�}\\000\\000\\000\\000\\000\\000�[�yvorbis\\000\\000\\000\\000\\\"V\\000\\000\\000\\000\\000\\000�]\\000\\000\\000\\000\\000\\000�OggS\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000�}\\000\\000\\000\\000\\000�}/�D�������������vorbis4\\000\\000\\000Xiph.Org libVorbis I 20200704 (Reducing Environment)\\000\\000\\000\\000vorbis\\\"BCV\\000\\000\\000� \\\
ƀАU\\000\\000\\000\\000B�F�P�����G�P���Pj� xJaɘ�kB�{Ͻ��{ 4d\\000\\000\\000@b�1	B��	Q�)Ba9	�r:	B� �.��r��\\rY\\000\\000\\0000!�B!�B\\\
)�R�)��b�1�s�1� �:褓N2����2ɨ��ZJ-�Sl��Xk�5��kP�c�1�c�1�c�1�BCV\\000 \\000\\000�AdB!�R�)�s�1ǀАU\\000\\000 \\000�\\000\\000\\000\\000G�ɑɑ$I�$K�$��,��,O5QSEUuU۵}ۗ}�wuٷ}�vuY�eYwm[�uW�u]�u]�u]�u]�u]�u 4d\\000 \\000�#9�#9�#9�#)����\\000d\\000\\000\\000�(��8�#9�cI��I��Y��i�&j����\\000\\000\\000\\000\\000\\000\\000\\000�(��(�#I��i�穞(�����i�����i��i��i��i��i��i��i��i��i��i��i�@h�*\\000@\\000@�q�Q�qɑ$	\\rY\\000�\\000\\000\\000�PG�˱$��,��4�3=W�M��U\\rY\\000\\000\\000\\000\\000\\000\\000\\000����O�$����$O�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4MӀАU\\000\\000\\000\\000 �B�1 4d\\000\\000\\000���1�)%��`!�1�!�<�Z:�RX2&=�����s��\\rY\\000\\000\\000F��xL�B(FqBg\\\
�BXN����N��=!�˹��{�BCV\\000�\\000\\000B!�B!��BJ)��b�)��r�1�s2� �:餓L*餣L2�(��RK1�[n1�Zk�9��2�c�1�c�1�c�1�АU\\000\\000\\000\\000a�A�BH!��b�)�s�1 4d\\000\\000\\000 \\000\\000\\000�Q$Er$Gr$I�,ɒ4ɳ<˳<��DM�TQU]�vm��e��]]�m_�]]�eY�]��e��u]�u]�u]�u]�u]�u\\rY\\000H\\000\\000�H��H��H��H��\\000�!�\\000\\000\\000\\000\\0008��8��H��X�%i�fy�gy������!�\\000\\000@\\000\\000\\000\\000\\000\\000\\000(��8��H�ei��y�'�����h�����i��i��i��i��i��i��i��i��i��i��i�&�\\\
\\000�\\000\\000�q�q�qGr$IBCV\\0002\\000\\000\\0000�Q$�r,I�4˳<M�L�eS7u�BCV\\000�\\000\\000\\000\\000\\000\\000\\000p<�s<Ǔ<ɳ<�s<ɓ4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4M�4 4d%\\000\\000\\000� Ǵ�$	�����Ĥ����:%��!��b�9ɘA��E�\\\"\\rY\\000D\\000\\000� �s�9'��9�tR���Rg��Zb�(��R�\\r��RH-�Tb-�v�J�%�\\000\\000\\000\\000,�BCV\\000Q\\000\\000�1H)�b�9�D�1�d�1!sNA��T*uPR�s�A���T:G��PRG�\\000\\000�\\000\\000�\\000�А@�\\000�A�4��4ϳ4��<QTUOU�=��LSU=�TUS5eWTMY�<�4=�TU�4UU4U�5M�u=U�e�UuYtU�vmٷ]YnOUe[T][7UW�UY�}W�m_EUU�u=Uu]�uu�t]]�TUvMוe�um�ue[WeY�5U�e�um�t]�veW�UY�m�u}]�e�7e��e[�}Y��at]�WeY�MY~ٖ���u_�DQU=U�]QU]�t][W]׶5Ք]�um�T]YVeY�]W�uMUeٔe�6]W�UY�uW�u[t]]7eY�UW�uW��c�m_]W�MY�}U�u_�ua�u��5U�}Sv}�te]�}�f]��u}_�m�Xe��u��[ׅ�s]_Wm�V�6����a�}�Xu�f[7��N~a8n�8��-tu[X^�6��O��ߨ�����k��,�����p��r|����,�*��o�r�O�\\\\�VY�Ֆ�a�uaمa�ں2��o��+����W��m˫��0�����o��3\\000\\0008\\000\\000�P\\\
\\rY\\000�	\\000X$��,�E˲DQ4EUEQU-M3MM�LS�<�4MSuE�T]K�LS�4��<�4M�tU�4eS4M�5U�vEU�eՕeYu]]MӕE�te�T]Yu]WV]W�%M3M��LS�<�4UӕMSu]��TS�D��DQUUSU]SUeW�<S�DO5=QTU�5e�TUY6UӖMS�e�Um�UeW�]ٶMU�eS5]�t]�v]�v]�vI�LS�<��<O5MSu]SU]��<��DQU5O4UUU]�4UW�<�T=QTUM�T�t]YVUSVEմeUUu�4UYveٶ]�ueSU]�T]Y6USv]W���*��iʲ���l���ʶm��궨��k��l�����k�,˶,��뚮*˦�ʶ,˺.˶���kۦ�ʺ+�tY�]��m�꺶�ʮ���l���n۾,��)ۦ�ʲ,��m˲/���ڦ�ڲ�������˲lۢiʲ���m��,˲l��,۶�ʺ�ڲ���,۲m��\\\
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
  },\
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
