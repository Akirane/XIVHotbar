
-- Load and initialize the include file.
 xivhotbar_keybinds_job['Base'] = {
     
  -- Hotbar #1
    {'battle 1 1', 'ja', 'Curing Waltz IV', 'stal', 'CW4', ''},
    {'battle 1 2', 'ja', 'Divine Waltz', 'stal', 'DW', ''},
    {'battle 1 2', 'ja', 'Haste Samba', 'me', 'HS'},
    {'battle 1 3', 'ja', 'Box Step', 't', 'BS'},
    {'battle 1 7', 'ja', 'Divine Waltz II', 'stal', 'DW2', ''},
    {'battle 1 6', 'ja', 'Curing Waltz III', 'stal', 'CW3', ''},
    {'battle 5 2', 'ja', 'Reverse Flourish', 'me', 'RF'},
    {'battle 1 9', 'ja', 'Accomplice', 'stal', 'Acc.'},
    --{'battle 1 0', 'gs', 'equip engaged', '', 'Norm.'},
    {'battle 2 9', 'gs', 'equip engaged[\'Hybrid\']', '', 'Hybr.'},
    {'battle 2 0', 'gs', 'equip engaged', '', 'Norm.'},
  -- Hotbar #2
    {'battle 2 1', 'ws', 'Aeolian Edge', 't', 'A.E.'},
    --{'battle 2 2', '/ct', 'Evisceration', 'stnpc', 'Evi.'},
    {'battle 2 2', 'ws', 'savage blade', 't', 'SB'},
    {'battle 2 3', 'ja', 'Despoil', 't', 'Desp.'},
    {'battle 2 4', 'ja', 'Bully', 'stnpc', 'Bully'},
    {'battle 2 5', 'ja', 'Hide', 'me', 'Hide'},
    {'battle 2 6', 'ja', 'Healing Waltz', 'stal', 'HW'},
    {'battle 2 8', 'ws', 'Evisceration', 'stnpc', 'Evi.'},
    {'battle 3 0', 'ws', 'Exenterator', 't', 'Ext.'},
  -- Hotbar #3
    {'battle 4 1', 'ja', 'Feint', 'me', 'Feint'},
    {'battle 4 2', 'ja', 'Conspirator', 'me', 'Cons.'},
    {'battle 2 2', 'ws', 'Rudra\'s Storm', 't', 'RS'},
    {'battle 4 7', 'ws', 'Empyreal Arrow', 't', 'EA'},
    {'battle 4 9', 'ws', 'Mandalic Stab', 't', 'MB'},
    {'battle 4 0', 'ws', 'Mandalic Stab', 'stnpc', 'MB'},

    {'battle 5 1', 'ja', 'Curing Waltz V', 'stal', 'CW5', ''},
    {'battle 5 3', 'ja', 'Animated Flourish', 'stnpc', 'AF', ''},
    {'battle 5 9', 'gs', 'equip engaged[\'ERegen\']', '', 'EReg.'},
    {'battle 5 0', 'ct', '/send @all lua exec get_pt', '', 'exec'},

}

xivhotbar_keybinds_job['WAR'] = {
	{'battle 3 1', 'ja', 'Warcry', 'me', 'Warcry'},
	{'battle 3 2', 'ja', 'Berserk', 'me', 'Ber.'},
	{'battle 3 3', 'ja', 'Aggressor', 'me', 'Agg.'},
    {'battle 1 0', 'ja', 'Provoke', 'stnpc', ''},
}

xivhotbar_keybinds_job['NIN'] = {
  {'battle 3 7', 'ma', 'utsusemi: ichi', 'me', 'U.Ich.'},
  {'battle 3 1', 'ma', 'utsusemi: ni', 'me', 'U.Ni'},
  {'b 3 2', 'ma', 'Tonko: Ni', 'me','Invis'},
  {'b 3 3', 'ma', 'Monomi: Ichi', 'me', 'Sneak'}
}
xivhotbar_keybinds_job['DNC'] = {
    {'battle 1 0', 'ja', 'Healing Waltz', 'stal', 'HW'},
    {'battle 1 8', 'ja', 'Drain Samba ii', 'me', 'DS'},
    {'battle 3 1', 'ja', 'Animated Flourish', 't', 'AF'},
    {'battle 3 2', 'ja', 'Box Step', 't', 'Bx.St.'},
    {'battle 3 3', 'ja', 'Spectral Jig', 'me', 'Spc.J.'},
    {'battle 3 4', 'ja', 'Curing Waltz III', 'stal', 'Cw.III'},
    {'battle 4 3', 'ja', 'Violent Flourish', 't', 'VF'},
}
xivhotbar_keybinds_job['SAM'] = {
    {'battle 3 1', 'ja', 'Sekkanoki', 'me', ''},
    {'battle 3 2', 'ja', 'Meditate', 'me', ''}
}

xivhotbar_keybinds_job['RUN'] = {
    {'battle 1 8', 'ma', 'flash', 'stnpc', ''},
    {'battle 3 1', 'ja', 'Lux', 'me', 'Lux'},
    {'battle 3 2', 'ja', 'vallation', 'me', 'Val.'}
}

xivhotbar_keybinds_job['RDM'] = {
    {'battle 1 8', 'ma', 'dispel', 't', 'Disp.'}
}

return xivhotbar_keybinds_job
