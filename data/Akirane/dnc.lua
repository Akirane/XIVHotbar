
-- Load and initialize the include file.
 xivhotbar_keybinds_job['Base'] = {
     
  -- Hotbar #1
    {'b 1 1', 'ja', 'Curing Waltz IV', 'stal', 'CW4', ''},
    {'b 1 2', 'ja', 'Divine Waltz', 'stal', 'DW', ''},
    {'b 1 2', 'ja', 'Haste Samba', 'me', 'HS'},
    {'b 1 3', 'ja', 'Box Step', 't', 'BS'},
    {'b 1 7', 'ja', 'Divine Waltz II', 'stal', 'DW2', ''},
    {'b 1 6', 'ja', 'Curing Waltz III', 'stal', 'CW3', ''},
    {'b 5 2', 'ja', 'Reverse Flourish', 'me', 'RF'},
    {'b 1 9', 'ja', 'Accomplice', 'stal', 'Acc.'},
    --{'b 1 10', 'gs', 'equip engaged', '', 'Norm.'},
    {'b 2 9', 'gs', 'equip engaged[\'Hybrid\']', '', 'Hybr.'},
    {'b 2 10', 'gs', 'equip engaged', '', 'Norm.'},
  -- Hotbar #2
    {'b 2 1', 'ws', 'Aeolian Edge', 't', 'A.E.'},
    --{'b 2 2', '/ct', 'Evisceration', 'stnpc', 'Evi.'},
    {'b 2 2', 'ws', 'savage blade', 't', 'SB'},
  {'b 2 3',  'ja', 'fan dance', 'me' ,'FanD'},
    {'b 2 4', 'ja', 'Bully', 'stnpc', 'Bully'},
    {'b 2 5', 'ja', 'Hide', 'me', 'Hide'},
    {'b 2 6', 'ja', 'Healing Waltz', 'stal', 'HW'},
    {'b 2 8', 'ws', 'Evisceration', 'stnpc', 'Evi.'},
    {'b 3 10', 'ws', 'Exenterator', 't', 'Ext.'},
  -- Hotbar #3
    {'b 4 1', 'ja', 'Feint', 'me', 'Feint'},
    {'b 4 2', 'ja', 'Conspirator', 'me', 'Cons.'},
    {'b 2 2', 'ws', 'Rudra\'s Storm', 't', 'RS'},
  {'b 4 7',  'ws', 'pyrrhic kleos', 't' ,'PC'},
  {'b 4 9',  'ja', 'reverse flourish', 'me' ,'RF'},
    {'b 4 10', 'ws', 'Mandalic Stab', 'stnpc', 'MB'},

    {'b 5 1', 'ja', 'Curing Waltz V', 'stal', 'CW5', ''},
    {'b 5 3', 'ja', 'Animated Flourish', 'stnpc', 'AF', ''},
    {'b 5 9', 'gs', 'equip engaged[\'ERegen\']', '', 'EReg.'},
    {'b 5 10', 'ct', '/send @all lua exec get_pt', '', 'exec'},

}

xivhotbar_keybinds_job['WAR'] = {
	{'b 3 1', 'ja', 'Warcry', 'me', 'Warcry'},
	{'b 3 2', 'ja', 'Berserk', 'me', 'Ber.'},
  {'b 3 3',  'ja', 'animated flourish', 'stnpc' ,'AF'},
    {'b 1 10', 'ja', 'Provoke', 'stnpc', ''},
}

xivhotbar_keybinds_job['NIN'] = {
  {'b 3 7', 'ma', 'utsusemi: ichi', 'me', 'U.Ich.'},
  {'b 3 1', 'ma', 'utsusemi: ni', 'me', 'U.Ni'},
  {'b 3 2', 'ma', 'Tonko: Ni', 'me','Invis'},
  {'b 3 3', 'ma', 'Monomi: Ichi', 'me', 'Sneak'}
}
xivhotbar_keybinds_job['DNC'] = {
    {'b 1 10', 'ja', 'Healing Waltz', 'stal', 'HW'},
    {'b 1 8', 'ja', 'Drain Samba ii', 'me', 'DS'},
    {'b 3 1', 'ja', 'Animated Flourish', 't', 'AF'},
    {'b 3 2', 'ja', 'Box Step', 't', 'Bx.St.'},
    {'b 3 3', 'ja', 'Spectral Jig', 'me', 'Spc.J.'},
    {'b 3 4', 'ja', 'Curing Waltz III', 'stal', 'Cw.III'},
    {'b 4 3', 'ja', 'Violent Flourish', 't', 'VF'},
}
xivhotbar_keybinds_job['SAM'] = {
    {'b 3 1', 'ja', 'Sekkanoki', 'me', ''},
    {'b 3 2', 'ja', 'Meditate', 'me', ''}
}

xivhotbar_keybinds_job['RUN'] = {
    {'b 1 8', 'ma', 'flash', 'stnpc', ''},
    {'b 3 1', 'ja', 'Lux', 'me', 'Lux'},
    {'b 3 2', 'ja', 'vallation', 'me', 'Val.'}
}

xivhotbar_keybinds_job['RDM'] = {
    {'b 1 8', 'ma', 'dispel', 't', 'Disp.'}
}

return xivhotbar_keybinds_job
