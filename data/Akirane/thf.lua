
-- Load and initialize the include file.
xivhotbar_keybinds_job['Base'] = {

    {'b 1 1',  'ja', 'Sneak Attack', 'me', 'Sneak'},
    {'b 1 2',  'ja', 'Trick Attack', 'me', 'Trick'},
    {'b 1 3',  'ja', 'Steal', 'stnpc', 'Steal'},
    {'b 1 4',  'ja', 'Mug', 't', 'Mug'},
    {'b 1 5',  'ja', 'Flee', 'me', 'Flee'},
    {'b 1 6',  'ja', 'Assassin\'s Charge', 'me', 'A. Chg.'},
    {'b 1 7',  'ja', 'Collaborator', 'stal', 'Col.'},
    {'b 1 9',  'ja', 'Accomplice', 'stal', 'Acc.'},

    {'b 2 9',  'gs', 'equip engaged[\'Hybrid\']', '', 'Hybr.'},
    {'b 2 0',  'gs', 'equip engaged', '', 'Norm.'},
    {'b 2 3',  'ja', 'Despoil', 't', 'Desp.'},
    {'b 2 4',  'ja', 'Bully', 'stnpc', 'Bully'},
    {'b 2 5',  'ja', 'Hide', 'me', 'Hide'},
    {'b 2 6',  'ra', '', 't', 'RA'},

    {'b 4 1',  'ja', 'Feint', 'me', 'Feint'},
    {'b 4 2',  'ja', 'Conspirator', 'me', 'Cons.'},

    {'b 5 9',  'gs', 'equip engaged[\'ERegen\']', '', 'EReg.'},
    {'b 5 0',  'ct', '/send @all lua exec get_pt', '', 'exec'},

}

xivhotbar_keybinds_job['Dagger'] = {

    {'b 2 1',  'ws', 'Aeolian Edge', 't', 'A.E.'},
    {'b 2 2',  'ws', 'Rudra\'s Storm', 't', 'RS'},
    {'b 2 8',  'ws', 'Evisceration', 'stnpc', 'Evi.'},

    {'b 3 0',  'ws', 'Exenterator', 't', 'Ext.'},

    {'b 4 7',  'ws', 'Empyreal Arrow', 't', 'EA'},
    {'b 4 9',  'ws', 'Mandalic Stab', 't', 'MB'},
}

xivhotbar_keybinds_job['Sword'] = {

    {'b 2 8',  'ws', 'Savage Blade', 't', 'SB'},
}

xivhotbar_keybinds_job['WAR'] = {

    {'b 1 0',  'ja', 'Provoke', 'stnpc', ''},

	{'b 3 1',  'ja', 'Warcry', 'me', 'Warcry'},
	{'b 3 2',  'ja', 'Berserk', 'me', 'Ber.'},
	{'b 3 3',  'ja', 'Aggressor', 'me', 'Agg.'},
}

xivhotbar_keybinds_job['NIN'] = {

	{'b 3 7',  'ma', 'utsusemi: ichi', 'me', 'U.Ich.'},
	{'b 3 1',  'ma', 'utsusemi: ni', 'me', 'U.Ni'},
	{'b 3 2',  'ma', 'Tonko: Ni', 'me','Invis'},
	{'b 3 3',  'ma', 'Monomi: Ichi', 'me', 'Sneak'}
}
xivhotbar_keybinds_job['DNC'] = {

    {'b 1 0',  'ja', 'Healing Waltz', 'stal', 'HW'},
    {'b 1 8',  'ja', 'Drain Samba ii', 'me', 'DS'},
    {'b 3 1',  'ja', 'Animated Flourish', 't', 'AF'},
    {'b 3 2',  'ja', 'Box Step', 't', 'Bx.St.'},
    {'b 3 3',  'ja', 'Spectral Jig', 'me', 'Spc.J.'},
    {'b 3 4',  'ja', 'Curing Waltz III', 'stal', 'Cw.III'},
    {'b 4 3',  'ja', 'Violent Flourish', 't', 'VF'},
}
xivhotbar_keybinds_job['SAM'] = {

    {'b 3 1',  'ja', 'Sekkanoki', 'me', ''},
    {'b 3 2',  'ja', 'Meditate', 'me', ''}
}

xivhotbar_keybinds_job['RUN'] = {

    {'b 1 8',  'ma', 'flash', 'stnpc', ''},
    {'b 3 1',  'ja', 'Lux', 'me', 'Lux'},
    {'b 3 2',  'ja', 'vallation', 'me', 'Val.'}
}

xivhotbar_keybinds_job['RDM'] = {

    {'b 1 8',  'ma', 'dispel', 't', 'Disp.'}
}

return xivhotbar_keybinds_job
