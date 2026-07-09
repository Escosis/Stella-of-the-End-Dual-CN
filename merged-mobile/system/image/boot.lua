----------------------------------------
-- 起動設定
----------------------------------------
local ex = {}
ex.windowsfontmax	= 200	-- Windows font検索数
--ex.fontdeconame		= { adv=1, name=1, sub=1, config=1, novel=1, full=1 }	-- 装飾するfont
ex.fontmodetable	= { normal=0, novel=90, full=80 }						-- mw bg番号
----------------------------------------
ex.debugfile		= "debug/dscreen.ini"
----------------------------------------
-- ■ ブランドロゴ
----------------------------------------
function brand_logo()
	-- script読み出し＆初期化
	callscript("system", init.brand_script)

	-- adv_init()が走るのでmwを消しておく
	tag{"lydel", id=(init.mwid)}
	flip()
end
----------------------------------------
function brandlogo(p)
	local v    = flg.logo or {}
	local file = p.file
	local mode = p.mode
	local time = p.time or v.time or 1000
	local wait = p.wait or v.wait or 2500
	local path = get_uipath()
	local id = 10
	local tr = { sys=2, time=(time) }

	----------------------------------------
	-- 初期化
	if mode and mode ~= "end" then
		message("通知", "ブランドロゴを表示します")
		if not flg then flg = {} end
		flg.logo = {}
		flg.logo.file  = init[mode] or path..mode
		flg.logo.time  = time
		flg.logo.wait  = wait
		flg.logo.count = 1

		autoskip_ctrl()
		if p.key == "disable" then allkeyoff() end

		e:tag{"lydel", id="startmask"}

		-- 表示
		local v  = flg.logo
		local tm = mode == "black" and 0 or v.time
		lyc2{ id=(id), file=(v.file) }
		uitrans{ sys=2, time=(tm) }

	----------------------------------------
	-- リセット
	elseif not file then
		estag("init")
		estag{"lyc2", { id=(id), file=(v.file) }}
		estag{"uitrans", tr}
		estag{"brandlogo_windowsexit"}
		flg.logo = nil
		allkeyon()

		-- titleへ
		if mode ~= "end" then
			local fl = p.bg or v.file or init.start_bg or "black" if init[fl] then fl = init[fl] end
			estag{"lydel", id=(id)}
			estag{"lyc2", {id="2", file=(fl)} }
			estag{"jump", file="system/first.iet", label="title"}
		else
			estag{"lydel", id=(id)}
			estag{"autoskip_ctrl", true}
		end
		estag()

	----------------------------------------
	-- 画像表示
	else
		estag("init")
		local m = tn(p.movie) or 0
		if m == 0 then
			estag{"lyc2", { id=(id), file=(path..file) }}
			estag{"uitrans", tr}
		end

		----------------------------------------
		-- brand call
		if p.sysvo then estag{"sysvo", p.sysvo} end

		----------------------------------------
		-- movie / ogv
		if m == 2 then
			local px = game.path.movie..file..".ogv"
			estag{"video", id=(id), file=(px)}
			estag{"flip"}
			estag{"eqwait", { video=(id), input="2"} }

		-- movie / [video]
		elseif m ~= 0 then
			-- skip設定
			local nm = p.skip and string.upper(p.skip) or "ALL"
			local tb = csv.advkey.list or {}
			local fl = nil
			if nm:find(":") then
				local a = explode(":", nm)
				nm = a[1]
				if a[2] and (tb[a[2]] or a[2] == "ALL") then
					if sys.brandlogo then
						nm = a[2]
					else
						fl = true
						sys.brandlogo = true
					end
				end
			end

			-- deck用のファイル名読み替え
			if steam then
				file = steam.deck_movie_file_name(file)
			end

			-- 再生
			local ky = nm == "NONE" and "" or getKeyString(nm)
			local px = game.path.movie..file..game.movieext
			estag{"keyconfig", role="1", keys=(ky)}
--			estag{"video", file=(px), skip="2"}
			estag{"movie_playfile", px}
			estag{"keyconfig", role="1", keys=""}
			if fl then estag{"syssave"} end

		-- wait
		else
			estag{"eqwait", wait }
		end

		----------------------------------------
		-- 合間の画像
		local bx = p.bg or v.file if bx == "none" then bx = nil end
		if bx then
			if bx == "black" or bx == "white" then bx = init[bx] end
			estag{"lyc2", { id=(id), file=(bx) }}
			estag{"uitrans", tr}
		end
		estag()
	end
