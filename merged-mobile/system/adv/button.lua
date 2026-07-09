---------------------------------------
-- ボタン制御 / Ver.3
----------------------------------------
btn = nil
----------------------------------------
local ex = {}
----------------------------------------
ex.pinid	 = ".10"	-- slider pin id
ex.blinkid	 = ".7"		-- active blink id
ex.blinktime = 500		-- active blink time
ex.blinktable = { btn=1, toggle=1, single=1, xslider=1, yslider=1, mark=1 }
----------------------------------------
-- ■ボタン処理
----------------------------------------
-- csvからボタンを生成する
function csvbtn3(name, defid, param)
	if not param then message("警告", "ボタンID", name, "が登録されていません") end
	local id = defid.."."
	local ps = get_psswap()		-- PS enter 0:○ 1:×

	-- スタック／初期化
	if not btn then btn = {} end
--	if not scr.btnfunc then scr.btnfunc = {} end
	btn[name] = { id=(id), p=(param), dis={}, key={} }
	btn.name = name
	btn.cursor = nil
	btn.group  = nil
	btn.moveover = nil
--	btn.renew  = nil	-- 更新フラグ

	-- uiの初期化
	if name ~= "adv" then lydel2(defid) end

	----------------------------------------
	-- btn cache
	local z  = {}
	local pp = param[1] ~= "" and param[1]
	for nm, p in pairs(param) do
		local fl = type(p) == "table" and p.file
		if fl and p.com ~= "key" and not z[fl] then
			z[fl] = pp and pp..fl or get_uipath(fl)
		end
	end

	-- file名変換
	local readfile = function(fl) return z[fl] or get_uipath(fl) end

	----------------------------------------
	-- ボタン画像個別設定
	local sw = {
		-- x slider
		xslider = function(ix, p)
			local x  = repercent(loadBtnData(p.def), p.w - p.p2)	-- スライダーの初期値 0-100
			local cl = getBtnThreshold(p, "pin") and getBtnPinClip("x", p, true)
			lyc2{ id=(ix..ex.pinid), x=(x), file=(readfile(p.p1)), draggable="1", dragarea=(p.area), clip=(cl)}		-- pin
			lyevent{ id=(ix..ex.pinid), name=(name), key=(p.name), drag="slider_dragX", dragin="slider_dragin", dragout="slider_dragout"}
		end,

		-- y slider
		yslider = function(ix, p)
			local y  = repercent(loadBtnData(p.def), p.h - p.p2)	-- スライダーの初期値 0-100
			local cl = getBtnThreshold(p, "pin") and getBtnPinClip("y", p, true)
			lyc2{ id=(ix..ex.pinid), y=(y), file=(readfile(p.p1)), draggable="1", dragarea=(p.area), clip=(cl)}		-- pin
			lyevent{ id=(ix..ex.pinid), name=(name), key=(p.name), drag="slider_dragY", dragin="slider_dragin", dragout="slider_dragout"}
		end,

		-- checkbox
		check = function(ix, p)
			local n = loadBtnData(p.def)
			local f = tn(p.p1) or 0
			lyc2{ id=(ix..'.2'), file=(readfile(p.file)), clip=(p.clip_c)}		-- check
			if n == f then
				tag{"lyprop", id=(ix..".2"), visible="0"}
			end
		end,

		-- トグル
		toggle = function(ix, p)
			local cf = p.def
			local p1 = tn(p.p1)
			local tg = loadBtnData(cf)
			if tg and tg == p1 then
				tag{"lyprop", id=(ix..".0"), clip=(p.clip_c)}
				setBtnStat(p.name, cf)	-- disable
			end
		end,

		-- selectbox
		select = function(ix, p) btn_selectdraw(ix, p) end,
	}

	----------------------------------------
	-- ボタン画像共通設定
	local button = function(p, ad)
		local ix = id..p.id
		local px = p.file
		local al = getBtnThreshold(p, "alpha")		-- しきい値を分離

		-- clipで作成
		if p.clip then
			local cd = al and al >= 0 and al
			lyc2{ id=(ix..'.0'), file=(readfile(px..ad)), alpha="255", clip=(p["clip"..ad]), clickablethreshold=(cd)}

		-- 複数画像で作成(レガシー)
		else
			local c1,c2,c3 = 255,0,0
			if ad == '_c' then c1,c3 = 0,255 elseif ad == '_a' then c1,c2 = 0,255 end
			lyc2{ id=(ix..'.0'), file=(readfile(px      )), alpha=(c1)}
			lyc2{ id=(ix..'.1'), file=(readfile(px..'_a')), alpha=(c2)}
