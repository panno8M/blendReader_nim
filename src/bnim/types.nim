import core

type
  MVert* = object
    co*: array[3, float32]
    no*: array[3, int16]
    flag*: byte
    bweight*: byte

  MEdge* = object
    v1*: int32
    v2*: int32
    crease*: byte
    bweight*: byte
    flag*: int16

  MFace* = object
    pad*: array[3, byte]
    v1*: int32
    v2*: int32
    v3*: int32
    v4*: int32
    mat_nr*: int16

  MPoly* = object
    loopstart*: int32
    totloop*: int32
    flag*: int16
    mat_nr*: int16

  MLoop* = object
    v*: uint32
    e*: uint32

  Mesh* = object
    id*: array[176, byte]
    adt*: Vaddr
    ipo*: Vaddr
    key*: Vaddr
    mat*: Vaddr
    mselect*: Vaddr
    mpoly*: Vaddr
    mloop*: Vaddr
    mloopuv*: Vaddr
    mloopcol*: Vaddr
    mface*: Vaddr
    ftface*: Vaddr
    tface*: Vaddr
    mvert*: Vaddr
    medge*: Vaddr
    dvert*: Vaddr
    mcol*: Vaddr
    texcomesh*: Vaddr
    edit_mesh*: Vaddr
    vdata*: array[240, byte]
    edata*: array[240, byte]
    fdata*: array[240, byte]
    pdata*: array[240, byte]
    ldata*: array[240, byte]
    totvert*: int32
    totedge*: int32
    totface*: int32
    totselect*: int32
    totpoly*: int32
    totloop*: int32
    attributes_active_index*: int32
    pad3*: int32
    act_face*: int32
    loc*: array[3, float32]
    size*: array[3, float32]
    texflag*: int16
    flag*: int16
    smoothresh*: float32
    cd_flag*: byte
    pad*: byte
    subdiv*: byte
    subdivr*: byte
    subsurftype*: byte
    editflag*: byte
    totcol*: int16
    remesh_voxel_size*: float32
    remesh_voxel_adaptivity*: float32
    remesh_mode*: byte
    symmetry*: byte
    pad1*: array[2, byte]
    face_sets_color_seed*: int32
    face_sets_color_default*: int32
    runtime*: array[176, byte]
