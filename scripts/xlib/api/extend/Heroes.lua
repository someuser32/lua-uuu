---@return {integer: userdata}
function Heroes.GetAllPlayers()
	local heroes = {}
	for _, player in pairs(Players.GetAll()) do
		local hero = Player.GetAssignedHero(player)
		if hero then
			heroes[Player.GetPlayerID(player)] = hero
		end
	end
	return heroes
end