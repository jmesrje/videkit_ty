--[[

Buttons are used to convey actions a user can perform.

]]

local vide = require(script.Parent.Parent.Parent.roblox_packages.vide)
local color = require(script.Parent.Parent.util.color)
local container = require(script.Parent.container)
local padding = require(script.Parent.padding)

local create = vide.create
local source = vide.source
local spring = vide.spring
local changed = vide.changed
local read = vide.read

type can<T> = T | () -> T
type button = {
	primary: can<boolean>?,
	disabled: can<boolean>?,
	text: can<string>,

	activated: (() -> ())?,

	layout: vide.vTextButton?,
	layout_text: vide.vTextLabel?,
	child: vide.vFrame?,

	_custom: can<any>?,
	_noborder: can<boolean>?,
	_selected: can<boolean>?,
	_nopadding: can<boolean>?,
	_nocorner: can<boolean>?,

}

local function button(props: button)

	local primary = props.primary
	local gui_state = source(Enum.GuiState.Idle)
	local disabled = props.disabled or false

	local no_padding = props._nopadding
	local no_border = props._noborder
	local no_corner = props._nocorner
	local selected = props._selected

	local function modifier()
		return
			if gui_state() == Enum.GuiState.NonInteractable then "Disabled"
			elseif read(selected) then "Selected"
			elseif gui_state() == Enum.GuiState.Press then "Pressed"
			elseif gui_state() == Enum.GuiState.Hover then "Hover"
			else "Default"
		
	end

	return create "TextButton" {

		Size = UDim2.new(1, 0, 0, 24),
		AutomaticSize = Enum.AutomaticSize.Y,

		Interactable = function()
			return not read(disabled)
		end,

		BackgroundColor3 = spring(color(props._custom or function()
			return if read(primary) then "MainButton" else "Button"
		end, modifier), 1/12, 1),
		AutoButtonColor = false,

		Activated = props.activated,

		create "UICorner" {
			CornerRadius = function()
				return if read(no_corner) then UDim.new() else UDim.new(0, 4)
			end,
		},

		create "UIStroke" {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = color(function()
				return if read(primary) then "MainButton" else "Border"
			end, "Pressed"),
			Enabled = function()
				return not read(no_border)
			end
		},

		container {

			create "TextLabel" {

				AutomaticSize = Enum.AutomaticSize.XY,
				Position = UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),

				BackgroundTransparency = 1,

				Text = props.text,
				TextColor3 = color(function()
					return if read(primary) then "BrightText" else "ButtonText"
				end),
				Font = Enum.Font.SourceSans,
				TextSize = 16,

				props.layout_text
			},

			props.child,
		},

		function()
			if read(no_padding) then return {} end
			return padding {
				padding = UDim.new(0, 6)
			}
		end,

		changed("GuiState", gui_state),

		props.layout

	}
	
end

return button