--			if flag then lyc2{ id=(ix..'.2'), file=(px..'_c'), alpha=(c3)} end
		end
		local cm = p.com
		if sw[cm] then sw[cm](ix, p, pin) end				-- 個別のボタン設定を呼び出す
		tag{"lyprop", id=(ix), left=(p.x), top=(p.y)}
	end

	----------------------------------------
	-- csvを展開
	for k, p in pairs(param) do
		local cm, ix, px
		if type(p) == "table" then
			local fx = p.file
			cm = p.com
			ix = p.id and id..p.id
			if fx and cm ~= "key" then
				px = readfile(fx)
			end
		end

		-- 画像設置
		if type(k) == 'string' and cm ~= 'work' then
			local al = getBtnThreshold(p, "alpha")		-- しきい値を分離

			----------------------------------------
			-- ボタン画像共通設定 / image
			local image = {
				-- オブジェクト
				obj  = function(id)	lyc2{ id=(ix), file=(px), x=(p.x), y=(p.y), alpha=(al), clip=(p.clip) } end,
				obj2 = function(id)	lyc2{ id=(ix), file=(px), x=(p.x), y=(p.y), alpha=(al), clip=(p.clip), anchorx="0", xscale=(p.w.."00")} end,
				obj3 = function(id)	lyc2{ id=(ix), file=(px), x=(p.x), y=(p.y), alpha=(al), clip=(p.clip), anchorx="0", anchory="0", xscale=(p.w.."00"), yscale=(p.h.."00")} end,
				objb = function(id)
					lyc2{ id=(ix..".0"), file=(px), alpha=(al), clip=(p.clip) }
					tag{"lyprop", id=(ix), left=(p.x), top=(p.y) }
				end,
				objps = function(id)
					local fl = ps and readfile(p.file.."_x") or px
					lyc2{ id=(ix..".0"), file=(fl), x=(p.x), y=(p.y), alpha=(al), clip=(p.clip) }
				end,

				-- box
				box = function(id)	lyc2{ id=(ix), width=(p.w), height=(p.h), color=("0"..p.p1), x=(p.x), y=(p.y), alpha=(al)} end,

				-- move
				move = function(id)
					local x  = p.p1
					local y  = p.p2
--					local al = p.flag
					local ov = p.over
					local ot = p.out
					local df = p.def
					local r  = df and loadBtnData(df)
					lyc2{ id=(ix..".-1.1"), file=(px), x=(p.x), y=(p.y), clip=(p.clip) }
					if r ~= 1 then tag{"lyprop", id=(ix), left=(x), top=(y)} end
					if p.p3 then
						lyc2{ id=(ix..".-1.0"), file=(readfile(p.p3)), x=(p.x), y=(p.y), alpha="0", clickablethreshold=(al)}
						lyevent{ base=(ix), id=(ix..".-1.0"), over="btn_moveover", out="btn_moveout", ov=(ov), ot=(ot), name=(name), x=(x), y=(y), p4=(p.p4), def=(df)}
					else
						if al then tag{"lyprop", id=(ix..".-1.1"), clickablethreshold=(al)} end
						lyevent{ base=(ix), id=(ix..".-1.1"), over="btn_moveover", out="btn_moveout", ov=(ov), ot=(ot), name=(name), x=(x), y=(y), p4=(p.p4), def=(df)}
					end
				end,

				-- key / 何もしない
				key = function() end
			}

			-- 画像
			if image[cm] then
				image[cm](id)

			-- ボタン
			else
				button(p, '')
				if cm == "mark" then
					lyevent{ id=(ix..'.0'), click="btn_click", name=(name), key=(k)}
				elseif cm == "help" then
					lyevent{ id=(ix..'.0'), over="btn_over", out="btn_out", name=(name), key=(k), se="1"}
				else
					local sl = p.p3 == "se_silent" and 1	-- アクティブ音なし簡易設定
					lyevent{ id=(ix..'.0'), click="btn_click", over="btn_over", out="btn_out", name=(name), key=(k), se=(sl)}
				end
			end

			-- blink
			if ex.blinktable[cm] and p.clip_a and getBtnThreshold(p, "blink") then
				local ig = ix..ex.blinkid
				lyc2{ id=(ig), file=(px), clip=(p.clip_a), layermode="add", alpha="0" }
			end

			-- キーの登録
			local ky = p.key
			if ky then
				local rep = p.file == 'repeat'		-- リピート
				btn[name].key[ky] = { name=(p.name), exec=(p.exec), rep=(rep) }	-- キー名に状態を保存
			end
		end
	end

	----------------------------------------
	-- single check / 他のボタンに影響を与えるので最後に処理する
	for k, p in pairs(param) do
		if type(p) == "table" and p.com == 'single' then setBtnStat(k, "single") end
	end

	-- 座標補正
	if game.crop and tn(defid) == 500 then
		tag{"lyprop", id=(defid), top=(game.crop)}
	end

	-- キー再設定
	if name ~= 'adv' then setonpush_ui() end
end
----------------------------------------
-- ボタン自動active
function button_autoactive()
	local tb = { btn=1, check=1, toggle=1, xslider=1, yslider=1 }
	local nm = btn.name
	local p  = btn[nm]
	local go = game.os
	if (go == "windows" or go == "wasm") and p then
		local m = e:getMousePoint()
		local x = m.x
		local y = m.y
		local b  = {}	-- ボタン名を格納しておく
		local z  = {}	-- ボタン名にidを割り当て
		for k, v in pairs(p.p) do
			local cm = type(v) == 'table' and v.com
			if cm and tb[cm] and not p.dis[k] then
				local w = v.w + v.x
				local h = v.h + v.y
				if x > v.x and y > v.y and x < w and y < h then
					table.insert(b, k)
					z[k] = v.id
				end
			end
		end

		-- ボタン数を見る
		local nm = b[1]		-- ひとつめのボタン名を入れておく
		local mx = #b
		if mx == 1 then
			btn_active2(nm)
			flip()
		elseif mx > 1 then
			local ix = ""
			for bt, id in pairs(z) do
				if ix < id then
					nm = bt		-- ボタン名更新
					ix = id		-- 手前のidを保存
				end
			end
			btn_active2(nm)
			flip()
		end
	end
