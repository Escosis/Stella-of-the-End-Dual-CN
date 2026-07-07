----------------------------------------
-- config拡張
----------------------------------------
local ex = {}
----------------------------------------
ex.resettable = { "master", "bgm", "bgmvo", "voice", "se", "sysse", "movie" }
----------------------------------------
-- 
function user_config(pg)
	if game.os == "windows" then
		if pg == 1 then
			user_configslider(getBtnInfo("aspeed"))
			user_configslider(getBtnInfo("mspeed"))
			user_configslider(getBtnInfo("mw_alpha"))

		elseif pg == 2 then
			user_configslider(getBtnInfo("master"))
			user_configslider(getBtnInfo("bgm"))
			user_configslider(getBtnInfo("bgmvo"))
			user_configslider(getBtnInfo("voice"))
			user_configslider(getBtnInfo("se"))
			user_configslider(getBtnInfo("sysse"))
			user_configslider(getBtnInfo("movie"))
			user_configslider(getBtnInfo("vo01"))
			user_configslider(getBtnInfo("vo02"))
			user_configslider(getBtnInfo("vo03"))
			user_configslider(getBtnInfo("vo04"))
			user_configslider(getBtnInfo("vo05"))
			user_configslider(getBtnInfo("vo06"))
			user_configslider(getBtnInfo("vo07"))
			user_confchar()
		end
	else
		if pg == 1 then

		elseif pg == 2 then
			user_configslider(getBtnInfo("aspeed"))
			user_configslider(getBtnInfo("mspeed"))
			user_configslider(getBtnInfo("mw_alpha"))

		elseif pg == 3 then
			user_configslider(getBtnInfo("master"))
			user_configslider(getBtnInfo("bgm"))
			user_configslider(getBtnInfo("bgmvo"))
			user_configslider(getBtnInfo("voice"))
			user_configslider(getBtnInfo("se"))
			user_configslider(getBtnInfo("sysse"))
			user_configslider(getBtnInfo("movie"))

			if game.os == "ios" then
				tag{"lyprop", id=(getBtnID("movie")), visible="0"}
				tag{"lyprop", id=(getBtnID("fl_movie")), visible="0"}
			end

		elseif pg == 4 then
			user_configslider(getBtnInfo("vo01"))
			user_configslider(getBtnInfo("vo02"))
			user_configslider(getBtnInfo("vo03"))
			user_configslider(getBtnInfo("vo04"))
			user_configslider(getBtnInfo("vo05"))
			user_configslider(getBtnInfo("vo06"))
			user_configslider(getBtnInfo("vo07"))
			user_confchar()

		end
	end
end
----------------------------------------
-- config slider装飾
function user_configslider(v, flag)
	local id = v.idx
	local ix = id..".3"
	local no = flag and conf.bgm or conf[v.def]
	if no == 0 then
		lydel2(ix)
	else
		local p2 = v.p2
		local w  = repercent(no, v.w - p2) + p2 / 2
		local cl = v.cx..","..(v.cy + v.ch*2)..","..w..","..v.h
		lyc2{ id=(ix), file=(":ui/"..v.file), clip=(cl) }
	end
end
----------------------------------------
function user_confsliderdrag(e, p)
	local fl = nil
	local bt = p.name
	local v  = getBtnInfo(bt)
	local sw = {
		aspeed = function()	conf.aspeed = 100 - conf.r_aspeed end,
		mspeed = function()	conf.mspeed = 100 - conf.r_mspeed end,
		mw_alpha = function()	conf_mwsample() end,

		master = function()	config_volume(e, p) end,
		bgm = function()	config_volume(e, p) end,
		bgmvo = function()	config_volume(e, p) end,
		voice = function()	config_volume(e, p) end,
		se = function()	 	config_volume(e, p) end,
		sysse = function()	config_volume(e, p) end,
		movie = function()	config_volume(e, p) end,
		vo01 = function()	config_volume(e, p) end,
		vo02 = function()	config_volume(e, p) end,
		vo03 = function()	config_volume(e, p) end,
		vo04 = function()	config_volume(e, p) end,
		vo05 = function()	config_volume(e, p) end,
		vo06 = function()	config_volume(e, p) end,
		vo07 = function()	config_volume(e, p) end,

		volume = function()	music_volume(e, p) fl = true end,
	}
	if sw[bt] then sw[bt]() end
	user_configslider(v, fl)
end
----------------------------------------
-- キャラ解放
function user_confchar()
	local no = tn(get_eval("g.cfg_chr"))
	if no < 1 then tag{"lyprop", id="500.c.3", visible="0"} end		-- ウィレム
	if no < 3 then tag{"lyprop", id="500.c.4", visible="0"} end		-- デリラ
	if no < 2 then tag{"lyprop", id="500.c.5", visible="0"} end		-- ガブリエル

	-- mob
	if no < 2 then
		local v1 = getBtnInfo("char05")
		local v2 = getBtnInfo("char06")
		tag{"lyprop", id="500.d", left=(v1.x - v2.x)}
	end

	-- hit
	tag{"lyprop", id=(getBtnID("char01")..".0"), clickablethreshold="255"}
	tag{"lyprop", id=(getBtnID("char02")..".0"), clickablethreshold="255"}
	tag{"lyprop", id=(getBtnID("char03")..".0"), clickablethreshold="255"}
	tag{"lyprop", id=(getBtnID("char04")..".0"), clickablethreshold="255"}
	tag{"lyprop", id=(getBtnID("char05")..".0"), clickablethreshold="255"}
	tag{"lyprop", id=(getBtnID("char06")..".0"), clickablethreshold="255"}
	tag{"lyprop", id=(getBtnID("char07")..".0"), clickablethreshold="255"}
end
----------------------------------------
-- reset
function user_confreset(e, p)
	local v  = getBtnInfo(p.btn)
	local nm = v.p1

	-- char
	if nm == "char" then
		confdef_voice()

	-- volume
	elseif nm == "vols" then
		for i, md in ipairs(ex.resettable) do
			conf_defsave(md)
		end

	-- slider
	elseif conf[nm] then
		conf_defsave(nm)
	end

	----------------------------------------
	set_volume()		-- ボリュームを設定する
	set_message_speed()	-- メッセージ速度を設定する
	mw_alpha()			-- MW不透明度を設定
	----------------------------------------
	se_ok()
	config_page(gscr.conf.page)		-- 再表示
	flip()
end
----------------------------------------
-- sub menu
----------------------------------------
-- 拡張click
function user_confsubopen(e, p)
	local v  = getBtnInfo(p.btn)
	local nm = v.p1
	if nm and lang[nm] then
		se_ok()
		sliderdrag_stat(0)	-- ドラッグ禁止
		csvbtn3("csub", "510", lang[nm])
		uiopenanime("conf")
	else
		message("警告", nm, "が作成されていません")
	end
end
----------------------------------------
-- 拡張click
function user_confsubclose(e, p)
	se_cancel()
	sliderdrag_stat(1)		-- ドラッグ許可
	delbtn('csub')
	config_page(gscr.conf.page)
	uiopenanime("conf")
end
----------------------------------------
