----------------------------------------
-- 多言語
----------------------------------------
local ex = {}
----------------------------------------
ex.langtable = {
	sub   = { conf="sub_lang",	 def="game_sublang", none=true },
	ui    = { conf="ui_lang",	 def="game_uilang",  none=true },
	voice = { conf="voice_lang", def="game_voicelang" },
	sysvo = { conf="sysvo_lang", def="game_sysvolang" },
	lvo   = { conf="lvo_lang",	 def="game_lvolang" },
}
----------------------------------------
-- lang初期化
function lang_confreset(def)
	set_language("main", def or get_language("def"))
	for nm, v in pairs(ex.langtable) do
		local ax = init[v.def]
		if ax then set_language(nm, ax) end
	end
end
----------------------------------------
-- 多言語書き込み
function set_language(md, ln)
	local z  = ex.langtable

	-- 主言語
	if md == "main" then
		conf.language = ln

	-- その他
	elseif z[md] then
		if z[md].none and ln == "none" then ln = nil end		-- noneの場合は消去

		local nm = z[md].conf
		conf[nm] = ln

	else
		message("警告", md, "は不明な言語指定です")
	end

	-- uipath書き換え
	set_uipath()
end
----------------------------------------
-- 言語取得
function get_language(md)
	local df = init.steam == "on" and init.steam_language or init.game_language or "ja"
	local r  = conf and conf.language or df
	local z  = ex.langtable
	if debug_flag and deb.lang then r = deb.lang end		-- debug / 言語切替

	-- main
	if not md then

	-- 初期値
	elseif md == "def" then
		r = df
		if debug_flag and deb.lang then r = deb.lang end	-- debug / 言語切替

	-- tableから読み出す
	elseif z[md] then
		local nm = z[md].conf
		r = nm and conf[nm] or r
	end
	return r
end
----------------------------------------
-- 
----------------------------------------
function lang_ja() adv_putlang("ja") end	-- 日本語
function lang_en() adv_putlang("en") end	-- 英語
function lang_cn() adv_putlang("cn") end	-- 簡体字
function lang_tw() adv_putlang("tw") end	-- 繁体字
----------------------------------------
-- 言語変更 / キー選択
function adv_putlang(nm)
	local flag = init.game_sublangview == "on" and flg.alt
	adv_setlang(nm, flag)
end
----------------------------------------
-- 言語変更 / 書き換え
function adv_setlang(nm, flag)
	local ln = get_language()		-- 主言語
	local sb = get_language("sub")	-- 副言語
	local r  = flag and sb or ln	-- flagが立っていたら副言語書き換え
	local v  = init.lang

	-- 入れ替え
	if nm ~= r and v[nm] then
		se_ok()

		-- 主言語
		if not flag then
			message("通知", "主言語", r, "→", nm)
			set_language("main", nm)
			if nm == sb then set_language("sub", r) end

		-- 副言語
		else
			message("通知", "副言語", r, "→", nm)
			set_language("sub" , nm)
			if nm == ln then set_language("main", r) end
		end
		lang_redraw()				-- 再描画
		asyssave()

	-- 副言語非表示
	elseif flag and nm == sb then
		message("通知", "副言語非表示")
		set_language("sub" , nil)
		lang_redraw()				-- 再描画
		asyssave()
	end
end
----------------------------------------
-- 言語入れ替え
function lang_change()
--[[
	local ln = get_language()		-- 主言語
	local sb = get_language("sub")	-- 副言語
	local fl = init.game_sublangview == "on"
	if fl and sb and ln~= sb then
		se_ok()
		set_language("main", sb)
		set_language("sub" , ln)
		lang_redraw()				-- 再描画
	end
]]

	-- 次の番号にトグル
	set_langnum()
	local num = conf.langnum + 1
	-- if num > #init.langnum then
	if num > 3 then -- 日本語・英語・簡体字の３つのみ
		num = 1
	end

	se_ok()
	set_language("main", init.langnum[num])
	lang_redraw()
	
	asyssave()
end
----------------------------------------
-- 再描画
function lang_redraw()
	local tl = getTitle()
	if tl then title_cachedelete() end	-- title cache delete
	system_cachedelete()				-- system cache delete

	-- font読み直し
	font_init()

	-- ボタン設置
	init_advmw(true)

	----------------------------------------
	local fl = true

	-- 選択肢
	if scr.select then
		estag("init")
		estag{"select_resetimage"}		-- 一旦消す
		estag{"select_view"}			-- 再描画
		estag{"select_event", true}		-- lyevent割り当て
		estag()
		fl = nil

	-- line
	elseif scr.line then
		local bl = scr.ip.block
		local v  = ast[bl].text
		if v.linemode then
			msgcheck("sys")			-- msg sys
			fl = nil
		end
		mwline_textredraw()			-- 再描画
	end

	-- 本編
	if fl then
		adv_cls4(true)
		mw_redraw(true)
		flip()
	end
	
	reloadSystemData()					-- システム再読み込み
	if tl then title_cache() end		-- title cache読み直し
end
----------------------------------------