end
----------------------------------------
-- ボタン処理終了
function delbtn(name, p)
	if btn[name] then
		-- scr.btnfuncから削除しておく
		if scr.btnfunc then
			for n, v in pairs(btn[name].p) do
				scr.btnfunc[name.."|"..n] = nil
			end
		end

		-- 消す
		local id = p or btn[name].id:sub(1, -2)
		lydel2(id)
		btn[name] = nil
	else
		error_message(name..'は登録されていませんでした')
		tag{"lydel", id="500"}
	end
	btn.name  = nil
	btn.group = nil
	btn.rep   = nil
	btn.cursor= nil

	-- configセーブフラグ
	local tbl = { csub=1, dlg=1 }
	if not tbl[name] then btn.renew = nil end

	-- カーソルキーを元に戻す
	delonpush_ui()
end
----------------------------------------
-- 
----------------------------------------
-- click
function btn_clickex(e, p)
	local bt = btn and btn.cursor
	local ky = p.key
	flg.btnclick = ky
	if bt and bt ~= ky then
		btn_out( e, { key=bt })
		btn_over(e, { key=ky })
	end
end
----------------------------------------
-- click
function btn_click(e, param)
--	local nm = param.key or btn.cursor
	local nm = btn.cursor
	if nm and get_gamemode('ui2', nm) then
		if param.click then
			----------------------------------------
			-- 無効なボタンなら何もしない
			if getBtnStat(nm) then return end

			----------------------------------------
			-- 押されたボタンをアクティブ色にする
			-- out
			if btn.cursor then
				local id = getBtnID(btn.cursor)..".0"
				btn_out(e, { id=(id), key=(btn.cursor) })
			end
			-- over
			param.se = true
			btn.cursor = nm
			btn_over(e, param)
		end

		----------------------------------------
		-- ボタン実行
		local p = getBtnInfo(btn.cursor)
		if p.exec then
			call_lua(param, p.exec)
		else
			-- ボタンを自動的に判別する
			btn_change(param)
		end
	end
end
----------------------------------------
function btn_over(e, param)
	local key = param.key
	if get_gamemode('ui2', key) then
		-- 別のボタンがあれば消去
		local bt = btn.cursor
		if bt and bt ~= param.key then btn_out(e, { key=(bt), se=(param.se), flip=(param.flip)}) end

		local p = getBtnInfo(key)
		local id = p.idx
		local cm = p.com
		local ss = param.se or cm == "xslider" or cm == "yslider"
		if not ss then se_active() end

		if cm == "help" then
		elseif cm == "single" then
			local df = loadBtnData(p.def) == 1
			local p2 = p.p2 ~= "1"
			local c  = p2 and (df and p.clip_d or p.clip_a) or df and p.clip_a or p.clip_d
			tag{"lyprop", id=(id..".0"), clip=(c)}

		-- x-slider pin
		elseif cm == "xslider" and getBtnThreshold(p, "pin") then
			tag{"lyprop", id=(id..ex.pinid), clip=(getBtnPinClip("x", p))}

		-- y-slider pin
		elseif cm == "yslider" and getBtnThreshold(p, "pin") then
			tag{"lyprop", id=(id..ex.pinid), clip=(getBtnPinClip("y", p))}

		-- select
		elseif cm == "select" then
			btn_selectdraw(id, p, 'a')

		elseif p.clip then
			tag{"lyprop", id=(id..".0"), clip=(p.clip_a)}
--			btn_yoyo(key, true)
		else
			tag{"lyprop", id=(id..'.0'), alpha=0}
			tag{"lyprop", id=(id..'.1'), alpha=255}
		end

		-- blink
		if p.clip_a and getBtnThreshold(p, "blink") then btn_blink(p) end

		uihelp_over(p)
		if p.over then tag{"calllua", ["function"]=(p.over), name=(key)} end
		if not param.flip then flip() end

		btn.cursor = key
		btn.group  = btn.name
		if not flg.dlg and param.type then btn_actcursor() end	-- マウス操作のときはアクティブ情報を削除
	end
end
----------------------------------------
function btn_out(e, param)
	local key = param.key
	if get_gamemode('ui2', key, true) then
		local p = getBtnInfo(key)
		local id = p.idx

		-- blink
		if p.clip_a and getBtnThreshold(p, "blink") then btn_blink(p, "stop") end

		-- out
		if not btn[btn.name].dis[p.name] then
			local cm = p.com
			if cm == "help" then
			elseif cm == "single" then
				local df = loadBtnData(p.def) == 1
				local p2 = p.p2 ~= "1"
				local c  = p2 and (df and p.clip_c or p.clip) or df and p.clip or p.clip_c
				tag{"lyprop", id=(id..'.0'), clip=(c)}

			-- x-slider pin
			elseif cm == "xslider" and getBtnThreshold(p, "pin") then
				tag{"lyprop", id=(id..ex.pinid), clip=(getBtnPinClip("x", p, true))}

			-- y-slider pin
			elseif cm == "yslider" and getBtnThreshold(p, "pin") then
				tag{"lyprop", id=(id..ex.pinid), clip=(getBtnPinClip("y", p, true))}

			-- select
			elseif cm == "select" then
				btn_selectdraw(id, p)

			elseif p.clip then
