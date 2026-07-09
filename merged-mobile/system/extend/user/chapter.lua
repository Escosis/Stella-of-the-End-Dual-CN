----------------------------------------
-- chapter
----------------------------------------
local ex = {}
----------------------------------------
ex.titletable = {
	time = 150,
	y = 5,
	h = 51,
	bt_start	= 182,
	bt_chap		= 263,
	bt_load		= 156,
	bt_conf		= 216,
	bt_extra	= 192,
	bt_exit		= 144,
}
----------------------------------------
-- 専用trans
function user_chapter()
	csvbtn3("ttl1", "500", lang.ui_chapter)
	user_chapbtn()
	screen_crop("500")
	uiopenanime("extr")
end
----------------------------------------
function user_chapbtn()
	local px = ":thumb/_cpt_th"
	local z  = gscr.vari
	local p  = getBtnInfo("line")
	local li = ":ui/"..p.file
	tag{"lyprop", id=(p.idx), visible="0"}

	-- loop
	local ct = 0
	for i=1, 21 do
		local nx = string.format("%02d", i)
		local v  = getBtnInfo("chap"..nx)
		local id = v.idx
		local nm = v.p2
		if tn(z[nm]) ~= 1 then
			tag{"lyprop", id=(id), visible="0"}
		else
			lyc2{ id=(id..".5"), file=(px..nx), x=(p.p1), y=(p.p2) }
			lyc2{ id=(id..".8"), file=(li), clip=(p.clip), x=(p.x), y=(p.y) }
			ct = i
		end
	end

	-- mask
	if ct > 1 and not gscr.clear then
		local v  = getBtnInfo(string.format("chap%02d", ct))
		local px = ":thumb/_cpt_th99"
		local id = v.idx
		lyc2{ id=(id..".5"), file=(px), x=(p.p1), y=(p.p2) }
	end
end
----------------------------------------
function user_chapclick(e, p)
	local v  = getBtnInfo(p.bt or p.btn)
	local p1 = v.p1
	local p2 = v.p2
	if p1 == "exit" then
		ReturnStack()	-- 空のスタックを削除
		se_cancel()

		-- 削除
--		titlepage = nil

		-- アニメーション
		estag("init")
		estag{"delbtn", 'ttl1'}		-- 削除
--		estag{"uitrans", 2000}
		estag{"title_init"}			-- titleへ
		estag()
	else
		se_start()
		lyc2{ id="zchapter", file=(init.white) }
		estag("init")
--		estag{"delbtn", 'ttl1'}		-- 削除
		estag{"title_start", p2}
		estag{"uitrans", 2000}
		estag()
	end
end
----------------------------------------
-- 
----------------------------------------
function user_titleover(e, p)
	local bt = p.name
	local v  = getBtnInfo(bt)
	local id = v.idx..".-1"
	local w  = v.w	-- mulpos(ex.titletable[bt])
	local h  = mulpos(ex.titletable.h)
	local y  = mulpos(ex.titletable.y)
	local tm = ex.titletable.time

	tag{"lytweendel", id=(id)}
	lyc2{ id=(id), width=(w), height=(h), y=(y), color="0x000000", anchorx="0", anchory=(h / 2) }
	systween{ id=(id), xscale="0,100", time=(tm) }
end
----------------------------------------
function user_titleout(e, p)
	local id = getBtnID(p.name)..".-1"
	local tm = ex.titletable.time
	tag{"lytweendel", id=(id)}
	systween{ id=(id), xscale="100,0", time=(tm) }
end
----------------------------------------
function user_extrapage(e, p)
	local v  = getBtnInfo(p.btn)
	local p2 = v.p2
	local mx = 4

	se_ok()
	local p, pg, ch = exf.getTable()
	local nm = p.name
	ch = ch + p2
	if ch < 1 then ch = mx elseif ch > mx then ch = 1 end
	appex[nm].char = ch				-- char保存
	extra_page()
	uiopenanime("extr")
end
----------------------------------------
-- ゲーム開始処理
function user_gamestart()
	-- ゲームクリアしていない場合はchapter2から
	local no = tn(get_eval("g.game_clear"))	-- <GAME_CLEAR>
	local fl = no == 0 and "chap02" or "gamestart"

	allkeyoff()				-- キー停止
	autoskip_disable()		-- autoskip停止
	bgm_stop{ time=2000 }	
	se_start()				

	local v  = getBtnInfo("bt_start")
	local tm = 300
	local id = v.idx
	local ix = id..".1"
	local iy = id..".-1"
	lyc2{ id=(ix), file=(":ui/"..v.file), clip=(v.clip) }
	systween{ id=(ix), time=(tm), alpha="255,0,255,0" }
	systween{ id=(iy), time=(tm), yscale="100,0", delay=(tm*2) }
	flip()

	local mv = "500.mv"
	estag("init")
	estag{"eqwait", (tm*4)}
	estag{"video", id=(mv), file=":ani/ef_monitor02_off.ogv"}
	estag{"flip"}
	estag{"eqwait", { video="1" }}
	estag{"title_start", fl}
	estag()
end
----------------------------------------
