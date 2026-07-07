----------------------------------------
-- config / UI以外の固定動作
----------------------------------------
-- message
----------------------------------------
function getMSpeed()
	local ms = 100 - conf.mspeed
	if flg.fastauto then			ms = getFastautoTime(ms)
	elseif conf.fl_mspeed == 0 then ms = 0 end
	return ms
end
----------------------------------------
function getASpeed()
	local sp = init.automode_speed	-- 基本待機時間
	local mg = init.automode_magni	-- 基本倍率
	if type(sp) == "table" then
		mg = sp[2] or mg
		sp = sp[1]
	end
	local as = (100 - conf.aspeed) * mg + sp
	if conf.fl_aspeed == 0 then as = init.autooff_speed end
	if flg.fastauto then as = 0 end
	return as
end
----------------------------------------
-- メッセージ速度を設定する
function set_message_speed()
	local ms = getMSpeed()

	if game and game.mwid then
		-- adv text
		tag{"chgmsg", id=(mw_getmsgid("adv")), layered="1"}
		set_message_speed_tween(ms)
		tag{"/chgmsg"}

		-- adv text / sub language
		if init.game_sublangview == "on" then
			tag{"chgmsg", id=(mw_getmsgid("sub")), layered="1"}
			set_message_speed_tween(ms)
			tag{"/chgmsg"}
		end
	end

	-- オート速度を設定する
	e:tag{"var", name="s.automodewait", data=(getASpeed())}
end
----------------------------------------
function set_message_speed_tween(delay, time, diff)
	local tm = time or init.game_messagetime
	local df = diff or init.game_messagedown
	e:tag{"scetween", mode="init", type="in"}
	e:tag{"scetween", mode="add" , type="in", param="alpha", ease="none", time=(tm), delay=(delay), diff="-255"}
	if df and conf.mspeed < 100 and conf.fl_mspeed == 1 then
	e:tag{"scetween", mode="add" , type="in", param="top",   ease="none", time=(tm), delay=(delay), diff=(df), ease="easeout_quad"}
	end
end
----------------------------------------
-- 音量計算
----------------------------------------
-- ボリュームを設定する
function set_volume()
	volume_master()
	volume_bgm()
	volume_movie()
end
----------------------------------------
-- マスター音量を計算する
function volume_master()
	volume_bgm()
	volume_movie()

	-- SE Master
	local ans = volume_count("master", conf.master, init.config_volumemax)
	e:tag{"var", name="s.sevol", data=(ans)}
end
----------------------------------------
-- BGMの音量を計算する
function volume_bgm()
	local ans = volume_count("bgm", conf.master, conf.bgm, init.config_bgmmax)
	e:tag{"var", name="s.bgmvol", data=(ans)}
end
----------------------------------------
-- movieの音量を設定する
function volume_movie()
	local ans = volume_count("movie", conf.master, (conf.movie or conf.bgm), (init.config_moviemax or init.config_bgmmax))
	e:tag{"var", name="s.videovol", data=(ans)}
end
----------------------------------------
-- volume計算
function volume_count(name, ...)
	local r = 1000
	local c = conf.fl_master == 0 and 0 or conf["fl_"..name]
	if c and c == 0 then
		r = 0
	else
		local t = { ... }
		local m = #t
		local c = 100
		for i, v in ipairs(t) do
			if i == 1 then	r = t[i]
			else			r = r * t[i] / 100 end
		end
		r = math.ceil(r * 10)
		if r > 1000 then r = 1000 end
	end
	return r
end
----------------------------------------
-- volume slider
function config_volume(e, p)
	local tbl = { master="volume_master", bgm="volume_bgm", movie="volume_movie" }

	-- 呼び出し
	local func = function(nm)
		-- artemis変数を書き換える
		if tbl[nm] then
			_G[tbl[nm]]()

		-- sefadeで処理
		else
			sesys_voslider(nm)
		end
	end

	-- ボタン判定
	local bt = p.name
	if bt then
		local v  = getBtnInfo(bt)
		local nm = v.def
		local nx = nm:gsub("fl_", "")

		-- main
		func(nx)

		-- sub
		local s = init["confvol_"..nx]
		local n = conf[nm]
		local f = nm:find("fl_")
		if s then
			if type(s) == "string" then s = { s } end
			for i, z in ipairs(s) do
				if f then conf["fl_"..z] = n
				else	  conf[z] = n end
				func(z)
			end
		end

		-- no
		config_volumeno(bt)
	end
