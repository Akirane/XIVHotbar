
xivhotbar_keybinds_job['Base'] = {
  -- Hotbar #1
  {'b 1 1',  'ma', 'Regen IV', 'stal', 'R.IV'},
  {'b 1 3',  'ma', 'Flash', 'stnpc', 'Flash'},
  {'b 1 4',  'ja', 'Lunge', 't', 'Lunge'},
  {'b 1 5',  'ma', 'temper', 'me', ''},
  {'b 1 6',  'ma', 'Protect IV', 'stal', ''},
  {'b 1 7',  'ma', 'Shell V', 'stal', ''},
  {'b 1 8',  'ma', 'Phalanx', 'me','Phal.'},
  {'b 1 9',  'ma', 'Ice Spikes', 'me','Ice.Sp.'},
  {'b 1 10', 'ws', 'Dimidiation', 't', 'Dimi.'},
  -- Hotbar #2
  {'b 2 1',  'gs', 'equip movement', '', 'Move.'},
  {'b 2 2',  'ma', 'Crusade', 'me', 'Crus.'},
  {'b 2 3',  'ja', 'Ignis', 'me', 'Ignis', 'ignis-icon'},
  {'b 2 4',  'ja', 'Gelus', 'me', 'Gelus', 'gelus-icon'},
  {'b 2 5',  'ja', 'Flabra', 'me', 'Flabra', 'flabra-icon'},
  {'b 2 6',  'ja', 'Tellus', 'me', 'Tel.', 'tellus-icon'},
  {'b 2 7',  'ja', 'Sulpor', 'me', 'Sul.', 'sulpor-icon'},
  {'b 2 8',  'ja', 'Unda', 'me', 'Und.', 'unda-icon'},
  {'b 2 9',  'ja', 'Lux', 'me', 'Lux', 'lux-icon'},
  {'b 2 10','ja', 'Tenebrae', 'me', 'Ten.', 'tenebrae-icon'},
  -- Hotbar #3
  {'b 3 10', 'ma', 'Stoneskin', 'me', 'SS'},
  {'b 3 1',  'ja', 'Gambit', 't', 'Gamb.', 'gambit-icon'},
  {'b 3 2',  'ja', 'Pflug', 'me', 'Pflug', 'pflug-icon'},
  {'b 3 3',  'ja', 'Valiance', 'me', 'Vali.', 'shellra'},
  {'b 3 4',  'ja', 'Liement', 'me', 'Lie.', 'liement-icon'},
  {'b 3 5',  'ja', 'Battuta', 'me', 'Bat.', 'battuta-icon'},
  {'b 3 6',  'ma', 'Foil', 'me', 'Foil', 'foil-icon'},
  {'b 3 7',  'gs', 'equip exp;wait 1;gs disable back', '', 'exp'},
  {'b 1 11',  'gs', 'enable back', '', 'back'},
  {'b 3 8',  'ws', 'Resolution', 't', 'Res.'},
  {'b 4 5',  'ma', 'stun', 'stnpc', 'Stun.'},
  {'b 3 9',  'ma', 'Blink', 'me', ''},
  {'b 4 1',  'ma', 'Refresh', 'me', 'Ref.'},
  {'b 4 2',  'ma', 'Aquaveil', 'me', ''},
  {'b 4 3',  'ja', 'Vallation', 'me', 'Val.'},
  {'b 4 4',  'ma', 'Poisonga', 'stnpc', 'Pois.'},
  {'b 4 6',  'ws', 'Upheaval', 't', 'Uph.'},
  {'b 4 7',  'gs', 'equip engaged[\'DT\']', '', 'DT'},
  {'b 4 8',  'gs', 'equip engaged', '', 'DPS'},
  {'b 4 9',  'ja', 'vivacious pulse', 'me', 'Pulse', 'pulse-icon'},
  {'b 4 10', 'ja', 'One for All', 'me', 'OFA', 'shellra'},
  {'b 4 12',  'ws', 'fell cleave', 'stnpc', 'FC'},
  {'b 1 12',  'gs', 'equip idle', '', 'Idle'},
  {'b 4 11',  'gs', 'equip magic_def', '', 'MDef'},
  {'f 1 5',  'ma', 'Protect V', 'stal', 'Pro.V'},
  {'f 1 6',  'ma', 'Shell V', 'stal', 'She.V'},
}

xivhotbar_keybinds_job['DRK'] = {
  {'b 1 2',  'ma', 'Stun', 'stnpc', 'Stun'},
  {'b 3 7',  'ja', 'Last Resort', 'me', 'L.R.'},
  {'b 3 8',  'ja', 'Souleater', 'me', 'S.E'}
}
xivhotbar_keybinds_job['WAR'] = {
  {'b 1 2',  'ja', 'Provoke', 'stnpc', 'Prov.'},
  {'b 5 3',  'ja', 'Berserk', 'me', 'Ber.'},
  {'b 3 8',  'ja', 'Warcry', 'me', 'War.'},
  {'b 5 2',  'ws', 'Ground Strike', 't', 'GS'}
}
xivhotbar_keybinds_job['SAM'] = {
  {'b 1 2',  'ja', 'Hasso', 'me', 'Has.'},
  {'b 4 9',  'ja', 'Meditate', 'me', 'Med.'},
  {'b 4 10', 'ja', 'Sekkanoki', 'me', 'Sek.'},
  {'b 5 2',  'ws', 'steel cyclone', 't', 'SC'},
  {'b 5 3',  'ja', 'swipe', 't', 'swipe', 'sulpor-icon'},
  {'b 5 4',  'ws', 'ground strike', 't', 'gs'},
}
xivhotbar_keybinds_job['BLU'] = {
  {'b 1 2',  'ma', 'Blank Gaze', 't', 'Blank'},
  {'b 2 1',  'ma', 'Cocoon', 'me', 'Coc.'},
  {'b 3 11',  'ma', 'jettatura', 'stnpc', 'Jet.'},
  {'b 3 12',  'ma', 'sheep song', 'stnpc', 'Sheep'},
  {'b 2 11',  'ma', 'geist wall', 'stnpc', 'Geist'},
}

return xivhotbar_keybinds_job
