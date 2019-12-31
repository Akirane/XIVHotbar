
xivhotbar_keybinds_general['Root'] = {
    -- #1 Hotbar
	{'f 1 1', 'ct', '/htb mount Raptor', 'me', 'Rapt.'},
	-- {'f 1 2', 'ct', 'dismount', 'me', 'Dismnt.'},
	{'f 1 7', 'item', "Panacea",'me', 'Pana.'},
	{'f 1 8', 'item', "Remedy",'me', 'Rem.'},
	{'f 1 9', 'item', "echo drops",'me', 'Echo'},
	{'f 1 0', 'item',  "Special Gobbiedial Key", 't', 'G.Key'},
	{'f 3 7', 'item', "poison potion",'me', 'Poison.'},

    -- #2 Hotbar
    {'f 2 1', 'ma', 'Joachim', 'me', 'Joa.'},
	{'f 2 2', 'ma', 'Mihli Aliapoh', 'me', 'MA'},
	{'f 2 3', 'ma', 'Ulmia', 'me', 'Ulmia'},
	{'f 2 4', 'ma', 'Kupofried', 'me', 'Kupof.'},
	{'f 2 5', 'ma', 'Zeid II', 'me', 'Zeid2'},
	{'f 2 6', 'ma', 'Koru-Moru', 'me', 'Koru'},
    {'f 2 7', 'ma', 'Qultada', 'me', 'Qul.'},
	-- {'f 2 8', 'ma', 'Sylvie (UC)', 'me', 'Sylvie'},
	{'f 2 8', 'ma', 'Yoran-Oran (UC)', 'me', 'Yoran'},
    -- {'f 2 9', 'ma', 'Nashmeira II', 'me', 'Nash.'},

    --{'f 3 0', 'ma', 'Aquaveil', 'me', 'Aq.'},

    {'f 3 8', 'gs', 'toggle weapon','','TGWep'},
    {'f 3 9', 'gs', 'toggle acc','','TGAcc'},
}

xivhotbar_keybinds_general['Medicine'] = {
	{'f 1 7', 'item', 'Panacea','me', 'Panacea'},
	{'f 1 5', 'item', "Soldier's drink",'me', 'A. Pwr'},
	{'f 1 6', 'item', "Braver's drink",'me', 'Attr. Up'},
	--{'f 1 8', 'item', "Barbarian's Drink",'me', 'A. Pwr'}
	-- {'f 1 8', 'item', "Oracle's Drink",'me', 'M. Pwr'},
}

return xivhotbar_keybinds_general
