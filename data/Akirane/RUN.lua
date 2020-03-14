
xivhotbar_keybinds_job['Base'] = {
  -- Hotbar #1
  {'battle 1 1', 'ma', 'Regen IV', 'stal', 'R.IV'},
  {'battle 1 3', 'ma', 'Flash', 't', 'Flash'},
  {'battle 1 4', 'ja', 'Lunge', 't', 'Lunge'},
  {'battle 1 5', 'ja', 'Swordplay', 'me', 'Swrd.'},
  {'battle 1 6', 'ma', 'Shell V', 'stal', 'Shl.5'},
  {'battle 1 7', 'ma', 'Phalanx II', 'stal', 'Ph.2'},
  {'battle 1 8', 'ma', 'Phalanx', 'me','Phal.'},
  {'battle 1 9', 'ma', 'Ice Spikes', 'me','Ice.Sp.'},
  {'battle 1 10', 'ws', 'Resolution', 't', 'Res.'},
  -- Hotbar #2
  {'battle 2 1', 'ja', 'Composure', 'me', 'Comp.'},
  {'battle 2 2', 'ma', 'Crusade', 'me', 'Crus.'},
  {'battle 2 3', 'ja', 'Ignis', 'me', 'Ignis'},
  {'battle 2 4', 'ja', 'Gelus', 'me', 'Gelus'},
  {'battle 2 5', 'ja', 'Flabra', 'me', 'Flabra'},
  {'battle 2 6', 'ja', 'Tellus', 'me', 'Tel.'},
  {'battle 2 7', 'ja', 'Sulpor', 'me', 'Sul.'},
  {'battle 2 8', 'ja', 'Unda', 'me', 'Unda'},
  {'battle 2 9', 'ja', 'Lux', 'me', 'Lux'},
  {'battle 2 10','ja', 'Tenebrae', 'me', 'Ten.'},
  -- Hotbar #3
  -- It's now possible to use your own custom images by adding a 6th argument
  {'battle 3 1', 'ja', 'Vallation', 'me', 'Vall.', 'cog'},
  {'battle 3 2', 'ja', 'Pflug', 'me', 'Pflug'},
  {'battle 3 3', 'ja', 'Valiance', 'me', 'Vali.'},
  {'battle 3 4', 'ja', 'Liement', 'me', 'Lie.'},
  {'battle 3 5', 'ma', 'Battuta', 'me', 'Bat.'},
  {'battle 3 6', 'ct', '/htb macro', 'me', 'SCH SC', 'attack'},
  {'f 1 5', 'ma', 'Protect V', 'stal', 'Pro.V'},
  {'f 1 6', 'ma', 'Shell V', 'stal', 'She.V'}
}

xivhotbar_keybinds_job['DRK'] = {
  {'battle 1 2', 'ma', 'Stun', 't', 'Stun'},
  {'battle 3 7', 'ja', 'Last Resort', 'me', 'L.R.'},
  {'battle 3 8', 'ja', 'Souleater', 'me', 'S.E'}
}

----------------------
-- User defined macros 
----------------------
--
-- Idea here is you should be able to define your 
-- own macros through functions in job files. Right now an exact copy 
-- of this function is shown at line 36 in xivhotbar.lua called 
-- sch_skillchain(). It only prints out two lines 
-- with a one second delay, but I think this example should be
-- sufficient to create your own macro.
function xivhotbar_keybinds_job:sch_skillchain()
	windower.chat.input('/party greetings no. 1')
	coroutine.sleep(1)
	windower.chat.input('/party greetings no. 2')
end

return xivhotbar_keybinds_job