end
----------------------------------------
-- 動画再生中に×ボタンが押されると抜けられなくなる対処
function brandlogo_windowsexit()
	if gameexitflag then tag{"exit"} end
end
----------------------------------------
-- windows
----------------------------------------
-- windows /64bit確認
function getWindowsOSbit()
	return e:var("s.llp64") == "1"
end
----------------------------------------
-- windows / OSボタン設定
function window_button()
	if game.trueos == "windows" then
		if init.window_maxwindow == "on" then e:tag{"var", name="s.enablemaximizedwindow", data="1"} end	-- 最大化フラグ
		local b1 = init.window_close
		local b2 = init.window_max
		local b3 = init.window_min
		if b1 then e:tag{"setonwindowbutton", button="0", handler="calllua", ["function"]=(b1)}
		else	   e:tag{"setonwindowbutton", button="0", handler="calllua", ["function"]="windowclose_default"} end
		if b2 then e:tag{"setonwindowbutton", button="1", handler="calllua", ["function"]=(b2)} end
		if b3 then e:tag{"setonwindowbutton", button="2", handler="calllua", ["function"]=(b3)} end
	end
end
----------------------------------------
-- windows / OSボタンを塞ぐ
function window_buttonexit()
	if game.trueos == "windows" then
		local nm = "adv_dummy"
		tag{"setonwindowbutton", button="0", handler="calllua", ["function"]=(nm)}
		tag{"setonwindowbutton", button="1", handler="calllua", ["function"]=(nm)}
		tag{"setonwindowbutton", button="2", handler="calllua", ["function"]=(nm)}
	end
end
----------------------------------------
-- ×ボタン / 初期値
function windowclose_default()
	saveWindowsSize()			-- windowsサイズ保存
	store(e, { file="exit" })	-- 変数を変換しておく
	tag{"exit"}
end
----------------------------------------
-- ×ボタン / OS dialog版
function window_close()
	if not gameexitflag then
		if get_dlgparam("exit") == 0 then
			se_ok()
			local v  = getLangHelp("dlgmes")
			local tl = v and v.check or "確認"
			local ms = v and v.exit  or "ゲームを終了しますか？"
			tag_dialog({ varname="yesno", title=(tl), message=(ms)}, "windowclose_next")
		else
			sv.go_exit()
		end
	end
end
----------------------------------------
function windowclose_next()
	local yn = tn(e:var("yesno"))
	if yn == 1 then
		se_ok()
		sv.go_exit()
	else
		se_cancel()
	end
	tag{"var", system="delete", name="yesno"}
end
----------------------------------------
-- ×ボタン / 画像dialog版(test)
function window_exclose()
	local st = e:getScriptStatus()

	-- 何もしない(できない)
	if flg.exskip or flg.dlg2 then

	-- delay中は飛ばす必要がある
	elseif flg.delay then
		flg.delayexclose = true
		setexclick()

	-- 念の為status:0のみ実行
	elseif st == 0 then
		if not flg.ui and not flg.dlg then	-- ゲーム画面
			advmw_clear("sp")			-- advボタンクリア
			autoskip_stop()
		end

		-- dialog表示
		local gd = get_dlgparam("gameend")
		if gd == 0 then
			yesno_gameend()
		else
			sv.go_exit()
		end
	end
end
----------------------------------------
-- auto cursor
----------------------------------------
-- カーソル追尾
function mouse_autocursor(name, time)
	if game.os == "windows" and conf.mouse == 1 then
--		local tbl = { 3,3,3,3,3,4,5,7,10,15 }
		local tbl = { 0.05, 0.05, 0.05, 0.05, 0.05, 0.07, 0.10, 0.13, 0.19, 0.26 }
		local m = e:getMousePoint()
		local v = getBtnInfo(name)
		local x = v.x + math.floor(v.w / 2)
		local y = v.y + math.floor(v.h / 2)
		local t = time or 60

		-- 計算
		local c  = 0
		local fx = math.floor((x - m.x) / 10)
		local fy = math.floor((y - m.y) / 10)
		for i=1, 10 do
			local tx = math.floor(t * tbl[i])
			eqtag{"calllua", ["function"]="mouse_autocursorlp", x=(fx), y=(fy)}
			eqwait(tx)
			c = c + tx
		end
		if c < time then eqwait(time - c) end
		eqtag{"calllua", ["function"]="mouse_autocursored", name=(name)}
	end
