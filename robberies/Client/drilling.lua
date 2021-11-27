Scaleforms = exports["meta_libs"]:Scaleforms()

Drilling = {}

LockboxAnimation = {
  ['objects'] = {},
  ['scenes'] = {},
}

function loadAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
      RequestAnimDict(dict)
      Citizen.Wait(0)
  end
end

function loadModel(model)
  if type(model) == 'number' then
      model = model
  else
      model = GetHashKey(model)
  end
  while not HasModelLoaded(model) do
      RequestModel(model)
      Citizen.Wait(0)
  end
end

local cam = nil
local pedCo, pedRotation = nil

Drilling.DisabledControls = {30,31,32,33,34,35}

Drilling.Start = function(callback)
  if not Drilling.Active then
    Drilling.Active = true
    Drilling.Init()
    Drilling.Update(callback)
  end
end

Drilling.Init = function()
  if Drilling.Scaleform then
    Scaleforms.UnloadMovie(Drilling.Scaleform)
  end

  Drilling.Scaleform = Scaleforms.LoadMovie("DRILLING")

  
  Drilling.DrillSpeed = 0.0
  Drilling.DrillPos   = 0.0
  Drilling.DrillTemp  = 0.0
  Drilling.HoleDepth  = 0.0
  

  Scaleforms.PopFloat(Drilling.Scaleform,"SET_SPEED",           0.0)
  Scaleforms.PopFloat(Drilling.Scaleform,"SET_DRILL_POSITION",  0.0)
  Scaleforms.PopFloat(Drilling.Scaleform,"SET_TEMPERATURE",     0.0)
  Scaleforms.PopFloat(Drilling.Scaleform,"SET_HOLE_DEPTH",      0.0)

  ped = PlayerPedId()
  pedCo, pedRotation = GetEntityCoords(ped), vector3(0.0, 0.0, 0.0)
  local animDict = 'anim_heist@hs3f@ig10_lockbox_drill@pattern_01@lockbox_01@male@'
  loadAnimDict(animDict)


  for k, v in pairs(Lockbox['objects']) do
    loadModel(v)
    LockboxAnimation['objects'][k] = CreateObject(GetHashKey(v), pedCo, 1, 0, 0)
  end

  -- cam = CreateCam("DEFAULT_ANIMATED_CAMERA", true)
  -- SetCamActive(cam, true)
  -- RenderScriptCams(true, 0, 3000, 1, 0)

  local safe = GetClosestObjectOfType(pedCo, 1.5, -1375589668)
  local offset = vector3(-0.08245002, 0.04296779, -0.6669331)
  local animCoords = GetOffsetFromEntityInWorldCoords(safe, offset)
    for i = 1, #Lockbox['animations'] do   
        LockboxAnimation['scenes'][i] = NetworkCreateSynchronisedScene(animCoords, GetEntityRotation(safe), 2, true, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(ped, LockboxAnimation['scenes'][i], animDict, Lockbox['animations'][i][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
        NetworkAddEntityToSynchronisedScene(LockboxAnimation['objects'][1], LockboxAnimation['scenes'][i], animDict, Lockbox['animations'][i][3], 1.0, -1.0, 1148846080)
        NetworkAddEntityToSynchronisedScene(LockboxAnimation['objects'][2], LockboxAnimation['scenes'][i], animDict, Lockbox['animations'][i][4], 1.0, -1.0, 1148846080)
    end

  NetworkStartSynchronisedScene(LockboxAnimation['scenes']['1'])
  -- PlayCamAnim(cam, 'enter_cam', 'anim_heist@hs3f@ig10_lockbox_drill@pattern_01@lockbox_01@male@', pedCo.x, pedCo.y, pedCo.z - 1.0, pedRotation, 0, 2)
  Wait(GetAnimDuration(animDict, 'enter') * 1000)

end

Drilling.Update = function(callback)
  while Drilling.Active do
    Drilling.Draw()
    Drilling.DisableControls()
    Drilling.HandleControls()
    Wait(0)
  end
  callback(Drilling.Result)
end

Drilling.Draw = function()
  DrawScaleformMovieFullscreen(Drilling.Scaleform,255,255,255,255,255)
end

Drilling.HandleControls = function()
  local last_pos = Drilling.DrillPos
  if IsControlJustPressed(0,172) then
    Drilling.DrillPos = math.min(1.0,Drilling.DrillPos + 0.01)
  elseif IsControlPressed(0,172) then
    Drilling.DrillPos = math.min(1.0,Drilling.DrillPos + (0.1 * GetFrameTime() / (math.max(0.1,Drilling.DrillTemp) * 10)))
  elseif IsControlJustPressed(0,173) then
    Drilling.DrillPos = math.max(0.0,Drilling.DrillPos - 0.01)
  elseif IsControlPressed(0,173) then
    Drilling.DrillPos = math.max(0.0,Drilling.DrillPos - (0.1 * GetFrameTime()))
  end

  local last_speed = Drilling.DrillSpeed
  if IsControlJustPressed(0,175) then
    Drilling.DrillSpeed = math.min(1.0,Drilling.DrillSpeed + 0.05)
  elseif IsControlPressed(0,175) then
    Drilling.DrillSpeed = math.min(1.0,Drilling.DrillSpeed + (0.5 * GetFrameTime()))
  elseif IsControlJustPressed(0,174) then
    Drilling.DrillSpeed = math.max(0.0,Drilling.DrillSpeed - 0.05)
  elseif IsControlPressed(0,174) then
    Drilling.DrillSpeed = math.max(0.0,Drilling.DrillSpeed - (0.5 * GetFrameTime()))
  end

  local last_temp = Drilling.DrillTemp
  if last_pos < Drilling.DrillPos then
    RequestAnimDict('anim@heists@fleeca_bank@drilling')
    if Drilling.DrillSpeed > 0.4 then
      Drilling.DrillTemp = math.min(1.0,Drilling.DrillTemp + ((0.05 * GetFrameTime()) *  (Drilling.DrillSpeed * 10)))
      Scaleforms.PopFloat(Drilling.Scaleform,"SET_DRILL_POSITION",Drilling.DrillPos)
      NetworkStartSynchronisedScene(LockboxAnimation['scenes']['2'])
      -- PlayCamAnim(cam, 'action_cam', 'anim_heist@hs3f@ig10_lockbox_drill@pattern_01@lockbox_01@male@', pedCo.x, pedCo.y, pedCo.z - 1.0, pedRotation, 0, 2)
    else
      if Drilling.DrillPos < 0.1 or Drilling.DrillPos < Drilling.HoleDepth then
        Scaleforms.PopFloat(Drilling.Scaleform,"SET_DRILL_POSITION",Drilling.DrillPos)
        NetworkStartSynchronisedScene(LockboxAnimation['scenes']['1'])
      else
        Drilling.DrillPos = last_pos
        Drilling.DrillTemp = math.min(1.0,Drilling.DrillTemp + (0.01 * GetFrameTime()))
      end
    end
  else
    if Drilling.DrillPos < Drilling.HoleDepth then
      Drilling.DrillTemp = math.max(0.0,Drilling.DrillTemp - ( (0.05 * GetFrameTime()) *  math.max(0.005,(Drilling.DrillSpeed * 10) /2)) )
    end

    if Drilling.DrillPos ~= Drilling.HoleDepth then
      Scaleforms.PopFloat(Drilling.Scaleform,"SET_DRILL_POSITION",Drilling.DrillPos)
    end
  end

  if last_speed ~= Drilling.DrillSpeed then
    Scaleforms.PopFloat(Drilling.Scaleform,"SET_SPEED",Drilling.DrillSpeed)
  end

  if last_temp ~= Drilling.DrillTemp then    
    Scaleforms.PopFloat(Drilling.Scaleform,"SET_TEMPERATURE",Drilling.DrillTemp)
  end

  if Drilling.DrillTemp >= 1.0 then
    Drilling.Result = false
    Drilling.Active = false
    endDrilling()
  elseif Drilling.DrillPos >= 1.0 then
    Drilling.Result = true
    Drilling.Active = false
    endDrilling()
  end

  Drilling.HoleDepth = (Drilling.DrillPos > Drilling.HoleDepth and Drilling.DrillPos or Drilling.HoleDepth)
end

Drilling.DisableControls = function()
  for _,control in ipairs(Drilling.DisabledControls) do
    DisableControlAction(0,control,true)
  end
end

Drilling.EnableControls = function()
  for _,control in ipairs(Drilling.DisabledControls) do
    DisableControlAction(0,control,true)
  end
end

function endDrilling()
  ClearPedTasks(ped)
  RenderScriptCams(false, false, 0, 1, 0)
  DestroyCam(cam, false)
  for k, v in pairs(LockboxAnimation['objects']) do
      DeleteObject(v)
  end 
end 

AddEventHandler("Drilling:Start",Drilling.Start)