--				btn_yoyo(key)
				tag{"lyprop", id=(id..'.0'), clip=(p.clip)}
			else
--				local id = getBtnID(key)
				tag{"lyprop", id=(id..'.0'), alpha=255}
				tag{"lyprop", id=(id..'.1'), alpha=0}
			end

			if p.out then tag{"calllua", ["function"]=(p.out), name=(key)} end
			if key == btn.cursor then btn.cursor=nil btn.group=nil uihelp_out(p) end
			if not param.flip then flip() end
		end
	end
end
----------------------------------------
-- ボタンをアクティブにする / name, dir, se, flip
function btn_active(...)
	-- param check
	local t = {...}
	local n, d, p = t[1], t[2], {}
	if type(n) == 'table' then
		p = n
		n = n[1]
	end

	-- disable check
	local name = btn.name
	if btn[name].dis[n] then
		local dw = btn[name].p[n][d]
		local t  = getBtnInfo(n)

		-- toggle
		if t.com == 'toggle' and getBtnStat(n) then
			dw = t.p2
		end
		if dw then btn_active(dw, d) end

	else
		local id = getBtnID(n)..'.0'
		btn_over(e, { id=(id), name=(name), key=(n), se=(p.se), flip=(p.flip)})
	end
end
----------------------------------------
function btn_active2(name) btn_active{ name, se=true, flip=true } end
----------------------------------------
-- ボタンをノンアクティブにする
function btn_nonactive(name, fp)
	if name then
		local n  = btn.name
		local id = getBtnID(name)..'.0'
		btn_out(e, { id=(id), name=(n), key=(name), flip=(fp)})
	end
end
----------------------------------------
-- moveボタンover処理
function btn_moveover(e, p)
	if p.df and loadBtnData(p.df) == 1 then return end

	-- windowsは画面外判定をする
	if game.os == "windows" then
		local m = e:getMousePoint()
		if m.x < 0 or m.y < 0 or m.x >= game.width or m.y >= game.height then return end
	end

	-- over
	local ov = p.ov
	if ov and _G[ov] then
		_G[ov](e, p)
	else
		local id = p.base
		local tm = init.ui_fade
		local x  = tn(p.x) ~= 0 and p.x
		local y  = tn(p.y) ~= 0 and p.y
		tag{"lytweendel", id=(id)}

		-- p4 func
		local p4 = p.p4
		if p4 == "takess" then sv.makepoint()
		elseif _G[p4] then _G[p4](p, "over") end

		-- tween
		if x then systween{ id=(id), x=(x..",0"), time=(tm)} end
		if y then systween{ id=(id), y=(y..",0"), time=(tm)} end
	end
	btn.moveover = true
end
----------------------------------------
-- moveボタンout処理
function btn_moveout(e, p)
	if p.df and loadBtnData(p.df) == 1 then return end

	-- out
	if btn.moveover then
		local ot = p.ot
		if ot and _G[ot] then
			_G[ot](e, p)
		else
			local id = p.base
			local tm = init.ui_fade
			local x  = tn(p.x) ~= 0 and p.x
			local y  = tn(p.y) ~= 0 and p.y
			tag{"lytweendel", id=(id)}
			if x then systween{ id=(id), x=("0,"..x), time=(tm)} end
			if y then systween{ id=(id), y=("0,"..y), time=(tm)} end

			-- p4 func
			local p4 = p.p4
			if _G[p4] then _G[p4](p, "out") end
		end
	end
	btn.moveover = nil
end
----------------------------------------
-- selectbox
----------------------------------------
-- selectbox描画
function btn_selectdraw(id, p, clip, num)
	local tb = { a=1, c=2, d=3 }
	local t  = explode("|", p.p1)
	local cf = loadBtnData(p.def)		-- read data

	-- 横位置
	local wx = clip and tb[clip] or 0

	-- 縦位置
	local hx = num or 0
	if not num then
		for i=1, #t do
			if cf == tn2(t[i]) then
				hx = i-1
				break
			end
		end
	end

	-- clip
	local cx = p.cx + (wx * p.cw)
	local cy = p.cy + (hx * p.ch)
	local cl = cx..","..cy..","..p.w..","..p.h
	tag{"lyprop", id=(id..".0"), clip=(cl)}
end
----------------------------------------
-- カーソル制御
----------------------------------------
-- LT
function btn_left(e, param)
	local n1 = btn.name
	local n2 = param.name
	local p  = btn[n1].p[n2]
	local bt = btn.cursor
	if bt then
		local v = getBtnInfo(bt)
		if v.lt then
			btn_nonactive(bt)
			btn_active(v.lt, 'lt')
			bt = v.lt
		end
	elseif p.def then
		btn_active(p.def, 'lt')
		bt = p.def
	end
	if bt and not flg.dlg then btn_actcursor(bt) end