end
----------------------------------------
function mouse_autocursorlp(e, p)
	local m = e:getMousePoint()
	tag{"mouse", left=(m.x + p.x), top=(m.y + p.y)}
end
----------------------------------------
function mouse_autocursored(e, p)
	btn_active2(p.name)
	flip()
end
----------------------------------------
-- ウィンドウサイズ
----------------------------------------
-- module名管理
function getWindowSizeModule()
	local r = nil
	if game.trueos == "windows" then
		local fl = init.game_screendll
		local no = getWindowsOSbit() and 2 or 1
		r = fl[no]
		if not isFile(r) then r = nil end
	end
	return r
end
----------------------------------------
-- windowサイズ変更初期化
function windows_screeninit()
	local mod = getWindowSizeModule()
	if mod and not windows_screenaspect then
		-- ver取得
		tag{"callnative", result="t.tmp", module=(mod), method="GetDllVersion"}
		local ver = e:var("t.tmp")

		-- artemis_resolution.dll
		if ver == "" then
			local px = e:var("s.savepath").."/"
			tag{"callnative", result="t.tmp", module=(mod), method="initialize", param=("path="..px)}		-- 初期化は一度のみ行う
			windows_screenaspect = "ver0"

		-- iarsys.dll
		else
			local z = debug_windows_screenload(sys.windowsize or {})
			windows_screenaspect = ver

			-- commandを読み込む
			tag{"var", name="t.tmp", system="get_exe_parameter"}
			local cm = e:var("t.tmp.window")
			if cm == "reset" then
				sys.windowsize = nil
				debug_windows_screensave()		-- debug reset
				message("通知", "window情報をリセットしました")

			-- サイズ決め打ち
			elseif cm:find("x") then
				setConsoleSize()	-- console
				tag{"callnative", result="t.tmp", module=(mod), method="GetDesktopSize"}
				local ax = explode("x", cm)
				local bx = explode(",", e:var("t.tmp"))
				local w  = tn(ax[1]) or game.width
				local h  = tn(ax[2]) or game.height
				if w < 100 or w > tn(bx[3]) then w = game.width  end
				if h < 100 or h > tn(bx[4]) then h = game.height end
				if z.x and z.y then
					tag{"callnative", result="t.tmp", module=(mod), method="SetWindowPosition", param=(z.x..","..z.y..","..w..","..h)}
				else
					tag{"callnative", result="t.tmp", module=(mod), method="SetWindowSize", param=(w.."x"..h)}
				end

			-- 位置とサイズ
			elseif z.w and z.h then
				setConsoleSize()	-- console
				tag{"callnative", result="t.tmp", module=(mod), method="SetWindowPosition", param=(z.x..","..z.y..","..z.w..","..z.h)}

			-- 位置だけ
			elseif z.x and z.y then
				setConsoleSize()	-- console
				setWindowsScreenSize(z.x, z.y)
			end
		end
	end
end
----------------------------------------
-- スクリーンサイズ保存
function saveWindowsSize()
	local mod = getWindowSizeModule()
	if mod and windows_screenaspect ~= "ver0" then
		if not sys.windowsize then sys.windowsize = {} end
		tag{"callnative", result="t.tmp", module=(mod), method="GetWindowPosition"}
		local ax = explode(",", e:var("t.tmp"))
		sys.windowsize.x = ax[1]
		sys.windowsize.y = ax[2]
		sys.windowsize.w = ax[3]
		sys.windowsize.h = ax[4]

		-- console
		if debug_flag then
			tag{"callnative", result="t.tmp", module=(mod), method="GetConsolePosition"}
			local bx = explode(",", e:var("t.tmp"))
			sys.windowsize.cx = bx[1]
			sys.windowsize.cy = bx[2]
			sys.windowsize.cw = bx[3]
			sys.windowsize.ch = bx[4]

			-- iniに保存
			debug_windows_screensave(ax)
		end
	end
