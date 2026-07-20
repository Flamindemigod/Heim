Heim = Heim or {};

function Heim.ZOFixes()
    function ZO_Scene:AddFragment_(fragment)
        if not self:HasFragment(fragment) then
            table.insert(self.fragments, fragment);
            fragment:SetSceneManager(self.sceneManager);
            fragment:Refresh();
        end
    end

    function ZO_Scene:AddFragment(fragment)
        if (Heim.scenes[self.name] ~= nil) then
            local fragName = HeimUtils.GetFragmentName(fragment);
            if (fragName == nil) then return nil; end
            Heim.scenes[self.name].fragmentList[fragName] = fragment;
            return;
        end
        self:AddFragment_(fragment);
    end

    function ZO_Scene:RemoveFragment_(fragment)
        for i = 1, #self.fragments do
            if (self.fragments[i] == fragment) then
                table.remove(self.fragments, i);
                fragment:Refresh();
                break
            end
        end
    end

    function ZO_Scene:RemoveFragment(fragment)
        if (Heim.scenes[self.name] ~= nil) then
            local fragName = HeimUtils.GetFragmentName(fragment);
            if (fragName == nil) then return nil; end
            Heim.scenes[self.name].fragmentList[fragName] = nil;
        end
        self:RemoveFragment_(fragment);
    end
    function ACTIVITY_TRACKER:RefreshAnchors() end
    function ZO_Synergy:OnSynergyAbilityChanged()
        local hasSynergy, synergyName, iconFilename, prompt =
            GetCurrentSynergyInfo();
        if hasSynergy then
            if self.lastSynergyName ~= synergyName then
                PlaySound(SOUNDS.ABILITY_SYNERGY_READY)
                self.action:SetHidden(true);
                self.key:SetHidden(true);
                self.lastSynergyName = synergyName
            end

            self.icon:SetTexture(iconFilename);

            SHARED_INFORMATION_AREA:SetHidden(self, false);
        else
            SHARED_INFORMATION_AREA:SetHidden(self, true);
            self.lastSynergyName = nil;
        end
    end
    -- Default UI Fragment. its a bit weird because it messes with a bunch of stuff in globla scope through methods and doesnt have any attributes itself;
    Heim.scenes.hud.scene:AddFragment_(HUD_FRAGMENT);
    -- https://github.com/esoui/esoui/blob/8c7b5f9c0bf1f35ac3dc2cfd3457f47e26f55880/esoui/ingame/scenes/ingamefragments.lua#L1079
    Heim.scenes.hud.scene:AddFragment_(HOUSING_HUD_ACTION_LAYER_FRAGMENT);
    Heim.scenes.hudui.scene:AddFragment_(HOUSING_HUD_ACTION_LAYER_FRAGMENT);
    Heim.scenes.hud.scene:AddFragment_(BATTLEGROUND_HUD_ACTION_LAYER_FRAGMENT);
    Heim.scenes.hudui.scene:AddFragment_(BATTLEGROUND_HUD_ACTION_LAYER_FRAGMENT);
    Heim.scenes.hud.scene:AddFragment_(SPECTATOR_CAMERA_ACTION_LAYER_FRAGMENT);
    Heim.scenes.hudui.scene:AddFragment_(SPECTATOR_CAMERA_ACTION_LAYER_FRAGMENT);
end