end
----------------------------------------
-- RT
function btn_right(e, param)
	local n1 = btn.name
	local n2 = param.name
	local p  = btn[n1].p[n2]
	local bt = btn.cursor
	if bt then
		local v = getBtnInfo(bt)
		if v.rt then
			btn_nonactive(bt)
			btn_active(v.rt, 'rt')
			bt = v.rt
		end
	elseif p.def then
		btn_active(p.def, 'rt')
		bt = p.def
	end
	if bt and not flg.dlg then btn_actcursor(bt) end
end
----------------------------------------
-- UP
function btn_up(e, param)
	local n1 = btn.name
	local n2 = param.name
	local p  = btn[n1].p[n2]
	local bt = btn.cursor
	if bt then
		local v = getBtnInfo(bt)
		if v.up then
			btn_nonactive(bt)
			btn_active(v.up, 'up')
			bt = v.up
		end
	elseif p.def then
		btn_active(p.def, 'up')
		bt = p.def
	end
	if bt and not flg.dlg then btn_actcursor(bt) end
end
----------------------------------------
-- DW
function btn_down(e, param)
	local n1 = btn.name
	local n2 = param.name
	local p  = btn[n1].p[n2]
	local bt = btn.cursor
	if bt then
		local v = getBtnInfo(bt)
		if v.dw then
			btn_nonactive(bt)
			btn_active(v.dw, 'dw')
			bt = v.dw
		end
	elseif p.def then
		btn_active(p.def, 'dw')
		bt = p.def
	end
	if bt and not flg.dlg then btn_actcursor(bt) end
end
----------------------------------------
-- LT/RT/UP/DWカーソル位置を保存
function btn_actcursor(bt)
	local name = btn.name
	if not flg.dlg and bt ~= -1 then
		if bt then	btn[name].actcursor = bt
		else		btn[name].actcursor = nil end

	-- 復帰
	elseif bt == -1 then
		local bt = btn[name].actcursor
		if bt then btn_active2(bt) end
	end
end
----------------------------------------
-- 現在の値を取得
function getbtn_actcursor()
	local r = nil
	local name = btn.name
	if btn[name] and btn[name].actcursor then r = btn[name].actcursor end
	return r
end
----------------------------------------
-- ボタン処理
----------------------------------------
-- ボタンの処理を自動判定
function btn_change(p)
	local bt = btn.cursor
	if bt and get_gamemode('ui2', bt) then
		se_ok()
		local t = getBtnInfo(bt)
		local sw = {
			mark	= function(p)	config_markclick(bt) end,						-- config専用
			check   = function(p)	check_change(bt) end,							-- checkbox
			single  = function(p)	single_change(bt) btn_active2(bt) flip() end,	-- singleボタン(アクティブにして返す)
			toggle  = function(p)	toggle_change(bt) end,							-- トグルボタン
			xslider = function(p)	sliderX(p) end,									-- 横スライダー
			yslider = function(p)	sliderY(p) end,									-- 縦スライダー
		}
		if t.com and sw[t.com] then
			sw[t.com](p)
		else
			sysmessage(bt, "には何も登録されていません", t.com)
		end
	end
end
----------------------------------------
-- チェックボックス入れ替え
function check_change(name)
	if get_gamemode('ui2', name) then
		local v = getBtnInfo(name)
		local p = loadBtnData(v.def)
		local f = tn(v.p1) or 0
--		if p == 0 then	p = 1 tag{"lyprop", id=(v.idx..".0"), clip=(v.clip_c)}
--		else			p = 0 tag{"lyprop", id=(v.idx..".0"), clip=(v.clip)} end
		if p == f then	tag{"lyprop", id=(v.idx..".2"), visible="1"}
		else			tag{"lyprop", id=(v.idx..".2"), visible="0"} end
		p = p == 0 and 1 or 0
		saveBtnData(v.def, p)

		-- p4に関数名があれば呼び出し
		if v.p4 then tag{"calllua", ["function"]=(v.p4), name=(name)} end
		flip()
	end
end
----------------------------------------
-- シングルボタン入れ替え
function single_change(name)
	if get_gamemode('ui2', name) then
		local v = getBtnInfo(name)
		local p = loadBtnData(v.def) == 0 and 1 or 0
		saveBtnData(v.def, p)
		setBtnStat(name, "single")

		-- p4に関数名があれば呼び出し
		if v.p4 then tag{"calllua", ["function"]=(v.p4), name=(name)} end
		flip()
	end
end
----------------------------------------
-- トグル入れ替え
function toggle_change(name)
	if get_gamemode('ui2', name) then
		local t = getBtnInfo(name)
		local part = t.p2
		local save = nil
		if getBtnStat(name) then
			setBtnStat(name, nil)	-- 自分 enable
			setBtnStat(part, t.def)	-- 相棒 disable
			btn_clip(name, 'clip_a')
			btn_clip(part, 'clip_c')
--			btn_yoyo(name, true)
--			btn_yoyo(part)
			btn.cursor = name
		else
