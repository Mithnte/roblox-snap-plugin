return {
        gridSteps = {0.25, 0.5, 1},
        rotateStepsDeg = {15, 45},

        defaultGridStep = 0.5,
        defaultRotateStepDeg = 15,

        gridSnapEnabled = true,
        rotateSnapEnabled = true,

        pivotMode = "World", -- "World" | "Local"

        vertexSnapEnabled = false,
        vertexSnapThreshold = 1.5,
        edgeSnapThreshold = 1,

        keymap = require(script.Hotkeys),
}