end
----------------------------------------
-- スクリーンサイズ変更
function setWindowsScreenSizeCall(e, p) setWindowsScreenSize() end
function setWindowsScreenSize(x, y)
	local mod = getWindowSizeModule()

	----------------------------------------
	local func = function(w, h)
		if windows_screenaspect == "ver0" then
			tag{"callnative", result="t.tmp", module=(mod), method="setwndsize", param=("width="..w..",height="..h)}
		elseif x and y then
			tag{"callnative", result="t.tmp", module=(mod), method="SetWindowPosition", param=(x..","..y..","..w..","..h)}
		else
			tag{"callnative", result="t.tmp", module=(mod), method="SetWindowSize", param=(w.."x"..h)}
		end
	end

	----------------------------------------
	if mod and windows_screenaspect then
		local sz = conf.winsize or 1		-- screen size
		local v  = init.game_windowsize

		-- fullscreenのときは実行しない
		if get_artemis("fullscreen") == 1 then
			message("通知", "fullscreenでは実行しません")

		-- setting.txtにて設定
		elseif v and v[sz] then
			local a = explode("x", v[sz])
			local w = a[1] or game.width
			local h = a[2] or game.height
			func(w, h)

		-- 直値で設定
		elseif type(sz) == "string" then
			if sz:find("x") then
				local a = explode("x", sz)
				func(a[1], a[2])
			end

		-- 倍率で設定
		else
			if sz <= 0 then sz = 1 end
			local a = init.game_scale
			local w = math.ceil(a[1] * sz)
			local h = math.ceil(a[2] * sz)
			func(w, h)
		end
	end
end
----------------------------------------
-- コンソールサイズ変更
function setConsoleSize()
	local mod = getWindowSizeModule()
	if mod and windows_screenaspect ~= "ver0" and debug_flag then
		local z = sys.windowsize or {}
		local s = "none"
		if z.cx and z.cy and z.cw and z.ch then s = z.cx..","..z.cy..","..z.cw..","..z.ch end
		tag{"callnative", result="t.tmp", module=(mod), method="SetConsolePosition", param=(s)}
	end
end
----------------------------------------
-- exeのcrcを判定して返す
function getWindowsCrc(file, crc)
	local r   = true
	local mod = getWindowSizeModule()
	if mod and windows_screenaspect ~= "ver0" then
		tag{"callnative", result="t.tmp", module=(mod), method="GetExecName"}
		local name = string.lower(e:var("t.tmp"))
		local cexe = string.lower(file)
		if name == cexe and isFile(name) and isFile(cexe) then
			tag{"var", system="file_crc", name="t.crc", file=(cexe)}
			local rcrc = e:var("t.crc")
			if string.lower(crc) == rcrc then r = nil end
		end

	-- dllを使用しない
	else
		tag{"var", system="file_crc", name="t.crc", file=(file)}
		if string.lower(crc) == e:var("t.crc") then r = nil end
	end
	return r
end
----------------------------------------
-- debug load
function debug_windows_screenload(r)
	if debug_flag then
		local fp = io.open(ex.debugfile, "r")
		if fp then
			for tx in fp:lines() do
				if tx:find("screen_[xywh]=[0-9]+") then
					local ax = explode("=", tx)
					local nm = ax[1]:gsub("screen_", "")
					local no = tn(ax[2])
					if no > 0 and no < 4096 then r[nm] = no end
				end
			end
			io.close(fp)
		end
	end
	return r
end
----------------------------------------
-- debug save
function debug_windows_screensave(data)
	if debug_flag then
		local fp = io.open(ex.debugfile, "w")
		if fp then
			local r = data or {}
			if r[1] then fp:write("screen_x="..r[1].."\n") end
			if r[2] then fp:write("screen_y="..r[2].."\n") end
			if r[3] then fp:write("screen_w="..r[3].."\n") end
			if r[4] then fp:write("screen_h="..r[4].."\n") end
			io.close(fp)
		end
	end
end
----------------------------------------
--
----------------------------------------
-- ■ font初期化
function font_init()
	-- langpack読み込み
--	flg.textfont = nil
	local ln = get_language("ui")
	local px = "system/table/list_"..game.os.."_"..ln..".tbl"
	e:include(px)

	-- OSとバージョン
	local s  = get_gamever() or "1.0"
	game.ver = s
	scr.gamever = s
	set_caption()		-- ウインドウタイトル設定
	get_fonttable()		-- fonttable作成

	-- cache
	local c  = 0
	local ln = get_language()
	for name, v in pairs(lang.font) do
		local sh = v.show or v[ln] and v[ln].show
		if sh == 'cache' then
			local id = 'fontcache.'..c
			set_textfont(name, id)
			e:tag{"chgmsg", id=(id), layered="1"}
			e:tag{"print", data="　"}
