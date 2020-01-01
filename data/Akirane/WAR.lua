xivhotbar_keybinds_job['Base'] = {
  -- Battle hotbar
  -- Hotbar #1
  --{'f 1 2', 'ws',  'Steel Cyclone', 't', 'S.C'},
	{'f 1 2', 'ws',  'Fell Cleave', 't', 'FC'},
	{'f 1 3', 'ws',  'Raging Rush', 't', 'R.R'},
	{'f 1 4', 'ja',  'Provoke', 'stnpc', 'Pro.'},
	{'f 1 5', 's', 'waruharu follow akirane', '', 'Follow'},
	{'f 1 6', 's', 'waruharu dia ii akirane', '', 'Follow'},
	-- Hotbar #3
	{'f 3 1', 'ja',  'Retaliation', 'me', 'Ret.'},
	{'f 3 2', 'ja',  'Berserk', 'me', 'Ber.'},
	{'f 3 3', 'ja',  'Warcry', 'me', 'Wrcr.'},
	{'f 3 4', 'ja',  'Blood Rage', 'me', 'B.R.'},
	{'f 3 5', 'ws',  'Fell Cleave', 't', 'FC'},
	-- Hotbar #3 --
	{'f 4 1', 'ja',  'Boost', 'me', 'Boost'},
	{'f 4 1', 'ct', '/ htb summon Carbuncle','me', 'Carb.'},
	{'f 4 2', 'ct', '/ htb summon Ifrit','me', 'Ifrit.'},
}
xivhotbar_keybinds_job['Carbuncle'] = {
  {'f 1 1', 'pet',  'Healing Ruby II', 'stpc', 'HR'},
}
xivhotbar_keybinds_job['Ifrit'] = {
  {'f 1 1', 'pet',  'Flaming Crush', 'stnpc', 'FC'},
}

xivhotbar_keybinds_job['THF'] = {
}
return xivhotbar_keybinds_job
