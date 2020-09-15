--[[
        Copyright © 2020, SirEdeonX, Akirane
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivhotbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX OR Akirane BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


--[[ 

    Theme

    Description: Copies content from settings.xml,
    these settings decide how the UI will draw its 
    elements.
--]]

local theme = {}

theme.apply = function (settings)

    local options = {}

    -- Hotbar
    local sh = settings.Hotbar
    options.enable_weapon_switching = sh.EnableWeaponSwitching
    options.show_description        = sh.ShowDescription
    options.hotbar_number           = sh.rows
    options.rows                    = sh.rows
    options.columns                 = sh.columns

    options.hide_empty_slots        = sh.HideEmptySlots
    options.hide_action_names       = sh.HideActionName
    options.hide_action_cost        = sh.HideActionCost
    options.hide_action_element     = sh.HideActionElement
    options.hide_recast_animation   = sh.HideRecastAnimation
    options.hide_recast_text        = sh.HideRecastText
    options.hide_battle_notice      = sh.HideBattleNotice
    options.hide_inventory_count    = sh.HideInventoryCount
	options.environment             = sh.Environment
	options.slot_icon_scale         = sh.SlotIconScale
	options.environment.hook_onto_bar = sh.Environment.HookOntoBar
	options.offsets = {
		['1'] = {Vertical = sh.Offsets.First.Vertical, OffsetX = sh.Offsets.First.OffsetX,  OffsetY = sh.Offsets.First.OffsetY},
		['2'] = {Vertical = sh.Offsets.Second.Vertical, OffsetX = sh.Offsets.Second.OffsetX, OffsetY = sh.Offsets.Second.OffsetY},
		['3'] = {Vertical = sh.Offsets.Third.Vertical, OffsetX = sh.Offsets.Third.OffsetX,  OffsetY = sh.Offsets.Third.OffsetY},
		['4'] = {Vertical = sh.Offsets.Fourth.Vertical, OffsetX = sh.Offsets.Fourth.OffsetX, OffsetY = sh.Offsets.Fourth.OffsetY},
		['5'] = {Vertical = sh.Offsets.Fifth.Vertical, OffsetX = sh.Offsets.Fifth.OffsetX,  OffsetY = sh.Offsets.Fifth.OffsetY},
		['6'] = {Vertical = sh.Offsets.Sixth.Vertical, OffsetX = sh.Offsets.Sixth.OffsetX,  OffsetY = sh.Offsets.Sixth.OffsetY}
	}
    settings.Hotbar = sh

    -- Theme
    local st = settings.Theme
    options.battle_notice_theme     = st.BattleNotice
    options.slot_theme              = st.Slot
    options.frame_theme             = st.Frame

    -- Style
    local ss = settings.Style
    options.slot_opacity            = ss.SlotAlpha
    options.slot_spacing            = ss.SlotSpacing
    options.hotbar_spacing          = ss.HotbarSpacing
    options.offset_x                = ss.OffsetX
    options.offset_y                = ss.OffsetY

    -- Color
    local sc = settings.Color
    options.feedback_max_opacity    = sc.Feedback.Opacity
    options.feedback_speed          = sc.Feedback.Speed
    options.disabled_slot_opacity   = sc.Disabled.Opacity
    options.mp_cost_color_red       = sc.MpCost.Red
    options.mp_cost_color_green     = sc.MpCost.Green
    options.mp_cost_color_blue      = sc.MpCost.Blue
    options.tp_cost_color_red       = sc.TpCost.Red
    options.tp_cost_color_green     = sc.TpCost.Green
    options.tp_cost_color_blue      = sc.TpCost.Blue

    -- Texts
    local st = settings.Texts
    options.font                    = st.Font
    options.font_size               = st.Size
	options.slot_text_size          = st.Size
    options.font_alpha              = st.Color.Alpha
    options.font_color_red          = st.Color.Red
    options.font_color_green        = st.Color.Green
    options.font_color_blue         = st.Color.Blue
    options.font_stroke_width       = st.Stroke.Width
    options.font_stroke_alpha       = st.Stroke.Alpha
    options.font_stroke_color_red   = st.Stroke.Red
    options.font_stroke_color_green = st.Stroke.Green
    options.font_stroke_color_blue  = st.Stroke.Blue
    options.text_offset_x           = st.OffsetX
    options.text_offset_y           = st.OffsetY

    -- Controls
    local sco = settings.Controls
    options.controls_battle_mode = sco.ToggleBattleMode

    return options
end

return theme
