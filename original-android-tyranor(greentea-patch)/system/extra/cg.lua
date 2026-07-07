----------------------------------------
-- おまけ／CG
----------------------------------------
-- CG初期化
function exf.cginit()

	if not appex.cgmd then appex.cgmd = {} end

	-- 強制開放
	local ex = "extra_cgopen"
	if _G[ex] then _G[ex]() end

	-- CG取得
	local stm = 0
	local stc = 0
	for set, v in pairs(csv.extra_cgmode) do
		local p = v[1]
		local n = v[2]
		local m = table.maxn(v) - 2

		-- 差分の開き具合を確認しておく
		local o = 0
		for i=1, m do
			local nm = v[i + 2]
			if gscr.ev[nm] then o = o + 1 end
		end

		-- 保存
		local fl = gscr.evset[set]
		if not appex.cgmd[p]	then appex.cgmd[p] = {} end
		if not appex.cgmd[p][n] then appex.cgmd[p][n] = { set=(set), file=(set), open=(o), max=(m), tbl=(v), flag=(fl) } end
		if fl then stc = stc + 1 end
		stm = stm + 1
	end

	-- パーセント
--	local px = stc == stm and 100 or percent(stc, stm)
--	exf.percent("500.nm", px, "num01")

	-- 各ページのボタン数
	local mx = appex.cgmd.pagemax
	for i, v in ipairs(appex.cgmd) do
		appex.cgmd[i].bmax = #v
		appex.cgmd[i].pmax = math.ceil(#v / mx)
	end

	-- cgcg切り替えリスト登録
	if init.extra_cgcglbrb == "on" then
		local z  = {}
		local ct = 1
		for ch, p in ipairs(appex.cgmd) do
			for pg, v in ipairs(p) do
				if v.open > 0 then
					z[ct] = { char=(ch), page=(pg) }
					appex.cgmd[ch][pg].cgcgcount = ct	-- リストにも保存
					ct = ct + 1
				end
			end
		end
		appex.cgmd.cgcgbuff = z
	end

	-- thumb
	e:include(":ui/extra/thumb.ipt")
end
----------------------------------------
-- ページ生成
function exf.cgpage()
	local p, page, char = exf.getTable()
	local px = p.p

	-- 切り替え
	local fx = char < 5
	local zz = fx and "a" or "b"
	local z2 = fx and "b" or "a"
	local nn = fx and "btn" or "cg"
	local cl = fx and 'c'
	local max= fx and 6 or px.pagemax
	tag{"lyprop", id=("500."..zz), visible="1"}
	tag{"lyprop", id=("500."..z2), visible="0"}
	setBtnStat("char00", cl)

	-- thumb / mask
	local mspx = get_uipath()..'extra/'
	local thid = px.p1 or 5		-- thumb id
--	local none = isFile(mspx.."nonecgmd.png") and mspx.."nonecgmd" or isFile(mspx.."none.png") and mspx.."none"
--	local mask = isFile(mspx.."maskcgmd.png") and mspx.."maskcgmd" or isFile(mspx.."mask.png") and mspx.."mask"
	local none = mspx.."none_"..zz

	-- ページ本体
	if max then
		-- page
		local hd = p.head or 0
		local s  = appex.cgmd.slider
		if s and s.no then hd = s.no * s.w end

		-- loop
		for i=1, max do
			local mv = px[char][hd + i]
			local nm = nn..string.format("%02d", i)
			local id = getBtnID(nm)

			-- ボタン
			if not mv then
				tag{"lyprop", id=(id), visible="0"}
				setBtnStat(nm, 'c')
			else
				tag{"lyprop", id=(id), visible="1"}
				setBtnStat(nm, nil)

				local idt = id.."."..thid
				if mv.flag then
					local ff = ipt_thumb[mv.file] or "_th_"..mv.file
					lyc2{ id=(idt), file=(":thumb/"..ff), x=(px.tx), y=(px.ty), mask=(mask)}
				elseif none then
					lyc2{ id=(idt), file=(none), x=(px.tx), y=(px.ty), mask=(mask)}
				else
					lydel2(idt)
				end
			end
		end

		----------------------------------------
		-- ボタン切り替え
		local md = appex.cgmd.md or "none"

		-- ページ番号切り替え
		if md:find("page") then
--			exf.pageno("no01", page)
--			exf.pageno("no02", px[char].pmax)
			for i=1, px[char].pmax do
				local nm = "page"..string.format("%02d", i)
				local c  = i == page and 'c'
				setBtnStat(nm, c)
			end
		end

		-- キャラ切り替え
		if md:find("char") then
			for i=1, #px do
				local nm = "char"..string.format("%02d", i)
				local c  = i == char and 'c'
				setBtnStat(nm, c)
			end
		end

		-- page pin
		local p1 = getBtnInfo('pin01')
		local p2 = getBtnInfo('pin02')
		if fx then
			local v1 = getBtnInfo('char00')
			local v2 = getBtnInfo('char0'..char)
			tag{"lyprop", id=(p1.idx), left=(p1.x + v1.x), top=(p1.y + v1.y)}	-- char
			tag{"lyprop", id=(p2.idx), left=(p2.x + v2.x), top=(p2.y + v2.y)}	-- page
		else
			local v1 = getBtnInfo('char0'..char)
			local v2 = getBtnInfo('page0'..page)
			tag{"lyprop", id=(p1.idx), left=(p1.x + v1.x), top=(p1.y + v1.y)}	-- char
			tag{"lyprop", id=(p2.idx), left=(p2.x + v2.x), top=(p2.y + v2.y)}	-- page
		end

		-- slider pos
		if md == "slider" then
			exf.sliderpos()
		end
	end
end
----------------------------------------
--
----------------------------------------
function cgmode_over(e, p)
	local bt = p.name
	local v  = bt and getBtnInfo(bt)
	if v then
		local nm = v.p3
		local z  = csv.mw[nm]
		local id = v.idx..'.'..z.id
		local px = get_uipath(z.file)
		lyc2{ id=(id), file=(px), x=(z.x), y=(z.y), clip=(z.clip) }
	end
end
----------------------------------------
function cgmode_out(e, p)
	local bt = p.name
	local v  = bt and getBtnInfo(bt)
	if v then
		local nm = v.p3
		local z  = csv.mw[nm]
		local id = v.idx..'.'..z.id
		lydel2(id)
	end
end
----------------------------------------
-- 
----------------------------------------
-- CG表示
function exf.cgview(no)
	local p, pg, ch = exf.getTable()
	local s  = appex.cgmd.slider or {}
	local hd = s.no and s.no * s.w or p.head or 0
	local z  = p.p[ch][hd + no]

	-- 下処理
	local c = 0
	flg.excgbuff = {}
	for i=1, z.max do
		local n = z.tbl[i+2]
		if gscr.ev[n] then
			table.insert(flg.excgbuff, n)
			c = c + 1
		end
	end
	flg.excgbuff.no    = no		-- 押されたボタン番号
	flg.excgbuff.count = 1		-- 差分カウンタ
	flg.excgbuff.max   = c		-- 差分最大数
	flg.excgbuff.set   = z.set	-- セット

	-- cursor out
	local bt = btn.cursor
	if bt then
		btn_out(e, { key=(bt) })
		exf.cgcursor = bt
	end

	-- uiあればcgcg設置
	local v  = lang.ui_cgcg
	local nm = v and v[2]
	if nm then
		-- 設置
		csvbtn3("cgcg", "700", v)
		flg.cgcg = true

		-- text check
		local fo = lang.font[nm]
		if fo then
			flg.cgcgfont = nm
			extra_cgcgtext(true)	-- text設置
		elseif nm == "img" then
			flg.cgcgfont = nm
		end

		-- on/off
		local c = gscr.cgcgbtn and 0 or 1
		tag{"lyprop", id="700.cg", visible=(c)}
	else
		flg.btnstop = true			-- ボタン封じ
	end

	-- 呼び出し
	e:tag{"call", file="system/ui.asb", label="cgviewer"}
end
----------------------------------------
-- cgcg削除
function extra_cg_viewerdel()
	if flg.cgcg then
		extra_cgcgtext()	-- text
		delbtn('cgcg')
		btn.name = "extr"
		flg.cgcgfont = nil
		flg.cgcg = nil
	end

	-- cgcg list
	if init.extra_cgcglbrb == "on" then
		exf.cgpage()
	end
end
----------------------------------------
-- cg表示終了
function extra_cg_viewerexit()
--	exf.bgmrestart()
	flg.keylist = nil
	flg.btnstop = nil
	flg.advdrag = nil
	flg.upedge = nil
	button_autoactive()		-- windows / cursor check

	-- カーソル復帰
	local bt = exf.cgcursor
	if bt and game.cs then btn_active2(bt) flip() end
	exf.cgcursor = nil
end
----------------------------------------
-- text
function extra_cgcgtext(flag)
	local func = function(no)
		return string.format("%02d", no)
	end

	----------------------------------------
	local imgnum = function(no, bt)
		local v  = getBtnInfo(bt)
		local id = v.idx
		local cl = (v.cw * no + v.cx)..","..v.cy..","..v.cw..","..v.ch
		tag{"lyprop", id=(id), clip=(cl)}
	end

	----------------------------------------
	local nm = flg.cgcgfont
	local id = "700.cg.text"
	if nm == "img" then
		local v  = flg.excgbuff
		local ct = v.count or 'x'
		local mx = v.max or #v
		if checkBtnExist("no99") then
			local a = NumToGrph(ct)
			local b = NumToGrph(mx)
			imgnum(a[1], "no10")
			imgnum(a[2], "no11")
			imgnum(b[1], "no20")
			imgnum(b[2], "no21")
		end
	elseif nm then
		if flag then
			local tx = func(ct).." / "..func(mx)
			ui_message(id, { nm, text=(tx) })
		else
			ui_message(id)
		end
	end
end
----------------------------------------
-- cgcg char/page/noを返す
function extra_cgcg_getchpg(add)
	local p, pg, ch = exf.getTable()
	local hd = p.head or 0
	local no = flg.excgbuff.no
	local z  = p.p[ch][hd + no]
	local ct = z.cgcgcount

	-- 加算する
	local b  = appex.cgmd.cgcgbuff
	if add then
		local mx = #b
		ct = ct + add
		if ct > mx then ct = 1 elseif ct < 1 then ct = mx end
	end

	-- 取り出す
	local z = b[ct]
	if z then
		local mx = appex[p.name].pagemax
		local px = z.page - 1
		ch = z.char
		pg = math.floor(px / mx) + 1
		no = px % mx + 1
	else
		message("警告", "リストにないCGです", ch, pg)
	end
	return ch, pg, no
end
----------------------------------------
-- cgcgキー設定
function extra_cgcg_keys()
	local t1 = { 37, 39, 304, 306 }
	local t2 = { 37, 39, 304, 306, 116, 117, 118, 119, 260, 261, 262, 263 }
	local tx = game.cs and t2 or t1
	local r  = {}
	for i, v in ipairs(tx) do
		r[v] = "extra_cgcg_push"
	end

	-- cgcgのみ動作
	if flg.cgcg then
		r[32] = "extra_cgcg_space"		-- SPC on/off
	end
	flg.keylist = r
end
----------------------------------------
-- cgcg push
function extra_cgcg_push(e, p)
	local tx = {
		LT = -1,
		RT =  1,
		LB = -1,
		RB =  1,
		L2 = -10,
		R2 =  10,
	}
	extra_cgcg_keys()

	-- cgcg切り替え
	local bt = p.ui
	if init.extra_cgcglbrb == "on" and (bt == "LB" or bt == "RB") then
		local p = exf.getTable()
		local ch, pg, no = extra_cgcg_getchpg(tx[bt])
		appex[p.name].char = ch
		appex[p.name].page = pg
		tag{"return"}
		exf.cgview(no)

	-- 次へ/前へ
	elseif bt and tx[bt] then
		local ad = tx[bt]
		local v  = flg.excgbuff
		local c  = v.count + ad
		local m  = v.max or #v
		if c < 1 then c = 1 elseif c > m then c = m end
	 	flg.excgbuff.count = c
		e:tag{"return"}
		e:tag{"jump", file="system/ui.asb", label="cgviewer"}
	end
end
----------------------------------------
-- cgcg space(btn on/off)
function extra_cgcg_space()
	local id = "700.cg"
	local fl = gscr.cgcgbtn
	if fl then
		gscr.cgcgbtn = nil
		tag{"lyprop", id=(id), visible="1"}
	else
		gscr.cgcgbtn = true
		tag{"lyprop", id=(id), visible="0"}
	end

	-- 
	estag("init")
	estag{"extra_cgcg_keys"}
	estag{"uitrans"}
	if gscr.cgcgbtn then
		local bt = btn.cursor
		if bt then estag{"btn_nonactive", bt} end
	else
		estag{"button_autoactive"}
	end
	estag()
end
----------------------------------------
-- 
----------------------------------------
-- cg表示
function extra_cg_viewer()
	local v  = flg.excgbuff
	local s  = v.set
	local c  = v.count
	local id = "600.1"
	lyc2{ id="600.0", file=(init.black) }	--, alpha="192"}

	extra_cgcgtext(true)	-- text設置

	--
	local n = v[c]

	message("通知", c.."/"..v.max, n)

	-- 表示
	local tbl  = csv.cgscroll or {}
	local t    = tbl[n] or tbl[s] or {}
	local md   = t[1]
	local time = 300
	local rule = init.rule_cgmode

	-- 表示
	local image = function(p)
		local mx = #t
		if mx > 2 then
			for i=3, mx, 2 do
				local n1 = t[i]
				local n2 = t[i+1]
				if n1 and n2 then
					if n1 == "x" or n1 == "y" then p[n1] = mulpos(n2) else p[n1] = n2 end
				end
			end
		end
		readImage(id, p)
	end

	-- 振り分け
	local sw = {
		cg =	 function() image{ file=(n), path=":cg/" } end,
		aniipt = function() image{ file=(n), path=":ani/" } end,
		anime =  function() image{ file=(n), path=":ani/", movie=1, loop=0 } end,

		-- movie
		movie = function()	exf.movieplay(n) end,

		-- scroll
		scroll = function()
			local time = 30000
			tween{ id=(id), x=("0,-"..game.width), time=(time)}
			eqwait(time)
			eqtag{"lytweendel", id=(id)}
		end,

		-- staffroll
		staff = function() staffroll{ ch=(n) } end,
	}
	if sw[md] then
		sw[md]()
	elseif n then
		lydel2(id)
		local m = ':ev/'	--..s.."/"
		local h = n:sub(1, 2)
		if h == "bg" then m = ":bg/" end
		if h == "sd" then m = ":sd/"..s.."/" end

		-- scroll
		local x   = 0
		local y   = 0

		-- 特殊処理
		if e:isFileExists(m..n..".ipt") then
			local idx = id..".m.a"
			readImage(idx, { path=(m), file=(n) })
			tag{"lyprop", id=(idx), intermediate_render="1"}

			local i = ipt.base or {}
			x = i.x or 0
			y = i.y or 0
		else
			-- 表示
			local idx = id..".m.a"
			lyc2{ id=(idx), file=(m..n)}

			-- 中心に置く
			tag{"var", name="t.ly", system="get_layer_info", id=(idx), style="map"}
			local w = tn(e:var("t.ly.width"))
			local h = tn(e:var("t.ly.height"))
			local g = game
			if g.width  ~= w then x = math.floor(g.ax - w / 2) end
			if g.height ~= h then y = math.floor(g.ay - h / 2) end
			tag{"lyprop", id=(idx), left=(x), top=(y)}
		end

		-- time
		local tm = 10000
		local dl = 500
		local t2 = math.floor(tm / 2)
		local sw = {
			lr = function() systween{ id=(id), x=(-x..","..x), time=(tm), ease="none", delay=(dl)} end,	-- 左→右
			rl = function() systween{ id=(id), x=(x..","..-x), time=(tm), ease="none", delay=(dl)} end,	-- 右→左
			ud = function() systween{ id=(id), y=(-y..","..y), time=(tm), ease="none", delay=(dl)} end,	-- 上→下
			du = function() systween{ id=(id), y=(y..","..-y), time=(tm), ease="none", delay=(dl)} end,	-- 下→上

			-- 中心→上→下
			cud = function()
				tag{"tweenset"}
				systween{ id=(id), y=("0,"..-y)	 , time=(t2), ease="inout", delay="2000"}
				systween{ id=(id), y=(-y..","..y), time=(tm), ease="inout", yoyo="-1"}
				tag{"/tweenset"}
			end,

			-- drag
			drag = function()
				local w = game.width
				local h = game.height
				lyc2{ id="600.s", file=(init.black), alpha="0", draggable="1", dragarea=(-w..","..-h..","..w..","..h)}
				lyevent{ id="600.s", dragin="cgmode_draginit", drag="cgmode_drag", dragout="cgmode_dragout"}
				flg.upedge = true
				flg.cgmode = { x=0, y=0, w=(x), h=(y), idx=(id) }
				tag{"lyprop", id=(id), top=(no)}
			end,
		}
		if md and sw[md] then sw[md]() end

		-- 上下黒線
		if game.crop then
