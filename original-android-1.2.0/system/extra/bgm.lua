----------------------------------------
-- おまけ／BGM
----------------------------------------
-- 初期化
function exf.bginit()
	local file = getplaybgmfile()

	-- bgm停止
--	if init.extrabgm_openplay ~= "on" then
--		bgm_stop{}
--		sys.extr.play = 0
--	end

	if not appex.bgmd then appex.bgmd = {} end

	-- 曲名取得 / 番号順に並べる
	local z    = lang.bgmname or {}
	local tbl  = {}
	local flag = init.extrabgm_flag == "all" and 1
	local text = nil
	for nm, v in pairs(csv.extra_bgm) do
		local no = tn(v[1])
		if no and no > 0 then
			local fl = flag or gscr.bgm[nm]
			local tx = z[nm]
			local t1, t2
			if tx then text = true end
			if bgmctrl then
				t1 = v.ex01
				t2 = v.ex02
			end
			appex.bgmd[no] = { file=(nm), no=(no), text=(tx), flag=(fl), time1=(t1), time2=(t2) }
		end
	end
	appex.bgmd.text = text

	-- 開放確認
	appex.bgmd.open = {}
	local c  = 1
	for i, v in ipairs(appex.bgmd) do
		if v.flag then
			table.insert(appex.bgmd.open, v)
			appex.bgmd[i].count = c
			c = c + 1
		end
	end

	-- 現在のページ位置
	local p = appex.bgmd
	local max = appex.bgmd.pagemax or #p
	appex.bgmd.pg  = 0
	appex.bgmd.max = max	-- 曲数

	-- 曲名座標を読み込む
	local px = get_uipath().."extra/title.ipt"
	if p.p1 == "ipt" and isFile(px) then
		e:include(px)
		appex.bgmd.ipt  = tcopy(ipt)
	end

	-- noを再生中の曲に合わせる
	local file = getplaybgmfile()
	local no = max
	for i, v in ipairs(p) do
		if file == v.file then
			no = i
			appex.bgmd.play = scr.bgm.file and true
			break
		end
	end
	appex.bgmd.no = no
	appex.bgmd.play = scr.bgm.file and true

	-- title処理
	exf.musicpage()
	exf.musictitle()
end
----------------------------------------
-- reset
function exf.bgmreset()
	if appex.bgmd.fadeout then appex.bgmd.play = nil end	-- fadeout中は再生フラグを倒す
--	flg.callfunc = nil			-- 関数呼び出し無効化
--	flg.timercount = nil		-- 秒表示無効化

	-- bgm ctrl
	if bgmctrl then bgmctrl.stop() end

	-- text消去
	if appex.bgmd.text then
		local p, page, char = exf.getTable()
		local v = p.p
		local m = v.max
		for i=1, m do
			local nm = "bgm"..string.format("%02d", i)
			ui_message(getBtnID(nm)..".20")
		end
	else
		ui_message('500.tx.20')
		ui_message('500.tx.21')
	end
end
----------------------------------------
-- ページ切り替え
function exf.bgpage()
	exf.bgmreset()		-- text消去
	exf.musicpage()		-- 再描画
end
----------------------------------------
-- 現在のページ
function exf.musicpage()
	local p, page, char = exf.getTable()
	local v  = p.p
	local m  = v.max
	local fl = appex.bgmd.text
	local pg = 0
	if fl then
		local s = appex[appex.name].slider
		pg = (s.no or 0) * s.w
	end

	-- loop
	local cl = init.extrabgm_btnlock	-- 未開放時の動作
	for i=1, m do
		local t  = v[i]
		local nm = "bgm"..string.format("%02d", i)
		setBtnStat(nm, nil)

		-- text
		if fl then
			t = v[pg + i]
			local id = getBtnID(nm)..".20"
			local tx = t.flag and t.text or ""
			ui_message(id, { "exbgm", text=(tx) })
		end

		-- 未開放処理
		if not t.flag then
			-- ボタンを非表示
			if cl == "hide" then
				setBtnStat(nm, 'c')
				tag{"lyprop", id=(getBtnID(nm)), visible="0"}

			-- clip変更
			elseif cl then
				setBtnStat(nm, cl)
			end
		end
	end

	-- play / title
	exf.musictitle()
	user_configslider(getBtnInfo("volume"), true)
end
----------------------------------------
-- 再生停止
function exf.musicreset()
	local p  = appex.bgmd
	local no = p.no
	if no and p[no] and p[no].flag then
		local nm = "bgm"..string.format("%02d", no)
		setBtnStat(nm, nil)
	end
	exf.bgmreset()
end
----------------------------------------
-- playボタン / 曲名表示
function exf.musictitle(over)
	local fl = getplaybgmfile()
	local no = appex.bgmd.no

	-- ボタン表示
	if fl then
		local pl = init.extrabgm_btnplay	-- 再生時の動作
		local bt = string.format("bgm%02d", no)
		if not pl then
			setBtnStat(bt, 'c')
		else
			btn_clip(bt, 'c')
		end
	end

	-- playボタン表示
	if checkBtnExist("bt_play") then
		local fx = fl and 'c'
		setBtnStat("bt_play", fx)
