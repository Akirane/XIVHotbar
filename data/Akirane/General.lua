
xivhotbar_keybinds_general['Root'] = {
    -- #1 Hotbar
	{'f 1 1', 'ct', '/htb mount crab', 'me', 'Crab'},
    {'f 1 7', 'item', 'Echo drops', 'me', 'Echo', 'echo'},
    {'f 1 8', 'item', 'Panacea', 'me', 'Pana', 'panacea'},
	{'f 1 9', 'item', "remedy",'me', 'Rem.', 'remedy'},
	{'f 1 10', 'item',  "Special Gobbiedial Key", 't', 'G.Key', 'gobbie'},

    -- #2 Hotbar
    {'f 2 1', 'ma', 'Joachim', 'me', 'Joa.'},
	{'f 2 2', 'ma', 'Mihli Aliapoh', 'me', 'MA'},
	{'f 2 3', 'ma', 'Ulmia', 'me', 'Ulmia'},
	{'f 2 4', 'ma', 'Kupofried', 'me', 'Kupof.'},
	{'f 2 5', 'ma', 'Zeid II', 'me', 'Zeid2'},
	{'f 2 6', 'ma', 'Koru-Moru', 'me', 'Koru'},
    {'f 2 7', 'ma', 'Qultada', 'me', 'Qul.'},
	{'f 2 8', 'ma', 'Yoran-Oran (UC)', 'me', 'Yoran'},
	{'f 2 9', 'ma', 'August', 'me', 'Aug'},

    {'b 6 1', 'ma', 'Joachim', 'me', 'Joa.'},
	{'b 6 2', 'ma', 'Mihli Aliapoh', 'me', 'MA'},
	{'b 6 3', 'ma', 'Ulmia', 'me', 'Ulmia'},
	{'b 6 4', 'ma', 'Kupofried', 'me', 'Kupof.'},
	{'b 6 5', 'ma', 'Zeid II', 'me', 'Zeid2'},
	{'b 6 6', 'ma', 'Koru-Moru', 'me', 'Koru'},
    {'b 6 7', 'ma', 'Qultada', 'me', 'Qul.'},
	{'b 6 8', 'ma', 'Yoran-Oran (UC)', 'me', 'Yoran'},
	{'b 6 9', 'ma', 'August', 'me', 'Aug'},
	{'b 6 10', 'ma', 'Selh\'teus', 'me', 'Sel'},

	{'f 3 7', 'item', "poison potion",'me', 'Poison.', 'poison'},
    {'f 3 8', 'gs', 'c toggle weapon','','TGWep'},
    {'f 3 9', 'gs', 'c toggle acc','','TGAcc'},
    --{'f 5 0', 'ct', '/refa all',nil,'Ref'},
}

xivhotbar_keybinds_general['Medicine'] = {
	{'f 1 7', 'item', 'Panacea','me', 'Panacea'},
	{'f 1 5', 'item', "Soldier's drink",'me', 'A. Pwr'},
	{'f 1 6', 'item', "Braver's drink",'me', 'Attr. Up'},
}

return xivhotbar_keybinds_general