--			btn_yoyo(name)
--			btn_yoyo(part, true)
			btn_clip(name, 'clip_c')
			btn_clip(part, 'clip_a')
			setBtnStat(name, t.def)	-- 自分 disable
			setBtnStat(part, nil)	-- 相棒 enable
			btn.cursor = part
		end
		flip()

		-- 保存
		if t.def and t.p1 then saveBtnData(t.def, tn(t.p1)) end

		-- 入れ替え
		local t = getBtnInfo(btn.cursor)
		if t.over then tag{"calllua", ["function"]=(t.over), name=(t.name)} flip() end
		if t.p4   then tag{"calllua", ["function"]=(t.p4)  , name=(t.name)} flip() end
	end
end
----------------------------------------
-- btn color
function btn_clip(name, clip)
	local t1 = { a=1, c=1, d=1 }
	local t2 = { e=4, f=5, g=6, h=7 }
	local v  = getBtnInfo(name)
	local nm = clip or "clip"
	local cl = v[nm]
	if not cl then
		local bt = "clip_"..nm
		if t1[nm] and v[bt] then
			cl = v[bt]
		elseif t2[nm] then
			local no = t2[nm]
			if v.dir == "width" then cl = (v.cx + v.cw * no)..","..v.cy..","..v.cw..","..v.ch
			else					 cl = v.cx..","..(v.cy + v.ch * no)..","..v.cw..","..v.ch end
		end
	end
	tag{"lyprop", id=(v.idx..'.0'), clip=(cl)}
end
----------------------------------------
-- 横スライダー
----------------------------------------
-- 横スライダー／分岐
function sliderX(p)
	local bt = btn.cursor
	if p.click or tn(p.key) == 1 then slider_clickX(e, p)
	elseif bt then xslider_add(bt, 10)
	end
end
----------------------------------------
-- 横スライダー／クリック処理
function slider_clickX(e, param)
	local name = param.btn or param.key
	if get_gamemode('ui2', name) and not flg.sliderdrag then
		local tbl = getBtnInfo(name)
		local pos = e:getMousePoint()
		local pin = math.floor(tbl.p2/2)

		-- 座標算出
		local x = pos.x - tbl.x - pin
		local m = tbl.w - tbl.p2
		local p = percent(x, m)

		-- pin移動
		local id = tbl.idx..ex.pinid
		if p < 0 then x,p = 0,0 elseif p > 100 then x,p = m,100 end
		tag{"lyprop", id=(id), left=(x)}

		-- 保存
		local old = nil
		if tbl.def then old = saveBtnData(tbl.def, p) end

		-- p4に関数名があれば呼び出し
		if tbl.p4 then tag{"calllua", ["function"]=(tbl.p4), name=(name), p=(p), old=(old)} end
		flip()
	end
end
----------------------------------------
-- 横スライダー／ドラッグ処理
function slider_dragX(e, param)
	local name = param.key
	if get_gamemode('ui2', name) then
		local id  = param.id
		local tbl = getBtnInfo(name)

		-- get_layer_info
		tag{"var", name="t.ly", system="get_layer_info", id=(id)}
		local x = tonumber(e:var("t.ly.left"))
		local m = tbl.w - tbl.p2
		local p = percent(x, m)

		-- 保存
		local old = nil
		if tbl.def then old = saveBtnData(tbl.def, p) end

		-- p4に関数名があれば呼び出し
		if tbl.p4 then tag{"calllua", ["function"]=(tbl.p4), name=(name), p=(p), old=(old)} end
		flip()
	end
end
----------------------------------------
-- 横スライダー／加算処理
function xslider_add(name, sub)
	if get_gamemode('ui2', name) then
		local t   = getBtnInfo(name)
		local id  = getBtnID(name)..ex.pinid
		local add = conf[t.def]
		add = add + sub
		if add > 100 then add = 100
		elseif add < 0 then add = 0 end

		-- 保存
		if t.def then saveBtnData(t.def, add) end

		local p = repercent(add, t.w - t.p2)
		tag{"lyprop", id=(id), left=(p)}

		-- p4に関数名があれば呼び出し
		if t.p4 then tag{"calllua", ["function"]=(t.p4), name=(name), p=(p)} end
		flip()
	end
end
----------------------------------------
-- 横スライダー／ピン位置を移動する
function xslider_pin(name, num)
	if get_gamemode('ui2', name) then
		local t  = getBtnInfo(name)
		local id = t.idx..ex.pinid
		local p  = repercent(num, t.w - t.p2)
		tag{"lyprop", id=(id), left=(p)}
	end
end
----------------------------------------
-- 縦スライダー
----------------------------------------
-- 縦スライダー／分岐
function sliderY(p)
	local bt = btn.cursor
	if p.click or tn(p.key) == 1 then slider_clickY(e, p)
	elseif bt then yslider_add(bt, 10)
	end
