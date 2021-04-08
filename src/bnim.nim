import bnim/[core, types, stringify]

export core, types, stringify

when isMainModule:
  block:
    let blend = openBlend("cube.blend")
    defer:
      blend.closeBlend()

    for header in blend.blockHeaders:
      if header.sdnaIdx.getStrcType().name == "Mesh":
        let mesh = accessSingle[Mesh](header.memAddr)[]
        echo repr mesh
        echo access[MVert](mesh.mvert)
        echo access[MPoly](mesh.mpoly)
        echo access[MLoop](mesh.mloop)