end
----------------------------------------
-- volume num
function config_volumeno(bt)
	local v  = getBtnInfo(bt)
	local p3 = v.p3
	if p3 then
		local nm = v.def:gsub("fl_", "")
		local no = conf[nm]
		if conf["fl_"..nm] == 0 then no = nm == "nis" and "off" or init.conf_mutetext or "off" end

		local ax = explode("|", p3)
		local x  = v.x
		local y  = v.y
		if ax[3] then
			local z = getBtnInfo(ax[3])
			x = z.x
			y = z.y
		end
		local id = "500.z."..ax[2]
		ui_message(id, { ax[1], text=(no) })
		tag{"lyprop", id=(id), left=(x), top=(y)}
	end
end
----------------------------------------
function config_volumenoloop()
	local nm = btn.name
	if nm and btn[nm] then
		for i, v in pairs(btn[nm].p) do
			if v.com == "xslider" then
				config_volumeno(i)
			end
		end
	end
end
----------------------------------------
function config_volumeupdate(bt, tx)
	local v  = getBtnInfo(bt)
	local p3 = v.p3
	if p3 then
		local ax = explode("|", p3)
		local id = "500.z."..ax[2]
		ui_message(id, tx)
	end
end
----------------------------------------
-- dialog
----------------------------------------
-- dialog on/off切り替え
function config_dialogset(e, p)
	local no = conf.dlg_all
	config_dialogreset(no)
	sys.dlgreset = nil
end
----------------------------------------
-- dialogを出すかどうか確認するテーブル
function config_dialogreset(no, flag)
	local t = init.dlg
	local b = {}
	for k, v in pairs(t) do
		local nm = v.name
		local md = v.mode
		if not b[nm] and (md == "reset" or not flag and md == "yesno") then
			local df = v.def
			local dt = df == 0 and no or df
			conf[nm] = dt
			b[nm] = true
--			message(nm, dt)
		end
	end
end
----------------------------------------
-- confからdialogパラメータを取得
function get_dlgparam(name)
	local r = nil
	local t = init.dlg[name]
	if init.game_exdialog ~= "on" and name:find("ex[0-9]+") then
--		message(name, "はon/off設定がありません")
	elseif conf.dlg_all == 1 then
		r = 1
	elseif t then
		r = conf[t.name]
	end
	return r
end
----------------------------------------
-- confにdialogパラメータを書き込む
function set_dlgparam(name, no)
	local t = init.dlg[name]
	if t then conf[t.name] = tn(no) end
end
----------------------------------------
-- exdef
----------------------------------------
-- 拡張初期化
function config_exdefault(page)
	local nm = "ui_config"..page
	local sx = {}
	for k, v in pairs(lang[nm]) do
		if type(k) == "string" then
			local cm = v.def
			if cm and not sx[cm] then
				sx[cm] = true
				conf_defsave(cm)	-- 実行
			end
		end
	end
end
----------------------------------------
-- dialogから呼ばれる
function config_pgdefview()
	local p = gscr.conf.page or 1

	-- reset
	config_exdefault(p)

	----------------------------------------
	confdef_cache()				-- image cache
	confdef_windows()			-- system windows
	if _G.user_conf		 then _G.user_conf() end			-- 拡張
	if _G.user_pagereset then _G.user_pagereset(p) end		-- exreset / user側で調整が必要な場合に使用する
	set_volume()				-- ボリュームを設定する
	set_message_speed()			-- メッセージ速度を設定する

	-- 再表示
	se_default()				-- ここでseを鳴らす
	set_langnum()				-- lang番号変換
	setWindowsScreenSize()		-- windows size
	config_page(p)				-- 描画
	flip()
	btn.renew = true