end
----------------------------------------
-- 縦スライダー／クリック処理
function slider_clickY(e, param)
	local name = param.btn or param.key
	if get_gamemode('ui2', name) and not flg.sliderdrag then
		local tbl  = getBtnInfo(name)
		local pos  = e:getMousePoint()
		local piny = math.floor(tbl.p2/2)

		-- 座標算出
		local y = pos.y - tbl.y - piny
		local m = tbl.h - tbl.p2
		local p = percent(y, m)

		-- pin移動
		local id = tbl.idx..ex.pinid
		if p < 0 then y,p = 0,0 elseif p > 100 then y,p = m,100 end
		tag{"lyprop", id=(id), top=(y)}

		-- 保存
		local old = nil
		if tbl.def then old = saveBtnData(tbl.def, p) end

		-- p4に関数名があれば呼び出し
		if tbl.p4 then tag{"calllua", ["function"]=(tbl.p4), name=(name), p=(p), old=(old)} end
		flip()
	end
end
----------------------------------------
-- 縦スライダー／ドラッグ処理
function slider_dragY(e, param)
	local name = param.key
	if get_gamemode('ui2', name) then
		local id  = param.id
		local tbl = getBtnInfo(name)

		-- get_layer_info
		tag{"var", name="t.ly", system="get_layer_info", id=(id)}
		local y = tonumber(e:var("t.ly.top"))
		local m = tbl.h - tbl.p2
		local p = percent(y, m)

		-- 保存
		local old = nil
		if tbl.def then old = saveBtnData(tbl.def, p) end

		-- p4に関数名があれば呼び出し
		if tbl.p4 then tag{"calllua", ["function"]=(tbl.p4), name=(name), p=(p), old=(old)} end
		flip()
	end
end
----------------------------------------
-- 縦スライダー／加算処理
function yslider_add(name, sub)
	if get_gamemode('ui2', name) then
		local t   = getBtnInfo(name)
		local id  = getBtnID(name)..".10"
		local add = conf[t.def]
		add = add + sub
		if add > 100 then add = 100
		elseif add < 0 then add = 0 end

		-- 保存
		if t.def then saveBtnData(t.def, add) end

		local p = repercent(add, t.h - t.p2)
		tag{"lyprop", id=(id), top=(p)}

		-- p4に関数名があれば呼び出し
		if t.p4 then tag{"calllua", ["function"]=(t.p4), name=(name), p=(p)} end
		flip()
	end
end
----------------------------------------
-- 縦スライダー／ピン位置を移動する
function yslider_pin(name, num)
	if get_gamemode('ui2', name) then
		local t  = getBtnInfo(name)
		local id = t.idx..".10"
		local p  = repercent(num, t.y - t.p2)
		tag{"lyprop", id=(id), top=(p)}
	end
end
----------------------------------------
-- draggable書き換え
function sliderdrag_stat(no)
	local nm = btn.name
	if btn[nm] then
		local id = btn[nm].id
		for k, p in pairs(btn[nm].p) do
			if type(p) == "table" and (p.com == 'xslider' or p.com == 'yslider') then
				tag{"lyprop", id=(id..p.id..ex.pinid), draggable=(no)}
			end
		end

		-- 1でボタン復帰
		if no == 1 then btn_actcursor(-1) end
	end
end
----------------------------------------
-- スライダーdrag開始 / マルチタッチ解除
function slider_dragin(e, p)
	local ky = p.key
	e:setUseMultiTouch(1)
	flg.sliderdrag = ky
end
----------------------------------------
-- スライダーdrag終了 / マルチタッチを3に制限
function slider_dragout(e,p)
	e:setUseMultiTouch(3)
end
----------------------------------------
-- 
----------------------------------------
-- ボタンのp1を使用してietを呼び出す
function btn_calliet(e, p)
	local bt = p.btn
	local v  = getBtnInfo(bt)
	local p1 = v.p1
	if p1 then
		local px = "system/extend/"..p1
		eqtag{"call", file=(px)}
	else
		message("警告", "p1が設定されていませんでした")
	end
end
----------------------------------------
-- ボタンステータス変更 / 全体
function btnstat(i, m)
	local id	= i or "500"
	local mode	= m or "disable"
	tag{"lyevent", id=(id), type="click",    mode=(mode)}
	tag{"lyevent", id=(id), type="rollover", mode=(mode)}
	tag{"lyevent", id=(id), type="rollout",  mode=(mode)}
end
----------------------------------------
-- ボタンblink
function btn_blink(p, com)
	if getBtnThreshold(p, "blink") then
		local id = p.idx..ex.blinkid
		if com == "stop" then
			tag{"lytweendel", id=(id)}
			tag{"lyprop", id=(id), alpha="0"}
		else
			local al = getBtnThreshold(p, "alpha") or 40
			systween{ id=(id), alpha=("0,"..al), yoyo="-1", time=(ex.blinktime) }
		end
	end
end
----------------------------------------
-- ボタンデータ保存
function saveBtnData(nm, dt)
	local name = btn.name
	local old  = nil
	if loadBtnData(nm) ~= dt then
		local md = name
		if nm:find(".", 1, true) then
			local a = explode("%.", nm)
			md = a[1] or name
			nm = a[2] or nm
		end
--		message("save", name, nm, dt)
		if md == 'conf' or md == 'csub' then
			old = conf[nm]
			conf[nm] = dt
			btn.renew = true	-- 更新フラグ
		elseif md == "scr" then
			old = scr[name][nm]
			scr[name][nm] = dt
		else
			old = sys[name][nm]
			sys[name][nm] = dt
		end
	end
	return old
