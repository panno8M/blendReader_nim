# bnim

Manipulaing ".blend" with nim.  
Attention! now this lib only supports:
* Read ".blend" file

  ```nim
  block:
    let blend = openBlend("cube.blend")
    defer:
      blend.closeBlend()

    # some action ...

  ```
* Search and extruct the following data:
  * MVert
  * MEdge
  * MPoly
  * MLoop
  * Mesh
  ```nim
  for header in blend.blockHeaders:
    if header.sdnaIndex.getStrcType(blend).name == "Mesh":
      let mesh = accessSingle[Mesh](header.memAddr, blend)[]
      echo access[MVert](mesh.mvert, blend).mapIt(it[])
      echo access[MEdge](mesh.mvert, blend).mapIt(it[])
      echo access[MPoly](mesh.mvert, blend).mapIt(it[])
      echo access[MLoop](mesh.mvert, blend).mapIt(it[])
  ```
* In addition to the above data, it is possible to dump binaly data by searching by type name
  ```nim
  blend.activate()
  for header in blend.blockHeaders:
    if header.sdnaIndex.getStrcType(blend).name == "Camera":
      echo access[array[576, byte]](header.memAddr)
  ```
* As a simplification of functions that require the Blend type as an argument, the argument can be omitted by pre-activationg it. This command is implicitly executed within openBlend()
  ```nim
  var 
    cubeMeshAddr:Vaddr
    icoMeshAddr:Vaddr
  let cube = openBlend("~/cube.blend") # At this time, cube will be activated.
  for header in cube.blockHeaders:
    if header.sdnaIndex.getStrcType().name == "Mesh":
      cubeMeshAddr = header.memAddr
      echo repr accessSingle[Mesh](header.memAddr)[]
  let ico = openBlend("~/ico.blend") # At this thime, ico will be activated.
  for header in cube.blockHeaders:
    if header.sdnaIndex.getStrcType().name == "Mesh":
      icoMeshAddr = header.memAddr
      echo repr accessSingle[Mesh](header.memAddr)[]

  cube.activate() # cube will be activated.

  echo repr accessSingle[Mesh](cubeMeshAddr)[]

  # You can also specify the file to use.
  # In this case, ico will not be activated.
  echo repr accessSingle[Mesh](icoMeshAddr, ico)[]

  ```