--			e:tag{"rp"}
			e:tag{"/chgmsg"}
			c = c + 1
		elseif sh and sh ~= 'none' then
			set_textfont(name, name)
		end
	end

	if c ~= 0 then
		e:tag{"lyprop", id="fontcache", left=(game.width), visible="0"}
	end
end
----------------------------------------
-- fonttable作成
function get_fonttable()
	local s = {}

	-- テーブル作成
	local v  = lang.uihelp.conf or {}	-- font名
	local mw = init.font_conftable		-- font設定 / conf並び順
	if mw then
		-- 手動定義
		for i, name in ipairs(mw) do
			if init[name] and v[name] then table.insert(s, name) end
		end
	else
		-- 自動抽出
		local mx = init.fontmax or 10
		for i=1, mx do
			local name = "font"..string.format("%02d", i)
			if init[name] and v[name] then table.insert(s, name) end
		end
	end

	-- windows専用
	if game.os == "windows" and init.game_windowsfont == "on" then
		tag{"var", name="t.font", system="get_font", monospace="1"}
		for i=0, ex.windowsfontmax do
			local n = e:var("t.font."..i);
			if n == '0' then
				break
			else
				table.insert(s, n)
			end
		end
	end
	fonttable = s
end
----------------------------------------
-- テキストレイヤーにfontを設定
function set_textfont(name, id, flag)
	-- １回だけ通過する
--	if not flg.textfont then flg.textfont = {} end
--	if not flg.textfont[name] then flg.textfont[name] = {} end
--	if not flag and flg.textfont[name][id] then return end
--	flg.textfont[name][id] = true

	-- 登録
	local font = get_fontdata(name, flag)
	local ly   = font.layered or 0
	e:tag{"chgmsg", id=(id), layered=(ly)}
	e:tag{"fontinit"}
	e:tag(font)

	-- show/hide
	local s = font.show
	if s and s ~= 'none' and s ~= 'cache' then
		e:tag{"scetween", mode="init", type="show"}
		e:tag{"scetween", mode="add",  type="show", param="alpha", ease="none", diff="0", time=(s), delay="0"}
		e:tag{"scetween", mode="init", type="hide"}
		e:tag{"scetween", mode="add",  type="hide", param="alpha", ease="none", diff="-255", time=(s), delay="0"}
	end

	-- indent
	local z  = getLangHelp("system")
	local id = font.indent
	local lr = font.logicalrange
	local tx = id and z[id]
	if tx then
		tag{"print", data=(tx)}		-- 一回書いておくとリセットできる？
		tag{"rp"}
		tag{"indent", nest="0", range="1", logicalrange=(lr), pair=(tx)}
	else
		tag{"indent", nest="0", range="0", logicalrange=(lr), pair=""}	-- indent無効化
		tag{"wordparts", parts="^"}										-- 英単語判定無効化
	end

	e:tag{"wordparts", parts="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"}

	-- prohibit
	local pr = tn(font.prohibit)
	local hd = pr == 2 and z.prohibit_head_s or pr and z.prohibit_head or " "
	local ft = pr == 2 and z.prohibit_foot_s or pr and z.prohibit_foot or " "
	e:tag{"prohibit", head=(hd), foot=(ft)}
	e:tag{"/chgmsg"}
