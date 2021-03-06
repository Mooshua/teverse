-- Copyright (c) 2019 teverse.com
-- ui.lua

local uiController = {}
local themeController = require("tevgit:create/controllers/theme.lua")
local toolsController = require("tevgit:create/controllers/tool.lua")

uiController.create = function(className, parent, properties, style)
    local gui = engine.construct(className, parent, properties)
    themeController.add(gui, style and style or "default")
    return gui
end

uiController.createFrame = function(parent, properties, style)
    local gui = uiController.create("guiFrame", parent, properties, style)
    return gui
end

local function spinCb()
    if not uiController.loadingFrame.visible then
        uiController.loadingTween.tweenObject.rotation = 0
        uiController.loadingTween:restart()
    end
end

uiController.setLoading = function(loading, message)
    if not uiController.loadingFrame then return end
    if loading then
        uiController.loadingFrame.visible = true
        uiController.loadingFrame.loadingMessage.text = message and message or "Loading"
        spinCb()
    else
        uiController.loadingFrame.visible = false
    end
end

uiController.createMainInterface = function(workshop)
    uiController.loadingFrame = uiController.create("guiFrame", workshop.interface, {
                                name = "loadingFrame",
                                size = guiCoord(0,300,0,100),
                                position = guiCoord(0.5,-150,0.5,-50),
                                guiStyle = enums.guiStyle.rounded
                            }, "main")

    uiController.create("guiTextBox", uiController.loadingFrame, {
        name = "loadingMessage",
        position = guiCoord(0, 10, 0.5, 0),
        size = guiCoord(1, -20, 0.5, -10),
        align = enums.align.middle,
        fontSize = 21,
        guiStyle = enums.guiStyle.noBackground,
        text = "Loading, maybe dont touch anything rn."
    }, "main")

    local loadingImage = uiController.create("guiImage", uiController.loadingFrame, {
        name = "loadingImage",
        position = guiCoord(0.5, -15, .333, -15),
        size = guiCoord(0, 30, 0, 30),
        texture = "fa:s-cog"
    }, "main")
    uiController.loadingTween = engine.tween:create(loadingImage, 1, {rotation = 360}, "inOutQuad", spinCb)

    local sideBar = uiController.createFrame(workshop.interface, {
        name = "toolbars",
        size = guiCoord(0,46,1,0),
        position = guiCoord(0,10,0,70)
    }, "main")
    
    uiController.topBar = uiController.createFrame(workshop.interface, {
        name = "topbar",
        size = guiCoord(1, 0, 0, 60),
        position = guiCoord(0,0,0,0)
    }, "main")

    toolsController.container = sideBar
    toolsController.workshop = workshop
    toolsController.ui = uiController

    toolsController.registerMenu("topBar", uiController.topBar)
    local saveBtn = toolsController.createButton("topBar", "fa:s-save", "Save")
    local saveAsBtn = toolsController.createButton("topBar", "fa:r-save", "Save As")
    local openBtn = toolsController.createButton("topBar", "fa:s-folder-open", "Open")
    local publishBtn = toolsController.createButton("topBar", "fa:s-cloud-upload-alt", "Publish")

    --[[
    local function checkIfPublishable()
        settingsBar.btn.visible = (engine.workshop.gameFilePath ~= "")
        settingsBar.publishNote.text = (engine.workshop.gameFilePath == "" and "You need to save this game before publishing." or "This file isn't linked to the TevCloud.")
        settingsBar.btn.label.text = (engine.workshop.gameCloudId == "" and "Publish" or "Update")

        if engine.workshop.gameCloudId ~= "" then
            settingsBar.publishNote.text = "This is a TevCloud project."
        end
    end

    checkIfPublishable()
    engine.workshop:changed(checkIfPublishable)
    ]]

    saveBtn:mouseLeftReleased(function()
        workshop:saveGame()
    end)
    saveAsBtn:mouseLeftReleased(function()
        workshop:saveGameAsDialogue()
    end)
    openBtn:mouseLeftReleased(function()
        workshop:openFileDialogue()
    end)
    publishBtn:mouseLeftReleased(function ()
        workshop:publishDialogue()
    end)
end

return uiController