--			lyc2{id="1.-1", width="8", height="1", color="0xfff00000", y="-1", visible="0"}
			tag{"lyprop", id="600", top=(game.crop)}
		end
	end

	-- 
	if md ~= "movie" then
		extra_cgcg_keys()	-- cgcgキー設定
		e:tag{"var", name="t.trns" , data=(time)}
		e:tag{"var", name="t.rule" , data=(rule)}
	end
end
----------------------------------------
function extra_cg_check(e, p)
	local bt = exf.cgcgcursor or p.name or btn.cursor
	local v  = flg.excgbuff
	local s  = v.set
	local c  = v.count
	if flg.cgcg and bt then
		local t  = getBtnInfo(bt)
		local p1 = t.p1
		local p2 = tn(t.p2)

		-- add
		if p1 == "add" then
			local m = v.max or #v
			c = c + p2
			if c < 1 then c = 1 elseif c > m then c = m end
		 	flg.excgbuff.count = c
			e:tag{"var", name="t.check", data="0"}

		-- exit
		elseif p1 == "exit" then
			e:tag{"var", name="t.check", data="1"}
		end

	-- 次
	else
		local r = 0
		c = c + 1
		if c > v.max then r = 1 end
 		flg.excgbuff.count = c
 		flg.excgbuff.cgcgv = true
		e:tag{"var", name="t.check", data=(r)}
	end
	exf.cgcgcursor = nil