end
----------------------------------------
-- ボタンデータ読み込み
function loadBtnData(name)
	local r  = name
	local bn = btn.name
	if r:find(".", 1, true) then
		local a  = explode("%.", r)
		local md = a[1]
		local nm = a[2]
		local sw = {
			conf = function() return conf[nm] end,
			sys  = function() return  sys[nm] end,
			gscr = function() return gscr[nm] end,
			scr  = function() return  scr[bn][nm] end,
		}
		if sw[md] then r = sw[md]() end
	elseif bn == "conf" or bn == "csub" then
		r = conf[name]
	elseif sys[bn] then
		r = sys[bn][name]
	end

	-- check
	if not r then
		r = 0
		message("注意", name, "は設定されていないパラメータです")
	end
	return r
end
----------------------------------------
-- 更新があったか確認する
function checkBtnData()
	return btn.renew
end
----------------------------------------
-- ボタン無効／有効切り替え
function setBtnStat(n, s)
	local name = btn.name
	local v    = getBtnInfo(n) or {}
	if btn[name] and v.name then

		----------------------------------------
		-- single
		if s == "single" then
			local d  = v.def and loadBtnData(v.def)
			local p1 = v.p1
			local p2 = v.p2 ~= "1"

			-- disable
			if p2 and d == 0 or not p2 and d == 1 then
				tag{"lyprop", id=(v.idx..".0"), clip=(v.clip)}
				if p1 then setBtnStat(p1, "c") end
			-- enable
			elseif p2 and d == 1 or not p2 and d == 0 then
				tag{"lyprop", id=(v.idx..".0"), clip=(v.clip_c)}
				if p1 then setBtnStat(p1) end
			end

		----------------------------------------
		-- ２番目使用
		elseif s == "a" then
			tag{"lyprop", id=(v.idx..".0"), clip=(v.clip_a)}

		----------------------------------------
		-- disable
		elseif s then
			btn[name].dis[n] = s

			-- clip
			btn_clip(n, s)
			if v.com == "xslider" or v.com == "yslider" then tag{"lyprop", id=(v.idx..ex.pinid), visible="0"} end

		----------------------------------------
		-- enable
		else
			btn[name].dis[n] = nil
			tag{"lyprop", id=(v.idx..".0"), clip=(v.clip)}
			if v.com == "xslider" or v.com == "yslider" then tag{"lyprop", id=(v.idx..ex.pinid), visible="1"} end
		end
	else
		sysmessage("エラー", n, "ボタンがありませんでした")
	end
end
----------------------------------------
-- ボタン無効／有効情報取得
function getBtnStat(n)
	local name = btn.name
	local p = nil
	if btn[name] then
		p = btn[name].dis[n]
	else
		sysmessage("エラー", n, "ボタンがありませんでした")
	end
	return p
end
----------------------------------------
-- slider pinのclip取得
function getBtnPinClip(mode, p, flag)
	local r = nil
	local a = p.p2
	if mode == "x" then
		r = (flag and "0,0," or a..",0,")..a..","..p.ch
	else
		r = (flag and "0,0," or "0,"..a..",")..p.cw..","..a
	end
	return r
end
----------------------------------------
-- ボタンしきい値の特殊処理を取得
function getBtnThreshold(p, mode)
	local r  = nil		-- 戻り値
	local pin= nil		-- slider pinをclip処理する
	local hit= nil		-- 当たり判定処理
	local bli= nil		-- blink
	local al = p.flag
	if type(al) == "string" then
		if al:find("pin")	then pin = true end
		if al:find("hit")	then hit = true end
		if al:find("blink")	then bli = true end

		-- 英字は削除
		al = tn(al:gsub("[a-z|]*", ""))
	end
	if al and al < 0 then hit = true al = nil end

	-- 返す値の処理
	local sw = {
		alpha = function() r = al end,
		blink = function() r = bli end,
		pin   = function() r = pin end,
		hit   = function() r = hit end,
	}
	if mode and sw[mode] then sw[mode]() else r = { alpha=(al), pin=(pin), hit=(hit), blink=(bli) } end
	return r
end
----------------------------------------
-- ボタンの有無確認
function checkBtnExist(n)
	local r = nil
	local name = btn.name
	if btn[name] and btn[name].p[n] then r = true end
	return r
end
----------------------------------------
-- ボタン情報取得
function getBtnInfo(n)
	local name = btn.name
	local p = {}
	if btn[name] and btn[name].p[n] then
		p = btn[name].p[n]
		p.path= btn[name].p[1]
		p.idx = p.id and btn[name].id..p.id
		p.dis = btn[name].dis[n]
	else
		sysmessage("エラー", n, "ボタンがありませんでした")
	end
	return p
end
----------------------------------------
-- ボタンID取得
function getBtnID(n)
	local name = btn.name
	local p = "error"
	if btn[name] and btn[name].p[n] then
		p = btn[name].id..btn[name].p[n].id
	else
		sysmessage("エラー", n, "ボタンがありませんでした")
	end
	return p
end
----------------------------------------