end
----------------------------------------
-- フォント装飾
function get_fontdata(name, mode)
	local nm = name
	local md = mode
	local fo = nil

	----------------------------------------
	-- font名変換
	local t  = lang.font or {}
	local fm = "normal"
	local fd = type(md) == "string"
	local cf = conf.font or 1						-- font config
	local hd = name:match("([a-z]+)[0-9][0-9]")		-- name header
	local ad = ex.fontmodetable[md] or 0			-- csv番号補正値
	if fd and hd then
		local gf = "game_font"..md
		fm = init[gf] or "normal"					-- 動作mode
		local sw = {
			name   = function() nm = name end,
			conf   = function()	nm = hd..string.format("%02d", ad + cf) end,		-- configのfontを使用する
			auto   = function() nm = hd..string.format("%02d", ad + 1)	end,		-- configのfontを使用する / 01から補正
			fixed  = function()	nm = hd..string.format("%02d", ad + 1)  end,		-- 01固定
--			normal = function()  end,												-- 何もしない

			-- font設定とfont faceを別々に設定
			["list"] = function()
				local mw = scr.mwno or 1	-- mw no
				local ls = "fontlist_"..hd..string.format("_%02d", mw)
				local z  = init[ls]
				if z then
					local v = init.font_conftable or {}
					nm = z[cf] or nm		-- font name
					fo = v[cf]				-- font face
				end
			end,
		}
		if sw[fm] then sw[fm]() end

		-- 存在確認
		if not t[nm] then
			nm = hd.."01"
			if fm == "conf" then fm = "auto" end
		end
	end

	local r = tcopy2(t[nm])
	if not r then
		sysmessage("エラー", nm, "は登録されていないfont設定です")
		return
	end

	----------------------------------------
	local ft = fonttable or {}						-- font table
	local ln = get_language()						-- 言語
	if r[ln] then r = tcopy(r[ln]) end				-- 言語切替

	----------------------------------------
	local fontfunc = function(nm)
		local r = nm
		if r then
			-- confで上書き
			if fm == "auto" then
				local z = lang.font or {}
				local n = hd..string.format("%02d", ad + cf)
				if z[n] and z[n][ln] then r = z[n][ln].face end
			end

			-- 変換
			if ft[r]   then r = ft[r] end
			if init[r] then r = init[r] end
		end
		return r and string.lower(r)
	end

	----------------------------------------
	-- font登録
	r[1] = "font"
	r.stack	   = 0		-- 直前の設定をフォントスタックに格納しない
	r.overflow = 1		-- テキストが溢れた場合に何もしない

	-- 特定文字セットのみ実行する(adv/name等)
	if fd and init.game_fontdeco == "on" then
		-- パラメータ上書き
		local nm = fontfunc(fo or r.face)	-- font face変換
		local ru = fontfunc(r.ruby)			-- ruby face変換
		r.ruby		  = nil
		r.face		  = nm
		r.rubyface	  = ru

		-- 縁影ルーチン / 太さ対応
		local s  = conf.shadow  or 1	-- conf / 影
		local o  = conf.outline or 1	-- conf / 縁
		local bs = r.shadow  or 0		-- csv / 影
		local bo = r.outline or 0		-- csv / 縁
		local bt = r.spacetop or 0		-- csv / 上
		local bb = r.spacebottom or 0	-- csv / 下
		local bl = r.left or 0			-- csv / 左
		local bk = r.kerning or 0		-- csv / 幅

		-- 縁は上下左右に伸びる
		if o == 0 then
			bt = bt + bo
			bb = bb + bo
			bl = bl + bo
			bk = bk + bo + bo
		end

		-- 影は右下に伸びる
		if s == 0 then
			bb = bb + bs
			bk = bk + bs
		end

		-- 格納
		r.shadow	  = bs * s
		r.outline	  = bo * o
		r.left		  = bl
		r.kerning	  = bk
		r.spacetop	  = bt
		r.spacebottom = bb

		-- 新しいfontに差し替え
		if fm == "auto" then
			local z  = fonttable or {}
			local nm = z[cf] or r.face
			local od = get_fontsize(r)		-- もとfontのサイズを得る
			if init[nm] then nm = init[nm] end
			r.face = nm

			-- 横幅確認
			local nw = get_fontsize(r)
			if od.w ~= nw.w and nw.w > 0 then r.size = math.ceil(r.size * od.w / nw.w) end

			-- 縦幅確認
			local n2 = get_fontsize(r)
			if n2.h ~= nw.h then
				local ad = math.floor((nw.h - n2.h) / 2)
				r.spacetop	  = r.spacetop	  + ad
				r.spacebottom = r.spacebottom + ad

				-- kerning
				local k1 = od.w - n2.w
				if k1 ~= 0 then
					local s2 = (od.w - n2.w) / 10
					r.kerning = r.kerning + s2
				end
			end
		end
	else
		r.face     = get_fontface(r.face)		-- font face変換
		r.rubyface = get_fontface(r.ruby)		-- ruby face変換
		r.ruby = nil
	end

	-- 保存
	if flg.ui and hd == "config" then flg.conf_fontsize = r.size end
	return r