--[[
		local v  = getBtnInfo("bt_play")
		local cl = over and (fl and "clip_d" or "clip_a") or (fl and "clip_c" or "clip")
		tag{"lyprop", id=(v.idx..".0"), clip=(v[cl])}
]]
	end

	-- stopボタン表示
	if checkBtnExist("bt_stop") then
		local fx = not fl and 'c'
		setBtnStat("bt_stop", fx)
	end

	-- 曲名表示
	if checkBtnExist("title") then
		local v  = getBtnInfo("title")
		local id = v.idx
		if fl and no then
			local n1 = math.floor((no-1) / 10)
			local n2 = ((no-1) % 10)
			local cl = (v.cx + n1 * v.cw)..","..(v.cy + n2 * v.ch)..","..v.cw..","..v.ch
			tag{"lyprop", id=(id..".0"), clip=(cl)}
			tag{"lyprop", id=(id), visible="1"}
		else
			tag{"lyprop", id=(id), visible="0"}
		end
	end
end
----------------------------------------
function exf.playover() exf.musictitle(true) end	-- playボタンover
function exf.playout()  exf.musictitle() end		-- playボタンout
----------------------------------------
-- bgmボタンover / out
function exf.bgmoverout(bt, cl)
	local fl = getplaybgmfile()
	local pl = init.extrabgm_btnplay	-- 再生時の動作
	if fl and pl then
		local v  = getBtnInfo(bt)
		local p2 = tn(v.p2)
		local no = appex.bgmd.pg + p2
		local nw = appex.bgmd.no
		if no == nw then
			btn_clip(bt, cl)
		end
	end
end
----------------------------------------
function exf.bgmover(e, p) exf.bgmoverout(p.name, 'd') end
function exf.bgmout(e, p)  exf.bgmoverout(p.name, 'c') end
----------------------------------------
-- 
----------------------------------------
-- volume
function music_volume(e, p)
	local c = conf.bgm
	local s = sys.extr.vol
	if c ~= s then
		conf.bgm = s
		volume_master()
	end
end
----------------------------------------
-- 
----------------------------------------
-- bgmクリック
function exf.clickbgm(bt, num)
	local p  = appex.bgmd
	local s  = p.slider
	local no = num
	if s then
		no = (s.no or 0) * s.w + num
	else
		local max = p.max
		local pg  = p.pg
		no  = pg + num
		if no > max then no = max end
	end

	-- play
	if p[no].flag then
		se_ok()
		appex.bgmd.no = no
		exf.bgmplay(p[no].file)
		exf.bgpage()			-- 再描画
		exf.bgmoverout(bt, 'd')	-- active
		flip()
	end
end
----------------------------------------
-- bgmボタン制御
function exf.clickbgmbtn(nm)
	local sw = {
		play = function() se_ok() exf.bgmplaystop(true) end,	-- playボタン
		stop = function() se_ok() exf.bgmstop(true) end,		-- stopボタン
		back = function() se_ok() exf.bgmadd(-1) end,			-- backボタン
		next = function() se_ok() exf.bgmadd( 1) end,			-- nextボタン
	}
	if sw[nm] then sw[nm]() end
end
----------------------------------------
-- 次の曲へ
function exf.bgmadd(add)
	local p = appex.bgmd
	local v = p.open
	local max = #v
	local num = p.no
	if not p[num].count then return end
	exf.musicreset()

	-- add
	local ct = p[num].count
	ct = ct + add
	if ct > max then ct = 1 elseif ct < 1 then ct = max end 

	-- Shuffle
	if bgmctrl then ct = bgmctrl.shuffle(ct, num) end

	local no = v[ct].no
	appex.bgmd.no = no		-- 曲番号

	-- play
	local file = p[no].file
	exf.bgmplay(file)
	exf.musictitle()
	flip()
end
----------------------------------------
-- 再生ボタン
function exf.bgmplaystop(flag)
	local fl = getplaybgmfile()
	local v  = flag and getBtnInfo("bt_play")
	if fl then
		bgm_stop{}
		exf.musicreset()
		appex.bgmd.play = nil
		exf.musictitle()

--		if flag then tag{"lyprop", id=(v.idx..".0"), clip=(v.clip_a)} end
		flip()
	else
		local p  = appex.bgmd
		local no = p.no
		if appex.bgmd.text then
			local s = appex[appex.name].slider
			no = (s.no or 0) * s.w + no		
		end

		if p[no].flag then
			exf.bgmplay(p[no].file)
			exf.musictitle()

--			if flag then tag{"lyprop", id=(v.idx..".0"), clip=(v.clip_d)} end
			flip()
		end
	end
end
----------------------------------------
-- 
----------------------------------------
-- 再生
function exf.bgmplay(name)
	local fl = getplaybgmfile()
	local pl = init.extrabgm_btnplay	-- 再生時の動作

	-- 停止
	if pl == "stop" and fl == name then
		exf.bgmstop()

	-- 再生
	else
		appex.bgmd.play = true
		bgm_play{ file=(name) }
		if bgmctrl then bgmctrl.play() end
	end
end
----------------------------------------
-- 停止ボタン
function exf.bgmstop()
	local fl = getplaybgmfile()
	if fl then
		bgm_stop{}
		if bgmctrl then bgmctrl.stop() end
		appex.bgmd.play = nil
		exf.musicreset()
		exf.musictitle()
		flip()
	end
end
----------------------------------------
-- bgm再開
function exf.bgmrestart()
	local p = appex.bgmd
	if p.play then
		exf.bgmplay(p[p.no].file)
	end
end
----------------------------------------
