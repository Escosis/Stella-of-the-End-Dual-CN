----------------------------------------
-- 
----------------------------------------
-- 専用trans
function siglus_trans(id, p)
--[[
	local tm = p.time or p.fade or "bg_fade"
	local md = p.rule or ""
	if init[tm] then tm = init[tm] end

	local sw = {

	-- クロス爆発ブラー
	sig_240 = function()
		tag{"lyprop", id=(id), anchorx=(game.ax), anchory=(game.ay)}
		tween{ id=(id), zoom="100,200,100", time=(tm / 2), ease="none" }
		flip()
	end,

	-- ズーム的な演出
	sig_250 = function()
		tag{"lyprop", id=(id), anchorx=(game.ax), anchory=(game.ay)}
		tween{ id=(id), zoom="100,150", time=(tm), ease="none" }
		flip()
	end,

	}
	if sw[md] then sw[md]() end
]]
end
----------------------------------------
-- 
----------------------------------------
-- quake
function user_quake(id, p)
	local md = p.dir2
	local lp = (p.count - 1) * 2 if lp < 0 then lp = -1 end
	local tm = p.time / 2
	local sz = p.power
	local hs = math.floor(sz / 2)

	local func = function(tm)
		local t1 = math.floor(tm / 2)
		local t2 = math.floor(tm / 2)
		return t1, t2
	end

	-- move
	local sw = {

	-- screen.quake[0].start(1, @time, @count, 0, @start_order, @end_order, [$$pos_convert_y(@power), 0])
	-- screen.quake[1].start(1, @time - 50, @count, 0, @start_order, @end_order, [$$pos_convert_x(@power), 6])
	wh = function()
		local t1, t2 = func(tm)
		tag{"tweenset"}
		tween{ id=(id), y=(    "0,"..-hs), time=(t1), ease="inout" }
		tween{ id=(id), y=(-hs..",".. hs), time=(t2), ease="inout", yoyo=(lp) }
		tween{ id=(id), y=( hs..",0"    ), time=(t1), ease="inout" }
		tag{"/tweenset"}
		local t1, t2 = func(tm - 50)
		tag{"tweenset"}
		tween{ id=(id), x=(    "0,"..-hs), time=(t1), ease="inout" }
		tween{ id=(id), x=(-hs..",".. hs), time=(t2), ease="inout", yoyo=(lp) }
		tween{ id=(id), x=( hs..",0"    ), time=(t1), ease="inout" }
		tag{"/tweenset"}
	end,

	-- 縦
	-- screen.quake[0].start(1, @time, @count, 0, @start_order, @end_order, [$$pos_convert_y(@power), 0])
	h = function()
		local t1, t2 = func(tm)
		tag{"tweenset"}
		tween{ id=(id), y=(    "0,"..-hs), time=(t1), ease="inout" }
		tween{ id=(id), y=(-hs..",".. hs), time=(t2), ease="inout", yoyo=(lp) }
		tween{ id=(id), y=( hs..",0"    ), time=(t1), ease="inout" }
		tag{"/tweenset"}
	end,

	-- 横
	-- screen.quake[1].start(1, @time, @count, 0, @start_order, @end_order, [$$pos_convert_x(@power), 6])
	w = function()
		local t1, t2 = func(tm)
		tag{"tweenset"}
		tween{ id=(id), x=(    "0,"..-hs), time=(t1), ease="inout" }
		tween{ id=(id), x=(-hs..",".. hs), time=(t2), ease="inout", yoyo=(lp) }
		tween{ id=(id), x=( hs..",0"    ), time=(t1), ease="inout" }
		tag{"/tweenset"}
	end,
	}
	if sw[md] then sw[md]() end

	-- wait
	local lp = p.count
	if p.wait and lp > 0 then
		local wa = tm * lp
		eqwait(wa)
	end
end
----------------------------------------
function user_exkoe()
	local no = flg.exkoe or 1
	local bl = scr.ip.block
	local z  = ast[bl].text.vo[no]
	flg.exkoe = no + 1

	-- play
	sesys_voplay(z)
end
----------------------------------------
-- コンフィグ・サウンドのキャラ別音声開放用
function user_cfg_chr(p)
	local nm = "g."..p.mode
	local no = p.no
	local od = tn(get_eval(nm))
	if no > od then
		set_eval(nm.."="..no)	-- 指定値以下のときの通った場合のみ指定値に。
	end
end
----------------------------------------
-- 起動
----------------------------------------
-- blandlogo
function user_brandlogo(p)
	local id01 = "logo.1"
	local id02 = "logo.2"
	local id03 = "logo.3"

	local tm = 350
	lyc2{ id=(id01), file=(":ui/"..p.file) }
	tag{"video", id=(id02), file=":ani/ef_monitor01_on.ogv" }

	tag{"video", id=(id03), file=":ani/ef_warning.ogv" }
	tag{"lyprop", id=(id03), alpha="180", xscale="200", yscale="200", visible="0", layermode="screen", anchorx="0", anchory="0"}

	sesys_se{ file="se010", path=":se/" }

	estag("init")
	estag{"uitrans", tm}
	estag{"lyprop", id=(id02), visible="0"}
	estag{"lyprop", id=(id03), visible="1"}
	estag{"uitrans", 100}
	estag{"eqwait", 8000}
	estag{"sesys_se", { file="se011", path=":se/" }}
	estag{"video", id=(id03), file=":ani/ef_monitor02_off.ogv" }
	estag{"uitrans", 0}
	estag{"lyprop", id=(id01), visible="0"}
	estag{"uitrans", 1500}
	estag{"lydel2", "logo"}
	estag()
end
----------------------------------------
-- 起動確認
function siglus_startup()
	if siglus_checkpuroro() then
		lydel2(2)
		title_start2("gamestart")
	end
end
----------------------------------------
-- プロローグチェック
function siglus_checkpuroro()
	return tn(get_eval("g.puroro")) == 0
end
----------------------------------------
-- titleボタンを塞ぐ
function siglus_titlebtn(bt, nm)
	if siglus_checkpuroro() then
		setBtnStat(bt , nm or 'c')
	end
end
----------------------------------------
-- 
----------------------------------------
-- autosave
function user_autosave(p)
	local nx = string.format("%02d", p.no)
	flg.autothumb = "auto_thumb"..nx
	scr.autoscript = "chap"..nx
	sv.autosave("asave")
end
----------------------------------------