end
----------------------------------------
-- font face変換
function get_fontface(name)
	local r = name
	if r and init[r] then r = string.lower(init[r]) end
	return r
end
----------------------------------------
-- font size
function get_fontsize(p)
	local tx = "あいうえおかきくけこ"
	local fo = tcopy(p)
	fo.width  = 4000
	fo.height = 2000

	-- 削除
	fo.style	= nil
	fo.outline	= 0
	fo.shadow	= 0

	local id = "fontsizesample"
	tag{"chgmsg", id=(id), layered="0"}
	tag{"rp"}
	tag(fo)
	tag{"print", data=(tx)}
	local r = {
		w = get_artemis("get_message_layer_width"),
		h = get_artemis("get_message_layer_height"),
	}
	tag{"rp"}
	tag{"/font"}
	tag{"/chgmsg"}
	return r
end
----------------------------------------
-- scetween del
function scetweendel()
	flg.scetweendel = true
	eqtag{"wait", input="1", scenario="1" }
end
----------------------------------------
-- 
----------------------------------------
-- システム読み直し
function reloadSystemData()
	system_cachedelete()		-- system cache delete
--	flg.textfont = nil			-- fontクリア
	set_uipath()				-- ui path再設定
	font_init()					-- font再設定 / tbl読み直し
	system_cache()				-- system cache
end
----------------------------------------
-- 
----------------------------------------
function loading_on()	if loading_icon then e:tag{"lyprop", id="zzlogo.load", visible="1"} e:tag{"lyprop", id="zzlogo.save", visible="0"} loading_flash("load") end end
function loading_off()	if loading_icon then e:tag{"lyprop", id="zzlogo.load", visible="0"} e:tag{"lyprop", id="zzlogo.save", visible="0"} loading_flash("stop") end end
function saving_on()	if loading_icon then e:tag{"lyprop", id="zzlogo.load", visible="0"} e:tag{"lyprop", id="zzlogo.save", visible="1"} loading_flash("save") end end
function saving_off()	if loading_icon then e:tag{"lyprop", id="zzlogo.load", visible="0"} e:tag{"lyprop", id="zzlogo.save", visible="0"} loading_flash("stop") end end
----------------------------------------
function loading_flash(nm)
	tag{"lytweendel", id="zzlogo.load"}
	tag{"lytweendel", id="zzlogo.save"}
	local al = "255,96"
	local tm = 1000
	local dl = 8000
	local sw = {
		load = function() systween{ id="zzlogo.load", alpha=(al), yoyo="-1", time=(tm), delay=(dl) } end,
		save = function() systween{ id="zzlogo.save", alpha=(al), yoyo="-1", time=(tm), delay=(dl) } end,
	}
	if sw[nm] then sw[nm]() end
end
----------------------------------------
function loading_func(p)
	if loading_icon then
		local flag = p["0"] or 'off'
		local logo = p["1"] ~= "logo" and true
		if flag == 'on' then
			loading_on()
			if logo then lyc2{id="zzlogn", file=(init.black), alpha="128"} end
			flip()
		else
			loading_off()
			if logo then tag{"lydel", id="zzlogn"} end
			flip()
		end
	end
	wt()
end
----------------------------------------
function saving_func(p)
	if loading_icon then
		local flag = p["0"] or 'off'
		if flag == 'on' then saving_on()  lyc2{id="zzlogn", file=(init.black), alpha="128"}
		else				 saving_off() tag{"lydel", id="zzlogn"} end
		flip()
	end
	wt()
end
----------------------------------------
-- loadmask
function loadmask_func(p)
	local f = p["0"] or p.del
	local t = p.time
	if f then
		local v = scr.bgm
		if v then
			local tm = t or init.ui_fade
			local vl = v.vol or 1000
			tag{"sfade", gain=(vl), time=(tm)}	-- bgm復帰

			-- bgv復帰
			local b = scr.lvo
			if b and not flg.ui then
				for i, v in pairs(b) do
					local g = v.p.gain or 1000
					tag{"sefade", id=(v.id), gain=(g), time=(tm)}
				end
			end
		end
		uimask_off()
	else
		local tm = t or init.ui_fade
		tag{"sfade", gain="0", time=(tm)}	-- bgm

		-- bgv fadeout
		local b = scr.lvo
		if b and not flg.ui then
			for i, v in pairs(b) do
				tag{"sefade", id=(v.id), gain="0", time=(tm)}
			end
		end
		uimask_on()
	end