end
----------------------------------------
-- 初期化
----------------------------------------
-- 格納
function conf_defsave(md)
	local v  = csv.conf[md] or {}
	local vo = csv.voice or {}
	local nm = v[1]
	local nx = v[2]
	local mi = v[3]
	local mx = v[4]
	local f3 = md:sub(1, 3)
	local f4 = md:sub(1, 4)
	if f3 == "fl_" and md ~= "fl_nis" or nx == "none" then

	----------------------------------------
	-- 最小値 / 最大値
	elseif mi and mi > tn(nx) then message("警告", nm, nx, "は最小値以下に設定されています")
	elseif mx and mx < tn(nx) then message("警告", nm, nx, "は最大値以上に設定されています")

	----------------------------------------
	-- voice
	elseif vo[md] then
		conf[md] = 100
		conf["fl_"..md] = 1
		if init.game_bgvvolume == "on" then
			conf["lvo"..md] = csv.conf.lvo		-- bgv音量を個別に持つ
			conf["fl_lvo"..md] = 1
		end

	-- dlg
	elseif f4 == "dlg_" then
		local nn = md:sub(5)
		local z  = init.dlg[nn]
		if z then
			conf[md] = z.def or 0
		else
			message("警告", md, "は不明なconfigパラメータ(dialog)です")
		end

	elseif f4 == "svo_" then
		local z  = csv.sysse.sysvo.charlist
		local ch = md:sub(5)
		for i, v in ipairs(z) do
			if v == ch then
				conf[md] = 1
				ch = nil
				break
			end
		end
		if ch then
			message("警告", ch, "は不明なキャラです(sysvo)", md)
		end

	elseif not nm then
		message("警告", md, "は不明なconfigパラメータです")

	----------------------------------------
	-- 固定値
	elseif nm == "set" then
		conf[md] = nx

	-- slider
	elseif nm == "slider" then
		conf[md] = nx
		conf["fl_"..md] = 1

	-- tablet
	elseif nm == "tablet" then
		if osx == "windows" then	 conf[md] = tn(e:var("s.windowstouch"))		-- Windows
		elseif game.sp then			 conf[md] = 1				-- スマホ設定
--		elseif osx == "switch"  then conf[md] = 1				-- Switch
		else						 conf[md] = nx end			-- その他

	-- init参照
	else
		conf[md] = init[nm] or init[nx] or nx
	end
end
----------------------------------------
function config_default(flag)
	local ln = get_language()

	message("通知", "設定を初期化しました")

	----------------------------------------
	-- バッファクリア
	local osx = game.os
	local def = conf and conf.dlg_reset
	local dck = sys  and sys.dlgreset
	conf = {}
	config_dialogreset(nil, flag)
	conf.keys = {}		-- keyconfig [key] = name
	if def and dck then conf.dlg_reset = def end

	----------------------------------------
	-- 初期化
	for md, v in pairs(csv.conf) do
		conf_defsave(md)
	end

	----------------------------------------
	-- 
	confdef_voice()		-- sound voice
	confdef_sysvo()		-- sound system voice
	confdef_secat()		-- sound secat
	confdef_cache()		-- image cache
	confdef_windows()	-- system windows

	----------------------------------------
	-- 言語
	lang_confreset(ln)

	----------------------------------------
	-- 拡張
	if _G.user_conf then _G.user_conf() end

	----------------------------------------
	-- debug設定があれば上書きする
	if debug_flag then debug_configinit() end

	----------------------------------------
	set_volume()		-- ボリュームを設定する
	set_message_speed()	-- メッセージ速度を設定する
end
----------------------------------------
-- 各キャラボイスのon/offはvoice_tableから取得する	0:off 1:on
function confdef_voice()
	local lvo = init.game_bgvvolume == "on"
	for nm, v in pairs(csv.voice) do
		if v.id and not v.mob then
			conf[nm] = 100
			conf["fl_"..nm] = 1
			if lvo then
				conf["lvo"..nm] = init.config_bgv	-- bgv音量を個別に持つ
				conf["fl_lvo"..nm] = 1
			end
		end
	end
end
----------------------------------------
-- system voice
function confdef_sysvo()
	local z = csv.sysse.sysvo.charlist
	if z then
		for i, v in ipairs(z) do conf["svo_"..v] = 1 end
	end
end
----------------------------------------
-- secat
function confdef_secat()
	local z = init.secat
	if z then
		for nm, v in pairs(z) do
			local vo = v.vol or 100
			conf[nm] = vo
			conf["fl_"..nm] = 1
		end
	end
end
----------------------------------------
-- cache / smartphoneのみ初期値0
function confdef_cache()
	local w = getWindowSizeModule()
	local r = w and init.system.autocache_x64 or init.system.autocache			-- cache mode : none/small/middle/large
	local m = w and init.system.cachemax_x64  or init.system.cachemax or 500
	local c = game.sp == 0 and 0 or 1
	conf.cache		= c			-- 0:off 1:on
	conf.cachemode	= r			-- none/small/middle/large
	conf.cachelevel = 100		-- 0～100%
	conf.cachemax	= m			-- cacheファイル数最大値
end
----------------------------------------
-- キーショートカット(キー番号管理)
function confdef_keys()
	for i=1, init.max_keyno do
		local k = init["config_key"..i]
		if k then conf.keys[i] = k end
	end
end
----------------------------------------
-- windowsかつフルサイズのときは上書き
function confdef_windows()
	local s = get_artemis("fullscreen")
	if osx == "windows" and s == 1 then
		conf.window = 1
	end
end
----------------------------------------