end
----------------------------------------
-- btn over
function extra_cgcg_over(e, p)
	local tb = { android=1, ios=1 }
	local bt = p.name
	local ox = game.os
	if bt and tb[ox] then exf.cgcgcursor = bt end
end
----------------------------------------
function cgmode_draginit(e, p)
	flg.advdrag = true
	flg.cgmode.m = e:getMousePoint()
end
----------------------------------------
function cgmode_drag(e, p)
	local m = e:getMousePoint()
	local v = flg.cgmode
	local w = v.w
	local h = v.h
	local x = v.x + m.x - v.m.x
	local y = v.y + m.y - v.m.y
	if x < w then x = w elseif x > -w then x = -w end
	if y < h then y = h elseif y > -h then y = -h end
	tag{"lyprop", id=(v.idx), left=(x), top=(y)}
	flip()
end
----------------------------------------
function cgmode_dragout(e, p)
	local m = e:getMousePoint()
	local v = flg.cgmode
	local w = v.w
	local h = v.h
	local a = m.x - v.m.x
	local b = m.y - v.m.y

	-- click
	if -10 < a and a < 10 and -10 < b and b < 10 then
		setexclick()		-- dummy click
		flg.upedge = nil
	else
		local x = v.x + a
		local y = v.y + b
		if x < w then x = w elseif x > -w then x = -w end
		if y < h then y = h elseif y > -h then y = -h end
		flg.cgmode.x = x
		flg.cgmode.y = y

		tag{"lyprop", id=(v.idx), left=(x), top=(y)}
		tag{"lyprop", id=(p.id) , left="0", top="0"}
		flip()
	end
	flg.advdrag = nil
end
----------------------------------------