end
----------------------------------------
-- uimask
function uimask_func(p)
	local f = p["0"] or p.del
	if f then	uimask_off()
	else		uimask_on() end
end
function uimask_on()  e:tag{"lyc"  , id="zzamask", file=(init.black)} end
function uimask_off() e:tag{"lydel", id="zzamask"} end
----------------------------------------
-- tap effect
----------------------------------------
-- 初期化
function init_tapeffect()
	local p  = csv.mw.tap
	local fl = p and ":ui/"..p.file..".png"
	if not p or not isFile(fl) then return end

	-- 画像
	local id = p.id..'.'
	local x  = p.x
	local y  = p.y
	local w  = p.w
	local h  = p.h
	local lp = p.clip
	local tm = p.clip_a
	local mx = p.clip_c
	local wh = ",0,"..w..","..h
	for i=1, mx do
		for j=1, lp do
			local ix = id..i..'.'..j
			local cl = (j-1) * w
			lyc2{ id=(ix), file=(fl), clip=(cl..wh), alpha="0" }
		end
		tag{"lyprop", id=(id..i), alpha="0", left=(-w)}
	end

	-- save
	tapeffect = {
		t  = {},
		id = id,
		ct = 0,
		mx = mx,
		x  = x,
		y  = y,
		w  = w,
		lp = lp,
		tm = tm,
	}
end
----------------------------------------
function vsync_tapeffect()
	if conf.tapeffect ~= 1 then return end

	local p  = tapeffect
	local tm = p.tm + e:now()
	local id = p.id
	local lp = p.lp
	local mx = p.mx
	local w  = p.w

	-- 時間処理
	if p.sv then
		local nw = e:now()
		for i, v in pairs(p.sv) do
			if nw > v.tm then
				local ct = v.lp + 1
				if ct >= lp then
					tag{"lytween", id=(id..i),			param="left" , time="0", from="0", to=(-w)}
					tag{"lytween", id=(id..i),			param="alpha", time="0", from="1", to="0"}
					tag{"lytween", id=(id..i.."."..ct), param="alpha", time="0", from="1", to="0"}
					tapeffect.t[v.no] = nil
					tapeffect.sv[i] = nil
					if tmaxn(tapeffect.sv) == 0 then tapeffect.sv = nil end
				else
					tag{"lytween", id=(id..i.."."..(ct-1)), param="alpha", time="0", from="1"  , to="0"}
					tag{"lytween", id=(id..i.."."..(ct  )), param="alpha", time="0", from="254", to="255"}
					tapeffect.sv[i].tm = tm
					tapeffect.sv[i].lp = ct
				end
			end
		end
	end

	-- タップ
	local tp = e:getTouchCount()
	if tp > 0 then
		if not tapeffect.sv then tapeffect.sv = {} end
		local t = tapeffect.t
		for no, v in pairs(e:getTouchPoint()) do
			if not t[no] then
				local ct = p.ct + 1 if ct > mx then ct = 1 end
				local x  = v.x + p.x
				local y  = v.y + p.y
				tag{"lytween", id=(id..ct),		  param="alpha", time="0", from="254", to="255"}
				tag{"lytween", id=(id..ct),		  param="left" , time="0", from=(x-1), to=(x)}
				tag{"lytween", id=(id..ct),		  param="top"  , time="0", from=(y-1), to=(y)}
				tag{"lytween", id=(id..ct..".1"), param="alpha", time="0", from="254", to="255"}
				for i=2, lp do
					tag{"lytween", id=(id..ct.."."..i), param="alpha", time="0", from="1", to="0"}
				end

				-- save
				tapeffect.ct = ct
				tapeffect.t[no] = ct
				tapeffect.sv[ct] = {
					lp = 1,
					tm = tm,
					no = no,
				}
			end
		end
	end
end
----------------------------------------
-- config on/off切り替え
function conf_tapeffect()
	local c = conf.tapeffect or 0
	local p = csv.mw.tap
	if p then
		tag{"lyprop", id=(p.id), visible=(c)}
	end
end
----------------------------------------
--
----------------------------------------
-- check novel mode
function getNovel()
	return init.game_novel == "on"
end
----------------------------------------
-- get novel data
function getNovelData()
	return getNovel() and scr.novel
end
----------------------------------------
